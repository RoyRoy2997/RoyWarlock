-- 创建技能对象

local NewSpell = Aurora.SpellHandler.NewSpell



-- 注册术士（WARLOCK）专精ID 1（痛苦/毁灭/恶魔学识需根据实际调整，此处默认核心专精）

Aurora.SpellHandler.PopulateSpellbook({

    spells = {

        -- 战斗前技能

        summon_pet = NewSpell(691),               -- 召唤宠物

        grimoire_of_sacrifice = NewSpell(108503), -- 牺牲魔典

        soul_fire = NewSpell(6353),               -- 灵魂之火

        incinerate = NewSpell(29722),             -- 烧尽



        -- 辅助战斗技能

        cataclysm = NewSpell(152108, { radius = 8 }),      -- 大灾变

        wither = NewSpell(445468),                         -- 枯萎

        infernal_bolt = NewSpell(434506),                  -- 狱火箭

        malevolence = NewSpell(442726),                    -- 怨毒

        channel_demonfire = NewSpell(196447),              -- 引导恶魔之火

        rain_of_fire = NewSpell(5740, { radius = 8 }),     -- 火焰之雨

        shadowburn = NewSpell(17877),                      -- 暗影灼烧

        conflagrate = NewSpell(17962),                     -- 燃烧

        ruination = NewSpell(434635),                      -- 陨灭 使徒天赋 混乱箭衍生

        chaos_bolt = NewSpell(116858),                     -- 混乱箭（需确认正确ID）

        dimensional_rift = NewSpell(387976),               -- 维度裂隙

        summon_infernal = NewSpell(1122, { radius = 10 }), -- 召唤地狱火

        Soulstone = NewSpell(20707),                       --灵魂石

        Burning_Rush = NewSpell(111400),                   --爆燃冲刺 火跑

        Kureshuaijie = NewSpell(456939),                   --酷热衰竭 天赋

        Moxingxiongcan = NewSpell(456943),                 --魔性凶残 天赋



        --打断技能

        spell_lock = NewSpell(119910),        -- 法术锁定 单体打断

        spell_lock_modian = NewSpell(132409), --牺牲魔典下的法术锁定

        --硬控技能



        Mortal_Coil = NewSpell(6789),                  --死亡缠绕 单体硬控

        Shadowfury = NewSpell(30283, { radius = 10 }), --暗影之怒 群体硬控



        --减伤技能

        Dark_Pact = NewSpell(108416),        -- 暗影契约 小减伤 45s cd

        Unending_Resolve = NewSpell(104773), -- 不灭决心 大减伤 180s cd



        -- 宠物召唤技能

        Fel_Domination = NewSpell(333889), -- 邪能统御 --释放后可以无施法时间 直接召唤宠物 在释放宠物前 释放此技能

        summon_imp = NewSpell(688),        -- 召唤小鬼

        summon_voidwalker = NewSpell(697), --召唤虚空行者

        summon_Sayaad = NewSpell(366222),  -- 召唤赛亚德

        summon_felhunter = NewSpell(691),  -- 召唤地狱猎犬



        -- 冷却技能

        blood_fury = NewSpell(20572),      -- 血怒（兽人种族技能）

        berserking = NewSpell(26297),      -- 狂暴（巨魔种族技能）

        fireblood = NewSpell(265221),      -- 火焰之血（血精灵/地精等种族技能）

        ancestral_call = NewSpell(274738), -- 先祖召唤（德莱尼种族技能）



        -- 【新增】快速放门宏相关技能

        soul_burn = NewSpell(74434),        -- 灵魂燃烧

        demonic_gateway = NewSpell(111771), -- 恶魔传送门

    },

    auras = {

        -- 光环注册（对应dot/buff）

        immolate = NewSpell(34884),                    -- 献祭dot

        wither_dot = NewSpell(445474),                 -- 枯萎dot

        grimoire_of_sacrifice_buff = NewSpell(108503), -- 牺牲魔典buff

        infernal_bolt_buff = NewSpell(348890),         -- 地狱火螺栓buff

        decimation = NewSpell(264170),                 -- 毁灭buff

        backdraft = NewSpell(117828),                  -- 顺风buff

        ritual_of_ruin = NewSpell(391924),             -- 毁灭仪式buff

    },

    talents = {

        grimoire_of_sacrifice = NewSpell(108503), -- 牺牲魔典天赋

        wither_talent = NewSpell(445468),         -- 枯萎天赋

    }

}, "WARLOCK", 3, "RoyWarlock") -- 最后一个参数为自定义命名空间
