PlayerCarryIdleState = Class{__includes = EntityIdleState}

function PlayerCarryIdleState:init(player, dungeon)

    self.entity = player
    self.dungeon = dungeon
    self.entity.offsetY = 5
    self.entity.offsetX = 0

    local direction = self.entity.direction
    self.entity:changeAnimation('idle-carry-' .. self.entity.direction)
end

function PlayerCarryIdleState:enter(params)
    --self.item = item

    self.entity.offsetY = 5
    self.entity.offsetX = 0

    self.entity.currentAnimation:refresh()
end

function PlayerCarryIdleState:update(dt)
    EntityIdleState.update(self, dt)
end

function PlayerCarryIdleState:update(dt)
    if love.keyboard.isDown('a') or love.keyboard.isDown('d') or
       love.keyboard.isDown('w') or love.keyboard.isDown('s') then
        self.entity:changeState('carry-walk')
    end

    if love.keyboard.wasPressed('q') then
        self.entity:changeState('throw-object')
    end
end