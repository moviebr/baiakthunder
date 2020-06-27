local positions = {
    [1] = Position(989, 1211, 7),
    [2] = Position(989, 1208, 7),
    [3] = Position(993, 1208, 7),
    [4] = Position(993, 1211, 7)
}
local shot = 4


function onThink(interval)

    positions[1]:sendDistanceEffect(positions[4], shot)
    positions[3]:sendDistanceEffect(positions[2], shot)
    addEvent(function()
      positions[4]:sendDistanceEffect(positions[3], shot)
      positions[2]:sendDistanceEffect(positions[1], shot)
    end, 270)

    addEvent(function()
      positions[3]:sendDistanceEffect(positions[2], shot)
      positions[1]:sendDistanceEffect(positions[4], shot)
    end, 560)

    addEvent(function()
      positions[2]:sendDistanceEffect(positions[1], shot)
      positions[4]:sendDistanceEffect(positions[3], shot)
    end, 850)
    return true
end
