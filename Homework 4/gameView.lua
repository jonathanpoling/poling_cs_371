local composer = require( "composer" )
local physics = require("physics") 
local json = require("json")

local scene = composer.newScene()
-- Initialize anything PERMANENT for this scene (w/placeholder vals; passed params will update)

ballSpeed = 1 -- 
local level = 0
score = 0
lives = 3
bricksDestroyed = 0
postGameTaps = 0
gameLost = false
highScores = {}
gameWon = false

paddleSFX = audio.loadSound("paddle.wav")
hitSFX = audio.loadSound("hit.wav")

-- enable physics, disable gravity (forces applied in this game do not rely on it)
-- ball = display.newCircle(display.contentCenterX, display.contentCenterY, 10)
physics.start()
physics.setGravity(0,0)

--
function doubleTap(event) -- allow for double-tapping to return to title screen
    if event.phase == "began" then
        if gameLost then
            postGameTaps = postGameTaps + 1
            if postGameTaps == 2 then
                -- clear out bricks 
                for i = brickGroup.numChildren, 1, -1 do 
                    physics.removeBody(brickGroup[i])
                    display.remove(brickGroup[i])
                end
                brickGroup = nil
                -- go back to title
                Runtime:removeEventListener("touch", doubleTap)
                composer.removeScene("gameView")
                composer.gotoScene("titleAndSettings", {params = {
                    highScores}})
            end
        end
    end
end

function gameOver() -- called when lives = 0 or when level 3 is cleared
    gameLost = true
    Runtime:removeEventListener("touch", move)
    display.remove(ball)
    if not gameWon then
        gameOverText.text = "Game Over!"
    else
        gameOverText.text = "Victory!" -- repurpose game over text obj for level 3 completion
    end
    -- check if a new high score should be inserted
    scorePos = 0
    for i = 5, 1, -1 do -- check if a new high score should be inserted
        local path = system.pathForFile("highscores.json", system.DocumentsDirectory)
        local file = io.open(path, "r") 
        jsonScores = file:read("*a") -- read entire file into one json string
        highScores = json.decode(jsonScores) -- decode into lua table
        if score > highScores[i] then
            scorePos = i
        end
        io.close(file)
    end
    if scorePos > 0 then
        print("inserting: "..tostring(score).." at pos "..tostring(scorePos))
        table.insert(highScores, scorePos, score)
        table.remove(highScores) -- remove previous 5th score
        newJsonScores = json.encode(highScores)
        local path = system.pathForFile("highscores.json", system.DocumentsDirectory)

        local file = io.open(path, "w")
        file:write(newJsonScores)
        io.close(file)
        
    end
    Runtime:addEventListener("touch", doubleTap)
    timer.performWithDelay(1000, function() -- require a somewhat quick "double tap", not just two taps
        if postGameTaps > 0 then
            postGameTaps = postGameTaps - 1
        end
    end, 0)
end

function level2()
    display.remove(ball)
    local txt = display.newText("Great Job! Starting level 2...", display.contentCenterX, 600, native.systemFontBold, 45)
    timer.performWithDelay(3000, function()
        level = 2
        Runtime:removeEventListener("touch", move)
        -- clear out bricks
        for i = brickGroup.numChildren, 1, -1 do 
            physics.removeBody(brickGroup[i])
            display.remove(brickGroup[i])
        end
        composer.removeScene("gameView")
        composer.gotoScene("gameView", {params = {
        level,
        ballSpeed,
        score }}
    )
    display.remove(txt)
    end)
end

function level3()
    display.remove(ball)
    local txt = display.newText("Great Job! Starting level 3...", display.contentCenterX, 600, native.systemFontBold, 45)
    timer.performWithDelay(3000, function()
        level = 3
        Runtime:removeEventListener("touch", move)
        -- clear out bricks
        for i = brickGroup.numChildren, 1, -1 do 
            physics.removeBody(brickGroup[i])
            display.remove(brickGroup[i])
        end
        composer.removeScene("gameView")
        composer.gotoScene("gameView", {params = {
        level,
        ballSpeed,
        score }}
    )
    display.remove(txt)
    end)
end

-- create score display; will be updated by scene functions
scoreHUD = display.newText(""..tostring(score), display.contentCenterX-50, 15, native.systemFontBold, 30)


-- brick spawning function
function spawnBricks()
    local bricks = display.newGroup() -- this group will contain all brick display objects and will be returned once they are all spawned
    if level == 1 then -- spawn level 1 brick arrangement (given by Dr. C)
        local reds = {};
        local function createRed (xPos, id)
            local red = display.newRect (xPos, 110, 30, 10);
            red:setFillColor(1,0,0);
            reds[id] = red;
            physics.addBody(red, "static")
            red.type = "redBrick"
            bricks:insert(red)
        end
    

        for i=1,9 do
            createRed(32*i, i);
        end


        local greens = {}; 
        local function createGreen (xPos, id)
            local green = display.newRect (xPos, 122, 30, 10);
            green:setFillColor(0,1,0);
            greens[id] = green;
            physics.addBody(green, "static")
            green.type = "greenBrick"
            bricks:insert(green)
        end

        for i=1,9 do
            createGreen(32*i, i);
        end


        local yellows = {}; 
        local function createYellow (xPos, id)
            local yellow = display.newRect (xPos, 134, 30, 10);
            yellow:setFillColor(1,1,0);
            yellows[id] = yellow;
            physics.addBody(yellow, "static")
            yellow.type = "yellowBrick"
            bricks:insert(yellow)
        end

        for i=1,9 do
            createYellow(32*i, i);
        end




    elseif level == 2 then -- spawn level 2 brick arrangement (full rows, up high)
        local reds = {};
        local function createRed (xPos, id)
            local red = display.newRect (xPos, 190, 30, 10);
            red:setFillColor(1,0,0);
            reds[id] = red;
            physics.addBody(red, "static")
            red.type = "redBrick"
            bricks:insert(red)
        end

        for i=1,19 do
            createRed(32*i, i);
        end


        local greens = {}; 
        local function createGreen (xPos, id)
            local green = display.newRect (xPos, 222, 30, 10);
            green:setFillColor(0,1,0);
            greens[id] = green;
            physics.addBody(green, "static")
            green.type = "greenBrick"
            bricks:insert(green)
        end

        for i=1,19 do
            createGreen(32*i, i);
        end


        local yellows = {}; 
        local function createYellow (xPos, id)
            local yellow = display.newRect (xPos, 250, 30, 10);
            yellow:setFillColor(1,1,0);
            yellows[id] = yellow;
            physics.addBody(yellow, "static")
            yellow.type = "yellowBrick"
            bricks:insert(yellow)
        end

        for i=1,19 do
            createYellow(32*i, i);
        end
        




    else -- spawn level 3 brick arrangement (full rows, down lower)
        local reds = {};
        local function createRed (xPos, id)
            local red = display.newRect (xPos, 410, 30, 10);
            red:setFillColor(1,0,0);
            reds[id] = red;
            physics.addBody(red, "static")
            red.type = "redBrick"
            bricks:insert(red)
        end

        for i=1,19 do
            createRed(32*i, i);
        end


        local greens = {}; 
        local function createGreen (xPos, id)
            local green = display.newRect (xPos, 422, 30, 10);
            green:setFillColor(0,1,0);
            greens[id] = green;
            physics.addBody(green, "static")
            green.type = "greenBrick"
            bricks:insert(green)
        end

        for i=1,19 do
            createGreen(32*i, i);
        end


        local yellows = {}; 
        local function createYellow (xPos, id)
            local yellow = display.newRect (xPos, 434, 30, 10);
            yellow:setFillColor(1,1,0);
            yellows[id] = yellow;
            physics.addBody(yellow, "static")
            yellow.type = "yellowBrick"
            bricks:insert(yellow)
        end

        for i=1,19 do
            createYellow(32*i, i);
        end
        
        
    end
    return bricks
end -- end of brick spawning function

-- Collision function: handles any and all physical collisions the ball encounters
function onLocalCollision(self, event) 
    if event.phase == "began" then
        -- if it hit the paddle, just play the paddle sound
        if event.other == paddle then
            audio.play(paddleSFX)
        -- if it hit a border, just check for life decrement/game over conditions
        elseif event.other == top or event.other == left or event.other == right or event.other == bottom then
            if event.other == bottom then
                lives = lives - 1 -- take life away if bottom hit
                if lives <= 0 then
                    gameOver()
                end
            end
            return 
        -- if a brick was hit (only other possibility), do some things...
        else 
            -- which type? apply score increase accordingly
            if event.other.type == "redBrick" then
                score = score + 1000
            elseif event.other.type == "greenBrick" then
                score = score + 100
            elseif event.other.type == "yellowBrick" then
                score = score + 50 
            end
            -- play sound effect, remove brick and update score display
            audio.play(hitSFX)
            display.remove(event.other)
            bricksDestroyed = bricksDestroyed + 1
            scoreHUD.text = "Score: "..tostring(score)
        end
    end
    -- check if level is complete. lvl 1 = 27 bricks, lvl 2/3 = 57 bricks 
    if level == 1 then
        if bricksDestroyed == 27 then -- go to level 2
            level2()
        end  
    elseif level == 2 then
        if bricksDestroyed == 57 then -- go to level 3
            level3()
        end
    else 
        if bricksDestroyed == 57 then -- level 3 won; game complete
            gameWon = true
            gameOver()
        end
    end
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    -- scale velocity based on ballSpeed param from settings
    -- boundaries
    top = display.newRect(0,40,display.contentWidth, 10);
    left = display.newRect(0,0,10, display.contentHeight);
    right = display.newRect(display.contentWidth-10,
				0,20,display.contentHeight);
    bottom = display.newRect(0,display.contentHeight-10, 
				display.contentWidth, 10);

    top.anchorX = 0;top.anchorY = 0;
    left.anchorX = 0;left.anchorY = 0;
    right.anchorX = 0;right.anchorY = 0;
    bottom.anchorX = 0;bottom.anchorY = 0;

    top:setFillColor(0.5, 0.5, 0.5)
    left:setFillColor(0.5, 0.5, 0.5)
    right:setFillColor(0.5, 0.5, 0.5)
    bottom:setFillColor(0.5, 0.5, 0.5)


    -- add physics to edges
    physics.addBody(left, "static")
    physics.addBody(right, "static")
    physics.addBody(bottom, "static")
    physics.addBody(top, "static")


    
    -- create paddle
    paddle = display.newRect (display.contentCenterX, display.contentHeight-50, 30, 6);
    paddle:setFillColor(0.529, 0.808, 0.922)
    physics.addBody(paddle, "static")

    -- paddle movement (by Dr. C)
    function move ( event )
	    if event.phase == "began" then		
		    paddle.markX = paddle.x 
	    elseif event.phase == "moved" and paddle.markX then	 	-- changed to check that markX exists to prevent crash
	 	    local x = (event.x - event.xStart) + paddle.markX	 	paddle.x = x;
	 	    if (x <= 10 + paddle.width/2) then
		        paddle.x = 10+paddle.width/2;
		    elseif (x >= display.contentWidth-10-paddle.width/2) then
		        paddle.x = display.contentWidth-10-paddle.width/2;
		    else
		        paddle.x = x;		
		    end
	    end
    end -- end of move()

end
 
 
-- show()
function scene:show( event )
    -- highscores path
    local path = system.pathForFile("highscores.json", system.ResourceDirectory)

    -- game data from prev level
    score = event.params[3]
    ballSpeed = event.params[2]
    level = event.params[1]
    local sceneGroup = self.view
    local phase = event.phase
    gameWon = false

    scoreHUD.text = "Score: "..tostring(score)

    if ( phase == "will" ) then
        -- Reset values that should be
        bricksDestroyed = 0 -- reset brick count
        lives = 3 -- reset life count 

        -- make level background
        if level == 1 then
            bg = display.newImage( "bg1.png" )
            score = 0 -- reset score if starting from lvl 1
        elseif level == 2 then
            bg = display.newImage( "bg2.png" )
        else
            bg = display.newImage( "bg3.png" )
        end
        


        -- set this to "Game Over!" when lives hit 0
        gameOverText = display.newText("", display.contentCenterX, display.contentCenterY, native.systemFontBold, 60)


        -- move bg and insert scene elements into 
        bg:translate(display.contentCenterX, display.contentCenterY)
        sceneGroup:insert(bg) -- insert scene content into scene group so it disappears when changing scenes
        sceneGroup:insert(left)
        sceneGroup:insert(right)
        sceneGroup:insert(top)
        sceneGroup:insert(bottom)
        sceneGroup:insert(paddle)
        sceneGroup:insert(scoreHUD)
        brickGroup = spawnBricks()
        sceneGroup:insert(brickGroup)
        sceneGroup:insert(gameOverText)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

        -- make ball
        ball = display.newCircle(display.contentCenterX,display.contentCenterY, 5)

        physics.addBody(ball, "dynamic",{
        bounce = 1, -- ensures unchanging velocity magnitude
        radius = 10
        })

        ball.collision = onLocalCollision -- register ball collision
        ball:addEventListener("collision")
        sceneGroup:insert(ball)

        ball:setLinearVelocity(35 * ballSpeed, 35 * ballSpeed)  
        -- 35 * ballspeed (which maxes at 10) seems to be the highest reasonable speed

        -- register paddle movement func under screen touch event
        Runtime:addEventListener("touch", move);
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