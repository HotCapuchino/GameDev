require("game")

function love.load()
    BIRD_GAME = Game:create()
end

function love.update()
    BIRD_GAME:update()
end

function love.draw()
    BIRD_GAME:draw()
end

function love.keypressed(key, _, isrepeat)
    if not isrepeat then
        BIRD_GAME:interraction(key)
    end
end
