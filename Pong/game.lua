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
    Computer = 'Computer',
    Player = 'Player'
}

COMPUTER_COLOR = { r = 55 / 255, g = 195 / 255, b = 245 / 255 }
PLAYER_COLOR = { r = 245 / 255, g = 55 / 255, b = 95 / 255 }

ScoreDisplayType = {
    SMALL = 1,
    BIG = 2
}

Game = {}
Game.__index = Game

function Game:create()
    local game = {}
    setmetatable(game, Game)

    -- resources
    game.fontName = '/res/AtariClassic.ttf'
    game.pongSound = love.audio.newSource('/res/pong.wav', 'static')
    game.victorySound = love.audio.newSource('/res/victory.wav', 'static')
    game.gameoverSound = love.audio.newSource('/res/gameover.wav', 'static')

    -- utils
    game.state = GameState.NOT_STARTED
    game.winner = nil
    game.multiplier = 0

    -- score
    game.computerScore = 0
    game.playerScore = 0
    game.scoreToWin = 9
    game.scoreShowedLastTime = nil

    -- game elements
    game.computerRacket = Racket:create(Players.Computer)
    game.playerRacket = Racket:create(Players.Player)
    game.ball = Ball:create()

    return game
end

function Game:init()
    self.state = GameState.NOT_STARTED
    self.winner = nil

    self.computerScore = 0
    self.playerScore = 0

    self.computerRacket:init()
    self.playerRacket:init()
    self.ball:init()
end

function Game:finish()
    self.state = GameState.FINISHED

    if self.computerScore > self.playerScore then
        self.winner = Players.Computer
        self:playSound(self.gameoverSound)
    else
        self.winner = Players.Player
        self:playSound(self.victorySound)
    end

    self.computerRacket:init()
    self.playerRacket:init()
    self.ball:hide()
end

function Game:draw()
    if self.state == GameState.NOT_STARTED then
        self:drawCenteredText('Welcome to Pong!\nPress ENTER to start the game!', 24)
    elseif self.state == GameState.FINISHED then
        if self.winner == Players.Computer then
            self:drawCenteredText('Game over!\nYou were be beaten by stupid machine!\nPress ENTER to play the game again \nPress ESCAPE to leave the game'
                , 18)
        else
            self:drawCenteredText('Victory!\nYou\'re the master chief!\nPress ENTER to play the game again \nPress ESCAPE to leave the game'
                , 18)
        end
    else
        if self.state == GameState.SHOWING_SCORE then
            if love.timer.getTime() - self.scoreShowedLastTime > 1 then
                self.scoreShowedLastTime = nil
                self.state = GameState.ACTIVE
            end
        end

        self.computerRacket:draw()
        self.playerRacket:draw()
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

    local textWidth  = font:getWidth(tostring(self.computerScore))
    local textHeight = font:getHeight()

    love.graphics.setColor(COMPUTER_COLOR.r, COMPUTER_COLOR.g, COMPUTER_COLOR.b, 1)
    love.graphics.print(tostring(self.computerScore), centeredX - padding, centeredY, 0, 1, 1, textWidth / 2,
        textHeight / 2)

    local textWidth  = font:getWidth(tostring(self.playerScore))
    local textHeight = font:getHeight()

    love.graphics.setColor(PLAYER_COLOR.r, PLAYER_COLOR.g, PLAYER_COLOR.b, 1)
    love.graphics.print(tostring(self.playerScore), centeredX + padding, centeredY, 0, 1, 1, textWidth / 2,
        textHeight / 2)

    love.graphics.setColor(r, g, b, a)
end

function Game:update()
    if self.state == GameState.ACTIVE then
        if love.keyboard.isDown('up') then
            self.playerRacket:applyForce(RacketDirection.UP)
        elseif love.keyboard.isDown('down') then
            self.playerRacket:applyForce(RacketDirection.DOWN)
        end

        self.computerRacket:update(self.ball)
        self.computerRacket:checkBorder()
        self.playerRacket:update()
        self.playerRacket:checkBorder()

        self.ball:update()
        self.ball:checkBorder()
        if self.ball:checkCollision(self.computerRacket) or self.ball:checkCollision(self.playerRacket) then
            self:playSound(self.pongSound)
        end

        if self:checkBallOutOfBounds() then
            self:updateMultiplier()

            if self.computerScore == self.scoreToWin or self.playerScore == self.scoreToWin then
                self:finish()
            else
                self.ball:init()
                self.ball:updateVelocity(self.multiplier)
                self.playerRacket:init()
                self.computerRacket:init()

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
        self.computerScore = self.computerScore + 1
        outOfBounds = true
    elseif self.ball.position.x < 0 then
        self.playerScore = self.playerScore + 1
        outOfBounds = true
    end

    return outOfBounds
end

function Game:updateMultiplier()
    self.multiplier = self.multiplier + 1

    if self.multiplier > 5 then
        self.multiplier = 5
    end
end

function Game:playSound(source)
    love.audio.stop()
    love.audio.play(source)
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
