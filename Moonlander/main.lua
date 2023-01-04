require("game")

function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    MOONLANDER_GAME = Game:create()
end

function love.update(dt)
    MOONLANDER_GAME:update(dt)
end

function love.draw()
    MOONLANDER_GAME:draw()
end
