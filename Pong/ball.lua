require("vector")

Ball = {}
Ball.__index = Ball

function Ball:create()
    local ball = {}
    setmetatable(ball, Ball)

    local centeredY = love.graphics.getHeight() / 2
    local centeredX = love.graphics.getWidth() / 2

    local xDir = math.random(0.6)
    local yDir = math.random(0.4, 0.6)
    if math.random() > 0.5 then
        xDir = xDir * -1
    end
    if math.random() > 0.5 then
        yDir = yDir * -1
    end

    ball.velocity = Vector:create(xDir, yDir)
    ball.position = Vector:create(centeredX, centeredY)
    ball.radius = 7

    return ball
end

function Ball:hide()
    self.position = Vector:create(0, -100)
end

function Ball:init()
    local centeredY = love.graphics.getHeight() / 2
    local centeredX = love.graphics.getWidth() / 2

    local xDir = math.random(0.6)
    local yDir = math.random(0.4, 0.6)
    if math.random() > 0.5 then
        xDir = xDir * -1
    end
    if math.random() > 0.5 then
        yDir = yDir * -1
    end


    self.velocity = Vector:create(xDir, yDir)
    self.position = Vector:create(centeredX, centeredY)
end

function Ball:draw()
    local r, g, b, a = love.graphics.getColor()

    if self.position.x > love.graphics.getWidth() / 2 then
        love.graphics.setColor(P2_COLOR.r, P2_COLOR.g, P2_COLOR.b, 1)
    elseif self.position.x < love.graphics.getWidth() / 2 then
        love.graphics.setColor(P1_COLOR.r, P1_COLOR.g, P1_COLOR.b, 1)
    elseif self.position.x == love.graphics.getWidth() / 2 then
        love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.circle('fill', self.position.x, self.position.y, self.radius)

    love.graphics.setColor(r, g, b, a)
end

function Ball:update()
    self.position:add(self.velocity)
end

function Ball:checkCollision(racket)
    -- проверка верхней и нижней границы поля
    if self.position.y + self.radius > love.graphics.getHeight() then
        self.position.y = love.graphics.getHeight() - self.radius
        self.velocity.y = -1 * self.velocity.y
    elseif self.position.y - self.radius < 0 then
        self.position.y = self.radius
        self.velocity.y = -1 * self.velocity.y
    end

    local bbox = racket:getBoundingBox()

    -- проверка коллизии с ракеткой
    if racket.player == Players.P2 then
        if self.position.x + self.radius > bbox[1] and self.position.y >= bbox[2] and self.position.y <= bbox[4] then
            self.velocity.x = -1 * self.velocity.x
        end
    else
        if self.position.x - self.radius < bbox[3] and self.position.y >= bbox[2] and self.position.y <= bbox[4] then
            self.velocity.x = -1 * self.velocity.x
        end
    end
end
