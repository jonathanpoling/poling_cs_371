-- Author: Jonathan Poling (solo)
-- Course and assignment #: CS 371-1, Assignment 3
-- Description: main.lua file for Keen Bayonet Sprite Viewer in Solar2D
-- Date of completion: 11/10/2025

-- ========= Initial Setup ====================================================
-- require widgets
local widget = require( "widget" )

-- hide the status bar
display.setStatusBar(display.HiddenStatusBar)

-- set background
bg = display.newImage("background.png")
bg.x = display.contentCenterX
bg.y = display.contentCenterY
bg.xScale = 0.8
bg.yScale = 0.8



-- ======== Sprite Sheet + Sequence Setup ==============
-- Note: Every animation sequence per object must have a "reverse" version, since clicking that part of the fish should play its animation
-- either forward or in reverse, depending on what the previous "direction" of animation was
-- whole sheet is 606x370

-- Mouth object setup: specify sheet area
mouthSheet = graphics.newImageSheet("KingBayonet.png",{
    name = "mouthAnimation",
    frames = {
        {x = 337, y = 23, width = 72, height = 31},
        {x = 412, y = 23, width = 72, height = 31},
        {x = 488, y = 23, width = 72, height = 31}
    },
    sheetContentWidth = 606,
    sheetContentHeight = 370
})

mouthSequences = {
    -- Mouth's "Open" animation sequence
    {
        name = "mouthOpen",
        frames = {1,2,3},
        time = 500, -- time in ms betwen frame changes
        loopCount = 1 -- play once
    },

    -- Mouth's "Close" animation sequence (reverses Open)
    {
        name = "mouthClose",
        frames = {3, 2, 1},
        time = 500, -- time in ms betwen frame changes
        loopCount = 1 -- play once
    }
}

-------------------------------------
-------------------------------------

-- Snout object setup: specify sheet area
snoutSheet = graphics.newImageSheet("KingBayonet.png",{
    name = "snoutAnimation",
    frames = {
        {x = 248, y = 32, width = 20, height = 12},
        {x = 273, y = 32, width = 20, height = 12},
        {x = 298, y = 32, width = 21, height = 12}
    },
    sheetContentWidth = 606,
    sheetContentHeight = 370
})

snoutSequences = {
    -- Snout's "Glow" animation sequence (at least, that's what I think it's doing?)
    {
        name = "snoutGlow",
        frames = {1,2,3},
        time = 500, -- time in ms betwen frame changes
        loopCount = 1, -- play once
    },

    -- Snout's "Dim" animation sequence (reverses Glow)
    {
        name = "snoutDim",
        frames = {3,2,1},
        time = 500, -- time in ms betwen frame changes
        loopCount = 1, -- play once
    }
}

-------------------------------------
-------------------------------------

-- Pectoral Fin object setup: specify sheet area
pectoralFinSheet = graphics.newImageSheet("KingBayonet.png",{
    name = "pectoralFinAnimation",
    frames = {
        {x = 26, y = 111, width = 63, height = 45},
        {x = 96, y = 118, width = 64, height = 45},
        {x = 168, y = 122, width = 65, height = 45}
    },
    sheetContentWidth = 606,
    sheetContentHeight = 370
})

pectoralFinSequences = {
    -- Pectoral Fin's "Wave" animation sequence
    {
        name = "pectoralFinWave",
        frames = {1,2,3},
        time = 500, -- time in ms betwen frame changes
        loopCount = 1 -- play once
    },

    -- Pectoral Fin's "Dewave" animation sequence (reverses Wave)
    {
        name = "pectoralFinDewave",
        frames = {3,2,1},
        time = 500, -- time in ms betwen frame changes
        loopCount = 1 -- play once
    }
}
-------------------------------------
-------------------------------------

-- Caudal Fin object setup: specify sheet area
caudalFinSheet = graphics.newImageSheet("KingBayonet.png",{
    name = "caudalFinAnimation",
    frames = { -- 251 OR 252 NOTHING ELSE
        {x = 252, y = 83, width = 64, height = 112},
        {x = 316, y = 98, width = 73, height = 83},
        {x = 393, y = 106, width = 73, height = 67}
    },
    sheetContentWidth = 606,
    sheetContentHeight = 370
})

caudalFinSequences = {
    -- Caudal Fin's "Wave" animation sequences
    {
        name = "caudalFinWave",
        frames = {1,2,3},
        time = 500, -- time in ms betwen frame changes
        loopCount = 1 -- play once
    },

    -- Caudal Fin's "Dewave" animation sequence (reverses Wave)
    {
        name = "caudalFinDewave",
        frames = {3,2,1},
        time = 500, -- time in ms betwen frame changes
        loopCount = 1 -- play once
    }
}

-------------------------------------
-------------------------------------

-- Dorsal Fin object setup: specify sheet area 
dorsalFinSheet = graphics.newImageSheet("KingBayonet.png",{
    frames = {
        {x = 485, y = 111, width = 73, height = 56}
        -- Only one frame (Inanimate)
    },
    sheetContentWidth = 606,
    sheetContentHeight = 370
})

-------------------------------------
-------------------------------------

-- Torso object setup: specify sheet area
torsoSheet = graphics.newImageSheet("KingBayonet.png",{
    frames = {
        {x = 26, y = 9, width = 201, height = 61}
        -- Only one frame (Inanimate)
    },
    sheetContentWidth = 606,
    sheetContentHeight = 370
})



-- ======== Sound effect Setup ==============
mouthSFX = audio.loadSound("mouth_sfx.wav")
caudalFinSFX = audio.loadSound("caudal_fin_sfx.wav")
pectoralFinSFX = audio.loadSound("pectoral_fin_sfx.wav")
snoutSFX = audio.loadSound("snout_sfx.wav")



-- ======== Create objects from sprite sheet portions, in one group ==============
Bayonet = display.newGroup() -- All parts of the body will be added to this group, so they can be moved uniformly
Bayonet.canMove = true -- bool used to enable/disable the bayonet's random movement


-- Create mouth object and set initial pos
Mouth = display.newSprite(Bayonet, mouthSheet, mouthSequences)
Mouth.x = -45.5
Mouth.y = 6.5
Mouth.xScale = 1.07 -- the mouth frame, for some reason, is not wide enough to fit in the gap it goes into
-- on the torso; this x scale is an ad hoc solution to that problem
Mouth.isOpen = false -- bool used to decide which animation to play on touch (see these bools' use in the "on touch" functions)
Mouth.isPlaying = false -- bool used to determine if this body part's animation is currently being played


-- Create Pectoral Fin object and set initial pos
PectoralFin = display.newSprite(Bayonet, pectoralFinSheet, pectoralFinSequences)
PectoralFin.x = 36
PectoralFin.y = 37
PectoralFin.isWaved = false -- bool used to decide which animation to play on touch
PectoralFin.isPlaying = false -- bool used to determine if this body part's animation is currently being played


-- Create snout object and set initial pos
Snout = display.newSprite(Bayonet, snoutSheet, snoutSequences)
Snout.x = -108
Snout.y = 4
Snout.isGlowing = false -- bool used to decide which animation to play on touch
Snout.isPlaying = false -- bool used to determine if this body part's animation is currently being played


-- Create Dorsal Fin object and set initial pos
DorsalFin = display.newSprite(Bayonet, dorsalFinSheet, {frames = {1}})
DorsalFin.x = 15
DorsalFin.y = -46


-- Create Caudal Fin object and set initial pos
CaudalFin = display.newSprite(Bayonet,caudalFinSheet, caudalFinSequences)
CaudalFin.x = 123
CaudalFin.y = -4
CaudalFin.isWaved = false -- bool used to decide which animation to play on touch
CaudalFin.isPlaying = false -- bool used to determine if this body part's animation is currently being played


-- Create Torso object and set initial pos
Torso = display.newSprite(Bayonet, torsoSheet, {frames = {1}})
Torso.y = 0
Torso.x = 0


-- Place entire body at center of screen
Bayonet.x = display.contentCenterX 
Bayonet.y = display.contentCenterY



-- ======== "On touch" functions for each body part ==============
function mouthTouched(event)
    if (Mouth.isPlaying or event.phase ~= "began") then
        return 0 -- don't do anything; animation currently playing
    end
    audio.play(mouthSFX)
    if Mouth.isOpen == false then -- determine which animation to play
        Mouth:setSequence("mouthOpen")
    else
        Mouth:setSequence("mouthClose")
    end
    Mouth.isPlaying = true
    Mouth.isOpen = not Mouth.isOpen -- invert current state
    Mouth:play()

    -- after animation finishes (1s), allow to be played again
    timer.performWithDelay(4000, function()
    Mouth.isPlaying = false
    end)
end

function caudalFinTouched(event)
    if CaudalFin.isPlaying or event.phase ~= "began" then
        return 0 -- don't do anything; animation currently playing
    end
    audio.play(caudalFinSFX)
    if CaudalFin.isWaved == false then -- determine which animation to play
        CaudalFin:setSequence("caudalFinWave")
    else
        CaudalFin:setSequence("caudalFinDewave")
    end
    CaudalFin.isPlaying = true
    CaudalFin.isWaved = not CaudalFin.isWaved -- invert current state
    CaudalFin:play()

    -- after animation finishes (1s), allow to be played again
    timer.performWithDelay(4000, function()
    CaudalFin.isPlaying = false
    end)
end

function pectoralFinTouched(event)
    if PectoralFin.isPlaying or event.phase ~= "began" then
        return 0 -- don't do anything; animation currently playing
    end
    audio.play(pectoralFinSFX)
    if PectoralFin.isWaved == false then -- determine which animation to play
        PectoralFin:setSequence("pectoralFinWave")
    else
        PectoralFin:setSequence("pectoralFinDewave")
    end
    PectoralFin.isPlaying = true
    PectoralFin.isWaved = not PectoralFin.isWaved -- invert current state
    PectoralFin:play()

    -- after animation finishes (1s), allow to be played again
    timer.performWithDelay(4000, function()
    PectoralFin.isPlaying = false
    end)
end

function snoutTouched(event)
    if Snout.isPlaying or event.phase ~= "began" then
        return 0 -- don't do anything; animation currently playing
    end
    audio.play(snoutSFX)
    if Snout.isGlowing == false then -- determine which animation to play
        Snout:setSequence("snoutGlow")
    else
        Snout:setSequence("snoutDim")
    end
    Snout.isPlaying = true
    Snout.isGlowing = not Snout.isGlowing -- invert current state
    Snout:play()

    -- after animation finishes (1s), allow to be played again
    timer.performWithDelay(4000, function()
    Snout.isPlaying = false
    end)
end



-- ======== Create labels for GUI widgets and some gloal modification data ============== 
MovementAndScaleModifier = 1 -- global multiplicative modifer to both scale and movement (ranges between 0 and 1.2)
Rotation = 0 -- global rotation modifier for the fish
Easing = "None" -- global easing indicator to be applied to movement
Easings = {"None", easing.inOutQuart, easing.inSine, easing.outBack} -- table to hold all possible easings; makes switching them easier; see radio button listener
RadioGroup = display.newGroup() -- group for the radio button set

-- make a label for the scale slider
scaleSliderLabel = display.newText({
    text = "Scale: "..tostring(MovementAndScaleModifier * 100),
    x = 70,
    y = 540,
    font = native.systemFont,
    fontSize = 40
})

-- make a label for the rotation slider
rotationSliderLabel = display.newText({
    text = "Rotation: "..tostring(Rotation),
    x = 320,
    y = 540,
    font = native.systemFont,
    fontSize = 40
})

-- make a label for the on/off switch for movement
switchLabel = display.newText({
    text = "Movement: On",
    x = 1070,
    y = 540,
    font = native.systemFont,
    fontSize = 40
})

-- make a label for all the easing buttons
radioLabels = display.newText({
    text = "Linear    Quart In/Out    Sine in    Back out ",
    x = 680,
    y = 540,
    font = native.systemFont,
    fontSize = 25
})



-- ======== GUI widget listener functions  ============== 
-- scale slider listener: called any time the slider's value changes
function scaleSliderListener(event)
    local xSign = Bayonet.xScale / math.abs(Bayonet.xScale) -- this var will hold -1 or 1 depending on the direction the fish is facing
    local val = event.value 
    val = (val * 1.2) / 100 -- extends range from 0-100 to 0-120; divide by 100 so we can easily scale by that %
    if (val == 0 or val == .012) then
        val = .01 -- according to the assigment dropbox, the fish should scale between 1 (NOT 0 or 1.2) and 120%
    end
    MovementAndScaleModifier = val -- set externally so that the movement function can use this as well
    Bayonet.xScale =  val * xSign
    Bayonet.yScale =  val
    -- update label
    scaleSliderLabel.text = "Scale: "..tostring(MovementAndScaleModifier * 100)
end

-- rotation slider listener: called any time the slider's value changes
function rotationSliderListener(event)
    Rotation = event.value * 3.6 -- make the range 0 - 360; set global rotation val to that
    Bayonet.rotation = Rotation
    -- update label
    rotationSliderLabel.text = "Rotation: "..tostring(Rotation)
end

-- switch listener: called any time the switch is toggled
function switchListener(event)
    Bayonet.canMove = not Bayonet.canMove -- allow/disallow movement 
    -- update label
    if switchLabel.text == "Movement: On" then
        switchLabel.text = "Movement: Off"
        transition.cancelAll()
    else
        switchLabel.text = "Movement: On"
        moveBayonet() -- immediately start moving again
    end
end

-- add drag + drop functionality for when movement is turned off (code given by Dr. Chung; thank you!)
local function drag (event)
    if (not Bayonet.canMove) then-- only allow dragging if movement is turned off
        if event.phase == "began" then     
            event.target.markX = event.target.x 
            event.target.markY = event.target.y
            event.target.isFocus = true;         
        elseif event.phase == "moved" and 
        event.target.isFocus == true then 
            local x = (event.x - event.xStart) + event.target.markX;     
            local y = (event.y - event.yStart) + event.target.markY;
            event.target.x, event.target.y = x, y;
        elseif event.phase == "ended" then 
            event.target.isFocus = false;
        end
    end
end

-- radio button listener: called any time a radio button is clicked
local function radioButtonListener( event )
    for i = 1, 4 do -- find which button is enabled; update easing appropriately
        if RadioGroup[i].isOn then
            Easing = Easings[i] -- Easings table has the SAME order as the radio button group; e.g. the ith easing function in Easings should be what we use
            -- if the ith radio button in the radio button Group is on 
            break
        end
    end
    print(Easing)
end

-- ======== Initialize GUI widgets, position them onscreen and assign listeners ============== 
rotationSlider = widget.newSlider({
    top = 580,
    left = 250,
    width = 150,
    value = 0,
    listener = rotationSliderListener
})

scaleSlider = widget.newSlider({
    top = 580,
    left = 0,
    width = 150,
    value = 80,
    listener = scaleSliderListener
})

onOffSwitch = widget.newSwitch({
    left = 1040,
    top = 590,
    style = "onOff",
    id = "onOffSwitch",
    onPress = switchListener,
    initialSwitchState = true
})

 
-- Create two associated radio buttons (inserted into the same display group)
local linearButton = widget.newSwitch(
    {
        left = 470,
        top = 580,
        style = "radio",
        id = "linearButton",
        onPress = radioButtonListener,
        initialSwitchState = true -- app starts with linear (none) easing
    }
)
RadioGroup:insert(linearButton) -- insert this button into the group (to prevent multiple from being selected)
 
local inOutQuartButton = widget.newSwitch(
    {
        left = 590,
        top = 580,
        style = "radio",
        id = "inOutQuartButton",
        onPress = radioButtonListener
    }
)
RadioGroup:insert(inOutQuartButton) -- insert this button into the group (to prevent multiple from being selected)

local inSineButton = widget.newSwitch(
    {
        left = 730,
        top = 580,
        style = "radio",
        id = "inSineButton",
        onPress = radioButtonListener
    }
)
RadioGroup:insert(inSineButton) -- insert this button into the group (to prevent multiple from being selected)

local outBackButton = widget.newSwitch(
    {
        left = 850,
        top = 580,
        style = "radio",
        id = "outBackButton",
        onPress = radioButtonListener
    }
)
RadioGroup:insert(outBackButton) -- insert this button into the group (to prevent multiple from being selected)



-- ======== Register touch listeners for each body part, and for GUI widgets ============== 
CaudalFin:addEventListener("touch", caudalFinTouched)
PectoralFin:addEventListener("touch", pectoralFinTouched)
Mouth:addEventListener("touch", mouthTouched)
Snout:addEventListener("touch", snoutTouched)
Bayonet:addEventListener ("touch", drag);



-- ======== Loop move function: check conditions/ change pos of fish every 20 ms ============== 
function moveBayonet() 
    if not Bayonet.canMove then
        return -- user has disabled movement; don't do anything
    end
    xDistance = MovementAndScaleModifier * math.random(-300,300) -- make distance moved scale with size
    yDistance = MovementAndScaleModifier * math.random(-100,100) 
    targetX = xDistance + Bayonet.x
    targetY = yDistance + Bayonet.y
    -- stay reasonably close to boundaries:
    if targetX > 1013 or targetX < 150 then 
        targetX = targetX - 2 * xDistance -- go the opposite x direction
    end

    if targetY > 540 or targetY < 100 then -- stay reasonably close to y boundary
        targetY = targetY - 2 * yDistance -- go the opposite y direction
    end

    if targetX > Bayonet.x then -- moving to the right
        Bayonet.xScale = -math.abs(Bayonet.xScale)
    else -- moving to the left
        Bayonet.xScale = math.abs(Bayonet.xScale)
    end
    if Easing == "None" then
        transition.to(Bayonet, {time = 2000, x = targetX, y = targetY})
    else 
        transition.to(Bayonet, {time = 2000, x = targetX, y = targetY, transition = Easing})
    end
end

-- Initialize other things 
moveBayonet() -- call once when app first starts
timer.performWithDelay(2000, moveBayonet, 0) -- init timer