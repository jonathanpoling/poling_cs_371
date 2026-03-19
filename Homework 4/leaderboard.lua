local composer = require( "composer" )
local json = require("json")
 
local scene = composer.newScene()
lbTaps = -1 -- start at -1 because the lb button click allso counts as a begin tap event in this scene somehow
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
 
 
 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
 
end
 

function doubleTap(event) -- function to allow double tap to change scenes
    if event.phase == "began" then
        lbTaps = lbTaps + 1
        print(lbTaps)
        if lbTaps == 2 then
            Runtime:removeEventListener("touch", doubleTap)
            composer.removeScene("leaderboard")
            composer.gotoScene("titleAndSettings", {params = {
            highScores}})
        end
    end
end
 
-- show()
function scene:show( event )
    -- require a somewhat quick "double tap", not just two taps
    timer.performWithDelay(1000, function()
        if lbTaps > 0 then
            lbTaps = lbTaps - 1
        end
    end, 0)
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        Runtime:addEventListener("touch", doubleTap)
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        -- create leaderboard label:
        lbText = display.newText({
            text = "High Scores:",
            x = display.contentCenterX,
            y = 200,
            fontSize = 60
            })
        sceneGroup:insert(lbText)
        -- open and read high scores into table
        local path = system.pathForFile("highscores.json", system.DocumentsDirectory)
        local file = io.open(path, "r") 
        jsonScores = file:read("*a") -- read entire file into one json string
        highScores = json.decode(jsonScores) -- decode into lua table
        for i,v in ipairs(highScores) do
            local scoreText = display.newText({
            text = tostring(v),
            x = display.contentCenterX,
            y = 300 + (100 * i),
            fontSize = 40
            })
            sceneGroup:insert(scoreText)
        end
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
        for i,v in ipairs(sceneGroup) do
            display.remove(v)
        end
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