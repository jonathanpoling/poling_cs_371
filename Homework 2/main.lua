
-- ========= Initial Setup ====================================================
-- hide the status bar
display.setStatusBar(display.HiddenStatusBar)


-- set background
bg = display.newImage("background.png")
bg.y = 480
bg.x = 320

-- make table to store coins and their info
Coins = {}

-- global score + gameover vars
Score = 0
GameOver = false

-- display score
scoreText = display.newText("Score: "..tostring(Score), display.contentCenterX, -30, native.systemFontBold, 50)
scoreText:setFillColor(0,0,0)

-- create sprite sheet for character and coins; define 
-- animation sequences
EsperSheet = graphics.newImageSheet("Esper.png", {
    width = 128,
    height = 128,
    numFrames = 10,
    sheetContentWidth = 768,
    sheetContentHeight = 256
})

EsperSequences = {
    {
    name = "run",
    start = 1, -- start at first frame
    count = 6, -- perform 6 frames
    time = 400, -- time in ms between frame changes
    loopCount = 3,
    loopDirection = "forward"
    },

    {
    name = "die",
    start = 9, -- start at 9th frame
    count = 2, -- perform 2 frames
    time = 1000, -- time in ms between frame changes
    loopCount = 3,
    loopDirection = "forward"
    }
}

currentTransition = nil -- we will use this to track Esper's transition state 

CoinSheet = graphics.newImageSheet("Coin.png", {
    name = "spin",
    frames = {
        {x = 0, y = 0, width = 76, height = 68},
        {x = 76, y = 0, width = 76, height = 68},
        {x = 152, y = 0, width = 76, height = 68},
        {x = 233, y = 0, width = 77, height = 68},
        {x = 315, y = 0, width = 76, height = 68},
        {x = 408, y = 0, width = 52, height = 68}
    },
    sheetContentWidth = 462,
    sheetContentHeight = 68
})

-- coin/death sfx setup
coinPickupSFX = audio.loadSound("coin.wav")
deathSFX = audio.loadSound("death.wav")

CoinSequence = {
    start = 1, -- start at first frame
    count = 6, -- perform 6 frames
    time = 500, -- time in ms betwen frame changes
    loopCount = 0, -- infinite
    loopDirection = "forward"
}





-- ========= Helper Functions ====================================================

-- get distance between two points
function distanceBetween(x1, y1, x2, y2)
    distance = ((y2-y1)^2 + (x2-x1)^2)^0.5
    return distance
end

-- timer data/setup
local GAME_DURATION = 20        -- it's a second
local timerText = display.newText("30.0", display.contentCenterX, 50, native.systemFontBold, 100)
timerText:setFillColor(0,0,0)
local elapsed = 0
local prevTime = system.getTimer()

-- timer function
local function gameLoop()
    if GameOver == false then
        local now = system.getTimer()
        local dt = (now - prevTime) / 1000
        prevTime = now
        elapsed = elapsed + dt
        local remain = math.max(0, GAME_DURATION - elapsed)
        timerText.text = string.format("%.1f", remain)
        if (elapsed >= 20) then
            gameLost()
        end
    end
end

-- called by the function after this to make Esper fade out
function fadeAway() 
    transition.fadeOut(Esper, {time = 1000})
    informGameOver() -- spawn game over text (feels better to have here)
end

-- called when time is up; sets up losing events
function gameLost() 
    GameOver = true

    transition.cancelAll() -- cancel any active transitions so animation always works

    audio.play(deathSFX)

    Esper:pause() -- play esper's dying animation
    Esper:setSequence("die")
    Esper:play()
    timer.performWithDelay(3000, fadeAway) -- fade esper out
end

-- End the game if the user has collected all 15 coins
function gameWon() 
    GameOver = true
    congratsTxt = display.newText("Congratulations!", display.contentCenterX, -100, native.systemFontBold, 70)
    congratsTxt:addEventListener("touch", startGame)
    congratsTxt:setFillColor(0,0,0.5)
end

-- display gameover text
function informGameOver()
    -- display text
    gameOverTxt = display.newText("Game Over", display.contentCenterX, display.contentCenterY, native.systemFontBold, 100)
    gameOverTxt:addEventListener("touch", startGame)
end

function spawnCoins() -- set up 15 coins for game start
    for i = 1, 15, 1 do
        local thisCoin = display.newSprite(CoinSheet, CoinSequence)
        thisCoin.x = math.random(40,600) -- leave about 40 pixels
        -- of "extra room" so the coins dont appear offscreen
        thisCoin.y = math.random(40,920)
        thisCoin:setSequence("spin")
        thisCoin:play()
        table.insert(Coins, thisCoin)
    end
end

function spawnEsper() -- set up esper with initial pos and attributes
    Esper = display.newSprite(EsperSheet, EsperSequences)
    Esper.x = 320
    Esper.y = 480
    Esper.isRunning = false
end

-- function to move esper to a tapped location
local currentTransition = nil -- initially, no transition active
function moveEsper(event)
    if GameOver == false then
        -- cancel current animation
        if currentTransition then
            transition.cancel(currentTransition)
            currentTransition = nil
        end

        -- start run animation
        Esper:setSequence("run")
        Esper:play()

        -- start movement
        currentTransition = transition.moveTo(Esper, {
            x = event.x,
            y = event.y,
            time = 1000,
            onComplete = function()
                currentTransition = nil
                -- only stop if no other transition started during movement
                Esper:pause()
            end
        })
    end
end

function update() -- check for certain conditions every 20 ms
    for i,v in ipairs(Coins) do
        if(distanceBetween(Esper.x, Esper.y, v.x, v.y) < 60) then
        -- remove coin and update score
        table.remove(Coins, i)
        display.remove(v)
        audio.play(coinPickupSFX)
        Score = Score + 100
        scoreText.text = "Score: "..tostring(Score)
        end
        if Score == 1500 then
            gameWon()
        end
    end
end

function startGame() -- clean up & start a new game
    -- remove game over/ congrats text
    display.remove(congratsTxt)
    display.remove(gameOverTxt)

    -- reset score text
    scoreText.text = "Score: 0"

    -- remove animation handler
    Runtime:removeEventListener("enterFrame", gameLoop)

    -- remove esper
    display.remove(Esper)

    -- reset globals
    GameOver = false
    Score = 0

    -- reset timer
    elapsed = 0
    prevTime = system.getTimer()
    timerText.text = string.format("%.1f", GAME_DURATION)

    -- cleanup coins if they still exist
    for i = #Coins, 1, -1 do
    display.remove(Coins[i])
    table.remove(Coins, i)
    end

    -- respawn coins and esper; re-register animation handler
    spawnCoins()
    spawnEsper()
    Runtime:addEventListener("enterFrame", gameLoop)
end





-- ========= Initial game start ====================================================

startGame() -- start the game for the first time
timer.performWithDelay(20, update, 0) -- init timer
bg:addEventListener("touch", moveEsper) -- add bg touch listener