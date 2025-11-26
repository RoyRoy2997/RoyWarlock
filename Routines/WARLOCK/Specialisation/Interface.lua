-- RoyWarlock 设置界面
local gui = Aurora.GuiBuilder:New()

-- 本地化文本
local L = {
    zh = {
        category = "Roy_Warlock设置",
        general = "通用设置",
        combat = "战斗设置",
        features = "功能设置",
        defensive = "减伤设置",
        special = "特殊功能",

        -- 通用设置
        language = "界面语言",
        language_tooltip = "选择界面显示语言",
        tutorial = "使用教程",
        tutorial_text = "自动目标：Aurora设置>Modules>Auto Target>Highest>Lock After Acquire 3.0",

        -- 战斗设置
        aoe_settings = "AOE设置",
        aoe_threshold = "AOE阈值",
        aoe_threshold_tooltip = "敌人数量达到此值时释放AOE技能（火焰之雨）",

        cataclysm_settings = "大灾变设置",
        cataclysm_threshold = "大灾变AOE阈值",
        cataclysm_threshold_tooltip = "敌人数量达到此值时释放大灾变",

        ttd_settings = "TTD设置",
        ttd_enabled = "启用TTD判断",
        ttd_enabled_tooltip = "启用时间到死亡判断，控制冷却技能释放",
        ttd_threshold = "TTD阈值(秒)",
        ttd_threshold_tooltip = "目标剩余存活时间高于此值时才会释放冷却技能",

        wither_settings = "枯萎设置",
        wither_max_targets = "补枯萎最大目标数",
        wither_max_targets_tooltip = "战斗中拥有枯萎debuff的敌人超过此数量时停止补枯萎",

        -- 功能设置
        pet_settings = "宠物设置",
        auto_summon_pet = "自动召唤宠物",
        auto_summon_pet_tooltip = "启用自动召唤宠物功能",
        use_fel_domination = "使用邪能统御",
        use_fel_domination_tooltip = "启用邪能统御快速召唤宠物",
        selected_pet = "首选宠物",
        selected_pet_tooltip = "选择自动召唤的宠物类型",
        pet_options = {
            imp = "小鬼",
            voidwalker = "虚空行者",
            sayaad = "魅魔",
            felhunter = "地狱猎犬"
        },

        interrupt_settings = "打断设置",
        interrupt_enabled = "启用自动打断",
        interrupt_enabled_tooltip = "启用自动打断敌方施法",
        hard_control_enabled = "启用硬控打断",
        hard_control_enabled_tooltip = "启用暗影之怒进行AOE硬控打断",
        use_mortal_coil_interrupt = "使用死亡缠绕打断",
        use_mortal_coil_interrupt_tooltip = "在硬控打断中使用死亡缠绕",

        trinket_settings = "饰品设置",
        trinket_mode = "饰品使用模式",
        trinket_mode_tooltip = "选择饰品的使用时机",
        trinket_modes = {
            infernal = "召唤地狱火时使用",
            cd = "卡CD使用",
            none = "不使用"
        },

        -- 减伤设置
        health_threshold = "减伤技能设置",
        dark_pact_health = "暗影契约血量(%)",
        dark_pact_health_tooltip = "血量低于此值时使用暗影契约",
        unending_resolve_health = "不灭决心血量(%)",
        unending_resolve_health_tooltip = "血量低于此值时使用不灭决心",
        mortal_coil_health = "死亡缠绕血量(%)",
        mortal_coil_health_tooltip = "血量低于此值时使用死亡缠绕",

        potion_settings = "药水设置",
        potion_mode = "爆发药水使用模式",
        potion_mode_tooltip = "选择爆发药水的使用时机",
        potion_modes = {
            infernal = "召唤地狱火时使用",
            cd = "卡CD使用",
            none = "不使用"
        },
        heal_potion_health = "治疗药水血量(%)",
        heal_potion_health_tooltip = "血量低于此值时使用治疗药水",

        -- 特殊功能
        burning_rush_settings = "爆燃冲刺设置",
        burning_rush_enabled = "启用爆燃冲刺",
        burning_rush_enabled_tooltip = "自动管理爆燃冲刺的开启和关闭",
        burning_rush_health = "火跑最低血量(%)",
        burning_rush_health_tooltip = "血量低于此值时自动关闭火跑",
        burning_rush_move_time = "移动时间阈值(秒)",
        burning_rush_move_time_tooltip = "持续移动超过此时间自动开启火跑",
        burning_rush_stand_time = "站立时间阈值(秒)",
        burning_rush_stand_time_tooltip = "站立超过此时间自动关闭火跑",

        gathering_settings = "聚拢检测设置",
        gathering_check_enabled = "启用聚拢检测",
        gathering_check_enabled_tooltip = "启用聚拢检测，控制AOE技能释放时机",
        gathering_percentage = "聚拢百分比(%)",
        gathering_percentage_tooltip = "坦克附近敌人占比达到此百分比才释放AOE技能"
    },

    en = {
        category = "Roy_Warlock Settings",
        general = "General Settings",
        combat = "Combat Settings",
        features = "Feature Settings",
        defensive = "Defensive Settings",
        special = "Special Functions",

        language = "Interface Language",
        language_tooltip = "Select interface display language",
        tutorial = "Usage Tutorial",
        tutorial_text = "AutoTarget：Aurora settings>Modules>Auto Target>Highest>Lock After Acquire 3.0",

        aoe_settings = "AOE Settings",
        aoe_threshold = "AOE Threshold",
        aoe_threshold_tooltip = "Number of enemies required to cast AOE skills (Rain of Fire)",

        cataclysm_settings = "Cataclysm Settings",
        cataclysm_threshold = "Cataclysm AOE Threshold",
        cataclysm_threshold_tooltip = "Number of enemies required to cast Cataclysm",

        ttd_settings = "TTD Settings",
        ttd_enabled = "Enable TTD Check",
        ttd_enabled_tooltip = "Enable time-to-death checking to control cooldown skill usage",
        ttd_threshold = "TTD Threshold(sec)",
        ttd_threshold_tooltip = "Only use cooldown skills when target TTD is above this value",

        wither_settings = "Wither Settings",
        wither_max_targets = "Max Wither Targets",
        wither_max_targets_tooltip =
        "Stop refreshing Wither when number of enemies with Wither debuff exceeds this value",

        pet_settings = "Pet Settings",
        auto_summon_pet = "Auto Summon Pet",
        auto_summon_pet_tooltip = "Enable automatic pet summoning",
        use_fel_domination = "Use Fel Domination",
        use_fel_domination_tooltip = "Enable Fel Domination for quick pet summoning",
        selected_pet = "Preferred Pet",
        selected_pet_tooltip = "Select pet type for automatic summoning",
        pet_options = {
            imp = "Imp",
            voidwalker = "Voidwalker",
            sayaad = "Succubus",
            felhunter = "Felhunter"
        },

        interrupt_settings = "Interrupt Settings",
        interrupt_enabled = "Enable Auto Interrupt",
        interrupt_enabled_tooltip = "Enable automatic interruption of enemy casts",
        hard_control_enabled = "Enable Hard Control Interrupt",
        hard_control_enabled_tooltip = "Enable Shadowfury for AOE hard control interrupts",
        use_mortal_coil_interrupt = "Use Mortal Coil Interrupt",
        use_mortal_coil_interrupt_tooltip = "Use Mortal Coil in hard control interrupts",

        trinket_settings = "Trinket Settings",
        trinket_mode = "Trinket Usage Mode",
        trinket_mode_tooltip = "Select when to use trinkets",
        trinket_modes = {
            infernal = "Use with Summon Infernal",
            cd = "Use on Cooldown",
            none = "Don't Use"
        },

        health_threshold = "Defensive Skill Settings",
        dark_pact_health = "Dark Pact Health(%)",
        dark_pact_health_tooltip = "Use Dark Pact when health below this value",
        unending_resolve_health = "Unending Resolve Health(%)",
        unending_resolve_health_tooltip = "Use Unending Resolve when health below this value",
        mortal_coil_health = "Mortal Coil Health(%)",
        mortal_coil_health_tooltip = "Use Mortal Coil when health below this value",

        potion_settings = "Potion Settings",
        potion_mode = "Burst Potion Mode",
        potion_mode_tooltip = "Select when to use burst potions",
        potion_modes = {
            infernal = "Use with Summon Infernal",
            cd = "Use on Cooldown",
            none = "Don't Use"
        },
        heal_potion_health = "Heal Potion Health(%)",
        heal_potion_health_tooltip = "Use heal potion when health below this value",

        burning_rush_settings = "Burning Rush Settings",
        burning_rush_enabled = "Enable Burning Rush",
        burning_rush_enabled_tooltip = "Automatically manage Burning Rush activation and deactivation",
        burning_rush_health = "Burning Rush Min Health(%)",
        burning_rush_health_tooltip = "Automatically disable Burning Rush when health below this value",
        burning_rush_move_time = "Movement Time Threshold(sec)",
        burning_rush_move_time_tooltip = "Automatically enable Burning Rush after moving for this duration",
        burning_rush_stand_time = "Standing Time Threshold(sec)",
        burning_rush_stand_time_tooltip = "Automatically disable Burning Rush after standing for this duration",

        gathering_settings = "Gathering Detection Settings",
        gathering_check_enabled = "Enable Gathering Detection",
        gathering_check_enabled_tooltip = "Enable gathering detection to control AOE skill usage",
        gathering_percentage = "Gathering Percentage(%)",
        gathering_percentage_tooltip = "Only use AOE skills when enemy percentage near tank reaches this value"
    }
}

-- 获取本地化文本
local function T(key)
    local language = Aurora.Config:Read("RoyWarlock.general.language") or "zh"
    return L[language][key] or key
end

-- 创建界面
local function CreateInterface()
    gui:Category(T("category"))
        :Tab(T("general"))
        :Header({ text = T("language") })
        :Dropdown({
            text = T("language"),
            key = "RoyWarlock.general.language",
            options = {
                { text = "中文", value = "zh" },
                { text = "English", value = "en" }
            },
            default = "zh",
            tooltip = T("language_tooltip"),
            onChange = function(value)
                Aurora.alert("Language changed to " .. value .. ". Please /reload to apply changes.", 116858)
            end
        })
    -- 【新增】天赋代码复制按钮
        :Header({ text = "天赋代码" })
        :Button({
            text = "使徒毁灭",
            width = 100,
            tooltip = "点击复制使徒毁灭天赋代码",
            onClick = function()
                local talentCode =
                "CsQAYIOwXTfhprvln24ZeRPDbMMmxMzMjY2MMmNzMDzysZMzMzsNzwyyMzAAAAAYmtlZml5BAjZMsQGYb0CNWwAAAAAAAYGDDAA"
                _G.CopyToClipboard(talentCode)
                print("天赋代码已复制到剪贴板！")
            end
        })
        :Button({
            text = "枯萎毁灭",
            width = 100,
            tooltip = "点击复制使徒毁灭天赋代码",
            onClick = function()
                local talentCode =
                "CsQAAAAAAAAAAAAAAAAAAAAAAMMmxMzMjYWMPgxsZmZYWmNjxMmFzwyyMzAAAAAGzstMzsMsADMLGzYGAzG2wAAAAAAAYmZGDAA"
                _G.CopyToClipboard(talentCode)
                print("天赋代码已复制到剪贴板！")
            end
        })


        :Header({ text = T("tutorial") })
        :Text({
            text = T("tutorial_text"),
            color = "normal",
            size = 10,
            width = 500
        })

        :Tab(T("combat"))
        :Header({ text = T("aoe_settings") })
        :Slider({
            text = T("aoe_threshold"),
            key = "RoyWarlock.aoe_threshold",
            min = 1,
            max = 10,
            step = 1,
            default = 3,
            tooltip = T("aoe_threshold_tooltip")
        })
        :Slider({
            text = T("cataclysm_threshold"),
            key = "RoyWarlock.cataclysm_threshold",
            min = 1,
            max = 10,
            step = 1,
            default = 3,
            tooltip = T("cataclysm_threshold_tooltip")
        })


        :Header({ text = T("ttd_settings") })
        :Checkbox({
            text = T("ttd_enabled"),
            key = "RoyWarlock.ttd_enabled",
            default = true,
            tooltip = T("ttd_enabled_tooltip")
        })
        :Slider({
            text = T("ttd_threshold"),
            key = "RoyWarlock.ttd_threshold",
            min = 0,
            max = 30,
            step = 1,
            default = 15,
            tooltip = T("ttd_threshold_tooltip")
        })


        :Header({ text = T("wither_settings") })
        :Slider({
            text = T("wither_max_targets"),
            key = "RoyWarlock.wither_max_targets",
            min = 1,
            max = 20,
            step = 1,
            default = 10,
            tooltip = T("wither_max_targets_tooltip")
        })


        :Tab(T("features"))
        :Header({ text = T("pet_settings") })
        :Checkbox({
            text = T("auto_summon_pet"),
            key = "RoyWarlock.auto_summon_pet",
            default = true,
            tooltip = T("auto_summon_pet_tooltip")
        })
        :Checkbox({
            text = T("use_fel_domination"),
            key = "RoyWarlock.use_fel_domination",
            default = true,
            tooltip = T("use_fel_domination_tooltip")
        })
        :Dropdown({
            text = T("selected_pet"),
            key = "RoyWarlock.selected_pet",
            options = {
                { text = T("小鬼"), value = "imp" },
                { text = T("虚空行者"), value = "voidwalker" },
                { text = T("魅魔"), value = "sayaad" },
                { text = T("地狱猎犬"), value = "felhunter" }
            },
            default = "felhunter",
            tooltip = T("selected_pet_tooltip")
        })


        :Header({ text = T("interrupt_settings") })
        :Checkbox({
            text = T("interrupt_enabled"),
            key = "RoyWarlock.interrupt_enabled",
            default = true,
            tooltip = T("interrupt_enabled_tooltip")
        })
        :Checkbox({
            text = T("hard_control_enabled"),
            key = "RoyWarlock.hard_control_enabled",
            default = true,
            tooltip = T("hard_control_enabled_tooltip")
        })
        :Checkbox({
            text = T("use_mortal_coil_interrupt"),
            key = "RoyWarlock.use_mortal_coil_interrupt",
            default = true,
            tooltip = T("use_mortal_coil_interrupt_tooltip")
        })


        :Header({ text = T("trinket_settings") })
        :Dropdown({
            text = T("trinket_mode"),
            key = "RoyWarlock.trinket_mode",
            options = {
                { text = T("联动地狱火"), value = "infernal" },
                { text = T("卡CD使用"), value = "cd" },
                { text = T("不使用"), value = "none" }
            },
            default = "infernal",
            tooltip = T("trinket_mode_tooltip")
        })


        :Tab(T("defensive"))
        :Header({ text = T("health_threshold") })
        :Slider({
            text = T("dark_pact_health"),
            key = "RoyWarlock.dark_pact_health",
            min = 20,
            max = 100,
            step = 5,
            default = 40,
            tooltip = T("dark_pact_health_tooltip")
        })
        :Slider({
            text = T("unending_resolve_health"),
            key = "RoyWarlock.unending_resolve_health",
            min = 10,
            max = 100,
            step = 5,
            default = 20,
            tooltip = T("unending_resolve_health_tooltip")
        })
        :Slider({
            text = T("mortal_coil_health"),
            key = "RoyWarlock.mortal_coil_health",
            min = 10,
            max = 100,
            step = 5,
            default = 60,
            tooltip = T("mortal_coil_health_tooltip")
        })


        :Header({ text = T("potion_settings") })
        :Dropdown({
            text = T("potion_mode"),
            key = "RoyWarlock.potion_mode",
            options = {
                { text = T("联动地狱火"), value = "infernal" },
                { text = T("卡CD使用"), value = "cd" },
                { text = T("嗜血时使用"), value = "bloodlust" }, -- 【新增】嗜血选项
                { text = T("不使用"), value = "none" }
            },
            default = "bloodlust",
            tooltip = T("potion_mode_tooltip")
        })
        :Slider({
            text = T("heal_potion_health"),
            key = "RoyWarlock.heal_potion_health",
            min = 10,
            max = 50,
            step = 5,
            default = 30,
            tooltip = T("heal_potion_health_tooltip")
        })


    -- 在特殊功能页面添加脱战启用选项
        :Tab(T("special"))
        :Header({ text = T("burning_rush_settings") })
        :Checkbox({
            text = T("burning_rush_enabled"),
            key = "RoyWarlock.burning_rush_enabled",
            default = false,
            tooltip = T("burning_rush_enabled_tooltip")
        })
        :Checkbox({
            text = "脱战启用爆燃冲刺",
            key = "RoyWarlock.burning_rush_ooc",
            default = false,
            tooltip = "在非战斗状态也启用爆燃冲刺自动管理"
        })
        :Slider({
            text = T("burning_rush_health"),
            key = "RoyWarlock.burning_rush_health",
            min = 10,
            max = 100,
            step = 5,
            default = 50,
            tooltip = T("burning_rush_health_tooltip")
        })
        :Slider({
            text = T("burning_rush_move_time"),
            key = "RoyWarlock.burning_rush_move_time",
            min = 0.5,
            max = 10,
            step = 0.5,
            default = 1.5,
            tooltip = T("burning_rush_move_time_tooltip")
        })
        :Slider({
            text = T("burning_rush_stand_time"),
            key = "RoyWarlock.burning_rush_stand_time",
            min = 0.5,
            max = 10,
            step = 0.5,
            default = 1.5,
            tooltip = T("burning_rush_stand_time_tooltip")
        })
        :Header({ text = T("gathering_settings") })
        :Checkbox({
            text = T("gathering_check_enabled"),
            key = "RoyWarlock.gathering_check_enabled",
            default = false,
            tooltip = T("gathering_check_enabled_tooltip")
        })
        :Slider({
            text = T("gathering_percentage"),
            key = "RoyWarlock.gathering_percentage",
            min = 10,
            max = 100,
            step = 5,
            default = 75,
            tooltip = T("gathering_percentage_tooltip")
        })

        :Tab("宏命令管理")
        :Header({ text = "状态栏宏命令" })
        :Text({
            text = "点击下方按钮复制对应的宏命令，然后在游戏内创建宏并绑定快捷键。强调：请将aurora改成自己的空间名称。",
            color = "normal",
            size = 10
        })
        :Button({
            text = "复制强制单体宏",
            onClick = function()
                _G.CopyToClipboard("/aurora forcesingle")
                print("宏命令已复制到剪贴板：/aurora forcesingle")
            end
        })
        :Button({
            text = "复制小爆发宏",
            onClick = function()
                _G.CopyToClipboard("/aurora smallburst")
                print("宏命令已复制到剪贴板：/aurora smallburst")
            end
        })
        :Button({
            text = "复制大爆发宏",
            onClick = function()
                _G.CopyToClipboard("/aurora bigburst")
                print("宏命令已复制到剪贴板：/aurora bigburst")
            end
        })
        :Button({
            text = "复制减伤宏",
            onClick = function()
                _G.CopyToClipboard("/aurora defensive")
                print("宏命令已复制到剪贴板：/aurora defensive")
            end
        })
        :Button({
            text = "复制陨灭宏",
            onClick = function()
                _G.CopyToClipboard("/aurora ruination")
                print("宏命令已复制到剪贴板：/aurora ruination")
            end
        })
        :Button({
            text = "复制补枯萎宏",
            onClick = function()
                _G.CopyToClipboard("/aurora wither")
                print("宏命令已复制到剪贴板：/aurora wither")
            end
        })
        :Button({
            text = "复制暗影灼烧宏",
            onClick = function()
                _G.CopyToClipboard("/aurora shadowburn")
                print("宏命令已复制到剪贴板：/aurora shadowburn")
            end
        })
        :Button({
            text = "复制拉怪补DOT宏",
            onClick = function()
                _G.CopyToClipboard("/aurora prepull")
                print("宏命令已复制到剪贴板：/aurora prepull")
            end
        })
    -- 【新增】自定义目标选择宏命令按钮
        :Button({
            text = "复制智能目标宏",
            onClick = function()
                _G.CopyToClipboard("/aurora customtarget")
                print("宏命令已复制到剪贴板：/aurora customtarget")
            end
        })
end

-- 注册状态栏
local function RegisterStatusToggles()
    -- 尝试通过状态栏对象本身删除
    if Aurora.Rotation.Cooldown and Aurora.Rotation.Cooldown.var then
        local removed = Aurora:RemoveGlobalToggle(Aurora.Rotation.Cooldown.var)
        if removed then
            print("成功删除冷却状态栏")
        else
            print("冷却状态栏删除失败")
        end
    end

    if Aurora.Rotation.Interrupt and Aurora.Rotation.Interrupt.var then
        local removed = Aurora:RemoveGlobalToggle(Aurora.Rotation.Interrupt.var)
        if removed then
            print("成功删除打断状态栏")
        else
            print("打断状态栏删除失败")
        end
    end

    -- 添加新的状态栏
    Aurora.Rotation.SmallBurstToggle = Aurora:AddGlobalToggle({
        label = "小爆发",
        var = "RoyWarlock_SmallBurst",
        icon = 442726, -- 怨毒图标
        tooltip = "启用怨毒",
        default = true
    })

    Aurora.Rotation.BigBurstToggle = Aurora:AddGlobalToggle({
        label = "大爆发",
        var = "RoyWarlock_BigBurst",
        icon = 1122, -- 召唤地狱火图标
        tooltip = "启用召唤地狱火",
        default = true
    })

    Aurora.Rotation.RuinationToggle = Aurora:AddGlobalToggle({
        label = "陨灭",
        var = "RoyWarlock_Ruination",
        icon = 434635, -- 陨灭图标
        tooltip = "启用陨灭技能释放",
        default = true
    })

    Aurora.Rotation.InterruptToggle = Aurora:AddGlobalToggle({
        label = "打断",
        var = "RoyWarlock_Interrupt",
        icon = 119910, -- 法术锁定图标
        tooltip = "启用自动打断",
        default = true
    })

    -- 保留其他自定义状态栏
    Aurora.Rotation.DefensiveToggle = Aurora:AddGlobalToggle({
        label = "减伤",
        var = "RoyWarlock_Defensive",
        icon = 104773, -- 不灭决心图标
        tooltip = "启用自动减伤",
        default = true
    })


    Aurora.Rotation.WitherToggle = Aurora:AddGlobalToggle({
        label = "补枯萎",
        var = "RoyWarlock_Wither",
        icon = 445468, -- 枯萎图标
        tooltip = "启用自动补枯萎dot",
        default = true
    })

    Aurora.Rotation.ShadowburnToggle = Aurora:AddGlobalToggle({
        label = "暗影灼烧",
        var = "RoyWarlock_Shadowburn",
        icon = 17877, -- 暗影灼烧图标
        tooltip = "启用暗影灼烧技能",
        default = true
    })

    Aurora.Rotation.PrepullToggle = Aurora:AddGlobalToggle({
        label = "拉怪补DOT",
        var = "RoyWarlock_Prepull",
        icon = 445468, -- 枯萎图标
        tooltip = "启用拉怪补DOT模式，战斗10秒后自动关闭",
        default = false
    })

    Aurora.Rotation.ForceSingleTargetToggle = Aurora:AddGlobalToggle({
        label = "强制单体",
        var = "RoyWarlock_ForceSingleTarget",
        icon = 29722, -- 烧尽图标
        tooltip = "开启后强制使用单体技能，忽略AOE阈值",
        default = false
    })
    -- 【新增】自定义目标选择状态栏
    Aurora.Rotation.CustomTargetToggle = Aurora:AddGlobalToggle({
        label = "智能目标",
        var = "RoyWarlock_CustomTarget",
        icon = 132204, -- 目标图标
        tooltip = "启用智能目标选择，自动选择最佳目标",
        default = true
    })

    print("RoyWarlock 状态栏已加载!")
end

-- 创建界面
CreateInterface()

-- 延迟注册状态栏
C_Timer.After(2, function()
    RegisterStatusToggles()
end)

print("RoyWarlock 界面已加载!")
