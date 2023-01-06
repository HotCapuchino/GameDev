Sky = {}
Sky.__index = Sky

Sky.STARS_COLOR = {
    WHITE = { r = 1, g = 1, b = 1 },
    PALE_WHITE = { r = 180 / 255, g = 180 / 255, b = 180 / 255 }
}

function Sky:create()
    local sky = {}
    setmetatable(sky, Sky)

    sky.stars = {}
    sky.color = nil
    sky.lastTimeColorChanged = os.clock()
    sky.currentColor = Sky.STARS_COLOR.WHITE

    return sky
end

function Sky:init()
    self.stars = {}
end

function Sky:generateStars(terrain)
    local cellDimension = 160

    for x = 0, width - cellDimension, cellDimension do
        for y = 0, height - cellDimension, cellDimension do
            local leftTop = Vector:create(x, y)
            local rightTop = Vector:create(x + cellDimension, y)
            local leftBottom = Vector:create(x, y + cellDimension)
            local rightBottom = Vector:create(x + cellDimension, y + cellDimension)
            local bbox = { leftTop, rightTop, leftBottom, rightBottom }
            local bboxAvailable = true

            for _, point in pairs(bbox) do
                if terrain:checkPolygonIncludesPoint(point) then
                    bboxAvailable = false
                    break
                end
            end

            if bboxAvailable then
                local starPosition = Vector:create(math.floor(math.random(x, x + cellDimension)),
                    math.floor(math.random(y, y + cellDimension)))

                if not terrain:checkPolygonIncludesPoint(starPosition) then
                    local lastIndex = 1

                    if #self.stars > 0 then
                        lastIndex = #self.stars + 1
                    end

                    self.stars[lastIndex] = starPosition
                end

            end
        end
    end
end

function Sky:update()
    local currentTime = os.clock()

    if currentTime - self.lastTimeColorChanged > 1 then
        if self.currentColor == Sky.STARS_COLOR.WHITE then
            self.currentColor = Sky.STARS_COLOR.PALE_WHITE
        else
            self.currentColor = Sky.STARS_COLOR.WHITE
        end

        self.lastTimeColorChanged = currentTime
    end
end

function Sky:draw()
    local r, g, b, a = love.graphics.getColor()

    love.graphics.setColor(self.currentColor.r, self.currentColor.g, self.currentColor.b, 1)

    for _, star in ipairs(self.stars) do
        local cX = star.x
        local cY = star.y
        love.graphics.circle('fill', cX, cY, 1)
    end

    love.graphics.setColor(r, g, b, a)
end
