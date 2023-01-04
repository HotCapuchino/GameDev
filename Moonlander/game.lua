require("vector")
require("noise")
require("terrain")
require("spaceship")
require("sky")

Game = {}
Game.__index = Game

GameState = {
    NOT_STARTED = 1,
    LEGEND = 2,
    ACTIVE = 3,
    FINISHED = 4,
}

function Game:create()
    local game = {}
    setmetatable(game, Game)

    game.score = 0
    game.fuel = 1000

    game.explosionSound = nil
    game.engineSound = nil
    game.spaceSounds = nil
    game.lowOnFuelSound = nil
    game.deathLineSound = nil

    game.state = GameState.NOT_STARTED

    game.terrain = Terrain:create()
    game.spaceship = Spaceship:create(Vector:create(math.floor(width * 0.2), math.floor(height * 0.2)))
    game.sky = Sky:create()

    game:init()

    return game
end

function Game:init()
    self.terrain:generate()
    self.sky:generateStars(self.terrain)
    self.spaceship:init()

    self.score = 0
    self.fuel = 1000

    -- just for test
    self.state = GameState.ACTIVE
end

function Game:draw()
    -- if self.state == GameState.NOT_STARTED then
    --     -- TODO: print instructions
    --     -- self:drawCenteredText("Welcome to moonlading game! Press ENTER to start the game. Press ESCAPE to exit the game."
    --     --     , 40)
    -- else
    if self.state == GameState.LEGEND then
        -- TODO: print mission text
    else
        self.terrain:draw()
        self.sky:draw()
        self.spaceship:draw()

        self:drawInfo()
    end
end

function Game:update(dt)
    if self.state == GameState.NOT_STARTED then
        if love.keyboard.isDown('l') then
            self.state = GameState.LEGEND
        end
    end

    if love.keyboard.isDown('return') and (self.state == GameState.NOT_STARTED or self.state == GameState.FINISHED) then
        self:init()
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
            -- TODO: apply force to spaceship
            self.spaceship:applyForce(Vector:create(0, -0.005))
        end

        if love.keyboard.isDown('left') then
            -- TODO: rotate spaceship left
            self.spaceship:rotate(-0.05)
        elseif love.keyboard.isDown('right') then
            -- TODO: rotate spaceship right
            self.spaceship:rotate(0.05)
        end

        self.spaceship:applyForce(Vector:create(0, 0.001))
    end

    self.sky:update(dt)
    self.spaceship:update(dt)
end

function Game:drawInfo()
    -- TODO: draw remained fuel, and player score

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
