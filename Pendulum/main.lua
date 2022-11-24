require("pendulum")
require("vector")
require("mover")
require("spring")

function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    -- pendulum = Pendulum:create(Vector:create(width / 2, 10), 200)
    -- pendulum2 = Pendulum:create(pendulum.position, 100)

    mover = Mover:create(width / 2, height / 2,  20)
    spring = Spring:create(Vector:create(width / 2, height - 10), 20)
end

function love.update()
    mover:update()
    spring:apply(mover)
    spring:constraint(mover, 50, 400)
    -- pendulum:update()
    -- pendulum2:update()
end

function love.draw()
    mover:draw()
    spring:draw()
    spring:drawLine(mover)
    -- pendulum:draw()
    -- pendulum2:draw()
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        mover:clicked(x, y)
        -- pendulum:clicked(x, y)
        -- pendulum2:clicked(x, y)
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if button == 1 then
        mover:stopDragging()
        -- pendulum:stopDragging(x, y)
        -- pendulum2:stopDragging(x, y)
    end
end