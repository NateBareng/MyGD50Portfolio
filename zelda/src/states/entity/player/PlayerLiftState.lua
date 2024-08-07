PlayerLiftState = Class{__includes = BaseState}

function PlayerLiftState:init(player, dungeon)
    self.player = player
    self.dungeon = dungeon
    self.player.offsetY = 5
    self.player.offsetX = 0

    local direction = self.player.direction
    local hitboxX, hitboxY, hitboxWidth, hitboxHeight

    if direction == 'left' then
        hitboxWidth = 8
        hitboxHeight = 16
        hitboxX = self.player.x - hitboxWidth
        hitboxY = self.player.y + 2
    elseif direction == 'right' then
        hitboxWidth = 8
        hitboxHeight = 16
        hitboxX = self.player.x + self.player.width
        hitboxY = self.player.y + 2
    elseif direction == 'up' then
        hitboxWidth = 16
        hitboxHeight = 8
        hitboxX = self.player.x
        hitboxY = self.player.y - hitboxHeight
    else
        hitboxWidth = 16
        hitboxHeight = 8
        hitboxX = self.player.x
        hitboxY = self.player.y + self.player.height
    end

    self.potHitbox = Hitbox(hitboxX, hitboxY, hitboxWidth, hitboxHeight)
    self.player:changeAnimation('lift-' .. self.player.direction)

end

function PlayerLiftState:enter(params)
    gSounds['hit-player']:stop()
    gSounds['hit-player']:play()

    self.player.currentAnimation:refresh()
end

function PlayerLiftState:update(dt)
    if self.player.currentAnimation.timesPlayed > 0 then
        self.player.currentAnimation.timesPlayed = 0

        for i, object in pairs(self.dungeon.currentRoom.objects) do
            if self.player.carrying == false then
                if object:collides(self.potHitbox) then
                    if object.throwable then
                        self.player.carrying = true
                        object.pickedup = true
                    end
                end
            end
        end

        if self.player.carrying == true then
            self.player:changeState('carry-idle')
        else
            self.player:changeState('idle')
        end
    end
end

function PlayerLiftState:render()
    local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
       math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))
end