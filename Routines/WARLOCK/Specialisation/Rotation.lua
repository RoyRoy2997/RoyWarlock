-- 获取常用单位

local player = Aurora.UnitManager:Get("player")

local target = Aurora.UnitManager:Get("target")

local pet = Aurora.UnitManager:Get("pet")



-- 获取技能书（对应Spellbook注册的命名空间和专精）

local spells = Aurora.SpellHandler.Spellbooks.warlock["3"].RoyWarlock.spells

local auras = Aurora.SpellHandler.Spellbooks.warlock["3"].RoyWarlock.auras

local talents = Aurora.SpellHandler.Spellbooks.warlock["3"].RoyWarlock.talents



-- 【新增】版本信息

local ROTATION_VERSION = "1.6.0"



-- 【新增】药水定义

local potions = {

    burst_3star = Aurora.ItemHandler.NewItem(212265), -- 淬火药水3星

    burst_2star = Aurora.ItemHandler.NewItem(212264), -- 淬火药水2星

    burst_1star = Aurora.ItemHandler.NewItem(212263), -- 淬火药水1星

    heal_3star = Aurora.ItemHandler.NewItem(244839),  -- 焕生治疗药水3星

    heal_2star = Aurora.ItemHandler.NewItem(244838),  -- 焕生治疗药水2星

    heal_1star = Aurora.ItemHandler.NewItem(244835),  -- 焕生治疗药水1星

    heal_Tang = Aurora.ItemHandler.NewItem(224464)    -- 治疗石

}



-- 战斗数据统计

local combatStats = {

    startTime = 0,

    totalDamage = 0,

    interrupts = 0,

    reflects = 0,

    lastReset = 0

}



-- 【新增】随机数生成器

local random = math.random

local lastRandomInterruptTime = 0

local randomInterruptDelay = 0



-- 技能使用冷却跟踪

local skillCooldowns = {

    spell_lock = 0,

}



-- ===== 新增：拉怪补DOT模式全局变量 =====

local prepullDotMode = {

    isEnabled = false, -- 模式是否开启

    startTime = 0,     -- 模式开启时间戳

    autoCloseTime = 5  -- 自动关闭时间（5秒）

}



-- 【新增】灵魂石战复相关变量

local soulstoneTargetTime = 0

local soulstoneTargetGuid = nil



-- 【新增】枯萎补dot目标跟踪

local witherRefreshTarget = nil



-- 【新增】宠物召唤延迟跟踪

local lastDismountTime = 0

local petSummonDelay = 1.0 -- 1秒延迟



-- 【修复】配置获取函数 - 确保设置页面选项正确生效

local function GetConfig(key, default)
    local value = Aurora.Config:Read("RoyWarlock." .. key)

    if value == nil then
        return default
    end

    return value
end



-- 【新增】TimeToDieRR函数 - 按照您提供的代码翻译成Aurora框架版本

local function TimeToDieRR(unit, percentage)
    percentage = percentage or 0

    if not unit.exists then return 0 end



    -- 检查是否是玩家或训练假人

    if unit.player or unit.isdummy then return 8888 end



    -- 计算目标血量（考虑百分比）

    local health = unit.health - (unit.healthmax / 100 * percentage)

    if health < 1 then return 0 end



    local CDRS1 = 1.0                     -- 血量修正

    local CDRS2 = 1.0                     -- 攻击力修正

    local prmh = player.healthmax * CDRS1 -- 玩家最大血量 * 修正



    -- 获取40码内活着的队友数量

    local active_heal_40y = 0

    Aurora.friends:within(40):each(function(friend)
        if friend.alive and friend.ishealer then
            active_heal_40y = active_heal_40y + 1
        end
    end)



    local pahn = active_heal_40y * 0.75 -- 团队输出系数

    local loss = prmh * math.max(pahn, CDRS2)



    -- 计算时间（8秒干死同血量怪）

    return math.min(math.max(health / loss * 8, Aurora.gcd()), 8888)
end



-- 【修改】状态栏检查函数 - 修复状态栏控制

local function IsToggleEnabled(toggleName)
    if not Aurora.Rotation then return true end

    if not Aurora.Rotation[toggleName] then return true end

    return Aurora.Rotation[toggleName]:GetValue()
end



-- 【修改】宠物存在判断函数 - 增加延迟机制

local function HasActivePet()
    -- 如果玩家刚下坐骑，等待延迟时间

    if GetTime() - lastDismountTime < petSummonDelay then
        return true -- 在延迟期间认为宠物存在，避免立即召唤
    end

    return pet and pet.exists
end



-- 检查技能冷却

local function IsSkillOnCooldown(skillName)
    return skillCooldowns[skillName] and GetTime() < skillCooldowns[skillName]
end



-- 设置技能冷却

local function SetSkillCooldown(skillName, duration)
    skillCooldowns[skillName] = GetTime() + duration
end



-- 打断状态跟踪表

local interruptTracker = {}

local lastInterruptTime = 0



-- 【修改】智能打断系统 - 修复配置读取

local function SmartInterrupts()
    -- 检查打断状态栏是否启用

    if not IsToggleEnabled("InterruptToggle") then
        return false
    end



    local currentTime = GetTime()



    -- 检查法术锁定冷却

    if IsSkillOnCooldown("spell_lock") then
        return false
    end



    -- 随机延迟机制：防止固定节奏的打断

    if currentTime - lastRandomInterruptTime < randomInterruptDelay then
        return false
    end



    -- 使用Aurora框架维护的打断列表

    local interruptList = Aurora.Lists.InterruptSpells or {}



    -- 优先级1：检查焦点目标

    local focusTarget = Aurora.UnitManager:Get("focus")

    if focusTarget and focusTarget.exists and focusTarget.casting and focusTarget.castinginterruptible then
        local castId = focusTarget.castingspellid

        if interruptList[castId] then
            if spells.spell_lock:cast(focusTarget) then
                lastRandomInterruptTime = currentTime

                randomInterruptDelay = random(0.5, 1.5) -- 随机延迟0.5-1.5秒

                SetSkillCooldown("spell_lock", 24)

                return true
            end
        end
    end



    -- 优先级2：扫描附近所有敌人

    local enemiesCastingDangerous = {}



    Aurora.enemies:within(15):each(function(enemy)
        if enemy.exists and enemy.casting and enemy.castinginterruptible and enemy.combat then
            local castId = enemy.castingspellid

            if interruptList[castId] then
                table.insert(enemiesCastingDangerous, enemy)
            end
        end
    end)



    -- 如果有符合条件的敌人，使用法术锁定打断第一个

    if #enemiesCastingDangerous >= 1 then
        local firstDangerousEnemy = enemiesCastingDangerous[1]

        if firstDangerousEnemy then
            local success = spells.spell_lock:cast(firstDangerousEnemy)

            if success then
                lastRandomInterruptTime = currentTime

                randomInterruptDelay = random(0.5, 1.5)

                SetSkillCooldown("spell_lock", 24)

                return true
            end
        end
    end



    -- 优先级3：检查当前目标

    if target and target.exists and target.casting and target.castinginterruptible then
        local castId = target.castingspellid

        if interruptList[castId] then
            if spells.spell_lock:cast(target) then
                lastRandomInterruptTime = currentTime

                randomInterruptDelay = random(0.5, 1.5)

                SetSkillCooldown("spell_lock", 24)

                return true
            end
        end
    end



    return false
end



-- 【修改】硬控打断系统 - 增加死亡缠绕选项

local function HardControlInterrupts()
    -- 检查硬控状态栏是否启用

    if not IsToggleEnabled("HardControlToggle") then
        return false
    end



    local currentTime = GetTime()



    -- 检查硬控技能冷却

    if IsSkillOnCooldown("Shadowfury") and IsSkillOnCooldown("Mortal_Coil") then
        return false
    end



    -- 随机延迟机制

    if currentTime - lastRandomInterruptTime < randomInterruptDelay then
        return false
    end



    local interruptList = Aurora.Lists.InterruptSpells or {}

    local enemiesCastingDangerous = {}



    -- 收集附近正在施放危险技能的敌人

    Aurora.enemies:within(40):each(function(enemy)
        if enemy.exists and enemy.casting and enemy.castinginterruptible and enemy.combat then
            local castId = enemy.castingspellid

            if interruptList[castId] then
                table.insert(enemiesCastingDangerous, enemy)
            end
        end
    end)



    -- 群体硬控：暗影之怒

    if #enemiesCastingDangerous >= 2 and not IsSkillOnCooldown("Shadowfury") then
        if spells.Shadowfury and spells.Shadowfury:ready() then
            if spells.Shadowfury:smartaoe(player, {

                    offsetMin = 0,

                    offsetMax = 40,

                    filter = function(unit, distance, position)
                        return unit.enemy and unit.alive
                    end

                })

            then
                lastRandomInterruptTime = currentTime

                randomInterruptDelay = random(1, 2)

                SetSkillCooldown("Shadowfury", 60)

                return true
            end
        end
    end



    -- 【新增】单体硬控：死亡缠绕

    if GetConfig("use_mortal_coil_interrupt", true) and not IsSkillOnCooldown("Mortal_Coil") then
        if spells.Mortal_Coil and spells.Mortal_Coil:ready() then
            -- 优先打断当前目标

            if target and target.exists and target.casting and target.castinginterruptible then
                local castId = target.castingspellid

                if interruptList[castId] then
                    if spells.Mortal_Coil:cast(target) then
                        lastRandomInterruptTime = currentTime

                        randomInterruptDelay = random(1, 2)

                        SetSkillCooldown("Mortal_Coil", 45)

                        return true
                    end
                end
            end



            -- 打断其他危险目标

            for _, enemy in ipairs(enemiesCastingDangerous) do
                if spells.Mortal_Coil:castable(enemy) then
                    if spells.Mortal_Coil:cast(enemy) then
                        lastRandomInterruptTime = currentTime

                        randomInterruptDelay = random(1, 2)

                        SetSkillCooldown("Mortal_Coil", 45)

                        return true
                    end
                end
            end
        end
    end



    return false
end



-- 【修改】基础减伤技能链（仅与血量挂钩）

local function BasicDefensiveChain()
    if not IsToggleEnabled("DefensiveToggle") then return false end



    local darkPactHealth = GetConfig("dark_pact_health", 40)

    local unendingResolveHealth = GetConfig("unending_resolve_health", 20)

    local mortalcoilhealth = GetConfig("mortal_coil_health", 60)



    -- 极度危险状态 - 使用不灭决心

    if player.hp < unendingResolveHealth then
        if spells.Unending_Resolve:ready() and spells.Unending_Resolve:castable(player) then
            return spells.Unending_Resolve:cast(player)
        end
    end



    -- 一般危险状态 - 使用暗影契约

    if player.hp < darkPactHealth then
        if spells.Dark_Pact:ready() and spells.Dark_Pact:castable(player) then
            return spells.Dark_Pact:cast(player)
        end
    end



    -- 最简单危险状态 - 使用死亡缠绕

    if player.hp < mortalcoilhealth then
        if spells.Mortal_Coil:ready() and spells.Mortal_Coil:castable(target) then
            return spells.Mortal_Coil:cast(target)
        end
    end



    return false
end



-- 【修复】宠物召唤管理 - 确保配置正确生效

local function PetManagement()
    -- 检查是否启用自动召唤宠物

    if not GetConfig("auto_summon_pet", true) then
        return false
    end



    if HasActivePet() then return false end



    local selectedPet = GetConfig("selected_pet", "felhunter")



    -- 检查是否启用邪能统御

    if GetConfig("use_fel_domination", true) then
        if spells.Fel_Domination:ready() and spells.Fel_Domination:castable(player) then
            spells.Fel_Domination:cast(player)
        end
    end



    -- 根据设置召唤宠物

    if selectedPet == "imp" and spells.summon_imp:ready() and spells.summon_imp:castable(player) then
        return spells.summon_imp:cast(player)
    elseif selectedPet == "voidwalker" and spells.summon_voidwalker:ready() and spells.summon_voidwalker:castable(player) then
        return spells.summon_voidwalker:cast(player)
    elseif selectedPet == "sayaad" and spells.summon_Sayaad:ready() and spells.summon_Sayaad:castable(player) then
        return spells.summon_Sayaad:cast(player)
    elseif selectedPet == "felhunter" and spells.summon_felhunter:ready() and spells.summon_felhunter:castable(player) then
        return spells.summon_felhunter:cast(player)
    end



    return false
end



-- 【新增】牺牲魔典管理

local function GrimoireManagement()
    if talents.grimoire_of_sacrifice and talents.grimoire_of_sacrifice:isknown() then
        if not player.aura(auras.grimoire_of_sacrifice_buff.spellId) then
            if spells.grimoire_of_sacrifice:ready() and spells.grimoire_of_sacrifice:castable(player) then
                return spells.grimoire_of_sacrifice:cast(player)
            end
        end
    end

    return false
end



-- 【修改】药水使用管理 - 修复配置读取

local function SmartPotionUse()
    local potionMode = GetConfig("potion_mode", "infernal")



    -- 如果设置为"none"，则不使用药水

    if potionMode == "none" then
        return false
    end



    local healPotionHealth = GetConfig("heal_potion_health", 30)



    -- 治疗药水逻辑 - 按品质从高到低使用

    if player.hp < healPotionHealth then
        local healPotions = { potions.heal_3star, potions.heal_2star, potions.heal_1star, potions.heal_Tang }

        for _, potion in ipairs(healPotions) do
            if potion:isknown() and potion:count() > 0 then
                if potion:use(player) then
                    return true
                end
            end
        end
    end



    -- 爆发药水逻辑 - 按品质从高到低使用

    if potionMode == "infernal" then
        -- 地狱火召唤时使用爆发药水

        if spells.summon_infernal:waslastcast(3) then
            local burstPotions = { potions.burst_3star, potions.burst_2star, potions.burst_1star }

            for _, potion in ipairs(burstPotions) do
                if potion:isknown() and potion:count() > 0 then
                    if potion:use(player) then
                        return true
                    end
                end
            end
        end
    elseif potionMode == "cd" then
        -- 卡CD使用

        local burstPotions = { potions.burst_3star, potions.burst_2star, potions.burst_1star }

        for _, potion in ipairs(burstPotions) do
            if potion and potion:ready() and potion:usable(player) and potion:count() > 0 then
                if potion:use(player) then
                    return true
                end
            end
        end
    end



    return false
end



-- 【修改】饰品使用管理 - 修复配置读取

local function SmartTrinketUse()
    local trinketMode = GetConfig("trinket_mode", "infernal")



    -- 如果设置为"none"，则不使用饰品

    if trinketMode == "none" then
        return false
    end



    if trinketMode == "infernal" then
        -- 地狱火召唤时使用饰品

        if spells.summon_infernal:waslastcast(3) then
            -- 饰品1

            local trinket1ID = GetInventoryItemID("player", 13)

            if trinket1ID and trinket1ID > 0 then
                local trinket1 = Aurora.ItemHandler.NewItem(trinket1ID)

                if trinket1 and trinket1:ready() and trinket1:usable(player) then
                    if trinket1:use(player) then
                        return true
                    end
                end
            end



            -- 饰品2

            local trinket2ID = GetInventoryItemID("player", 14)

            if trinket2ID and trinket2ID > 0 then
                local trinket2 = Aurora.ItemHandler.NewItem(trinket2ID)

                if trinket2 and trinket2:ready() and trinket2:usable(player) then
                    return trinket2:use(player)
                end
            end
        end
    elseif trinketMode == "cd" then
        -- 卡CD使用饰品

        local trinket1ID = GetInventoryItemID("player", 13)

        if trinket1ID and trinket1ID > 0 then
            local trinket1 = Aurora.ItemHandler.NewItem(trinket1ID)

            if trinket1 and trinket1:ready() and trinket1:usable(player) then
                if trinket1:use(player) then
                    return true
                end
            end
        end



        local trinket2ID = GetInventoryItemID("player", 14)

        if trinket2ID and trinket2ID > 0 then
            local trinket2 = Aurora.ItemHandler.NewItem(trinket2ID)

            if trinket2 and trinket2:ready() and trinket2:usable(player) then
                return trinket2:use(player)
            end
        end
    end



    return false
end



-- 【修复】灵魂石战复功能

local function SoulstoneBattleRes()
    if not spells.Soulstone:ready() then
        return false
    end



    local currentTime = GetTime()

    local mouseoverUnit = Aurora.UnitManager:Get("mouseover")



    -- 检查鼠标指向的单位是否符合战复条件

    if mouseoverUnit and mouseoverUnit.exists then
        -- 使用Aurora框架的属性检查死亡状态

        if mouseoverUnit.dead and mouseoverUnit.player then
            -- 检查是否可以施放灵魂石

            if spells.Soulstone:castable(mouseoverUnit) then
                -- 开始或更新指向时间

                if soulstoneTargetGuid ~= mouseoverUnit.guid then
                    soulstoneTargetGuid = mouseoverUnit.guid

                    soulstoneTargetTime = currentTime

                    print("开始指向战复目标: " .. mouseoverUnit.name)
                else
                    -- 检查是否指向超过1.5秒

                    if currentTime > soulstoneTargetTime + 1.5 then
                        local success = spells.Soulstone:cast(mouseoverUnit)

                        if success then
                            print("成功对 " .. mouseoverUnit.name .. " 使用灵魂石战复")

                            soulstoneTargetGuid = nil

                            soulstoneTargetTime = 0
                        end

                        return success
                    end
                end
            end
        else
            -- 重置指向状态（如果指向了不符合条件的单位）

            if soulstoneTargetGuid and soulstoneTargetGuid ~= mouseoverUnit.guid then
                soulstoneTargetGuid = nil

                soulstoneTargetTime = 0
            end
        end
    else
        -- 没有鼠标指向或单位不存在时重置

        soulstoneTargetGuid = nil

        soulstoneTargetTime = 0
    end



    return false
end



-- 【新增】计算当前拥有枯萎debuff的敌人数量

local function CountWitherTargets()
    local witherCount = 0

    Aurora.enemies:within(40):each(function(enemy)
        if enemy.exists and enemy.alive and enemy.combat then
            if enemy.aura(445474) then
                witherCount = witherCount + 1
            end
        end
    end)

    return witherCount
end



-- 【新增】寻找最需要补枯萎dot的目标

local function FindBestWitherTarget()
    local bestTarget = nil

    local bestScore = -9999

    local aoeThreshold = GetConfig("aoe_threshold", 3)



    -- 【新增】检查补枯萎开关和最大目标数限制

    if not IsToggleEnabled("WitherToggle") then
        return nil
    end



    local witherMaxTargets = GetConfig("wither_max_targets", 10)

    local currentWitherCount = CountWitherTargets()



    -- 如果已经达到最大枯萎目标数，停止补枯萎

    if currentWitherCount >= witherMaxTargets then
        return nil
    end



    -- 如果敌人数量达到AOE阈值，优先使用AOE技能，不单独补dot

    local active_enemies = player.enemiesaround(40)

    if active_enemies >= aoeThreshold then
        return nil
    end



    -- 遍历所有敌人，找到最需要补枯萎dot的目标

    Aurora.enemies:within(40):each(function(enemy)
        if enemy.exists and enemy.alive and enemy.combat then
            local witherRemains = enemy.auraremains(445474) or 0

            local ttd = TimeToDieRR(enemy, 0)



            -- 计算分数：枯萎持续时间21秒，剩余时间越少，分数越高

            -- 同时考虑目标存活时间，存活时间太短的目标收益低

            local score = 21 - witherRemains - (ttd >= 14 and 0 or 14 - ttd)



            if score > bestScore then
                bestScore = score

                bestTarget = enemy
            end
        end
    end)



    return bestTarget
end



-- 【新增】补枯萎dot功能

local function RefreshWitherDot()
    if not spells.wither or not spells.wither:ready() then
        return false
    end



    local bestWitherTarget = FindBestWitherTarget()

    if bestWitherTarget and bestWitherTarget.auraremains(445474) < 5 then
        if spells.wither:castable(bestWitherTarget) then
            witherRefreshTarget = bestWitherTarget

            return spells.wither:cast(bestWitherTarget)
        end
    end



    return false
end



-- 【新增】TTD冷却技能判断

local function ShouldUseCooldown()
    local ttdEnabled = GetConfig("ttd_enabled", true)

    local ttdThreshold = GetConfig("ttd_threshold", 15)



    if not ttdEnabled then
        return true
    end



    if not target.exists then
        return false
    end



    local targetTTD = TimeToDieRR(target, 0)

    return targetTTD > ttdThreshold
end



-- 【修改】智能暗影灼烧功能 - 增加状态栏控制

local function SmartShadowburn()
    -- 检查暗影灼烧状态栏是否启用

    if not IsToggleEnabled("ShadowburnToggle") then
        return false
    end



    if not spells.shadowburn or not spells.shadowburn:ready() then
        return false
    end



    local soul_shard = player.soulshards or 0

    local aoeThreshold = GetConfig("aoe_threshold", 3)

    local active_enemies = player.enemiesaround(40)



    -- 绝对优先条件1：目标生命值 < 20%（斩杀阶段）

    if target.exists and target.alive and target.hp < 20 then
        if spells.shadowburn:castable(target) then
            return spells.shadowburn:cast(target)
        end
    end



    -- 绝对优先条件2：灵魂碎片 ≥ 4 个（接近上限）

    if soul_shard >= 4 then
        if spells.shadowburn:castable(target) then
            return spells.shadowburn:cast(target)
        end
    end



    -- 寻找血量最低的敌人（斩杀优先级）

    local lowestHealthTarget = nil

    local lowestHealth = 100



    Aurora.enemies:within(40):each(function(enemy)
        if enemy.exists and enemy.alive and enemy.combat then
            -- 优先选择血量低于30%的目标（斩杀阶段）

            if enemy.hp < 30 and enemy.hp < lowestHealth then
                lowestHealth = enemy.hp

                lowestHealthTarget = enemy
            end

            -- 如果没有斩杀目标，选择血量最低的目标

            if lowestHealthTarget == nil and enemy.hp < lowestHealth then
                lowestHealth = enemy.hp

                lowestHealthTarget = enemy
            end
        end
    end)



    -- 对最低血量目标使用暗影灼烧

    if lowestHealthTarget and spells.shadowburn:castable(lowestHealthTarget) then
        -- 小怪即将死亡（5秒内）时使用暗影灼烧获取碎片返还

        local ttd = TimeToDieRR(lowestHealthTarget, 0)

        if ttd <= 5 then
            return spells.shadowburn:cast(lowestHealthTarget)
        end



        -- -- 单体战斗中常规使用

        -- if active_enemies <= aoeThreshold then

        --     if spells.shadowburn:count() > 1 then

        --         return spells.shadowburn:cast(lowestHealthTarget)

        --     end

        -- end
    end



    return false
end



-- 冷却技能列表（按顺序执行）

local function Dps()
    -- 定义过滤函数：只统计"存活"且"在战斗中"的敌人

    local combatEnemyFilter = function(unit)
        return unit.alive     -- 单位存活

            and unit.incombat -- 单位在战斗中

            and unit.enemy    -- 单位是敌对目标（默认已包含，可省略）
    end



    -- 获取玩家40码范围内"存活且在战斗中"的敌人数量

    local active_enemies = player.enemiesaround(40, combatEnemyFilter)



    -- 【新增】获取AOE阈值配置

    local aoeThreshold = GetConfig("aoe_threshold", 3)



    -- 获取当前灵魂碎片数量（若为nil则默认0，避免报错）

    local soul_shard = player.soulshards or 0



    -- 只在没有宠物时才召唤

    if not HasActivePet() then
        if PetManagement() then return true end
    end



    -- 【新增】优先级1：灵魂石战复

    if SoulstoneBattleRes() then return true end



    -- 【新增】优先级2：防御

    if BasicDefensiveChain() then return true end



    if SmartInterrupts() then
        return true
    end



    if HardControlInterrupts() then
        return true
    end



    -- 【新增】优先级4：药水使用

    if SmartPotionUse() then return true end



    -- 【新增】优先级5：饰品使用

    if SmartTrinketUse() then return true end



    -- 【新增】优先级6：补枯萎dot（在大灾变CD或敌人数量不足时）

    if active_enemies < aoeThreshold or not spells.cataclysm:ready() then
        if RefreshWitherDot() then
            return true
        end
    end



    -- actions.assisted_combat+=/cataclysm --大灾变

    if spells.cataclysm:isknown() and spells.cataclysm:ready() and spells.cataclysm:castable(player) then
        if active_enemies >= aoeThreshold then
            spells.cataclysm:smartaoe(target, {

                offsetMin = 0,  -- 最小偏移距离（避免贴脸）

                offsetMax = 40, -- 最大偏移距离（限制释放范围）

                filter = function(unit, distance, position)
                    -- 过滤条件：只统计存活的敌人

                    return unit.enemy and unit.alive
                end

            })

            return true
        end
    end



    -- actions.assisted_combat+=/wither,if=!dot.immolate.ticking&!talent.wither --枯萎

    if spells.wither and spells.wither:ready() and spells.wither:castable(target) then
        if not target.aura(auras.immolate) and not talents.wither_talent then
            spells.wither:cast(target)

            return true
        end
    end



    -- actions.assisted_combat+=/wither,if=!dot.wither.ticking&talent.wither --枯萎

    if spells.wither and spells.wither:ready() and spells.wither:castable(target) then
        if not target.aura(445474) and talents.wither_talent then
            spells.wither:cast(target)

            return true
        end
    end



    -- 【修改】冷却技能判断 - 加入TTD条件

    if Aurora.Rotation.Cooldown:GetValue() and ShouldUseCooldown() then --cooldown
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

        if spells.ancestral_call and spells.ancestral_call:ready() and spells.ancestral_call:castable(player) then
            spells.ancestral_call:cast(player)

            return true
        end



        -- actions.cooldowns+=/summon_infernal --地狱火

        if spells.summon_infernal:isknown() and spells.summon_infernal:ready() and spells.summon_infernal:castable(player) then
            spells.summon_infernal:smartaoe(target, {

                offsetMin = 0,  -- 最小偏移距离（避免贴脸）

                offsetMax = 40, -- 最大偏移距离（限制释放范围）

                filter = function(unit, distance, position)
                    -- 过滤条件：只统计存活的敌人

                    return unit.enemy and unit.alive
                end

            })

            return true
        end



        -- actions.assisted_combat+=/malevolence --怨毒

        if spells.malevolence and spells.malevolence:ready() and spells.malevolence:castable(player) then
            spells.malevolence:cast(player)

            return true
        end
    end



    -- actions.assisted_combat+=/infernal_bolt,if=buff.infernal_bolt.up&buff.infernal_bolt.remains<=5 --狱火箭

    if spells.infernal_bolt and spells.infernal_bolt:ready() and spells.infernal_bolt:castable(target) then
        if player.aura(433891) and player.auraremains(433891) <= 5 then
            spells.infernal_bolt:cast(target)

            return true
        end
    end



    -- actions.assisted_combat+=/incinerate,if=buff.infernal_bolt.up&buff.infernal_bolt.remains<=5 --烧尽

    if spells.incinerate and spells.incinerate:ready() and spells.incinerate:castable(target) then
        if player.aura(433891) and player.auraremains(433891) <= 5 then
            spells.incinerate:cast(target)

            return true
        end
    end



    -- actions.assisted_combat+=/channel_demonfire,if=target.distance<=40  --引导恶魔之火

    if spells.channel_demonfire and spells.channel_demonfire:ready() and spells.channel_demonfire:castable(player) then
        if target:distanceto(player) <= 40 then
            spells.channel_demonfire:cast(player)

            return true
        end
    end



    -- 【修改】火焰之雨 - 使用AOE阈值配置

    if spells.rain_of_fire:isknown() and spells.rain_of_fire:ready() and spells.rain_of_fire:castable(player) then
        if active_enemies >= aoeThreshold then
            spells.rain_of_fire:smartaoe(player, {

                offsetMin = 0,  -- 最小偏移距离（避免贴脸）

                offsetMax = 40, -- 最大偏移距离（限制释放范围）

                filter = function(unit, distance, position)
                    -- 过滤条件：只统计存活的敌人

                    return unit.enemy and unit.alive
                end

            })

            return true
        end
    end



    -- actions.assisted_combat+=/soul_fire,if=buff.decimation.up&soul_shard<=4 --灵魂之火

    if spells.soul_fire and spells.soul_fire:ready() and spells.soul_fire:castable(target) then
        if player.aura(457555) and soul_shard <= 4 then --屠戮buff 457555 5个碎片自动获得
            spells.soul_fire:cast(target)

            return true
        end
    end



    -- 【修改】暗影灼烧 - 使用智能暗影灼烧功能

    if SmartShadowburn() then
        return true
    end



    -- backdraft 117828 爆燃buff

    -- actions.assisted_combat+=/conflagrate,if=buff.backdraft.down&soul_shard>=1.5&active_enemies<=2 --燃烧

    if spells.conflagrate and spells.conflagrate:ready() and spells.conflagrate:castable(target) then
        if not player.aura(117828) and soul_shard >= 1.5 and active_enemies <= aoeThreshold then
            spells.conflagrate:cast(target)

            return true
        end
    end



    -- 【修改】陨灭和混乱箭 - 添加状态栏开关控制

    if IsToggleEnabled("RuinationToggle") then
        -- actions.assisted_combat+=/ruination,if=active_enemies<=2&soul_shard>=4,cooldown_allow_casting_success=1

        if spells.ruination and spells.ruination:ready() and spells.ruination:castable(target) then
            if soul_shard >= 4 and active_enemies <= aoeThreshold then
                spells.chaos_bolt:cast(target)

                return true
            end
        end



        -- actions.assisted_combat+=/ruination,if=active_enemies<=2&soul_shard>=2&buff.ritual_of_ruin.up,cooldown_allow_casting_success=1

        if spells.ruination and spells.ruination:ready() and spells.ruination:castable(target) then
            if soul_shard >= 4 and active_enemies <= aoeThreshold and player.aura(387157) then
                spells.chaos_bolt:cast(target)

                return true
            end
        end



        -- actions.assisted_combat+=/ruination,if=active_enemies<=2

        if spells.ruination and spells.ruination:ready() and spells.ruination:castable(target) then
            spells.chaos_bolt:cast(target)

            return true
        end
    end



    -- actions.assisted_combat+=/chaos_bolt,if=active_enemies<=2&soul_shard>=4,cooldown_allow_casting_success=1

    if spells.chaos_bolt and spells.chaos_bolt:ready() and spells.chaos_bolt:castable(target) then
        if soul_shard >= 4 and active_enemies <= aoeThreshold then
            spells.chaos_bolt:cast(target)

            return true
        end
    end



    -- actions.assisted_combat+=/chaos_bolt,if=active_enemies<=2&soul_shard>=2&buff.ritual_of_ruin.up,cooldown_allow_casting_success=1

    if spells.chaos_bolt and spells.chaos_bolt:ready() and spells.chaos_bolt:castable(target) then
        if soul_shard >= 4 and active_enemies <= aoeThreshold and player.aura(387157) then
            spells.chaos_bolt:cast(target)

            return true
        end
    end



    -- actions.assisted_combat+=/chaos_bolt,if=active_enemies<=2

    if spells.chaos_bolt and spells.chaos_bolt:ready() and spells.chaos_bolt:castable(target) then
        if active_enemies <= aoeThreshold then
            spells.chaos_bolt:cast(target)

            return true
        end
    end



    -- actions.assisted_combat+=/dimensional_rift

    if spells.dimensional_rift and spells.dimensional_rift:ready() and spells.dimensional_rift:castable(target) then
        spells.dimensional_rift:cast(target)

        return true
    end



    -- actions.assisted_combat+=/infernal_bolt,if=buff.backdraft.stack>=2

    if spells.infernal_bolt and spells.infernal_bolt:ready() and spells.infernal_bolt:castable(target) then
        if player.auracount(117828) >= 2 then
            spells.infernal_bolt:cast(target)

            return true
        end
    end



    -- actions.assisted_combat+=/incinerate,if=buff.backdraft.stack>=2

    if spells.incinerate and spells.incinerate:ready() and spells.incinerate:castable(target) then
        if player.auracount(117828) >= 2 then
            spells.incinerate:cast(target)

            return true
        end
    end



    -- actions.assisted_combat+=/conflagrate,if=charges>=2

    if spells.conflagrate and spells.conflagrate:ready() and spells.conflagrate:castable(target) then
        if spells.conflagrate:charges() >= 2 then
            spells.conflagrate:cast(target)

            return true
        end
    end



    -- actions.assisted_combat+=/infernal_bolt,cooldown_allow_casting_success=1

    if spells.infernal_bolt and spells.infernal_bolt:ready() and spells.infernal_bolt:castable(target) then
        spells.infernal_bolt:cast(target)

        return true
    end



    -- actions.assisted_combat+=/incinerate,cooldown_allow_casting_success=1

    if spells.incinerate and spells.incinerate:ready() and spells.incinerate:castable(target) then
        spells.incinerate:cast(target)

        return true
    end



    -- actions.assisted_combat+=/infernal_bolt

    if spells.infernal_bolt and spells.infernal_bolt:ready() and spells.infernal_bolt:castable(target) then
        spells.infernal_bolt:cast(target)

        return true
    end



    -- actions.assisted_combat+=/incinerate

    if spells.incinerate and spells.incinerate:ready() and spells.incinerate:castable(target) then
        spells.incinerate:cast(target)

        return true
    end



    return false
end



local function Ooc()
    -- 【修改】非战斗状态宠物和魔典管理 - 只在没有宠物时才召唤

    if not HasActivePet() then
        if PetManagement() then return true end
    end



    if GrimoireManagement() then return true end



    return false
end



-- 注册循环

Aurora:RegisterRoutine(function()
    -- 【修改】检测下坐骑状态

    if player.mounted then
        lastDismountTime = GetTime() -- 更新下坐骑时间

        return
    end



    -- 跳过死亡、进食、饮水状态

    if player.dead or player.aura("Food") or player.aura("Drink") or player.mounted then
        return
    end



    if player.combat then
        Dps()
    else
        Ooc()
    end
end, "WARLOCK", 3, "RoyWarlock") -- 对应专精ID和命名空间



-- 【新增】版本检查

local function CheckRotationVersion()
    local lastVersion = Aurora.Config:Read("RoyWarlock.rotation_version") or "0"

    if lastVersion ~= ROTATION_VERSION then
        print("=== RoyWarlock 循环已更新 ===")

        print("版本: " .. ROTATION_VERSION)

        print("• 修复配置读取问题")

        print("• 增加死亡缠绕打断选项")

        print("• 增加暗影灼烧状态栏控制")

        print("• 优化界面设置")

        print("=============================")

        Aurora.Config:Write("RoyWarlock.rotation_version", ROTATION_VERSION)
    end
end



CheckRotationVersion()

print("RoyWarlock " .. ROTATION_VERSION .. " 循环已加载!")
