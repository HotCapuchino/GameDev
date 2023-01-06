Terrain = {}
Terrain.__index = Terrain

function Terrain:create()
    local terrain = {}
    setmetatable(terrain, Terrain)

    terrain.points = {}
    terrain.collision = Collision:create()

    return terrain
end

function Terrain:generate()
    math.randomseed(os.clock())
    local noise = Noise:create()
    local ys = {}
    local maxValue = 0
    local minValue = 0
    local step = math.random(30, 40)
    local pointsAmount = width / step

    for i = 1, pointsAmount + 1 do
        local y = noise:perlin(math.random(1, 10), math.random(1, 10), math.random(1, 10))
        ys[i] = y

        if y > maxValue then
            maxValue = y
        end
        if y < minValue then
            minValue = y
        end
    end

    local perlinRange = maxValue - minValue

    local maxHeight = height
    local minHeight = math.floor(height * 0.6)
    local heightRange = maxHeight - minHeight
    local lastX = 0

    for i = 1, pointsAmount + 1 do
        local yRemapped = ((ys[i] - minValue) / perlinRange) * heightRange + minHeight

        self.points[i] = Vector:create(lastX, yRemapped)
        lastX = lastX + step + math.random(0, 20)
    end

    self:checkForStraightLines()
end

function Terrain:draw()
    for i = 1, #self.points - 1 do
        local firstPoint = self.points[i]
        local secondPoint = self.points[i + 1]
        love.graphics.line(firstPoint.x, firstPoint.y, secondPoint.x, secondPoint.y)
    end
end

function Terrain:checkForStraightLines()
    local straightLinesNeeded = 3
    local straightLinesPresent = 0

    local possiblePointsIndexesToChange = {}

    for i = 1, #self.points - 1 do
        local point1 = self.points[i]
        local point2 = self.points[i + 1]

        if point1.x > 0 and point2.x > 0 and point1.x < width and point2.x < width then
            local angle = math.deg(math.abs(math.atan((point2.y - point1.y) / (point2.x - point1.x))))

            if angle < 1 then
                straightLinesPresent = straightLinesPresent + 1
            elseif angle < 30 then
                local lastIndex = -1

                if #possiblePointsIndexesToChange == 0 then
                    lastIndex = 1
                else
                    lastIndex = #possiblePointsIndexesToChange
                end

                local newTable = {}
                newTable["index"] = i + 1
                newTable["y"] = point1.y

                possiblePointsIndexesToChange[lastIndex] = newTable
            end

        end
    end

    if straightLinesPresent < straightLinesNeeded then
        for _, table in pairs(possiblePointsIndexesToChange) do
            local pointIndex = table["index"]
            local y = table["y"]

            self.points[pointIndex].y = y

            if straightLinesPresent == straightLinesNeeded then
                break
            end
        end
    end
end

function Terrain:checkPolygonIncludesPoint(point)
    local intersectionsAmount = 0

    for i = 1, #self.points do
        local point1 = self.points[i]
        local point2 = nil

        if i == #self.points then
            -- closing polygon
            point2 = Vector:create(point1.x, height)
        else
            point2 = self.points[i + 1]
        end

        if point1.x > 0 and point2.x > 0 and point1.x < width and point2.x < width then
            -- checking if provided point is one of the polygon points
            if point1 == point or point2 == point then
                return true
            end
        end

        local exPoint = Vector:copy(point)
        exPoint.x = width * 2
        -- сhecking intersection with polygon segments
        if self.collision:hasIntersection(point1, point2, point, exPoint) then
            intersectionsAmount = intersectionsAmount + 1
        end
    end

    if intersectionsAmount == 0 then
        return false
    else
        return intersectionsAmount % 2 ~= 0
    end
end
