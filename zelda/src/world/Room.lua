--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Room = Class{}

function Room:init(player)
    self.width = MAP_WIDTH
    self.height = MAP_HEIGHT

    self.tiles = {}
    self:generateWallsAndFloors()

    -- entities in the room
    self.entities = {}
    self:generateEntities()

    -- game objects in the room
    self.objects = {}
    self:generateObjects()

    -- doorways that lead to other dungeon rooms
    self.doorways = {}
    table.insert(self.doorways, Doorway('top', false, self))
    table.insert(self.doorways, Doorway('bottom', false, self))
    table.insert(self.doorways, Doorway('left', false, self))
    table.insert(self.doorways, Doorway('right', false, self))

    -- reference to player for collisions, etc.
    self.player = player

    -- used for centering the dungeon rendering
    self.renderOffsetX = MAP_RENDER_OFFSET_X
    self.renderOffsetY = MAP_RENDER_OFFSET_Y

    -- used for drawing when this room is the next room, adjacent to the active
    self.adjacentOffsetX = 0
    self.adjacentOffsetY = 0
    self.projectiles = {}
end

--[[
    Randomly creates an assortment of enemies for the player to fight.
]]
function Room:generateEntities()
    local types = {'skeleton', 'slime', 'bat', 'ghost', 'spider'}

    for i = 1, 10 do
        local type = types[math.random(#types)]

        table.insert(self.entities, Entity {
            animations = ENTITY_DEFS[type].animations,
            walkSpeed = ENTITY_DEFS[type].walkSpeed or 20,

            -- ensure X and Y are within bounds of the map
            x = math.random(MAP_RENDER_OFFSET_X + TILE_SIZE,
                VIRTUAL_WIDTH - TILE_SIZE * 2 - 16),
            y = math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE,
                VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16),
            
            width = 16,
            height = 16,

            health = ENTITY_DEFS[type].health
        })

        self.entities[i].stateMachine = StateMachine {
            ['walk'] = function() return EntityWalkState(self.entities[i]) end,
            ['idle'] = function() return EntityIdleState(self.entities[i]) end
        }

        self.entities[i]:changeState('walk')
    end
end

--[[
    Randomly creates an assortment of obstacles for the player to navigate around.
]]
function Room:generateObjects()
    table.insert(self.objects, GameObject(
        GAME_OBJECT_DEFS['switch'],
        math.random(MAP_RENDER_OFFSET_X + TILE_SIZE,
                    VIRTUAL_WIDTH - TILE_SIZE * 2 - 16),
        math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE,
                    VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16)
    ))

    local switch = self.objects[1]

    -- define a function for the switch that will open all doors in the room
    switch.onCollide = function()
        if switch.state == 'unpressed' then
            switch.state = 'pressed'
            
            -- open every door in the room if we press the switch
            for k, doorway in pairs(self.doorways) do
                doorway.open = true
            end

            gSounds['door']:play()
        end
    end

    -- add to list of objects in scene (only one switch for now)
    local potsinplay = math.random(3, 8)
    for i = 0, potsinplay do
        table.insert(self.objects, GameObject(GAME_OBJECT_DEFS['pot'],
            math.random(MAP_RENDER_OFFSET_X + TILE_SIZE + 16,
                VIRTUAL_WIDTH - TILE_SIZE * 2 - 32),
            math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE,
                VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 32) 
        ))
    end

    local chestsinplay = math.random(8, 10)
    for chest = 0, chestsinplay do
        table.insert(self.objects, GameObject(GAME_OBJECT_DEFS['chest'],
            math.random(MAP_RENDER_OFFSET_X + TILE_SIZE + 16, VIRTUAL_WIDTH - TILE_SIZE * 2 - 32),
            math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE, VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 32)
        ))
    end

end

--[[
    Generates the walls and floors of the room, randomizing the various varieties
    of said tiles for visual variety.
]]
function Room:generateWallsAndFloors()
    for y = 1, self.height do
        table.insert(self.tiles, {})

        for x = 1, self.width do
            local id = TILE_EMPTY

            if x == 1 and y == 1 then
                id = TILE_TOP_LEFT_CORNER
            elseif x == 1 and y == self.height then
                id = TILE_BOTTOM_LEFT_CORNER
            elseif x == self.width and y == 1 then
                id = TILE_TOP_RIGHT_CORNER
            elseif x == self.width and y == self.height then
                id = TILE_BOTTOM_RIGHT_CORNER
            
            -- random left-hand walls, right walls, top, bottom, and floors
            elseif x == 1 then
                id = TILE_LEFT_WALLS[math.random(#TILE_LEFT_WALLS)]
            elseif x == self.width then
                id = TILE_RIGHT_WALLS[math.random(#TILE_RIGHT_WALLS)]
            elseif y == 1 then
                id = TILE_TOP_WALLS[math.random(#TILE_TOP_WALLS)]
            elseif y == self.height then
                id = TILE_BOTTOM_WALLS[math.random(#TILE_BOTTOM_WALLS)]
            else
                id = TILE_FLOORS[math.random(#TILE_FLOORS)]
            end
            
            table.insert(self.tiles[y], {
                id = id
            })
        end
    end
end

function Room:update(dt, entity)

    -- don't update anything if we are sliding to another room (we have offsets)
    if self.adjacentOffsetX ~= 0 or self.adjacentOffsetY ~= 0 then return end

    self.player:update(dt)

    for i = #self.entities, 1, -1 do
        local entity = self.entities[i]

        -- remove entity from the table if health is <= 0
        if entity.dead and entity.droppedheart == false then
            local heart = GameObject(
                GAME_OBJECT_DEFS['heart'],
                entity.x, 
                entity.y
            )
            heart.onConsume = function(player, object)
                gSounds['reveal']:play()
                self.player.health = math.min(self.player.health + 2, PLAYER_HEALTH)
            end

            if math.random(1,4) == 1 then
                table.insert(self.objects, heart)
            end
            entity.droppedheart = true
        end

        if entity.health <= 0 then
            entity.dead = true
        elseif not entity.dead then
            entity:processAI({room = self}, dt)
            entity:update(dt)
        end

        for j, projectile in pairs(self.projectiles) do
            projectile:update(dt)

            local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) 
            + MAP_RENDER_OFFSET_Y - TILE_SIZE

            if entity:collides(projectile) and not entity.dead then
                entity:damage(1)
                gSounds['hit-enemy']:play()
                table.remove(self.projectiles, j)
            end

            if 	projectile.x <= MAP_RENDER_OFFSET_X + TILE_SIZE - projectile.width or projectile.x >= VIRTUAL_WIDTH - TILE_SIZE * 2 or
                projectile.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - projectile.height or projectile.y  >= bottomEdge then
                table.remove(self.projectiles, j)
            end

            if projectile.hitsfloor then
                    table.remove(self.projectiles, j)
            end

        end

        -- collision between the player and entities in the room
        if not entity.dead and self.player:collides(entity) and not self.player.invulnerable then
            gSounds['hit-player']:play()
            self.player:damage(1)
            self.player:goInvulnerable(1.5)

            if self.player.health == 0 then
                gStateMachine:change('game-over')
            end
        end

        for i, object in pairs(self.objects) do
            if entity:collides(object) then
                if object.solid then
                    if entity.direction == 'left' then
                        entity.x = entity.x - PLAYER_WALK_SPEED * dt
    
                        if entity.x <= object.x + object.width then
                            entity.x = object.x  + entity.width + 0.9
                            entity.bumped = true
                        end
    
                    elseif entity.direction == 'right' then
                        entity.x = entity.x + PLAYER_WALK_SPEED * dt
    
                        if entity.x + entity.width >= object.x then
                            entity.x = object.x - entity.width - 1
                            entity.bumped = true
                        end
    
                    elseif entity.direction == 'down' then
                        entity.y = entity.y + PLAYER_WALK_SPEED * dt
    
                        if entity.y + entity.height >= object.y then
                            entity.y = object.y - entity.height - 1
                            entity.bumped = true
                        end
    
                    elseif entity.direction == 'up' then
                        entity.y = entity.y - PLAYER_WALK_SPEED * dt
    
                        if entity.y <= object.y + object.height - entity.height/2 then 
                            entity.y = object.y + object.height - entity.height/2 + 0.9
                            entity.bumped = true
                        end
    
                    end
                end
            end

        end
    end

    for k, object in pairs(self.objects) do
        object:update(dt)
        if object.pickedup == true then
            object.x = self.player.x
            object.y = self.player.y - self.player.height/2
        end

        -- trigger collision callback on object
        if self.player:collides(object) then
            object:onCollide(self.player, object)
            if object.solid then
                if self.player.direction == 'left' then
                    self.player.x = self.player.x - PLAYER_WALK_SPEED * dt

                    if self.player.x <= object.x + object.width then
                        self.player.x = object.x  + self.player.width + 0.5
                        
                    end

                elseif self.player.direction == 'right' then
                    self.player.x = self.player.x + PLAYER_WALK_SPEED * dt

                    if self.player.x + self.player.width >= object.x then
                        self.player.x = object.x - self.player.width - 1

                    end

                elseif self.player.direction == 'down' then
                    self.player.y = self.player.y + PLAYER_WALK_SPEED * dt

                    if self.player.y + self.player.height >= object.y  then
                        self.player.y = object.y - self.player.height - 1

                    end

                elseif self.player.direction == 'up' then
                    self.player.y = self.player.y - PLAYER_WALK_SPEED * dt

                    if self.player.y <= object.y + object.height - self.player.height/2 then 
                        self.player.y = object.y + object.height - self.player.height/2 + 0.8

                    end

                end
                self.player.bumped = true 
            end

            if object.consumable then
                object:onConsume(self.player, object)
                table.remove(self.objects, k)
            end
        end

        if object.broken then
            object.state = 'broken'
            if object.droppeditem == false then
                local heart = GameObject(
                GAME_OBJECT_DEFS['heart'],
                object.x, 
                (object.y - 8)
                )
                heart.onConsume = function(player, object)
                    gSounds['item-reveal']:play()
                    self.player.health = math.min(self.player.health + 2, PLAYER_HEALTH)
                end

                if math.random(4) <= 1 then
                    table.insert(self.objects, heart)
                end
                object.droppeditem = true
            end
        end
    end
end

function Room:render()
    for y = 1, self.height do
        for x = 1, self.width do
            local tile = self.tiles[y][x]
            love.graphics.draw(gTextures['tiles'], gFrames['tiles'][tile.id],
                (x - 1) * TILE_SIZE + self.renderOffsetX + self.adjacentOffsetX, 
                (y - 1) * TILE_SIZE + self.renderOffsetY + self.adjacentOffsetY)
        end
    end

    -- render doorways; stencils are placed where the arches are after so the player can
    -- move through them convincingly
    for k, doorway in pairs(self.doorways) do
        doorway:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end

    for k, object in pairs(self.objects) do
        object:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end

    for k, projectile in pairs(self.projectiles) do
        projectile:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end

    for k, entity in pairs(self.entities) do
        if not entity.dead then entity:render(self.adjacentOffsetX, self.adjacentOffsetY) end
    end

    -- stencil out the door arches so it looks like the player is going through
    love.graphics.stencil(function()
        -- left
        love.graphics.rectangle('fill', -TILE_SIZE - 6, MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE,
            TILE_SIZE * 2 + 6, TILE_SIZE * 2)
        
        -- right
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE) - 6,
            MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE, TILE_SIZE * 2 + 6, TILE_SIZE * 2)
        
        -- top
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
            -TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)
        
        --bottom
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
            VIRTUAL_HEIGHT - TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)
    end, 'replace', 1)

    love.graphics.setStencilTest('less', 1)
    
    if self.player then
        self.player:render()
    end

    love.graphics.setStencilTest()

    --
    -- DEBUG DRAWING OF STENCIL RECTANGLES
    --

    -- love.graphics.setColor(255, 0, 0, 100)
    
    -- -- left
    -- love.graphics.rectangle('fill', -TILE_SIZE - 6, MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE,
    -- TILE_SIZE * 2 + 6, TILE_SIZE * 2)

    -- -- right
    -- love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE),
    --     MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE, TILE_SIZE * 2 + 6, TILE_SIZE * 2)

    -- -- top
    -- love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
    --     -TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)

    -- --bottom
    -- love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
    --     VIRTUAL_HEIGHT - TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)
    
    -- love.graphics.setColor(255, 255, 255, 255)
end