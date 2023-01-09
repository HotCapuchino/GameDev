require("vector")
require("vehicle")
require("path")
require("complex_path")

function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    -- path = Path:create(Vector:create(200, 200), Vector:create(600, 400))

    vehicle1 = Vehicle:create(400, 400)
    vehicle2 = Vehicle:create(400, 400)
    vehicle2.maxForce = 0.7
    vehicle2.maxSpeed = 2

    points = {Vector:create(100, 200), Vector:create(300, 400), Vector:create(500, 200), Vector:create(700, 100)}

    complexPath = ComplexPath:create(points)
end

function love.update(dt)
    -- vehicle1:follow(path)
    -- vehicle1:borders(path)
    -- vehicle2:follow(path)
    -- vehicle2:borders(path)

    vehicle1:followComplex(complexPath)
    vehicle1:complexBorders(complexPath)
    vehicle2:followComplex(complexPath)
    vehicle2:complexBorders(complexPath)
    
    vehicle1:update()
    vehicle2:update()
end

function love.draw()
    -- path:draw()
    complexPath:draw()
    vehicle1:draw()
    vehicle2:draw()

end

