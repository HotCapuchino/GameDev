Sky = {}
Sky.__index = Sky

function Sky:create()
    local sky = {}
    setmetatable(sky, Sky)

    sky.stars = {}

    return sky
end

function Sky:generateStars(terrain)
    local cellDimension = 80

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

                local lastIndex = 1

                if #self.stars > 0 then
                    lastIndex = #self.stars + 1
                end

                self.stars[lastIndex] = starPosition
            end
        end
    end
end

function Sky:update(dt)
    -- TODO: make stars flickering
end

function Sky:draw()
    for _, star in ipairs(self.stars) do
        local cX = star.x
        local cY = star.y
        love.graphics.circle('fill', cX, cY, 1)
    end
end
