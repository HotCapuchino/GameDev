Attractor = {}
Attractor.__index = Attractor

function Attractor:create(location, mass)
    local attractor = {}
    setmetatable(attractor, Attractor)
    attractor.location = location
    attractor.mass = mass
    attractor.size = 30 + 0.3 * mass
    attractor.inner_size = attractor.size

    return attractor
end

function Attractor:draw()
    local r, g, b, a = love.graphics.getColor()
    love.graphics.circle("line", self.location.x, self.location.y, self.size)

    self.inner_size = self.inner_size - 0.5
    if self.inner_size <= 0 then
        self.inner_size = self.size
    end

    love.graphics.circle("line", self.location.x, self.location.y, self.inner_size)
    love.graphics.setColor(r, g, b, a)
end

function Attractor:attract(mover)
    local diff = self.location - mover.location
    local distance = diff:mag()

    if distance < 5 then
        distance = 5
    elseif distance > 30 then
        distance = 30
    end

    local G = 4.67

    local force = diff:norm()
    
    local strength = (G * self.mass * mover.weight) / (distance * distance)
    force:mul(strength)

    mover:applyForce(force)
end
