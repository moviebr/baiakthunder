local tier = {
{                    --tier1
{id =2120 , chance = 10, count = 1}, --rope
{id =2554 , chance = 5, count = 1}, --shovel
{id =1991 , chance = 10, count = 1}, --bag
{id =1998 , chance = 5, count = 1}, --backpack
{id =2376 , chance = 10, count = 1}, --sword1
{id =2409 , chance = 5, count = 1}, --sword2
{id =2461 , chance = 10, count = 1}, --helmet1
{id =2458 , chance = 5, count = 1}, --helmet2
{id =2467 , chance = 10, count = 1}, --armor1
{id =2464 , chance = 5, count = 1}, --armor2
{id =2649 , chance = 10, count = 1}, --legs1
{id =2648 , chance = 5, count = 1}, --legs2
{id =2643 , chance = 10, count = 1}, --feet1
{id =2642 , chance = 5, count = 1}, --feet2
{id =2684 , chance = 20, count = 10}, --food1
{id =2689 , chance = 20, count = 10}, --food2
{id =2691 , chance = 20, count = 10}, --food3
{id =2677 , chance = 20, count = 20}, --food4
{id =2674 , chance = 20, count = 10}, --food5
{id =2386 , chance = 10, count = 1}, --axe1
{id =2441 , chance = 5, count = 1}, --axe2
{id =2437 , chance = 10, count = 1}, --club1
{id =2398 , chance = 5, count = 1}, --club2
{id =2190 , chance = 5, count = 1}, --wand1
{id =2191 , chance = 5, count = 1}, --wand2
{id =2456 , chance = 5, count = 1}, --bow1
{id =7438 , chance = 5, count = 1}, --bow2
{id =2512 , chance = 10, count = 1}, --shield1
{id =2529 , chance = 5, count = 1}, --shield2
{id =2331 , chance = 10, count = 10}, --rune1
{id =2313 , chance = 5, count = 10}, --rune2
{id =2544 , chance = 10, count = 10}, --ammo1
{id =2545 , chance = 5, count = 10}, --ammo2
{id =8704 , chance = 10, count = 1}, --potion1
{id =7618 , chance = 5, count = 1} --potion2
},
{                    --tier2
{id =2392 , chance = 10, count = 1}, --sword1
{id =7385 , chance = 5, count = 1}, --sword2
{id =2460 , chance = 10, count = 1}, --helmet1
{id =2480 , chance = 5, count = 1}, --helmet2
{id =2465 , chance = 10, count = 1}, --armor1
{id =2463 , chance = 5, count = 1}, --armor2
{id =2478 , chance = 10, count = 1}, --legs1
{id =2647 , chance = 5, count = 1}, --legs2
{id =11303 , chance = 10, count = 1}, --feet1
{id =7453 , chance = 5, count = 1}, --feet2
{id =2428 , chance = 10, count = 1}, --axe1
{id =2429 , chance = 5, count = 1}, --axe2
{id =2439 , chance = 10, count = 1}, --club1
{id =2423 , chance = 5, count = 1}, --club2
{id =2188 , chance = 5, count = 1}, --wand1
{id =8921 , chance = 5, count = 1}, --wand2
{id =8857 , chance = 5, count = 1}, --bow1
{id =8855 , chance = 5, count = 1}, --bow2
{id =2524 , chance = 10, count = 1}, --shield1
{id =2525 , chance = 5, count = 1}, --shield2
{id =2288 , chance = 10, count = 10}, --rune1
{id =2274 , chance = 5, count = 10}, --rune2
{id =7364 , chance = 10, count = 10}, --ammo1
{id =15648 , chance = 5, count = 10} --ammo2

}
}
function onUse(player, item, fromPosition, itemEx, toPosition, isHotkey)
    chesttier = math.floor(((item.actionid % 1000) + 100 ) / 200)
    if Game.getStorageValue(item:getActionId()) ~= 1 then
    for a=item:getSize()-1 , 0, -1 do
        item:getItem(i):remove() -- cleaning any old remaining items from previous games.
    end
    for i=1,20 do
        percentage = math.random(1,100)
        randomitem = math.random(1,#tier[chesttier])
            if percentage <= tier[chesttier][randomitem].chance then
            item:addItem(tier[chesttier][randomitem].id, math.random(1,tier[chesttier][randomitem].count))    --adding random item
            end
    end
    Game.setStorageValue(item:getActionId(), 1)
    end
end 