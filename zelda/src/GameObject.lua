--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameObject = Class{}

function GameObject:init(def, x, y)
    -- string identifying this object type
    self.type = def.type

    self.texture = def.texture
    self.frame = def.frame or 1

    -- whether it acts as an obstacle or not
    self.solid = def.solid

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states

    -- dimensions
    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height

    -- default empty collision callback
     self.onCollide = function() end
    self.consumable = def.consumable
    self.onConsume = def.onConsume
    self.throwable = def.throwable
    self.pickedup = false
    self.dx = 0
    self.dy = 0
    self.throwed = false
    self.aimX = 0
    self.aimY = 0
    self.throwdirection = nil
    self.hitsfloor = false
    self.broken = false
    self.breakable = def.breakable
    self.droppeditem = false
end

function GameObject:collides(target)
    return not (self.x + self.width < target.x or self.x > target.x + target.width or
                self.y + self.height < target.y or self.y > target.y + target.height)
end

function GameObject:update(dt)
    if self.throwed then 
        if self.throwdirection == 'up' and self.y <= self.aimY then
            self.hitsfloor = true
        elseif self.throwdirection ~= 'up' and self.y >= self.aimY then
            self.hitsfloor = true
        else
            self.x = self.x + self.dx * dt
            self.y = self.y + self.dy * dt
        end

    end

end

function GameObject:yeet(direction, trajX, trajY, speed)
    self.throwed = true
    self.throwdirection = direction
    self.aimX = trajX
    self.aimY = trajY
    self.dx = (self.aimX - self.x) * speed
    self.dy = (self.aimY - self.y) * speed
end

function GameObject:render(adjacentOffsetX, adjacentOffsetY)
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
end