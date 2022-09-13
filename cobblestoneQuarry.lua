--[[
Informaion: This is going to mine a block every 5 seconds and deposit it UP
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

while true do
    turtle.dig()
    if not turtle.dropUp() then
        os.sleep(3600) -- 60 minutes
    end
    os.sleep(5) -- 5 seconds
end