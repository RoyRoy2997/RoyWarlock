-- RoyWarlock 设置界面
local gui = Aurora.GuiBuilder:New()

-- 本地化文本
local L = {
    zh = {
        category = "Roy_Warlock设置",
        general = "常用设置",
        combat = "战斗设置",
        defensive = "减伤设置",
        interrupt = "打断设置",
        pet = "宠物设置",
        potion = "药水设置",
        trinket = "饰品设置",
        advanced = "高级设置",

        -- 通用设置
        language = "界面语言",
        language_tooltip = "选择界面显示语言",
        tutorial = "使用教程",
        tutorial_text = "毁灭术专精循环，包含智能宠物管理、基础减伤和打断功能。",

        -- 战斗设置
        ttd_settings = "TTD设置",
        ttd_enabled = "启用TTD判断",
        ttd_enabled_tooltip = "启用时间到死亡判断，避免在目标即将死亡时使用长冷却技能",
        ttd_threshold = "TTD阈值(秒)",
        ttd_threshold_tooltip = "目标剩余存活时间低于此值时不会使用地狱火和怨毒",

        -- 宠物设置
        pet_settings = "宠物设置",
        selected_pet = "首选宠物",
        selected_pet_tooltip = "选择自动召唤的宠物类型",
        pet_options = {
            imp = "小鬼",
            voidwalker = "虚空行者",
            sayaad = "魅魔",
            felhunter = "地狱猎犬"
        },

        -- 减伤设置
        health_threshold = "减伤技能设置",
        dark_pact_health = "暗影契约血量(%)",
        dark_pact_health_tooltip = "血量低于此值时使用暗影契约",
        unending_resolve_health = "不灭决心血量(%)",
        unending_resolve_health_tooltip = "血量低于此值时使用不灭决心",
        mortal_coil_health = "死亡缠绕血量（%)",
        mortal_coil_health_tooltip = "血量低于此值时使用死亡缠绕",

        -- 打断设置
        interrupt_settings = "打断设置",
        interrupt_enabled = "启用自动打断",
        interrupt_enabled_tooltip = "启用自动打断敌方施法",
        hard_control_enabled = "启用硬控打断",
        hard_control_enabled_tooltip = "启用暗影之怒进行AOE硬控打断",

        -- 药水设置
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

        -- 饰品设置
        trinket_settings = "饰品设置",
        trinket_mode = "饰品使用模式",
        trinket_mode_tooltip = "选择饰品的使用时机",
        trinket_modes = {
            infernal = "召唤地狱火时使用",
            cd = "卡CD使用",
            none = "不使用"
        },



        -- 高级设置
        advanced_settings = "高级设置",
        pause_for_casting = "读条时暂停循环",
        pause_for_casting_tooltip = "施法或引导时暂停其他技能释放"
    },

    en = {
        category = "Destruction Warlock Settings",
        general = "General Settings",
        combat = "Combat Settings",
        defensive = "Defensive Settings",
        interrupt = "Interrupt Settings",
        pet = "Pet Settings",
        potion = "Potion Settings",
        trinket = "Trinket Settings",
        movement = "Movement Settings",
        advanced = "Advanced Settings",

        language = "Interface Language",
        language_tooltip = "Select interface display language",
        tutorial = "Usage Tutorial",
        tutorial_text = "Destruction Warlock rotation with smart pet management, basic defense and interrupt functions.",

        ttd_settings = "TTD Settings",
        ttd_enabled = "Enable TTD Check",
        ttd_enabled_tooltip = "Enable time-to-death checking to avoid using long cooldowns on dying targets",
        ttd_threshold = "TTD Threshold(sec)",
        ttd_threshold_tooltip = "Don't use Infernal and Malevolence if target TTD is below this value",

        pet_settings = "Pet Settings",
        selected_pet = "Preferred Pet",
        selected_pet_tooltip = "Select pet type for automatic summoning",
        pet_options = {
            imp = "Imp",
            voidwalker = "Voidwalker",
            sayaad = "Succubus",
            felhunter = "Felhunter"
        },

        health_threshold = "Defensive Skill Settings",
        dark_pact_health = "Dark Pact Health(%)",
        dark_pact_health_tooltip = "Use Dark Pact when health below this value",
        unending_resolve_health = "Unending Resolve Health(%)",
        unending_resolve_health_tooltip = "Use Unending Resolve when health below this value",
        mortal_coil_health = "mortal_coil Health(%)",
        mortal_coil_health_tooltip = "Use mortal_coil when health below this value",

        interrupt_settings = "Interrupt Settings",
        interrupt_enabled = "Enable Auto Interrupt",
        interrupt_enabled_tooltip = "Enable automatic interruption of enemy casts",
        hard_control_enabled = "Enable Hard Control Interrupt",
        hard_control_enabled_tooltip = "Enable Shadowfury for AOE hard control interrupts",

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

        trinket_settings = "Trinket Settings",
        trinket_mode = "Trinket Usage Mode",
        trinket_mode_tooltip = "Select when to use trinkets",
        trinket_modes = {
            infernal = "Use with Summon Infernal",
            cd = "Use on Cooldown",
            none = "Don't Use"
        },


        advanced_settings = "Advanced Settings",
        pause_for_casting = "Pause Rotation While Casting",
        pause_for_casting_tooltip = "Pause other skill casts while casting or channeling"
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
        :Spacer()

        :Header({ text = T("tutorial") })
        :Text({
            text = T("tutorial_text"),
            color = "normal",
            size = 10
        })
        :Spacer()

        :Tab(T("pet"))
        :Header({ text = T("pet_settings") })
        :Dropdown({
            text = T("selected_pet"),
            key = "RoyWarlock.selected_pet",
            options = {
                { text = T("小鬼"), value = "imp" },
                { text = T("虚空行者"), value = "voidwalker" },
                { text = T("魅魔"), value = "sayaad" },
                { text = T("狗"), value = "felhunter" }
            },
            default = "felhunter",
            tooltip = T("selected_pet_tooltip")
        })
        :Spacer()

        :Tab(T("combat"))
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
            min = 5,
            max = 30,
            step = 1,
            default = 15,
            tooltip = T("ttd_threshold_tooltip")
        })
        :Spacer()

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
        :Spacer()

        :Tab(T("interrupt"))
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
        :Spacer()

        :Tab(T("potion"))
        :Header({ text = T("potion_settings") })
        :Dropdown({
            text = T("potion_mode"),
            key = "RoyWarlock.potion_mode",
            options = {
                { text = T("联动地狱火"), value = "infernal" },
                { text = T("卡CD使用"), value = "cd" },
                { text = T("不使用"), value = "none" }
            },
            default = "infernal",
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
        :Spacer()

        :Tab(T("trinket"))
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
        :Spacer()



        :Tab(T("advanced"))
        :Header({ text = T("advanced_settings") })
        :Checkbox({
            text = T("pause_for_casting"),
            key = "RoyWarlock.pause_for_casting",
            default = true,
            tooltip = T("pause_for_casting_tooltip")
        })
end

-- 注册状态栏
local function RegisterStatusToggles()
    Aurora.Rotation.HardControlToggle = Aurora:AddGlobalToggle({
        label = "硬控",
        var = "RoyWarlock_HardControl",
        icon = 30283, -- 暗影之怒图标
        tooltip = "启用硬控打断（暗影之怒/死亡缠绕）",
        default = true
    })

    Aurora.Rotation.DefensiveToggle = Aurora:AddGlobalToggle({
        label = "减伤",
        var = "RoyWarlock_Defensive",
        icon = 104773, -- 不灭决心图标
        tooltip = "启用自动减伤",
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
