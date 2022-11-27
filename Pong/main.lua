require("game")

function love.load()
    PONG_GAME = Game:create()
end

function love.update()
    PONG_GAME:update()
end

function love.draw()
    PONG_GAME:draw()
end
