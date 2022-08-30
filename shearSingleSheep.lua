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