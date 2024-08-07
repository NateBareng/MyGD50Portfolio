PlayerThrowState = Class{__includes = BaseState}

function PlayerThrowState:init(player, dungeon)
    self.player = player
    self.dungeon = dungeon
    self.player.offsetY = 5
    self.player.offsetX = 0
end

function PlayerThrowState:enter(params)
    gSounds['yeet-throw']:stop()
    gSounds['yeet-throw']:play()

    self.player.currentAnimation:refresh()

    local direction = self.player.direction
    self.player:changeAnimation('throw-' .. self.player.direction)

    local throwX, throwY
	if self.player.direction == 'up' then
		throwX = self.player.x
		throwY = self.player.y - (4 * TILE_SIZE)
	elseif self.player.direction == 'down' then
		throwX = self.player.x
		throwY = self.player.y + (4 * TILE_SIZE)
	elseif self.player.direction == 'left' then
		throwX = self.player.x - (4 * TILE_SIZE)
		throwY = self.player.y + self.player.height - 8
	else
		throwX = self.player.x + (4 * TILE_SIZE)
		throwY = self.player.y + self.player.height - 8
    end
    
    for i, object in pairs(self.dungeon.currentRoom.objects) do
        if object.pickedup then
            object:yeet(self.player.direction, throwX, throwY, 0.5)
            table.insert(self.dungeon.currentRoom.projectiles, object)
            self.player.carrying = false
            object.pickedup = false
            table.remove(self.dungeon.currentRoom.objects, i)
        end
    end
end

function PlayerThrowState:update(dt)

    if self.player.currentAnimation.timesPlayed > 0 then
        self.player.currentAnimation.timesPlayed = 0


        if self.player.carrying == true then
            self.player:changeState('carry-idle')
        else
            self.player:changeState('idle')
        end
    end
end

function PlayerThrowState:render()
    local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
       math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))
end