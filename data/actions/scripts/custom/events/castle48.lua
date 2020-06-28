function onUse(player, item, fromPosition, target, toPosition, isHotkey)

  local playerGuildId = player:getGuild():getId()
  local retorno = Castle48H:useLever(playerGuildId)

  if Game.getStorageValue(Castle48H.storageGuildLever) == playerGuildId then
    player:sendCancelMessage(Castle48H.msg.prefix .. Castle48H.msg.alreadyOwner)
    player:getPosition():sendMagicEffect(CONST_ME_POFF)
    return true
  end

  if Game.getStorageValue(Castle48H.storageGlobal) ~= 1 then
    player:sendCancelMessage(Castle48H.msg.prefix .. Castle48H.msg.notOpen)
    player:teleportTo(player:getTown():getTemplePosition())
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
  else
    Castle48H:useLever(playerGuildId)
    Game.broadcastMessage(Castle48H.msg.prefix .. Castle48H.msg.nowOwner:format(player:getGuild():getName()))
    player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
    Game.setStorageValue(Castle48H.storageGuildLever, playerGuildId)
  end

    return true
end
