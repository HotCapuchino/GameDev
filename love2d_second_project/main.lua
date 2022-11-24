require("wave")

function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    wave = Wave:create(100, 500, 4, 200, {1, 1, 1}, {181/255, 179/255, 179/255, 0.5}, 10, 0.002, 0)
    wave2 = Wave:create(200, 600, 4, -200, {1, 1, 1}, {181/255, 179/255, 179/255, 0.5}, 20, 0.001, 10)
end

function love.draw()
    wave:draw()
    wave2:draw()
end

