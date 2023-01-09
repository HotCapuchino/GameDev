Snowfall = {}
Snowfall.__index = Snowfall

AmountChanger = {
    INCREASE = 1,
    DECREASE = 2
}

WindDirection = {
    LEFT = "left",
    RIGHT = "right"
}

function Snowfall:create(amount)
    local snowfall = {}
    setmetatable(snowfall, Snowfall)

    snowfall.minAmount = 500
    snowfall.maxAmount = 2000

    if amount < snowfall.minAmount then
        amount = snowfall.minAmount
    elseif amount > snowfall.maxAmount then
        amount = snowfall.maxAmount
    end

    snowfall.amount = amount
    snowfall.windDirection = nil
    snowfall.snowflakes = {}

    snowfall:createSnowflakes()

    return snowfall
end

function Snowfall:createSnowflakes()
    for i = 1, self.amount do
        self.snowflakes[i] = self:createSnowflake()
    end
end

function Snowfall:createSnowflake()
    math.randomseed(os.clock())

    local startX = 20
    local endX = width - 20

    if self.windDirection == WindDirection.LEFT then
        endX = width * 1.5
    elseif self.windDirection == WindDirection.RIGHT then
        startX = -width * 0.5
    end

    local x = math.random(startX, endX)
    local y = math.random(-height * 2, -20)
    return Snowflake:create(Vector:create(x, y))
end

function Snowfall:update(dt)
    for i = 1, #self.snowflakes do
        local snowflake = self.snowflakes[i]

        local force = nil

        if self.windDirection == WindDirection.LEFT then
            force = Vector:create(-0.5 * dt, 0)
        elseif self.windDirection == WindDirection.RIGHT then
            force = Vector:create(0.5 * dt, 0)
        end

        snowflake:applyForce(force, dt)
        snowflake:update(dt)

        if snowflake:isDead() then
            self.snowflakes[i] = self:createSnowflake()
        end
    end
end

function Snowfall:draw()
    for _, snowflake in ipairs(self.snowflakes) do
        snowflake:draw()
    end
end

function Snowfall:changeAmount(amount)
    local lastIndex = #self.snowflakes

    if amount == AmountChanger.DECREASE and self.amount > self.minAmount then
        self.amount = self.amount - 1
        table.remove(self.snowflakes)
    elseif amount == AmountChanger.INCREASE and self.amount < self.maxAmount then
        self.amount = self.amount + 1
        self.snowflakes[lastIndex] = self:createSnowflake()
    end
end

function Snowfall:toggleWind()
    if self.windDirection then
        self.windDirection = nil
    else
        self.windDirection = WindDirection.LEFT
    end
end

function Snowfall:changeWindDirection(direction)
    if self.windDirection then
        self.windDirection = direction
    end
end
