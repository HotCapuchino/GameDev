require("vector")

Racket = {}
Racket.__index = Racket

function Racket:create(player)
    local racket = {}
    setmetatable(racket, Racket)

    racket.height = 80
    racket.width = 8
    racket.velocity = Vector:create(0, 0)
    racket.player = player

    local centeredY = love.graphics.getHeight() / 2
    local centeredX = 0

    if racket.player == Players.P2 then
        centeredX = love.graphics.getWidth() - racket.width
    end

    -- top left corner
    racket.position = Vector:create(centeredX, centeredY - racket.height / 2)

    return racket
end

function Racket:init()
    local centeredY = love.graphics.getHeight() / 2
    local centeredX = 0

    if self.player == Players.P2 then
        centeredX = love.graphics.getWidth() - self.width
    end

    -- top left corner
    self.position = Vector:create(centeredX, centeredY - self.height / 2)
end

function Racket:draw()
    love.graphics.rectangle('fill', self.position.x, self.position.y, self.width, self.height)
end

function Racket:update()
    self.position:add(self.velocity)
    self.velocity = Vector:create(0, 0)
end

function Racket:applyForce(force)
    self.velocity = force
end

function Racket:checkCollision()
    local upperBound = self.position.y
    local lowerBound = self.position.y + self.height

    if upperBound <= 0 then
        self.position.y = 0
    elseif lowerBound >= love.graphics.getHeight() then
        self.position.y = love.graphics.getHeight() - self.height
    end
end

function Racket:getBoundingBox()
    return { self.position.x, self.position.y, self.position.x + self.width, self.position.y + self.height }
end
