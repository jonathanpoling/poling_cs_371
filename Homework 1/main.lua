-- Make a black background that, when touched, spawns a ball; does not get touched if a
-- ball is tapped instead
local background = display.newRect(160,240,320,800)
background:setFillColor(0,0,0)
HeightOffset = 130 -- used to more accurately refer to content area height boundaries,
--                    since the direct value via display.contenthHeight doesnt look quite right

VerticalBalls = 0 -- global counters for each ball type
HorizontalBalls = 0
DiagonalBalls = 0

-- make a gui to display my last name and the global counters
GUI = display.newGroup()
GUI.x = 0
GUI.y = 0
display.newText({text = "Poling"; fontSize = 12; x = 40; y = -50; parent = GUI})
V = display.newText({text = "V: 0"; fontSize = 12; x = 40; y = -20; parent = GUI})
H = display.newText({text = "H: 0"; fontSize = 12; x = 140; y = -20; parent = GUI})
D = display.newText({text = "D: 0"; fontSize = 12; x = 240; y = -20; parent = GUI})

--make an update function to reflect the amount change in the gui when a new ball is spawned
function updateBallAmounts()
    V.text = "V: " .. tostring(VerticalBalls)
    H.text = "H: " .. tostring(HorizontalBalls)
    D.text = "D: " .. tostring(DiagonalBalls)
end

-- Make a table to store balls and their types, define spawning behavior
BallGroupTable = {}
BallTypes = {"Vertical","Horizontal","Diagonal"}
function spawnBall(event)
    if (event.phase == "began") then
        -- create the group that will contain the ball and its label;
        -- decide its radius and start coordinates
        local ballGroup = display.newGroup()
        ballGroup.radius = math.random(30,60)
        local x = event.x
        local y = event.y
        -- check to see if the ball was spawned "out of bounds";
        -- if it was, correct the coordinates so it doesnt get stuck
        if (x >= display.contentWidth - ballGroup.radius ) then
            x = 319 - ballGroup.radius
        elseif (x - ballGroup.radius <= 0) then
            x = 1 + ballGroup.radius
        end
        -- now checking if out of y bounds
        if((y - ballGroup.radius) <= 0 - HeightOffset) then
            y = 1 + ballGroup.radius - HeightOffset
        elseif (y + ballGroup.radius >= display.contentHeight + HeightOffset) then
            y = display.contentHeight + HeightOffset - ballGroup.radius
        end

        -- actually set the group's location now that it has been checked
        ballGroup.x = x
        ballGroup.y = y
        ballGroup.xModifier = 1 -- these will be used by the update function to
        ballGroup.yModifier = 1 -- change the balls' movement direction
        ballGroup.isRotating = false -- diagonals should not be rotating at start;
        -- ^^ this value is only changed for diagonal balls anyway

        -- draw the ball on screen
        local ball = display.newCircle(0, 0, ballGroup.radius)
        ball:setFillColor(math.random(),math.random(),math.random())

        -- decide the ball's type
        ball.type = BallTypes[math.random(3)]

        -- based on the chosen type: change movement modifier, add listener, update amount,
        -- set initial state, and apply image label, then add label and ball to group
        if(ball.type == "Vertical") then
            ballGroup.xModifier = 0
            ball:addEventListener("touch", doubleBallSize)
            VerticalBalls = VerticalBalls + 1
            ball.sizeDoubled = false -- first touch should enlarge
            local img = display.newImage(ballGroup,"Vertical.png")
            img.xScale = 0.1
            img.yScale = 0.1
            ballGroup:insert(ball)
            img:toFront()
        end
        if(ball.type == "Horizontal") then
            ballGroup.yModifier = 0
            ball:addEventListener("touch", fadeBall)
            HorizontalBalls = HorizontalBalls + 1
            local img = display.newImage(ballGroup,"Horizontal.png")
            img.xScale = 0.1
            img.yScale = 0.1
            ballGroup.isFading = false
            ballGroup:insert(ball)
            img:toFront()
        end
        if(ball.type == "Diagonal") then
            DiagonalBalls = DiagonalBalls + 1
            ball:addEventListener("touch", rotateBall)
            local img = display.newImage(ballGroup,"Diagonal.png")
            img.xScale = 0.1
            img.yScale = 0.1
            ballGroup:insert(ball)
            img:toFront()
        end
        -- finally, insert the finished ball structure (group) into the grand table
        table.insert(BallGroupTable, ballGroup)
    end
    -- update + bring the GUI to the front so the balls dont go over it
    updateBallAmounts()
    GUI:toFront()
end

-- Define function to make horizontal balls fade out when touched
function fadeBall(event)
    if(event.phase == "began" and event.target.parent.isFading == false) then
        event.target.parent.isFading = true
        transition.fadeOut(event.target.parent, {time = 2000, onComplete = deleteBall})
        HorizontalBalls = HorizontalBalls - 1
    end
    return true;
end

-- function to double a vertical ball's size (or half it) when it is touched
function doubleBallSize(event)
    if(event.phase == "began") then
        if (event.target.sizeDoubled == false) then
            transition.scaleTo(event.target.parent, {
                xScale = 2; yScale = 2; transition = easing.inOutQuart; time = 2000})
            event.target.sizeDoubled = true
            event.target.parent.radius = event.target.parent.radius * 2
        else
            transition.scaleTo(event.target.parent, {
                xScale = 1; yScale = 1; transition = easing.inOutQuart; time = 2000})
                event.target.sizeDoubled = false
                event.target.parent.radius = event.target.parent.radius * 0.5
        end
    end
    return true
end

-- function to toggle rotation on diagonal balls when touched
function rotateBall(event)
    if(event.phase == "began") then
        if (event.target.parent.isRotating == false) then
            event.target.parent.isRotating = true
        else
            event.target.parent.isRotating = false
        end
    end
    return true
end

-- general function to delete balls (currently only used by fadeBall)
function deleteBall(event)
    if(event.phase == "began") then
        table.remove(BallGroupTable, table.indexOf(event.target))
        display.remove(event.target)
    end
    return true
end

-- function to update ball positions, and rotation if diagonal
function update()
    updateBallAmounts() 
    if (#BallGroupTable ~= 0) then
        for i,v in ipairs(BallGroupTable) do
            local ball = BallGroupTable[i] -- ball = the whole GROUP (ball + label)
            -- did ball reach left/right bound? if so invert x direction
            if((ball.x + ball.radius) > display.contentWidth or (ball.x - ball.radius) < 0) then
                ball.xModifier = ball.xModifier * -1
            end
            -- did ball reach upper/lower bound? if so invert y direction
            if((ball.y + ball.radius) > (display.contentHeight + HeightOffset)  or (ball.y - ball.radius) < (0 - HeightOffset)) then
                ball.yModifier = ball.yModifier * -1
            end
            ball.x = ball.x + (1*ball.xModifier) -- horizontal movement
            ball.y = ball.y + (1*ball.yModifier) -- vertical movement
            if(ball.isRotating == true) then
                ball:rotate(3)
            end
        end
    end
end

-- add background tap listener and start timer for updater
timer.performWithDelay(20, update, 0)
background:addEventListener("touch", spawnBall)
