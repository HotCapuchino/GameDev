World = {}
World.__index = World

function World:create(map)
    local world = {}
    setmetatable(world, World)

    world.map = map
    world.height = #map
    world.width = #map[1]
    
    return world
end

function World:draw()
    for i = 1, self.height do
        for j = 1, self.width do
            local cell = self.map[i][j]
            local texture = ENV.textures[cell]

            love.graphics.draw(ENV.tileset, texture, 16 * (j - 1), 16 * (i - 1))
        end
    end
end

function World:globalToLocal(x, y)
    return math.floor(x / 16), math.floor(y / 16)
end

function World:localToGlobal(x, y)
    return (x * 16) + 8, (y * 16) + 8
end