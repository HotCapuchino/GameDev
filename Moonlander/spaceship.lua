Spaceship = {}
Spaceship.__index = Spaceship

LandingStatus = {
    SUCCESS = 1,
    FAILURE = 2,
    NOT_LANDED = 3
}

EngineColor = { r = 105 / 255, g = 205 / 255, b = 245 / 255 }

function Spaceship:create(position)
    local spaceship = {}
    setmetatable(spaceship, Spaceship)

    spaceship.initialPosition = position
    spaceship.position = Vector:copy(position)

    spaceship.velocity = Vector:create(love.timer.getDelta() * 10, 0)
    spaceship.maxVerticalSpeed = 0.1
    spaceship.maxHorizontalSpeed = 0.1

    spaceship.acceleration = Vector:create(0, 0)

    spaceship.angleVelocity = 0
    spaceship.angle = 0
    spaceship.maxPossibleLandingAngle = 25

    spaceship.destroyed = false
    spaceship.active = false
    spaceship.activeDuration = nil
    spaceship.inactiveDuration = os.clock()
    spaceship.landingStatus = LandingStatus.NOT_LANDED

    spaceship.elements = {
        -- central part of spaceship
        {
            element = 'polygon',
            type = 'fill',
            points = { -5, -1, 5, -1, 5, 1, -5, 1 },
            translatedPoints = { -5, -1, 5, -1, 5, 1, -5, 1 }
        },
        -- spaceship bottom
        {
            element = 'line',
            type = nil,
            points = { -7, 6, -4, 1 },
            translatedPoints = { -7, 6, -4, 1 }
        },
        {
            element = 'line',
            type = nil,
            points = { 7, 6, 4, 1 },
            translatedPoints = { 7, 6, 4, 1 }
        },
        -- landing platforms of spaceship
        {
            element = 'polygon',
            type = 'fill',
            points = { -9, 6, -5, 6, -5, 7, -9, 7 },
            translatedPoints = { -9, 6, -5, 6, -5, 7, -9, 7 }
        },
        {
            element = 'polygon',
            type = 'fill',
            points = { 5, 6, 9, 6, 9, 7, 5, 7 },
            translatedPoints = { 5, 6, 9, 6, 9, 7, 5, 7 }
        },
        -- spaceship jet
        {
            element = 'polygon',
            type = 'line',
            points = { -2, 1, 2, 1, -4, 5, 4, 5 },
            translatedPoints = { -2, 1, 2, 1, -4, 5, 4, 5 }
        },
        -- spaceship cabin
        {
            element = 'polygon',
            type = 'line',
            points = { -5, -7, -3, -10, 3, -10, 5, -7, 5, -4, 3, -1, -3, -1, -5, -4 },
            translatedPoints = { -5, -7, -3, -10, 3, -10, 5, -7, 5, -4, 3, -1, -3, -1, -5, -4 }
        },
    }

    spaceship.collision = Collision:create()
    spaceship.engineShed = {
        small = { -1, 5, 1, 5, 0, 7 },
        middle = { -2, 5, 2, 5, 0, 9 },
        big = { -3, 5, 3, 5, 0, 11 }
    }

    return spaceship
end

function Spaceship:init()
    self.position = Vector:copy(self.initialPosition)
    math.randomseed(os.clock())

    if math.random() > 0.5 then
        self.velocity = Vector:create(love.timer.getDelta() * 10, 0)
    else
        self.velocity = Vector:create(love.timer.getDelta() * -10, 0)
    end
    self.maxVerticalSpeed = 0.1
    self.maxHorizontalSpeed = 0.1

    self.acceleration = Vector:create(0, 0)

    self.angleVelocity = 0
    self.angle = 0

    self.destroyed = false
    self.active = false
    self.landingStatus = LandingStatus.NOT_LANDED
end

function Spaceship:draw()
    love.graphics.push()
    love.graphics.translate(self.position.x, self.position.y)
    love.graphics.rotate(self.angle)

    for _, table in pairs(self.elements) do
        if table['element'] == 'polygon' then
            love.graphics.polygon(table['type'], table['points'])
        else
            love.graphics.line(table['points'])
        end
    end

    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(EngineColor.r, EngineColor.g, EngineColor.b, 1)

    if self.active then
        if os.clock() - self.activeDuration > 1 then
            love.graphics.polygon('fill', self.engineShed.big)
        elseif os.clock() - self.activeDuration > 0.5 then
            love.graphics.polygon('fill', self.engineShed.middle)
        else
            love.graphics.polygon('fill', self.engineShed.small)
        end
    else
        if os.clock() - self.inactiveDuration < 0.5 then
            love.graphics.polygon('fill', self.engineShed.big)
        elseif os.clock() - self.inactiveDuration < 1 then
            love.graphics.polygon('fill', self.engineShed.middle)
        elseif os.clock() - self.inactiveDuration < 1.5 then
            love.graphics.polygon('fill', self.engineShed.small)
        end
    end

    love.graphics.setColor(r, g, b, a)
    love.graphics.pop()
end

function Spaceship:update()
    self.velocity:add(self.acceleration)
    self.position:add(self.velocity)
    self.angle = self.angle + self.angleVelocity

    if self.position.x < 0 then
        self.position.x = width
    end

    if self.position.x > width then
        self.position.x = 0
    end

    local angleToDegrees = math.deg(self.angle)

    if angleToDegrees < -90 then
        self.angle = math.rad(-90)
    elseif angleToDegrees > 90 then
        self.angle = math.rad(90)
    end

    self.acceleration:mul(0)
    self:updateSpaceshipPolygonCoords()
end

function Spaceship:updateSpaceshipPolygonCoords()
    for index, table in ipairs(self.elements) do
        local points = table['points']

        for i = 1, #points - 1, 2 do
            local x = points[i] + self.position.x
            local y = points[i + 1] + self.position.y
            local translatedX = self.position.x + (x - self.position.x) * math.cos(self.angle) -
                (y - self.position.y) * math.sin(self.angle)
            local translatedY = self.position.y + (x - self.position.x) * math.sin(self.angle) -
                (y - self.position.y) * math.cos(self.angle)

            self.elements[index]['translatedPoints'][i] = translatedX
            self.elements[index]['translatedPoints'][i + 1] = translatedY
        end
    end
end

function Spaceship:rotate(dangle)
    self.angle = self.angle + dangle
end

function Spaceship:applyForce(force)
    self.acceleration:add(force)
end

function Spaceship:toggleActivity(active)
    if active ~= self.active then
        if not active then
            self.inactiveDuration = os.clock()
        else
            self.activeDuration = os.clock()
        end
    end

    self.active = active
end

function Spaceship:checkForCollision(terrain)
    if self.position.y < -100 then
        self.destroyed = true
        self.landingStatus = LandingStatus.FAILURE
        self.active = false

        return true
    end

    local leftX = nil
    local rightX = nil

    -- searching for the border left and border right point of spaceship
    for _, table in pairs(self.elements) do
        local translatedPoints = table['translatedPoints']

        for i = 1, #translatedPoints - 1, 2 do
            local translatedX = translatedPoints[i]

            if leftX == nil then
                leftX = translatedX
            elseif leftX > translatedX then
                leftX = translatedX
            end

            if rightX == nil then
                rightX = translatedX
            elseif rightX < translatedX then
                rightX = translatedX
            end
        end
    end

    -- collecting polygon points that are the closest to the spaceship
    local minDeltaLeft = width
    local minDeltaRight = width

    local minIndex = nil
    local maxIndex = nil

    for i = 1, #terrain.points do
        local point = terrain.points[i]

        if point.x < leftX and (leftX - point.x) < minDeltaLeft then
            minDeltaLeft = leftX - point.x
            minIndex = i
        end

        if point.x > rightX and (point.x - rightX) < minDeltaRight then
            minDeltaRight = point.x - rightX
            maxIndex = i
        end
    end

    -- constructing segments that are the closest to the spaceship rn
    local closePoints = {}
    local counter = 1

    if not minIndex or not maxIndex then
        return
    end

    for i = minIndex, maxIndex do
        closePoints[counter] = terrain.points[i]
        counter = counter + 1
    end

    local hasIntersection = false

    local intersectionPoint1 = nil
    local intersectionPoint2 = nil

    for i = 1, #closePoints - 1 do
        local point1 = closePoints[i]
        local point2 = closePoints[i + 1]

        -- checking whether spaceship collide with one of the found segments
        for _, table in pairs(self.elements) do
            local translatedPoints = table['translatedPoints']

            for i = 1, #translatedPoints - 3, 2 do
                local pointToCheck1 = Vector:create(translatedPoints[i], translatedPoints[i + 1])
                local pointToCheck2 = Vector:create(translatedPoints[i + 2], translatedPoints[i + 3])

                if self.collision:hasIntersection(point1, point2, pointToCheck1, pointToCheck2) then
                    hasIntersection = true
                    intersectionPoint1 = point1
                    intersectionPoint2 = point2
                    break
                end
            end

            if hasIntersection then
                break
            end
        end

        if hasIntersection then
            break
        end
    end

    if hasIntersection then
        -- calculate angle for collided segment
        local intersectionAngle = math.deg(math.abs(math.atan((intersectionPoint2.y - intersectionPoint1.y) /
            (intersectionPoint2.x - intersectionPoint1.x))))

        if math.abs(intersectionAngle - math.deg(self.angle)) < 7 and intersectionAngle < self.maxPossibleLandingAngle
            and self.velocity.y <= self.maxVerticalSpeed and self.velocity.x <= self.maxHorizontalSpeed then
            -- landing successful
            self.landingStatus = LandingStatus.SUCCESS
        else
            -- spaceship exploded
            self.destroyed = true
            self.landingStatus = LandingStatus.FAILURE
        end

        self.active = false
        self.velocity = Vector:create(0, 0)

        return true
    end

    return false
end
