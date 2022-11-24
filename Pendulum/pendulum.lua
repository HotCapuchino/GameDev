require("vector")

Pendulum = {}
Pendulum.__index = Pendulum 

function Pendulum:create(origin, length)
    local pendulum = {}
    setmetatable(pendulum, Pendulum)
    pendulum.origin = origin
    pendulum.length = length
    pendulum.position = Vector:create(0, 0)
    pendulum.aVelocity = 0
    pendulum.aAcceleration = 0
    pendulum.damping = 0.995
    pendulum.angle = math.pi / 4
    pendulum.r = 20
    pendulum.gravity = 0.4

    pendulum.dragging = false


    return pendulum
end

function Pendulum:draw() 
    self.position.x = self.length * math.sin(self.angle) + self.origin.x
    self.position.y = self.length * math.cos(self.angle) + self.origin.y
    love.graphics.circle("line", self.origin.x, self.origin.y, 5)
    love.graphics.line(self.origin.x, self.origin.y, self.position.x, self.position.y)

    local style = "fill"
    if self.dragging then
        style = "line"
    end

    love.graphics.circle(style, self.position.x, self.position.y, self.r)
end

function Pendulum:update()
    self:drag()
    self.aAcceleration = (-1 * self.gravity / self.length) * math.sin(self.angle)
    self.aVelocity = (self.aVelocity + self.aAcceleration) * self.damping
    self.angle = self.angle + self.aVelocity
end

function Pendulum:clicked(mouseX, mouseY)
    local d = Vector:create(mouseX, mouseY) - self.position
    d = d:mag()

    if d < self.r then
        self.dragging = true
    end
end

function Pendulum:stopDragging()
    if self.dragging then
        self.dragging = false
        self.aVelocity = 0
    end
end

function Pendulum:drag()
    if self.dragging then
        local x, y = love.mouse.getPosition()
        local diff = self.origin - Vector:create(x, y)
        self.angle = math.atan2(-1 * diff.y, diff.x) - math.pi / 2
    end
end