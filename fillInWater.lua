function fillInWater()
    local water=false
    local junkData, blockData = turtle.detect()
    while blockData.name == "minecraft:water" do
        turtle.select(16)
        turtle.place()
        junkData, blockData = turtle.detect()
    end
    select(1)
end
