local positions = {
    [1] = Position(989, 1211, 7),
    [2] = Position(989, 1208, 7),
    [3] = Position(993, 1208, 7),
    [4] = Position(993, 1211, 7),
}
local shot = 31

function onThink(interval)
    positions[1]:sendDistanceEffect(positions[2], shot)
    addEvent(function()
        positions[2]:sendDistanceEffect(positions[3], shot)
    end, 300)
    addEvent(function()
        positions[3]:sendDistanceEffect(positions[4], shot)
    end, 600)
    addEvent(function()
        positions[4]:sendDistanceEffect(positions[1], shot)
    end, 900)
   return true
end