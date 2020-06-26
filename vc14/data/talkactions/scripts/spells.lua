function onSay(player, words, param)
    local text = {}
    local spells = {}
    for _, spell in ipairs(player:getInstantSpells()) do
        if spell.level ~= 0 then
            if spell.manapercent > 0 then
                spell.mana = spell.manapercent .. "%"
            end
            spells[#spells + 1] = spell
        end
    end

    table.sort(spells, function(a, b) return a.level < b.level end)

    local prevLevel = -1
    for i, spell in ipairs(spells) do
        if prevLevel ~= spell.level then
            if i == 1 then
                text[#text == nil and 1 or #text+1] = "- Spells para Level "
            else
                text[#text+1] = "\n- Spells para Level "
            end
            text[#text+1] = spell.level .. "\n"
            prevLevel = spell.level
        end
        text[#text+1] = " - " .. spell.words .. " - " .. spell.mana .. "\n"
    end

    player:showTextDialog(2175, table.concat(text))
    return false
end