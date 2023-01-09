require('world')
require('player')

function loadTextures()
    ENV = {}
    ENV.tileset = love.graphics.newImage("assets/RogueEnvironment16x16.png")

    local quads = {
        {0,  5*16,  0*16}, -- floor v1
        {1,  6*16,  0*16}, -- floor v2
        {2,  7*16,  0*16}, -- floor v3
        {3,  0*16,  0*16}, -- upper left corner
        {4,  3*16,  0*16}, -- upper right corner
        {5,  0*16,  3*16}, -- lower left corner
        {6,  3*16,  3*16}, -- lower right corner
        {7,  2*16,  0*16}, -- horizontal
        {8,  0*16,  2*16}, -- vertical
        {9,  1*16,  2*16}, -- up
        {10, 2*16,  3*16}, -- down
        {11, 2*16,  1*16}, -- left
        {12, 1*16,  1*16}, -- right
        {13, 1*16,  0*16}, -- down cross
        {14, 3*16, 14*16}, -- spikes
    }
    ENV.textures = {}
    for i = 1, #quads do
        local q = quads[i]
        ENV.textures[q[1]] = love.graphics.newQuad(q[2], q[3], 16, 16, ENV.tileset:getDimensions())
    end

    pl_tileset = love.graphics.newImage("assets/RoguePlayer_48x48.png")
    
    pl_move = {}
    pl_move.textures = {}
    for i = 1, 6 do
        pl_move.textures[i] = love.graphics.newQuad((i - 1) * 48, 48 * 2, 48, 48, pl_tileset:getDimensions())
    end

    pl_idle = {}
    pl_idle.textures = {}
    for i = 1, 8 do
        pl_idle.textures[i] = love.graphics.newQuad((i - 1) * 48, 0, 48, 48, pl_tileset:getDimensions())
    end

end

function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    loadTextures()

    local map = {
        { 3,  7,  7, 13,  7,  7,  7,  4},
        { 8,  0,  0,  8,  0,  0,  0,  8},
        { 8,  0,  0,  8,  0,  0,  0,  8},
        { 8,  0,  0,  8, 14,  0,  0,  8},
        { 8,  0,  0, 10,  0,  8,  0,  8},
        { 8,  0,  0,  0,  0,  8,  0,  8},
        { 8,  0,  0,  0,  0,  0,  0,  8},
        { 5,  7,  7,  7,  7,  7,  7,  6}
    }

    world = World:create(map)
    player = Player:create(24, 24)
    scaleX = width / (world.width * 16)
    scaleY = height / (world.height * 16)
end

function love.draw()
    love.graphics.scale(scaleX, scaleY)
    world:draw()
    player:draw()
end

function love.update(dt)
    player:update(dt)
end

function love.mousepressed(x, y, button)
    local gx, gy = world:localToGlobal(world:globalToLocal(x / scaleX, y / scaleY))
    
    if button == 1 then
        player:setTarget(gx, gy)
    end
end

