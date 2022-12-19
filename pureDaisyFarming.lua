--[[
    This program will mine out and replace pure daisy stuff both below and above.
]]
function upDownTurnRight()
    turtle.forward()
    turtle.digUp()
    turtle.placeUp()
    turtle.digDown()
    turtle.placeDown()
    turtle.forward()
    turtle.digUp()
    turtle.placeUp()
    turtle.digDown()
    turtle.placeDown()
    turtle.turnRight()
end

for j=1,200 do
    turtle.suckUp(16)
    turtle.forward()
    upDownTurnRight()
    upDownTurnRight()
    upDownTurnRight()
    upDownTurnRight()
    turtle.back()
    turtle.select(2)
    turtle.drop()
    turtle.select(1)
end
