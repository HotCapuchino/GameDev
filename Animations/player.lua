Player = {}
Player.__index = Player

function Player:create(x, y)
    local player = {}
    setmetatable(player, Player)

    player.x = x 
    player.y = y

    player.tx = x
    player.ty = y

    player.duration = {
        move = 0.5,
        idle = 1
    }
    player.currentTime = 0

    player.state = "idle"

    return player
end

function Player:setTarget(x, y)
    self.tx = x
    self.ty = y
end

function Player:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)

    local sprite = 1

    if self.state == "move" then
        sprite = math.floor(self.currentTime / self.duration[move] * #pl_move.textures) + 1 -- +1, потому что 1 текстура - состояние покоя 
        love.graphics.draw(pl_tileset, pl_move.textures[sprite], -12, -12, 0, 0.5, 0.5)
    else 
        sprite = math.floor(self.currentTime / self.duration[idle] * #pl_idle.textures) + 1
        love.graphics.draw(pl_tileset, pl_idle.textures[sprite], -12, -12, 0, 0.5, 0.5)
    end


    love.graphics.pop()
end

function Player:update(dt)
    self.currentTime = self.currentTime + dt

    if self.state == 'move' then
        if self.currentTime >= self.duration[move] then
            self.currentTime = self.currentTime - self.duration[move]
        end
    else 
        if self.currentTime >= self.duration[idle] then
            self.currentTime = self.currentTime - self.duration[idle]
        end
    end

    self.state = "idle"

    if self.x ~= self.tx then
        if self.x > self.tx then
            self.x = self.x - 1
        else
            self.x = self.x + 1
        end

        self.state = "move"
    end

    if self.y ~= self.ty then
        if self.y > self.ty then
            self.y = self.y - 1
        else
            self.y = self.y + 1
        end

        self.state = "move"
    end
end