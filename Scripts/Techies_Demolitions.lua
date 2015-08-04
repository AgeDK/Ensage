--<<Techies_Demolitions script by Zanko version 4.0f>>
--[[
             _.-^^---....,,--
         _--                  --_
        <                        >)
        |                         |
         \._                   _./
            ```--. . , ; .--'''
                  | |   |
               .-=||  | |=-.
               `-=#$%&%$#=-'
                  | ;  :|
         _____.,-#%&$@%#&#~,._____
    -------------------------------------
    | Techies_Demolitions Script by Zanko |
    -------------------------------------
    =========== Version 4.0f ===========
    Description:
    ------------
        Useful information to plan your Techies strategies (Detailed information can be found in the forum images)
    Changelog:
    ----------
	Version 4.0f - 2nd May 2015 7:37PM :
        - Fix for 6.84
    Version 4.0e - 27th February 2015 6:37PM :
        - Fix error startup
        - Fix forcestaff/eul to dispel linken
        - Implement greedy bombing (Hold down CTRL)
    Version 4.0d - 18th January 2015 4:31PM :
        - Use Mouseover for more realistic forcestaff
        - Change CTRL to ALT for convenience
    Version 4.0c - 11th January 2015 3:43PM :
        - Fixed Meepo bug
        - Fixed Auto forcestaff to locate nil hero
        - Clean Code
    Version 4.0b - 11th January 2015 12:53PM :
        - Fixed Auto forcestaff that cause crashes
        - Script now requires "libs.TargetFind"
    Version 4.0 - 11th January 2015 2:35PM :
        - Fixed Scepter damage bug (Thanks Thomas)
        - Fixed Spectre reduction bug (Thanks Thomas)
        - Added Abaddon redirect and Kunkka Boat mechanics
        - Fixed Meepo illusion bug
        - Fixed bomb to randomly detonate due to last seen hero
        - Added Auto force staff (Hold CTRL to see the range for forcestaff and Eul and to activate this function)
            - Forcestaff if there is fatal mine stack 600 units ahead and is in cast range of 800.
            - Removal of linken and force staff if the enemy is in cast range of 700 for Eul Scepter.
        - Added selections display of number of bombs.
        - Added menu selections for hero to auto detonate
    Version 3.4 - 28th December 2014 2:35PM :
        - Implement array loop for InvulnerableToRemoteMinesList (Thanks swift)
        - Fixed script crash when the enemy team contains
            - CDOTA_Unit_Hero_Treant
            - CDOTA_Unit_Hero_Bloodseeker
            - CDOTA_Unit_Hero_Abaddon
        - Fixed spamming bombing (no more noise)
        - Rework self detonation (More efficient)
        - Bomb now will not explode till the last bomb is planted
            - If enemy needs 3 bombs and you plant the 3rd bomb, it will explode once the 3rd bomb lands
            - Previously explode at the gesture of planting
        - Bomb now take into account mixture of bombs (level 1, level 2, level 3, Scepter)
        - Efficient bombing for Faceless Void implemented.
    Version 3.3 - 27th December 2014 2:18PM :
        - Removed print statement that causes script to crash
        - Changed comparing hero name string to class ID for efficiency
        - Self detonation will now consider damage amplification
            - modifier_undying_flesh_golem_plague_aura (Using linear function)
            - modifier_shadow_demon_soul_catcher
            - modifier_chen_penitence
            - modifier_slardar_sprint
            - modifier_bloodseeker_bloodrage
            - modifier_item_mask_of_madness_berserk
        - Self detonation will now consider damage reduction of stack form
            - Templar assassin refraction (Track cool down, assume maximum charge if on cool down)
            - modifier_treant_living_armor
            - modifier_visage_gravekeepers_cloak
    Version 3.2 - 27th December 2014 1:11AM :
        - Self detonation now works with meepo clone. Display GUI will only display for main meepo.
        - Self detonation will now consider
            - modifier_wisp_overcharge
            - modifier_abaddon_aphotic_shield
            - Spectre's Dispersion
            - modifier_medusa_mana_shield
            - modifier_kunkka_ghost_ship_damage_absorb
            - modifier_ember_spirit_flame_guard
        - Self detonation will consider if the skill above are stacked together
             (Example, Ember can have 4 modifiers can it will calculate accordingly)
        - GUI display for remote mine will display RequiredBomb(with or without buff)/ Max Bomb (Without Buff)
    Version 3.1 - 26th December 2014 5:55PM :
        - Clean some code
        - Update spell immunity/invulnerable list
        - Change bomb display, if target cannot be killed then display "MAX" instead of "#INF/#INF"
    Version 3.0 - 25th December 2014 12:10AM :
        - Clean code
        - Bomb will not auto detonate if the following modifier occurs
            - modifier_puck_phase_shift"
            - modifier_storm_spirit_ball_lightning
            - modifier_morphling_waveform
            - modifier_brewmaster_primal_split
            - modifier_ember_spirit_sleight_of_fist_caster
            - modifier_phoenix_supernova_hiding
            - modifier_oracle_false_promise
            - modifier_phoenix_supernova_hiding
            - modifier_faceless_void_time_walk
            - modifier_faceless_void_time_walk_slow
            - modifier_obsidian_destroyer_astral_imprisonment_prison
            - modifier_shadow_demon_disruption
            - modifier_abaddon_borrowed_time
            - modifier_dazzle_shallow_grave
            - modifier_eul_cyclone
            - modifier_brewmaster_storm_cyclone
        Version 2.2b - 24th December 2014 8:00PM :
            - Fixed sentry/gem display bug
        Version 2.2 - 24th December 2014 4:58PM :
            - Added Toggle key for auto detonation
            - Fixed bug regarding remote mines and land mines interaction
            - Moved helper function EasyDraw to the top
        Version 2.1b - 24th December 2014 10:38AM:
            - Clean duplications of code
            - Fixed bug of not able to initialize script
        Version 2.1 - 24th December 2014 01:38AM:
            - Added Self_Detonation Function (BETA)
            - Self Detonation now bomb minimum number of bombs (Efficient)
        Version 2.0 - 23rd December 2014 07:12PM:
            - Added bomb visibility
            - Added bomb range
            - Added gem display to the hero panel
            - Added sentry display to the hero panel
            - Fixed reloading script error
            - Added EasyCreateFont(), EasyCreateRect() and EasyCreateText() function for easy drawing
            - Update bomb display info (Bomb will now display both current and Max bomb)
            - Push down the bomb information to avoid blocking the death timer
            - Script will now disabled if Techies is not picked
            - Put on GitHub
        Version 1.0 - 6th December 2014 10:28AM:
            - Added simple calculation for Techies land mines, remote mines and suicide.
]]--
require("libs.ScriptConfig")
require("libs.Utils")
require("libs.TargetFind")

config = ScriptConfig.new()
config:SetParameter("ShowMineRequired", true)
config:SetParameter("ShowLandMineRange", false)
config:SetParameter("ShowStatisRange", false)
config:SetParameter("ShowRemoteMineRange", true)
config:SetParameter("ShowMineVisibility", true)
config:SetParameter("ShowGem", true)
config:SetParameter("ShowSentry", true)
config:SetParameter("Active", 221, config.TYPE_HOTKEY) -- "]"
config:Load()

------- Draw Helper Function -----------
local screenResolution = client.screenSize
local screenRatio = client.screenRatio

function EasyCreateFont(name, fontname, tallRatio, weight)
    return drawMgr:CreateFont(name, fontname, tallRatio * screenResolution.y, weight)
end

function EasyCreateText(xRatio, yRatio, color, text, font)
    return drawMgr:CreateText(xRatio * screenResolution.x, yRatio * screenResolution.y, color, text, font)
end

function EasyCreateRect(xRatio, yRatio, wRatio, hRatio, color)
    return drawMgr:CreateRect(xRatio * screenResolution.x, yRatio * screenResolution.y, wRatio * screenResolution.x, hRatio * screenResolution.y, color)
end
-------- Initialize Variables --------
sleepTick = 0

local InvulnerableToRemoteMinesList = {
        ---- Invulnerability granted by being hidden ----
            "modifier_brewmaster_primal_split",
            "modifier_ember_spirit_sleight_of_fist_caster",
            "modifier_juggernaut_omnislash",
            "modifier_juggernaut_omnislash_invulnerability",
            "modifier_life_stealer_infest",
            "modifier_phoenix_supernova_hiding",
            "modifier_puck_phase_shift",
            "modifier_tusk_snowball_movement",
         ---- Invulnerability granted by disables ----
            "modifier_bane_nightmare_invulnerable",
            "modifier_brewmaster_storm_cyclone",
            "modifier_eul_cyclone",
            "modifier_shadow_demon_disruption",
            "modifier_invoker_tornado",
            "modifier_obsidian_destroyer_astral_imprisonment_prison",
            ---- Invulnerability granted by blink ----
            "modifier_ember_spirit_fire_remnant",
            "modifier_faceless_void_time_walk",
            "modifier_morphling_waveform",
            "modifier_storm_spirit_ball_lightning",
            "modifier_rattletrap_hookshot", -- not invulnerable but too fast to detonate
            ---- Invulnerability granted by spell ----
            "modifier_medusa_stone_gaze",
            "modifier_naga_siren_song_of_the_siren",
            "modifier_oracle_false_promise",
            "modifier_dazzle_shallow_grave",
            "modifier_abaddon_borrowed_time",
            ---- Invulnerability granted by mirror image ----
            "modifier_chaos_knight_phantasm",
            "modifier_naga_siren_mirror_image",
            ---- Spell Immunity ----
            "modifier_huskar_life_break_charge",
            "modifier_omniknight_repel",
            "modifier_life_stealer_rage",
            "modifier_juggernaut_blade_fury",
            "modifier_omniknight_repel"}

local landMineDamage = 0
local remoteMineDamage = 0
local ShowMineRequired = config.ShowMineRequired
local ShowLandMineRange = config.ShowLandMineRange
local ShowStatisRange = config.ShowStatisRange
local ShowRemoteMineRange = config.ShowRemoteMineRange
local ShowMineVisibility = config.ShowMineVisibility
local ShowGem = config.ShowGem
local ShowSentry = config.ShowSentry
local myDrawing = {}

local toggleCommand = config.Active
local AllowSelfDetonate = true
local heroInfoPanel = {}
local upLandMine = false
local upRemoteMine = false
local upSuicide = false
local effect = {}
local bombCountArray = {}
local bombInformationArray = {}

heroIcon = {}
clickIcon = {}

local F10 = EasyCreateFont("F10", "Arial", 0.0125, 1)
local F11 = EasyCreateFont("F11", "Arial", 0.01274074074074074, 550 * screenResolution.x)
local AllowSelfDetonateText  = EasyCreateText(0.0026041666666666665, 0.041666666666666664, -1, "", F11)
AllowSelfDetonateText.visible = false


function Tick( tick )

    currentTick = tick

    if not PlayingGame() or client.console or not SleepCheck("stop") then return end
    if sleepTick and sleepTick > tick then return end
    me = entityList:GetMyHero()

    

    if not me or me.classId ~= CDOTA_Unit_Hero_Techies  then
        print("This script is for Techies")
        script:Disable()
        return
    end

    if not bombInformationArray.Damage then
        bombInformationArray.Damage = {}
    end
    
    if not bombInformationArray.HeroDamage then
        bombInformationArray.HeroDamage = {}
    end
    
    if not bombInformationArray.HeroPredictedDamage then
        bombInformationArray.HeroPredictedDamage = {}
    end

    if not effect.Range then
        effect.Range = {}
    end
    
    if not effect.Visible then
        effect.Visible = {}
    end
    
    enemies = entityList:GetEntities({type = LuaEntity.TYPE_HERO})
    mines = entityList:GetEntities({classId = CDOTA_NPC_TechiesMines})
    
    AllowSelfDetonateText.visible = true

    --Obtain Techies' Land Mines Damage
    if me:GetAbility(1).level ~= 0 then
        local landMineDamageArray = {300, 375, 450, 525}
        landMineDamage = landMineDamageArray[me:GetAbility(1).level]
        upLandMine = true
    end

    --Obtain Techies' Remote Mines Damage
    if me:GetAbility(6).level ~= 0 then
        local remoteMineDamageArray = {300, 450, 600}
        remoteMineDamage = me:FindItem("item_ultimate_scepter") and (remoteMineDamageArray[me:GetAbility(6).level] + 150) or remoteMineDamageArray[me:GetAbility(6).level]
        upRemoteMine = true
    end

    if me:GetAbility(3).level ~= 0 then
        local suicideDamageArray = {500, 650, 850, 1150}
        upSuicide = true
        suicideDamage = suicideDamageArray[me:GetAbility(3).level]
    end
    
    if ShowMineRequired then
        if mines ~= nil then
            MinesInformationDisplay()
        end
            CalculateTechiesInformation()
            ShowSelectedInformation()
    end
    Sleep(100)
end

function Key(msg,code)
    if client.chat then return end
    if msg == KEY_DOWN then
        if code == toggleCommand then
            AllowSelfDetonate = not AllowSelfDetonate
        end
    end
    if AllowSelfDetonate == false then
        AllowSelfDetonateText.text = "( ] ) Auto Detonate: OFF"
    else
        AllowSelfDetonateText.text = "( ] ) Auto Detonate: ON"
    end
    for i = 1,5 do
        local x = 0.7369791666666666
        local y = 0.008333333333333333
        local w = 0.011458333333333333
        local h = 0.020370370370370372
        
        if IsMouseOnButton(x + i * 0.0145, y, w, h) then
            if msg == LBUTTON_DOWN then
                heroIcon[i].activated = not heroIcon[i].activated
            end
        end
    end
    
end

function IsMouseOnButton(xRatio, yRatio, wRatio, hRatio)
    local mouseXRatio = client.mouseScreenPosition.x / screenResolution.x
    local mouseYRatio = client.mouseScreenPosition.y / screenResolution.y
    return mouseXRatio > xRatio and mouseXRatio <= xRatio + wRatio and mouseYRatio > yRatio and mouseYRatio <= yRatio + hRatio
end

function DisableEnemy(hero)
    if hero.classId == CDOTA_Unit_Hero_Zuus then
        if hero:GetAbility(4) and hero:GetAbility(4).level > 0 and hero:GetAbility(4).abilityPhase then
            SelfEul()
        end
    end
    if me:DoesHaveModifier("modifier_lina_laguna_blade") or me:DoesHaveModifier("modifier_lion_finger_of_death") then
        SelfEul()
    end
end

function SelfEul()
    local eulScepter = me:FindItem("item_cyclone")
    if eulScepter and eulScepter.cd == 0 and me.mana >= eulScepter.manacost and SleepCheck("Eul") then
        me:SafeCastItem(eulScepter.name, me)
        Sleep(300, "Eul")
    end
end
function CalculateTechiesInformation()
    local xSpacing = 0.034375
    local drawFromTopRatio = 0.070
    local illusionCheck = true
    local meepos = entityList:GetEntities({type = LuaEntity.TYPE_MEEPO})

    for i = 1, #enemies do
        local heroInfo = enemies[i]
        local ID = heroInfo.classId

		if IsKeyDown(88) and SleepCheck("Aggro") and enemies[i].alive then
                Aggro(enemies[i])
                Sleep(500, "Aggro")
            end
			
		DisableEnemy(enemies[i])
        if ID == CDOTA_Unit_Hero_Undying and heroInfo.team == me.team then
            undying = heroInfo
            if heroInfo:FindItem("item_ultimate_scepter") then
                undyingMinAmplificationArray = {0.15, 0.20, 0.25}
                undyingMaxAmplificationArray = {0.30, 0.35, 0.40}
            else
                undyingMinAmplificationArray = {0.05, 0.10, 0.15}
                undyingMaxAmplificationArray = {0.20, 0.25, 0.30}
            end
            if heroInfo:GetAbility(4) ~= nil then
                undyingMinPercentAmplified = undyingMinAmplificationArray[heroInfo:GetAbility(4).level]
                undyingMaxPercentAmplified = undyingMaxAmplificationArray[heroInfo:GetAbility(4).level]
            else
                undyingMinPercentAmplified = 0
                undyingMaxPercentAmplified = 0
            end
        end

        if ID == CDOTA_Unit_Hero_Shadow_Demon and heroInfo.team == me.team then
            demonAmplificationArray = {0.20, 0.30, 0.40, 0.50}
            if heroInfo:GetAbility(2) ~= nil then
                demonPercentAmplified = demonAmplificationArray[heroInfo:GetAbility(2).level]
            else
                demonPercentAmplified = 0
            end
        end

        if ID == CDOTA_Unit_Hero_Treant and heroInfo.team ~= me.team then
            treantInstanceBlockArray = {4, 5, 6, 7}
            treantDamageBlockArray = {20, 40, 60, 80}

            if heroInfo:GetAbility(3) ~= nil then
                treantInstanceBlocked = treantInstanceBlockArray[heroInfo:GetAbility(3).level]
                treantDamageBlocked = treantDamageBlockArray[heroInfo:GetAbility(3).level]
            else
                treantInstanceBlocked = 0
                treantDamageBlocked = 0
            end
        end

        if ID == CDOTA_Unit_Hero_Bloodseeker then
            bloodseekerAmplificationArray = {0.25, 0.30, 0.35, 0.40}
            if heroInfo:GetAbility(1) ~= nil then
                bloodseekerPercentAmplified = bloodseekerAmplificationArray[heroInfo:GetAbility(1).level]
            else
                bloodseekerPercentAmplified = 0
            end
        end

        if ID == CDOTA_Unit_Hero_Chen and heroInfo.team == me.team then
            chenAmplificationArray = {0.14, 0.18, 0.22, 0.26}
            if heroInfo:GetAbility(1) ~= nil then
                chenPercentAmplified = chenAmplificationArray[heroInfo:GetAbility(1).level]
            else
                chenPercentAmplified = 0
            end
        end
        
        if ID == CDOTA_Unit_Hero_Abaddon and heroInfo.team ~= me.team then
            abaddonBlockArray = {110, 140, 170, 200}
            if heroInfo:GetAbility(2) ~= nil then
                abaddonDamageBlocked = abaddonBlockArray[heroInfo:GetAbility(2).level]
            else
                abaddonDamageBlocked = 0
            end
        end

        if ID == CDOTA_Unit_Hero_Wisp and heroInfo.team ~= me.team then
            wispBlockArray = {0.05, 0.10, 0.15, 0.20}
            if heroInfo:GetAbility(4) ~= nil then
                wispPercentBlocked = wispBlockArray[heroInfo:GetAbility(4).level]
            else
                wispPercentBlocked = 0
            end
        end

        if meepos ~= nil then
            if ID == CDOTA_Unit_Hero_Meepo then
                heroInfo.meepoNumber = -1
                if heroInfo.meepoIllusion then
                    illusionCheck = true
                else 
                    illusionCheck = false
                end
                
                local meepoUlt = heroInfo:GetAbility(4)
                if meepoUlt and meepoUlt.level ~= nil then
                    heroInfo.meepoNumber = (meepoUlt:GetProperty("CDOTA_Ability_Meepo_DividedWeStand", "m_nWhichDividedWeStand") + 1)
                end
            else
                heroInfo.meepoNumber = -1
                illusionCheck = heroInfo.illusion
            end
        end
        if illusionCheck == false then
            local uniqueIdentifier = heroInfo.handle
            local playerIconLocation = heroInfo.playerId
            if uniqueIdentifier ~= me.handle then
                if heroInfoPanel[uniqueIdentifier] == nil then
                    bombInformationArray.HeroDamage[uniqueIdentifier] = 0
                    heroInfoPanel[uniqueIdentifier] = {}
                    if me.team == LuaEntity.TEAM_DIRE then
                        xIconOrigin = 0.273958
                        xTextOrigin = 0.2842705
                        playerOffset = 0
                    elseif me.team == LuaEntity.TEAM_RADIANT then
                        xIconOrigin = 0.5546875
                        xTextOrigin = 0.565
                        playerOffset = 5
                    end
                    if heroInfo.team ~= me.team and heroInfo.meepoNumber < 2 then
                        heroInfoPanel[uniqueIdentifier].landMineIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation - playerOffset), drawFromTopRatio, 0.0078125, 0.01388, 0x00000095)
                        heroInfoPanel[uniqueIdentifier].landMineIcon.textureId = drawMgr:GetTextureId("NyanUI/other/npc_dota_techies_land_mine")
                        heroInfoPanel[uniqueIdentifier].landMineIcon.visible = true
                        heroInfoPanel[uniqueIdentifier].landMineText = EasyCreateText(xTextOrigin + xSpacing * (playerIconLocation - playerOffset), drawFromTopRatio, -1, "", F10)
                        heroInfoPanel[uniqueIdentifier].landMineText.visible = false

                        heroInfoPanel[uniqueIdentifier].remoteMineIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation - playerOffset), drawFromTopRatio + 0.017, 0.0078125, 0.01388, 0x00000095)
                        heroInfoPanel[uniqueIdentifier].remoteMineIcon.textureId = drawMgr:GetTextureId("NyanUI/other/npc_dota_techies_remote_mine")
                        heroInfoPanel[uniqueIdentifier].remoteMineIcon.visible = true
                        heroInfoPanel[uniqueIdentifier].remoteMineText = EasyCreateText(xTextOrigin + xSpacing * (playerIconLocation - playerOffset), drawFromTopRatio + 0.017, -1, "", F10)
                        heroInfoPanel[uniqueIdentifier].remoteMineText.visible = false

                        heroInfoPanel[uniqueIdentifier].suicideIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation - playerOffset), drawFromTopRatio + 0.034, 0.0078125, 0.01388, 0x00000095)
                        heroInfoPanel[uniqueIdentifier].suicideIcon.textureId = drawMgr:GetTextureId("NyanUI/spellicons/techies_suicide")
                        heroInfoPanel[uniqueIdentifier].suicideIcon.visible = true
                        heroInfoPanel[uniqueIdentifier].suicideText = EasyCreateText(xTextOrigin + xSpacing * (playerIconLocation - playerOffset), drawFromTopRatio + 0.034, -1, "", F10)
                        heroInfoPanel[uniqueIdentifier].suicideText.visible = false

                        heroInfoPanel[uniqueIdentifier].gemIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation - playerOffset), 0.0074, 0.0078125, 0.01388, 0x00000095)
                        heroInfoPanel[uniqueIdentifier].gemIcon.textureId = drawMgr:GetTextureId("NyanUI/other/O_gem")
                        heroInfoPanel[uniqueIdentifier].gemIcon.visible = false

                        heroInfoPanel[uniqueIdentifier].sentryIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation - playerOffset), 0.0074 + 0.015, 0.0078125, 0.01388, 0x00000095)
                        heroInfoPanel[uniqueIdentifier].sentryIcon.textureId = drawMgr:GetTextureId("NyanUI/other/O_sentry")
                        heroInfoPanel[uniqueIdentifier].sentryIcon.visible = false
                        if heroIcon[playerIconLocation - playerOffset + 1] == nil then
                            heroIcon[playerIconLocation - playerOffset + 1] = {}
                            heroIcon[playerIconLocation - playerOffset + 1].activated = true
                            heroIcon[playerIconLocation - playerOffset + 1].name = heroInfo.name
                        end
                        if clickIcon[playerIconLocation - playerOffset + 1] == nil then 
                            local x = 0.7369791666666666
                            local y = 0.008333333333333333
                            local w = 0.011458333333333333
                            local h = 0.020370370370370372
                            local shringOffset = 0.0005
                            local i = playerIconLocation - playerOffset + 1
                            clickIcon[i] = {}
                            clickIcon[i].board = EasyCreateRect(x + i * 0.0145, y, w, h,0x8B008BFF)
                            clickIcon[i].back = EasyCreateRect(x + shringOffset + i * 0.0145, y + shringOffset * screenRatio, w - 2 * shringOffset, h - 2 * shringOffset * screenRatio, 0x000000FF)
                            clickIcon[i].mini = EasyCreateRect(x + shringOffset + i * 0.0145, y + shringOffset * screenRatio, w - 2 * shringOffset, h - 2 * shringOffset * screenRatio, 0x000000FF)
                        end
                    end
                end
                ------------------------------------------- CALCULATIONS -------------------------------------------
                if heroIcon[playerIconLocation - playerOffset + 1] ~= nil then
                    if heroIcon[playerIconLocation - playerOffset + 1].activated == true then
                        clickIcon[playerIconLocation - playerOffset + 1].back.textureId = drawMgr:GetTextureId("NyanUI/spellicons/doom_bringer_empty1")
                        clickIcon[playerIconLocation - playerOffset + 1].mini.textureId = drawMgr:GetTextureId("NyanUI/miniheroes/"..heroIcon[playerIconLocation - playerOffset + 1].name:gsub("npc_dota_hero_",""))
                    else
                        clickIcon[playerIconLocation - playerOffset + 1].mini.textureId = drawMgr:GetTextureId("NyanUI/spellicons/doom_bringer_empty1")
                    end    
                end 
                
                if heroInfo.alive then
                    heroInfoPanel[uniqueIdentifier].aliveFlag = 1

                else
                    heroInfoPanel[uniqueIdentifier].aliveFlag = 0
                end

                if upLandMine and landMineDamage ~= nil then
                    local landMineDamageDeal = (1 - heroInfo.dmgResist) * landMineDamage
                    heroInfoPanel[uniqueIdentifier].numberOfLandMineRequired = math.ceil(heroInfo.health / landMineDamageDeal) * heroInfoPanel[uniqueIdentifier].aliveFlag
                    heroInfoPanel[uniqueIdentifier].maxLandMineRequired = math.ceil(heroInfo.maxHealth / landMineDamageDeal)
                    local landMineString = tostring(heroInfoPanel[uniqueIdentifier].numberOfLandMineRequired).." / "..tostring(heroInfoPanel[uniqueIdentifier].maxLandMineRequired)
                    if heroInfoPanel[uniqueIdentifier].landMineText ~= nil then
                        heroInfoPanel[uniqueIdentifier].landMineText.text = landMineString
                        heroInfoPanel[uniqueIdentifier].landMineText.visible = true
                    end
                end

                if upRemoteMine and remoteMineDamage ~= nil then
                    local remoteMineDamageDeal = (1 - heroInfo.magicDmgResist) * remoteMineDamage
                    local remoteMineString = ""

                    if InvulnerableToRemoteMines(heroInfo) or heroInfo.magicDmgResist == 1 then
                        heroInfoPanel[uniqueIdentifier].numberOfRemoteMineRequired = math.ceil(heroInfo.health / 0) * heroInfoPanel[uniqueIdentifier].aliveFlag
                        heroInfoPanel[uniqueIdentifier].maxRemoteMineRequired = math.ceil(heroInfo.maxHealth / remoteMineDamageDeal)
                        remoteMineString = ("MAX")
                    else
                        heroInfoPanel[uniqueIdentifier].numberOfRemoteMineRequired = CalculateBombsRequired(heroInfo, remoteMineDamage, heroInfoPanel[uniqueIdentifier].aliveFlag)
                        heroInfoPanel[uniqueIdentifier].maxRemoteMineRequired = math.ceil(heroInfo.maxHealth / remoteMineDamageDeal)
                        remoteMineString = tostring(heroInfoPanel[uniqueIdentifier].numberOfRemoteMineRequired).." / "..tostring(heroInfoPanel[uniqueIdentifier].maxRemoteMineRequired)
                    end

                    if heroInfoPanel[uniqueIdentifier].remoteMineText ~= nil then
                        heroInfoPanel[uniqueIdentifier].remoteMineText.text = remoteMineString
                        heroInfoPanel[uniqueIdentifier].remoteMineText.visible = true
                    end
                end

                if upSuicide and suicideDamage ~= nil then
                    local suicideDamageDeal = (1 - heroInfo.dmgResist) * suicideDamage
                    if heroInfoPanel[uniqueIdentifier].suicideText ~= nil then
                        if heroInfo.alive then
                            if suicideDamageDeal > heroInfo.health then
                                heroInfoPanel[uniqueIdentifier].suicideText.text = "Yes"
                            else
                                heroInfoPanel[uniqueIdentifier].suicideText.text = "No"
                            end
                        else
                            if suicideDamageDeal > heroInfo.maxHealth then
                                heroInfoPanel[uniqueIdentifier].suicideText.text = "Yes"
                            else
                                heroInfoPanel[uniqueIdentifier].suicideText.text = "No"
                            end
                        end
                        heroInfoPanel[uniqueIdentifier].suicideText.visible = true
                    end
                end
                if ShowGem and heroInfoPanel[uniqueIdentifier].gemIcon ~= nil then
                    local gemCheck = heroInfo:FindItem("item_gem")
                    if gemCheck then
                        heroInfoPanel[uniqueIdentifier].gemIcon.visible = true
                    else
                        heroInfoPanel[uniqueIdentifier].gemIcon.visible = false
                    end
                end

                if ShowSentry and  heroInfoPanel[uniqueIdentifier].sentryIcon ~= nil then
                    local sentryCheck = heroInfo:FindItem("item_ward_sentry")
                    if sentryCheck then
                        heroInfoPanel[uniqueIdentifier].sentryIcon.visible = true
                    else
                        heroInfoPanel[uniqueIdentifier].sentryIcon.visible = false
                    end
                end
                if heroInfoPanel[uniqueIdentifier].numberOfRemoteMineRequired ~= nil then
                   
                    if AllowSelfDetonate and heroInfo.team ~= me.team and heroIcon[playerIconLocation - playerOffset + 1].activated == true then
                        AutoForceStaff(heroInfo, heroInfoPanel[uniqueIdentifier].numberOfRemoteMineRequired)
                        CalculateDamage(heroInfo, heroInfoPanel[uniqueIdentifier].numberOfRemoteMineRequired)
                    end
                end
            end
        end
    end

end

function Aggro(hero)
    myHero = entityList:GetMyPlayer()
    myHero:Attack(hero)
	
end

function MinesInformationDisplay()

    for i,v in ipairs(mines) do
        local onScreen = client:ScreenPosition(v.position)
        if v.team == me.team then
            if bombInformationArray.Damage == nil then
                bombInformationArray.Damage = {}
            end
		

            if v.health == 200 and bombInformationArray.Damage[v.handle] == nil then
                    if me:FindItem("item_ultimate_scepter") then
                        bombInformationArray.Damage[v.handle] = 150 * (me:GetAbility(6).level + 1) + 150
                    else
                        bombInformationArray.Damage[v.handle] = 150 * (me:GetAbility(6).level + 1)
                    end
            end

            if effect.Range == nil then
               effect.Range = {}
            end
            if effect.Visible == nil then
                effect.Visible = {}
            end
            if onScreen then
                if v.alive then    
                    if not effect.Range[v.handle] then
                        effect.Range[v.handle] = Effect(v,"range_display")
                        if v.health == 100 and ShowLandMineRange then
                            effect.Range[v.handle]:SetVector(1, Vector(200,0,0) )
                        elseif v.name == "npc_dota_techies_stasis_trap" and ShowStatisRange then
                            effect.Range[v.handle]:SetVector(1, Vector(450,0,0) )
                        elseif v.health == 200 and ShowRemoteMineRange then
                            effect.Range[v.handle]:SetVector(1, Vector(425,0,0) )
                        end
                    end
                    if v.visibleToEnemy then    
                        if not effect.Visible[v.handle] and ShowMineVisibility then
                            effect.Visible[v.handle] = Effect(v,"aura_shivas")
                            effect.Visible[v.handle]:SetVector(1, Vector(0,0,0) )
                        end
                    else
                        if  effect.Visible[v.handle] then
                            effect.Visible[v.handle] = nil
                            collectgarbage("collect")
                        end
                    end
                else
                    if  effect.Range[v.handle] then
                        effect.Range[v.handle] = nil
                        collectgarbage("collect")
                    end
                    if  effect.Visible[v.handle] then
                        effect.Visible[v.handle] = nil
                        collectgarbage("collect")
                    end
                end
            end
        end
    end
end

function ShowSelectedInformation(selectedUnits)
    local myPlayer = entityList:GetMyPlayer()
    local mySelection = myPlayer.selection
    local landMineCount = 0
    local statisCount = 0
    local remoteCount = 0
    local selectSelf = false
    if myDrawing[me.handle] == nil then
        myDrawing[me.handle] = {}
        
        myDrawing[me.handle].landMineIcon = EasyCreateRect(0.4921875 + 0.05677083333333333, 0.9064814814814814 , 0.0265625, 0.04814814814814815, 0x00000095)
        myDrawing[me.handle].landMineIcon.textureId = drawMgr:GetTextureId("NyanUI/other/npc_dota_techies_land_mine")
        myDrawing[me.handle].landMineIcon.visible = false
        myDrawing[me.handle].landMineText = EasyCreateText(0.5057291666666667 + 0.05677083333333333, 0.9592592592592593, -1, "0", F10)
        myDrawing[me.handle].landMineText.visible = false
        
        myDrawing[me.handle].statisIcon = EasyCreateRect(0.4921875 + 0.05677083333333333 * 2, 0.9064814814814814 , 0.0265625, 0.04814814814814815, 0x00000095)
        myDrawing[me.handle].statisIcon.textureId = drawMgr:GetTextureId("NyanUI/other/npc_dota_techies_stasis_trap")
        myDrawing[me.handle].statisIcon.visible = false
        myDrawing[me.handle].statisText = EasyCreateText(0.5057291666666667 + 0.05677083333333333 * 2, 0.9592592592592593, -1, "0", F10)
        myDrawing[me.handle].statisText.visible = false
        
        myDrawing[me.handle].remoteMineIcon = EasyCreateRect(0.4921875 + 0.05677083333333333 * 3, 0.9064814814814814 , 0.0265625, 0.04814814814814815, 0x00000095)
        myDrawing[me.handle].remoteMineIcon.textureId = drawMgr:GetTextureId("NyanUI/other/npc_dota_techies_remote_mine")
        myDrawing[me.handle].remoteMineIcon.visible = false
        myDrawing[me.handle].remoteMineText = EasyCreateText(0.5057291666666667 + 0.05677083333333333 * 3, 0.9592592592592593, -1, "0", F10)
        myDrawing[me.handle].remoteMineText.visible = false
    end
    
    
    for i = 1, #mySelection do
        if mySelection[i].name == "npc_dota_hero_techies" then
            selectSelf = true
        end
        
        if mySelection[i].health == 100 then
            landMineCount = landMineCount + 1
        end
        
        if mySelection[i].name == "npc_dota_techies_stasis_trap" then
            statisCount = statisCount + 1
            
        end
        
        if mySelection[i].health == 200 then
            remoteCount = remoteCount + 1
        end
    end
    if (landMineCount > 0 or statisCount > 0 or remoteCount > 0) and selectSelf == false then
        myDrawing[me.handle].landMineText.text = tostring(landMineCount)
        myDrawing[me.handle].statisText.text = tostring(statisCount)
        myDrawing[me.handle].remoteMineText.text = tostring(remoteCount)
        myDrawing[me.handle].landMineIcon.visible = true
        myDrawing[me.handle].landMineText.visible = true
        myDrawing[me.handle].statisIcon.visible = true
        myDrawing[me.handle].statisText.visible = true
        myDrawing[me.handle].remoteMineIcon.visible = true
        myDrawing[me.handle].remoteMineText.visible = true
        
    else
        myDrawing[me.handle].landMineIcon.visible = false
        myDrawing[me.handle].landMineText.visible = false
        myDrawing[me.handle].statisIcon.visible = false
        myDrawing[me.handle].statisText.visible = false
        myDrawing[me.handle].remoteMineIcon.visible = false
        myDrawing[me.handle].remoteMineText.visible = false
    end
end

function AutoForceStaff(hero, bombNeeded)
    if IsKeyDown(18) then
        if not effect.Range[me.handle] then
            effect.Range[me.handle] = Effect(me,"range_display")
        end
        if not effect.Range[me.handle * 2] then
            effect.Range[me.handle * 2] = Effect(me,"range_display")
        end
        effect.Range[me.handle]:SetVector(1, Vector(800,0,0))
        effect.Range[me.handle * 2]:SetVector(1, Vector(700,0,0))
        if hero.visible then
            local countBomb = 1
            bombInformationArray.HeroPredictedDamage[hero.handle]  = 0
            local realHealth = me:FindItem("item_ultimate_scepter") and (bombNeeded * (150 * (me:GetAbility(6).level + 1) + 150)) or (bombNeeded * (150 * (me:GetAbility(6).level + 1)))
            --local forcedHero = entityList:GetMouseover()
			local forcedHero = targetFind:GetClosestToMouse(100)

        if forcedHero ~= nil and forcedHero.handle == hero.handle then
                local predictedX = forcedHero.position.x + (math.cos(forcedHero.rotR) * 600)
                local predictedY = forcedHero.position.y + (math.sin(forcedHero.rotR) * 600)
                
                for j,value in ipairs(mines) do
                    if value.team == me.team and hero.team ~= me.team and hero.alive and value.alive and value.health == 200 then
                        local checkPrediction = isHeroInBombRange(predictedX, predictedY, value.position.x, value.position.y)
                        if checkPrediction and value:GetAbility(1).level == 1 then
                            bombInformationArray.HeroPredictedDamage[hero.handle] = bombInformationArray.HeroPredictedDamage[hero.handle] + bombInformationArray.Damage[value.handle]
                            if bombInformationArray.HeroPredictedDamage[hero.handle] >=  realHealth and hero.visible and hero.health > 0 then
                                local inForceRange = me.GetDistance2D(me, forcedHero) < 800
                                local inEulRange = me.GetDistance2D(me, forcedHero) < 700
                                local linkenHero  = forcedHero:IsLinkensProtected()
                                local forcestaff = me:FindItem("item_force_staff")
                                local eulScepter = me:FindItem("item_cyclone")
                                if linkenHero then
                                    if eulScepter and eulScepter.cd == 0 and me.mana >= eulScepter.manacost and inEulRange then
                                        me:CastAbility(eulScepter, forcedHero)
                                        break
                                    end
                                else
                                    if forcestaff and forcestaff.cd == 0 and me.mana >= forcestaff.manacost and inForceRange then
                                        me:CastAbility(forcestaff, forcedHero)
                                        break
                                    end
                                end
                            else
                                countBomb = countBomb + 1
                            end
                        end
                    end
                end
            end
        end
    else
        if  effect.Range[me.handle] then
            effect.Range[me.handle] = nil
            collectgarbage("collect")
        end
        if  effect.Range[me.handle * 2] then
            effect.Range[me.handle * 2] = nil
            collectgarbage("collect")
        end
    end
end

function isHeroInBombRange(x, y, center_x, center_y)
    if (math.pow((x - center_x),2) + math.pow((y - center_y), 2)) < math.pow(425, 2) then
        return true
    else
        return false
    end
end

function CalculateDamage(hero, bombNeeded)
    local countBomb = 1
    bombInformationArray.HeroDamage[hero.handle]  = 0
    hero.bombCountArray = {}
    actualHealth = me:FindItem("item_ultimate_scepter") and (bombNeeded * (150 * (me:GetAbility(6).level + 1) + 150)) or (bombNeeded * (150 * (me:GetAbility(6).level + 1)))

    for j,value in ipairs(mines) do
        if value.team == me.team and hero.team ~= me.team and hero.alive and value.alive and value.health == 200 then
            check = value.GetDistance2D(value, hero) < 425
            if check and value:GetAbility(1).level == 1 then
                bombInformationArray.HeroDamage[hero.handle] = bombInformationArray.HeroDamage[hero.handle] + bombInformationArray.Damage[value.handle]
                hero.bombCountArray[countBomb] = value
                if bombInformationArray.HeroDamage[hero.handle] >=  actualHealth and hero.visible and hero.health > 0 then
                    SelfDetonate(hero)
                    break
                else
                    countBomb = countBomb + 1
                end
            end
        end
    end
end

function SelfDetonate(hero)
    for i = 1, #hero.bombCountArray do
        v = hero.bombCountArray[i]
        if InvulnerableToRemoteMines(hero) == false  and not IsKeyDown(17) then
            v:CastAbility(v:GetAbility(1))
        end
    end
end

function CalculateBombsRequired (hero, bombDamage, alive)

    local heroHP = hero.health
    local heroMP = hero.mana
    local extraMagicPercentBlocked = 0
    local finalPercentageBlocked = hero.magicDmgResist
    ---- Damage Amplification ----
    if hero:DoesHaveModifier("modifier_undying_flesh_golem_plague_aura") and hero.team ~= me.team then

        local y1 = undyingMaxPercentAmplified
        local y2 = undyingMinPercentAmplified
        local x1 = 200
        local x2 = 750
        if hero.GetDistance2D(undying, hero) > 750 then
            undyingPercentAmplified = undyingMinPercentAmplified
        elseif hero.GetDistance2D(undying, hero) < 200 then
            undyingPercentAmplified = undyingMaxPercentAmplified
        else
            undyingPercentAmplified = y1 +((y2 - y1)/(x2 - x1)) * (hero.GetDistance2D(undying, hero) - x1)
        end
        extraMagicPercentBlocked = extraMagicPercentBlocked - undyingPercentAmplified
    end

    if hero:DoesHaveModifier("modifier_shadow_demon_soul_catcher") and hero.team ~= me.team then
        extraMagicPercentBlocked = extraMagicPercentBlocked - demonPercentAmplified
    end

    if hero:DoesHaveModifier("modifier_chen_penitence") and hero.team ~= me.team then
        extraMagicPercentBlocked = extraMagicPercentBlocked - chenPercentAmplified
    end

    if hero:DoesHaveModifier("modifier_slardar_sprint") and hero.team ~= me.team then
        extraMagicPercentBlocked = extraMagicPercentBlocked - 0.15
    end

    if hero:DoesHaveModifier("modifier_bloodseeker_bloodrage") and hero.team ~= me.team then

        extraMagicPercentBlocked = extraMagicPercentBlocked - bloodseekerPercentAmplified
    end

    if hero:DoesHaveModifier("modifier_item_mask_of_madness_berserk") and hero.team ~= me.team then
        extraMagicPercentBlocked = extraMagicPercentBlocked - 0.3
    end



    ---- Damage Reduction ----
    if hero:DoesHaveModifier("modifier_kunkka_ghost_ship_damage_absorb") and hero.team ~= me.team then
        heroHP = heroHP * 2
    elseif hero:DoesHaveModifier("modifier_abaddon_borrowed_time_damage_redirect") and hero.team ~= me.team then
        extraMagicPercentBlocked = extraMagicPercentBlocked + 0.35
    end

    if hero:DoesHaveModifier("modifier_wisp_overcharge") and hero.team ~= me.team then
        extraMagicPercentBlocked = extraMagicPercentBlocked + wispPercentBlocked

    end

    if hero:DoesHaveModifier("modifier_abaddon_aphotic_shield") and hero.team ~= me.team then
        heroHP = heroHP + abaddonDamageBlocked
    end

    if hero:DoesHaveModifier("modifier_ember_spirit_flame_guard") and hero.team ~= me.team then
        local emberSpiritBlockArray = {50, 200, 350, 500}
        local damageBlocked = emberSpiritBlockArray[hero:GetAbility(3).level]
        local emberPercentageBlocked = hero.magicDmgResist
        emberPercentageBlocked = emberPercentageBlocked + extraMagicPercentBlocked - extraMagicPercentBlocked * emberPercentageBlocked
        heroHP = heroHP + damageBlocked * (1 - emberPercentageBlocked)
    end
    if hero.name == "npc_dota_hero_spectre" and hero.team ~= me.team and hero:GetAbility(3).level ~= 0 then
        local spectreBlockArray = {0.10, 0.14, 0.18, 0.22}
        local percentageBlocked = spectreBlockArray[hero:GetAbility(3).level]
        extraMagicPercentBlocked = extraMagicPercentBlocked + percentageBlocked
    end

    if hero.classId == CDOTA_Unit_Hero_TemplarAssassin then
        local templarBlockArray = {3, 4, 5, 6}
        local instanceBlocked = templarBlockArray[hero:GetAbility(1).level]
        finalPercentageBlocked = finalPercentageBlocked + extraMagicPercentBlocked - extraMagicPercentBlocked * finalPercentageBlocked
        templarSpellReadyCheck = hero:GetAbility(1).cd == 0
        if templarSpellReadyCheck == false then
            heroHP = heroHP + (1 - finalPercentageBlocked) * bombDamage * instanceBlocked
        end
    end
    if hero:DoesHaveModifier("modifier_medusa_mana_shield") and hero.team ~= me.team then

        local medusaBlockArray = {1.6, 1.9, 2.2, 2.5}
        local damagePerMana = medusaBlockArray[hero:GetAbility(3).level]
        local haveHP = true
        local haveMP = true
        local bombCountMedusa = 1
        hpLeftMedusa = heroHP
        mpLeftMedusa = heroMP
        finalPercentageBlocked = finalPercentageBlocked + extraMagicPercentBlocked - extraMagicPercentBlocked * finalPercentageBlocked
        if hero:DoesHaveModifier("modifier_treant_living_armor") and hero.team ~= me.team then
        local treantLivingArmor = hero:FindModifier("modifier_treant_living_armor")
            if treantLivingArmor then
                treantLivingArmorStack = treantLivingArmor.stacks
            end
            while haveHP and haveMP do
                if treantLivingArmorStack > 0 then
                    remoteMineDamageDealToHP = (1 - finalPercentageBlocked) * bombDamage * 0.4 - treantDamageBlocked
                else
                    remoteMineDamageDealToHP = (1 - finalPercentageBlocked) * bombDamage * 0.4
                end

                remoteMineDamageDealToMP = (bombDamage * 0.6)  / damagePerMana
                hpLeftMedusa = hpLeftMedusa - remoteMineDamageDealToHP
                mpLeftMedusa = mpLeftMedusa - remoteMineDamageDealToMP

                if hpLeftMedusa < 0 and mpLeftMedusa < 0 then -- HP depletes same time, MP doesn't matter
                    haveHP = false
                    haveMP = false
                elseif mpLeftMedusa < 0 and hpLeftMedusa > 0 then --MP depletes first, MP matters
                    haveHP = true
                    haveMP = false
                elseif mpLeftMedusa > 0 and hpLeftMedusa < 0 then -- HP depletes first, MP doesn't matter
                    haveHP = false
                    haveMP = true
                else
                    bombCountMedusa = bombCountMedusa + 1
                    if treantLivingArmorStack > 0 then
                        treantLivingArmorStack = treantLivingArmorStack - 1
                    end
                end
            end
            if haveHP == true and haveMP == false then
                bombCountMedusa = math.ceil(bombCountMedusa + hpLeftMedusa / ((1 - finalPercentageBlocked) * bombDamage))
            else
                bombCountMedusa = math.ceil(bombCountMedusa)
            end

        else
            while haveHP and haveMP do

                remoteMineDamageDealToHP = (1 - finalPercentageBlocked) * bombDamage * 0.4
                remoteMineDamageDealToMP = (bombDamage * 0.6)  / damagePerMana
                hpLeftMedusa = hpLeftMedusa - remoteMineDamageDealToHP
                mpLeftMedusa = mpLeftMedusa - remoteMineDamageDealToMP

                if hpLeftMedusa < 0 and mpLeftMedusa < 0 then -- HP depletes same time, MP doesn't matter
                    haveHP = false
                    haveMP = false
                elseif mpLeftMedusa < 0 and hpLeftMedusa > 0 then --MP depletes first, MP matters
                    haveHP = true
                    haveMP = false
                elseif mpLeftMedusa > 0 and hpLeftMedusa < 0 then -- HP depletes first, MP doesn't matter
                    haveHP = false
                    haveMP = true
                else
                    bombCountMedusa = bombCountMedusa + 1
                end
            end
            if haveHP == true and haveMP == false then
                bombCountMedusa = math.ceil(bombCountMedusa + hpLeftMedusa / ((1 - finalPercentageBlocked) * bombDamage))
            else
                bombCountMedusa = math.ceil(bombCountMedusa)
            end

        end
        return bombCountMedusa

    elseif hero:DoesHaveModifier("modifier_visage_gravekeepers_cloak") and hero.team ~= me.team then
        local bombCountVisage = 1
        local visageBlockArray = {0.03, 0.06, 0.12, 0.16}
        local visagePercentBlocked = visageBlockArray[hero:GetAbility(3).level]
        local visageCloak = hero:FindModifier("modifier_visage_gravekeepers_cloak")
        if visageCloak then
                visageCloakStack = visageCloak.stacks
        end
        local visageHP = heroHP
        if hero:DoesHaveModifier("modifier_treant_living_armor") and hero.team ~= me.team then
            local treantLivingArmor = hero:FindModifier("modifier_treant_living_armor")
            if treantLivingArmor then
                treantLivingArmorStack = treantLivingArmor.stacks
            end
            local haveHP = true
            finalPercentageBlocked = finalPercentageBlocked + extraMagicPercentBlocked - extraMagicPercentBlocked * finalPercentageBlocked
            visageBaseMagicResistance = (finalPercentageBlocked - visageCloakStack * visagePercentBlocked ) / (1 - visageCloakStack * visagePercentBlocked)
            while haveHP do
                finalPercentageBlockedVisage = visageBaseMagicResistance + visagePercentBlocked * visageCloakStack - visagePercentBlocked * visageCloakStack * visageBaseMagicResistance
                if treantLivingArmorStack > 0 then
                    remoteMineDamageDealToHP = (1 - finalPercentageBlockedVisage) * bombDamage - treantDamageBlocked
                else
                    remoteMineDamageDealToHP = (1 - finalPercentageBlockedVisage) * bombDamage
                end
                visageHP = visageHP - remoteMineDamageDealToHP

                if visageHP < 0 then
                    haveHP = false
                else
                    bombCountVisage = bombCountVisage + 1
                    if visageCloakStack > 0 then
                        visageCloakStack = visageCloakStack - 1
                    end
                    if treantLivingArmorStack > 0 then
                        treantLivingArmorStack = treantLivingArmorStack - 1
                    end

                end
            end
        else
            local haveHP = true
            finalPercentageBlocked = finalPercentageBlocked + extraMagicPercentBlocked - extraMagicPercentBlocked * finalPercentageBlocked
            visageBaseMagicResistance = (finalPercentageBlocked - visageCloakStack * visagePercentBlocked ) / (1 - visageCloakStack * visagePercentBlocked)
            while haveHP do
                finalPercentageBlockedVisage = visageBaseMagicResistance + visagePercentBlocked * visageCloakStack - visagePercentBlocked * visageCloakStack * visageBaseMagicResistance
                remoteMineDamageDealToHP = (1 - finalPercentageBlockedVisage) * bombDamage
                visageHP = visageHP - remoteMineDamageDealToHP

                if visageHP < 0 then
                    haveHP = false
                else
                    bombCountVisage = bombCountVisage + 1
                    if visageCloakStack > 0 then
                        visageCloakStack = visageCloakStack - 1
                    end

                end
            end
        end
        return bombCountVisage



    else
        finalPercentageBlocked = finalPercentageBlocked + extraMagicPercentBlocked - extraMagicPercentBlocked * finalPercentageBlocked
        if hero:DoesHaveModifier("modifier_treant_living_armor") and hero.team ~= me.team then
            local treantLivingArmor = hero:FindModifier("modifier_treant_living_armor")
            local bombCountTrent = 1
            if treantLivingArmor then
                treantLivingArmorStack = treantLivingArmor.stacks
            end
            local tempHP = heroHP
            local haveHP = true
            while haveHP do
                if treantLivingArmorStack > 0 then
                    remoteMineDamageDealToHP = (1 - finalPercentageBlocked) * bombDamage - treantDamageBlocked
                else
                    remoteMineDamageDealToHP = (1 - finalPercentageBlocked) * bombDamage
                end
                tempHP = tempHP - remoteMineDamageDealToHP

                if tempHP < 0 then
                    haveHP = false
                else
                    bombCountTrent = bombCountTrent + 1
                    if treantLivingArmorStack > 0 then
                        treantLivingArmorStack = treantLivingArmorStack - 1
                    end

                end
            end

            return bombCountTrent
        else
            return math.ceil(heroHP / ((1 - finalPercentageBlocked) * bombDamage))
        end
    end



end

function Sleep(duration)
    sleepTick = currentTick + duration
end


function InvulnerableToRemoteMines(hero)
    for i,modifiers in ipairs(InvulnerableToRemoteMinesList) do
        if hero:DoesHaveModifier(modifiers) then
            return true
        end
    end
    return false
end

function GameClose()
    sleepTick = 0
    landMineDamage = 0
    remoteMineDamage = 0
    heroInfoPanel = {}
    upLandMine = false
    upRemoteMine = false
    upSuicide = false
    effect = {}
    heroIcon = {}
    clickIcon = {}
    bombCountArray = {}
    bombInformationArray = {}
    myDrawing = {}
    collectgarbage("collect")
end

script:RegisterEvent(EVENT_TICK,Tick)
script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_KEY,Key)
