local positions = {
    [1] = Position(989, 1211, 7),
    [2] = Position(989, 1208, 7),
    [3] = Position(993, 1208, 7),
    [4] = Position(993, 1211, 7),
    [5] = Position(991, 1211, 7)
}
local shot = 29
local corrida = true

function onThink(interval)
    positions[1]:sendDistanceEffect(positions[2], shot)
    if corrida then
        positions[5]:sendDistanceEffect(positions[1], shot)
    end
    addEvent(function()
        positions[2]:sendDistanceEffect(positions[3], shot)
        if corrida then
            addEvent(function()
                positions[2]:sendDistanceEffect(positions[3], shot)
            end, 70)
        end
    end, 300)
    addEvent(function()
        positions[3]:sendDistanceEffect(positions[4], shot)
        if corrida then
            addEvent(function()
                positions[3]:sendDistanceEffect(positions[4], shot)
            end, 70)
        end
    end, 600)
    addEvent(function()
        positions[4]:sendDistanceEffect(positions[1], shot)
        if corrida then
            addEvent(function()
                positions[4]:sendDistanceEffect(positions[1], shot)
            end, 70)
        end
    end, 900)
   return true
end