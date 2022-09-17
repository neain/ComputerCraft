--[[
Informaion: This is going to move forward and place a block beneath itself. 
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

function screenWriting(screenText)
    term.clear()
    term.setCursorPos(1,1)
    io.write(screenText)
    term.setCursorPos(1,2)
    io.write("Fuel Left: " .. turtle.getFuelLevel())
    
end

bridgeDistance = 64
for bridgeDistance=0,64 do
    screenWriting("Moved: " .. bridgeDistance)
    if turtle.forward() then
        turtle.placeDown()
    else
        for goBack=0, bridgeDistance do
            turtle.back()
        end
        return
    end

end

for goBack=0, 64 do
    turtle.back()
end