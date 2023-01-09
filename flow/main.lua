require("vector")
require("vehicle")
require("flow")

function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    vehicle = Vehicle:create(width / 2, height / 2)
    flowMap = FlowMap:create(40)
    flowMap:init2()
end

function love.update(dt)
    vehicle:follow(flowMap)
    vehicle:borders()
    vehicle:update()
end

function love.draw()
    flowMap:draw()
    vehicle:draw()
end
