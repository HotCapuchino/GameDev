Vehicle = {}
Vehicle.__index = Vehicle

function Vehicle:create(x, y)
    local vehicle = {}
    setmetatable(vehicle, Vehicle)
    vehicle.acceleration = Vector:create(0, 0)
    vehicle.velocity = Vector:create(0, 0)
    vehicle.location = Vector:create(x, y)
    vehicle.r = 5
    vehicle.vertices = {0, - vehicle.r * 2, -vehicle.r, vehicle.r * 2, vehicle.r, 2 * vehicle.r}
    vehicle.maxSpeed = 4
    vehicle.maxForce = 0.1
    vehicle.wtheta = 0
    return vehicle
end

function Vehicle:update()
    self.velocity:add(self.acceleration)
    self.velocity:limit(self.maxSpeed)
    self.location:add(self.velocity)
    self.acceleration:mul(0)
end

function Vehicle:applyForce(force)
    self.acceleration:add(force)
end

function Vehicle:follow(flowMap)
    -- желаемое направление (вектор)
    local desired = flowMap:lookup(self.location)

    if desired then
        desired:mul(self.maxSpeed)
    
        -- разница между желаемым направлением и текущим направлением
        local steer = desired - self.velocity
        steer:limit(self.maxForce)
    
        self:applyForce(steer)
    end
end

function Vehicle:borders()
    if self.location.x < -self.r then
        self.location.x = width + self.r
    end
    if self.location.y < -self.r then
        self.location.y = height + self.r
    end
    if self.location.x > width + self.r then
        self.location.x = -self.r
    end
    if self.location.y > height + self.r then
        self.location.y = -self.r
    end
end


function Vehicle:draw()
    local theta = self.velocity:heading() + math.pi / 2
    love.graphics.push()
    love.graphics.translate(self.location.x, self.location.y)
    love.graphics.rotate(theta)
    love.graphics.polygon("fill", self.vertices)
    love.graphics.pop()
end