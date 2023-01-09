require("particle")
require("vector")
require("partticlesystem")
require("repeller")


function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    
    system = ParticleSystem:create(Vector:create(width / 2, height / 2))
    repeller = Repeller:create(Vector:create(width / 2, height / 2 + height / 3))
end

function love.update()
    system:update()
    system:applyRepeller(repeller)
end


function love.draw()
    system:draw()
    repeller:draw()
end