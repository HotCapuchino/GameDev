require("vector")
require("mover")
require("particle")
require("particleSystem")
require("repeller")

function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    -- particle = Particle:create(Vector:create(width / 2, height / 2))
    system = ParticleSystem:create(Vector:create(width / 2, height / 2))
    repeller = Repeller:create(Vector:create(width / 2, height / 3 * 2))
end

function love.update(dt)
    -- if particle:isDead() then
    --     particle = Particle:create(Vector:create(width / 2, height / 2))
    -- end
    -- particle:update()
    system:update()
    system:applyRepeller(repeller)
end

function love.draw()
    system:draw()
    -- particle:draw()
end