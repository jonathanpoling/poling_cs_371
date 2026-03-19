-- declare required features
local composer = require( "composer" )
local widget = require("widget")
local json = require("json")
-- initialize some data w/ default vals
level = 1
ballSpeed = 1
highScores = {1000, 0, 0, 0, 0} -- initial high scores



-- scene creation
local scene = composer.newScene()
 
-- create title and name, set initial position
nameText = display.newText({
    text = "  Mobile Breakout\nby Jonathan Poling",
    x = display.contentCenterX,
    y = display.contentCenterY - 300,
    fontSize = 40
})



-- create radio buttons for level selection, set initial pos;
-- also make listener
local radioGroup = display.newGroup() -- group for radio button set

-- radio button "on press" listener
function radioButtonListener(event)
    if event.phase == "began" then
        for i = 1, 3 do-- loop thru radio group
            if radioGroup[i].isOn then
                -- change level var to match selected radio button #
                level = i
                print("level is: " ..tostring(level))
            end
        end
    end
end

radioLabels = display.newText({
    text = "Level 1       Level 2      Level 3",
    x = display.contentCenterX + 20,
    y = 650,
    fontSize = 40
})
-- level 1's radio button:
local level1Button = widget.newSwitch({
    left = display.contentCenterX - 200,
    top = 700,
    style = "radio",
    id = "level1Button",
    onPress = radioButtonListener,
    initialSwitchState = true, -- default to level 1
    level = 1 -- the int corresponding to level #
})
radioGroup:insert(level1Button)

-- level 2's radio button:
local level2Button = widget.newSwitch({
    left = display.contentCenterX,
    top = 700,
    style = "radio",
    id = "level2Button",
    onPress = radioButtonListener,
    initialSwitchState = false,
    level = 2 -- the int corresponding to level #
})
radioGroup:insert(level2Button)

-- level 3's radio button:
local level3Button = widget.newSwitch({
    left = display.contentCenterX + 200,
    top = 700,
    style = "radio",
    id = "level3Button",
    onPress = radioButtonListener,
    initialSwitchState = false,
    level = 3 -- the int corresponding to level #
})
radioGroup:insert(level3Button)

-- start button

function onStartButtonClick(event)
    if event.phase == "began" then
        composer.gotoScene("gameView", {params = {
            level,
            ballSpeed,
            0
        }})
    end
end

startButtonGroup = display.newGroup()
startButtonGroup.x = display.contentCenterX - 40
startButtonGroup.y = 500
startButtonRect = display.newRect(startButtonGroup, 50, 25, 240, 100)
startButtonTxt = display.newText({
    text = "Start",
    parent = startButtonGroup,
    x = 50,
    y = 25, 
    fontSize = 40
})
startButtonTxt:setTextColor(0,0,0)

startButtonGroup:addEventListener("touch",onStartButtonClick)

-- leaderboard button
function onLBButtonClick(event)
    if event.phase == "began" then
        composer.gotoScene("leaderboard", {params = {
            level,
            ballSpeed
        }})
    end
end

lbButtonGroup = display.newGroup()
lbButtonGroup.x = display.contentCenterX - 40
lbButtonGroup.y = 1000
lbButtonRect = display.newRect(lbButtonGroup, 50, 25, 240, 100)
lbButtonTxt = display.newText({
    text = "Leaderboard",
    parent = lbButtonGroup,
    x = 50,
    y = 25, 
    fontSize = 40
})
lbButtonTxt:setTextColor(0,0,0)

lbButtonGroup:addEventListener("touch",onLBButtonClick)

-- speed slider 
ballSpeedSliderLabel = display.newText({
    text = "Ball Speed: "..tostring(ballSpeed), 
    x = display.contentCenterX,
    y = 780,
    font = native.systemFont,
    fontSize = 40
})

function speedSliderListener(event)
    local val = event.value 
    val = math.floor((val /11.1111) + 1) -- adjust range from 0-100 to 1-10
    ballSpeed = val
    ballSpeedSliderLabel.text = "Ball Speed: "..tostring(ballSpeed)
end

ballSpeedSlider = widget.newSlider({
    top = 850,
    left = display.contentCenterX - 75,
    width = 150,
    value = 1,
    listener = speedSliderListener
})

 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- add all this scene's elements to the scene group
    sceneGroup:insert(startButtonGroup)
    sceneGroup:insert(radioGroup)
    sceneGroup:insert(nameText)
    sceneGroup:insert(lbButtonGroup)
    sceneGroup:insert(radioLabels)
    sceneGroup:insert(ballSpeedSliderLabel)
    sceneGroup:insert(ballSpeedSlider)

    -- create high scores file iff it doesnt exist yet
    local path = system.pathForFile("highscores.json", system.DocumentsDirectory)
    local file = io.open(path, "r")

    if not file then -- file = null if it wasn't found, works for false condition here
        file = io.open(path, "w")
        file:write(json.encode({1000,0,0,0,0}))
    end
    
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
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