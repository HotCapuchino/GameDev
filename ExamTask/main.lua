require('vector')
require('snowflake')
require('snowfall')

function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    snowfall = Snowfall:create(2000)
    background = love.graphics.newImage("assets/southpark.png")
    cartman_song = love.audio.newSource("assets/cartman_song.mp4", 'stream')
    love.graphics.setFont(love.graphics.newFont(16))
end

function love.update(dt)
    if not cartman_song:isPlaying() then
        cartman_song:play()
    end
    snowfall:update(dt)
end

function love.draw()
    love.graphics.draw(background, 0, 0)
    snowfall:draw()

    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(0, 0, 0, 1)

    love.graphics.print("Press +/- to increase/decrease snowflakes amount", 30, 30)
    love.graphics.print("Current amount of snowlakes: " .. snowfall.amount, 30, 60)

    love.graphics.print("To enable/disable wind use W", width - 350, 30)
    love.graphics.print("Use left/right arrow key to change wind direction", width - 400, 60)

    if snowfall.windDirection then
        love.graphics.print("Current wind direction: " .. snowfall.windDirection, width - 350, 90)
    end

    love.graphics.setColor(r, g, b, a)
end

function love.keypressed(key, _, isrepeat)
    if not isrepeat then
        if key == 'w' then
            snowfall:toggleWind()
        elseif key == 'left' and snowfall.windDirection then
            snowfall:changeWindDirection(WindDirection.LEFT)
        elseif key == 'right' and snowfall.windDirection then
            snowfall:changeWindDirection(WindDirection.RIGHT)
        end
    end

    if key == '+' or key == 'kp+' then
        snowfall:changeAmount(AmountChanger.INCREASE)
    elseif key == '-' or key == 'kp-' then
        snowfall:changeAmount(AmountChanger.DECREASE)
    end
end
