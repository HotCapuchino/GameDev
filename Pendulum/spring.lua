Spring = {}
Spring.__index = Spring 

function Spring:create(anchor, length)
    local spring = {}
    setmetatable(spring, Spring)
    spring.anchor = anchor
    spring.length = length
    spring.k = 0.1

    return spring
end

function Spring:apply(mover)
    local diff = mover.position - self.anchor
    local d = diff:mag()
    local stretch = d - self.length
    local dir = diff:norm()
    dir:mul(-1 * self.k * stretch)
    mover:applyForce(dir)
end

function Spring:draw()
    love.graphics.rectangle("fill", self.anchor.x - 5, self.anchor.y - 5, 10, 10)
end

function Spring:drawLine(mover)
    love.graphics.line(mover.position.x, mover.position.y, self.anchor.x, self.anchor.y)
end

function Spring:constraint(mover, minlen, maxlen)
    local dir = mover.position - self.anchor
    local d = dir:mag()

    if d < minlen then 
        dir = dir:norm()
        dir:mul(minlen)
        mover.position = self.anchor + dir
        mover.velocity:mul(0)
    elseif d > maxlen then
        dir = dir:norm()
        dir:mul(maxlen)
        mover.position = self.anchor + dir
        mover.velocity:mul(0)
    end
end