ComplexPath = {}
ComplexPath.__index = ComplexPath

function ComplexPath:create(points, d)
    local complexPath = {}
    setmetatable(complexPath, ComplexPath)

    complexPath.points = points
    complexPath.d = 20 or d

    return complexPath
end

function ComplexPath:draw()
    local r, g, b, a = love.graphics.getColor()

    for i = 1, #self.points - 1 do
        local pathStart = self.points[i]
        local pathEnd = self.points[i + 1]

        love.graphics.setColor(0.31, 0.31, 0.31, 0.7)
        love.graphics.setLineWidth(self.d)
        love.graphics.line(pathStart.x, pathStart.y, pathEnd.x, pathEnd.y)

        love.graphics.setBlendMode("replace")
        love.graphics.circle("fill", pathStart.x, pathStart.y, self.d / 2)
        love.graphics.circle("fill", pathEnd.x, pathEnd.y, self.d / 2)
    
        love.graphics.setColor(0., 0., 0., 0.7)
        love.graphics.setLineWidth(self.d / 10)
        love.graphics.line(pathStart.x, pathStart.y, pathEnd.x, pathEnd.y)
    
        love.graphics.setColor(r, g, b, a)
    end

end