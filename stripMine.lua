--[[
    Assumptions: a stack of torches in the final slot

    This program is meant to make a strip mine. only a single level, looking from above it should look somthing like
    x = stone
    | = mined out portion

    |xxx|xxx|xxx|xxx|xxx|xxx|xxx|
    |xxx|xxx|xxx|xxx|xxx|xxx|xxx|
    |xxx|xxx|xxx|xxx|xxx|xxx|xxx|
    |xxx|xxx|xxx|xxx|xxx|xxx|xxx|
    |xxx|xxx|xxx|xxx|xxx|xxx|xxx|
    |xxx|xxx|xxx|xxx|xxx|xxx|xxx|
    |---|---|---|---|---|---|---|

    this should allow the player to go through and mine anything valuable.
]]

term.clear()
term.setCursorPos(1,1)
io.write("Length of a side: ")
sSize = io.read()
if sSize == nil then sSize = 16 end

function screenWriting(screenText)
    term.clear()
    term.setCursorPos(1,1)
    io.write(screenText)
    term.setCursorPos(1,2)
    io.write("Square size: " .. sSize)
    term.setCursorPos(1,3)
    io.write("Fuel Left: " .. turtle.getFuelLevel())
end

-------------------
-- Logging Start --
-------------------

local printToTurtle = true

local logfile="/Logfile.txt" -- This is the destination where the logs and errors in writed.
local file=fs.open(logfile, "w")
file.writeLine("------------")
file.writeLine("-- Log script by iRichard. Modified by Neain --")
file.writeLine("Log created on day: "..os.day().." at "..textutils.formatTime(os.time(), timedate).." (in-game time).")
file.writeLine("Computer ID: "..os.getComputerID())
file.writeLine("------------")
file.close() 

function writeToLog(assasinText)
    if printToTurtle then
        print(assasinText)
    end
    
    local file=fs.open(logfile, "a")
    file.writeLine(assasinText)
    file.close()
end

-----------------
-- Logging End --
-----------------

------------------------------
-- 'Global' Variables Start --
------------------------------

-- saved in x, z format
local FaceForwardFromStart = { 0, 1, 1}
local FaceRightFromStart = { 1, 0, 2 }
local FaceBackwardFromStart = { 0, -1, 3}
local FaceLeftFromStart = { -1, 0, 4 }

-- the current location in x, y, z
-- starts of at 0,0,0 because thats where the miner should be located
local currentLoc = { 0,0,0 }

-- the current direction stored as {x,z}
-- starts at 0, 1 because the front is facing Z ()
local currentFacing = FaceForwardFromStart

-- variables that shouldnt need to be variables, but are so that debugging things is easier
local invSize = 14
local sides, depth = tonumber(sSize), tonumber(yDisp) -- length of the sides, how far down or up
-- local sides, depth = 5, 5

----------------------------
-- 'Global' Variables End --
----------------------------


---------------------
-- Functions Start --
---------------------

-- all this does is deposite all items in front of it. 
-- should only be called when at 0,0,0 and facing backward from start
-- returns false if not at 0,0,0 or if the facing isnt back from start (-z)
function depositAll()
    -- checking that its at the correct location
    if currentLoc[1]==0 and currentLoc[2]==0 and currentLoc[3]==0 then
    else
        return false
    end
    -- checking that its facing the correct way
    if currentFacing == FaceBackwardFromStart then
    else
        return false
    end

    -- after this part it is accepted that the turtle is at 0,0,0 and facing the chest behind its starting location

    local needBurnable = true
    for slotDepositAll = 1,invSize do
        turtle.select(slotDepositAll)
        if needBurnable and turtle.refuel(0) then
            needBurnable = false
        else
            turtle.drop()
        end
    end
    turtle.select(1)
    return true
end

-- saves where its at, and what direction its facing and returns to base
-- drops off all items
-- returns to where it was, facing the direction it was
function returnToBase()
    local savedX, savedY, savedZ = currentLoc[1],currentLoc[2],currentLoc[3]
    local savedDirection = currentFacing

    moveToLocX(0)
    moveToLocZ(0)

    faceDirection(FaceBackwardFromStart)
    depositAll()
    faceDirection(FaceLeftFromStart)
    refreshFuel()
    faceDirection(FaceForwardFromStart)

    moveToLocZ(savedZ)
    moveToLocX(savedX)
    
    faceDirection(savedDirection)
end

-- each time a block is mined, checks if slot 16 (or the farthest slot selected by {invSize}) is empty or not. 
-- if its empty, then keep going. If it has anything in it, then return false
function canCollectMore()
    if turtle.getItemCount(invSize) == 0 then
        return true
    end
    return false
end

-- turns the turtle until it faces the direction desired
function faceDirection(faceDir)
    local displacement = currentFacing[3]-faceDir[3]
    if displacement == 1 or displacement == -3 then
        turtle.turnLeft()
    end
    if displacement == 2 or displacement == -2 then
        turtle.turnRight()
        turtle.turnRight()
    end
    if displacement == 3 or displacement == -1 then
        turtle.turnRight()
    end
    currentFacing=faceDir
end

-- looks through the entire inventory for fuel and will eat everything it finds
-- returns true if it refueled anything, false if there was nothing. 
-- (Planning on finding nothing never happening because each time it drops items off, it will make sure it has a full stack in slot 1)
function refuel()
    -- checking that the turtle isnt above 90k. if it is... we need nothing
    if turtle.getFuelLevel()>90000 then
        return
    end

    for lookingForEdibles = 1,invSize do
        turtle.select(lookingForEdibles)
        turtle.refuel(turtle.getItemCount())
    end
    turtle.select(1)
end

-- turns to the left and grabs a stack. LEFT SHOULD BE A BOX OF FUEL.
-- returns false if not called when at 0,0,0 and looking left
function refreshFuel()
    -- checking that we dont already have something in the first slot
    if turtle.refuel(0) then
        return true
    end

    -- checking that the turtle thinks its at 0,0,0 and looking left
    if not (currentFacing==FaceLeftFromStart and currentLoc[1]==0 and currentLoc[2]==0 and currentLoc[3]==0) then
        return false
    end

    turtle.suck()
    return true
end

-- moves to x={xLoc} and mines every block
-- returns true if it can move to that location
-- returns false if anything gets in the way
function moveToLocX(xGoing)
    local lDist = math.abs(xGoing-currentLoc[1])

    if xGoing > currentLoc[1] then
        faceDirection(FaceRightFromStart)
    elseif xGoing < currentLoc[1] then
        faceDirection(FaceLeftFromStart)
    else
        return true
    end
    for distance = 1,lDist do
        mineForward()
    end
end

-- moves to z={zLoc} and mines every block
-- returns true if it can move to that location
-- returns false if anything gets in the way
function moveToLocZ(zGoing)
    local lDist = math.abs(zGoing-currentLoc[3])

    if zGoing > currentLoc[3] then
        faceDirection(FaceForwardFromStart)
    elseif zGoing < currentLoc[3] then
        faceDirection(FaceBackwardFromStart)
    else
        return true
    end
    for distance = 1,lDist do
        mineForward()
    end
end

-- checks forward, if block, then mine, then move forward, if block above, mine above, if block below, mine below.
function mineForward()
    while turtle.detect() do
        if turtle.dig() then
            if not canCollectMore() then
                returnToBase()
            end
        end
    end
    
    -- just making sure that the turtle doesnt run off again
    if currentLoc[1] < -1 then
        writeToLog("263: Turtle went into -X area")
        os.exit()
    end
    if currentLoc[3] < -1 then
        writeToLog("267: Turtle went into -Z area")
        os.exit()
    end
    if currentLoc[1] > (sides+3) then
        writeToLog("263: Turtle went too far into X area")
        os.exit()
    end
    if currentLoc[3] > (sides+3) then
        writeToLog("267: Turtle went too far into Z area")
        os.exit()
    end



    if turtle.forward() then
        currentLoc[1] = currentLoc[1] + currentFacing[1]
        currentLoc[3] = currentLoc[3] + currentFacing[2]
        screenWriting("Turtle at x,y,z: " .. currentLoc[1] .. "," .. currentLoc[2] .. "," .. currentLoc[3])
    end

    if turtle.detectUp() then
        if turtle.digUp() then
            if not canCollectMore then
                returnToBase()
            end
        end
    end

    if turtle.detectDown() then
        if turtle.digDown() then
            if not canCollectMore then
                returnToBase()
            end
        end
    end
    runTorchProtocolAlpha()
end

function runTorchProtocolAlpha()
    writeToLog("CurrentLoc[1], CurrentLoc[3](" .. currentLoc[1] .. "," .. currentLoc[3] .. ")")
    writeToLog("(CurrentLoc[1]-1) % 4, (CurrentLoc[3]-1) % 13(" .. (currentLoc[1]-1) % 4 .. "," .. (currentLoc[3]-1) % 13 .. ")")
    writeToLog("------------------------------------------------------------------------------------")
    if (currentLoc[1]-1) % 4==0 and (currentLoc[3]-1) % 13==0 then
        writeToLog("Inside the if statement")
        writeToLog("CurrentLoc[1], CurrentLoc[3](" .. currentLoc[1] .. "," .. currentLoc[3] .. ")")
        turtle.select(16)
        turtle.placeDown()
        turtle.select(1)
    end
end

-- sets up the logic to mine in a square for each Y level
function squareLogic(sideLength)
    while currentLoc[1] ~= sideLength do --while x is not our length 
        while currentLoc[3] ~= (sideLength-1) do -- while z is not our length
            faceDirection(FaceForwardFromStart)
            runTorchProtocolAlpha()
            mineForward()
        end

        if currentLoc[1] == sideLength-1 and currentLoc[3] == sideLength-1 then
            break
        end

        moveToLocZ(0)

        -- turning code here. Need to mine 4 blocks and then turn left
        if(currentLoc[1]~=sideLength-1) then -- as long as where we are is not the final x location
            faceDirection(FaceRightFromStart)
            mineForward()
            mineForward()
            mineForward()
            mineForward()
            faceDirection(FaceForwardFromStart)
        end
    end

    moveToLocX(0)
    moveToLocZ(0)

    faceDirection(FaceBackwardFromStart)
    depositAll()
    faceDirection(FaceLeftFromStart)
    refreshFuel()
    refuel()
    faceDirection(FaceForwardFromStart)

end



function dumpTable(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dumpTable(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end
-------------------
-- Functions End --
-------------------

-----------------------------
-- Running Code Below Here --
-----------------------------


faceDirection(FaceLeftFromStart)
refreshFuel()
refuel()

if turtle.detectUp() then
    turtle.digUp()
end

if turtle.detectDown() then
    turtle.digDown()
end

faceDirection(FaceForwardFromStart)
squareLogic(sides)

--[[ os.sleep(5)
faceDirection(FaceRightFromStart)
os.sleep(5)
faceDirection(FaceLeftFromStart)
os.sleep(5)
faceDirection(FaceBackwardFromStart)
os.sleep(5)
faceDirection(FaceForwardFromStart) ]]

