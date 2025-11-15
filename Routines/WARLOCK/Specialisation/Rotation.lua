-- 获取常用单位
local player = Aurora.UnitManager:Get("player")
local target = Aurora.UnitManager:Get("target")

-- 获取技能书（对应Spellbook注册的命名空间和专精）
local spells = Aurora.SpellHandler.Spellbooks.warlock["3"].RoyWarlock.spells
local auras = Aurora.SpellHandler.Spellbooks.warlock["3"].RoyWarlock.auras
local talents = Aurora.SpellHandler.Spellbooks.warlock["3"].RoyWarlock.talents

-- 战斗前动作（仅非伤害性技能）
local function PreCombat()

end

-- 冷却技能列表（按顺序执行）
local function Cooldowns()
    -- actions.cooldowns+=/blood_fury（兽人种族技能）
    if spells.blood_fury:isknown() and spells.blood_fury:ready() and spells.blood_fury:castable(player) then
        spells.blood_fury:cast(player)
        return true
    end

    -- actions.cooldowns+=/berserking（巨魔种族技能）
    if spells.berserking:isknown() and spells.berserking:ready() and spells.berserking:castable(player) then
        spells.berserking:cast(player)
        return true
    end

    -- actions.cooldowns+=/fireblood（火焰之血种族技能）
    if spells.fireblood:isknown() and spells.fireblood:ready() and spells.fireblood:castable(player) then
        spells.fireblood:cast(player)
        return true
    end

    -- actions.cooldowns+=/ancestral_call（先祖召唤种族技能）
    if spells.ancestral_call:isknown() and spells.ancestral_call:ready() and spells.ancestral_call:castable(player) then
        spells.ancestral_call:cast(player)
        return true
    end

    -- actions.cooldowns+=/summon_infernal
    if spells.summon_infernal:isknown() and spells.summon_infernal:ready() and spells.summon_infernal:castable(player) then
        spells.summon_infernal:cast(target)
        return true
    end

    return false
end

-- 辅助战斗技能列表（按优先级顺序执行）
local function AssistedCombat()
    -- actions.assisted_combat=grimoire_of_sacrifice,if=pet.any.active&buff.grimoire_of_sacrifice.down
    local petActive = Aurora.UnitManager:Get("pet").exists
    local sacrificeBuffDown = not player.aura(auras.grimoire_of_sacrifice_buff.spellId)
    if petActive and sacrificeBuffDown and spells.grimoire_of_sacrifice:isusable() then
        spells.grimoire_of_sacrifice:cast(player)
        return true
    end

    -- actions.assisted_combat+=/cataclysm
    if spells.cataclysm:isusable() and spells.cataclysm:getcd() <= 0 and target.distanceto(player) <= 40 then
        spells.cataclysm:cast(target)
        return true
    end

    -- actions.assisted_combat+=/wither,if=!dot.immolate.ticking&!talent.wither
    local noImmolateDot = not target.aura(auras.immolate.spellId)
    local noWitherTalent = not talents.wither:isknown()
    if noImmolateDot and noWitherTalent and spells.wither:isusable() then
        spells.wither:cast(target)
        return true
    end

    -- actions.assisted_combat+=/wither,if=!dot.wither.ticking&talent.wither
    local noWitherDot = not target.aura(auras.wither_dot.spellId)
    local hasWitherTalent = talents.wither:isknown()
    if noWitherDot and hasWitherTalent and spells.wither:isusable() then
        spells.wither:cast(target)
        return true
    end

    -- actions.assisted_combat+=/infernal_bolt,if=buff.infernal_bolt.up&buff.infernal_bolt.remains<=5
    local infernalBoltUp = player.aura(auras.infernal_bolt_buff.spellId)
    local infernalBoltRemains = infernalBoltUp and player.auraremains(auras.infernal_bolt_buff.spellId) or 0
    if infernalBoltUp and infernalBoltRemains <= 5 and spells.infernal_bolt:isusable() then
        spells.infernal_bolt:cast(target)
        return true
    end

    -- actions.assisted_combat+=/incinerate,if=buff.infernal_bolt.up&buff.infernal_bolt.remains<=5
    if infernalBoltUp and infernalBoltRemains <= 5 and spells.incinerate:isusable() then
        spells.incinerate:cast(target)
        return true
    end

    -- actions.assisted_combat+=/malevolence
    if spells.malevolence:isusable() and spells.malevolence:getcd() <= 0 then
        spells.malevolence:cast(target)
        return true
    end

    -- actions.assisted_combat+=/channel_demonfire,if=target.distance<=40
    if target.distanceto(player) <= 40 and spells.channel_demonfire:isusable() then
        spells.channel_demonfire:cast(target)
        return true
    end

    -- actions.assisted_combat+=/rain_of_fire,if=active_enemies>3（8码范围内敌人数量）
    local activeEnemies = player.enemiesaround(8)
    if activeEnemies > 3 and spells.rain_of_fire:isusable() then
        spells.rain_of_fire:cast(target)
        return true
    end

    -- actions.assisted_combat+=/soul_fire,if=buff.decimation.up&soul_shard<=4
    local decimationUp = player.aura(auras.decimation.spellId)
    local soulShardCount = player.soulshards or 0
    if decimationUp and soulShardCount <= 4 and spells.soul_fire:isusable() then
        spells.soul_fire:cast(target)
        return true
    end

    -- actions.assisted_combat+=/shadowburn,if=active_enemies<=2
    if activeEnemies <= 2 and spells.shadowburn:isusable() and spells.shadowburn:getcd() <= 0 then
        spells.shadowburn:cast(target)
        return true
    end

    -- actions.assisted_combat+=/conflagrate,if=buff.backdraft.down&soul_shard>=1.5&active_enemies<=2
    local backdraftDown = not player.aura(auras.backdraft.spellId)
    if backdraftDown and soulShardCount >= 1.5 and activeEnemies <= 2 and spells.conflagrate:isusable() then
        spells.conflagrate:cast(target)
        return true
    end

    -- actions.assisted_combat+=/ruination,if=active_enemies<=2&soul_shard>=4,cooldown_allow_casting_success=1
    if activeEnemies <= 2 and soulShardCount >= 4 and spells.ruination:isusable() and spells.ruination:getcd() <= 0 then
        spells.ruination:cast(target)
        return true
    end

    -- actions.assisted_combat+=/chaos_bolt,if=active_enemies<=2&soul_shard>=4,cooldown_allow_casting_success=1
    if activeEnemies <= 2 and soulShardCount >= 4 and spells.chaos_bolt:isusable() and spells.chaos_bolt:getcd() <= 0 then
        spells.chaos_bolt:cast(target)
        return true
    end

    -- actions.assisted_combat+=/ruination,if=active_enemies<=2&soul_shard>=2&buff.ritual_of_ruin.up
    local ritualOfRuinUp = player.aura(auras.ritual_of_ruin.spellId)
    if activeEnemies <= 2 and soulShardCount >= 2 and ritualOfRuinUp and spells.ruination:isusable() then
        spells.ruination:cast(target)
        return true
    end

    -- actions.assisted_combat+=/chaos_bolt,if=active_enemies<=2&soul_shard>=2&buff.ritual_of_ruin.up
    if activeEnemies <= 2 and soulShardCount >= 2 and ritualOfRuinUp and spells.chaos_bolt:isusable() then
        spells.chaos_bolt:cast(target)
        return true
    end

    -- actions.assisted_combat+=/ruination,if=active_enemies<=2
    if activeEnemies <= 2 and spells.ruination:isusable() then
        spells.ruination:cast(target)
        return true
    end

    -- actions.assisted_combat+=/chaos_bolt,if=active_enemies<=2
    if activeEnemies <= 2 and spells.chaos_bolt:isusable() then
        spells.chaos_bolt:cast(target)
        return true
    end

    -- actions.assisted_combat+=/dimensional_rift
    if spells.dimensional_rift:isusable() and spells.dimensional_rift:getcd() <= 0 then
        spells.dimensional_rift:cast(target)
        return true
    end

    -- actions.assisted_combat+=/infernal_bolt,if=buff.backdraft.stack>=2
    local backdraftStack = player.auracount(auras.backdraft.spellId) or 0
    if backdraftStack >= 2 and spells.infernal_bolt:isusable() then
        spells.infernal_bolt:cast(target)
        return true
    end

    -- actions.assisted_combat+=/incinerate,if=buff.backdraft.stack>=2
    if backdraftStack >= 2 and spells.incinerate:isusable() then
        spells.incinerate:cast(target)
        return true
    end

    -- actions.assisted_combat+=/conflagrate,if=charges>=2
    local conflagrateCharges = spells.conflagrate:charges() or 0
    if conflagrateCharges >= 2 and spells.conflagrate:isusable() then
        spells.conflagrate:cast(target)
        return true
    end

    -- actions.assisted_combat+=/infernal_bolt,cooldown_allow_casting_success=1
    if spells.infernal_bolt:isusable() and spells.infernal_bolt:getcd() <= 0 then
        spells.infernal_bolt:cast(target)
        return true
    end

    -- actions.assisted_combat+=/incinerate,cooldown_allow_casting_success=1
    if spells.incinerate:isusable() and spells.incinerate:getcd() <= 0 then
        spells.incinerate:cast(target)
        return true
    end

    -- actions.assisted_combat+=/infernal_bolt
    if spells.infernal_bolt:isusable() then
        spells.infernal_bolt:cast(target)
        return true
    end

    -- actions.assisted_combat+=/incinerate
    if spells.incinerate:isusable() then
        spells.incinerate:cast(target)
        return true
    end

    return false
end

-- 注册循环
Aurora:RegisterRoutine(function()
    -- 跳过死亡、进食、饮水状态
    if player.dead or player.ishumanoid or player.isdrinking then
        return
    end

    -- 战斗前逻辑
    if not player.combat then
        if PreCombat() then
            return
        end
    end

    -- 战斗中逻辑：先执行冷却技能，再执行辅助战斗技能
    if player.combat then
        if Cooldowns() then
            return
        end
        if AssistedCombat() then
            return
        end
    end
end, "WARLOCK", 1, "WarlockRotation") -- 对应专精ID和命名空间
