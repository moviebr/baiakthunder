local boss = Action()

local config = {
  towerPos = {
    [1] = Position(955, 1445, 8),
    [2] = Position(943, 1445, 8),
  },
  towerName = "Boss Tower",
  bossName = "Drogorion",
  bossPosition = Position(949, 1445, 8),
}

function boss.onUse(player, item, fromPosition, target, toPosition, isHotkey)
  
  if player:getStorageValue(97134) < 1 then
    return false
  end

  player:setStorageValue(97134, -1)
  player:getPosition():sendMagicEffect(7)
  Game.broadcastMessage("Tssss!")
  addEvent(Game.broadcastMessage, 20 * 1000, "Gaaahhh!")
  addEvent(function()
    Game.broadcastMessage("Criaturas estranhas estão surgindo em Akravi!")
      for a, b in ipairs(config.towerPos) do
        Game.createMonster(config.towerName, b, false, true)
        b:sendMagicEffect(CONST_ME_TELEPORT)
      end
  end, 40 * 1000)
  addEvent(function()
    local boss = Game.createMonster(config.bossName, config.bossPosition, false, true)
    boss:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
    Game.broadcastMessage("O jogador ".. player:getName() .. " libertou o boss em Akravi!")
  end, 50 * 1000)

  addEvent(function()
    local spectator = Game.getSpectators(Position(949, 1444, 8), false, false, 0, 10, 0, 4)
    if #spectator > 0 then
      for a, b in ipairs(spectator) do
        local creature = Creature(b)
          if creature:isMonster() then
            creature:getPosition():sendMagicEffect(CONST_ME_POFF)
            creature:remove()
          end
      end
    end
  end, 30 * 60 * 1000)

  return false
end

boss:aid(3781)
boss:register()