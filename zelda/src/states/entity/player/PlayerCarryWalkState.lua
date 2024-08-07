PlayerCarryWalkState = Class{__includes = EntityWalkState}

function PlayerCarryWalkState:init(player, dungeon)
    self.entity = player
    self.dungeon = dungeon
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerCarryWalkState:update(dt)
    if love.keyboard.isDown('a') then
        self.entity.direction = 'left'
        self.entity:changeAnimation('carry-left')
    elseif love.keyboard.isDown('d') then
        self.entity.direction = 'right'
        self.entity:changeAnimation('carry-right')
    elseif love.keyboard.isDown('w') then
        self.entity.direction = 'up'
        self.entity:changeAnimation('carry-up')
    elseif love.keyboard.isDown('s') then
        self.entity.direction = 'down'
        self.entity:changeAnimation('carry-down')
    else
        self.entity:changeState('carry-idle')
    end

    if love.keyboard.wasPressed('q') then
        self.entity:changeState('throw-object')
    end

    EntityWalkState.update(self, dt)

    if self.bumped then
        if self.entity.direction == 'left' then
            
            self.entity.x = self.entity.x - PLAYER_WALK_SPEED * dt
            
            for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
                if self.entity:collides(doorway) and doorway.open then

                    self.entity.y = doorway.y + 4
                    Event.dispatch('shift-left')
                    self.entity.carrying = false
                    self.entity:changeState('walk')
                end
            end

            self.entity.x = self.entity.x + PLAYER_WALK_SPEED * dt
        elseif self.entity.direction == 'right' then
            
            self.entity.x = self.entity.x + PLAYER_WALK_SPEED * dt
            
            for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
                if self.entity:collides(doorway) and doorway.open then

                    self.entity.y = doorway.y + 4
                    Event.dispatch('shift-right')
                    self.entity.carrying = false
                    self.entity:changeState('walk')
                end
            end

            self.entity.x = self.entity.x - PLAYER_WALK_SPEED * dt
        elseif self.entity.direction == 'up' then
            
            self.entity.y = self.entity.y - PLAYER_WALK_SPEED * dt
            
            for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
                if self.entity:collides(doorway) and doorway.open then
                    self.entity.x = doorway.x + 8
                    Event.dispatch('shift-up')
                    self.entity.carrying = false
                    self.entity:changeState('walk')
                end
            end

            self.entity.y = self.entity.y + PLAYER_WALK_SPEED * dt
        else
            
            self.entity.y = self.entity.y + PLAYER_WALK_SPEED * dt
            
            for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
                if self.entity:collides(doorway) and doorway.open then
                    self.entity.x = doorway.x + 8
                    Event.dispatch('shift-down')
                    self.entity.carrying = false
                    self.entity:changeState('walk')
                end
            end

            self.entity.y = self.entity.y - PLAYER_WALK_SPEED * dt
        end
    end
end