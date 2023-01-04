Spaceship = {}
Spaceship.__index = Spaceship

function Spaceship:create(position)
    local spaceship = {}
    setmetatable(spaceship, Spaceship)

    spaceship.position = position
    spaceship.initialPosition = position

    spaceship.velocity = Vector:create(0.1, 0)
    spaceship.acceleration = Vector:create(0, 0)

    spaceship.angleVelocity = 0
    spaceship.angle = 0

    spaceship.destroyed = false
    spaceship.active = false

    spaceship.points = {}

    return spaceship
end

function Spaceship:init()
    -- TODO: init spaceship
    self.position = self.initialPosition

    self.velocity = Vector:create(0.1, 0)
    self.acceleration = Vector:create(0, 0)

    self.angleVelocity = 0
    self.angle = 0

    self.destroyed = false
    self.active = false
end

function Spaceship:draw()
    -- TODO: draw spaceship
    -- TODO: correctly translate spaceship
    love.graphics.push()
    love.graphics.translate(self.position.x + 10, self.position.y + 10)
    love.graphics.rotate(self.angle)

    love.graphics.rectangle('line', -10, -10, 15, 15)

    love.graphics.pop()
end

function Spaceship:update(dt)
    -- TODO: update spaceship position
    self.velocity:add(self.acceleration)
    self.position:add(self.velocity)
    self.angle = self.angle + self.angleVelocity
    self.acceleration:mul(0)
end

function Spaceship:rotate(dangle)
    -- TODO: rotate spaceship
    self.angle = self.angle + dangle
end

function Spaceship:applyForce(force)
    -- TODO: add force vector
    self.acceleration:add(force)
end

function Spaceship:checkForCollision(terrain)
    -- TODO: check for collision with terrain
end
