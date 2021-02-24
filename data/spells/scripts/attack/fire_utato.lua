local animationDelay = 200
local combat = {}

local area = {
    {
        {0, 1, 0},
        {1, 2, 1},
        {0, 1, 0}
    },
    {
        {1, 0, 1},
        {0, 2, 0},
        {1, 0, 1}
    },
    {
        {0, 1, 1, 1, 0},
        {1, 0, 0, 0, 1},
        {1, 0, 2, 0, 1},
        {1, 0, 0, 0, 1},
        {0, 1, 1, 1, 0}
    }
}

for i = 1, #area do
    combat[i] = Combat()
    combat[i]:setParameter(COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
    combat[i]:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_FIREAREA)
end

for x, _ in ipairs(area) do
    combat[x]:setArea(createCombatArea(area[x]))
end

function executeCombat(p, i)
    if not p.player then
        return false
    end
    if not p.player:isPlayer() then
            return false
    end
    p.combat[i]:execute(p.player, p.var)
end

function onCastSpell(player, var)

    local p = {player = player, var = var, combat = combat}

    local level = player:getLevel()
    local maglevel = player:getMagicLevel()
    local min = (level / 5) + (maglevel * 1.4) + 8
    local max = (level / 5) + (maglevel * 2.2) + 14

    for i = 1, #area do
        combat[i]:setFormula(COMBAT_FORMULA_LEVELMAGIC, 0, -min, 0, -max)
        if i == 1 then
            combat[i]:execute(player, var)
        else
            addEvent(executeCombat, (animationDelay * i) - animationDelay, p, i)
        end
    end

    return true
end