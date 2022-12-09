Bird = {}
Bird.__index = Bird

BirdTypes = {
    Bluebird = 'bluebird',
    Redbird = 'redbird',
    Yellowbird = 'yellowbird'
}

BirdFlapPosition = {
    Upflap = 'upflap',
    Midflap = 'midflap',
    Downflap = 'downflap'
}

BirdFlapDirection = {
    Up = -1,
    Down = 1
}

function Bird:create()
    local bird = {}
    setmetatable(bird, Bird)

    local cX = love.graphics.getWidth() / 2 - 50
    local cY = love.graphics.getHeight() / 2 - 50

    bird.center = nil

    bird.flapPosition = BirdFlapPosition.Midflap
    bird.flapDirection = BirdFlapDirection.Up
    bird.position = Vector:create(cX, cY)
    bird.birdType = nil
    bird.inactive = false

    bird.currentSprite = nil
    bird.sprites = {}
    bird.quad = nil
    bird.gravity = Vector:create(0, 0.7)

    bird.minAngle = -0.6
    bird.angle = 0
    bird.maxAngle = 1.2

    bird.acceleration = Vector:create(0, 0)

    bird.frameUpdateInterval = 48
    bird.framesSinceSpriteUpdated = 0

    bird:loadSprites()

    return bird
end

function Bird:loadSprites()
    -- загрузка спрайтов птиц
    for _, birdType in pairs(BirdTypes) do
        self.sprites[birdType] = {}

        for _, birdPosition in pairs(BirdFlapPosition) do
            self.sprites[birdType][birdPosition] = love.graphics.newImage('res/sprites/' ..
                birdType .. '-' .. birdPosition .. '.png')
        end
    end
end

function Bird:init()
    math.randomseed(os.clock())

    local cX = love.graphics.getWidth() / 2 - 50
    local cY = love.graphics.getHeight() / 2 - 50

    self.position = Vector:create(cX, cY)
    self.inactive = false
    self.gravity = Vector:create(0, 0.7)

    local randomNum = math.random(1, 3)
    if randomNum == 1 then
        self.birdType = BirdTypes.Bluebird
    elseif randomNum == 2 then
        self.birdType = BirdTypes.Redbird
    else
        self.birdType = BirdTypes.Yellowbird
    end

    self.flapPosition = BirdFlapPosition.Midflap
    self.flapDirection = BirdFlapDirection.Up
    self.currentSprite = self.sprites[self.birdType][self.flapPosition]

    self.center = Vector:create(cX - self.currentSprite:getWidth(), cY - self.currentSprite:getHeight())

    self.quad = love.graphics.newQuad(0, 0, self.currentSprite:getWidth(), self.currentSprite:getHeight(),
        self.currentSprite)
end

function Bird:update()
    self:updateSprite()
    self.position:add(self.acceleration)
    self.position:add(self.gravity)

    self.angle = self.angle + 0.008
    if self.angle > self.maxAngle then
        self.angle = self.maxAngle
    end

    self.acceleration.y = self.acceleration.y + 0.01
    if self.acceleration.y > 0 then
        self.acceleration:mul(0)
    end
end

function Bird:updateSprite()
    if self.frameUpdateInterval == self.framesSinceSpriteUpdated then
        if self.flapPosition == BirdFlapPosition.Upflap then
            self.flapPosition = BirdFlapPosition.Midflap
            self.flapDirection = BirdFlapDirection.Down
        elseif self.flapPosition == BirdFlapPosition.Downflap then
            self.flapPosition = BirdFlapPosition.Midflap
            self.flapDirection = BirdFlapDirection.Up
        else
            if self.flapDirection == BirdFlapDirection.Up then
                self.flapPosition = BirdFlapPosition.Upflap
            else
                self.flapPosition = BirdFlapPosition.Downflap
            end
        end

        self.currentSprite = self.sprites[self.birdType][self.flapPosition]
        self.framesSinceSpriteUpdated = 0
    else
        self.framesSinceSpriteUpdated = self.framesSinceSpriteUpdated + 1
    end
end

function Bird:draw()
    love.graphics.draw(self.currentSprite, self.quad, self.position.x, self.position.y, self.angle)
end

function Bird:applyForce(force)
    if not self.inactive then
        self.acceleration:add(force)
        if self.acceleration.y < -1.5 then
            self.acceleration.y = -1.5
        end

        self.angle = self.minAngle
    end
end

function Bird:getBoundingBox()
    local topLeft = self.position
    local topRight = Vector:create(self.position.x + self.currentSprite:getWidth(), self.position.y)
    local bottomLeft = Vector:create(self.position.x, self.position.y + self.currentSprite:getHeight())
    local bottomRight = Vector:create(self.position.x + self.currentSprite:getWidth(),
        self.position.y + self.currentSprite:getHeight())

    return { topLeft, topRight, bottomLeft, bottomRight }
end

function Bird:updateSpeed(multiplier)
    self.frameUpdateInterval = self.frameUpdateInterval - multiplier * 6
end

function Bird:checkCollision(instance)
    local birdBbox = self:getBoundingBox()

    if instance == nil then
        -- коллизия с верхней границой
        if birdBbox[1].y < 0 then
            self.position.y = 0
        end
    elseif getmetatable(instance) == Ground then
        -- коллизия с землей
        if CollisionDetection(instance:getBoundingBox(), birdBbox) then
            self.gravity = Vector:create(0, 0)
            return true
        end
    elseif getmetatable(instance) == Obstacles then
        -- коллизия с трубами
        for _, pipe in ipairs(instance.pipes) do
            local upperPipeBbox = pipe:getUpperBoundingBox()
            local lowerPipeBbox = pipe:getLowerBoundingBox()

            if CollisionDetection(upperPipeBbox, birdBbox) or CollisionDetection(lowerPipeBbox, birdBbox) then
                self.inactive = true
                return true
            end
        end
    end

    return false

end

function Bird:checkPointScored(obstacles)
    local birdBbox = self:getBoundingBox()
    local pointScored = false

    if getmetatable(obstacles) == Obstacles then
        for i = 1, #obstacles.pipes do
            local pipeBbox = obstacles.pipes[i]:getBoundingBox()

            if not obstacles.pipes[i].checked and pipeBbox[2].x < birdBbox[1].x then
                obstacles.pipes[i].checked = true
                pointScored = true
                break
            end
        end
    end

    return pointScored
end

-- рассчет коллизии для двух прямоугольников
function CollisionDetection(masterBbox, slaveBbox)
    local minX = masterBbox[1].x
    local minY = masterBbox[1].y

    local maxX = masterBbox[4].x
    local maxY = masterBbox[4].y

    for _, vector in ipairs(slaveBbox) do
        if vector.x > minX and vector.x < maxX and vector.y > minY and vector.y < maxY then
            return true
        end
    end

    return false
end
