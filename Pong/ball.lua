require("vector")

Ball = {}
Ball.__index = Ball

function Ball:create()
    local ball = {}
    setmetatable(ball, Ball)

    local centeredY = love.graphics.getHeight() / 2
    local centeredX = love.graphics.getWidth() / 2

    local xDir = 1
    local yDir = math.random(3, 5) / 10
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

    self.position = Vector:create(centeredX, centeredY)
end

function Ball:draw()
    local r, g, b, a = love.graphics.getColor()

    if self.position.x > love.graphics.getWidth() / 2 then
        love.graphics.setColor(PLAYER_COLOR.r, PLAYER_COLOR.g, PLAYER_COLOR.b, 1)
    elseif self.position.x < love.graphics.getWidth() / 2 then
        love.graphics.setColor(COMPUTER_COLOR.r, COMPUTER_COLOR.g, COMPUTER_COLOR.b, 1)
    elseif self.position.x == love.graphics.getWidth() / 2 then
        love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.circle('fill', self.position.x, self.position.y, self.radius)

    love.graphics.setColor(r, g, b, a)
end

function Ball:update()
    self.position:add(self.velocity)
end

function Ball:updateVelocity(multiplier)


    local xDir = (10 + multiplier) / 10
    local yDir = (math.random(3, 5) + multiplier) / 10
    if math.random() > 0.5 then
        xDir = xDir * -1
    end
    if math.random() > 0.5 then
        yDir = yDir * -1
    end


    self.velocity = Vector:create(xDir, yDir)
end

function Ball:checkBorder()
    -- проверка верхней и нижней границы поля
    if self.position.y + self.radius > love.graphics.getHeight() then
        self.position.y = love.graphics.getHeight() - self.radius
        self.velocity.y = -1 * self.velocity.y
    elseif self.position.y - self.radius < 0 then
        self.position.y = self.radius
        self.velocity.y = -1 * self.velocity.y
    end
end

function Ball:checkCollision(racket)
    local vectoredBbox = racket:getVectoredBoundingBox()

    local hasCollision = false

    local minX = vectoredBbox[1].x
    local maxX = vectoredBbox[2].x
    local minY = vectoredBbox[1].y
    local maxY = vectoredBbox[3].y

    -- проверка вхождения угла ракетки
    for i = 1, #vectoredBbox do
        if vectoredBbox[i]:distanceTo(self.position) < self.radius then
            hasCollision = true
            self.position = vectoredBbox[i]
            -- self.velocity.x = -1 * self.velocity.x
            break
        end
    end

    -- проверка по перпендикуляру
    if self.position.y >= minY and self.position.y <= maxY then
        -- мяч сбоку
        local leftProjection = Vector:create(minX, self.position.y)
        local rightProjection = Vector:create(maxX, self.position.y)

        if self.position:distanceTo(leftProjection) < self.radius then
            hasCollision = true
            self.position = Vector:create(minX - self.radius, self.position.y)
        elseif self.position:distanceTo(rightProjection) < self.radius then
            hasCollision = true
            self.position = Vector:create(maxX + self.radius, self.position.y)
        end
    end

    if self.position.x >= minX and self.position.x <= maxX then
        -- мяч сверху
        local upProjection = Vector:create(self.position.x, minY)
        local downProjection = Vector:create(self.position.x, maxY)

        if self.position:distanceTo(upProjection) < self.radius then
            hasCollision = true
            self.position = Vector:create(self.position.x, minY - self.radius)
        elseif self.position:distanceTo(downProjection) < self.radius then
            hasCollision = true
            self.position = Vector:create(self.position.x, maxX + self.radius)
        end
    end

    if hasCollision then
        self.velocity.x = -1 * self.velocity.x
    end

    return hasCollision
end
