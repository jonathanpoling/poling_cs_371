local Blue = require("blue");

local Green = Blue:new(); -- Greens inherit from Blue

function Green:spawn(x, y) -- Override Blue spawn
    self.shape = display.newCircle(x, y, 30) -- radius is purly my best choice
    self.shape.parent = self
    self.shape.tag = self.tag
    self.shape:setFillColor(0,1,0) -- Override: make circle green
    physics.addBody(self.shape, "dynamic", { bounce = 0.3, radius = 30 })
end

return Green