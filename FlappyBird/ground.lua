Ground = {}
Ground.__index = Ground

function Ground:create(position)
    local ground = {}
    setmetatable(ground, Ground)

    ground.sprite = love.graphics.newImage('res/sprites/base.png')
    ground.sprite:setWrap('repeat', 'repeat')
    ground.quad = love.graphics.newQuad(0, 0, love.graphics.getWidth() * 2, love.graphics.getHeight(), ground.sprite)
    ground.position = position

    ground.testPos = position
    ground.speed = 0

    return ground
end

function Ground:draw()
    love.graphics.draw(self.sprite, self.quad, self.position.x, self.position.y)
end

function Ground:update()
    self.position.x = self.position.x - 0.2 * self.speed

    if self.position.x < -self.sprite:getWidth() then
        self.position.x = 0
    end
end

function Ground:updateSpeed(multiplier)
    self.speed = multiplier
end

function Ground:getBoundingBox()
    local maxX = love.graphics.getWidth()
    local maxY = love.graphics.getHeight()

    local topLeft = self.position
    local topRight = Vector:create(maxX, self.position.y)
    local bottomLeft = Vector:create(self.position.x, maxY)
    local bottomRight = Vector:create(maxX, maxY)

    return { topLeft, topRight, bottomLeft, bottomRight }
end
