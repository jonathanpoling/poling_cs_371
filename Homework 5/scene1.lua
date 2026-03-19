local composer = require( "composer" )
local widget = require( "widget" )

local scene = composer.newScene()

-- Global Scene data; will be updated by events and is passed to the next scene
shapeSpawnDelay = 200 -- 200 - 1000 ms; updated by onSliderUpdate

 
 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    -- Create label for spawn delay slider
    spawnIntervalSliderLabel = display.newText({
        text = "Shape Spawn Interval: "..tostring(shapeSpawnDelay).." ms",
        x = display.contentCenterX,
        y = display.contentCenterY - 270
    })
 
    -- Create touch listener for the start button that switches to scene 2
    function onStartButtonPress(event)
        if event.phase == "began" then
            composer.gotoScene("scene2", {
                effect = "crossFade",
                time = 800,
                -- pass data to next scene
                params = {shapeSpawnDelay}
            })
        end
    end

    -- Create event listener for the speed slider
    function onSliderUpdate(event)
        if event.phase == "moved" then
            -- Update the shape spawn delay 
            -- (manip event value so range goes from 0-100 -> 200-1000)
            shapeSpawnDelay = (spawnIntervalSlider.value * 8 ) + 200
            -- update label
            spawnIntervalSliderLabel.text = "Shape Spawn Interval: "..tostring(shapeSpawnDelay).." ms"
        end
    end

    -- Create start button
    startButton = display.newRect(display.contentCenterX, display.contentCenterY, 250, 100)
    startButtonText = display.newText({
        text = "Start",
        x = display.contentCenterX,
        y = display.contentCenterY,
        fontSize = 45
    })
    startButtonText:setTextColor(0,0,0)

    -- Create falling speed slider
    spawnIntervalSlider = widget.newSlider{
        x = display.contentCenterX,
        y = display.contentCenterY - 300,
        width = 200,
        value = 0
    }

    -- Assign touch listener function to start button display object
    startButton:addEventListener("touch", onStartButtonPress)

    -- Assign slider update function to the slider object
    spawnIntervalSlider:addEventListener("touch", onSliderUpdate)

    -- Add newly created objects to the scene group so that they can be hidden when changing scene
    sceneGroup:insert(startButton)
    sceneGroup:insert(startButtonText)
    sceneGroup:insert(spawnIntervalSlider)
    sceneGroup:insert(spawnIntervalSliderLabel)
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        print("scene 1")
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
 
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
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