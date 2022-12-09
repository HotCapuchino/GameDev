Pipe = {}
Pipe.__index = Pipe

PipeType = {
    Upper = 1,
    Lower = 2
}

function Pipe:create(position, availableHeight, sprite)
    local pipe = {}
    setmetatable(pipe, Pipe)

    pipe.overallPosition = position
    pipe.checked = false
    pipe.upperPosition = nil
    pipe.lowerPosition = nil

    pipe.upperSprite = nil
    pipe.lowerSprite = nil

    pipe.sprite = sprite

    pipe:generatePipeParts(availableHeight)

    return pipe
end

function Pipe:generatePipeParts(availableHeight)
    math.randomseed(os.clock())
    local upperPercentage = math.random(1, 5) / 10

    local upperHeight = availableHeight * upperPercentage
    local lowerHeight = availableHeight * (1 - upperPercentage)

    self.upperPosition = Vector:create(self.overallPosition.x, upperHeight - self.sprite:getHeight())
    self.lowerPosition = Vector:create(self.overallPosition.x,
        love.graphics.getHeight() - lowerHeight)
end

function Pipe:draw(quad)
    love.graphics.draw(self.sprite, quad, self.upperPosition.x, self.upperPosition.y, math.pi, 1, 1,
        self.sprite:getWidth(), self.sprite:getHeight())
    love.graphics.draw(self.sprite, quad, self.lowerPosition.x, self.lowerPosition.y)
end

function Pipe:update(xOffset)
    self.overallPosition.x = self.upperPosition.x - xOffset
    self.upperPosition.x = self.upperPosition.x - xOffset
    self.lowerPosition.x = self.lowerPosition.x - xOffset
end

function Pipe:getBoundingBox(type)
    local topLeft = nil
    local topRight = nil
    local bottomLeft = nil
    local bottomRight = nil

    if type == nil then
        -- общий bbox
        topLeft = self.overallPosition
        topRight = Vector:create(self.overallPosition.x + self.sprite:getWidth(), self.overallPosition.y)
        bottomLeft = Vector:create(self.overallPosition.x, love.graphics:getHeight())
        bottomRight = Vector:create(self.overallPosition.x + self.sprite:getWidth(), love.graphics:getHeight())
    elseif type == PipeType.Upper then
        -- bbox верхней трубы
        topLeft = self.upperPosition
        topRight = Vector:create(self.upperPosition.x + self.sprite:getWidth(), self.upperPosition.y)
        bottomLeft = Vector:create(self.upperPosition.x, self.upperPosition.y + self.sprite:getHeight())
        bottomRight = Vector:create(self.upperPosition.x + self.sprite:getWidth(),
            self.upperPosition.y + self.sprite:getHeight())
    elseif type == PipeType.Lower then
        -- bbox нижней трубы
        topLeft = self.lowerPosition
        topRight = Vector:create(self.lowerPosition.x + self.sprite:getWidth(), self.lowerPosition.y)
        bottomLeft = Vector:create(self.lowerPosition.x, self.lowerPosition.y + self.sprite:getHeight())
        bottomRight = Vector:create(self.lowerPosition.x + self.sprite:getWidth(),
            self.lowerPosition.y + self.sprite:getHeight())
    end

    return { topLeft, topRight, bottomLeft, bottomRight }
end

function Pipe:getUpperBoundingBox()
    return self:getBoundingBox(PipeType.Upper)
end

function Pipe:getLowerBoundingBox()
    return self:getBoundingBox(PipeType.Lower)
end
