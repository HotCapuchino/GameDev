ParticleSystem={}
ParticleSystem.__index=ParticleSystem


function ParticleSystem:create(origin,n,cls)
    local system = {}
    setmetatable(system,ParticleSystem)
    system.origin=origin
    system.n=n or 20
    system.particles={}
    system.cls=cls or Particle
    system.index=1

    return system
end

function ParticleSystem:draw()
    for k,v in pairs(self.particles) do
        v:draw()
    end
end

function ParticleSystem:applyForce(force)
    for k,v in pairs(self.particles) do
        v:applyForce(force)
    end
end

function ParticleSystem:applyRepeller(repeller)
    for k,v in pairs(self.particles) do
        v:applyForce(repeller:repel(v))
    end
end

function ParticleSystem:createParticle()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    return self.cls:create(Vector:create(math.random(50, width - 50), math.random(50, height - 50)), math.random(20, 50))
end

function ParticleSystem:update()
    if #self.particles < self.n then
        self.particles[self.index]=self:createParticle()
        self.index=self.index+1
    end

    for k,v in pairs(self.particles) do
        if v:isDead() then
            v = self:createParticle()
            self.particles[k]=v
        end
        v:update()
    end
end