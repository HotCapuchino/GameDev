require("vector")
require("ball")

RacketDirection = {
    UP = 1,
    DOWN = 2
}

Racket = {}
Racket.__index = Racket

function Racket:create(player)
    local racket = {}
    setmetatable(racket, Racket)

    racket.height = 80
    racket.width = 8
    racket.velocity = Vector:create(0, 0)
    racket.player = player
    racket.appliableForce = Vector:create(0, 0)

    local centeredY = love.graphics.getHeight() / 2
    local centeredX = 0

    if racket.player == Players.Player then
        centeredX = love.graphics.getWidth() - racket.width
    end

    -- top left corner
    racket.position = Vector:create(centeredX, centeredY - racket.height / 2)

    return racket
end

function Racket:init()
    local centeredY = love.graphics.getHeight() / 2
    local centeredX = 0

    if self.player == Players.Player then
        centeredX = love.graphics.getWidth() - self.width
    end

    -- top left corner
    self.position = Vector:create(centeredX, centeredY - self.height / 2)
end

function Racket:draw()
    love.graphics.rectangle('fill', self.position.x, self.position.y, self.width, self.height)
end

function Racket:update(ball)
    if ball then
        -- TODO: подстроить позицию ракетки под мяч
        local centeredY = self.position.y + self.height / 2
        local directionToMove = RacketDirection.UP

        if ball.position.y > centeredY then
            directionToMove = RacketDirection.DOWN
        end

        local upperPercentileWidth = love.graphics.getWidth() * 0.6

        if ball.position.x < upperPercentileWidth then
            self:applyForce(directionToMove)
        end

    end

    self.position:add(self.velocity)
    self.velocity = Vector:create(0, 0)
end

function Racket:applyForce(direction)
    if direction == RacketDirection.UP then
        self.appliableForce = Vector:create(0, -1)
    else
        self.appliableForce = Vector:create(0, 1)
    end
    self.velocity = self.appliableForce
end

function Racket:checkBorder()
    local upperBound = self.position.y
    local lowerBound = self.position.y + self.height

    if upperBound <= 0 then
        self.position.y = 0
    elseif lowerBound >= love.graphics.getHeight() then
        self.position.y = love.graphics.getHeight() - self.height
    end
end

function Racket:getVectoredBoundingBox()
    local topLeft = self.position
    local topRight = Vector:create(self.position.x + self.width, self.position.y)
    local bottomLeft = Vector:create(self.position.x, self.position.y + self.height)
    local bottomRight = Vector:create(self.position.x + self.width, self.position.y + self.height)

    return { topLeft, topRight, bottomLeft, bottomRight }
end
