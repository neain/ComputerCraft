term.clear()
term.setCursorPos(1,1)
io.write("going [u]p or [d]own?")
isQuarry = io.read()

term.clear()
term.setCursorPos(1,1)
io.write("Length of a side: ")
sSize = io.read()
if sSize == nil then sSize = 16 end

term.clear()
term.setCursorPos(1,1)
if string.lower(isQuarry) == "u" 
then 
    io.write("How far up?: ")
else 
    io.write("How far down?: ") 
end
yDisp = io.read()

function screenWriting(screenText)
    term.clear()
    term.setCursorPos(1,1)
    io.write(screenText)
    term.setCursorPos(1,2)
    io.write("Going to Y: " .. yDisp)
    term.setCursorPos(1,3)
    io.write("Square size: " .. sSize)
    term.setCursorPos(1,4)
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
local sides, depth = tonumber(sSize), tonumber(yDisp) -- length of the sides, how far down or up. This is a variable so that that when testing I can change it to constants and not enter the data each time
-- local sides, depth = 5, 5

local goingUp
if string.lower(isQuarry) == "u" then 
    goingUp = true
else 
    goingUp = false 
end


----------------------------
-- 'Global' Variables End --
----------------------------


---------------------
-- Functions Start --
---------------------

function checkForOre()
    
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
-------------------
-- Functions End --
-------------------

-----------------------------
-- Running Code Below Here --
-----------------------------

