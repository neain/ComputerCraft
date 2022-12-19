--[[
    This program assums that there is a sheep directly in front of the turtle,
    an inventory directly behind the turtle and that the turtle has shears in slot 1.

    It will use 200 durability of the ~238 durability that shears have. you can then repair
        or replace the shears as needed.
]]
for i=1,200 do
    turtle.place()
    turtle.drop()
    os.sleep(5) -- seconds
end