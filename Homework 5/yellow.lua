local Red = require("red");

local Yellow = Red:new(); -- Yellows inherit from Red

function Yellow:spawn(x, y) -- Override Red spawn
    self.shape = display.newCircle(x, y, 30) -- radius is purly my best choice
    self.shape.parent = self
    self.shape.tag = self.tag
    self.shape:setFillColor(1,1,0) -- Override: make circle yellow
    physics.addBody(self.shape, "dynamic", { bounce = 0.3, radius = 30 })
end

return Yellow