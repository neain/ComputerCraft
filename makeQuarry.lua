--[[ term.clear()
term.setCursorPos(1,1)
io.write("Quarry or Pillar?")
isQuarry = io.read()

term.clear()
term.setCursorPos(1,1)
io.write("Length of a side: ")
sSize = io.read()

term.clear()
term.setCursorPos(1,1)
io.write("Y displacement: ")
yDisp = io.read()

if isQuarry == "Pillar" then
    goingUp = true
else
    goingUp = false
end

]]--

function screenWriting(screenText)
    term.clear()
    term.setCursorPos(1,1)
    io.write(screenText)
    term.setCursorPos(1,2)
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
local invSize = 5
local goingUp = false
-- local sides, depth = sSize, yDisp
local sides, depth = 5, 5



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

-- attempts to go up one block. Will mine blocks.
-- returns true if you can go up once
function goUp()
    while not turtle.up() do
        if turtle.detectUp() then
            local junkData, nameOfBlockUp = turtle.inspectUp()
            writeToLog("Line 110 - DetectingUp: " .. nameOfBlockUp.name)
            screenWriting("x,y,z: " .. currentLoc[1] .. "," .. currentLoc[2] .. "," .. currentLoc[3])
            if turtle.digUp() then
                if not canCollectMore then
                    returnToBase()
                end
            end

        else

        end
    end
    currentLoc[2] = currentLoc[2]+1
    return true
end

-- attempts to go down one block
-- returns true if you can move down once
function goDown()
    while not turtle.down() do
        if turtle.detectDown() then
            local junkData, nameOfBlockDown = turtle.inspectDown()
            writeToLog("Line 130 - DetectingDown: " .. nameOfBlockDown.name)
            screenWriting("x,y,z: " .. currentLoc[1] .. "," .. currentLoc[2] .. "," .. currentLoc[3])
            if turtle.digDown() then
                if not canCollectMore then
                    returnToBase()
                end
            end

        else

        end
    end
    currentLoc[2] = currentLoc[2]-1
    return true
end

-- saves where its at, and what direction its facing and returns to base
-- drops off all items
-- returns to where it was, facing the direction it was
function returnToBase()
    writeToLog("167: returnToBase")
    local savedX, savedY, savedZ = currentLoc[1],currentLoc[2],currentLoc[3]
    local savedDirection = currentFacing

    moveToLocX(0)
    moveToLocZ(0)
    moveToLocY(0)

    faceDirection(FaceBackwardFromStart)
    depositAll()
    writeToLog("177: About to turn Left")
    faceDirection(FaceLeftFromStart)
    refreshFuel()
    faceDirection(FaceForwardFromStart)

    moveToLocZ(savedY)
    moveToLocY(savedZ)
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
    writeToLog("203: faceDirection")
    writeToLog(dump(faceDir))
    local displacement = currentFacing[3]-faceDir[3]
-- todo    writeToLog("203: displacement | " .. displacement)
    if displacement == 1 or displacement == -3 then
-- todo        writeToLog("205: should be turning left once")
        turtle.turnLeft()
    end
    if displacement == 2 or displacement == -2 then
-- todo        writeToLog("208: should be turning right twice")
        turtle.turnRight()
        turtle.turnRight()
    end
    if displacement == 3 or displacement == -1 then
-- todo        writeToLog("212: should be turning right once")
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

-- checks if there is enough fuel for this level of square.     
function checkFuel(squareSize)
    if turtle.getFuelLevel() < squareSize*squareSize*currentLoc[2] then
        refreshFuel()
    end
end

-- moves one block forward without trying to mine anything
-- returns false if it cant move
function moveWithoutMining()
    if turtle.forward() then
        writeToLog("255: turtle moved forward")
        currentLoc[1] = currentLoc[1] + currentFacing[1]
        currentLoc[3] = currentLoc[3] + currentFacing[2]
        return true
    else
        writeToLog("260: failed to move forward.")
        return false
    end
end

-- moves to x={xLoc} without mining a block
-- returns true if it can move to that location
-- returns false if anything gets in the way
function moveToLocX(xGoing)
    writeToLog("270: Started moveToLocX")
    local lDist = math.abs(xGoing-currentLoc[1])

    if xGoing > currentLoc[1] then
        faceDirection(FaceRightFromStart)
    elseif xGoing < currentLoc[1] then
        faceDirection(FaceLeftFromStart)
    else
        return true
    end
    for distance = 1,lDist do
        moveWithoutMining()
    end
end

-- moves to y={yLoc} without mining a block
-- returns true if it can move to that location
-- returns false if anything gets in the way
function moveToLocY(yGoing)
    local lDist = math.abs(yGoing-currentLoc[2])

    if yGoing > currentLoc[2] then
        for distance = 1,lDist do
            goUp()
        end
    
    elseif yGoing < currentLoc[2] then
        for distance = 1,lDist do
            goDown()
        end
    else
        return true
    end
end

-- moves to z={zLoc} without mining a block
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
        moveWithoutMining()
    end
end

-- checks forward, if block, then mine, then move forward, if block above, mine above, if block below, mine below.
function mineForward()
    writeToLog("325: mineForward start")
    if turtle.detect() then
        local junkData, nameOfBlock = turtle.inspect()
-- todo        writeToLog("320 - Detecting: " .. nameOfBlock.name)
        if turtle.dig() then
-- todo            writeToLog("330: mineForward digging: ")
            if not canCollectMore() then
                writeToLog("341: mineForward cantCollect More")
                returnToBase()
            end
        end

    end
    
-- todo    writeToLog("339: Trying turtle.forward()")
    if turtle.forward() then
        currentLoc[1] = currentLoc[1] + currentFacing[1]
        currentLoc[3] = currentLoc[3] + currentFacing[2]
--[[    else
        writeToLog("344: failed to move. Turtle error message: ")
        print(turtle.forward())
        writeToLog(turtle.forward())
]]        
    end

    if turtle.detectUp() then
        if turtle.digUp() then
-- todo            writeToLog("353: dug up")
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
end

-- sets up the logic to mine in a square for each Y level
function squareLogic(sideLength)
    for zDistance = 1,sideLength-1 do
        for xDistance = 1,sideLength-1 do
            mineForward()
            writeToLog("384: x,y,z: " .. currentLoc[1] .. "," .. currentLoc[2] .. "," .. currentLoc[3])
            screenWriting("x,y,z: " .. currentLoc[1] .. "," .. currentLoc[2] .. "," .. currentLoc[3])
        end
        -- turning code here
        if(currentLoc[1]~=sideLength-1) then
            faceDirection(FaceRightFromStart)
            mineForward()
            writeToLog("390: x,y,z: " .. currentLoc[1] .. "," .. currentLoc[2] .. "," .. currentLoc[3])
            screenWriting("x,y,z: " .. currentLoc[1] .. "," .. currentLoc[2] .. "," .. currentLoc[3])

            writeToLog("393: End of one side. % is (" .. currentLoc[1]%2 .. ")")
            writeToLog("394: zDistance(" .. zDistance .. ")")
            if(currentLoc[1]%2==0) then
                writeToLog("395: Face Forward")
                faceDirection(FaceForwardFromStart)
            else
                writeToLog("398: Face Back")
                faceDirection(FaceBackwardFromStart)
            end
        end
    end
    moveToLocX(0)
    moveToLocZ(0)
    moveToLocY(0)

    faceDirection(FaceBackwardFromStart)
    depositAll()
    faceDirection(FaceLeftFromStart)
    refreshFuel()
    faceDirection(FaceForwardFromStart)

end

-- sets up the logic to mine a square, then change Y, and mine the next square
function devastate(length, height)
    writeToLog("407: devastate| (" .. length .. "," .. height .. ")" )
    for i = 1,height do
        squareLogic(length)
        for n = 1,3 do
            if goingUp then
                goUp()
            else
                goDown()
            end
        end
    end
end

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
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

if turtle.detectUp() then
    turtle.digUp()
end

if turtle.detectDown() then
    turtle.digDown()
end

faceDirection(FaceLeftFromStart)
refreshFuel()
refuel()
faceDirection(FaceForwardFromStart)
devastate(sides, depth)

--[[ os.sleep(5)
faceDirection(FaceRightFromStart)
os.sleep(5)
faceDirection(FaceLeftFromStart)
os.sleep(5)
faceDirection(FaceBackwardFromStart)
os.sleep(5)
faceDirection(FaceForwardFromStart) ]]

