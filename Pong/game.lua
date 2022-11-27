require("ball")
require("racket")
require("vector")

GameState = {
    NOT_STARTED = 1,
    ACTIVE = 2,
    FINISHED = 3,
    SHOWING_SCORE = 4,
}

Players = {
    P1 = 'Player 1',
    P2 = 'Plyaer 2'
}

P1_COLOR = { r = 55 / 255, g = 195 / 255, b = 245 / 255 }
P2_COLOR = { r = 245 / 255, g = 55 / 255, b = 95 / 255 }

ScoreDisplayType = {
    SMALL = 1,
    BIG = 2
}

Game = {}
Game.__index = Game

function Game:create()
    local game = {}
    setmetatable(game, Game)

    game.fontName = '/res/pixel_font.ttf'
    game.state = GameState.NOT_STARTED
    game.winner = nil

    game.p1Score = 0
    game.p2Score = 0
    game.scoreToWin = 7
    game.scoreShowedLastTime = nil

    game.leftRacket = Racket:create(Players.P1)
    game.rightRacket = Racket:create(Players.P2)
    game.ball = Ball:create()

    return game
end

function Game:init()
    self.state = GameState.NOT_STARTED
    self.winner = nil

    self.p1Score = 0
    self.p2Score = 0

    self.leftRacket:init()
    self.rightRacket:init()
    self.ball:init()
end

function Game:finish()
    self.state = GameState.FINISHED

    if self.p1Score > self.p2Score then
        self.winner = Players.P1
    else
        self.winner = Players.P2
    end

    self.leftRacket:init()
    self.rightRacket:init()
    self.ball:hide()
end

function Game:draw()
    if self.state == GameState.NOT_STARTED then
        self:drawCenteredText('Welcome to Pong!', 60)
    elseif self.state == GameState.FINISHED then
        local winnerPlayer = ''

        if self.winner == Players.P1 then
            winnerPlayer = 'Player 1'
        else
            winnerPlayer = 'Player 2'
        end
        self:drawCenteredText('Game over!\nWinner is ' ..
            winnerPlayer .. '\nPress ENTER to play the game again \nPress ESCAPE to leave the game', 32)
    else
        if self.state == GameState.SHOWING_SCORE then
            if love.timer.getTime() - self.scoreShowedLastTime > 1 then
                self.scoreShowedLastTime = nil
                self.state = GameState.ACTIVE
            end
        end

        self.leftRacket:draw()
        self.rightRacket:draw()
        local displayType = ScoreDisplayType.BIG

        if self.state == GameState.ACTIVE then
            self.ball:draw()
            displayType = ScoreDisplayType.SMALL
        end

        self:displayScore(displayType)
    end
end

function Game:displayScore(displayType)
    local r, g, b, a = love.graphics.getColor()

    local centeredX = love.graphics.getWidth() / 2
    local centeredY = love.graphics.getHeight() / 2

    local fontSize = 60
    local padding = 50

    if displayType == ScoreDisplayType.SMALL then
        centeredY = 30
        fontSize = 20
        padding = 30
    end


    local font = love.graphics.newFont(self.fontName, fontSize)
    love.graphics.setFont(font)

    local textWidth  = font:getWidth(self.p1Score)
    local textHeight = font:getHeight()

    love.graphics.setColor(P1_COLOR.r, P1_COLOR.g, P1_COLOR.b, 1)
    love.graphics.print(self.p1Score, centeredX - padding, centeredY, 0, 1, 1, textWidth / 2, textHeight / 2)

    local textWidth  = font:getWidth(self.p2Score)
    local textHeight = font:getHeight()

    love.graphics.setColor(P2_COLOR.r, P2_COLOR.g, P2_COLOR.b, 1)
    love.graphics.print(self.p2Score, centeredX + padding, centeredY, 0, 1, 1, textWidth / 2, textHeight / 2)

    love.graphics.setColor(r, g, b, a)
end

function Game:update()
    if self.state == GameState.ACTIVE then
        if love.keyboard.isDown("w") then
            self.leftRacket:applyForce(Vector:create(0, -1))
        elseif love.keyboard.isDown('s') then
            self.leftRacket:applyForce(Vector:create(0, 1))
        end

        if love.keyboard.isDown('up') then
            self.rightRacket:applyForce(Vector:create(0, -1))
        elseif love.keyboard.isDown('down') then
            self.rightRacket:applyForce(Vector:create(0, 1))
        end

        self.leftRacket:update()
        self.leftRacket:checkCollision()
        self.rightRacket:update()
        self.rightRacket:checkCollision()

        self.ball:update()
        self.ball:checkCollision(self.leftRacket)
        self.ball:checkCollision(self.rightRacket)

        if self:checkBallOutOfBounds() then
            if self.p1Score == self.scoreToWin or self.p2Score == self.scoreToWin then
                self:finish()
            else
                self.ball:init()
                self.rightRacket:init()
                self.leftRacket:init()

                self.state = GameState.SHOWING_SCORE
                self.scoreShowedLastTime = love.timer.getTime()
            end

        end
    end

    if love.keyboard.isDown('escape') then
        love.event.quit()
    end
    if love.keyboard.isDown('backspace') and self.state == GameState.ACTIVE then
        self:init()
        self.state = GameState.NOT_STARTED
    end

    if love.keyboard.isDown('return') and (self.state == GameState.NOT_STARTED or self.state == GameState.FINISHED) then
        self:init()
        self.state = GameState.ACTIVE
    end
end

function Game:checkBallOutOfBounds()
    local windowWidth = love.graphics.getWidth()
    local outOfBounds = false

    if self.ball.position.x > windowWidth then
        self.p1Score = self.p1Score + 1
        outOfBounds = true
    elseif self.ball.position.x < 0 then
        self.p2Score = self.p2Score + 1
        outOfBounds = true
    end

    return outOfBounds
end

function Game:drawCenteredText(text, fontSize)
    local font = love.graphics.newFont(self.fontName, fontSize)
    love.graphics.setFont(font)

    local textWidth  = font:getWidth(text)
    local textHeight = font:getHeight()

    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    love.graphics.print(text, windowWidth / 2, windowHeight / 2, 0, 1, 1, textWidth / 2, textHeight / 2)
end
