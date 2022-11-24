Wave = {}
Wave.__index = Wave

function Wave:create(x_start, x_end, step, y_offset, line_color, line_fill, amp, angVel, angle)
    local wave = {}
    setmetatable(wave, Wave)
    wave.x_start = x_start
    wave.x_end = x_end
    wave.step = step
    wave.y_offset = y_offset

    wave.line_color = line_color
    wave.line_fill = line_fill
    wave.amp = amp
    wave.angVel = angVel
    wave.angle = angle

    return wave
end

function Wave:draw()
    local height = love.graphics.getHeight()

    for x=self.x_start, self.x_end, self.step do
        y = self.amp * math.sin((self.angle + x / 240) * 10) + self.y_offset
        love.graphics.setColor(unpack(self.line_color))
        love.graphics.circle('line', x, y + height / 2, 10)

        love.graphics.setColor(unpack(self.line_fill))
        love.graphics.circle('fill', x, y + height / 2, 10)
    end
    
    self.angle = self.angle + self.angVel
end
