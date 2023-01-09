RectParticlesSystem = {}
RectParticlesSystem.__index = RectParticlesSystem

function RectParticlesSystem:create(n, cls)
    local rectParticles = {}
    setmetatable(rectParticles, RectParticlesSystem)
    system.n=n or 20
    system.particles={}
    system.cls=cls or Particle

    return rectParticles
end

function RectParticlesSystem:addParticles()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    for i = 1, self.n, 1 do
        self.particles[i] = self.cls:create(Vector:create(math.random(50, width - 50), math.random(50, height - 50)), math.random(20, 50))
    end
end 

function ParticleSystem:draw()
    for k,v in pairs(self.particles) do
        v:draw()
    end
end

function ParticleSystem:shatter(x, y)
    for i = 1, self.n, 1 do
        position = self.particles[i].position
        width = self.particles[i].width

        if x >= position.x && x < position.
    end
end