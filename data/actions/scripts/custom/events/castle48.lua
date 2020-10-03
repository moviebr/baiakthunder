function onUse(player, item, fromPosition, target, toPosition, isHotkey)

  local guild = player:getGuild()

  if not guild then
    player:teleportTo(player:getTown():getTemplePosition())
    player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
    Castle48H:deletePlayer(player:getId())
    return true
  end

  if Game.getStorageValue(Castle48H.storageLever) == guild:getId() then
    player:sendCancelMessage(Castle48H.msg.prefix .. Castle48H.msg.alreadyOwner)
    player:getPosition():sendMagicEffect(CONST_ME_POFF)
    return true
  end

  Game.broadcastMessage(Castle48H.msg.prefix .. Castle48H.msg.nowOwner:format(guild:getName()))
  Castle48H.useLever(guild:getId())
  player:getPosition():sendMagicEffect(CONST_ME_FIREAREA)

  return true
end
