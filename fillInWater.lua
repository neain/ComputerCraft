-- variables that shouldnt need to be variables, but are so that debugging things is easier
local invSize = 14


function checkForWaterAndLava()
    local water=false
    local junkData, blockData = turtle.detectDown()
    while blockData.name == "minecraft:water" or blockData.name == "minecraft:lava" do
        for i=1,invSize do
            turtle.select(i)
            local itemJunk = turtle.getItemData()
        end
        turtle.select(16)
        turtle.place()
        junkData, blockData = turtle.detect()
    end
    select(1)
end
