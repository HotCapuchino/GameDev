require("vector")

Particle = {}
Particle.__index = Particle

function Particle:create(position)
    local particle = {}
    setmetatable(particle, Particle)
    particle.position = position
    particle.acceleration = Vector:create(0, 0.05)
    particle.velocity = Vector:create(math.random(-1, 1), math.random(-1, 1))
    particle.lifespan = 100
    particle.texture = love.graphics.newImage("assets/coin.png")

    return particle
end

function Particle:update()
    self.velocity:add(self.acceleration)
    self.position:add(self.velocity)
    self.lifespan = self.lifespan - 1
end

function Particle:isDead()
    if self.lifespan < 0 then
        return true
    end
    return false
end

function Particle:draw()
    r, g, b, a = love.graphics.getColor()

    love.graphics.setColor(255, 255, 255, self.lifespan / 100)
    love.graphics.draw(self.texture, 
                        self.position.x - 0.1 * self.texture:getWidth() / 2, 
                        self.position.y - 0.1 * self.texture:getHeight() / 2,
                        0.1, 
                        0.1)
end

function Particle:applyForce(force)
    self.acceleration:add(force)
end