--<<Complete bot for Meepo(Full Version), made by Moones>>

--LIBRARIES--

require("libs.ScriptConfig")
require("libs.Utils")
require("libs.TargetFind")
require("libs.Animations")
require("libs.SkillShot")
require("libs.AbilityDamage")
require("libs.Res")
require("libs.DrawManager3D")

--END of LIBRARIES--

--INFO--

--[[
        +-------------------------------------------------+              
        |                                                 |          
        |          iMeepo Script - Made by Moones         |        
        |          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^         |     
        +-------------------------------------------------+    
                                                                                                                                   
        =+=+=+=+=+=+=+=+=+ VERSION 0.818 +=+=+=+=+=+=+=+=+=+
 
        Description:
        ------------
        
        - Script which controls Meepo for you. Goal was to acomplish automatic playing through whole game, but so far human control is still needed. 
        - Hold N to kill enemy, Hold H to run away, If you are lanning with meepo press L.
        
        TODO:
        ----
        
        - Waypoints
        - AUTO FOUNTAIN DIVE - ......
        - BEHAVIOURS IN SPECIAL SITUATIONS - detect when your meepo could be ganked etc..

]]--

----Version
local currentVersion = 0.818
local Beta = ""

--END of INFO--

--SETTINGS--

----ScriptConfig----
local config = ScriptConfig.new()
config:SetParameter("ChaseKey", "N", config.TYPE_HOTKEY)
config:SetParameter("RetreatKey", "H", config.TYPE_HOTKEY)
config:SetParameter("HealKey", "G", config.TYPE_HOTKEY)
config:SetParameter("FarmJungleKey", "B", config.TYPE_HOTKEY)
config:SetParameter("AllMeeposIdle", "V", config.TYPE_HOTKEY)
config:SetParameter("Debug", "P", config.TYPE_HOTKEY)
config:SetParameter("Lane", "L", config.TYPE_HOTKEY)
config:SetParameter("PoofBindInDota", "W", config.TYPE_HOTKEY)
config:SetParameter("EarthbindBindInDota", "Q", config.TYPE_HOTKEY)
config:SetParameter("StopKeyBindInDota", "S", config.TYPE_HOTKEY)
config:SetParameter("AllPoofToSelected", "U", config.TYPE_HOTKEY)
config:SetParameter("Meepo1", 49, config.TYPE_HOTKEY) -- 49 is Key Code for 1
config:SetParameter("Meepo2", 50, config.TYPE_HOTKEY) -- 50 is Key Code for 2 for all KeyCodes go to http://www.zynox.net/forum/threads/336-KeyCodes
config:SetParameter("Meepo3", 51, config.TYPE_HOTKEY) -- 3
config:SetParameter("Meepo4", 52, config.TYPE_HOTKEY) -- 4
config:SetParameter("Meepo5", 53, config.TYPE_HOTKEY) -- 5
config:SetParameter("EnableAutoBind", true, config.TYPE_BOOL)
config:SetParameter("AutoGoFarmAfterChase", true, config.TYPE_BOOL)
config:SetParameter("UseBoTs", true, config.TYPE_BOOL)
config:SetParameter("AutoPush", true, config.TYPE_BOOL)
config:SetParameter("MinHPToFightPercent", 50, config.TYPE_NUMBER)
config:SetParameter("HPPercentToGoHealWhenHoldingKey", 50, config.TYPE_NUMBER)
config:SetParameter("VersionInfoPosX", 680, config.TYPE_NUMBER)
config:SetParameter("VersionInfoPosY", 820, config.TYPE_NUMBER)
config:SetParameter("MinimapNumbersXMove", 0, config.TYPE_NUMBER)
config:Load()

-----ScriptConfig Variables----
local mainkey = config.ChaseKey
local retreatkey = config.RetreatKey
local farmJkey = config.FarmJungleKey
local debugKey = config.Debug
local idleKey = config.AllMeeposIdle
local laneKey = config.Lane
local meepo1 = config.Meepo1
local meepo2 = config.Meepo2
local meepo3 = config.Meepo3
local meepo4 = config.Meepo4
local meepo5 = config.Meepo5
local minimapMove = config.MinimapNumbersXMove
local minhp = config.MinHPToFightPercent
local healpercent = config.HPPercentToGoHealWhenHoldingKey
local healkey = config.HealKey
local stop1 = config.PoofBindInDota
local stop2 = config.EarthbindBindInDota
local stop3 = config.StopKeyBindInDota

-----Local Script Variables----
local reg = false local myId = nil local attack = 0 local move = 0 local start = false local meepoTable = {} local meepos = nil
local active = true local monitor = client.screenSize.x/1920 local DWS = {} local castingEarthbind = {0,0,0,0,0,0,0} local poofDamage = { 0, 0 }
local F14 = drawMgr:CreateFont("F14","Tahoma",client.screenSize.x*0.01,600) local meepoStateSigns = {} local base = nil local allies = nil local enemies = nil
local meepoNumberSigns = {} local F15 = drawMgr:CreateFont("F15","Tahoma",50*monitor,600*monitor) local entitiesForPush = {} local meepoMinimapNumberSigns = {}
local F13 = drawMgr:CreateFont("F13","Tahoma",16*monitor,600*monitor) local spellDamageTable = {} local visibleCamps = {} local campSigns = {} 
local outdated = false local F12 = drawMgr:CreateFont("F12","Tahoma",13*monitor,600*monitor) local versionSign = drawMgr:CreateText(config.VersionInfoPosX,config.VersionInfoPosY,0x66FF33FF,"",F14)
local retreat = false local retreattime = nil local mousehoverCamp = nil local closestCamp = nil local retreatStartTime = nil local lichJumpRange = 575
local dodgedistance = nil local dodgeradius = nil local aoeStarttime = nil local start,vec = nil,nil local infoSign = drawMgr:CreateText(config.VersionInfoPosX,config.VersionInfoPosY+20,-1,"",F12)
local retreatkeyCount = 0 local doubleclickTime = nil local EthDmg = 0 local eff = nil local ctrl = 17 local gameTime = 0 local enemyTeam = nil local meTeam = nil
local me = nil local player = nil local targetlock = false local statusText = drawMgr:CreateText(10*monitor,580*monitor,99333580,"",F14) statusText.visible = false local victim = nil

----Local Meepo States----
local STATE_NONE, STATE_CHASE, STATE_FARM_JUNGLE, STATE_FARM_LANE, STATE_LANE, STATE_PUSH, STATE_HEAL, STATE_ESCAPE, STATE_POOF_OUT, STATE_MOVE, STATE_STACK = 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11

----States Signs----
local statesSigns = {
        {"Idling", -1}, 
        {"Chasing", 0x17E317FF},
        {"Farming and Stacking Jungle", 0x65d9f7ff},
        {"Farming Lane", 0x3375ffff},
        {"Laninng", 0xbf00bfff},
        {"Pushing Lane", 0xf3f00bff},
        {"Healing", 0xff6b00ff},
        {"Escaping", 0xfe86c2ff},
        {"Poofing Out", 0x008321ff},
        {"Moving", 0xa46900ff},
        {"Stacking", 0xa89500ff}
}

----Jungle Camps positions, Stacks Positions----
local JungleCamps = {
        {position = Vector(-1131,-4044,127), stackPosition = Vector(-2498.94,-3517.86,128), waitPosition = Vector(-1401.69,-3791.52,128), team = 2, id = 1, farmed = false, lvlReq = 8, visible = false, visTime = 0, stacking = false},
        {position = Vector(-366,-2945,127), stackPosition = Vector(-534.219,-1795.27,128), waitPosition = Vector(536,-3001,256), team = 2, id = 2, farmed = false, lvlReq = 3, visible = false, visTime = 0, stacking = false},
        {position = Vector(1606.45,-3433.36,256), stackPosition = Vector(1325.19,-5108.22,256), waitPosition = Vector(1541.87,-4265.38,256), team = 2, id = 3, farmed = false, lvlReq = 8, visible = false, visTime = 0, stacking = false},
        {position = Vector(3126,-3439,256), stackPosition = Vector(4410.49,-3985,256), waitPosition = Vector(3401.5,-4233.39,256), team = 2, id = 4, farmed = false, lvlReq = 3, visible = false, visTime = 0, stacking = false},
        {position = Vector(3031.03,-4480.06,256), stackPosition = Vector(1368.66,-5279.04,256), waitPosition = Vector(2939.61,-5457.52,256), team = 2, id = 5, farmed = false, lvlReq = 1, visible = false, visTime = 0, stacking = false},
        {position = Vector(-2991,191,256), stackPosition = Vector(-3483,-1735,247), waitPosition = Vector(-2433,-356,256), team = 2, id = 6, farmed = false, lvlReq = 12, visible = false, visTime = 0, ancients = true, stacking = false},
        {position = Vector(1167,3295,256), stackPosition = Vector(570.86,4515.96,256), waitPosition = Vector(1011,3656,256), team = 3, id = 7, farmed = false, lvlReq = 8, visible = false, visTime = 0, stacking = false},
        {position = Vector(-244,3629,256), stackPosition = Vector(-1170.27,4581.59,256), waitPosition = Vector(-515,4845,256), team = 3, id = 8, farmed = false, lvlReq = 3, visible = false, visTime = 0, stacking = false},
        {position = Vector(-1588,2697,127), stackPosition = Vector(-1302,3689.41,136.411), waitPosition = Vector(-1491,2986,127), team = 3, id = 9, farmed = false, lvlReq = 3, visible = false, visTime = 0, stacking = false},
        {position = Vector(-3157.74,4475.46,256), stackPosition = Vector(-3296.1,5508.48,256), waitPosition = Vector(-3086,4924,256), team = 3, id = 10, farmed = false, lvlReq = 1, visible = false, visTime = 0, stacking = false},
        {position = Vector(-4382,3612,256), stackPosition = Vector(-3026.54,3819.69,132.345), waitPosition = Vector(-3995,3984,256), team = 3, id = 11, farmed = false, lvlReq = 8, visible = false, visTime = 0, stacking = false},
        {position = Vector(4026,-709.943,128), stackPosition = Vector(2228.46,-1046.78,128), waitPosition = Vector(3122,-1158.69,128), team = 3, id = 12, farmed = false, lvlReq = 12, visible = false, visTime = 0,  ancients = true, stacking = false}
}

--END of SETTINGS--

--GLOBAL CONSTANTS--

----Key Function

function Key(msg, code)
        local me = me 
        local player = player
        if client.chat or client.console or Animations.maxCount < 1 or not PlayingGame() or client.shopOpen or me.health < 0 then return end
        if msg == RBUTTON_DOWN and shop() and client.mousePosition.x < 10000 then
                local selection = player.selection
                for h, smeepo in pairs(selection) do
                        if meepoTable[smeepo.handle] and meepoTable[smeepo.handle].state ~= STATE_LANE and meepoTable[smeepo.handle].state ~= STATE_MOVE and meepoTable[smeepo.handle].state ~= STATE_NONE then
                                --Updating state of meepo
                                meepoTable[smeepo.handle].state = STATE_NONE
                        end
                end
        elseif msg == LBUTTON_DOWN and client.mouseScreenPosition.x > 300 then
                local me = entityList:GetMyHero()
                if not me then return end
                local targetFind = targetFind
                local mOver = targetFind:GetClosestToMouse(me,999999)
                if mOver and GetDistance2D(mOver, client.mousePosition) < 300 then 
                        victim = mOver 
                        targetlock = true
                        return false
                elseif victim then
                        victim = nil
                        targetlock = false
                        return false
                end
        elseif msg == KEY_UP and not IsKeyDown(ctrl) then       
                if code == mainkey or code == healkey then
                        return true
                elseif code == farmJkey then
                        local selection = player.selection
                        for h, smeepo in pairs(selection) do
                                if meepoTable[smeepo.handle] then
                                        --Updating state of meepo
                                        local distance = GetDistance2D
                                        local hovc = closestCamp and distance(client.mousePosition,closestCamp.position) < 100
                                        if meepoTable[smeepo.handle].state ~= STATE_STACK and meepoTable[smeepo.handle].state ~= STATE_HEAL and meepoTable[smeepo.handle].state ~= STATE_POOF_OUT and meepoTable[smeepo.handle].state ~= STATE_ESCAPE and 
                                        (meepoTable[smeepo.handle].state ~= STATE_FARM_JUNGLE or hovc) then
                                                if hovc then
                                                        meepoTable[smeepo.handle].camp = closestCamp
                                                        meepoTable[smeepo.handle].hoveredCamp = true
                                                else
                                                        meepoTable[smeepo.handle].camp = nil
                                                        meepoTable[smeepo.handle].hoveredCamp = false
                                                end
                                                meepoTable[smeepo.handle].lastcamp = nil
                                                meepoTable[smeepo.handle].state = STATE_FARM_JUNGLE
                                        elseif meepoTable[smeepo.handle].state == STATE_FARM_JUNGLE or meepoTable[smeepo.handle].state == STATE_PUSH then
                                                meepoTable[smeepo.handle].camp = nil
                                                meepoTable[smeepo.handle].lastcamp = nil
                                                meepoTable[smeepo.handle].state = STATE_STACK
                                        else
                                                meepoTable[smeepo.handle].state = STATE_NONE
                                        end
                                end
                        end
                        return true
                elseif code == stop1 or code == stop2 or code == stop3 then
                        local selection = player.selection
                        for h, smeepo in pairs(selection) do
                                if meepoTable[smeepo.handle] and meepoTable[smeepo.handle].state ~= STATE_LANE and meepoTable[smeepo.handle].state ~= STATE_MOVE and meepoTable[smeepo.handle].state ~= STATE_NONE then
                                        --Updating state of meepo
                                        meepoTable[smeepo.handle].state = STATE_NONE
                                end
                        end
                elseif code == idleKey then
                        for h, smeepo in pairs(meepoTable) do
                                --Updating state of meepo
                                if meepoTable[h] then
                                        meepoTable[h].state = STATE_NONE
                                end
                        end
                        return true
                elseif code == laneKey then
                        local selection = player.selection
                        for h, smeepo in pairs(selection) do
                                if meepoTable[smeepo.handle] then
                                        --Updating state of meepo
                                        if meepoTable[smeepo.handle].state ~= STATE_POOF_OUT and meepoTable[smeepo.handle].state ~= STATE_ESCAPE and 
                                        meepoTable[smeepo.handle].state ~= STATE_LANE then
                                                meepoTable[smeepo.handle].state = STATE_LANE
                                                --print("laneKey")
                                        elseif meepoTable[smeepo.handle].state == STATE_LANE then
                                                meepoTable[smeepo.handle].state = STATE_NONE
                                        end
                                end
                        end
                        return true
                elseif code == config.AllPoofToSelected then
                        local selection = player.selection
                        if not selection[1] then return end
                        local selected = selection[1]
                        for number,meepo in pairs(meepos) do
                                local poof = meepoTable[meepo.handle].poof
                                meepo:CastAbility(poof,selected.position)
                        end
                        return true
                elseif code == debugKey then
                        SetDebugState(not IsDebugActive())
                        return true
                elseif config.EnableAutoBind and (code == meepo1 or code == meepo2 or code == meepo3 or code == meepo4 or code == meepo5) and meepos then
                        for number,meepo in pairs(meepos) do
                                if meepo.alive then
                                        local meepoUlt = meepo:GetAbility(4)
                                        local meeponumber = (meepoUlt:GetProperty( "CDOTA_Ability_Meepo_DividedWeStand", "m_nWhichDividedWeStand" ) + 1)
                                        if code == meepo1 and meeponumber == 1 then
                                                SelectUnit(meepo)
                                                return true
                                        elseif code == meepo2 and meeponumber == 2 then
                                                SelectUnit(meepo)
                                                return true
                                        elseif code == meepo3 and meeponumber == 3 then
                                                SelectUnit(meepo)
                                                return true
                                        elseif code == meepo4 and meeponumber == 4 then
                                                SelectUnit(meepo)
                                                return true
                                        elseif code == meepo5 and meeponumber == 5 then
                                                SelectUnit(meepo)
                                                return true
                                        end
                                end
                        end
                elseif code == retreatkey then
                        if retreatkeyCount == 0 then
                                retreatkeyCount = 1
                        elseif retreatkeyCount == 1 then
                                retreatkeyCount = 2
                                for number,meepo in pairs(meepoTable) do
                                        meepoTable[number].state = STATE_ESCAPE
                                        meepoTable[number].retreat = true
                                end
                        end
                        return true
                end
        end
end

----Main tick function--
function Main(tick)
        
        gameTime = client.gameTime 
        
        --VersionInfo
        if gameTime > 1 then
                versionSign.visible = false
                infoSign.visible = false
        else
                local up,ver,beta,info = Version()
                if up then
                        if beta ~= "" then
                                versionSign.text = "Your version of iMeepo is up-to-date! (v"..currentVersion.." "..Beta..")"
                        else
                                versionSign.text = "Your version of iMeepo is up-to-date! (v"..currentVersion..")"
                        end
                        versionSign.color = 0x66FF33FF
                        if info then
                                infoSign.text = info
                                infoSign.visible = true
                        end
                end
                if outdated then
                        if beta ~= "" then
                                versionSign.text = "Your version of iMeepo is OUTDATED (Yours: v"..currentVersion.." "..Beta.." Current: v"..ver.." "..beta.."), send me email to moones@email.cz to get current one!"
                        else
                                versionSign.text = "Your version of iMeepo is OUTDATED (Yours: v"..currentVersion.." "..Beta.." Current: v"..ver.."), send me email to moones@email.cz to get current one!"
                        end
                        versionSign.color = 0xFF6600FF
                        if info then
                                infoSign.text = info
                                infoSign.visible = true
                        end
                end
                versionSign.visible = true
        end
        
        if not PlayingGame() or Animations.maxCount < 1 then return end
        
        --Local function variables
        local me = me local ID = me.classId if ID ~= myId then Close() end local player = player
        local DWSMain = me:GetAbility(4)
        local ethereal = me:FindItem("item_ethereal_blade") if not enemyTeam then enemyTeam = me:GetEnemyTeam() end
        local mOver = entityList:GetMouseover() local numberOfNotVisibleEnemies = 0 if not meTeam then meTeam = me.team end
        local allchase = false local myHand = me.handle local dangerousPosition = nil local distance = GetDistance2D
        local mathmin,mathmax,mathcos,mathsin,mathceil,mathrad,mathsqrt,mathabs,mathrad,mathfloor,mathatan,mathdeg = math.min,math.max,math.cos,math.sin,math.ceil,math.rad,math.sqrt,math.abs,math.rad,math.floor,math.atan,math.deg
        local mousePosition = client.mousePosition local latency = client.latency local IsKeyDown = IsKeyDown local aliveenemies = 0
                
        --Collecting Meepos
        if me.alive then
                if (DWS and not DWS[1]) or (allies and #allies < 5) or (enemies and (#enemies < 5 or not enemies[5].hero)) then
                        DWS[1] = DWSMain.level
                        meepos = entityList:GetEntities({type = LuaEntity.TYPE_MEEPO, team = meTeam})
                        allies = entityList:GetEntities({type = LuaEntity.TYPE_HERO, team = meTeam, illusion=false})
                        --Get enemies
                        enemies = entityList:GetEntities({type = LuaEntity.TYPE_HERO, team = enemyTeam, illusion = false})
                        --Get Bear!!
                        local bear = entityList:GetEntities({classId = CDOTA_Unit_SpiritBear, team = enemyTeam})[1]
                        if bear then
                                enemies[6] = bear
                        end
                        collectMeepos(meepos)
                elseif DWS[1] < DWSMain.level then
                        meepos = entityList:GetEntities({type = LuaEntity.TYPE_MEEPO, team = meTeam})
                        allies = entityList:GetEntities({type = LuaEntity.TYPE_HERO, team = meTeam})
                        collectMeepos(meepos)
                        DWS[1] = DWSMain.level
                elseif not DWS[2] and me:AghanimState() then
                        meepos = entityList:GetEntities({type = LuaEntity.TYPE_MEEPO, team = meTeam})
                        allies = entityList:GetEntities({type = LuaEntity.TYPE_HERO, team = meTeam})
                        collectMeepos(meepos)
                        DWS[2] = true
                end
        end
        
        local meepos, enemies, allies = meepos, enemies, allies
        local tempmeepoTable = meepoTable
        
        if not tempmeepoTable[myHand] then return end
        
        local myInfo = tempmeepoTable[myHand]

        --Getting Poof Damage
        local poofDamage2 = poofDamage
        local poof = myInfo.poof
        if poof and poof.level > 0 and (not poofDamage2 or poofDamage2[2] < poof.level) then
                poofDamage = { AbilityDamage.GetDamage(poof), poof.level }
        end
        
        --SwitchingTreads back to agility
        SwitchTreads(true)
        
        --KS with ethereal
        if ethereal and SleepCheck("eth") then
                EthDmg = AbilityDamage.GetDamage(ethereal)*1.4
                Sleep(10000,"eth")
        end
        local EthDmg = EthDmg
        
        ----print(me.classId)
        --base
        if not base then
                base = entityList:GetEntities({classId = CDOTA_Unit_Fountain,team = meTeam})[1]
        end
        
        --neutrals
        local neutrals = entityList:GetEntities({team=LuaEntity.TEAM_NEUTRAL})
        
        if targetlock then
                if victim and victim.alive then
                        statusText.text = "LOCKED on "..client:Localize(victim.name)
                else
                        targetlock = false
                end
                statusText.visible = true
                local sizeX = (F14:GetTextSize(statusText.text).x)/2.5
                statusText.x = client.mouseScreenPosition.x-sizeX
                statusText.y = client.mouseScreenPosition.y-client.screenSize.x*0.01
        else
                statusText.visible = false
        end
                
        --creeps 
        entitiesForPush = {}
        
        local lanecreeps = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Lane,visible=true})
        local siege = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Siege,team=enemyTeam,visible=true})
        local towers = entityList:GetEntities({classId=CDOTA_BaseNPC_Tower,visible=true})
        local ward = entityList:GetEntities({classId=CDOTA_BaseNPC_Venomancer_PlagueWard,team=enemyTeam,visible=true})
        local fam = entityList:GetEntities({classId=CDOTA_Unit_VisageFamiliar,team=enemyTeam,visible=true})
        local spider = entityList:GetEntities({classId=CDOTA_Unit_Broodmother_Spiderling,team=enemyTeam,visible=true})
        local boar = entityList:GetEntities({classId=CDOTA_Unit_Hero_Beastmaster_Boar,team=enemyTeam,visible=true})
        local forg = entityList:GetEntities({classId=CDOTA_BaseNPC_Invoker_Forged_Spirit,team=enemyTeam,visible=true})
        --local build = entityList:GetEntities({classId=CDOTA_BaseNPC_Building,team=enemyTeam,visible=true})
        local racks = entityList:GetEntities({classId=CDOTA_BaseNPC_Barracks,team=enemyTeam,visible=true})

        local alliedUnit = nil
        local entitiesForPushCount = 0
        for i = 1, #lanecreeps do local v = lanecreeps[i] if not v:IsInvul() and v.team ~= meTeam and v.alive and not v:IsAttackImmune() and v.spawned then entitiesForPushCount = entitiesForPushCount + 1 entitiesForPush[entitiesForPushCount] = v end 
        
                --Allied unit
                if v.team == meTeam and v.health > v.maxHealth*0.5 and (not alliedUnit or v.health > alliedUnit.health) then
                        alliedUnit = v
                end
        end
        for i = 1, #siege do local v = siege[i] if not v:IsInvul() and v.team ~= meTeam and v.alive and not v:IsAttackImmune() and v.spawned then entitiesForPushCount = entitiesForPushCount + 1 entitiesForPush[entitiesForPushCount] = v end end
        for i = 1, #towers do local v = towers[i] if not v:IsInvul() and v.team ~= meTeam and v.alive and not v:IsAttackImmune() then entitiesForPushCount = entitiesForPushCount + 1 entitiesForPush[entitiesForPushCount] = v end end
        for i = 1, #ward do local v = ward[i] if not v:IsInvul() and v.team ~= meTeam and v.alive and not v:IsAttackImmune() then entitiesForPushCount = entitiesForPushCount + 1 entitiesForPush[entitiesForPushCount] = v end end
        for i = 1, #fam do local v = fam[i] if not v:IsInvul() and v.team ~= meTeam and v.alive and not v:IsAttackImmune() then entitiesForPushCount = entitiesForPushCount + 1 entitiesForPush[entitiesForPushCount] = v end end
        for i = 1, #spider do local v = spider[i] if not v:IsInvul() and v.team ~= meTeam and v.alive and not v:IsAttackImmune() then entitiesForPushCount = entitiesForPushCount + 1 entitiesForPush[entitiesForPushCount] = v end end
        for i = 1, #boar do local v = boar[i] if not v:IsInvul() and v.team ~= meTeam and v.alive and not v:IsAttackImmune() then entitiesForPushCount = entitiesForPushCount + 1 entitiesForPush[entitiesForPushCount] = v end end 
        for i = 1, #forg do local v = forg[i] if not v:IsInvul() and v.team ~= meTeam and v.alive and not v:IsAttackImmune() then entitiesForPushCount = entitiesForPushCount + 1 entitiesForPush[entitiesForPushCount] = v end end
        for i = 1, #racks do local v = racks[i] if not v:IsInvul() and v.team ~= meTeam and v.alive and not v:IsAttackImmune() then entitiesForPushCount = entitiesForPushCount + 1 entitiesForPush[entitiesForPushCount] = v end end
        
        local entitiesForPush = entitiesForPush
        
        --Reseting farmed/visible/stacking state of camps
        local drawMgr3D = drawMgr3D
        local tempJungleCamps = JungleCamps
        for i = 1, #tempJungleCamps do
                local camp = tempJungleCamps[i]
                local block = false
                local farmed = true
                for k = 1, #neutrals do
                        local ent = neutrals[k]
                        if ent.health and ent.alive and ent.visible and ent.spawned and distance(ent,camp.position) < 800 then                                          
                                farmed = false
                                JungleCamps[camp.id].farmed = false
                                tempJungleCamps = JungleCamps
                        end
                end
                for m = 1, #allies do
                        local v = allies[m]
                        if distance(v,camp.position) < 500 and v.alive then
                                block = true
                        end
                        if farmed and distance(v,camp.position) < 300 then
                                JungleCamps[camp.id].farmed = true
                                tempJungleCamps = JungleCamps
                        end
                        if distance(v,camp.position) < 500 then
                                JungleCamps[camp.id].visible = v.visibleToEnemy
                                tempJungleCamps = JungleCamps
                        end
                end
                if gameTime < 30 then
                        JungleCamps[camp.id].farmed = true
                        tempJungleCamps = JungleCamps
                end
                if (gameTime % 60 > 0.5 and gameTime % 60 < 2) or (gameTime > 30 and gameTime < 32) then
                        if camp.farmed then
                                if not block then
                                        JungleCamps[camp.id].farmed = false
                                        tempJungleCamps = JungleCamps
                                end
                        end
                        if camp.stacking then
                                JungleCamps[camp.id].stacking = false
                                tempJungleCamps = JungleCamps
                        end
                end
                if camp.visible then
                        if (gameTime - camp.visTime) > 30 then
                                JungleCamps[camp.id].visible = false
                                tempJungleCamps = JungleCamps
                        end
                end
                if not campSigns[camp.id] then
                        campSigns[camp.id] = drawMgr3D:CreateText(camp.position, Vector(0,0,0), Vector2D(0,0), 0x66FF33FF, "Camp Available!", F14)
                else
                        if tempJungleCamps[camp.id].farmed then
                                campSigns[camp.id].drawObj.text = "Camp farmed!"
                                campSigns[camp.id].drawObj.color = 0xFF6600FF
                        elseif tempJungleCamps[camp.id].visible then
                                campSigns[camp.id].drawObj.text = "Camp visible!"
                                campSigns[camp.id].drawObj.color = 0xFFFF00FF
                        else
                                campSigns[camp.id].drawObj.text = "Camp available!"
                                campSigns[camp.id].drawObj.color = 0x66FF33FF
                        end
                end
                if not closestCamp or distance(mousePosition,closestCamp.position) > distance(mousePosition,camp.position) then
                        closestCamp = camp
                end
        end     
        
        local closestCamp = closestCamp
        local tempmousehoverCamp = mousehoverCamp
        --Hovered camp
        if closestCamp and distance(mousePosition,closestCamp.position) < 100 then
                if not tempmousehoverCamp then
                        mousehoverCamp = drawMgr3D:CreateText(closestCamp.position, Vector(0,0,0), Vector2D(0,15), -1, "Farm this CAMP? Press "..string.char(farmJkey), F14)
                else
                        mousehoverCamp.pos = closestCamp.position
                end
        elseif tempmousehoverCamp then
                mousehoverCamp.drawObj.visible = false
        end
        
        --Sorting Enemies
        -- if #enemies > 1 then
                -- table.sort(enemies, function (a,b) return a.health*(1/(1-a.dmgResist)) > b.health*(1/(1-b.dmgResist)) end)
        -- end
        
        local Lich = nil
        local Pudge = nil
        local Jakiro = nil
        local Mirana = nil
        local Invoker = nil
        local Kunkka = nil
        
        --Enemies loop
        for vNum = 1, #enemies do
                local enemy = enemies[vNum]
                if not (client.shopOpen or client.paused) and me.alive and not IsKeyDown(ctrl) then
                        
                        if not enemy.visible and enemy.alive and not enemy:IsIllusion() then
                                numberOfNotVisibleEnemies = numberOfNotVisibleEnemies + 1
                        end
                        
                        if not enemy:IsIllusion() and enemy.alive and enemy.health > 0  then
                                if not dangerousPosition then
                                        dangerousPosition = enemy.position
                                else
                                        dangerousPosition = dangerousPosition + enemy.position
                                end
                                aliveenemies = aliveenemies + 1
                        end
                                
                        
                        if enemy.visible and (enemy.hero or enemy.classId == CDOTA_Unit_SpiritBear) and enemy.alive and not enemy:IsIllusion() then
                                
                                --Determining main enemy
                                if not (mOver and (mOver.hero or mOver.classId == CDOTA_Unit_SpiritBear) and mOver.alive and mOver.team == enemyTeam and not mOver:IsIllusion()) then
                                        if not targetlock and ((not victim or (victim.health*(1/(1-victim.dmgResist))) > (enemy.health*(1/(1-enemy.dmgResist)))) and distance(mousePosition,enemy) < client.screenSize.x) then
                                                victim = enemy
                                        end                     
                                        if not targetlock and (distance(mousePosition,enemy) < 300 and (not victim or distance(mousePosition,enemy) < distance(mousePosition,victim))) then
                                                victim = enemy
                                        end
                                end
                                
                                --Ethereal KS
                                if SleepCheck("ethereal") and ethereal and canCast(me, ethereal) and distance(me,enemy) <= ethereal.castRange+100 then
                                        local ethDmgTaken = enemy:DamageTaken(EthDmg,DAMAGE_MAGC,me)
                                        if ethDmgTaken >= enemy.health and (enemy.health > ethDmgTaken*0.5 or distance(me,enemy) > (ethereal.castRange*0.5)+50) then
                                                me:CastAbility(ethereal, enemy)
                                                Sleep(100+latency, myHand.."-casting")
                                                Sleep(200,"ethereal")
                                        end
                                end

                                --Hex
                                if SleepCheck("hex") and not enemy:IsMagicImmune() and (myInfo.state == STATE_CHASE or myInfo.state == STATE_ESCAPE or myInfo.state == STATE_HEAL) and 
                                (enemy.hero or enemy.classId == CDOTA_Unit_SpiritBear) and enemy.classId ~= CDOTA_BaseNPC_Creep_Neutral then
                                        local hex = me:FindItem("item_sheepstick")
                                        if canCast(me, hex) and chainEarthbind(me, enemy, me:GetTurnTime(enemy), meepos) and distance(me,enemy) <= hex.castRange+25 then
                                                me:CastAbility(hex,enemy)
                                                Sleep(me:GetTurnTime(enemy)*1000,myHand.."-casting")
                                                Sleep(me:GetTurnTime(enemy)*1000+500,"hex")
                                        end
                                end     
                                
                                --Cast Earthbind                                
                                if not enemy:IsMagicImmune() and (enemy.hero or enemy.classId == CDOTA_Unit_SpiritBear) then
                                        local closest = getClosest(enemy,1,true,nil,meepos, distance)
                                        if closest and (closest ~= me or not (myInfo.blink and canCast(me,myInfo.blink) and distance(me, enemy) > 700)) and distance(closest,enemy) < 2000 then
                                                local hand = closest.handle
                                                local info = tempmeepoTable[hand]
                                                local earthbind = info.earthbind
                                                local delay = earthbind:FindCastPoint()*1000 + latency + closest:GetTurnTime(enemy)*1000
                                                local speed = earthbind:GetSpecialData("speed", earthbind.level)
                                                local prediction = SkillShot.SkillShotXYZ(closest,enemy,delay,speed)
                                                local radius = earthbind:GetSpecialData("radius", earthbind.level)
                                                
                                                --checking if enemy is casting
                                                local castingspell = false
                                                for i = 1, #enemy.abilities do
                                                        local v = enemy.abilities[i]
                                                        local cp = v:FindCastPoint()
                                                        if v.abilityPhase and cp >= (distance(closest,enemy)-radius+25)/857 and Animations.getDuration(v)/1000 <= cp/3 then
                                                                castingspell = true
                                                        end
                                                end
                                                
                                                if SleepCheck(hand.."-casting")  and earthbind and not earthbind.abilityPhase and (((info.state ~= STATE_NONE and info.state ~= STATE_MOVE and info.state ~= STATE_LANE) and (info.state ~= STATE_FARM_JUNGLE or closest.visibleToEnemy))) then
                                                        if canCast(closest,earthbind) and prediction and 
                                                        distance(closest, prediction) <= earthbind.castRange+(radius/2) and ((gameTime > castingEarthbind[vNum] and chainEarthbind(closest, enemy, delay/1000+distance(closest,prediction)/speed, meepos)) or enemy:IsChanneling() or castingspell) then
                                                                if distance(prediction,closest) > earthbind.castRange+25 then
                                                                        prediction = (prediction - closest.position) * (earthbind.castRange - radius) / distance(prediction,closest) + closest.position
                                                                end
                                                                if distance(enemy,prediction) <= (radius/2)-50 and distance(enemy,prediction) < (radius/2)-50 then
                                                                        prediction = enemy.position
                                                                end
                                                                ----print(meepoTable[closest.handle].earthbind.castRange, distance(closest, prediction))
                                                                if distance(closest, prediction) <= earthbind.castRange+25 then
                                                                        meepoTable[hand].prediction = {prediction,enemy.handle}
                                                                        tempmeepoTable = meepoTable
                                                                        closest:CastAbility(earthbind, prediction)
                                                                        castingEarthbind[vNum] = gameTime + delay/1000 + distance(closest,prediction)/speed + 1
                                                                        Sleep(earthbind:FindCastPoint()*1000,hand.."-casting")
                                                                end
                                                        end
                                                end
                                        end
                                end
                                
                                local near,dist,nearMeepo = anyMeepoisNear(enemy, 1000, nil, meepos, distance, mathcos, mathsin)
                                local hand = nil
                                if nearMeepo then hand = nearMeepo.handle end
                                local info = tempmeepoTable[hand]
                                --Escape mode
                                if (enemy.hero or enemy.classId == CDOTA_Unit_SpiritBear) and near and nearMeepo and nearMeepo.alive and info and info.state ~= STATE_ESCAPE then
                                        --if (player.selection[1].handle ~= nearMeepo.handle or meepoTable[nearMeepo.handle].state == STATE_CHASE) then
                                        local inc = 0--IncomingDamage(enemy,false)
                                        local channel = enemy:GetChanneledAbility()
                                        local pooftaken = enemy:DamageTaken(poofDamage[1],DAMAGE_MAGC,me)
                                        if (inc >= enemy.health or enemy.health < pooftaken*getAliveNumber(false,meepos)) or (channel and (channel.name == "item_travel_boots" or channel.name == "item_tpscroll")) then
                                                if info.state ~= STATE_ESCAPE and near and distance(nearMeepo,enemy) < 400 and (info.state == STATE_FARM_JUNGLE or info.state == STATE_NONE or info.state == STATE_MOVE or info.state == STATE_CHASE or info.state == STATE_PUSH) then
                                                        DebugPrint("EscapeC")
                                                        allchase = enemy                                                        
                                                        if SleepCheck("pingdanger") then
                                                                client:Ping(Client.PING_NORMAL,enemy.position)
                                                                Sleep(7000,"pingdanger")
                                                        end
                                                end
                                        else
                                                local meinc = 0--IncomingDamage(nearMeepo,false)
                                                if (player.selection[1].handle ~= hand or (info.state ~= STATE_CHASE or not IsKeyDown(mainkey))) and nearMeepo.health < nearMeepo.maxHealth*(minhp/100) and enemy.health > pooftaken*getAliveNumber(false,meepos) then                  
                                                        if near and (info.state == STATE_FARM_JUNGLE or info.state == STATE_NONE or info.state == STATE_MOVE or info.state == STATE_CHASE or info.state == STATE_PUSH) and ((nearMeepo.visibleToEnemy and 500) or (distance(nearMeepo,enemy) < enemy.attackRange and gameTime > 1200)) then
                                                                DebugPrint("EscapeE")
                                                                if nearMeepo.health < 300 or info.state ~= STATE_CHASE then
                                                                        meepoTable[hand].lastState = info.state
                                                                        meepoTable[hand].state = STATE_ESCAPE
                                                                        tempmeepoTable = meepoTable
                                                                        if SleepCheck("ping") then
                                                                                client:Ping(Client.PING_DANGER,enemy.position)
                                                                                Sleep(7000,"ping")
                                                                        end
                                                                        Sleep(4000,hand.."-escape")
                                                                end
                                                        end
                                                end
                                        end
                                        -- elseif meepoTable[nearMeepo.handle].state ~= STATE_NONE and meepoTable[nearMeepo.handle].state ~= STATE_MOVE and nearMeepo.visibleToEnemy then
                                                -- meepoTable[nearMeepo.handle].state = STATE_NONE
                                        -- end
                                end
                        end     
                        --Sleep(1000,enemy.handle)
                end
                
                --Recognizing dangerous enemies
                if enemy.classId == CDOTA_Unit_Hero_Lich then
                        Lich = enemy
                elseif enemy.classId == CDOTA_Unit_Hero_Pudge then
                        Pudge = enemy
                elseif enemy.classId == CDOTA_Unit_Hero_Jakiro then
                        Jakiro = enemy
                elseif enemy.classId == CDOTA_Unit_Hero_Invoker then
                        Invoker = enemy
                elseif enemy.classId == CDOTA_Unit_Hero_Kunkka then
                        Kunkka = enemy
                elseif enemy.classId == CDOTA_Unit_Hero_Mirana then
                        Mirana = enemy
                end
                
        end
        
        if dangerousPosition then
                dangerousPosition = dangerousPosition/#enemies
        end

        local cast = {}
        
        if Invoker or Kunkka or Mirana then
                cast = entityList:GetEntities({classId=CDOTA_BaseNPC})
        end
        
        --Lich Chain Frost
        local projectiles = entityList:GetProjectiles({})
        local chainFrost = nil
        if Lich then
                local chainfrost = Lich:GetAbility(4)
                if chainfrost and chainfrost.cd > 0 then
                        for i = 1, #projectiles do
                                local v = projectiles[i]
                                if v.speed == 750 then
                                        chainFrost = v
                                end
                        end
                end
        end
        
        --LineDodge variables
        local linedodge = false
        local linedodgeHero = nil
        local dodgespeed = 0
        
        --Pudge Hook
        if Pudge then
                local hook = Pudge:GetAbility(1)
                if hook and hook.abilityPhase and Animations.getDuration(hook) >= 50 then
                        linedodge = true
                        linedodgeHero = Pudge
                        dodgeradius = hook:GetSpecialData("hook_width",hook.level)
                        dodgedistance = hook:GetSpecialData("hook_distance",hook.level) + dodgeradius + 50
                        dodgespeed = hook:GetSpecialData("hook_speed",hook.level)
                end
        end
        
        --Jakiro IcePath
        if Jakiro then
                local IcePath = Jakiro:GetAbility(2)
                if IcePath and IcePath.abilityPhase and Animations.getDuration(IcePath) >= 50 then
                        linedodge = true
                        linedodgeHero = Jakiro
                        dodgeradius = IcePath:GetSpecialData("path_radius",IcePath.level) - 100
                        dodgedistance = 1100 + dodgeradius + 50
                        dodgespeed = 1000 - 100*IcePath.level
                end
        end
        
        --Mirana arrow
        local arrow = nil
        if Mirana then
                arrow = FindEntity(cast,me,650,nil)
                if arrow then   
                        if not start then
                                start = arrow.position
                        end
                        if arrow.visibleToEnemy and not vec then
                                vec = arrow.position
                                if distance(vec,start) < 50 then
                                        vec = nil
                                end
                        end
                        if start and vec then
                                linedodge = true
                                dodgeradius = 10
                                dodgespeed = 857
                        end
                elseif start then
                        start,vec = nil,nil
                end
        end
        
        --Kunkka torrent
        local torrent = nil
        if Kunkka then 
                torrent = FindEntity(cast,me,nil,"modifier_kunkka_torrent_thinker")
                if torrent then
                        if not aoeStarttime then
                                aoeStarttime = gameTime
                        end
                elseif aoeStarttime and gameTime - aoeStarttime > 1.5 then aoeStarttime = nil 
                end
        end
        
        --Invoker Sunstrike
        local sunstrike = nil
        if Invoker then
                sunstrike = FindEntity(cast,me,nil,"modifier_invoker_sun_strike")
                if sunstrike then
                        if not aoeStarttime then
                                aoeStarttime = gameTime
                        end
                elseif aoeStarttime and gameTime - aoeStarttime > 1.7 then aoeStarttime = nil 
                end
        end
        
        --If we are hovering someone with mouse then they are our main victim
        if not targetlock and mOver and (mOver.hero or mOver.classId == CDOTA_Unit_SpiritBear) and mOver.alive and mOver.team == enemyTeam and not mOver:IsIllusion() then
                victim = mOver
        end
        
        --Retreat
        local lowest = nil
        local lowHandle = nil
        if IsKeyDown(retreatkey) and not client.chat and not IsKeyDown(ctrl) then
                lowest = getLowestHPMeepo(meepos)
                if lowest then
                        lowHandle = lowest.handle
                        meepoTable[lowHandle].state = STATE_ESCAPE
                        meepoTable[lowHandle].retreat = true
                        tempmeepoTable = meepoTable
                end
                retreat = true
                if not retreatStartTime then
                        retreatStartTime = gameTime
                end
        elseif not retreattime and retreat then
                retreattime = gameTime
                retreatStartTime = nil
        elseif retreat and retreattime and gameTime - retreattime > 3 then
                retreat = false
                retreattime = nil
                retreatStartTime = nil
        end
        
        --doubleclick Retreat
        if retreatkeyCount == 2 then
                if not doubleclickTime then
                        doubleclickTime = gameTime
                elseif gameTime - doubleclickTime > 20 or ((IsKeyDown(mainkey) or IsKeyDown(healkey)) and not client.chat) then
                        doubleclickTime = nil
                        retreatkeyCount = 0
                end
        elseif retreatkeyCount == 1 then
                if not doubleclickTime then
                        doubleclickTime = gameTime
                elseif gameTime - doubleclickTime > 0.5 or ((IsKeyDown(mainkey) or IsKeyDown(healkey)) and not client.chat) then
                        doubleclickTime = nil
                        retreatkeyCount = 0
                end
        end

        --Cycling through our meepos
        for i = 1, #meepos do
                local meepo = meepos[i]
                local meepoHandle = meepo.handle
                local meepoUlt = meepo:GetAbility(4)
                local meeponumber = (meepoUlt:GetProperty( "CDOTA_Ability_Meepo_DividedWeStand", "m_nWhichDividedWeStand" ) + 1)
                local info = tempmeepoTable[meepoHandle]
                if not meepo:IsChanneling() and not (client.shopOpen or client.paused or IsKeyDown(ctrl)) and info then
                        
                        if allchase then
                                if info.state ~= STATE_HEAL and meepo.alive and meepo.health > (meepo.maxHealth/100)*minhp then                                                         
                                        meepoTable[meepoHandle].victim = allchase
                                        meepoTable[meepoHandle].state = STATE_CHASE
                                else
                                        meepoTable[meepoHandle].victim = nil
                                end
                                tempmeepoTable = meepoTable
                                info = tempmeepoTable[meepoHandle]
                        end
                        if meepo.alive then
                                
                                --Earthbind cancel
                                local earthbind = info.earthbind
                                local EBprediction = info.prediction
                                if earthbind.abilityPhase and EBprediction and SleepCheck(meepoHandle.."-cancel") then
                                        local enemy = entityList:GetEntity(EBprediction[2])
                                        local delay = earthbind:FindCastPoint()*1000 + latency + meepo:GetTurnTime(enemy)*1000
                                        local speed = earthbind:GetSpecialData("speed", earthbind.level)
                                        local prediction = SkillShot.SkillShotXYZ(meepo,enemy,delay,speed)
                                        local radius = earthbind:GetSpecialData("radius", earthbind.level)
                                        if prediction and distance(prediction,meepo) < earthbind.castRange+(radius/2) then
                                                if distance(prediction,meepo) > earthbind.castRange+25 then
                                                        prediction = (prediction - meepo.position) * (earthbind.castRange - radius) / distance(prediction,meepo) + meepo.position
                                                end
                                                if distance(enemy,prediction) <= (radius/2)-50 and distance(enemy,prediction) < (radius/2)-50 then
                                                        prediction = enemy.position
                                                end
                                                if distance(EBprediction[1],prediction) > radius+50 then
                                                        meepo:Stop()
                                                        meepo:CastAbility(earthbind,prediction)
                                                        Sleep(delay - latency,meepoHandle.."-casting")
                                                        Sleep(1000,meepoHandle.."-cancel")
                                                end
                                        end
                                end
                                        
                                --Kunkka Torrent dodge
                                if torrent and SleepCheck(meepoHandle.."torrent") and distance(meepo,torrent) <= 320 then
                                        AOEDodge(meepo, torrent.position, 320,mathfloor, mathsqrt)
                                        Sleep(1600-((gameTime-aoeStarttime)*1000)+latency,meepoHandle.."-move")
                                        Sleep(1600-((gameTime-aoeStarttime)*1000)+latency,meepoHandle.."-casting")
                                        Sleep(1600-((gameTime-aoeStarttime)*1000)+latency,meepoHandle.."-attack")
                                        Sleep(1600-((gameTime-aoeStarttime)*1000)+latency,meepoHandle.."torrent")
                                end
                                
                                --Invoker Sunstrike Dodge
                                if sunstrike and SleepCheck(meepoHandle.."sunstrike") and distance(meepo,sunstrike) <= 270 then
                                        AOEDodge(meepo, sunstrike.position, 270,mathfloor, mathsqrt)
                                        Sleep(1600-((gameTime-aoeStarttime)*1000)+latency,meepoHandle.."-move")
                                        Sleep(1600-((gameTime-aoeStarttime)*1000)+latency,meepoHandle.."-casting")
                                        Sleep(1600-((gameTime-aoeStarttime)*1000)+latency,meepoHandle.."-attack")
                                        Sleep(1600-((gameTime-aoeStarttime)*1000)+latency,meepoHandle.."sunstrike")
                                end
                                
                                --Line dodge
                                if linedodge and dodgedistance and dodgeradius and SleepCheck(meepoHandle.."dodge") and linedodgeHero then
                                        LineDodge(meepo, Vector(linedodgeHero.position.x + dodgedistance * mathcos(linedodgeHero.rotR), linedodgeHero.position.y + dodgedistance * mathsin(linedodgeHero.rotR), linedodgeHero.position.z), linedodgeHero.position, dodgeradius, (distance(linedodgeHero,meepo)/dodgespeed)*1000+latency,mathfloor, mathsqrt, mathabs)
                                end
                                
                                --Arrow dodge
                                if linedodge and arrow and SleepCheck(meepoHandle.."dodge") and start then
                                        local distance2 = FindAB(start,vec,distance(meepo,start)*10,mathdeg, mathatan, mathabs, mathrad, mathcos, mathsin)
                                        --check for block
                                        if distance(meepo, start) <= (distance(start,distance2) + dodgeradius + 25) and distance(arrow,start) <= distance(meepo,start) then
                                                --dodge
                                                LineDodge(meepo, distance2, start, dodgeradius, (distance(arrow.position,meepo)/dodgespeed)*1000+latency,mathfloor, mathsqrt, mathabs)
                                        end
                                end
                                
                                --Lich Ulti Split
                                if chainFrost and SleepCheck(meepoHandle.."chainfrost") and info.state ~= STATE_CHASE then
                                        local target = chainFrost.target
                                        if target and target ~= meepo then
                                                local dist = distance(target,meepo)
                                                if dist < lichJumpRange then
                                                        local pos = target.position + ((meepo.position - target.position)*(lichJumpRange + 10)/dist)
                                                        meepo:Move(pos)
                                                        Sleep(50+latency,meepoHandle.."chainfrost")
                                                        Sleep((distance(pos,meepo)/meepo.movespeed)*1000+latency,meepoHandle.."-move")
                                                        Sleep((distance(pos,meepo)/meepo.movespeed)*1000+latency,meepoHandle.."-casting")
                                                end
                                        else
                                                FindOptimalPlaceAgainstChainFrost(meepo,distance,mathsqrt)
                                                Sleep(50+latency,meepoHandle.."chainfrost")
                                        end
                                end
                                
                                --Retreat
                                if not IsKeyDown(ctrl) and IsKeyDown(retreatkey) and not client.chat then
                                        if retreatStartTime then
                                                if lowest and lowHandle ~= meepoHandle then
                                                        if (meepo.health <= meepo.maxHealth*0.5 or (gameTime - retreatStartTime) > 3) then
                                                                meepoTable[meepoHandle].state = STATE_ESCAPE
                                                                meepoTable[meepoHandle].retreat = true
                                                        else
                                                                meepoTable[meepoHandle].state = STATE_CHASE
                                                        end
                                                        tempmeepoTable = meepoTable
                                                        info = tempmeepoTable[meepoHandle]
                                                end
                                        end
                                end
                                
                                if info.state ~= STATE_CHASE and info.state ~= STATE_POOF_OUT and info.state ~= STATE_HEAL and info.state ~= STATE_ESCAPE and info.state ~= STATE_FARM_JUNGLE and info.state ~= STATE_PUSH and not SleepCheck(meepoHandle.."-casting") and info.poof and info.poof.abilityPhase then
                                        meepo:Stop()
                                end
                                
                                if dangerousPosition and ((info.camp and distance(dangerousPosition,info.camp.position) < 1000) or distance(meepo,dangerousPosition) < 1000) and (info.state == STATE_FARM_JUNGLE or info.state == STATE_PUSH) then
                                        meepoTable[meepoHandle].state = STATE_ESCAPE
                                        tempmeepoTable = meepoTable
                                        info = tempmeepoTable[meepoHandle]
                                end                                     
                                
                                --HealKey
                                if IsKeyDown(healkey) and not client.chat then
                                        if meepo.health <= meepo.maxHealth*(healpercent/100) then
                                                if not info.healPosition then
                                                        meepoTable[meepoHandle].healPosition = meepo.position
                                                else
                                                        meepoTable[meepoHandle].state = STATE_HEAL
                                                end
                                                tempmeepoTable = meepoTable
                                                info = tempmeepoTable[meepoHandle]
                                        elseif SleepCheck(meepoHandle.."-move") then
                                                meepo:Move(mousePosition)
                                                Sleep(500,meepoHandle.."-move")
                                        end
                                end
                        
                                --rupture
                                if meepo:DoesHaveModifier("modifier_bloodseeker_rupture") then
                                        if meepo.activity == LuaEntityNPC.ACTIVITY_MOVE then
                                                local prev = SelectUnit(meepo)
                                                player:HoldPosition()
                                                SelectBack(prev)
                                        end
                                        local rupture = meepo:FindModifier("modifier_bloodseeker_rupture")
                                        Sleep(rupture.remainingTime*1000,meepoHandle.."-move")
                                end
                                
                                --Poof out
                                if info.state == STATE_POOF_OUT and SleepCheck(meepoHandle.."-casting") then
                                        if info.lastState then
                                                meepoTable[meepoHandle].state = info.lastState
                                                meepoTable[meepoHandle].lastState = nil
                                        else
                                                meepoTable[meepoHandle].state = STATE_FARM_JUNGLE
                                        end
                                        tempmeepoTable = meepoTable
                                        info = tempmeepoTable[meepoHandle]
                                end
                                
                                --charged meepo
                                if meepo:DoesHaveModifier("modifier_spirit_breaker_charge_of_darkness_vision") and (info.state == STATE_FARM_JUNGLE or info.state == STATE_PUSH) then
                                        meepoTable[meepoHandle].state = STATE_ESCAPE
                                        tempmeepoTable = meepoTable
                                        info = tempmeepoTable[meepoHandle]
                                end
                                
                                --Escape function
                                if info.state == STATE_ESCAPE then
                                        local travels = meepo:FindItem("item_travel_boots") or meepo:FindItem("item_travel_boots_2")
                                        local tp = meepo:FindItem("item_tpscroll")
                                        local item = nil
                                        local poof = info.poof
                                        meepoTable[meepoHandle].victim = nil
                                        if info.foundCreep then
                                                meepoTable[meepoHandle].foundCreep = false
                                        end
                                        if SleepCheck(meepoHandle.."-casting") then
                                                local meepotp,time = tping(base.position,distance,meepo.handle)
                                                if poof.level > 0 and canCast(meepo, poof) and not poof.abilityPhase then
                                                        local farrest = getFarrestMeepo(meepo,meepos,distance)
                                                        local near,dist,nearMeepo = anyMeepoisNear(base.position, 2000, meepo, meepos, distance, mathcos, mathsin)
                                                        local pos = nil
                                                        if (farrest and distance(meepo,farrest) > 1000) and distance(meepo,base) > distance(farrest,base) and not meepotp then
                                                                pos = farrest.position
                                                        elseif ((near and nearMeepo) or (meepotp and (time and time < (poof:FindCastPoint()-meepo:GetTurnTime(base.position))))) and distance(meepo,base.position) > 1000 then
                                                                pos = base.position
                                                        end
                                                        if pos then
                                                                meepo:CastAbility(poof,pos)                                             
                                                                if pos == base.position then
                                                                        meepoTable[meepoHandle].lastState = STATE_LANE
                                                                        --print("escape")
                                                                elseif pos == farrest.position then
                                                                        meepoTable[meepoHandle].lastState = STATE_ESCAPE
                                                                end
                                                                meepoTable[meepoHandle].state = STATE_POOF_OUT
                                                                if distance(meepo,base.position) > 50 then
                                                                        meepo:Move(base.position,true)
                                                                end
                                                                Sleep(poof:FindCastPoint()*1000,meepoHandle.."-casting")
                                                        end
                                                end
                                                if travels then item = travels else item = tp end
                                                if item and canCast(meepo, item) and (not meepotp or not canCast(meepo,poof)) and not IsInDanger(meepo,nil,distance,mathmin) and distance(meepo,base.position) > 2000 and SleepCheck("travels") then
                                                        meepo:CastAbility(item,base.position)
                                                        meepoTable[meepoHandle].tping = base.position
                                                        meepoTable[meepoHandle].tpTime = gameTime+(latency/1000)+meepo:GetTurnTime(base.position)
                                                        Sleep(3000,meepoHandle.."-casting")
                                                        Sleep(100,"travels")
                                                        return
                                                end
                                        end
                                        if SleepCheck(meepoHandle.."-move") and not meepo:IsChanneling() then
                                                local nearNum,nearTable = getNearVictims(meepo,distance)
                                                local pos = nil
                                                if nearNum > 0 then
                                                        for i = 1, #nearTable do
                                                                local v = nearTable[i]
                                                                if pos then
                                                                        pos = pos + v.position
                                                                else
                                                                        pos = v.position
                                                                end
                                                        end
                                                        local pos1 = pos/nearNum
                                                        pos = (meepo.position - pos1) * (distance(meepo,pos1) + 5000) / distance(meepo,pos1) + meepo.position
                                                end
                                                if pos and pos1 and distance(meepo,pos1) < 1200 then
                                                        meepo:Move(pos)
                                                else
                                                        meepo:Move(base.position)
                                                end
                                                Sleep(750, meepoHandle.."-move")                                
                                        end
                                        tempmeepoTable = meepoTable
                                        info = tempmeepoTable[meepoHandle]
                                end
                                
                                --reseting tp position
                                if info.tping then
                                        -- if not meepoTable[meepoHandle].starttp then
                                                -- meepoTable[meepoHandle].starttp = gameTime 
                                        -- elseif gameTime - meepoTable[meepoHandle].starttp > 5 then
                                                -- meepoTable[meepoHandle].starttp = nil
                                                -- meepoTable[meepoHandle].tping = nil
                                        -- end
                                        local tp = meepo:FindItem("item_tpscroll") or meepo:FindItem("item_travel_boots") or meepo:FindItem("item_travel_boots_2")
                                        
                                        local tped = (tp and (mathceil(tp.cd + 3) == mathceil(tp:GetCooldown(tp.level))))
                                        if tped then
                                                meepoTable[meepoHandle].tping = nil
                                                meepoTable[meepoHandle].tpTime = nil
                                                tempmeepoTable = meepoTable
                                                info = tempmeepoTable[meepoHandle]
                                        end
                                end
                                
                                --Heal function
                                if (info.state == STATE_HEAL or (meepo.alive and (((meepo.health+(meepo.healthRegen*(distance(meepo,base)/meepo.movespeed))) < meepo.maxHealth/4.25 and 
                                info.state ~= STATE_POOF_OUT and info.state ~= STATE_LANE and info.state ~= STATE_ESCAPE and (info.state ~= STATE_FARM_JUNGLE or 
                                (info.camp and distance(info.camp.position,meepo) > 1000))) or meepo:DoesHaveModifier("modifier_bloodseeker_thirst_vision") or info.healPosition))) and SleepCheck(meepoHandle.."-heal") then                   
                                        local incDmgM = 0--IncomingDamage(meepo,false)  
                                        --Updating state of meepo
                                        if info.state ~= STATE_HEAL then
                                                meepoTable[meepoHandle].lastState = info.state
                                                meepoTable[meepoHandle].state = STATE_HEAL      
                                                meepoTable[meepoHandle].camp = nil
                                                meepoTable[meepoHandle].lastcamp = nil
                                                if info.foundCreep then
                                                        meepoTable[meepoHandle].foundCreep = false
                                                end
                                        end
                                        
                                        --Giving orders to heal
                                        local mustGoBase,items,isMe = haveHealingItems(meepo, distance)
                                        if not info.healPosition and not mustGoBase and not IsInDanger(meepo,nil,distance,mathmin) and (not info.camp or distance(meepo,info.camp.position) > 1000) and not me:DoesHaveModifier("modifier_flask_healing") then
                                                if isMe and (me.maxHealth - me.health) > 300 then
                                                        me:CastAbility(items[1], me)
                                                elseif distance(me, meepo) > 200 then
                                                        meepo:Follow(me)
                                                else
                                                        me:CastAbility(items[1], meepo)
                                                end
                                        else
                                                if info.victim and info.victim.visible and distance(info.victim,meepo) < info.victim.attackRange and (incDmgM > meepo.health or meepo.health < 300) then
                                                        meepo:Move((meepo.position - info.victim.position) * (distance(meepo,info.victim) + info.victim.attackRange) / distance(meepo,info.victim) + meepo.position)
                                                end
                                                if not IsInDanger(meepo,nil,distance,mathmin) then
                                                        if config.UseBoTs then
                                                                useTP(meepo, meepoHandle, base.position, false, false, meepos, distance, mathcos, mathsin)
                                                        else
                                                                useTP(meepo, meepoHandle, base.position, false, true, meepos, distance, mathcos, mathsin)
                                                        end
                                                end
                                                if SleepCheck(meepoHandle.."-casting") and distance(meepo,base.position) > 50 then
                                                        meepo:Move(base.position)
                                                end
                                        end
                                        tempmeepoTable = meepoTable
                                        info = tempmeepoTable[meepoHandle]
                                        Sleep(500, meepoHandle.."-heal")
                                end
                                
                                if info.state == STATE_ESCAPE and distance(meepo,base.position) < 1000 then
                                        --print("escapedToBase")
                                        meepoTable[meepoHandle].state = STATE_LANE
                                        meepoTable[meepoHandle].retreat = false
                                        tempmeepoTable = meepoTable
                                        info = tempmeepoTable[meepoHandle]
                                end
                                
                                --Going farm after healed
                                if meepo.alive and ((info.state == STATE_HEAL and meepo.health > meepo.maxHealth/1.4) or (info.state == STATE_ESCAPE and (not dangerousPosition or distance(meepo,dangerousPosition) > 2500) and not IsInDanger(meepo,nil,distance,mathmin) and SleepCheck(meepoHandle.."-escape") and (not (IsKeyDown(retreatkey) and not client.chat) or distance(meepo,base.position) < 1000))) then         

                                        --HealKey
                                        if info.healPosition then
                                                local farrest = getFarrestMeepo(meepo,meepos,distance)
                                                meepoTable[meepoHandle].state = STATE_LANE
                                                --print("HealKey")
                                                useTP(meepo, meepoHandle, farrest.position, false, true, meepos, distance, mathcos, mathsin)
                                                meepoTable[meepoHandle].healPosition = nil      
                                        else
                                        
                                                --Updating state of meepo       
                                                if info.lastState and info.lastState ~= STATE_HEAL then
                                                        if not retreat and not info.retreat then
                                                                meepoTable[meepoHandle].state = info.lastState
                                                        elseif retreatkeyCount ~= 2 then
                                                                meepoTable[meepoHandle].state = STATE_NONE      
                                                                meepoTable[meepoHandle].retreat = false
                                                        end
                                                elseif not (IsKeyDown(retreatkey) and not client.chat) then
                                                        if not retreat and not info.retreat then
                                                                meepoTable[meepoHandle].state = STATE_FARM_JUNGLE
                                                        elseif retreatkeyCount ~= 2 then
                                                                meepoTable[meepoHandle].state = STATE_NONE
                                                                meepoTable[meepoHandle].retreat = false
                                                        end
                                                end
                                        end
                                        tempmeepoTable = meepoTable
                                        info = tempmeepoTable[meepoHandle]
                                end
                                
                                
                                --
                                if not IsKeyDown(ctrl) and IsKeyDown(mainkey) and not client.chat and meepo.health < (meepo.maxHealth/100)*minhp and (info.state == STATE_LANE or info.state == STATE_NONE) then        
                                        meepoTable[meepoHandle].state = STATE_ESCAPE
                                        tempmeepoTable = meepoTable
                                        info = tempmeepoTable[meepoHandle]
                                end
                                
                                --Chase function
                                if not IsKeyDown(ctrl) and ((IsKeyDown(mainkey) and not client.chat) or (info.state == STATE_CHASE and (not IsKeyDown(mainkey) or client.chat))) and meepo.health > (meepo.maxHealth/100)*minhp then    
                                        if meepo.alive and not meepo:IsStunned() and not meepo:IsRooted() and info.state ~= STATE_HEAL and 
                                        info.state ~= STATE_POOF_OUT and info.state ~= STATE_ESCAPE then                                
                                                -- local victim2 = meepoTable[meepoHandle].victim
                                                --local incDmgM = IncomingDamage(meepo,false) 
                                                --local incDmgv = IncomingDamage(victim,false)
                                                meepoTable[meepoHandle].victim = victim

                                                local near,dist,nearMeepo = anyMeepoisNear(victim, 700, meepo, meepos, distance, mathcos, mathsin)
                                                
                                                if info.victim and not info.victim.visible then
                                                        if info.victimFogTime == 0 then
                                                                meepoTable[meepoHandle].victimFogTime = gameTime
                                                        elseif (gameTime - info.victimFogTime) > 5 then
                                                                meepoTable[meepoHandle].victim = nil
                                                                meepoTable[meepoHandle].victimFogTime = 0
                                                        end
                                                end
                                                
                                                local selection = player.selection
                                                local selHand = nil
                                                if selection[1] then selHand = selection[1].handle end
                                                local nearR = false
                                                local selected = nil
                                                if (victim and victim.alive and victim.visible and (distance(meepo,victim) < 500 or near) and (victim.hero or victim.classId == CDOTA_Unit_SpiritBear)) or (IsKeyDown(mainkey) and not client.chat and victim and victim.alive and (victim.hero or victim.classId == CDOTA_Unit_SpiritBear)) then
                                                        if selection[1] then
                                                                if selection[1].classId ~= ID then selection = {meepos[1]} selHand = selection[1].handle end
                                                                if tempmeepoTable[selHand] then
                                                                        if tempmeepoTable[selHand].state ~= STATE_CHASE then
                                                                                meepoTable[selHand].state = STATE_CHASE
                                                                        end
                                                                        useTP(meepo, meepoHandle, victim.position, false, true, meepos, distance, mathcos, mathsin)
                                                                        OrbWalk(meepo,meepoHandle,victim,true,meepos, distance, mathcos, mathsin,mathabs,mathrad,mathceil,mathmax)
                                                                        selected = selection[1]
                                                                        if distance(selected, victim) < 500 then
                                                                                nearR = true
                                                                        end
                                                                end
                                                        end
                                                        if victim and victim.alive and (victim.hero or victim.classId == CDOTA_Unit_SpiritBear) and victim.visible and (nearR or near or distance(meepo,victim) < 1000) then
                                                                if info.state ~= STATE_CHASE then
                                                                        meepoTable[meepoHandle].state = STATE_CHASE
                                                                        meepoTable[meepoHandle].camp = nil
                                                                        meepoTable[meepoHandle].lastcamp = nil
                                                                        meepoTable[meepoHandle].foundCreep = false
                                                                end
                                                                useTP(meepo, meepoHandle, victim.position, false, true,meepos, distance, mathcos, mathsin)
                                                                OrbWalk(meepo,meepoHandle,victim,true,meepos, distance, mathcos, mathsin,mathabs,mathrad,mathceil,mathmax)
                                                        end
                                                elseif info.state == STATE_CHASE then
                                                        if config.AutoGoFarmAfterChase then
                                                                meepoTable[meepoHandle].state = STATE_FARM_JUNGLE
                                                        else
                                                                meepoTable[meepoHandle].state = STATE_NONE
                                                        end
                                                        meepoTable[meepoHandle].victim = nil
                                                elseif SleepCheck(meepoHandle.."-move") and (info.state == STATE_NONE or info.state == STATE_MOVE or info.state == STATE_LANE) then
                                                        meepoTable[meepoHandle].victim = nil
                                                        meepo:Move(mousePosition)
                                                        Sleep(500,meepoHandle.."-move")
                                                end
                                        end
                                        tempmeepoTable = meepoTable
                                        info = tempmeepoTable[meepoHandle]
                                else
                                        --Updating state of meepo
                                        if tempmeepoTable[meepoHandle].state == STATE_CHASE then
                                                if meepo.health <= (meepo.maxHealth/100)*minhp then
                                                        meepoTable[meepoHandle].state = STATE_ESCAPE
                                                else
                                                        if config.AutoGoFarmAfterChase then
                                                                meepoTable[meepoHandle].state = STATE_FARM_JUNGLE
                                                        else
                                                                meepoTable[meepoHandle].state = STATE_NONE
                                                        end
                                                end
                                                meepoTable[meepoHandle].victim = nil
                                        end
                                        tempmeepoTable = meepoTable
                                end
                                
                                --Unaggro
                                if tempmeepoTable[meepo.handle].state ~= STATE_LANE then
                                        for i = 1, #projectiles do
                                                local p = projectiles[i]
                                                local sour = p.source
                                                if sour and sour.classId == CDOTA_BaseNPC_Tower and p.target and p.target.handle == meepoHandle and distance(meepo,sour) <= sour.attackRange+25 then
                                                        local sourHand = sour.handle
                                                        local closest = getClosest(sour,1,false,meepo,meepos, distance)
                                                        local dmg = meepo:DamageTaken((sour.dmgMax+sour.dmgMin)/2,DAMAGE_PHYS,sour)
                                                        if closest and closest.health > meepo.health then
                                                                if SleepCheck(meepoHandle.."unaggro") and SleepCheck(sourHand) and SleepCheck(closest.handle.."unaggro") then
                                                                        if alliedUnit and (dmg >= meepo.maxHealth*0.2 or meepo.health-(dmg*1.5) <= meepo.maxHealth*0.5)
                                                                        and distance(closest,sour) <= sour.attackRange then
                                                                                meepo:Attack(alliedUnit)
                                                                                closest:Attack(sour)
                                                                                Sleep((distance(meepo,p.position)/p.speed)*1000,sourHand)
                                                                                Sleep(250, meepoHandle.."unaggro")
                                                                                Sleep(250, closest.handle.."unaggro")
                                                                        end
                                                                elseif SleepCheck(meepoHandle.."unaggro2") and SleepCheck(meepoHandle.."-casting") then
                                                                        local prev = SelectUnit(meepo)
                                                                        player:HoldPosition()
                                                                        SelectBack(prev)
                                                                        Sleep((distance(meepo,p.position)/p.speed)*1000,meepoHandle.."unaggro2")
                                                                end
                                                        else
                                                                if SleepCheck(meepoHandle.."unaggro") and SleepCheck(sourHand) then
                                                                        if alliedUnit and (dmg >= meepo.maxHealth*0.2 or meepo.health-(dmg*1.5) <= meepo.maxHealth*0.5)then
                                                                                meepo:Attack(alliedUnit)
                                                                                Sleep((distance(meepo,p.position)/p.speed)*1000,sourHand)
                                                                                Sleep(250, meepoHandle.."unaggro")
                                                                        end
                                                                elseif SleepCheck(meepoHandle.."unaggro2") and SleepCheck(meepoHandle.."-casting") and meepo.activity == LuaEntityNPC.ACTIVITY_MOVE then
                                                                        local prev = SelectUnit(meepo)
                                                                        player:HoldPosition()
                                                                        SelectBack(prev)
                                                                        Sleep((distance(meepo,p.position)/p.speed)*1000,meepoHandle.."unaggro2")
                                                                end
                                                        end
                                                end
                                        end
                                end
                                        
                                --Lane Farm
                                if meepo.alive and tempmeepoTable[meepoHandle].state == STATE_PUSH then                                         
                                        local def = false
                                        local pushEntity = nil
                                        local pushEntities = {}
                                        local pushEntitiesCount = 0
                                        for i = 1, entitiesForPushCount do
                                                local creep = entitiesForPush[i]
                                                if creep.team ~= meTeam and creep.alive and creep.visible then
                                                        if distance(creep,meepo) <= 4000 then
                                                                if distance(creep,meepo) <= 400 then
                                                                        pushEntitiesCount = pushEntitiesCount + 1
                                                                        pushEntities[pushEntitiesCount] = creep
                                                                end
                                                                if not pushEntity or (creep.health < pushEntity.health and distance(creep,pushEntity) < 700) then
                                                                        pushEntity = creep
                                                                end
                                                        end
                                                end
                                        end

                                        if (not tempmeepoTable[meepoHandle].camp or ((gameTime % 60 > 0 and gameTime % 60 < 1) or tempJungleCamps[tempmeepoTable[meepoHandle].camp.id].farmed or tempJungleCamps[tempmeepoTable[meepoHandle].camp.id].visible)) then
                                                DebugPrint("Getting Camp")
                                                meepoTable[meepoHandle].camp = getClosestCamp(meepo,nil,nil,nil, distance)
                                        elseif tempmeepoTable[meepoHandle].camp and SleepCheck(meepoHandle.."-camp") then
                                                DebugPrint("Getting Camp 2")
                                                local camp = getClosestCamp(meepo,nil,nil,nil, distance)
                                                if camp and distance(meepo,camp.position) < distance(meepo,tempmeepoTable[meepoHandle].camp.position) then
                                                        meepoTable[meepoHandle].camp = camp
                                                end
                                                Sleep(3000, meepoHandle.."-camp")
                                        end
                                        tempmeepoTable = meepoTable
                                        local camp = nil
                                        if tempmeepoTable[meepoHandle].camp then
                                                camp = tempJungleCamps[tempmeepoTable[meepoHandle].camp.id]
                                        end
                                        
                                        local en = false
                                        
                                        if pushEntity then
                                                for i = 1, #towers do
                                                        local v = towers[i]
                                                        if v.team == meTeam and distance(v,pushEntity) < 1000 then
                                                                def = true
                                                        end
                                                        if v.team ~= meTeam and distance(v,pushEntity) < 1000 and aliveenemies > 2 then
                                                                meepoTable[meepoHandle].state = STATE_FARM_JUNGLE
                                                        end
                                                end
                                                for i = 1, #enemies do
                                                        local e = enemies[i]
                                                        if e.alive and e.visible and distance(e,pushEntity) < 700 and not def then
                                                                en = true
                                                        end
                                                end
                                        end

                                        if en or (not def and (numberOfNotVisibleEnemies > 1 and (dangerousPosition and distance(meepo,dangerousPosition) < 1200))) or (numberOfNotVisibleEnemies > 2 and (dangerousPosition and distance(meepo,dangerousPosition) < 2500)) or (not pushEntity or (camp and not camp.farmed and not camp.visible and not camp.stacking and distance(camp.position,meepo) < distance(pushEntity,meepo) and distance(pushEntity,meepo) > 500)) and aliveenemies > 2 then                          
                                                meepoTable[meepoHandle].state = STATE_FARM_JUNGLE
                                        end

                                        
                                        local tp = false
                                        if pushEntity and pushEntity.alive and not meepo:IsChanneling() then
                                                DebugPrint("FarmJungle2")
                                                if config.UseBoTs then
                                                        tp = useTP(meepo, meepoHandle, pushEntity.position, false, false, meepos, distance, mathcos, mathsin)
                                                else
                                                        tp = useTP(meepo, meepoHandle, pushEntity.position, false, true, meepos, distance, mathcos, mathsin)
                                                end

                                                if distance(pushEntity,meepo) < 500 then
                                                        if pushEntity.classId == CDOTA_BaseNPC_Tower then
                                                                local tank = false
                                                                for i = 1, #lanecreeps do
                                                                        local v = lanecreeps[i]
                                                                        if v.team == meTeam and v.spawned and distance(v,pushEntity) < pushEntity.attackRange+100 then
                                                                                tank = true
                                                                        end
                                                                end
                                                                if tank then
                                                                        OrbWalk(meepo, meepoHandle, pushEntity, pushEntitiesCount > 1, meepos, distance, mathcos, mathsin,mathabs,mathrad,mathceil,mathmax)
                                                                elseif distance(meepo,pushEntity) < pushEntity.attackRange+500 and SleepCheck(meepoHandle.."-move") then
                                                                        local pos = (meepo.position - pushEntity.position) * (distance(meepo,pushEntity) + pushEntity.attackRange+100) / distance(meepo,pushEntity) + meepo.position
                                                                        meepo:Move(pos)
                                                                        Sleep(500, meepoHandle.."-move")
                                                                end
                                                        else
                                                                local poofDmg = mathceil(pushEntity:DamageTaken(poofDamage[1],DAMAGE_MAGC,meepo))
                                                                OrbWalk(meepo, meepoHandle, pushEntity, (pushEntity.health > poofDmg or pushEntitiesCount > 1), meepos, distance, mathcos, mathsin,mathabs,mathrad,mathceil,mathmax)    
                                                        end
                                                elseif SleepCheck(meepoHandle.."-move") then
                                                        meepo:Move(pushEntity.position)
                                                        Sleep(500, meepoHandle.."-move")
                                                end                                     
                                        end
                                end
                                
                                --Jungling
                                if meepo.alive and tempmeepoTable[meepoHandle].state == STATE_FARM_JUNGLE then
                                        local push = {false,0,nil}
                                        for i = 1, entitiesForPushCount do
                                                local creep = entitiesForPush[i]
                                                if creep.team ~= meTeam then
                                                        local en = false
                                                        for i = 1, #enemies do
                                                                local e = enemies[i]
                                                                if e.alive and e.visible and not e:IsIllusion() and distance(e,creep) < 700 then
                                                                        en = true
                                                                end
                                                        end
                                                        if not en then
                                                                push = {true,distance(creep,meepo),creep}
                                                        end
                                                end
                                        end
                                        DebugPrint("FarmJungle1")
                                        if (not tempmeepoTable[meepoHandle].camp or (((gameTime % 60 > 0 and gameTime % 60 < 1) or (tempJungleCamps[tempmeepoTable[meepoHandle].camp.id].farmed and gameTime > 30) or tempJungleCamps[tempmeepoTable[meepoHandle].camp.id].visible) and not tempmeepoTable[meepoHandle].hoveredCamp)) then
                                                DebugPrint("Getting Camp")
                                                meepoTable[meepoHandle].camp = nil
                                                meepoTable[meepoHandle].lastcamp = nil
                                                meepoTable[meepoHandle].camp = getClosestCamp(meepo, false, numberOfNotVisibleEnemies, dangerousPosition, distance)
                                                meepoTable[meepoHandle].hoveredCamp = false
                                        elseif tempmeepoTable[meepoHandle].camp and SleepCheck(meepoHandle.."-camp") and not tempmeepoTable[meepoHandle].hoveredCamp then
                                                DebugPrint("Getting Camp 2")
                                                local camp = getClosestCamp(meepo, false, numberOfNotVisibleEnemies, dangerousPosition, distance)
                                                if camp and (distance(meepo,camp.position) < distance(meepo,tempmeepoTable[meepoHandle].camp.position) or (camp.team ~= meTeam and numberOfNotVisibleEnemies > 2)) then
                                                        meepoTable[meepoHandle].hoveredCamp = false
                                                        meepoTable[meepoHandle].camp = camp
                                                end
                                                Sleep(3000, meepoHandle.."-camp")
                                        end
                                        tempmeepoTable = meepoTable
                                        local camp = nil
                                        if tempmeepoTable[meepoHandle].camp then
                                                camp = tempJungleCamps[tempmeepoTable[meepoHandle].camp.id]
                                        end
                                        local creepForCurrentMeepo = nil
                                        local creepsNearCurrentMeepo = {}
                                        local creepsNearCurrentMeepoCount = 0
                                        local def = false
                                        local back = false
                                        if push[3] then
                                                for i = 1, #towers do
                                                        local v = towers[i]
                                                        if v.team == meTeam and distance(v,push[3]) < 2000 then
                                                                def = true
                                                        end
                                                        if v.team ~= meTeam and distance(v,push[3]) < 2000 then
                                                                back = true
                                                        end
                                                end
                                        end
                                        if camp then
                                                for i = 1, #neutrals do
                                                        local creep = neutrals[i]
                                                        if creep.spawned and distance(meepo,creep) <= 1000 and (distance(camp.position,creep) <= 650 or (creep.visible and distance(creep,camp.position) < 1200)) and creep.alive then
                                                                creepsNearCurrentMeepoCount = creepsNearCurrentMeepoCount + 1
                                                                creepsNearCurrentMeepo[creepsNearCurrentMeepoCount] = creep
                                                                if not creepForCurrentMeepo or creep.health < creepForCurrentMeepo.health then
                                                                        creepForCurrentMeepo = creep
                                                                end
                                                        end
                                                end

                                                if meepo.visibleToEnemy and not tempJungleCamps[camp.id].visible and creepForCurrentMeepo and distance(meepo,camp.position) < 500 then
                                                        JungleCamps[camp.id].visible = true
                                                        JungleCamps[camp.id].visTime = gameTime
                                                        tempJungleCamps = JungleCamps
                                                        meepoTable[meepoHandle].lastcamp = camp
                                                        meepoTable[meepoHandle].camp = nil
                                                        if tempmeepoTable[meepoHandle].foundCreep then
                                                                meepoTable[meepoHandle].foundCreep = false
                                                        end
                                                        meepoTable[meepoHandle].hoveredCamp = false
                                                        camp = getClosestCamp(meepo, false, numberOfNotVisibleEnemies, dangerousPosition, distance)
                                                end
                                                tempmeepoTable = meepoTable
                                                if camp then
                                                        if config.AutoPush and not tempmeepoTable[meepoHandle].hoveredCamp and ((numberOfNotVisibleEnemies < 4 or (not dangerousPosition or distance(meepo,dangerousPosition) > 2500)) or def) and (((push[1] and push[2] < distance(camp.position,meepo)) or def) or camp.farmed or camp.visible) and (not back or aliveenemies < 2) then
                                                                meepoTable[meepoHandle].state = STATE_PUSH
                                                        end
                                                end
                                        elseif SleepCheck(meepoHandle.."-move") then
                                                if config.AutoPush and ((numberOfNotVisibleEnemies < 4 or (not dangerousPosition or distance(meepo,dangerousPosition) > 2500)) or def) and push[1] and (not back or aliveenemies < 2) then
                                                        meepoTable[meepoHandle].state = STATE_PUSH
                                                end
                                                if tempmeepoTable[meepoHandle].lastcamp and distance(meepo, tempmeepoTable[meepoHandle].lastcamp) then
                                                        meepo:Move(tempmeepoTable[meepoHandle].lastcamp.stackPosition)
                                                        Sleep(750,meepoHandle.."-move")
                                                else
                                                        local c = getClosestPos(meepo,distance)
                                                        if distance(meepo,c.stackPosition) > 50 then
                                                                meepo:Move(c.stackPosition)
                                                                Sleep(750,meepoHandle.."-move")
                                                        end
                                                end
                                        end
                                        if camp and not meepo:IsChanneling() then
                                                DebugPrint("FarmJungle2")
                                                local tp = nil
                                                if distance(camp.position,meepo) > 1200 then
                                                        if config.UseBoTs then
                                                                tp = useTP(meepo, meepoHandle, camp.position, false, false, meepos, distance, mathcos, mathsin)
                                                        else
                                                                tp = useTP(meepo, meepoHandle, camp.position, false, true, meepos, distance, mathcos, mathsin)
                                                        end
                                                end

                                                if SleepCheck(meepoHandle.."stack") and (distance(meepo,camp.position) > 450 or not tempmeepoTable[meepoHandle].foundCreep) and SleepCheck(meepoHandle.."-move") and not meepo:IsChanneling() and 
                                                not tp and (not creepForCurrentMeepo or not creepForCurrentMeepo.alive) then
                                                        if tempmeepoTable[meepoHandle].foundCreep then                                          
                                                                meepoTable[meepoHandle].foundCreep = false
                                                        end
                                                        if (tempJungleCamps[camp.id].stacking or (tempJungleCamps[camp.id].farmed and gameTime % 60 > 50)) and distance(meepo,camp.position) < 1500 then
                                                                if distance(meepo,camp.position) < 1000 then                                                    
                                                                        if distance(meepo,camp.stackPosition) > 50 then
                                                                                meepo:Move(camp.stackPosition)
                                                                                Sleep(750,meepoHandle.."-move")
                                                                        end
                                                                elseif meepo.activity == LuaEntityNPC.ACTIVITY_MOVE then
                                                                        DebugPrint("HoldPos")
                                                                        local prev = SelectUnit(meepo)
                                                                        player:HoldPosition()
                                                                        SelectBack(prev)
                                                                end
                                                        elseif not tempmeepoTable[meepoHandle].hoveredCamp or not tempJungleCamps[camp.id].farmed then
                                                                meepo:Move(camp.position)
                                                                Sleep(750,meepoHandle.."-move")
                                                                -- if creepForCurrentMeepo then
                                                                        -- print(meeponumber,creepForCurrentMeepo,creepForCurrentMeepo.name,creepForCurrentMeepo.alive,tempmeepoTable[meepoHandle].foundCreep, distance(meepo,camp.position))
                                                                -- else
                                                                        -- print(meeponumber,creepForCurrentMeepo,tempmeepoTable[meepoHandle].foundCreep, distance(meepo,camp.position))
                                                                -- end
                                                        elseif tempJungleCamps[camp.id].farmed and tempmeepoTable[meepoHandle].hoveredCamp then
                                                                meepo:Move(camp.stackPosition)
                                                                Sleep(750,meepoHandle.."-move")
                                                        end
                                                end
                                                if creepForCurrentMeepo and creepForCurrentMeepo.alive then
                                                        if (meepo.health <= mathmin(mathmax(mathceil(meepo:DamageTaken(creepForCurrentMeepo.dmgMin + creepForCurrentMeepo.dmgBonus,DAMAGE_PHYS,creepForCurrentMeepo))*(creepsNearCurrentMeepoCount)*2, meepo.maxHealth/5),meepo.maxHealth/4.25) or meepo.health < 150) and ((meepo.health <= creepForCurrentMeepo.health) or creepsNearCurrentMeepoCount > 1) then
                                                                if distance(meepo,creepForCurrentMeepo) < creepForCurrentMeepo.attackRange+100 and not IsInDanger(meepo,nil,distance,mathmin) then
                                                                        local pos = (meepo.position - creepForCurrentMeepo.position) * (distance(meepo,creepForCurrentMeepo) + creepForCurrentMeepo.attackRange+100) / distance(meepo,creepForCurrentMeepo) + meepo.position
                                                                        if SleepCheck(meepoHandle.."-move") then
                                                                                meepo:Move(pos)
                                                                                Sleep(500,meepoHandle.."-move")
                                                                        end
                                                                else
                                                                        if not SleepCheck(meepoHandle.."-casting") then
                                                                                local prev = SelectUnit(meepo)
                                                                                player:HoldPosition()
                                                                                SelectBack(prev)
                                                                        end
                                                                        meepoTable[meepoHandle].state = STATE_HEAL
                                                                end
                                                        end
                                                        meepoTable[meepoHandle].foundCreep = true
                                                        tempmeepoTable = meepoTable
                                                        JungleCamps[camp.id].farmed = false
                                                        tempJungleCamps = JungleCamps
                                                        local stackDuration = mathmin((distance(creepForCurrentMeepo,camp.stackPosition)+(creepsNearCurrentMeepoCount*60))/mathmin(creepForCurrentMeepo.movespeed,me.movespeed), 9)
                                                        if creepForCurrentMeepo:IsRanged() and creepsNearCurrentMeepoCount <= 4 then
                                                                stackDuration = mathmin((distance(creepForCurrentMeepo,camp.stackPosition)+creepForCurrentMeepo.attackRange+(creepsNearCurrentMeepoCount*60))/mathmin(creepForCurrentMeepo.movespeed,me.movespeed), 9)
                                                        end
                                                        if SleepCheck(meepoHandle.."-moveStack") and (gameTime % 60 > (60 - stackDuration) and gameTime % 60 < 57) and (distance(creepForCurrentMeepo,meepo) < 250 or tempJungleCamps[camp.id].stacking) then   
                                                                local pos = (camp.stackPosition - creepForCurrentMeepo.position) * (distance(camp.stackPosition,creepForCurrentMeepo) + creepForCurrentMeepo.attackRange) / distance(camp.stackPosition,creepForCurrentMeepo) + camp.stackPosition
                                                                meepo:Move(pos)
                                                                Sleep((distance(meepo,pos)/meepo.movespeed)*1000,meepoHandle.."-moveStack")
                                                                Sleep((60 - (gameTime % 60))*1000,meepoHandle.."stack")
                                                                JungleCamps[camp.id].stacking = true
                                                                tempJungleCamps = JungleCamps
                                                        elseif SleepCheck(meepoHandle.."stack") and not tempJungleCamps[camp.id].stacking then
                                                                local poofDmg = mathceil(creepForCurrentMeepo:DamageTaken(poofDamage[1],DAMAGE_MAGC,meepo))
                                                                if ((creepsNearCurrentMeepoCount > 3 and camp.lvlReq == 8) or (creepsNearCurrentMeepoCount > 4 and camp.lvlReq < 8 and camp.lvlReq >= 3) or (creepsNearCurrentMeepoCount > 4 and camp.lvlReq < 3)) and tempmeepoTable[meepoHandle].poof and tempmeepoTable[meepoHandle].poof.cd == 0 and meepo.mana >= tempmeepoTable[meepoHandle].poof.manacost and (tempmeepoTable[meepoHandle].poof.level == 4 or (tempmeepoTable[meepoHandle].poof.level >= 1 and camp.lvlReq < 8)) then 
                                                                        if tempmeepoTable[meepoHandle].poof and canCast(meepo, tempmeepoTable[meepoHandle].poof) then
                                                                                local pos = camp.position
                                                                                if distance(meepo,creepForCurrentMeepo.position) < distance(meepo,camp.position) then
                                                                                        pos = creepForCurrentMeepo.position
                                                                                end
                                                                                if distance(meepo,pos) > 50 then
                                                                                        if SleepCheck(meepoHandle.."-move") then
                                                                                                meepo:Move(pos)
                                                                                                Sleep(750,meepoHandle.."-move")
                                                                                        end
                                                                                elseif SleepCheck(meepoHandle.."-casting") and distance(meepo,camp.position) < 200 then
                                                                                        meepo:CastAbility(tempmeepoTable[meepoHandle].poof,meepo.position)
                                                                                        Sleep(tempmeepoTable[meepoHandle].poof:FindCastPoint()*1000,meepoHandle.."-casting")
                                                                                end
                                                                        elseif SleepCheck(meepoHandle.."-move") then
                                                                                local pos = (camp.stackPosition - creepForCurrentMeepo.position) * (distance(camp.stackPosition,creepForCurrentMeepo) + creepForCurrentMeepo.attackRange) / distance(camp.stackPosition,creepForCurrentMeepo) + camp.stackPosition
                                                                                meepo:Move(pos)
                                                                                Sleep(750,meepoHandle.."-move")
                                                                                Sleep(mathmin((distance(meepo,camp.stackPosition)/meepo.movespeed)*1000,tempmeepoTable[meepoHandle].poof.cd*1000),meepoHandle.."-orb")                                                  
                                                                        end
                                                                elseif SleepCheck(meepoHandle.."-orb") then
                                                                        OrbWalk(meepo, meepoHandle, creepForCurrentMeepo, (creepForCurrentMeepo.health > poofDmg/1.2 or creepsNearCurrentMeepoCount > 1 or creepForCurrentMeepo.health > meepo.health), meepos, distance, mathcos, mathsin,mathabs,mathrad,mathceil,mathmax)
                                                                end
                                                        end
                                                elseif ((tempmeepoTable[meepoHandle].foundCreep and distance(meepo,camp.position) < 600) or distance(meepo,camp.position) < 200) and SleepCheck("blink") then
                                                        if meepo.health < meepo.maxHealth/4.25 then
                                                                meepoTable[meepoHandle].state = STATE_HEAL
                                                        end
                                                        meepoTable[meepoHandle].lastcamp = camp
                                                        JungleCamps[camp.id].farmed = true
                                                        tempJungleCamps = JungleCamps
                                                        if not tempmeepoTable[meepoHandle].hoveredCamp then
                                                                meepoTable[meepoHandle].camp = nil
                                                                meepoTable[meepoHandle].hoveredCamp = false
                                                        elseif tempmeepoTable[meepoHandle].camp and distance(meepo, tempmeepoTable[meepoHandle].camp.stackPosition) > 100 and SleepCheck(meepoHandle.."-move") then
                                                                meepo:Move(meepoTable[meepoHandle].camp.stackPosition)
                                                                Sleep(750,meepoHandle.."-move")
                                                        end
                                                        if tempmeepoTable[meepoHandle].foundCreep then
                                                                meepoTable[meepoHandle].foundCreep = false
                                                        end
                                                        tempmeepoTable = meepoTable
                                                end
                                        elseif SleepCheck(meepoHandle.."-move") and not meepo:IsChanneling() and not tp then
                                                for i = 1, #entitiesForPush do
                                                        local creep = entitiesForPush[i]
                                                        if creep.team ~= meTeam and distance(creep,meepo) <= 4000 then
                                                                local en = false
                                                                for i = 1, #enemies do
                                                                        local e = enemies[i]
                                                                        if e.alive and e.visible and distance(e,creep) < 700 then
                                                                                en = true
                                                                        end
                                                                end
                                                                local back = false
                                                                for i = 1, #towers do
                                                                        local v = towers[i]
                                                                        if v.team ~= meTeam and distance(v,creep) < 2000 then
                                                                                back = true
                                                                        end
                                                                end
                                                                if config.AutoPush and not en and (not back or aliveenemies < 2) and not tempmeepoTable[meepoHandle].hoveredCamp then
                                                                        meepoTable[meepoHandle].state = STATE_PUSH
                                                                end
                                                        end
                                                end
                                                if not tempmeepoTable[meepoHandle].hoveredCamp then
                                                        meepoTable[meepoHandle].camp = nil
                                                        meepoTable[meepoHandle].hoveredCamp = false
                                                end
                                                if tempmeepoTable[meepoHandle].foundCreep then
                                                        meepoTable[meepoHandle].foundCreep = false
                                                end
                                                if tempmeepoTable[meepoHandle].hoveredCamp then
                                                        meepoTable[meepoHandle].lastcamp = tempmeepoTable[meepoHandle].camp
                                                end 
                                                if tempmeepoTable[meepoHandle].lastcamp then
                                                        meepoTable[meepoHandle].camp = getClosestCamp(meepo,false, numberOfNotVisibleEnemies, dangerousPosition, distance,true)
                                                        if distance(meepo, tempmeepoTable[meepoHandle].lastcamp.stackPosition) > 100 then
                                                                meepo:Move(meepoTable[meepoHandle].lastcamp.stackPosition)
                                                                Sleep(750,meepoHandle.."-move")
                                                        end
                                                else
                                                        meepoTable[meepoHandle].camp = getClosestCamp(meepo,false, numberOfNotVisibleEnemies, dangerousPosition, distance,true)
                                                        camp = meepoTable[meepoHandle].camp
                                                        if camp and distance(meepo, camp.stackPosition) > 100 then
                                                                meepo:Move(camp.stackPosition)
                                                                Sleep(750,meepoHandle.."-move")
                                                        end
                                                end
                                                tempmeepoTable = meepoTable
                                        end
                                end
                                                
                                --Stacking
                                if meepo.alive and tempmeepoTable[meepoHandle].state == STATE_STACK then
                                        
                                        if (not tempmeepoTable[meepoHandle].camp or ((gameTime % 60 > 0 and gameTime % 60 < 1) or tempJungleCamps[tempmeepoTable[meepoHandle].camp.id].farmed or tempJungleCamps[tempmeepoTable[meepoHandle].camp.id].visible)) then
                                                DebugPrint("Getting Camp")
                                                meepoTable[meepoHandle].camp = getClosestCamp(meepo, true, numberOfNotVisibleEnemies,nil, distance)
                                        elseif tempmeepoTable[meepoHandle].camp and SleepCheck(meepoHandle.."-camp") then
                                                DebugPrint("Getting Camp 2")
                                                local camp = getClosestCamp(meepo, true, numberOfNotVisibleEnemies,nil, distance)
                                                if camp and (distance(meepo,camp.position) < distance(meepo,tempmeepoTable[meepoHandle].camp.position) or (camp.team ~= meTeam and numberOfNotVisibleEnemies > 3)) then
                                                        meepoTable[meepoHandle].camp = camp
                                                end
                                                Sleep(3000, meepoHandle.."-camp")
                                        end
                                        local camp = nil
                                        tempmeepoTable = meepoTable
                                        if tempmeepoTable[meepoHandle].camp then
                                                camp = tempJungleCamps[tempmeepoTable[meepoHandle].camp.id]
                                        end
                                        local creepForCurrentMeepo = nil
                                        local creepsNearCurrentMeepo = {}
                                        local creepsNearCurrentMeepoCount = 0
                                        if camp then
                                                for i = 1, #neutrals do
                                                        local creep = neutrals[i]
                                                        if creep.visible and creep.spawned and distance(creep,meepo) <= 900 and (distance(camp.position,meepo) <= 1000 or (creep.visible and distance(creep,camp.position) < 1200)) then
                                                                creepsNearCurrentMeepoCount = creepsNearCurrentMeepoCount + 1
                                                                creepsNearCurrentMeepo[creepsNearCurrentMeepoCount] = creep
                                                                if not creepForCurrentMeepo or distance(meepo, creep) > distance(meepo, creepForCurrentMeepo) then
                                                                        creepForCurrentMeepo = creep
                                                                end
                                                        end
                                                end

                                                if meepo.visibleToEnemy and not tempJungleCamps[camp.id].visible and creepForCurrentMeepo then
                                                        JungleCamps[camp.id].visible = true
                                                        JungleCamps[camp.id].visTime = gameTime
                                                        tempJungleCamps = JungleCamps
                                                        meepoTable[meepoHandle].lastcamp = camp
                                                        meepoTable[meepoHandle].camp = nil
                                                        if tempmeepoTable[meepoHandle].foundCreep then
                                                                meepoTable[meepoHandle].foundCreep = false
                                                        end
                                                        camp = getClosestCamp(meepo, true, numberOfNotVisibleEnemies,nil, distance)
                                                end
                                        elseif SleepCheck(meepoHandle.."-move") then
                                                if tempmeepoTable[meepoHandle].lastcamp and distance(meepo, meepoTable[meepoHandle].lastcamp.stackPosition) > 50 then
                                                        meepo:Move(meepoTable[meepoHandle].lastcamp.stackPosition)
                                                        Sleep(750,meepoHandle.."-move")
                                                end
                                        end
                                        tempmeepoTable = meepoTable
                                                
                                        if camp and not meepo:IsChanneling() then
                                                DebugPrint("FarmJungle2")
                                                
                                                local tp = nil
                                                if config.UseBoTs then
                                                        tp = useTP(meepo, meepoHandle, camp.position, false, false, meepos, distance, mathcos, mathsin)
                                                else
                                                        tp = useTP(meepo, meepoHandle, camp.position, false, true, meepos, distance, mathcos, mathsin)
                                                end

                                                local stackDuration = 0
                                                if creepForCurrentMeepo and creepForCurrentMeepo.alive then
                                                        stackDuration = mathmin((distance(creepForCurrentMeepo,camp.stackPosition)+(creepsNearCurrentMeepoCount*45))/mathmin(creepForCurrentMeepo.movespeed,me.movespeed), 9)
                                                        if creepForCurrentMeepo:IsRanged() and creepsNearCurrentMeepoCount <= 4 then
                                                                stackDuration = mathmin((distance(creepForCurrentMeepo,camp.stackPosition)+creepForCurrentMeepo.attackRange+(creepsNearCurrentMeepoCount*45))/mathmin(creepForCurrentMeepo.movespeed,me.movespeed), 9)
                                                        end
                                                end
                                                local moveTime = 50 - (distance(meepo,camp.position)+50)/meepo.movespeed
                                                if stackDuration > 0 then
                                                        moveTime = 60 - stackDuration - (distance(meepo,creepForCurrentMeepo.position)+50)/meepo.movespeed
                                                end
                                                if SleepCheck(meepoHandle.."stack") and SleepCheck(meepoHandle.."-move") and not meepo:IsChanneling() and 
                                                not tp then
                                                        if gameTime % 60 < moveTime then
                                                                if distance(meepo,camp.waitPosition) > 50 then
                                                                        meepo:Move(camp.waitPosition)
                                                                end
                                                        elseif (not creepForCurrentMeepo or not creepForCurrentMeepo.visible) then
                                                                if distance(meepo,camp.position) > 50 then
                                                                        meepo:Move(camp.position)
                                                                end
                                                        end
                                                        Sleep(750,meepoHandle.."-move")
                                                end
                                                if gameTime % 60 > moveTime then
                                                        if creepForCurrentMeepo and creepForCurrentMeepo.alive then
                                                                meepoTable[meepoHandle].foundCreep = true
                                                                JungleCamps[camp.id].farmed = false
                                                                tempJungleCamps = JungleCamps
                                                                if SleepCheck(meepoHandle.."-moveStack") and (gameTime % 60 > (60 - stackDuration) and gameTime % 60 < 57) and (distance(creepForCurrentMeepo,meepo) < 700 or tempJungleCamps[camp.id].stacking) then   
                                                                        local pos = (camp.stackPosition - creepForCurrentMeepo.position) * (distance(camp.stackPosition,creepForCurrentMeepo) + creepForCurrentMeepo.attackRange) / distance(camp.stackPosition,creepForCurrentMeepo) + camp.stackPosition
                                                                        meepo:Move(pos)
                                                                        Sleep((distance(meepo,pos)/meepo.movespeed)*1000,meepoHandle.."-moveStack")
                                                                        Sleep((60 - (gameTime % 60))*1000,meepoHandle.."stack")
                                                                        JungleCamps[camp.id].stacking = true
                                                                        tempJungleCamps = JungleCamps
                                                                elseif SleepCheck(meepoHandle.."stack") and not tempJungleCamps[camp.id].stacking and SleepCheck(meepoHandle.."-attack") then
                                                                        local pos = (creepForCurrentMeepo.position - meepo.position) * (distance(meepo.position,creepForCurrentMeepo) - 800) / distance(meepo.position,creepForCurrentMeepo) + creepForCurrentMeepo.position
                                                                        meepo:Move(pos)
                                                                        meepo:Move(camp.stackPosition,true)
                                                                        Sleep(5000,meepoHandle.."-attack")
                                                                end
                                                                tempmeepoTable = meepoTable
                                                        end
                                                end
                                        end
                                end
                        
                                --Drawings
                                if not meepoNumberSigns[meepoHandle] then
                                        if meeponumber == 1 then
                                                meepoNumberSigns[meepoHandle] = drawMgr:CreateText(-7*monitor,-90*monitor,-1,""..meeponumber,F15)
                                        else
                                                meepoNumberSigns[meepoHandle] = drawMgr:CreateText(-7*monitor,-80*monitor,-1,""..meeponumber,F15)
                                        end
                                        meepoNumberSigns[meepoHandle].visible = true
                                        meepoNumberSigns[meepoHandle].entity = meepo
                                        meepoNumberSigns[meepoHandle].entityPosition = Vector(0,0,meepo.healthbarOffset)
                                end
                                if not meepoNumberSigns[meepoHandle.."-num"] then
                                        meepoNumberSigns[meepoHandle.."-num"] = drawMgr:CreateText(2,70 + 79*(meeponumber-1),-1,""..meeponumber,F15)
                                end
                                if not meepoNumberSigns[meepoHandle.."-minimap"] then
                                        local minimap_vec = MapToMinimap(meepo.position.x,meepo.position.y)
                                        meepoNumberSigns[meepoHandle.."-minimap"] = drawMgr:CreateText(minimap_vec.x-2+minimapMove,minimap_vec.y-5,-1,""..meeponumber,F13)
                                elseif SleepCheck(meepoHandle.."-minimap") then
                                        local minimap_vec = MapToMinimap(meepo.position.x,meepo.position.y)
                                        meepoNumberSigns[meepoHandle.."-minimap"].x, meepoNumberSigns[meepoHandle.."-minimap"].y = minimap_vec.x-2+minimapMove,minimap_vec.y-5
                                        Sleep(Animations.maxCount*2, meepoHandle.."-minimap")
                                end
                                local sign = statesSigns[tempmeepoTable[meepoHandle].state]
                                if sign then
                                        if not meepoStateSigns[meepoHandle] then
                                                meepoStateSigns[meepoHandle] = drawMgr:CreateText(120,79*meeponumber,sign[2],""..sign[1],F14) meepoStateSigns[meepoHandle].visible = true
                                        else
                                                meepoStateSigns[meepoHandle].text = ""..sign[1]
                                                if tempmeepoTable[meepoHandle].state == STATE_CHASE and tempmeepoTable[meepoHandle].victim then 
                                                        meepoStateSigns[meepoHandle].text = meepoStateSigns[meepoHandle].text..": "..client:Localize(tempmeepoTable[meepoHandle].victim.name)
                                                end
                                                meepoStateSigns[meepoHandle].color = sign[2]
                                        end
                                end
                                
                                --Determining move and idle states
                                if meepo.state == STATE_NONE or meepo.state == STATE_MOVE then
                                        if meepo.activity == LuaEntityNPC.ACTIVITY_MOVE then
                                                meepoTable[meepoHandle].state = STATE_MOVE
                                        elseif meepo.activity == LuaEntityNPC.ACTIVITY_IDLE then
                                                meepoTable[meepoHandle].state = STATE_NONE
                                        end
                                        tempmeepoTable = meepoTable
                                end

                        elseif tempmeepoTable[meepoHandle] then
                        
                                --Reseting meepo attributes when he ded
                                --print("reset")
                                meepoTable[meepoHandle].state = STATE_LANE
                                meepoTable[meepoHandle].victim = nil
                                meepoTable[meepoHandle].foundCreep = false
                                meepoTable[meepoHandle].camp = nil
                                meepoTable[meepoHandle].victimFogTime = 0               
                                tempmeepoTable = meepoTable
                        end
                end
        end 
        
        if not tempmeepoTable[myHand].blink then
                meepoTable[myHand].blink = me:FindItem("item_blink")
                tempmeepoTable = meepoTable
        end
        
        --Blink
        if SleepCheck("blink") and (victim and victim.visible and distance(me,victim) > 700 and distance(me,victim) < 1700 and (tempmeepoTable[myHand].state == STATE_CHASE and me.health > (me.maxHealth/3)) or 
        (tempmeepoTable[myHand].camp and distance(me,tempmeepoTable[myHand].camp.position) > 200 and distance(me,tempmeepoTable[myHand].camp.position) < 1200 and tempmeepoTable[myHand].state == STATE_FARM_JUNGLE)) and retreatkeyCount == 0 and not retreat then
                local blink = tempmeepoTable[myHand].blink
                local blinkPos = nil
                if (victim and (victim.hero or victim.classId == CDOTA_Unit_SpiritBear) and victim.visible and distance(me,victim) > 700 and distance(me,victim) < 1700 and tempmeepoTable[myHand].state == STATE_CHASE) then
                        blinkPos = victim.position
                elseif tempmeepoTable[myHand].state == STATE_FARM_JUNGLE and tempmeepoTable[myHand].camp and not tempmeepoTable[myHand].camp.farmed and not tempmeepoTable[myHand].camp.visible and not tempmeepoTable[myHand].camp.stacking then
                        blinkPos = tempmeepoTable[myHand].camp.position
                end
                if blinkPos then
                        if distance(me,blinkPos) > 1100 then
                                blinkPos = (blinkPos - me.position) * 1100 / distance(blinkPos,me) + me.position
                        end
                        meepoTable[myHand].blinkPos = blinkPos
                        tempmeepoTable = meepoTable
                        if canCast(me, blink) then
                                DebugPrint("blink")
                                me:CastAbility(blink,blinkPos)
                                if victim then
                                        Sleep(me:GetTurnTime(victim)*1000,myHand.."-casting")
                                        Sleep(me:GetTurnTime(victim)*1000+500,"blink")
                                else
                                        Sleep(me:GetTurnTime(tempmeepoTable[myHand].camp.position)*1000,myHand.."-casting")
                                        Sleep(me:GetTurnTime(tempmeepoTable[myHand].camp.position)*1000+500,"blink")
                                end
                        end
                end
        end
end

----Better functions to collect our meepos. Currently broken in Ensage

-- function meepoAdd(entity)
        -- --print("asd")
        -- if entity.type == LuaEntity.TYPE_MEEPO and not meepoTable[entity.handle] then
                -- meepoTable[entity.handle] = entity
        -- end
-- end

-- function meepoUpdate(propertyName,entity,newData)
        -- if entity.type == LuaEntity.TYPE_MEEPO then
                -- meepoTable[entity.handle] = entity
        -- end
-- end

----Function called on Load, registers our Main tick function and ensures reseting of all variables and settings to prevent crash

function Load() 
        
        --Checking version
        --download()
        local up,ver,beta,info = Version()
        if up then
                if beta ~= "" then
                        versionSign.text = "Your version of iMeepo is up-to-date! (v"..currentVersion.." "..Beta..")"
                else
                        versionSign.text = "Your version of iMeepo is up-to-date! (v"..currentVersion..")"
                end
                versionSign.color = 0x66FF33FF
                if info then
                        infoSign.text = info
                        infoSign.visible = true
                end
        end
        if outdated then
                if beta ~= "" then
                        versionSign.text = "Your version of iMeepo is OUTDATED (Yours: v"..currentVersion.." "..Beta.." Current: v"..ver.." "..beta.."), send me email to moones@email.cz to get current one!"
                else
                        versionSign.text = "Your version of iMeepo is OUTDATED (Yours: v"..currentVersion.." "..Beta.." Current: v"..ver.."), send me email to moones@email.cz to get current one!"
                end
                versionSign.color = 0xFF6600FF
                if info then
                        infoSign.text = info
                        infoSign.visible = true
                end
        end
        versionSign.visible = true
        
        if PlayingGame() then
                me = entityList:GetMyHero()
                player = entityList:GetMyPlayer()
                if not player or not me or me.classId ~= CDOTA_Unit_Hero_Meepo then 
                        versionSign.visible = false
                        infoSign.visible = false
                        script:Disable()
                else
                        reg = true start = false myId = me.classId active = true meepoTable = {} DWS = {} base = nil allies = nil enemies = nil outdated = false retreat = false
                        retreattime = nil castingEarthbind = {0,0,0,0,0,0,0} poofDamage = { 0, 0 } meepoStateSigns = {} entitiesForPush = {} meepoMinimapNumberSigns = {} meepoNumberSigns = {}
                        spellDamageTable = {} mousehoverCamp = nil closestCamp = nil retreatStartTime = nil aoeStarttime = nil start,vec = nil,nil retreatkeyCount = 0 doubleclickTime = nil
                        EthDmg = 0 campSigns = {} eff = nil enemyTeam = nil meTeam = nil targetlock = false victim = nil
                        JungleCamps = {
                                {position = Vector(-1131,-4044,127), stackPosition = Vector(-2498.94,-3517.86,128), waitPosition = Vector(-1401.69,-3791.52,128), team = 2, id = 1, farmed = false, lvlReq = 8, visible = false, visTime = 0, stacking = false},
                                {position = Vector(-366,-2945,127), stackPosition = Vector(-534.219,-1795.27,128), waitPosition = Vector(536,-3001,256), team = 2, id = 2, farmed = false, lvlReq = 3, visible = false, visTime = 0, stacking = false},
                                {position = Vector(1606.45,-3433.36,256), stackPosition = Vector(1325.19,-5108.22,256), waitPosition = Vector(1541.87,-4265.38,256), team = 2, id = 3, farmed = false, lvlReq = 8, visible = false, visTime = 0, stacking = false},
                                {position = Vector(3126,-3439,256), stackPosition = Vector(4410.49,-3985,256), waitPosition = Vector(3401.5,-4233.39,256), team = 2, id = 4, farmed = false, lvlReq = 3, visible = false, visTime = 0, stacking = false},
                                {position = Vector(3031.03,-4480.06,256), stackPosition = Vector(1368.66,-5279.04,256), waitPosition = Vector(2939.61,-5457.52,256), team = 2, id = 5, farmed = false, lvlReq = 1, visible = false, visTime = 0, stacking = false},
                                {position = Vector(-2991,191,256), stackPosition = Vector(-3483,-1735,247), waitPosition = Vector(-2433,-356,256), team = 2, id = 6, farmed = false, lvlReq = 12, visible = false, visTime = 0, ancients = true, stacking = false},
                                {position = Vector(1167,3295,256), stackPosition = Vector(570.86,4515.96,256), waitPosition = Vector(1011,3656,256), team = 3, id = 7, farmed = false, lvlReq = 8, visible = false, visTime = 0, stacking = false},
                                {position = Vector(-244,3629,256), stackPosition = Vector(-1170.27,4581.59,256), waitPosition = Vector(-515,4845,256), team = 3, id = 8, farmed = false, lvlReq = 3, visible = false, visTime = 0, stacking = false},
                                {position = Vector(-1588,2697,127), stackPosition = Vector(-1302,3689.41,136.411), waitPosition = Vector(-1491,2986,127), team = 3, id = 9, farmed = false, lvlReq = 3, visible = false, visTime = 0, stacking = false},
                                {position = Vector(-3157.74,4475.46,256), stackPosition = Vector(-3296.1,5508.48,256), waitPosition = Vector(-3086,4924,256), team = 3, id = 10, farmed = false, lvlReq = 1, visible = false, visTime = 0, stacking = false},
                                {position = Vector(-4382,3612,256), stackPosition = Vector(-3026.54,3819.69,132.345), waitPosition = Vector(-3995,3984,256), team = 3, id = 11, farmed = false, lvlReq = 8, visible = false, visTime = 0, stacking = false},
                                {position = Vector(4026,-709.943,128), stackPosition = Vector(2228.46,-1046.78,128), waitPosition = Vector(3122,-1158.69,128), team = 3, id = 12, farmed = false, lvlReq = 12, visible = false, visTime = 0,  ancients = true, stacking = false}
                        }
                        script:RegisterEvent(EVENT_FRAME, Main)
                        -- script:RegisterEvent(EVENT_ENTITY_ADD, meepoAdd)
                        -- script:RegisterEvent(EVENT_ENTITY_UPDATE, meepoUpdate)
                        script:RegisterEvent(EVENT_KEY, Key)
                        script:UnregisterEvent(Load)
                end
        end     
end

----Function called on close, unregisters our Main tick function and resets everything as well

function Close()
        start = false enemyTeam = nil meTeam = nil
        myId = nil
        active = true
        meepoTable = {}
        DWS = {}
        base = nil
        allies = nil 
        enemies = nil
        castingEarthbind = {0,0,0,0,0,0,0}
        poofDamage = { 0, 0 }
        meepoStateSigns = {}
        entitiesForPush = {}
        meepoMinimapNumberSigns = {}
        meepoNumberSigns = {}
        spellDamageTable = {}
        mousehoverCamp = nil
        closestCamp = nil
        outdated = false 
        retreat = false
        retreattime = nil
        retreatStartTime = nil
        aoeStarttime = nil
        start,vec = nil,nil
        retreatkeyCount = 0
        doubleclickTime = nil
        me = nil
        player = nil
        meepos = nil
        JungleCamps = {
                {position = Vector(-1131,-4044,127), stackPosition = Vector(-2498.94,-3517.86,128), waitPosition = Vector(-1401.69,-3791.52,128), team = 2, id = 1, farmed = false, lvlReq = 8, visible = false, visTime = 0, stacking = false},
                {position = Vector(-366,-2945,127), stackPosition = Vector(-534.219,-1795.27,128), waitPosition = Vector(536,-3001,256), team = 2, id = 2, farmed = false, lvlReq = 3, visible = false, visTime = 0, stacking = false},
                {position = Vector(1606.45,-3433.36,256), stackPosition = Vector(1325.19,-5108.22,256), waitPosition = Vector(1541.87,-4265.38,256), team = 2, id = 3, farmed = false, lvlReq = 8, visible = false, visTime = 0, stacking = false},
                {position = Vector(3126,-3439,256), stackPosition = Vector(4410.49,-3985,256), waitPosition = Vector(3401.5,-4233.39,256), team = 2, id = 4, farmed = false, lvlReq = 3, visible = false, visTime = 0, stacking = false},
                {position = Vector(3031.03,-4480.06,256), stackPosition = Vector(1368.66,-5279.04,256), waitPosition = Vector(2939.61,-5457.52,256), team = 2, id = 5, farmed = false, lvlReq = 1, visible = false, visTime = 0, stacking = false},
                {position = Vector(-2991,191,256), stackPosition = Vector(-3483,-1735,247), waitPosition = Vector(-2433,-356,256), team = 2, id = 6, farmed = false, lvlReq = 12, visible = false, visTime = 0, ancients = true, stacking = false},
                {position = Vector(1167,3295,256), stackPosition = Vector(570.86,4515.96,256), waitPosition = Vector(1011,3656,256), team = 3, id = 7, farmed = false, lvlReq = 8, visible = false, visTime = 0, stacking = false},
                {position = Vector(-244,3629,256), stackPosition = Vector(-1170.27,4581.59,256), waitPosition = Vector(-515,4845,256), team = 3, id = 8, farmed = false, lvlReq = 3, visible = false, visTime = 0, stacking = false},
                {position = Vector(-1588,2697,127), stackPosition = Vector(-1302,3689.41,136.411), waitPosition = Vector(-1491,2986,127), team = 3, id = 9, farmed = false, lvlReq = 3, visible = false, visTime = 0, stacking = false},
                {position = Vector(-3157.74,4475.46,256), stackPosition = Vector(-3296.1,5508.48,256), waitPosition = Vector(-3086,4924,256), team = 3, id = 10, farmed = false, lvlReq = 1, visible = false, visTime = 0, stacking = false},
                {position = Vector(-4382,3612,256), stackPosition = Vector(-3026.54,3819.69,132.345), waitPosition = Vector(-3995,3984,256), team = 3, id = 11, farmed = false, lvlReq = 8, visible = false, visTime = 0, stacking = false},
                {position = Vector(4026,-709.943,128), stackPosition = Vector(2228.46,-1046.78,128), waitPosition = Vector(3122,-1158.69,128), team = 3, id = 12, farmed = false, lvlReq = 12, visible = false, visTime = 0,  ancients = true, stacking = false}
        }
        campSigns = {}
        collectgarbage("collect")
        if reg then
                script:UnregisterEvent(Main)
                -- script:UnregisterEvent(meepoAdd)
                -- script:UnregisterEvent(meepoUpdate)
                script:UnregisterEvent(Key)
                script:RegisterEvent(EVENT_TICK, Load)  
                reg = false
        end
end

--Registering our Load and Close functions

script:RegisterEvent(EVENT_CLOSE, Close)
script:RegisterEvent(EVENT_TICK, Load)

--END of GLOBAL CONSTANTS--

--FUNCTIONS--

----Determining if given spell can be casted by meepo

function canCast(meepo, spell) 
        return meepo and spell and spell:CanBeCasted() and meepo:CanCast()
end

----Determining if victim will get hit by Poof

function willHit(meepo, victim, radius, n, meepos, distance, mathcos, mathsin)
        local near,dist,nearMeepo = anyMeepoisNear(victim, radius, meepo, meepos, distance, mathcos, mathsin)
        return ((radius and distance(meepo, victim) <= radius+150) or (n and near and dist <= radius+150)) and 
        (victim:IsStunned() or victim:IsRooted() or victim.movespeed < 200 or victim.creep or victim.classId == CDOTA_BaseNPC_Creep_Neutral or 
        Animations.isAttacking(victim) or (n and near and nearMeepo.handle ~= meepo.handle) or 
        victim.activity == LuaEntityNPC.ACTIVITY_IDLE)
end

----Determining when to use earthbind to ensure 100% chaining

function chainEarthbind(meepo, target, delay, meepos)
        local chain = false
        local stunned = false
        local modifiers_table = {"modifier_shadow_demon_disruption", "modifier_obsidian_destroyer_astral_imprisonment_prison", 
                "modifier_eul_cyclone", "modifier_invoker_tornado", "modifier_bane_nightmare", "modifier_shadow_shaman_shackles", 
                "modifier_crystal_maiden_frostbite", "modifier_ember_spirit_searing_chains", "modifier_axe_berserkers_call",
                "modifier_lone_druid_spirit_bear_entangle_effect", "modifier_meepo_earthbind", "modifier_naga_siren_ensnare",
                "modifier_storm_spirit_electric_vortex_pull", "modifier_treant_overgrowth", "modifier_cyclone",
                "modifier_sheepstick_debuff", "modifier_shadow_shaman_voodoo", "modifier_lion_voodoo", "modifier_brewmaster_storm_cyclone",
                "modifier_puck_phase_shift"}
        local modifiers = target.modifiers
        local length = #modifiers_table
        table.sort(modifiers, function (a,b) return a.remainingTime > b.remainingTime end)
        for i = 1, #modifiers do
                local m = modifiers[i]
                for z = 1, length do
                        local k = modifiers_table[z]
                        if m and (m.stunDebuff or m.name == k) then
                                stunned = true
                                local remainingTime = m.remainingTime
                                if m.name == "modifier_eul_cyclone" then remainingTime = m.remainingTime+0.07 end
                                if remainingTime <= delay then
                                        chain = true
                                else
                                        chain = false
                                end
                        end
                end
        end
        return not (stunned or target:IsStunned()) or chain
end

----Collecting our meepos

function collectMeepos(meepos)
        for i = 1, #meepos do
                local meepo = meepos[i]
                if meepo and meepo.alive then
                        local hand = meepo.handle
                        if not meepoTable[hand] and not meepo:IsIllusion() then
                                meepoTable[hand] = {}
                                meepoTable[hand].state = STATE_LANE
                                meepoTable[hand].lastState = nil
                                meepoTable[hand].victim = nil
                                meepoTable[hand].lastcamp = nil
                                meepoTable[hand].foundCreep = false
                                meepoTable[hand].camp = nil
                                meepoTable[hand].victimFogTime = 0
                                meepoTable[hand].poof = meepo:GetAbility(2)
                                meepoTable[hand].earthbind = meepo:GetAbility(1)
                        end
                end
        end
end

----Checking if any meepo is casting Earthbind right now

function earthbindAnimation(meepos)
        for i = 1, #meepos do
                local meepo = meepos[i]
                local earthbind = meepo:GetAbility(1)
                if earthbind and earthbind.abilityPhase then
                        return true
                end
        end
        return false
end

----Checking if any meepo is farming

function anyMeepoIsPushing(meepos)
        for i = 1, #meepos do
                local meepo = meepos[i]
                if meepo.state == STATE_PUSH then
                        return true
                end
        end
        return false
end

----Getting position where to move for meepos to attempt blocking victim

function getBlockPositions(victim,rotR,meepo, mathcos, mathsin)
        local me = me
        local rotR1,rotR2 = -rotR,(-3-rotR)
        local infront = Vector(victim.position.x+me.movespeed*mathcos(rotR), victim.position.y+me.movespeed*mathsin(rotR), victim.position.z)
        local behind = Vector(victim.position.x+(-me.movespeed/2)*mathcos(rotR), victim.position.y+(-me.movespeed/2)*mathsin(rotR), victim.position.z)
        return Vector(infront.x+90*mathcos(rotR1), infront.y+90*mathsin(rotR1), infront.z),
        Vector(infront.x+90*mathcos(rotR2), infront.y+90*mathsin(rotR2), infront.z),
        Vector(behind.x+120*mathcos(rotR1), behind.y+120*mathsin(rotR1), behind.z),
        Vector(behind.x+120*mathcos(rotR2), behind.y+120*mathsin(rotR2), behind.z),infront
end

----Checking if victim is facing any of our meepos

function isFacingAnyMeepo(victim,meepos,mathabs,mathrad,mathmax)
        for i = 1, #meepos do
                local m = meepos[i]
                if (mathmax(mathabs(FindAngleR(victim) - mathrad(FindAngleBetween(victim, m))) - 0.20, 0)) <= 0.01 then
                        return true
                end
        end
        return false
end

----Checking if we have any meepo near victim

function anyMeepoisNear(victim, range, meepo, meepos, distance, mathcos, mathsin)
        local closest = nil
        for i = 1, #meepos do
                local m = meepos[i]
                if victim then
                        local pos = victim
                        if GetType(pos) ~= "Vector" then pos = victim.position end
                        local mpos = m.position
                        local dist = distance(mpos,pos)
                        if not closest or dist < distance(closest,pos) then
                                closest = m
                        end     
                end
        end
        if closest then
                local pos = victim
                if GetType(pos) ~= "Vector" then pos = victim.position end
                local mpos = closest.position
                if victim.activity == LuaEntityNPC.ACTIVITY_MOVE then
                        pos = Vector(victim.position.x+(victim.movespeed*1.5)*mathcos(victim.rotR), victim.position.y+(victim.movespeed*1.5)*mathsin(victim.rotR), victim.position.z)
                end
                if closest.activity == LuaEntityNPC.ACTIVITY_MOVE then
                        mpos = Vector(closest.position.x+(closest.movespeed)*mathcos(closest.rotR), closest.position.y+(closest.movespeed)*mathsin(closest.rotR), closest.position.z)
                end
                local dist = distance(mpos,pos)
                if (range and dist < range) and (not meepo or closest.handle ~= meepo.handle) then
                        return true,dist,closest
                end
        end
        return false,0,nil
end

----Returns lowest HP meepo

function getLowestHPMeepo(meepos)
        local lowest = nil
        for i = 1, #meepos do
                local meepo = meepos[i]
                if not lowest or lowest.health > meepo.health then
                        lowest = meepo
                end
        end
        return lowest
end

----Returns closest meepo to victim

function getClosest(victim, num, net, exclude, meepos, distance)
        --local meepos = entityList:GetEntities({type=LuaEntity.TYPE_MEEPO, team=meTeam, alive=true})
        if net or num == 1 then
                local closest = nil
                for i = 1, #meepos do
                        local meepo = meepos[i]
                        if not meepo:IsIllusion() and (not exclude or meepo.handle ~= exclude.handle) and meepo.alive and ((meepoTable[meepo.handle].earthbind and canCast(meepo, meepoTable[meepo.handle].earthbind)) or not net) and (not closest or (victim and distance(meepo,victim) < distance(closest,victim))) then
                                closest = meepo
                        end
                end
                return closest
        elseif num > 1 then
                --table.sort(meepos, function (a,b) return distance(a,victim) < distance(b,victim) end)         
                local returnTable = {}
                local number = 0
                for i = 1, #meepos do
                        local meepo = meepos[i]
                        number = number + 1
                        if meepo.alive and number <= num and not meepoTable[meepo.handle].victim then
                                returnTable[i] = meepo
                        end
                end
                return returnTable 
        else
                --table.sort(meepos, function (a,b) return distance(a,victim) < distance(b,victim) end)
                local returnTable = {}
                for i = 1, #meepos do
                        local meepo = meepos[i]
                        if meepo.alive and not meepoTable[meepo.handle].victim then
                                returnTable[i] = meepo
                                return returnTable
                        end
                end
        end
        return nil
end

----Returns number of alive meepos

function getAliveNumber(all,meepos)
        local number = 0
        for i = 1, #meepos do
                local meepo = meepos[i]
                if meepo.alive and ((meepoTable[meepo.handle] and meepoTable[meepo.handle].state ~= STATE_HEAL) or all) then
                        number = number + 1
                end
        end
        return number
end             

----Checks if main meepo has items for heal and is close to given meepo

function haveHealingItems(meepo, distance)
        local me = me
        local isMe = false
        if meepo.handle == me.handle then
                me = meepo
                isMe = true
        end
        local salve = me:FindItem("item_flask")
        local bottle = me:FindItem("item_bottle")
        local items = {}
        if salve then
                items[#items+1] = salve
        end
        if bottle and bottle.charges > 0 then
                items[#items+1] = bottle
        end
        if items[1] and (distance(me, meepo) < 1000 or isMe) then
                return false, items, isMe
        end
        return true, nil
end


----Checks if given meepo is in danger

function IsInDanger(meepo,except,distance,mathmin)
        if meepo and meepo.alive then
                local projs = entityList:GetProjectiles({target=meepo})
                for k = 1, #projs do
                        local z = projs[k]      
                        if z and z.source and z.target == meepo and (not except or z.source.handle ~= except.handle) and (distance(z,z.source) < 1000 or (z.source.dmgMin and z.source.dmgMin > meepo.health)) then
                                return true
                        end
                end
                for i = 1, #enemies do
                        local v = enemies[i]            
                        if v.alive and v.visible and distance(meepo,v) < 700 and (not except or v.handle ~= except.handle) then
                                return true
                        end
                end
                local neutrals = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Neutral,visible=true})
                for i = 1, #neutrals do
                        local v = neutrals[i]   
                        if distance(meepo,v) < v.attackRange+200 and v.alive and (not except or v.handle ~= except.handle) and v.activity == LuaEntityNPC.ACTIVITY_ATTACK then
                                return true
                        end
                        for i = 1, #v.abilities do
                                local k = v.abilities[i]
                                if distance(meepo,v) < mathmin(k.castRange+200,1000) and (not except or v.handle ~= except.handle) then
                                        return true
                                end
                        end
                end
                local modifiers = {"modifier_item_urn_damage","modifier_doom_bringer_doom","modifier_axe_battle_hunger",
                "modifier_queenofpain_shadow_strike","modifier_phoenix_fire_spirit_burn","modifier_venomancer_poison_nova",
                "modifier_venomancer_venomous_gale","modifier_silencer_curse_of_the_silent","modifier_silencer_last_word","modifier_spirit_breaker_charge_of_darkness_vision",
                "modifier_bloodseeker_thirst"}
                for i = 1, #modifiers do
                        local v = modifiers[i]
                        if meepo:DoesHaveModifier(v) then
                                return true
                        end
                end
        end
end

----Return how many meepos are farming this camp

function getFarmingMeeposCamp(camp,current)
        if camp then
                local number = 0
                local tempmeepoTable = meepoTable
                for meepoHandle, meepo in pairs(tempmeepoTable) do
                        local meepo = tempmeepoTable[meepoHandle]
                        if meepo.camp and meepo.camp == camp and (not current or meepo.handle ~= current.handle) then
                                number = number + 1
                        end
                end
                return number
        end
end

----Returns closest jungle camp for given meepo

function getClosestCamp(meepo, stack, num, pos, distance, any)
        if meepo and meepo.health and meepo.alive then
                local closest = nil
                local tempJungleCamps = JungleCamps
                for i = 1, #tempJungleCamps do
                        local camp = tempJungleCamps[i]
                        local number = getFarmingMeeposCamp(camp,meepo)
                        local cnumber = 0
                        if closest then 
                                cnumber = getFarmingMeeposCamp(closest,meepo)
                        end
                        local reqNum = 1
                        if camp.ancients then
                                reqNum = 2
                        elseif meepo.level < 10 then
                                reqNum = 3
                        end
                        if (camp.team == meepo.team or ((not num or num < 2 or (not pos or distance(meepo,pos) > 2500)) and client.gameTime > 2400)) and ((not camp.visible and ((not stack and meepo.level >= camp.lvlReq) or (stack and camp.lvlReq == 8)) and (camp.team == meepo.team or meepo.level >= 17) and ((number < reqNum or any) and (not camp.ancients or (meepo.level >= 17 or me:AghanimState()))))) and 
                        (not closest or distance(meepo,camp.position) < distance(meepo,closest.position) or cnumber > 2 or closest.farmed or closest.visible) and not camp.farmed and not camp.visible then
                                
                                closest = camp
                        end
                end
                return closest
        end
end

----Returns closest wait position

function getClosestPos(meepo,distance)
        if meepo and meepo.alive then
                local closest = nil
                local tempJungleCamps = JungleCamps
                for i = 1, #tempJungleCamps do
                        local camp = tempJungleCamps[i]
                        if camp.team == meepo.team and (not closest or distance(meepo,camp.waitPosition) < distance(meepo,closest.waitPosition)) then
                                closest = camp
                        end
                end
                return closest
        end
end

----Returns farrest meepo

function getFarrestMeepo(meepo, meepos,distance)
        if meepo and meepo.alive then
                local farrest = nil
                for i = 1, #meepos do
                        local farMeepo = meepos[i]
                        if farMeepo.handle ~= meepo.handle and (not farrest or (distance(farMeepo,meepo) > distance(farrest,meepo))) then
                                farrest = farMeepo
                        end
                end
                return farrest
        end
end

----Returns number of near victims

function getNearVictims(meepo,distance)
        if meepo and meepo.alive then
                local number = 0
                local table = {}
                for i = 1, #enemies do
                        local v = enemies[i]
                        if v.alive and v.visible and distance(v,meepo) <= 1000 then
                                number = number + 1 
                                table[number] = v
                        end
                end
                return number,table
        end
end

----AnyMeepoTping

function tping(position,distance,meepoh)
        local tempmeepoTable = meepoTable
        for meepoHandle,meepo in pairs(tempmeepoTable) do
                if tempmeepoTable[meepoHandle].tping and distance(tempmeepoTable[meepoHandle].tping, position) < 1000 and meepoHandle ~= meepoh then
                        if tempmeepoTable[meepoHandle].tpTime then
                                return true,(3 - (client.gameTime - tempmeepoTable[meepoHandle].tpTime))
                        end
                        return true
                end
        end
        return false
end

----Use TP

function useTP(meepo, meepoHandle, position, nopoof, notp, meepos, distance, mathcos, mathsin)
        if SleepCheck(meepoHandle.."-casting") and position then
                local travels = meepo:FindItem("item_travel_boots") or meepo:FindItem("item_travel_boots_2")
                local tp = meepo:FindItem("item_tpscroll")
                local item = nil
                local tempmeepoTable = meepoTable
                local poof = tempmeepoTable[meepoHandle].poof
                local near,dist,nearMeepo = anyMeepoisNear(position, 5000, meepo, meepos, distance, mathcos, mathsin)
                local victim = tempmeepoTable[meepoHandle].victim
                if victim and (victim.hero or victim.classId == CDOTA_Unit_SpiritBear) then
                        near,dist,nearMeepo = anyMeepoisNear(position, 1000, meepo, meepos, distance, mathcos, mathsin)
                end
                local meepotp,time = tping(position,distance,meepo.handle)
                if not nopoof and poof and not poof.abilityPhase and poof.level > 0 and canCast(meepo, poof) and ((near and distance(nearMeepo,meepo) > 1000 and nearMeepo ~= meepo) or (meepotp and time and time < (poof:FindCastPoint()-meepo:GetTurnTime(position)))) then
                        meepo:CastAbility(poof,position)
                        meepo:Move(position, true)
                        meepoTable[meepoHandle].lastState = tempmeepoTable[meepoHandle].state
                        meepoTable[meepoHandle].state = STATE_POOF_OUT
                        Sleep(poof:FindCastPoint()*1000,meepoHandle.."-casting")
                        return true
                end
                if travels then item = travels else item = tp end
                if (not poof or (not poof.abilityPhase and poof.cd > 0)) and item and canCast(meepo, item) and not notp and distance(meepo,position) > 4000 and (not meepotp or (not poof or not canCast(meepo,poof))) and SleepCheck("travels") then
                        meepo:CastAbility(item,position)
                        meepo:Move(position, true)      
                        meepoTable[meepoHandle].tping = position
                        meepoTable[meepoHandle].tpTime = gameTime+(client.latency/1000)+meepo:GetTurnTime(position)
                        Sleep(3000,meepoHandle.."-casting")
                        Sleep(100,"travels")
                        return true
                end
        end
end

function GetAttackRange(hero)
        local bonus = 0
        if hero.classId == CDOTA_Unit_Hero_TemplarAssassin then         
                local psy = hero:GetAbility(3)
                psyrange = {60,120,180,240}                     
                if psy and psy.level > 0 then                   
                        bonus = psyrange[psy.level]                             
                end                     
        elseif hero.classId == CDOTA_Unit_Hero_Sniper then              
                local aim = hero:GetAbility(3)
                aimrange = {100,200,300,400}                    
                if aim and aim.level > 0 then           
                        bonus = aimrange[aim.level]                             
                end                     
        end             
        return hero.attackRange + bonus
end

----returns damage going on meepo

function IncomingDamage(unit,onlymagic,lane)
        if unit and unit.alive then
                local result = 0
                local plusdamage = 0
                local type = DAMAGE_MAGC
                local results = {}
                local resultsMagic = {}
                local enemy = enemies
                local source = nil
                if #enemies > 0 and unit.team == enemy[1].team then
                        enemy = allies
                end             
                for i,v in pairs(enemy) do      
                        if v.alive and v.visible then
                                if not onlymagic and not results[v.handle] and (Animations.isAttacking(v) or distance(unit,v) < 200) and distance(unit,v) <= GetAttackRange(v) + 50 and (mathmax(math.abs(FindAngleR(v) - math.rad(FindAngleBetween(v, unit))) - 0.20, 0)) == 0 then
                                        local dmg = (v.dmgMax+v.dmgBonus)*(4/(Animations.getBackswingTime(v)+Animations.GetAttackTime(v)) + latency/1000)
                                        if v.type == LuaEntity.TYPE_MEEPO then
                                                dmg = dmg*getAliveNumber()
                                        end
                                        plusdamage = plusdamage + dmg
                                        results[v.handle] = true
                                end
                                result = result + math.floor(unit:DamageTaken(plusdamage,DAMAGE_PHYS,v))
                                plusdamage = 0
                                for i,k in pairs(unit.modifiers) do
                                        local spell = v:FindSpell(k.name:gsub("modifier_",""))
                                        if spell then
                                                local dmg
                                                if not spellDamageTable[spell.handle] or spellDamageTable[spell.handle][2] ~= spell.level or spellDamageTable[spell.handle][3] ~= v.dmgMin+v.dmgBonus or spellDamageTable[spell.handle][4] ~= v.attackSpeed then
                                                        spellDamageTable[spell.handle] = { AbilityDamage.GetDamage(spell), spell.level, v.dmgMin+v.dmgBonus, v.attackSpeed }
                                                end
                                                dmg = spellDamageTable[spell.handle][1]
                                                if v.type == LuaEntity.TYPE_MEEPO then
                                                        dmg = dmg*getAliveNumber()
                                                end
                                                if dmg and dmg > 0 and not resultsMagic[spell.handle] and not resultsMagic[k.handle] then
                                                        plusdamage = plusdamage + dmg
                                                        type = AbilityDamage.GetDmgType(spell)
                                                        resultsMagic[k.handle] = true
                                                        resultsMagic[spell.handle] = true
                                                end
                                        end
                                end
                                result = result + math.floor(unit:DamageTaken(plusdamage,type,v))
                                plusdamage = 0
                                for i,k in pairs(v.abilities) do
                                        if k.level > 0 and (k.abilityPhase or (k:CanBeCasted() and k:FindCastPoint() < 0.4)) and not resultsMagic[k.handle] and distance(v,unit) <= k.castRange+100 and (((mathmax(math.abs(FindAngleR(v) - math.rad(FindAngleBetween(v, unit))) - 0.20, 0)) == 0 
                                        and (k:IsBehaviourType(LuaEntityAbility.BEHAVIOR_UNIT_TARGET) or k:IsBehaviourType(LuaEntityAbility.BEHAVIOR_POINT))) or k:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NO_TARGET)) then
                                                local dmg
                                                if not spellDamageTable[k.handle] or spellDamageTable[k.handle][2] ~= k.level or spellDamageTable[k.handle][3] ~= v.dmgMin+v.dmgBonus or spellDamageTable[k.handle][4] ~= v.attackSpeed then
                                                        spellDamageTable[k.handle] = { AbilityDamage.GetDamage(k), k.level, v.dmgMin+v.dmgBonus, v.attackSpeed }
                                                end
                                                dmg = spellDamageTable[k.handle][1]
                                                if dmg then
                                                        plusdamage = plusdamage + dmg
                                                        type = AbilityDamage.GetDmgType(k)
                                                        resultsMagic[k.handle] = true
                                                end
                                        end
                                end
                                result = result + math.floor(unit:DamageTaken(plusdamage,type,v))
                                plusdamage = 0
                                for i,k in pairs(v.items) do
                                        local dmg
                                        if not spellDamageTable[k.handle] or spellDamageTable[k.handle][2] ~= v.level or spellDamageTable[k.handle][3] ~= v.dmgMin+v.dmgBonus or spellDamageTable[k.handle][4] ~= v.attackSpeed then
                                                spellDamageTable[k.handle] = { AbilityDamage.GetDamage(k), v.level, v.dmgMin+v.dmgBonus, v.attackSpeed }
                                        end
                                        dmg = spellDamageTable[k.handle][1]
                                        if dmg and dmg > 0 and k.castRange and not resultsMagic[k.handle] and distance(v,unit) <= k.castRange+200 then
                                                plusdamage = plusdamage + dmg
                                                resultsMagic[k.handle] = true
                                        end
                                end
                                result = result + math.floor(unit:DamageTaken(plusdamage,DAMAGE_MAGC,v))
                                plusdamage = 0
                        end
                end     
                for i,k in pairs(entityList:GetProjectiles({target=unit})) do
                        if k.source then
                                -- local spell = k.source:FindSpell(k.name)
                                -- if spell and not resultsMagic[k.source.handle] and not resultsMagic[k.name] then
                                        -- local dmg
                                        -- if not spellDamageTable[spell.handle] or spellDamageTable[spell.handle][2] ~= spell.level or spellDamageTable[spell.handle][3] ~= k.source.dmgMin+k.source.dmgBonus or spellDamageTable[spell.handle][4] ~= k.source.attackSpeed then
                                                -- spellDamageTable[spell.handle] = { AbilityDamage.GetDamage(spell), spell.level, k.source.dmgMin+k.source.dmgBonus, k.source.attackSpeed }
                                        -- end
                                        -- dmg = spellDamageTable[spell.handle][1]
                                        -- if k.source.type == LuaEntity.TYPE_MEEPO then
                                                -- dmg = dmg*getAliveNumber()
                                        -- end
                                        -- if dmg then
                                                -- result = result + math.floor(unit:DamageTaken(dmg,AbilityDamage.GetDmgType(spell),k.source))
                                                -- resultsMagic[k.source.handle] = true
                                                -- resultsMagic[k.name] = true
                                        -- end
                                if not onlymagic and k.source and not results[k.source.handle] and k.source.dmgMax then
                                        local dmg = (k.source.dmgMax+k.source.dmgBonus)*(4/(Animations.getBackswingTime(k.source)+Animations.GetAttackTime(k.source)) + latency/1000)
                                        if k.source.type == LuaEntity.TYPE_MEEPO then
                                                dmg = dmg*getAliveNumber()
                                        end
                                        plusdamage = plusdamage + dmg
                                        source = k.source
                                        results[k.source.handle] = true
                                end
                        end
                end     
                if source then
                        result = result + math.floor(unit:DamageTaken(plusdamage,DAMAGE_PHYS,source))
                end
                if result then
                        return result
                else
                        return 0
                end
        end
end

----Switching treads for mana

function SwitchTreads(back)
        local me = me
        local treads = me:FindItem("item_power_treads")
        if treads and SleepCheck("treads") and me.alive and not me:IsInvisible() then
                local state = treads.bootsState
                if back then
                        if state == 1 then
                                me:CastAbility(treads)
                                Sleep(200+client.latency,"treads")
                        elseif state == 0 then
                                me:CastAbility(treads)
                                me:CastAbility(treads)
                                Sleep(200+client.latency,"treads")
                        end
                else
                        if state == 2 then
                                me:CastAbility(treads)
                                me:CastAbility(treads)
                                Sleep(2000+client.latency,"treads")
                        elseif state == 0 then
                                me:CastAbility(treads)
                                Sleep(2000+client.latency,"treads")
                        end
                end
        end
end

----OrbWalks on victim, uses spells and abilities

function OrbWalk(meepo, meepoHandle, victim, usePoof, meepos, distance, mathcos, mathsin,mathabs,mathrad,mathceil,mathmax)
        local player = player
        local me = me
        local tempmeepoTable = meepoTable
        local poof = tempmeepoTable[meepoHandle].poof
        if meepo:IsChanneling() then return end
        --local infront = Vector(victim.position.x+150*mathcos(victim.rotR), victim.position.y+150*mathsin(victim.rotR), victim.position.z)
        local behind = Vector(meepo.position.x+(-200)*mathcos(meepo.rotR), meepo.position.y+(-200)*mathsin(meepo.rotR), meepo.position.z)
        --local block = SkillShot.__CheckBlock(entitiesForPush,meepo.position,infront,100,victim)
        local position = nil
        if not Animations.CanMove(meepo) and victim and victim.alive then
                                        
                --Cast Poof global
                if poof and SleepCheck(meepoHandle.."-casting") and victim and victim.visible and meepo.health > meepo.maxHealth/2.5 then
                        local radius = poof:GetSpecialData("radius", poof.level)
                        local near,dist,nearMeepo = anyMeepoisNear(victim, radius, meepo, meepos, distance, mathcos, mathsin)
                        if near and not poof.abilityPhase and poof.level > 0 and nearMeepo ~= meepo and distance(meepo,nearMeepo) > 700 and (willHit(meepo, victim, radius, true, meepos, distance, mathcos, mathsin) or distance(meepo,victim) > radius*1.5) and distance(nearMeepo,victim) > distance(meepo,victim) then
                                if canCast(meepo, poof) then
                                        SwitchTreads()
                                        meepo:CastAbility(poof,nearMeepo.position)
                                        meepoTable[meepoHandle].lastState = tempmeepoTable[meepoHandle].state
                                        meepoTable[meepoHandle].state = STATE_POOF_OUT
                                        Sleep(poof:FindCastPoint()*1000,meepoHandle.."-casting")
                                elseif poof.cd == 0 then
                                        SwitchTreads()
                                end
                        end
                end     
                
                --Cast Poof
                if poof and SleepCheck(meepoHandle.."-casting") and not poof.abilityPhase and victim and victim.visible and not victim:IsMagicImmune() and victim.alive and usePoof and not victim.ancient and 
                victim.classId ~= CDOTA_BaseNPC_Tower and victim.classId ~= CDOTA_BaseNPC_Creep_Siege then
                        local hitDmg = mathceil(victim:DamageTaken((meepo.dmgMin + meepo.dmgMax)/2,DAMAGE_PHYS,meepo))
                        local poofDmg = mathceil(victim:DamageTaken(poofDamage[1],DAMAGE_MAGC,meepo))
                        local radius = poof:GetSpecialData("radius", poof.level)
                        local near,dist,nearMeepo = anyMeepoisNear(victim, radius, meepo, meepos, distance, mathcos, mathsin)
                        local near2,dist2,nearMeepo2 = anyMeepoisNear(victim, 1300, meepo, meepos, distance, mathcos, mathsin)
                        --print(poofDmg,hitDmg,((not chainEarthbind(meepo, victim, poof:FindCastPoint()+client.latency/1000, meepos) and victim:IsInvisible()) or not victim:IsInvisible() or victim.creep or 
                        --victim.classId == CDOTA_BaseNPC_Creep_Neutral or victim.classId == CDOTA_BaseNPC_Creep_Lane or (not meepo:GetAbility(1) or not canCast(meepo, meepo:GetAbility(1)))), poof.level, willHit(meepo, victim, radius/2+50, false, meepos, distance, mathcos, mathsin),(not tempmeepoTable[meepoHandle].camp or (distance(meepo, tempmeepoTable[meepoHandle].camp.position) < radius+25) or tempmeepoTable[meepoHandle].state == STATE_PUSH or tempmeepoTable[meepoHandle].state == STATE_CHASE))
                        if poofDmg/1.5 > hitDmg and ((not chainEarthbind(meepo, victim, poof:FindCastPoint()+client.latency/1000, meepos) and victim:IsInvisible()) or not victim:IsInvisible() or victim.creep or 
                        victim.classId == CDOTA_BaseNPC_Creep_Neutral or victim.classId == CDOTA_BaseNPC_Creep_Lane) and poof.level > 0 
                        and willHit(meepo, victim, radius/2, false, meepos, distance, mathcos, mathsin) and (not tempmeepoTable[meepoHandle].camp or (distance(meepo, tempmeepoTable[meepoHandle].camp.position) < radius+25) or tempmeepoTable[meepoHandle].state == STATE_PUSH or tempmeepoTable[meepoHandle].state == STATE_CHASE) then
                                if canCast(meepo, poof) then                                    
                                        SwitchTreads()
                                        if ((near and (dist and distance(meepo,victim) > dist)) or near2) and nearMeepo and distance(meepo,victim) > distance(nearMeepo,victim) then
                                                meepo:CastAbility(poof,nearMeepo.position)
                                                Sleep(poof:FindCastPoint()*1000,meepoHandle.."-casting")
                                        elseif willHit(meepo, victim, radius/2, false, meepos, distance, mathcos, mathsin) then
                                                meepo:CastAbility(poof,meepo.position)
                                                Sleep(poof:FindCastPoint()*1000,meepoHandle.."-casting")
                                        end
                                elseif poof.cd == 0 then
                                        SwitchTreads()
                                end
                        end
                end
                
                --useTP(meepo, meepoHandle, victim.position, true)
                        
                --Attack
                if SleepCheck(meepoHandle.."-attack") and SleepCheck(meepoHandle.."-casting") then              
                        meepo:Attack(victim)    
                        Sleep(Animations.GetAttackTime(meepo)*1000 + Animations.getBackswingTime(meepo)*1000 - meepo:GetTurnTime(behind)*1000,meepoHandle.."-attack")
                end
        else
                        
                --Block victim if there is any, or try to get in better position
                if SleepCheck(meepoHandle.."-casting") and SleepCheck(meepoHandle.."-move") then
                        if victim and victim.alive then
                                local bPos1,bPos2,bPos3,bPos4,bPos = getBlockPositions(victim,victim.rotR,meepo, mathcos, mathsin)
                                local dist1,dist2,bDist,canblock = distance(meepo,bPos1),distance(meepo,bPos2),distance(meepo,bPos),SkillShot.__CheckBlock(entitiesForPush,meepo.position,bPos,100,victim)
                                and (distance(meepo,bPos) > distance(victim,bPos))
                                if meepo.attackSpeed < 200 and ((victim.hero or victim.classId == CDOTA_Unit_SpiritBear) or (not victim:IsRanged() and victim.classId ~= CDOTA_BaseNPC_Tower and victim.classId ~= CDOTA_BaseNPC_Creep_Lane and 
                                victim.classId ~= CDOTA_BaseNPC_Barracks and victim.classId ~= CDOTA_BaseNPC_Building and victim.classId ~= CDOTA_BaseNPC_Creep_Siege)) 
                                and victim.visible and (victim.activity == LuaEntityNPC.ACTIVITY_MOVE or 
                                not isFacingAnyMeepo(victim, meepos,mathabs,mathrad,mathmax)) then
                                        if not canblock then
                                                if dist1 < dist2 and not SkillShot.__CheckBlock(entitiesForPush,meepo.position,bPos1,100,victim) then
                                                        if tempmeepoTable[meepoHandle].state ~= STATE_FARM_JUNGLE or (tempmeepoTable[meepoHandle].camp and distance(meepo, tempmeepoTable[meepoHandle].camp.position) < distance(bPos1, tempmeepoTable[meepoHandle].camp.position)) then
                                                                meepo:Move(bPos1)
                                                                position = bPos1
                                                        else
                                                                meepo:Follow(victim)
                                                        end
                                                elseif not SkillShot.__CheckBlock(entitiesForPush,meepo.position,bPos2,100,victim) then
                                                        if tempmeepoTable[meepoHandle].state ~= STATE_FARM_JUNGLE or (tempmeepoTable[meepoHandle].camp and distance(meepo, tempmeepoTable[meepoHandle].camp.position) < distance(bPos2, tempmeepoTable[meepoHandle].camp.position)) then
                                                                meepo:Move(bPos2)
                                                                position = bPos2
                                                        else
                                                                meepo:Follow(victim)
                                                        end
                                                elseif dist1 < dist2 then
                                                        if tempmeepoTable[meepoHandle].state ~= STATE_FARM_JUNGLE or (tempmeepoTable[meepoHandle].camp and distance(meepo, tempmeepoTable[meepoHandle].camp.position) < distance(bPos3, tempmeepoTable[meepoHandle].camp.position)) then
                                                                meepo:Move(bPos3)
                                                                position = bPos3
                                                        else
                                                                meepo:Follow(victim)
                                                        end
                                                else
                                                        if tempmeepoTable[meepoHandle].state ~= STATE_FARM_JUNGLE or (tempmeepoTable[meepoHandle].camp and distance(meepo, tempmeepoTable[meepoHandle].camp.position) < distance(bPos4, tempmeepoTable[meepoHandle].camp.position)) then
                                                                meepo:Move(bPos4)
                                                                position = bPos4
                                                        else
                                                                meepo:Follow(victim)
                                                        end
                                                end                                                                             
                                        elseif tempmeepoTable[meepoHandle].state ~= STATE_FARM_JUNGLE or (tempmeepoTable[meepoHandle].camp and distance(meepo, tempmeepoTable[meepoHandle].camp.position) < distance(bPos, tempmeepoTable[meepoHandle].camp.position)) then
                                                meepo:Move(bPos)
                                                position = bPos
                                        else
                                                meepo:Follow(victim)
                                        end
                                else
                                        meepo:Follow(victim)
                                end
                        elseif player.selection[1] and meepoHandle ~= player.selection[1].handle then
                                meepoTable[meepoHandle].state = STATE_FARM_JUNGLE
                        else
                                meepoTable[meepoHandle].state = 10
                                meepo:Move(client.mousePosition)
                        end     
                        Sleep(Animations.getBackswingTime(meepo)*1000,meepoHandle.."-move")
                        if meepoHandle == me.handle then
                                start = false
                        end
                end
        end
end
        
----Shop Opened ((C) Nyan)

function shop()
        local mx = client.mouseScreenPosition.x
        local my = client.mouseScreenPosition.y 
        local ShopPanel = {1920-565,76,1920,80+774}
        if client.shopOpen and mx >= ShopPanel[1] and mx <= ShopPanel[3] and my >= ShopPanel[2] and my <= ShopPanel[4] then 
                return false 
        end
        return true
end
                
                
----Download Version File

-- function download()
        -- --require 'luarocks.require'
        -- local http = require 'socket.http'
        -- local content = http.get("https://raw.githubusercontent.com/Moones/Ensage-scripts/master/Scripts/iMeepo_Version.lua").readAll()
        -- if not content then
                -- error("Could not connect to website")
        -- end
        -- local f = fs.open(SCRIPT_PATH.."/iMeepo_Version.lua", "w")
        -- f.write(content)
        -- f.close()
-- end

----Check Version
                
function Version()
        local file = io.open(SCRIPT_PATH.."/iMeepo_Version.lua", "r")
        local ver = nil
        if file then
                ver = file:read("*number")
                file:read("*line")
                beta = file:read("*line")
                info = file:read("*line")
                file:close()
        end
        if ver then
                local bcheck = ""..beta
                if ver == currentVersion and bcheck == Beta then
                        outdated = false
                        return true,ver,beta,info
                elseif ver > currentVersion or bcheck ~= Beta then
                        outdated = true
                        return false,ver,beta,info
                end
        else
                versionSign.text = "You didn't download version info file from Moones' repository. Please do so to keep the script updated."
                versionSign.color = -1
                return false
        end
end     

----DODGING

----LICH ULT SPLITTING

function IsOptimalPlaceAgainstChainFrost(pos,validTargets,distance)
        for i = 1, #validTargets do
                local v = validTargets[i]
                if distance(v, pos) < lichJumpRange - 5 then
                        return false
                end
        end
        return true
end

function FindOptimalPlaceAgainstChainFrost(meepo,distance,mathsqrt)
        local validTargets = entityList:FindEntities(function (ent) return (ent.creep or ent.hero) and ent.team ~= 5 - meepo.team and (not ent.creep or ent.spawned) and not ent:IsInvul() and ent.handle ~= meepo.handle and distance(meepo,ent) < lichJumpRange*3/2 end)
        ----print(#validTargets)
        local move = not IsOptimalPlaceAgainstChainFrost(meepo,validTargets,distance)
        if move then
                local nearbyCount = 0
                for i = 1, #validTargets do
                        local v = validTargets[i]
                        if distance(v,meepo) < lichJumpRange then
                                nearbyCount = nearbyCount + 1
                        end
                end
                if nearbyCount > 1 then
                        local intersections = {}
                        local intersectionsCount = 0
                        for i = 1, #validTargets do
                                local v = validTargets[i]
                                for k = 1, #validTargets do
                                        local l = validTargets[k]
                                        if l ~= v then
                                                local dist = distance(l,v)
                                                if dist < lichJumpRange then
                                                        local midpoint = (l.position + v.position) / 2
                                                        local directionVector = (v.position - l.position) / dist
                                                        local rDist = mathsqrt(lichJumpRange*lichJumpRange - (dist*dist)/4)
                                                        local rDirection = Rotate90(directionVector)
                                                        local ti = {midpoint - rDirection*rDist, midpoint + rDirection*rDist}
                                                        for a = 1, #ti do
                                                                local b = ti[a]
                                                                if IsOptimalPlaceAgainstChainFrost(b,validTargets,distance) then
                                                                        intersectionsCount = intersectionsCount + 1
                                                                        intersections[intersectionsCount] = b
                                                                end
                                                        end
                                                end
                                        end
                                end
                        end
                        table.sort(intersections, function (a,b) return distance(a,meepo) < distance(b,meepo) end)
                        for i = 1, #intersections do
                                local v = intersections[i]
                                if IsOptimalPlaceAgainstChainFrost(v,validTargets,distance) then
                                        meepo:Move(v)
                                        Sleep((distance(v,meepo)/meepo.movespeed)*1000+client.latency,meepo.handle.."-move")
                                        Sleep((distance(v,meepo)/meepo.movespeed)*1000+client.latency,meepo.handle.."-casting")
                                        return
                                end
                        end
                end
        end
end

function Rotate90(vec)
        return Vector(vec.y,-1 * (vec.x),vec.z)
end

----ABILITIES DODGING

function FindEntity(cast,me,dayvision,m1)
        for i = 1, #cast do
                local z = cast[i]
                if z.team ~= me.team then
                        if (not dayvision or z.dayVision == dayvision) and (not m1 or z:DoesHaveModifier(m1)) then
                                return z
                        end
                end
        end
        return nil
end

function LineDodge(meepo, pos1, pos2, radius, sleep,mathfloor, mathsqrt, mathabs)
        radius = radius + 250
        local calc1 = (mathfloor(mathsqrt((pos2.x-meepo.position.x)^2 + (pos2.y-meepo.position.y)^2)))
        local calc2 = (mathfloor(mathsqrt((pos1.x-meepo.position.x)^2 + (pos1.y-meepo.position.y)^2)))
        local calc4 = (mathfloor(mathsqrt((pos1.x-pos2.x)^2 + (pos1.y-pos2.y)^2)))
        local calc3, perpendicular, k, x4, z4, dodgex, dodgey
        perpendicular = (mathfloor((mathabs((pos2.x-pos1.x)*(pos1.y-meepo.position.y)-(pos1.x-meepo.position.x)*(pos2.y-pos1.y)))/(mathsqrt((pos2.x-pos1.x)^2 + (pos2.y-pos1.y)^2))))
        k = ((pos2.y-pos1.y)*(meepo.position.x-pos1.x) - (pos2.x-pos1.x)*(meepo.position.y-pos1.y)) / ((pos2.y-pos1.y)^2 + (pos2.x-pos1.x)^2)
        x4 = meepo.position.x - k * (pos2.y-pos1.y)
        z4 = meepo.position.y + k * (pos2.x-pos1.x)
        calc3 = (mathfloor(mathsqrt((x4-meepo.position.x)^2 + (z4-meepo.position.y)^2)))
        dodgex = x4 + (radius/calc3)*(meepo.position.x-x4)
        dodgey = z4 + (radius/calc3)*(meepo.position.y-z4)
        if perpendicular < radius and calc1 < calc4 and calc2 < calc4 then
                local dodgevector = Vector(dodgex,dodgey,meepo.position.z)
                meepo:Move(dodgevector)
                Sleep(sleep,meepo.handle.."-move")
                Sleep(sleep,meepo.handle.."-casting")
                Sleep(sleep,meepo.handle.."-attack")
                Sleep(250,meepo.handle.."dodge")
                return
        end
end

function AOEDodge(meepo, pos1, radius,mathfloor, mathsqrt)
        local calc = (mathfloor(mathsqrt((pos1.x-meepo.position.x)^2 + (pos1.y-meepo.position.y)^2)))
        local dodgex, dodgey
        dodgex = pos1.x + (radius/calc)*(meepo.position.x-pos1.x)
        dodgey = pos1.y + (radius/calc)*(meepo.position.y-pos1.y)
        if calc < radius then
                local dodgevector = Vector(dodgex,dodgey,meepo.position.z)
                meepo:Move(dodgevector)
                return
        end
end

function FindAB(first, second, distance,mathdeg, mathatan, mathabs, mathrad, mathcos, mathsin)
        local xAngle = mathdeg(mathatan(mathabs(second.x - first.x)/mathabs(second.y - first.y)))
        local retValue = nil
        local retVector = Vector()
        if first.x <= second.x and first.y >= second.y then
                        retValue = 270 + xAngle
        elseif first.x >= second.x and first.y >= second.y then
                        retValue = (90-xAngle) + 180
        elseif first.x >= second.x and first.y <= second.y then
                        retValue = 90+xAngle
        elseif first.x <= second.x and first.y <= second.y then
                        retValue = 90 - xAngle
        end
        retVector = Vector(first.x + mathcos(mathrad(retValue))*distance,first.y + mathsin(mathrad(retValue))*distance,0)
        client:GetGroundPosition(retVector)
        retVector.z = retVector.z+100
        return retVector
end
        
--END of FUNCTIONS--
