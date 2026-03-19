local Shape = {}; -- initialize this Shape as an empty table
local physics = require( "physics" )
local removeSFX = audio.loadSound("remove.wav")

function Shape:new(o) -- serves as constructor of new Shape instance
    -- specify metatable as self to allow object behavior
    o = o or {};
    setmetatable(o, self)
    self.__index = self;
    return o;
end

function Shape:spawn(x, y) -- spawn a circle (default); set this shape's tag, color (default red) and physics body type
    self.shape = display.newCircle(x, y, 30) -- radius is purly my best choice
    self.shape.pp = self -- assign parent (self in this case since Shape is a superclass)
    self.shape.tag = self.tag
    self.shape:setFillColor(1,0,0)
    physics.addBody(self.shape, "dynamic", { bounce = 0.3, radius = 30 })

end

function Shape:touch() -- drag and drop functionality by Dr. C, with some modifications for the purpose of this implementation
    local function onTouch(event)
        self.shape:setLinearVelocity(0,0) -- keep object still
        if event.phase == "began" then
            event.target.markX = event.target.x
            event.target.markY = event.target.y
            event.target.isFocus = true;
        elseif event.phase == "moved" and event.target.isFocus == true then
            local x = (event.x - event.xStart) + event.target.markX;
            local y = (event.y - event.yStart) + event.target.markY;
            event.target.x, event.target.y = x, y;
        elseif event.phase == "ended" then
            event.target.isFocus = false;
        end
    end
self.shape:addEventListener ("touch", onTouch);
end

function Shape:sound()
    audio.play(removeSFX)
end

function Shape:collide()
    local function onCollision(event)
        -- check if this shape collided with a shape of the same class 
        if (event.other.tag == self.tag) and (event.phase == "began") then
            self:sound()
            score = score + 500 -- this sucks bc it relies on a global score but its the only way i could think to do this
            physics.removeBody(self.shape)
            self.shape:removeSelf()
        end
    end
    self.shape.collision = onCollision -- register ball collision
    self.shape:addEventListener("collision", onCollision)
end

function Shape:delete()
    display.remove(self.shape)
end



return Shape