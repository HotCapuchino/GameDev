require('vector')
require('ground')
require('background')
require('bird')
require('pipe')
require('obstacles')

GameState = {
    NOT_STARTED = 1,
    ACTIVE = 2,
    FINISHED = 3,
}

GameLevel = {
    EASY = 1,
    MEDIUM = 2,
    HARD = 3,
    CRAZY = 4
}

Game = {}
Game.__index = Game

function Game:create()
    local game = {}
    setmetatable(game, Game)

    -- sounds
    game.birdDieSound = love.audio.newSource('res/audio/die.wav', 'static')
    game.birdHitSound = love.audio.newSource('res/audio/hit.wav', 'static')
    game.pointScoredSound = love.audio.newSource('res/audio/point.wav', 'static')
    game.swooshSound = love.audio.newSource('res/audio/swoosh.wav', 'static')
    game.windSound = love.audio.newSource('res/audio/wing.wav', 'static')

    -- utils
    game.state = nil
    game.level = nil

    -- quads
    game.messageQuad = nil
    game.gameoverQuad = nil
    game.scoreQuad = nil

    -- sprites
    game.scoreSprites = {}
    game.infoSprites = { gameover = nil, message = nil }

    -- score
    game.score = nil

    -- game elements
    game.bird = Bird:create()
    game.background = Background:create(Vector:create(0, 0))

    local groundLevel = Vector:create(0, 500)
    local availableHeight = groundLevel.y

    game.ground = Ground:create(groundLevel)
    game.obstacles = Obstacles:create(2, availableHeight)

    game:loadSprites()
    game:init()

    return game
end

function Game:init()
    self.state = GameState.NOT_STARTED

    self.score = 0
    self.level = GameLevel.EASY

    self.background:init()
    self.bird:init()
    self.obstacles:init()
    self:updateDifficulty()
end

function Game:loadSprites()
    local maxWidth = 0
    -- загрузка цифр счета
    for i = 0, 9 do
        self.scoreSprites[i + 1] = love.graphics.newImage('res/sprites/' .. tostring(i) .. '.png')

        if self.scoreSprites[i + 1]:getWidth() > maxWidth then
            maxWidth = self.scoreSprites[i + 1]:getWidth()
        end
    end

    self.scoreQuad = love.graphics.newQuad(0, 0, maxWidth, self.scoreSprites[1]:getHeight(),
        self.scoreSprites[1])

    -- загрузка спрайтов сообщений
    self.infoSprites['gameover'] = love.graphics.newImage('res/sprites/gameover.png')
    self.infoSprites['message'] = love.graphics.newImage('res/sprites/message.png')

    self.messageQuad = love.graphics.newQuad(0, 0, self.infoSprites['message']:getWidth(),
        self.infoSprites['message']:getHeight(),
        self.infoSprites['message'])
    self.gameoverQuad = love.graphics.newQuad(0, 0, self.infoSprites['gameover']:getWidth(),
        self.infoSprites['gameover']:getHeight(),
        self.infoSprites['gameover'])
end

function Game:draw()
    self.background:draw()

    if self.state == GameState.ACTIVE or self.state == GameState.FINISHED then
        self.obstacles:draw()
    end

    self.ground:draw()

    if self.state == GameState.NOT_STARTED then
        self:drawMessage(self.infoSprites['message'], self.messageQuad)
    else
        self:drawScore()

        if self.state == GameState.FINISHED then
            self:drawMessage(self.infoSprites['gameover'], self.gameoverQuad)
        end

        self.bird:draw()
    end
end

function Game:drawScore()
    local stringifiedScore = tostring(self.score)
    local amountOfSprites = #stringifiedScore

    local spritesToDraw = {}
    local gap = 10
    local overallWidth = 0

    for i = 1, amountOfSprites do
        local char = stringifiedScore:sub(i, i)
        spritesToDraw[i] = self.scoreSprites[tonumber(char) + 1]

        overallWidth = overallWidth + spritesToDraw[i]:getWidth()

        if i ~= amountOfSprites then
            overallWidth = overallWidth + gap
        end
    end

    local prevX = love.graphics.getWidth() / 2 - overallWidth / 2
    local cY = 30

    for _, value in ipairs(spritesToDraw) do
        love.graphics.draw(value, self.scoreQuad, prevX, cY)

        prevX = prevX + value:getWidth() + gap
    end
end

function Game:drawMessage(sprite, quad)
    local cX = love.graphics.getWidth() / 2
    local cY = love.graphics.getHeight() / 2

    local messageWidth = sprite:getWidth()
    local messageHeight = sprite:getHeight()

    local x = cX - messageWidth / 2
    local y = cY - messageHeight / 2 - 50

    love.graphics.draw(sprite, quad, x, y)
end

function Game:interraction(key)
    if key == 'escape' then
        love.event.quit()
    end
    if key == 'backspace' and self.state == GameState.ACTIVE then
        self:init()
        self.state = GameState.NOT_STARTED
    end

    if key == 'return' and (self.state == GameState.NOT_STARTED or self.state == GameState.FINISHED) then
        self:init()

        if self.state == GameState.NOT_STARTED then
            self.state = GameState.ACTIVE
            self:playSound(self.swooshSound)
        else
            self.state = GameState.NOT_STARTED
        end
    end

    if self.state == GameState.ACTIVE and (key == 'space' or key == 'return') then
        self.bird:applyForce(Vector:create(0, -1.5))
        if not self.bird.inactive then
            self:playSound(self.windSound)
        end
    end
end

function Game:update()
    -- TODO: логика прибавления очков

    if self.state == GameState.ACTIVE or self.state == GameState.NOT_STARTED then
        self.ground:update()
        self.background:update()

        if self.state == GameState.ACTIVE then
            self.bird:update()
            self.obstacles:update()
        end

        self.bird:checkCollision()

        if self.bird:checkCollision(self.ground) then
            self.state = GameState.FINISHED
            self:playSound(self.birdDieSound)
        end

        if not self.bird.inactive then
            if self.bird:checkCollision(self.obstacles) then
                self.ground:updateSpeed(0)
                self.background:updateSpeed(0)
                self.obstacles:updateSpeed(0)
                self:playSound(self.birdHitSound)
            end
        end

        if self.bird:checkPointScored(self.obstacles) then
            self:playSound(self.pointScoredSound)
            self:updateScore()
        end
    end

end

function Game:playSound(source)
    love.audio.play(source)
end

function Game:updateScore()
    self.score = self.score + 1

    if self.score % 5 == 0 then
        self:updateDifficulty()
    end
end

function Game:updateDifficulty()
    local maxLevel = GameLevel.CRAZY

    if self.level + 1 > maxLevel then
        self.level = GameLevel.CRAZY
    elseif self.level == nil then
        self.level = GameLevel.EASY
    else
        self.level = self.level + 1
    end

    self.ground:updateSpeed(self.level)
    self.bird:updateSpeed(self.level)
    self.background:updateSpeed(self.level)
    self.obstacles:updateSpeed(self.level)
end
