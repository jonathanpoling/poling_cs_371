local Shape = require("shape");

local Blue = Shape:new(); -- Blues inherit from the Shape superclass

function Blue:spawn(x, y) -- override Shape's spawn method
    self.tag = "Blue" -- Override: specify tag
    self.shape = display.newCircle(x, y, 30) -- radius is purly my best choice
    self.shape.pp = self
    self.shape.tag = self.tag
    self.shape:setFillColor(0,0,1) -- override: make it blue instead
    physics.addBody(self.shape, "dynamic", { bounce = 0.3, radius = 30 })
end

function Blue:touch() -- override Shape's touch method
    local function onTouch(event)
        if event.phase == "began" then
            self.shape.strokeWidth = 4 -- Override: add an outline
            self.shape:setStrokeColor(1,1,1) -- Override: taps will set the outline color to white
            event.target.markX = event.target.x
            event.target.markY = event.target.y
            event.target.isFocus = true;
        elseif event.phase == "moved" and event.target.isFocus == true then
            local x = (event.x - event.xStart) + event.target.markX;
            local y = (event.y - event.yStart) + event.target.markY;
            event.target.x, event.target.y = x, y;
        elseif event.phase == "ended" then
            --event.target:setFillColor( <RANDOM> );
            event.target.isFocus = false;
        end
    end
self.shape:addEventListener ("touch", onTouch);
end

return Blue