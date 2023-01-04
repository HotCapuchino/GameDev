local function onSegment(p1, p2, r)
    return (p2.x <= math.max(p1.x, r.x)) and (p2.x >= math.min(p1.x, r.x)) and (p2.y <= math.max(p1.y, r.y)) and
        (p2.y >= math.min(p1.y, r.y))
end

local function calculateDirection(p1, p2, r)
    local val = ((p2.y - p1.y) * (r.x - p2.x)) - ((p2.x - p1.x) * (r.y - p2.y))

    if val > 0 then
        return 1
    elseif val < 0 then
        return 2
    else
        return 0
    end
end

local function hasIntersection(l1p1, l1p2, l2p1, l2p2)
    local dir1 = calculateDirection(l1p1, l1p2, l2p1)
    local dir2 = calculateDirection(l1p1, l1p2, l2p2)
    local dir3 = calculateDirection(l2p1, l2p2, l1p1)
    local dir4 = calculateDirection(l2p1, l2p2, l1p2)

    if dir1 ~= dir2 and dir3 ~= dir4 then
        return true
    end

    if dir1 == 0 and onSegment(l1p1, l1p2, l2p1) then
        return true
    end

    if dir2 == 0 and onSegment(l1p1, l1p2, l2p2) then
        return true
    end

    if dir3 == 0 and onSegment(l2p1, l2p2, l1p1) then
        return true
    end

    if dir4 == 0 and onSegment(l2p1, l2p2, l1p2) then
        return true
    end

    return false
end

Terrain = {}
Terrain.__index = Terrain

function Terrain:create()
    local terrain = {}
    setmetatable(terrain, Terrain)

    terrain.points = {}

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

-- TODO: угол вычисляется неправильно
function Terrain:checkForStraightLines()
    local straightLinesNeeded = 3
    local straightLinesPresent = 0

    local possiblePointsIndexesToChange = {}

    for i = 1, #self.points - 1 do
        local point1 = self.points[i]
        local point2 = self.points[i + 1]

        if point1.x > 0 and point2.x > 0 and point1.x < width and point2.x < width then
            local angle = math.abs(math.atan(point2.y - point1.y, point2.x - point1.x) * (180 / math.pi))
            -- print(angle)

            if angle < 1 then
                straightLinesPresent = straightLinesPresent + 1
            elseif angle < 60 then
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
        if hasIntersection(point1, point2, point, exPoint) then
            intersectionsAmount = intersectionsAmount + 1
        end
    end

    if intersectionsAmount == 0 then
        return false
    else
        return intersectionsAmount % 2 ~= 0
    end
end
