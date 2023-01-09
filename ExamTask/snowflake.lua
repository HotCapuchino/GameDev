Snowflake = {}
Snowflake.__index = Snowflake

function Snowflake:create(position)
    local snowflake = {}
    setmetatable(snowflake, Snowflake)

    snowflake.position = position
    snowflake.velocity = nil
    snowflake.acceleration = nil
    snowflake.texture = love.graphics.newImage("assets/snowflake.png")
    snowflake.scale = 0.1

    return snowflake
end

function Snowflake:update()
    self.velocity:add(self.acceleration)
    self.position:add(self.velocity)
    self.acceleration:mag(0)
end

function Snowflake:draw()
    love.graphics.draw(self.texture, self.position.x - self.scale * self.texture:getWidth() / 2,
        self.position.y - self.scale * self.texture:getHeight() / 2, self.scale, self.scale)
end

function Snowflake:isDead()
    return (
        (self.position.x < -self.texture:getWidth() or self.position.x > width) and
            (self.position.y > 0 or self.position.y < height)) or
        self.position.y > height + self.texture:getHeight()
end

function Snowflake:applyForce(force, dt)
    if not self.velocity then
        self.velocity = Vector:create(dt * math.random(), 20 * dt)
    end

    if not self.acceleration then
        self.acceleration = Vector:create(dt * math.random(-0.5, 0.5), 2 * dt)
    end

    if force and self.position.y > 0 then
        self.acceleration:add(force)
    end
end
