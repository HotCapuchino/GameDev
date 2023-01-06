require("vector")
require("noise")
require("terrain")
require("spaceship")
require("sky")
require("collision")

Game = {}
Game.__index = Game

GameState = {
    NOT_STARTED = 1,
    LEGEND = 2,
    ACTIVE = 3,
    FINISHED = 4,
    SHOWING_RESULTS = 5
}

ALERT_COLOR = { r = 220 / 255, g = 20 / 255, b = 20 / 255 }

function Game:create()
    local game = {}
    setmetatable(game, Game)
    math.randomseed(os.clock())

    game.fontName = '/res/AtariClassic.ttf'

    game.score = 0
    game.fuel = 200

    game.explosionSound = love.audio.newSource('/res/explosion.wav', 'static')
    game.engineSound = love.audio.newSource('/res/engineSound.wav', 'stream')
    game.lowOnFuelSound = love.audio.newSource('/res/alarm.wav', 'static')
    game.deathLineSound = love.audio.newSource('/res/houston.wav', 'static')
    game.legendSound = love.audio.newSource('res/terminatorTheme.mp3', 'stream')

    game.lowFuelMark = 100
    game.lowFuelPlayed = false

    game.state = GameState.NOT_STARTED

    game.terrain = Terrain:create()
    game.spaceship = Spaceship:create(Vector:create(math.random(math.floor(width * 0.1), math.floor(width * 0.8)),
        math.floor(height * 0.2)))
    game.sky = Sky:create()

    game:init()
    game:resetScoreAndFuel()

    return game
end

function Game:init()
    self.terrain:generate()
    self.sky:init()
    self.sky:generateStars(self.terrain)
    self.spaceship:init()

    self.lowFuelPlayed = false

    self.state = GameState.NOT_STARTED
end

function Game:resetScoreAndFuel()
    self.score = 0
    self.fuel = 200
end

function Game:draw()
    if self.state == GameState.NOT_STARTED then
        self:drawCenteredText("Welcome to moonlading game!\nPress ENTER to start the game.\nPress ESCAPE to exit the game.\nPress L to acquaint with LEGEND."
            , 36)
    elseif self.state == GameState.LEGEND then
        self:drawCenteredText("Hello astronaunts!\nYour mission is simple yet crucial for\nUS government!\nDemocratic world came across red alert\nonce again, but this time things are getting\nreally hot!\nCommunists are trying to take space superiority,\nand it's our resposibility to protect moon\nfrom antidemocratic invasion!\nPress ENTER to start!"
            , 26)
    else
        self.terrain:draw()
        self.sky:draw()

        if self.fuel < self.lowFuelMark and self.state ~= GameState.SHOWING_RESULTS then
            local r, g, b, a = love.graphics.getColor()

            love.graphics.setColor(ALERT_COLOR.r, ALERT_COLOR.g, ALERT_COLOR.b, 1)
            self:drawCenteredText("Caution! Low fuel", 20)
            love.graphics.setColor(r, g, b, a)
        end

        self.spaceship:draw()

        self:drawInfo()

        if self.state == GameState.SHOWING_RESULTS then
            if self.spaceship.landingStatus == LandingStatus.FAILURE then
                self:drawCenteredText("Rest in piece, astronaut...\nYour name will be carved in stone..\nPress ENTER to try again."
                    , 20)
            else
                self:drawCenteredText("Congratulations!\nYou managed to repel red alert!..\nPress ENTER to try again.",
                    20)
            end
        end
    end
end

function Game:update(dt)
    if self.state == GameState.NOT_STARTED then
        if love.keyboard.isDown('l') then
            self.state = GameState.LEGEND
        end
    end

    if self.state == GameState.LEGEND then
        if not self.legendSound:isPlaying() then
            self.legendSound:play()
        end
    else
        self.legendSound:stop()
    end

    if love.keyboard.isDown('return') and
        (
        self.state == GameState.NOT_STARTED or self.state == GameState.FINISHED or
            self.state == GameState.SHOWING_RESULTS) then
        self:init()

        if self.fuel == 0 then
            self:resetScoreAndFuel()
        end

        self.state = GameState.ACTIVE
    end

    if love.keyboard.isDown('escape') then
        if self.state == GameState.NOT_STARTED or self.state == GameState.FINISHED then
            love.event.quit()
        else
            self.state = GameState.NOT_STARTED
        end
    end

    if self.state == GameState.ACTIVE then
        if love.keyboard.isDown('up') then
            if self.fuel > 0 then
                local x = 0.06 * dt * math.sin(self.spaceship.angle)
                local y = -0.04 * dt * math.cos(self.spaceship.angle)

                if not self.engineSound:isPlaying() then
                    self.engineSound:play()
                end

                self.spaceship:toggleActivity(true)
                self.spaceship:applyForce(Vector:create(x, y))

                if 10 * dt > self.fuel then
                    self.fuel = 0
                    self.engineSound:stop()
                    self.spaceship:toggleActivity(false)
                else
                    self.fuel = self.fuel - 10 * dt
                end

                if self.fuel < self.lowFuelMark and not self.lowFuelPlayed then
                    self.lowFuelPlayed = true
                    self:playSound(self.lowOnFuelSound)
                end
            end
        else
            self.engineSound:stop()
            self.spaceship:toggleActivity(false)
        end

        if love.keyboard.isDown('left') then
            self.spaceship:rotate(-2 * dt)
        elseif love.keyboard.isDown('right') then
            self.spaceship:rotate(2 * dt)
        end

        self.spaceship:applyForce(Vector:create(0, 0.02 * dt))

        self.sky:update()
        self.spaceship:update(dt)

        if self.spaceship:checkForCollision(self.terrain) then
            self.state = GameState.SHOWING_RESULTS
            self.engineSound:stop()

            if self.spaceship.landingStatus == LandingStatus.FAILURE then
                self:playSound(self.explosionSound)
                self:playSound(self.deathLineSound)
            else
                self.score = self.score + 100
            end
        end
    end
end

function Game:drawInfo()
    local r, g, b, a = love.graphics.getColor()

    local font = love.graphics.newFont(self.fontName, 16)
    love.graphics.setFont(font)
    local textHeight = font:getHeight()
    local gap = 10

    love.graphics.print("Score " .. self.score, 40, 40)

    if self.fuel < self.lowFuelMark then
        love.graphics.setColor(ALERT_COLOR.r, ALERT_COLOR.g, ALERT_COLOR.b, 1)
    end

    love.graphics.print("Fuel " .. math.floor(self.fuel), 40, 40 + textHeight + gap)
    love.graphics.setColor(r, g, b, a)

    local horizontalSpeedDirection = 'E'

    if self.spaceship.velocity.x < 0 then
        horizontalSpeedDirection = 'W'
    end

    if self.spaceship.velocity.x > self.spaceship.maxHorizontalSpeed then
        love.graphics.setColor(ALERT_COLOR.r, ALERT_COLOR.g, ALERT_COLOR.b, 1)
    end
    love.graphics.print("Horizontal speed " ..
        math.abs(math.floor(self.spaceship.velocity.x * 100)) .. horizontalSpeedDirection, width - 350, 40)
    love.graphics.setColor(r, g, b, a)

    if self.spaceship.velocity.y > self.spaceship.maxVerticalSpeed then
        love.graphics.setColor(ALERT_COLOR.r, ALERT_COLOR.g, ALERT_COLOR.b, 1)
    end
    love.graphics.print("Vertical speed " .. math.floor(self.spaceship.velocity.y * 100), width - 350,
        40 + textHeight + gap)
    love.graphics.setColor(r, g, b, a)

    if math.abs(math.deg(self.spaceship.angle)) > self.spaceship.maxPossibleLandingAngle then
        love.graphics.setColor(ALERT_COLOR.r, ALERT_COLOR.g, ALERT_COLOR.b, 1)
    end
    love.graphics.print("Spaceship angle " .. math.floor(self.spaceship.angle * 180 / math.pi), width - 350,
        40 + textHeight * 2 + gap * 2)

    love.graphics.setColor(r, g, b, a)
end

function Game:playSound(source)
    love.audio.play(source)
end

function Game:drawCenteredText(text, fontSize)
    local linesAmount = 1

    for i = 1, #text do
        if text:sub(i, i) == '\n' then
            linesAmount = linesAmount + 1
        end
    end

    local font = love.graphics.newFont(self.fontName, fontSize)
    love.graphics.setFont(font)

    local textWidth  = font:getWidth(text)
    local textHeight = font:getHeight(text) * linesAmount

    love.graphics.print(text, width / 2, height / 2, 0, 1, 1, textWidth / 2,
        textHeight / 2)
end
