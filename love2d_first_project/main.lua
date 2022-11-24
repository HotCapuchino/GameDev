require("vector")
require("mover")
require "attractor"

function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    -- local location = Vector:create(width / 2 + 100, height / 2 - 100)

    -- attractor = Attractor:create(location, 20)

    -- local location = Vector:create(width / 2, height / 2)
    -- big_attractor = Attractor:create(location, 30)
    
    -- local velocity = Vector:create(0.1, 0.1)
    -- local location = Vector:create(300, 350)
    -- mover = Mover:create(location, velocity)

    mover = Mover:random()
    mover2 = Mover:random()
    -- mover2.aVelocity = 0.3
end

function love.update(dt)
    if love.keyboard.isDown("left") then
        mover:rotate(-0.05)
    end
    if love.keyboard.isDown("right") then
        mover:rotate(0.05)
    end
    if love.keyboard.isDown('up') then
        local x = 0.1 * math.cos(mover.angle)
        local y = 0.1 * math.sin(mover.angle)
        mover:applyForce(Vector:create(x, y))
        mover.active = true
    end
    if love.keyboard.isDown('down') then
        mover.active = false
    end

    mover:update()
    mover:checkBoundaries()

    x, y = love.mouse.getPosition()
    local mouse = Vector:create(x, y)
    local dir = mouse - mover2.location
    local acceleration = dir:norm() * 0.05
    mover2.acceleration = acceleration
    local angle = math.atan2(mover2.velocity.y, mover2.velocity.x)
    mover2.angle = angle

    mover2:update()
    mover2:checkBoundaries()
    -- attractor:attract(mover)
    -- big_attractor:attract(attractor)
end

function love.draw()
    mover:draw()
    mover2:draw()
    -- attractor:draw()
    -- big_attractor:draw()
end

function love.keypressed(key)
end
