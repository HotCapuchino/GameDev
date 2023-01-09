Vehicle = {}
Vehicle.__index = Vehicle

function Vehicle:create(x, y)
    local vehicle = {}
    setmetatable(vehicle, Vehicle)
    vehicle.acceleration = Vector:create(0, 0)
    vehicle.velocity = Vector:create(0, 0)
    vehicle.location = Vector:create(x, y)
    vehicle.r = 5
    vehicle.vertices = {0, -vehicle.r * 2, -vehicle.r, vehicle.r * 2, vehicle.r, 2 * vehicle.r}
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

function Vehicle:follow(path)
    local predict = self.velocity:copy()
    predict:norm()
    -- смотрит на 50 пикс вперед
    predict:mul(50)
    local pos = self.location + predict
    local a = path.start
    local b = path.stop

    -- вычисление перпендикуляра к прямой, относительно которой происходит движение (на 50 пикс вперед)
    -- нужно для понимания того, когда движение происходит не вдоль линии
    local normal = getNormalPoint(pos, a, b)
    -- направление движения (вдоль линии)
    local dir = b - a
    dir:norm()
    dir:mul(10)
    -- результрующий вектор направления
    local target = normal + dir
    local distance = pos:distTo(dir)
    if distance > path.d then
        self:seek(target)
    end
end

function Vehicle:followComplex(complexPath)
    for i = 1, #complexPath.points - 1 do
        local predict = self.velocity:copy()
        predict:norm()
        -- смотрит на 50 пикс вперед
        predict:mul(100)
        local pos = self.location + predict
        local a = complexPath.points[i]
        local b = complexPath.points[i + 1]

        -- вычисление перпендикуляра к прямой, относительно которой происходит движение (на 50 пикс вперед)
        -- нужно для понимания того, когда движение происходит не вдоль линии
        local normal = getNormalPoint(pos, a, b)
        -- направление движения (вдоль линии)
        local dir = b - a
        dir:norm()
        dir:mul(10)
        -- результирующий вектор направления
        local target = normal + dir
        local distance = pos:distTo(dir)
        if distance > complexPath.d then
            self:seek(target)
        end
    end
end 

function Vehicle:seek(target)
    local desired = target - self.location
    if desired:mag() == 0 then
        return
    end

    desired:norm()
    desired:mul(self.maxSpeed)
    local steer = desired - self.velocity
    steer:limit(self.maxForce)
    self:applyForce(steer)
end

function Vehicle:borders(path)
    if self.location.x > path.stop.x + self.r then
        self.location.x = path.start.x - self.r
        self.location.y = path.start.y + (self.location.y - path.stop.y)
    end
end

function Vehicle:complexBorders(complexPath)
    for i = 1, #complexPath.points - 1 do
        local start = complexPath.points[i]
        local stop = complexPath.points[i + 1]

        if self.location.x > stop.x + self.r then
            self.location.x = start.x - self.r
            self.location.y = start.y + (self.location.y - stop.y)
        end
    end
end 

-- function Vehicle:borders()
--     if self.location.x < -self.r then
--         self.location.x = width + self.r
--     end
--     if self.location.y < -self.r then
--         self.location.y = height + self.r
--     end
--     if self.location.x > width + self.r then
--         self.location.x = -self.r
--     end
--     if self.location.y > height + self.r then
--         self.location.y = -self.r
--     end
-- end


function Vehicle:draw()
    local theta = self.velocity:heading() + math.pi / 2
    love.graphics.push()
    love.graphics.translate(self.location.x, self.location.y)
    love.graphics.rotate(theta)
    love.graphics.polygon("fill", self.vertices)
    love.graphics.pop()
end

function getNormalPoint(p, a, b)
    local ap = p - a
    local ab = b - a
    ab:norm()
    ab:mul(ap:dot(ab))
    local point = a + ab
    return point
end