Collision = {}
Collision.__index = Collision

function Collision:create()
    local collision = {}
    setmetatable(collision, Collision)
    return collision
end

function Collision:onSegment(p1, p2, r)
    return (p2.x <= math.max(p1.x, r.x)) and (p2.x >= math.min(p1.x, r.x)) and (p2.y <= math.max(p1.y, r.y)) and
        (p2.y >= math.min(p1.y, r.y))
end

function Collision:calculateDirection(p1, p2, r)
    local val = ((p2.y - p1.y) * (r.x - p2.x)) - ((p2.x - p1.x) * (r.y - p2.y))

    if val > 0 then
        return 1
    elseif val < 0 then
        return 2
    else
        return 0
    end
end

function Collision:hasIntersection(l1p1, l1p2, l2p1, l2p2)
    local dir1 = self:calculateDirection(l1p1, l1p2, l2p1)
    local dir2 = self:calculateDirection(l1p1, l1p2, l2p2)
    local dir3 = self:calculateDirection(l2p1, l2p2, l1p1)
    local dir4 = self:calculateDirection(l2p1, l2p2, l1p2)

    if dir1 ~= dir2 and dir3 ~= dir4 then
        return true
    end

    if dir1 == 0 and self:onSegment(l1p1, l1p2, l2p1) then
        return true
    end

    if dir2 == 0 and self:onSegment(l1p1, l1p2, l2p2) then
        return true
    end

    if dir3 == 0 and self:onSegment(l2p1, l2p2, l1p1) then
        return true
    end

    if dir4 == 0 and self:onSegment(l2p1, l2p2, l1p2) then
        return true
    end

    return false
end
