Background = {}
Background.__index = Background

function Background:create(position)
    local background = {}
    setmetatable(background, Background)

    background.spriteDay = love.graphics.newImage('res/sprites/background-day.png')
    background.spriteNight = love.graphics.newImage('res/sprites/background-night.png')
    background.spriteDay:setWrap('repeat', 'repeat')
    background.spriteNight:setWrap('repeat', 'repeat')

    background.chosenSprite = background.spriteDay

    background.quad = love.graphics.newQuad(0, 0, love.graphics.getWidth() * 2,
        love.graphics.getHeight(),
        background.spriteDay)
    background.position = position
    background.speed = 0

    return background
end

function Background:init()
    math.randomseed(os.clock())

    if math.random(1, 2) == 1 then
        self.chosenSprite = self.spriteDay
    else
        self.chosenSprite = self.spriteNight
    end
end

function Background:draw()
    love.graphics.draw(self.chosenSprite, self.quad, self.position.x, self.position.y)
end

function Background:update()
    self.position.x = self.position.x - 0.05 * self.speed

    if self.position.x < -self.spriteDay:getWidth() then
        self.position.x = 0
    end
end

function Background:updateSpeed(multiplier)
    self.speed = multiplier
end
