Obstacles = {}
Obstacles.__index = Obstacles

function Obstacles:create(amount, availableHeight)
    local obstacles = {}
    setmetatable(obstacles, Obstacles)

    obstacles.sprites = {}
    obstacles.positions = {}
    obstacles.speed = 0

    obstacles.chosenSprite = nil
    obstacles.quad = nil

    obstacles.pipes = {}
    obstacles.pipesAmount = amount
    obstacles.availableHeight = availableHeight

    obstacles.horizontalGap = nil

    obstacles:loadSprites()

    return obstacles
end

function Obstacles:loadSprites()
    -- загрузка препятствий
    self.sprites[1] = love.graphics.newImage('res/sprites/pipe-red.png')
    self.sprites[1]:setWrap('repeat', 'repeat')
    self.sprites[2] = love.graphics.newImage('res/sprites/pipe-green.png')
    self.sprites[2]:setWrap('repeat', 'repeat')
end

function Obstacles:init()
    math.randomseed(os.clock())

    self.chosenSprite = self.sprites[math.random(1, #self.sprites)]
    self.chosenSprite:setWrap('repeat', 'repeat')
    self.quad = love.graphics.newQuad(0, 0, self.chosenSprite:getWidth(), self.chosenSprite:getHeight(),
        self.chosenSprite)

    local overallPipeWidth = self.chosenSprite:getWidth() * self.pipesAmount
    self.horizontalGap = (love.graphics.getWidth() - overallPipeWidth) / (self.pipesAmount)

    local currentX = love.graphics.getWidth()

    for i = 1, self.pipesAmount do
        self.pipes[i] = Pipe:create(Vector:create(currentX, 0), self.availableHeight, self.chosenSprite)

        currentX = currentX + self.chosenSprite:getWidth() + self.horizontalGap
    end
end

function Obstacles:draw()
    for i = 1, #self.pipes do
        self.pipes[i]:draw(self.quad)
    end
end

function Obstacles:update()
    for i = 1, #self.pipes do
        self.pipes[i]:update(0.2 * self.speed)
    end

    self:checkObstacleOutOfBoudns()
end

function Obstacles:updateSpeed(multiplier)
    self.speed = multiplier
end

-- логика шафла труб
function Obstacles:checkObstacleOutOfBoudns()
    local firstPipeIndex = nil

    for i = 1, #self.pipes do
        local bbox = self.pipes[i]:getBoundingBox()

        if bbox[2].x < 0 then
            firstPipeIndex = i
            break
        end
    end

    if firstPipeIndex ~= nil then
        self.pipes[firstPipeIndex] = Pipe:create(Vector:create(love.graphics.getWidth(), 0), self.availableHeight,
            self.chosenSprite)
    end

end
