--[[
Informaion: The first level bottom will be placed one lower than where the turtle is placed. 
The turtle clears forward, and to the right. Any blocks to the left of or behind the 
turtle will not be touched.
]]

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

term.clear()
term.setCursorPos(1,1)
io.write("going [u]p or [d]own? ")
isQuarry = io.read()

goingUp = true


writeToLog("43: isQuarry(" .. string.lower(isQuarry) .. ")")
if string.lower(isQuarry) == "u" then
    goingUp = true
else 
    goingUp = false 
end
writeToLog("49: goingUp(" .. tostring(goingUp) .. ")")

term.clear()
term.setCursorPos(1,1)
io.write("Length of a side: ")
sSize = io.read()
if sSize == nil then 
    sSize = 16 
end

term.clear()
term.setCursorPos(1,1)
io.write("How many floors?: ")
floorCount = io.read()
-- floorCount = floorCount - 1

term.clear()
term.setCursorPos(1,1)
io.write("Empty space between floor and ceiling of each room (min of 3)? ")
space = io.read()

term.clear()
term.setCursorPos(1,1)
io.write("How many layers does each floor have between air blocks? ")
floorLayerCount = io.read()

term.clear()
term.setCursorPos(1,1)
io.write("[y]es or [n]o. Skylights to prevent spawning during the day?  ")
skyLightQuestion =  string.lower(io.read())

writeToLog("80: skyLightQuestion(" .. skyLightQuestion .. ")")
if skyLightQuestion == "y" then
    skyLights = true
else
    skyLights = false
end

writeToLog("87: skyLights(" .. skyLightQuestion .. ")")
skyLightDistance = 7
if skyLights then
    term.clear()
    term.setCursorPos(1,1)
    io.write("7 is the default. Distance between skylights?  ")
    skyLightDistance = tonumber(io.read())
end

if skyLightDistance == nil then
    skyLightDistance = 7
end



function screenWriting(screenText)
    term.clear()
    term.setCursorPos(1,1)
    io.write(screenText)
    term.setCursorPos(1,2)
    io.write("Fuel Left: " .. turtle.getFuelLevel())
    term.setCursorPos(1,3)
    io.write("Number of Floors: " .. (floorCount))
    term.setCursorPos(1,4)
    io.write("Floor size: " .. sides)
    term.setCursorPos(1,5)
    io.write("Living Area: " .. space)
    term.setCursorPos(1,6)
    io.write("Floor layers: " .. floorLayerCount)
    term.setCursorPos(1,7)
    io.write("Skylights: " .. skyLightQuestion)
    term.setCursorPos(1,8)
    
end

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
sides, floors = tonumber(sSize), tonumber(floorCount) -- length of the sides, how far down or up
floorThickness = floorLayerCount
airBetween = space

--[[
sides, floors = 5, 5
floorThickness = 1
airBetween = 6 ]]

local isolatedFloorSize = (floorThickness + airBetween)
local fullPasses = math.floor(airBetween/3)
local partialQuarrying = airBetween%3
local numberOf 
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
    writeToLog("148: Turtle at (" .. currentLoc[1] .. "," .. currentLoc[2] .. "," .. currentLoc[3] ..")")
    screenWriting("Turtle at x,y,z: " .. currentLoc[1] .. "," .. currentLoc[2] .. "," .. currentLoc[3])

    return true
end

-- attempts to go down one block
-- returns true if you can move down once
function goDown()
    while not turtle.down() do
        if turtle.detectDown() then
            local junkData, nameOfBlockDown = turtle.inspectDown()
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
    writeToLog("172: Turtle at (" .. currentLoc[1] .. "," .. currentLoc[2] .. "," .. currentLoc[3] ..")")
    screenWriting("Turtle at x,y,z: " .. currentLoc[1] .. "," .. currentLoc[2] .. "," .. currentLoc[3])
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
    moveToLocY(0)

    faceDirection(FaceBackwardFromStart)
    depositAll()
    faceDirection(FaceLeftFromStart)
    refuel()
    refreshFuel()
    faceDirection(FaceForwardFromStart)

    moveToLocY(savedY)
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
        return true
    end

    for lookingForEdibles = 1,invSize do
        turtle.select(lookingForEdibles)
        turtle.refuel(turtle.getItemCount())
    end
    turtle.select(1)

    if turtle.getFuelLevel()>90000 then
        return false
    end
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
    refuel()
    if turtle.getFuelLevel() < squareSize*squareSize*currentLoc[2] then
        refreshFuel()
    end
end

-- moves one block forward without trying to mine anything
-- returns false if it cant move
function moveWithoutMining()
    -- just making sure that the turtle doesnt run off again
    if currentLoc[1]<-1 then
        writeToLog("270: Turtle went into -X area")
        os.exit()
    end
    if currentLoc[3]<-1 then
        writeToLog("270: Turtle went into -Z area")
        os.exit()
    end

    if turtle.forward() then
        currentLoc[1] = currentLoc[1] + currentFacing[1]
        currentLoc[3] = currentLoc[3] + currentFacing[2]
        writeToLog("281: Turtle at (" .. currentLoc[1] .. "," .. currentLoc[2] .. "," .. currentLoc[3] ..")")
        screenWriting("Turtle at x,y,z: " .. currentLoc[1] .. "," .. currentLoc[2] .. "," .. currentLoc[3])
        return true
    else
        return false
    end
end

-- moves one block backwards without trying to mine anything
-- returns false if it cant move
function moveWithoutMiningBack()
    -- just making sure that the turtle doesnt run off again
    if currentLoc[1]<-1 then
        writeToLog("270: Turtle went into -X area")
        os.exit()
    end
    if currentLoc[3]<-1 then
        writeToLog("270: Turtle went into -Z area")
        os.exit()
    end

    if turtle.back() then
        currentLoc[1] = currentLoc[1] - currentFacing[1]
        currentLoc[3] = currentLoc[3] - currentFacing[2]
        writeToLog("311: Turtle at (" .. currentLoc[1] .. "," .. currentLoc[2] .. "," .. currentLoc[3] ..")")
        screenWriting("Turtle at x,y,z: " .. currentLoc[1] .. "," .. currentLoc[2] .. "," .. currentLoc[3])
        return true
    else
        return false
    end
end

-- moves to x={xLoc} without mining a block
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
        moveWithoutMining()
    end
end

-- moves to y={yLoc} while mining anything that gets in its way
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

-- moves to z={zLoc} backwards without mining a block
-- returns true if it can move to that location
-- returns false if anything gets in the way
function moveBackToLocZ(zGoing)
    local lDist = math.abs(zGoing-currentLoc[3])

    if zGoing > currentLoc[3] then
        faceDirection(FaceBackwardFromStart)
    elseif zGoing < currentLoc[3] then
        faceDirection(FaceForwardFromStart)
    else
        return true
    end
    for distance = 1,lDist do
        moveWithoutMiningBack()
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
    if currentLoc[1]<-1 then
        writeToLog("263: Turtle went into -X area")
        os.exit()
    end
    if currentLoc[3]<-1 then
        writeToLog("267: Turtle went into -Z area")
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
end

function runSkylightProtocolAlpha()
    if currentLoc[1]%skyLightDistance==0 and currentLoc[3]%skyLightDistance==0 then
        currentY = currentLoc[2]
        moveToLocY(currentLoc[2]+isolatedFloorSize)
        moveToLocY(currentY)
    end
end

-- sets up the logic to mine in a square for each Y level
function squareLogic(sideLength)
    while currentLoc[1] ~= sideLength do --while x is not our length 
        while currentLoc[3] ~= (sideLength-1) do -- while z is not our length
            faceDirection(FaceForwardFromStart)
            mineForward()
            if skyLights then
                runSkylightProtocolAlpha()
            end
        end

        if currentLoc[1] == sideLength-1 and currentLoc[3] == sideLength-1 then
            break
        end

        moveBackToLocZ(0)

        -- turning code here
        if(currentLoc[1]~=sideLength-1) then -- as long as where we are is not the final x location
            faceDirection(FaceRightFromStart)
            mineForward()
            if skyLights then
                runSkylightProtocolAlpha()
            end
            faceDirection(FaceForwardFromStart)
        end
    end

    moveToLocX(0)
    moveToLocZ(0)
end

-- sets up the logic to mine a square, then change Y, and mine the next square
-- 5, 3, 3
function devastate(length, height, yStart)
    local yCurrent = 0
    while yCurrent<height do
        -- first make sure we are on the correct Y level
        writeToLog("509: length, height, yStart (" .. length .. "," .. height .. "," .. yStart .. ")")
        if goingUp then
            while currentLoc[2]<yCurrent+yStart do
                if goUp() then
                    turtle.digUp()
                end
            end
        else
            writeToLog("517: currentLoc[y]>math (" .. currentLoc[2] .. "," .. (yCurrent+yStart)*-1 .. ")")
            while currentLoc[2]>(yCurrent*-1+yStart) do
                if goDown() then
                    turtle.digDown()
                end
            end
        end

        -- then call squareLogic to mine out that level
        squareLogic(length)
        yCurrent = yCurrent + 3
    end
    writeToLog("---------------------------------------------")
    writeToLog("529: End of a devastate")
    writeToLog("---------------------------------------------")
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

 function makeFloor()
    if goingUp then
        ud = 1
    else
        ud=-1
    end
    for numberOfFloors = 0,floors-1 do -- do this for each floor
        local times = 0
--          5 floors, 4,
            writeToLog("555: going to Y (" .. (numberOfFloors*isolatedFloorSize*ud) .. ")")
            writeToLog("556: numberOfFloors,isolatedFloorSize,ud  (" .. numberOfFloors .. "," .. isolatedFloorSize .. "," .. ud .. ")")
            devastate(sides, fullPasses*3, numberOfFloors*isolatedFloorSize*ud) -- once this is done running, we are at the Y of the floor +1, and most of the area is cleared (all if a multiple of three)
            writeToLog("558: partialQuarrying(" .. partialQuarrying .. ")")
            if partialQuarrying>0 then
                writeToLog("560: going to Y (" .. ((numberOfFloors*isolatedFloorSize+partialQuarrying+fullPasses*3)*ud) .. ")")
                writeToLog("561: numberOfFloors,isolatedFloorSize,ud,partialQuarrying,fullPasses  (" .. numberOfFloors .. "," .. isolatedFloorSize .. "," .. ud .. "," .. partialQuarrying .. "," .. fullPasses .. ")")
                devastate(sides, 1, (numberOfFloors*isolatedFloorSize+partialQuarrying+(fullPasses-1)*3)*ud) 
                -- 0,8,1,2,1   - 0 + 2 + 3
            end

            times = times + 1
--        end


    end

    moveToLocX(0)
    moveToLocZ(0)
    moveToLocY(0)
    returnToBase()
    faceDirection(FaceForwardFromStart)
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
makeFloor()

--[[ os.sleep(5)
faceDirection(FaceRightFromStart)
os.sleep(5)
faceDirection(FaceLeftFromStart)
os.sleep(5)
faceDirection(FaceBackwardFromStart)
os.sleep(5)
faceDirection(FaceForwardFromStart) ]]

