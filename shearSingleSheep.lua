--[[
    This program assums that there is a sheep directly in front of the turtle,
    an inventory directly behind the turtle and that the turtle has shears in slot 1.

    It will use 200 durability of the ~238 durability that shears have. you can then repair
        or replace the shears as needed.
]]
for i=1,200 do
    turtle.place()
    turtle.turnLeft()
    turtle.turnLeft()
    turtle.select(2)
    turtle.drop()
    turtle.turnLeft()
    turtle.turnLeft()
    turtle.select(1)
    os.sleep(300) -- 5 minutes
end