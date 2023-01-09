FlowMap = {}
FlowMap.__index = FlowMap

function FlowMap:create(size)
    local flow = {}
    setmetatable(flow, FlowMap)
    flow.field = {}
    flow.size = size or 20
    love.math.setRandomSeed(100)

    return flow
end

function FlowMap:init()
    local cols = math.floor(width / self.size)
    local rows = math.floor(height / self.size)
    
    local xoff = 0
    local yoff = 0

    for i = 1, cols do
        yoff = 0
        self.field[i] = {}
        for j = 1, rows do
            local theta = love.math.noise(xoff, yoff)
            theta = math.map(theta, 0, 1, 0, math.pi * 2)

            self.field[i][j] = Vector:create(math.cos(4 * theta), math.sin(4 * theta))
            yoff = yoff + 0.1
        end
        xoff = xoff + 0.1
    end
end 

function FlowMap:init2()
    local cols = math.floor(width / self.size)
    local rows = math.floor(height / self.size)
    
    local xoff = 0
    local yoff = 0

    local centerX = math.floor(cols / 2)
    local centerY = math.floor(rows / 2)

    for i = 1, cols do
        yoff = 0
        self.field[i] = {}
        for j = 1, rows do
            local theta = 0.2

            local vec = Vector:create((j - rows / 2), -(i - cols / 2))
            vec:norm()
            self.field[i][j] = vec
            yoff = yoff + 0.1
        end
        xoff = xoff + 0.1
    end
end

function FlowMap:draw()
    for i = 1, #self.field do
        for j = 1, #self.field[i] do
            local cx = self.size * (i - 1) + self.size / 2
            local cy = self.size * (j - 1) + self.size / 2

            drawVector(self.field[i][j], cx, cy, self.size / 2 - 2)
        end
    end
end

function FlowMap:lookup(location)
    if location.y > 0 and location.x > 0 then
        local col = math.floor(location.x / self.size) + 1
        local row = math.floor(location.y / self.size) + 1
        
        -- костыль
        if location.x >= width then
            col = col - 1
        end 
        -- костыль
        if location.y >= height then
            row = row - 1
        end 
        
        return self.field[col][row]:copy()
    end
end 

function drawVector(v, x, y, scale)
    love.graphics.push()

    love.graphics.translate(x, y)
    love.graphics.rotate(v:heading())
    local len = v:mag() * scale
    love.graphics.line(0, 0, len, 0)
    love.graphics.circle('fill', len, 0, 2)

    love.graphics.pop()
end