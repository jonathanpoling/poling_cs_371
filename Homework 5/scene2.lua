-- Include required libraries/class defns
local composer = require( "composer" )
local physics = require( "physics" )
 
local Red = require("red")
local Blue = require("blue")
local Yellow = require("yellow")
local Green = require("green")

local scene = composer.newScene()

-- Game data
ballTable = {}
score = 0
gameOver  = false
shapeSpawnDelay = 200 -- default value; real value passed in from previous scene

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
    local sceneGroup = self.view
    -- start physics before anything else
    physics.start()
    -- make group for walls for easy moving
    wallGroup = display.newGroup()

    -- create score HUD
        scoreHUD = display.newText({
            text = "Score: "..tostring(score),
            x = display.contentCenterX,
            y = 0,
            fontSize = 30
        })
        sceneGroup:insert(scoreHUD)

    -- Make walls
    local bottom = display.newRect(0, display.contentHeight-20, display.contentWidth, 20)
    bottom.anchorX = 0; bottom.anchorY = 0

    local left = display.newRect(0, 0, 20, display.contentHeight)
    left.anchorX = 0; left.anchorY = 0

    local right = display.newRect(display.contentWidth -20, 0, 20, display.contentHeight)
    right.anchorX = 0; right.anchorY = 0

    -- give walls physics property
    physics.addBody(left, "static")
    physics.addBody(right, "static")
    physics.addBody(bottom, "static")

    -- put walls into their own group
    wallGroup:insert(left)
    wallGroup:insert(right)
    wallGroup:insert(bottom)

    sceneGroup:insert(wallGroup)
    -- move this group off screen
    wallGroup.x = -2000
    wallGroup.y = 2000

    -- Dr. C's fall function, with a few additions appropriate for this use of it
    function fall()
        -- update score hud
        scoreHUD.text = "Score: "..tostring(score)
        if gameOver then
            return -- don't do anything if the game is over
        end
        rand = math.random()
        local xPos = math.random (30,600);
        local yPos = -50
        if (rand <= 0.25) then
            local r = Red:new() -- create new Red Shape
            r.tag = "red"
            r:spawn(xPos, yPos) -- spawn at chosen coordinates
            r:touch() -- add touch listener
            r:collide() -- add collision listener
            table.insert(ballTable, r)
            sceneGroup:insert(r.shape)

        elseif (rand > 0.25 and rand <= 0.50) then
            local b = Blue:new() -- create new Blue Shape
            b.tag = "blue"
            b:spawn(xPos, yPos) -- spawn at chosen coordinates
            b:touch() -- add touch listener
            b:collide() -- add collision listener
            table.insert(ballTable, b)
            sceneGroup:insert(b.shape)

        elseif (rand > 0.50 and rand <= 0.75) then
            local y = Yellow:new() -- create new Yellow Shape
            y.tag = "yellow"
            y:spawn(xPos, yPos) -- spawn at chosen coordinates
            y:touch() -- add touch listener
            y:collide() -- add collision listener
            table.insert(ballTable, y)
            sceneGroup:insert(y.shape)

        elseif (rand > 0.75) then
            local g = Green:new() -- create new Green Shape
            g.tag = "green"
            g:spawn(xPos, yPos) -- spawn at chosen coordinates
            g:touch() -- add touch listener
            g:collide() -- add collision listener
            table.insert(ballTable, g)
            sceneGroup:insert(g.shape)

        end
    end -- end of fall function

end

 
-- show()
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        score = 0 -- reset score and update the HUD
        scoreHUD.text = "Score: "..tostring(score)

        -- get shape spawn delay from scene 1
        shapeSpawnDelay = event.params[1]

        -- move walls into view 
        wallGroup.x = 0
        wallGroup.y = 0
 
    elseif ( phase == "did" ) then
        -- get spawner running again
        gameOver = false
        dropShape = timer.performWithDelay(shapeSpawnDelay, fall, 0)
        
        -- Create touch listener for the start button that switches back to scene 1
        function onBackButtonPress(event)
            if event.phase == "began" then
                gameOver = true
                composer.gotoScene("scene1", {
                    effect = "crossFade",
                    time = 800,
                    -- pass data to next scene
                    params = {shapeSpawnDelay}
                })
            end
        end

        -- Create start button
        backButton = display.newRect(display.contentCenterX, 40, 250, 50)
        backButtonText = display.newText({
            text = "Back",
            x = display.contentCenterX,
            y = 40,
            fontSize = 45
        })
        backButtonText:setTextColor(0,0,0)

        backButton:addEventListener("touch", onBackButtonPress)

        sceneGroup:insert(backButton)
        sceneGroup:insert(backButtonText)
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)

        -- Stop spawning balls
        timer.cancel(dropShape)

        -- Remove all balls from display
        for i = #ballTable, 1, -1 do
            ballTable[i]:delete()
            table.remove(ballTable, i)
        end

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene