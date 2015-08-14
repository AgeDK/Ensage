--<<Auto Chase + Spell/Item Combo, made by Moones>>

--[[ Moones's Combo Script ]]--

local currentVersion = 0.41
local Beta = ""

require("libs.ScriptConfig")
require("libs.Utils")
require("libs.HeroInfo")
require("libs.Animations2")
require("libs.TargetFind")
require("libs.SkillShotBETA")
require("libs.AbilityDamage")
require("libs.DrawManager3D")
require("libs.EasyHUD")

local config = ScriptConfig.new()
config:SetParameter("Chase", "G", config.TYPE_HOTKEY)
config:SetParameter("Retreat", "Z", config.TYPE_HOTKEY)
config:SetParameter("Harras", "B", config.TYPE_HOTKEY)
config:SetParameter("BlinkToggle", "H", config.TYPE_HOTKEY)
config:SetParameter("StackKey", "J", config.TYPE_HOTKEY)
config:SetParameter("KillSteal", false, config.TYPE_BOOL)
config:SetParameter("TargetFindRange", 5000, config.TYPE_NUMBER)
config:SetParameter("TargetClosestToMouse", false, config.TYPE_BOOL)
config:SetParameter("TargetLowestHP", true, config.TYPE_BOOL)
config:SetParameter("MoveToEnemyWhenLocked", false, config.TYPE_BOOL)
config:SetParameter("AutoMoveToEnemy", false, config.TYPE_BOOL)
config:SetParameter("VersionInfoPosX", 630, config.TYPE_NUMBER)
config:SetParameter("VersionInfoPosY", 700, config.TYPE_NUMBER)
config:SetParameter("AutoLock", true, config.TYPE_BOOL)
config:SetParameter("ManualLock", true, config.TYPE_BOOL)
config:SetParameter("UseBlink", true, config.TYPE_BOOL)
config:SetParameter("UseEul", true, config.TYPE_BOOL)
config:SetParameter("EMBERUseUlti", true, config.TYPE_BOOL)
config:SetParameter("Combo1", 49, config.TYPE_HOTKEY) -- 49 is Key Code for 1
config:SetParameter("Combo2", 50, config.TYPE_HOTKEY) -- 50 is Key Code for 2 for all KeyCodes go to http://www.zynox.net/forum/threads/336-KeyCodes
config:SetParameter("Combo3", 51, config.TYPE_HOTKEY) -- 3
config:SetParameter("EnableComboKeys", false, config.TYPE_BOOL)
config:Load()
	
local chasekey = config.Chase local blinktoggle = config.BlinkToggle local killsteal = config.KillSteal
local reg = false local myhero = nil local victim = nil local myId = nil local attack = 0 local move = 0 local start = false local resettime = nil local type = nil local channelactive = false local mePosition local atr = nil
local useblink = config.UseBlink local xposition = nil local monitor = client.screenSize.x/1600 local F14 = drawMgr:CreateFont("F14","Tahoma",13*monitor,800*monitor) local statusText = drawMgr:CreateText(10*monitor,580*monitor,99333580,"",F14) statusText.visible = false
local targetlock = false local testX, tinfoHeroSize, tinfoHeroDown, txxB, txxG, rate, con, x_, y_ local click = {} local follow = 0 local indicate = {} local JungleCamps = {} local camp = nil local enemyHP = nil local trolltoggle = false local esstone = false
local campSigns = {} local damageTable = {} local comboTable = {} local retreat = false local statusText2 = drawMgr:CreateText(0,0,-54619000,"",F14) statusText2.visible = false local harras = false local lastPrediction = nil local F12 = drawMgr:CreateFont("F12","Tahoma",12*monitor,800*monitor)
local versionSign = drawMgr:CreateText(client.screenSize.x*config.VersionInfoPosX/1000,client.screenSize.y*config.VersionInfoPosY/1000,0x66FF33FF,"",F14) local infoSign = drawMgr:CreateText(client.screenSize.x*config.VersionInfoPosX/1000,(client.screenSize.y*config.VersionInfoPosY/1000)+20,-1,"",F12)
local lastCastPrediction = nil local mySpells = nil local HUD = nil local sunstrikeButtonID, sunstrikeButton, coldsnapButtonID, coldsnapButton, chaosmeteorButtonID, chaosmeteorButton, tornadoButtonID, tornadoButton, empButton, empButtonID, forgespiritButtonID, forgespiritButton, icewallButton, icewallButtonID, alacrityButton, alacrityButtonID, ghostwalkButton, ghostwalkButtonID, blastButton, blastButtonID
local KSSS = true local DSS = true local EStoMouse = false local textFont = drawMgr:CreateFont("textFont","Arial",14,400) local tuskSnowBall = false local buttons = {} local combo = 0 local comboready = false local directiontable = {} local PuckPosition = nil local LastCastedTable = {}
local positionsTable = {} local stackTable = {}

local itemcomboTable = {
	{ "item_soul_ring", false, nil, false, false, true },
	{ "item_veil_of_discord", false, nil, false, false, true },
	{ "item_cyclone", true, nil, false, false, true },
	{ "item_rod_of_atos", true, nil, false, false, true },
	{ "item_sheepstick", true, nil, false, false, true }, 
	{ "item_orchid", true, nil, false, false, true }, 
	{ "item_diffusal_blade", true, nil, false, false, true }, 
	{ "item_diffusal_blade_2", true, nil, false, false, true }, 
	{ "item_shivas_guard", true, 1000, nil, false, false, true }, 
	{ "item_abyssal_blade", true, nil, false, true, true },
	{ "item_solar_crest" },
	{ "item_medallion_of_courage" },
	{ "item_ethereal_blade", false, nil, false, false, true },
	{ "item_dagon", false, nil, killsteal},
	{ "item_dagon_2", false, nil, killsteal },
	{ "item_dagon_3", false, nil, killsteal },
	{ "item_dagon_4", false, nil, killsteal },
	{ "item_dagon_5", false, nil, killsteal },
	{ "item_urn_of_shadows" },
	--{ "item_armlet", false, 500, false, true },
	{ "item_blade_mail", true, 500, false, true, true },
	{ "item_heavens_halberd", true, 500, false, false, true },
	{ "item_mjollnir", false, 500, false, true, true },
	{ "item_arcane_boots", false, nil, false, true, true },
	{ "item_phase_boots", true, nil, false, true, true },
	{ "item_refresher", false, nil, false, true },
	{ "item_dust", false, 1050, false, true, true }
	--{ "item_force_staff" }
}

local invokerCombo = {
	{ {"invoker_cold_snap"}, {"invoker_ice_wall", 590, true, 1} },
	{ {"invoker_tornado", "travel_distance", true, nil, false, "travel_speed"}, {"invoker_emp", nil, false, 2.9} },
	{ {"invoker_forge_spirit", 700}, {"invoker_sun_strike", nil, false, 1.7}, {"invoker_chaos_meteor", nil, false, 1.3}, {"invoker_alacrity", nil, nil, nil, nil, nil, nil, nil, nil, nil, true} },
	{ {"invoker_deafening_blast", "travel_distance", true, nil, false, "travel_speed"}, {"invoker_ghost_walk", nil, false} },
	{ {"invoker_tornado", "travel_distance", true, nil, false, "travel_speed"}, {"invoker_emp", nil, false, 2.9}, {"invoker_chaos_meteor", nil, false, 1.3}, {"invoker_deafening_blast", "travel_distance", true, nil, false, "travel_speed"}, {"invoker_cold_snap"}  },
	{ {"invoker_tornado", "travel_distance", true, nil, false, "travel_speed"}, {"invoker_sun_strike", nil, false, 1.7}, {"invoker_chaos_meteor", nil, false, 1.3}, {"invoker_deafening_blast", "travel_distance", true, nil, false, "travel_speed"}, {"invoker_cold_snap"}  },
	{ {"invoker_cold_snap"}, {"invoker_chaos_meteor", nil, false, 1.3}, {"invoker_deafening_blast", "travel_distance", true, nil, false, "travel_speed"}, {"invoker_sun_strike", nil, false, 1.7}  }
}

local RubickSpellSteals = {}
local RubickNoSpellSteals = {}
local RubickKeepSpellSteals = {}
RubickSpellSteals["batrider_firefly"] = 6
RubickSpellSteals["lone_druid_spirit_bear"] = 10
RubickSpellSteals["leshrac_split_earth"] = 6
RubickSpellSteals["sniper_assassinate"] = 6
RubickSpellSteals["windrunner_powershot"] = 3
RubickSpellSteals["juggernaut_blade_fury"] = 6
RubickSpellSteals["juggernaut_healing_ward"] = 4
RubickSpellSteals["gyrocopter_flak_cannon"] = 4
RubickSpellSteals["mirana_arrow"] = 10
RubickSpellSteals["pudge_meat_hook"] = 10
RubickSpellSteals["spirit_breaker_charge_of_darkness"] = 7
RubickSpellSteals["slark_pounce"] = 6
RubickSpellSteals["broodmother_spin_web"] = 5
RubickSpellSteals["ursa_overpower"] = 7
RubickNoSpellSteals["pudge_rot"] = true
RubickNoSpellSteals["lich_dark_ritual"] = true
RubickNoSpellSteals["bane_enfeeble"] = true
RubickNoSpellSteals["bloodseeker_bloodrage"] = true
RubickNoSpellSteals["drow_ranger_frost_arrows"] = true
RubickNoSpellSteals["earthshaker_enchant_totem"] = true
RubickNoSpellSteals["kunkka_x_marks_the_spot"] = true
RubickNoSpellSteals["viper_poison_attack"] = true
RubickKeepSpellSteals["pudge_meat_hook"] = true

function Key(msg, code)
	if client.chat or client.console or not PlayingGame() or client.paused then return end
	if msg == LBUTTON_DOWN and client.mouseScreenPosition.x > 300 then
		local me = entityList:GetMyHero()
		if not me then return end
		local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO, team=me:GetEnemyTeam()})
		for i = 1, #enemies do 
			local v = enemies[i]
			local id = v.playerId
			local x,y,h,w
			local button = indicate[id]
			if button then
				x,y,h,w = button.x,button.y,button.h,button.w
			else
				local xx = GetXX(v)
				x,y,h,w = xx-20+x_*id,0,x_,35*monitor
				indicate[id] = drawMgr:CreateRect(x,y,h,w,9911861800) 
				indicate[id].visible = false
			end
			if IsMouseOnButton(x,y,h,w) then
				if victim and victim == v then
					victim = nil
					targetlock = false
					indicate[id].visible = false
					return true
				else
					victim = v
					targetlock = true
					enemyHP = victim.health
					indicate[id].visible = true
					for z = 1, 9 do	
						local k = indicate[z]
						if k and k.visible and z ~= id then
							indicate[z].visible = false
						end
					end
					return true
				end
			end
		end
		if config.ManualLock then
			local targetFind = targetFind
			local mOver = targetFind:GetClosestToMouse(me,999999)
			if mOver and GetDistance2D(mOver, client.mousePosition) < 300 then 
				if victim and victim == mOver then
					indicate[victim.playerId].visible = false
					victim = nil
					targetlock = false
					return false
				else
					victim = mOver 
					indicate[victim.playerId].visible = false
					targetlock = true 
					enemyHP = victim.health
					return false
				end
			elseif victim then
				indicate[victim.playerId].visible = false
				victim = nil
				targetlock = false
				return false
			end
		end
	elseif msg == KEY_UP then
		if code == blinktoggle then
			useblink = not useblink
			return true
		elseif code == config.Retreat then
			retreat = not retreat
			return true
		elseif code == config.Harras then
			harras = not harras
			return true
		elseif config.EnableComboKeys and buttons[1] then
			if code == config.Combo1 or code == config.Combo2 or code == config.Combo3 then
				local me = entityList:GetMyHero()
				local invoke, refresher = me:GetAbility(6), me:FindItem("item_refresher")
				if invoke.level < 4 then
					buttons[1].txt.text = "Need Invoke lvl 4!" Sleep(1000,"refbutton")
				elseif not me:AghanimState() then
					buttons[1].txt.text = "Need Aghanims!" Sleep(1000,"refbutton")
				elseif not refresher then
					buttons[1].txt.text = "Need Refresher!" Sleep(1000,"refbutton")
				elseif not refresher:CanBeCasted() and refresher.cd > 10 then
					buttons[1].txt.text = "Refresher is on cd!" Sleep(1000,"refbutton")
				elseif code == config.Combo1 then
					combo = 1
					comboready = false
				elseif code == config.Combo2 then
					combo = 2
					comboready = false
				elseif code == config.Combo3 then
					combo = 3
					comboready = false
				end
			end
		end
	end
end

function buttonClick(b1,b2,t)
	if not t.visible and t.text ~= "Cancel" then return end
	if buttons[1] and t.text == buttons[1].txt.text then
		if buttons[5] and buttons[5].obj then
			buttons[5].obj.visible = false buttons[5].out.visible = false buttons[5].txt.visible = false 
			--HUD:RemoveElement(buttons[5].id+1)
			--buttons[5] = nil
		end
		local me = entityList:GetMyHero()
		local invoke, refresher = me:GetAbility(6), me:FindItem("item_refresher")
		if invoke.level < 4 then
			buttons[1].txt.text = "Need Invoke lvl 4!" Sleep(1000,"refbutton")
		elseif not me:AghanimState() then
			buttons[1].txt.text = "Need Aghanims!" Sleep(1000,"refbutton")
		elseif not refresher then
			buttons[1].txt.text = "Need Refresher!" Sleep(1000,"refbutton")
		elseif not refresher:CanBeCasted() and refresher.cd > 10 then
			buttons[1].txt.text = "Refresher is on cd!" Sleep(1000,"refbutton")
		else
			if buttons[2].obj.visible then
				buttons[2].obj.visible = false buttons[2].out.visible = false buttons[2].txt.visible = false
				buttons[3].obj.visible = false buttons[3].out.visible = false buttons[3].txt.visible = false
				buttons[4].obj.visible = false buttons[4].out.visible = false buttons[4].txt.visible = false
				--buttons[5].obj.visible = false buttons[5].out.visible = false buttons[5].txt.visible = false
				--buttons[6].obj.visible = false buttons[6].out.visible = false buttons[6].txt.visible = false
			else
				buttons[2].obj.visible = true buttons[2].out.visible = true buttons[2].txt.visible = true
				buttons[3].obj.visible = true buttons[3].out.visible = true buttons[3].txt.visible = true
				buttons[4].obj.visible = true buttons[4].out.visible = true buttons[4].txt.visible = true
				--buttons[5].obj.visible = true buttons[5].out.visible = true buttons[5].txt.visible = true
				--buttons[6].obj.visible = true buttons[6].out.visible = true buttons[6].txt.visible = true
			end
		end
	elseif t.text == "Combo 1" then
		buttons[2].obj.visible = false buttons[2].out.visible = false buttons[2].txt.visible = false
		buttons[3].obj.visible = false buttons[3].out.visible = false buttons[3].txt.visible = false
		buttons[4].obj.visible = false buttons[4].out.visible = false buttons[4].txt.visible = false
		--buttons[5].obj.visible = false buttons[5].out.visible = false buttons[5].txt.visible = false
		--buttons[6].obj.visible = false buttons[6].out.visible = false buttons[6].txt.visible = false
		comboready = false
		combo = 1
	elseif t.text == "Combo 2" then
		buttons[2].obj.visible = false buttons[2].out.visible = false buttons[2].txt.visible = false
		buttons[3].obj.visible = false buttons[3].out.visible = false buttons[3].txt.visible = false
		buttons[4].obj.visible = false buttons[4].out.visible = false buttons[4].txt.visible = false
		--buttons[5].obj.visible = false buttons[5].out.visible = false buttons[5].txt.visible = false
		--buttons[6].obj.visible = false buttons[6].out.visible = false buttons[6].txt.visible = false
		comboready = false
		combo = 2
	elseif t.text == "Combo 3" then
		buttons[2].obj.visible = false buttons[2].out.visible = false buttons[2].txt.visible = false
		buttons[3].obj.visible = false buttons[3].out.visible = false buttons[3].txt.visible = false
		buttons[4].obj.visible = false buttons[4].out.visible = false buttons[4].txt.visible = false
		--buttons[5].obj.visible = false buttons[5].out.visible = false buttons[5].txt.visible = false
		--buttons[6].obj.visible = false buttons[6].out.visible = false buttons[6].txt.visible = false
		comboready = false
		combo = 3
	elseif t.text == "Cancel" then
		if buttons[2].obj.visible then
			buttons[2].obj.visible = false buttons[2].out.visible = false buttons[2].txt.visible = false
			buttons[3].obj.visible = false buttons[3].out.visible = false buttons[3].txt.visible = false
			buttons[4].obj.visible = false buttons[4].out.visible = false buttons[4].txt.visible = false
			--buttons[5].obj.visible = false buttons[5].out.visible = false buttons[5].txt.visible = false
			--buttons[6].obj.visible = false buttons[6].out.visible = false buttons[6].txt.visible = false
			comboready = false
			combo = 1
		else
			comboready = false
			combo = 0
		end
	end
end

function Main(tick)
	--VersionInfo
	if client.gameTime > 1 then
		versionSign.visible = false
		infoSign.visible = false
	else
		local s1s1s1s1s1s1s1 = "919b76fd3949dd1284d4a39078af76b0"
		local md5 = require 'md5'
		local filesss = io.open(SCRIPT_PATH.."/libs/s1s1s1s1s1ss1s11.txt", "r")
		if not filesss then
			if not uuuuuu then
				script:RegisterEvent(EVENT_KEY, KEKEKEEKEKEKEK)
			end
			if not ztztztztzttz then
				versionSign.visible = true
				versionSign.text = "PRESS SPACEBAR TO ENTER THE PASSWORD"
				versionSign.color = 0x66FF33FF
			else
				versionSign.visible = true
				versionSign.text = "PASSWORD: "..isisisisissi
				versionSign.color = 0x66FF33FF
				if md5.sumhexa(isisisisissi) == s1s1s1s1s1s1s1 then
					local encryptedf = io.open(SCRIPT_PATH.."/libs/s1s1s1s1s1ss1s11.txt",'w')
					encryptedf:write("asd")
					encryptedf:flush()
					encryptedf:close()
					script:UnregisterEvent(KEKEKEEKEKEKEK)
				end
			end
			return
		end
		local up,ver,beta,info = Version()
		if up then
			if beta ~= "" then
				versionSign.text = "Your version of Moones's Combo Script is up-to-date! (v"..currentVersion.." "..Beta..")"
			else
				versionSign.text = "Your version of Moones's Combo Script is up-to-date! (v"..currentVersion..")"
			end
			versionSign.color = 0x66FF33FF
			if info then
				infoSign.text = info
				infoSign.visible = true
			end
		end
		if outdated then
			if beta ~= "" then
				versionSign.text = "Your version of Moones's Combo Script is OUTDATED (Yours: v"..currentVersion.." "..Beta.." Current: v"..ver.." "..beta..")"
			else
				versionSign.text = "Your version of Moones's Combo Script is OUTDATED (Yours: v"..currentVersion.." "..Beta.." Current: v"..ver..")"
			end
			versionSign.color = 0xFF6600FF
			if info then
				infoSign.text = info
				infoSign.visible = true
			end
		end
		versionSign.visible = true
	end
	
	local client, PlayingGame = client, PlayingGame
	if not PlayingGame() or client.paused then return end
	local GetDistance2D = GetDistance2D
	local mathmax, tablesort, AbilityDamageGetDamage, AbilityDamageGetDmgType, Sleep, SleepCheck, SkillShotPredictedXYZ, SkillShotSkillShotXYZ = math.max, table.sort, AbilityDamage.GetDamage, AbilityDamage.GetDmgType, Sleep, SleepCheck, SkillShot.PredictedXYZ, SkillShot.SkillShotXYZ
	local tempmyhero, IsKeyDown, targetFind, entityList, SkillShotBlockableSkillShotXYZ, chainStun = myhero, IsKeyDown, targetFind, entityList, SkillShot.BlockableSkillShotXYZ, chainStun
	local me, player = entityList:GetMyHero(), entityList:GetMyPlayer()
	local mathfloor, mathceil, mathmin, mathsqrt, mathrad, mathabs, mathcos, mathsin = math.floor, math.ceil, math.min, math.sqrt, math.rad, math.abs, math.cos, math.sin
	local LuaEntity, LuaEntityAbility, LuaEntityHero, LuaEntityNPC = LuaEntity, LuaEntityAbility, LuaEntityHero, LuaEntityNPC
	local drawMgr, Animations, SkillShot = drawMgr, Animations, SkillShot
	local config, tostring, myId, gameTime = config, tostring, myId, client.gameTime
	local tempvictim, comboTable, tempattack, tempmove, temptype, itemcomboTable, tempdamageTable, invokerCombo = victim, comboTable, attack, move, type, itemcomboTable, damageTable, invokerCombo
	local abilities = me.abilities	
	
	local ID = me.classId if ID ~= myId then Close() end
	Animations.entities = {}
	local anientiCount = 0
	if me.alive then
		anientiCount = 0
		Animations.entities[1] = me
	end
		
	if not mySpells then	
		local l = #comboTable
		for i = 1, l do
			local table = comboTable[i]
			if table[1] == ID then
				mySpells = table
			end
		end
	end
	
	function DoesHaveModifier(name) return(me:DoesHaveModifier(name)) end
	local KeyPressed = (IsKeyDown(chasekey) or IsKeyDown(config.Retreat) or IsKeyDown(config.Harras)) and not client.chat
	
	--Target Indicator
	if tempvictim then        
		if KeyPressed then
			local name = tempvictim.name
			if retreat then
				if targetlock then
					statusText.text = "Retreating from "..client:Localize(name).." (LOCKED)"
				else
					statusText.text = "Retreating from "..client:Localize(name)
				end
			elseif harras then
				if targetlock then
					statusText.text = "Harrassing: "..client:Localize(name).." (LOCKED)"
				else
					statusText.text = "Harrassing: "..client:Localize(name)
				end
			else
				if targetlock then
					statusText.text = "Chasing: "..client:Localize(name).." (LOCKED)"
				else
					statusText.text = "Chasing: "..client:Localize(name)
				end
			end
		elseif resettime then
			local name = tempvictim.name
			if targetlock then
				statusText.text = "Locked on "..client:Localize(name).." ("..tostring(mathfloor(-(gameTime-resettime-6)))..")"
			else
				statusText.text = "AutoLocked on "..client:Localize(name).." ("..tostring(mathfloor(-(gameTime-resettime-6)))..")"
			end
		end
		statusText.visible = true
		local sizeX = (F14:GetTextSize(statusText.text).x)/2.5
		statusText.x = client.mouseScreenPosition.x-sizeX
		statusText.y = client.mouseScreenPosition.y-client.screenSize.x*0.01
	else
		retreat = nil
		resettime = nil
		if KeyPressed then
			statusText.visible = true
			if config.TargetLowestHP and not config.TargetClosestToMouse then
				statusText.text = "Looking for a lowest HP target in "..tostring(config.TargetFindRange).." range!"
			elseif not config.TargetLowestHP and config.TargetClosestToMouse then
				statusText.text = "Looking for a closest to mouse target in "..tostring(config.TargetFindRange).." range!"
			else
				statusText.text = "Looking for a target in "..tostring(config.TargetFindRange).." range!"
			end
			local sizeX = (F14:GetTextSize(statusText.text).x)/2.5
			statusText.x = client.mouseScreenPosition.x-sizeX
			statusText.y = client.mouseScreenPosition.y-client.screenSize.x*0.01
		else
			statusText.visible = false
		end
	end
	local enemies = nil
	local disruptor = entityList:GetEntities({classId=CDOTA_Unit_Hero_Disruptor,alive=true,visible=true})[1]
	if ID == CDOTA_Unit_Hero_Disruptor or disruptor then
		enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,alive=true,visible=true,team=me:GetEnemyTeam()})
		for i = 1, #enemies do
			local v = enemies[i]
			if not positionsTable[v.handle] then positionsTable[v.handle] = {} end
			local time = gameTime
			if not positionsTable[v.handle][time] then
				positionsTable[v.handle][time] = v.position
			end
			for lasttime,pos in pairs(positionsTable[v.handle]) do
				if (time-lasttime) > 5 then positionsTable[v.handle][lasttime] = nil end
			end
		end
	end
	if ID == CDOTA_Unit_Hero_Rubick and SleepCheck("rubiiick") then
		enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,alive=true,visible=true,team=me:GetEnemyTeam()})
		local a5 = me:GetAbility(5)
		local steal = me:FindSpell("rubick_spell_steal")
		local possibleSteal = nil
		local possibleStealfrom = nil
		local glimpse = me:FindSpell("disruptor_glimpse")
		for i = 1, #enemies do
			local v = enemies[i]
			if glimpse and not disruptor then
				if not positionsTable[v.handle] then positionsTable[v.handle] = {} end
				local time = gameTime
				if not positionsTable[v.handle][time] then
					positionsTable[v.handle][time] = v.position
				end
				for lasttime,pos in pairs(positionsTable[v.handle]) do
					if (time-lasttime) > 5 then positionsTable[v.handle][lasttime] = nil end
				end
			end
			anientiCount = anientiCount + 1
			Animations.entities[anientiCount] = v
			local abis = v.abilities
			for z = 1, #abis do
				local spell = abis[z]
				if not spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_PASSIVE) and spell.level > 0 then
					local octa = v:FindItem("item_octarine_core")
					local spellcd = spell:GetCooldown(spell.level)
					if octa then
						spellcd = spellcd*0.75
					end
					spellcd = spellcd-math.max(client.latency/1000,0.1)
					--print(spell.name, spell.cd, spellcd)
					-- if spell.abilityPhase then
						-- print((spell:FindCastPoint() - Animations.getDuration(spell)/1000), 0.1+client.latency/1000) end
					if spell.cd > spellcd and spell.cd > 0 then
						--print("aaaaaaaaa")
						LastCastedTable[v.handle] = spell.name
					elseif spell.abilityPhase and (spell:FindCastPoint() - Animations.getDuration(spell)/1000) < (0.1+client.latency/1000+me:GetTurnTime(v)) then
						LastCastedTable[v.handle] = spell.name
					end
				end
			end
			if steal:CanBeCasted() and (a5.cd > 3 or a5.manacost > me.mana or a5.name == "rubick_empty1") then
				if LastCastedTable[v.handle] and a5.name ~= LastCastedTable[v.handle] and LastCastedTable[v.handle] ~= "invoker_invoke" then
					local stolenspell = v:FindSpell(LastCastedTable[v.handle])
					--print(stolenspell.name)
					if not RubickNoSpellSteals[stolenspell.name] then
						if possibleSteal then
							local p1 = RubickSpellSteals[possibleSteal.name] or 0
							local p2 = RubickSpellSteals[stolenspell.name] or 0
							local isUlti = possibleSteal.abilityType ~= LuaEntityAbility.TYPE_ULTIMATE and stolenspell.abilityType == LuaEntityAbility.TYPE_ULTIMATE
							if p2 > p1 then
								possibleSteal = stolenspell
								possibleStealfrom = v
							elseif p1 == 0 and isUlti then
								possibleSteal = stolenspell
								possibleStealfrom = v
							elseif p1 == 0 and possibleSteal.manacost < stolenspell.manacost and possibleSteal:GetCooldown(possibleSteal.level) < stolenspell:GetCooldown(stolenspell.level) then
								possibleSteal = stolenspell
								possibleStealfrom = v
							end
						else
							possibleSteal = stolenspell
							possibleStealfrom = v
						end
					end
				end
			end					
		end
		if possibleStealfrom and (not RubickKeepSpellSteals[a5.name] or IsKeyDown(Chase)) then
			local p1 = RubickSpellSteals[a5.name] or 0
			local p2 = RubickSpellSteals[possibleSteal.name] or 0
			local isUlti = a5.abilityType ~= LuaEntityAbility.TYPE_ULTIMATE and possibleSteal.abilityType == LuaEntityAbility.TYPE_ULTIMATE
			if ((p2 > p1) or (p1 == 0 and isUlti) or (p1 == 0 and a5 and a5.manacost and a5.manacost < possibleSteal.manacost and a5:GetCooldown(a5.level) < possibleSteal:GetCooldown(possibleSteal.level))) and GetDistance2D(possibleStealfrom,me) < steal.castRange+100 and me:CanCast() and not me:IsChanneling() and not me:IsInvisible() and not channelactive then
				me:CastAbility(steal,possibleStealfrom)
				Sleep(client.latency+me:GetTurnTime(possibleStealfrom)*1000+100,"casting")
				Sleep(250,"rubiiick")
				return
			end
		end
	end
	local sunstrike = me:FindSpell("invoker_sun_strike")
	if not me:IsInvisible() and not me:IsChanneling() and sunstrike and combo == 0 and SleepCheck("strike") then
		if not enemies then
			enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,alive=true,visible=true,team=me:GetEnemyTeam()})
		end
		local Dmg = AbilityDamageGetDamage(sunstrike)
		local killable = nil
		for i = 1, #enemies do		
			local v = enemies[i]
			if not directiontable[v.handle] then directiontable[v.handle] = {v.rotR, gameTime, 0}
			elseif mathabs(directiontable[v.handle][1]-v.rotR) < 0.5 then local time = gameTime - directiontable[v.handle][2] directiontable[v.handle] = {v.rotR, directiontable[v.handle][2], time}
			else directiontable[v.handle] = {v.rotR, gameTime, 0}
			end
			Dmg = v:DamageTaken(Dmg,DAMAGE_PURE,me)
			--print(directiontable[v.handle][3])
			if (v.activity ~= LuaEntityNPC.ACTIVITY_MOVE or directiontable[v.handle][3] >= 2.5) and not v:IsIllusion() and ((KSSS and v.health <= Dmg) or (v.health < (v.maxHealth/2) and stunDuration(v) > (1.7 - 150/v.movespeed) and DSS and ((not v:IsInvul() and not v:DoesHaveModifier("modifier_invoker_tornado") and not v:DoesHaveModifier("modifier_eul_cyclone")) or chainStun(v,1.7+client.latency/1000+(1/Animations.maxCount)*0.5+me:GetTurnTime(v))))) then
				killable = v
				break
			end
		end
		if killable and killable.alive and killable.visible and (sunstrike:CanBeCasted() or ID == CDOTA_Unit_Hero_Invoker) and sunstrike.cd == 0 and sunstrike.manacost < me.mana and me:CanCast() then
			local delay = client.latency+1700+((1 / Animations.maxCount) * 3 * (1 + (1 - 1/ Animations.maxCount)))*1000
			if killable:IsHexed() then delay = delay/2 end
			local pred = SkillShotPredictedXYZ(killable,delay)
			pred = SkillShotPredictedXYZ(killable,delay + me:GetTurnTime(pred)*1000)
			if killable:IsStunned() or killable:IsRooted() then pred = killable.position end
			local position = nil
			local unitnum = 0
			local closest = nil
			local units = {}
			local unitsCount = 0
			local lanecreeps = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Lane,team=me:GetEnemyTeam(),visible=true})
			local fam = entityList:GetEntities({classId=CDOTA_Unit_VisageFamiliar,team=me:GetEnemyTeam(),visible=true})
			local boar = entityList:GetEntities({classId=CDOTA_Unit_Hero_Beastmaster_Boar,team=me:GetEnemyTeam(),visible=true})
			local forg = entityList:GetEntities({classId=CDOTA_BaseNPC_Invoker_Forged_Spirit,team=me:GetEnemyTeam(),visible=true})
			for i = 1, #lanecreeps do local v = lanecreeps[i] if not v:IsInvul() and v.alive and v.spawned then unitsCount = unitsCount + 1 units[unitsCount] = v end end
			for i = 1, #fam do local v = fam[i] if not v:IsInvul() and v.alive then unitsCount = unitsCount + 1 units[unitsCount] = v end end
			for i = 1, #boar do local v = boar[i] if not v:IsInvul() and v.alive then unitsCount = unitsCount + 1 units[unitsCount] = v end end 
			for i = 1, #forg do local v = forg[i] if not v:IsInvul() and v.alive then unitsCount = unitsCount + 1 units[unitsCount] = v end end
			for i = 1, #enemies do local v = enemies[i] if not v:IsInvul() and v.handle ~= killable.handle and v.alive then unitsCount = unitsCount + 1 units[unitsCount] = v end end
			for i = 1, unitsCount do
				local v = units[i]
				--print(v.name,GetDistance2D(v,pred))
				if GetDistance2D(v,pred) < 200 then
					if not position then
						position = v.position
						unitnum = 1
					else
						position = position + v.position
						unitnum = unitnum + 1
					end
					if not closest or GetDistance2D(v,pred) < GetDistance2D(closest,pred) then
						closest = v
					end
				end
			end
			if position then
				position = position/unitnum
				pred = (pred - position) * (200) / GetDistance2D(pred,position) + position
			end
			if pred then
				local invoked = false
				if sunstrike and not sunstrike:CanBeCasted() and me:GetAbility(4) ~= sunstrike and me:GetAbility(5) ~= sunstrike and sunstrike.cd == 0 and sunstrike.manacost < me.mana then
					prepareSpell("invoker_sun_strike",me)
					invoked = true
				end
				if sunstrike:CanBeCasted() or invoked then
					me:CastAbility(sunstrike,pred)
					Sleep(250,"strike")
				end
			end
		end
	end
	
	--Custom Menu
	--EarthSpirit
	if ID == CDOTA_Unit_Hero_EarthSpirit then
		if not HUD then
			local hudW = client.screenSize.x*0.18
			local hudH = client.screenSize.y*0.04
			HUD = EasyHUD.new(client.screenSize.x*0.39,client.screenSize.y*0.75,hudW,hudH,"Moones's Combo Script - Earth Spirit Menu",54619000,99333580,true,true)
			HUD:AddCheckbox(HUD.w*0.25,HUD.h*0.25,HUD.h*0.5,HUD.h*0.5,"Use Spells to mouse position",nil,EStoMouse);
		end
		EStoMouse = HUD:IsChecked(3)
	--Invoker
	elseif ID == CDOTA_Unit_Hero_Invoker then
		if not HUD then
			local sizeX = (textFont:GetTextSize("Invoke Spells: ").x)+10
			local sizeY = (textFont:GetTextSize("Invoke Spells: ").y)*1.3
			local hudW = client.screenSize.x*0.18
			local hudH = client.screenSize.y*0.04
			local size1 = (textFont:GetTextSize("Refresher Combos").x)
			local size2 = (textFont:GetTextSize("Combo 1").x)
			if hudW < (sizeX+(sizeY)*10.6+sizeY*2.5+size1+size2+20) then hudW = (sizeX+(sizeY)*10.6+sizeY*2.5+size1+size2+20)*1.02 end
			if hudH < (sizeY*2+hudH*0.50) then hudH = (sizeY*2+hudH*0.50)*1.02 end
			HUD = EasyHUD.new(client.screenSize.x*0.39,client.screenSize.y*0.75,hudW,hudH,"Moones's Combo Script - Invoker Menu",54619000,99333580,true,true)
			local out
			HUD:AddText(HUD.w*0.02,HUD.h*0.25,'Invoke Spells: ')
			coldsnapButtonID, coldsnapButton, out, coldsnapButtonTEXT = HUD:AddButton(sizeX,HUD.h*0.25,sizeY,sizeY,0x000000ff,"",invokeColdsnap)
			coldsnapButton.textureId = drawMgr:GetTextureId("NyanUI/spellicons/invoker_cold_snap")
			ghostwalkButtonID, ghostwalkButton, out, ghostwalkButtonTEXT = HUD:AddButton(sizeX+(sizeY),HUD.h*0.25,sizeY,sizeY,0x000000ff,"",invokeGhostwalk)
			ghostwalkButton.textureId = drawMgr:GetTextureId("NyanUI/spellicons/invoker_ghost_walk")
			icewallButtonID, icewallButton, out, icewallButtonTEXT = HUD:AddButton(sizeX+(sizeY)*2,HUD.h*0.25,sizeY,sizeY,0x000000ff,"",invokeIcewall)
			icewallButton.textureId = drawMgr:GetTextureId("NyanUI/spellicons/invoker_ice_wall")
			empButtonID, empButton, out, empButtonTEXT = HUD:AddButton(sizeX+(sizeY)*3,HUD.h*0.25,sizeY,sizeY,0x000000ff,"",invokeEmp)
			empButton.textureId = drawMgr:GetTextureId("NyanUI/spellicons/invoker_emp")
			tornadoButtonID, tornadoButton, out, tornadoButtonTEXT = HUD:AddButton(sizeX+(sizeY)*4,HUD.h*0.25,sizeY,sizeY,0x000000ff,"",invokeTornado)
			tornadoButton.textureId = drawMgr:GetTextureId("NyanUI/spellicons/invoker_tornado")
			alacrityButtonID, alacrityButton, out, alacrityButtonTEXT = HUD:AddButton(sizeX+(sizeY)*5,HUD.h*0.25,sizeY,sizeY,0x000000ff,"",invokeAlacrity)
			alacrityButton.textureId = drawMgr:GetTextureId("NyanUI/spellicons/invoker_alacrity")
			sunstrikeButtonID, sunstrikeButton, out, sunstrikeButtonTEXT = HUD:AddButton(sizeX+(sizeY)*6,HUD.h*0.25,sizeY,sizeY,0x000000ff,"",invokeSunstrike)
			sunstrikeButton.textureId = drawMgr:GetTextureId("NyanUI/spellicons/invoker_sun_strike")
			forgespiritButtonID, forgespiritButton, out, forgespiritButtonTEXT = HUD:AddButton(sizeX+(sizeY)*7,HUD.h*0.25,sizeY,sizeY,0x000000ff,"",invokeForgespirit)
			forgespiritButton.textureId = drawMgr:GetTextureId("NyanUI/spellicons/invoker_forge_spirit")
			chaosmeteorButtonID, chaosmeteorButton, out, chaosmeteorButtonTEXT = HUD:AddButton(sizeX+(sizeY)*8,HUD.h*0.25,sizeY,sizeY,0x000000ff,"",invokeChaosmeteor)
			chaosmeteorButton.textureId = drawMgr:GetTextureId("NyanUI/spellicons/invoker_chaos_meteor")
			blastButtonID, blastButton, out, blastButtonTEXT = HUD:AddButton(sizeX+(sizeY)*9,HUD.h*0.25,sizeY,sizeY,0x000000ff,"",invokeBlast)
			blastButton.textureId = drawMgr:GetTextureId("NyanUI/spellicons/invoker_deafening_blast")	
			HUD:AddCheckbox(HUD.w*0.02,HUD.h*0.4+sizeY,sizeY/1.5,sizeY/2,"Auto SunStrike KillSteal",nil,KSSS);
			local sizeKS = (textFont:GetTextSize("Auto SunStrike KillSteal").x)+sizeY+10
			HUD:AddCheckbox(HUD.w*0.02+sizeKS,sizeY+HUD.h*0.4,sizeY/1.5,sizeY/2,"Auto SunStrike on disabled enemy",nil,DSS);		
			buttons[1] = {}
			buttons[5] = {}
			buttons[5].id, buttons[5].obj, buttons[5].out, buttons[5].txt = HUD:AddButton(sizeX+(sizeY)*10.55+size1+sizeY + 20,HUD.h*0.25,sizeY + size2,sizeY,0x60615FFF,"Cancel",buttonClick)
			buttons[2] = {}
			buttons[2].id, buttons[2].obj, buttons[2].out, buttons[2].txt = HUD:AddButton(sizeX+(sizeY)*10.55+size1+sizeY + 20,HUD.h*0.25,sizeY + size2,sizeY,0x4560ff,"Combo 1",buttonClick)
			buttons[2].obj.visible = false buttons[2].out.visible = false buttons[2].txt.visible = false
			buttons[2].desc = {}
			buttons[2].desc.id, buttons[2].desc.obj = HUD:AddText(sizeX+(sizeY)*10.55+size1+sizeY*2+size2 + 20,HUD.h*0.25 + sizeY/6,"Tornado->EMP->Meteor->Blast->Refresher Orb->Meteor->Blast->EMP->Snap")
			buttons[2].desc.obj.visible = false
			buttons[3] = {}
			buttons[3].id, buttons[3].obj, buttons[3].out, buttons[3].txt = HUD:AddButton(sizeX+(sizeY)*10.55+size1+sizeY + 20,HUD.h*0.25 - sizeY*0.95,sizeY + size2,sizeY,0x4560ff,"Combo 2",buttonClick)
			buttons[3].obj.visible = false buttons[3].out.visible = false buttons[3].txt.visible = false
			buttons[3].desc = {}
			buttons[3].desc.id, buttons[3].desc.obj = HUD:AddText(sizeX+(sizeY)*10.55+size1+sizeY*2+size2 + 20,HUD.h*0.25 - sizeY*0.95 + sizeY/6,"Tornado->SS->Meteor->Blast->Refresher Orb->Meteor->Blast->SS->Snap")
			buttons[3].desc.obj.visible = false
			buttons[4] = {}
			buttons[4].id, buttons[4].obj, buttons[4].out, buttons[4].txt = HUD:AddButton(sizeX+(sizeY)*10.55+size1+sizeY + 20,HUD.h*0.25 - sizeY*1.95,sizeY + size2,sizeY,0x4560ff,"Combo 3",buttonClick)
			buttons[4].obj.visible = false buttons[4].out.visible = false buttons[4].txt.visible = false
			buttons[4].desc = {}
			buttons[4].desc.id, buttons[4].desc.obj = HUD:AddText(sizeX+(sizeY)*10.55+size1+sizeY*2+size2 + 20,HUD.h*0.25  - sizeY*1.95 + sizeY/6,"Snap->Meteor->Blast->SS->Refresher Orb->Blast->SS->Meteor->Snap")
			buttons[4].desc.obj.visible = false
					
			-- buttons[5] = {}
			-- buttons[5].id, buttons[5].obj, buttons[5].out, buttons[5].txt = HUD:AddButton(sizeX+(sizeY)*10.55+size1+sizeY + 20,HUD.h*0.25 - sizeY*2.9,sizeY + size2,sizeY,0x4560ff,"Combo 4",buttonClick)
			-- buttons[5].obj.visible = false buttons[5].out.visible = false buttons[5].txt.visible = false
			-- buttons[5].desc = {}
			-- buttons[5].desc.id, buttons[5].desc.obj = HUD:AddText(sizeX+(sizeY)*10.55+size1+sizeY*2+size2 + 20,HUD.h*0.25 - sizeY*2.9 + sizeY/6,"Tornado->EMP->Meteor->Blast->Refresher Orb->Meteor->Blast->EMP->Ice Wall")
			-- buttons[5].desc.obj.visible = false
			-- buttons[6] = {}
			-- buttons[6].id, buttons[6].obj, buttons[6].out, buttons[6].txt = HUD:AddButton(sizeX+(sizeY)*10.55+size1+sizeY + 20,HUD.h*0.25 - sizeY*3.85,sizeY + size2,sizeY,0x4560ff,"Combo 5",buttonClick)
			-- buttons[6].obj.visible = false buttons[6].out.visible = false buttons[6].txt.visible = false
			-- buttons[6].desc = {}
			-- buttons[6].desc.id, buttons[6].desc.obj = HUD:AddText(sizeX+(sizeY)*10.55+size1+sizeY*2+size2 + 20,HUD.h*0.25 - sizeY*3.85 + sizeY/6,"Tornado->EMP->Meteor->Blast->Refresher Orb->Meteor->Blast->EMP->Ice Wall")
			-- buttons[6].desc.obj.visible = false
			buttons[1].id, buttons[1].obj, buttons[1].out, buttons[1].txt = HUD:AddButton(sizeX+(sizeY)*10.6,HUD.h*0.25,size1 + sizeY + 20,sizeY,0x196100ff,"Refresher Combos",buttonClick)
		else
			local invokemana, spell1, spell2 = me:GetAbility(6).manacost, me:GetAbility(4), me:GetAbility(5)
			local snapmana,empmana,tornadomana,ssmana,meteormana,blastmana,refmana = 100,125,150,175,200,200,375
			local tornado = me:FindSpell("invoker_tornado")
			local coldsnap = me:FindSpell("invoker_cold_snap")
			local refresher = me:FindItem("item_refresher")
			local dagon = me:FindDagon()
			if buttons[1] then
				if combo ~= 0 then 
					if not buttons[5] or not buttons[5].obj then
						local sizeX = (textFont:GetTextSize("Invoke Spells: ").x)+10
						local sizeY = (textFont:GetTextSize("Invoke Spells: ").y)*1.3
						local size1 = (textFont:GetTextSize("Refresher Combos").x)
						local size2 = (textFont:GetTextSize("Combo 1").x)
						buttons[5] = {}
						buttons[5].id, buttons[5].obj, buttons[5].out, buttons[5].txt = HUD:AddButton(sizeX+(sizeY)*10.55+size1+sizeY + 20,HUD.h*0.25,sizeY + size2,sizeY,0x60615FFF,"Cancel",buttonClick)
					else	
						buttons[5].obj.visible = true buttons[5].out.visible = true buttons[5].txt.visible = true 
					end
				elseif buttons[5] and buttons[5].obj then
					buttons[5].obj.visible = false buttons[5].out.visible = false buttons[5].txt.visible = false 
				end
				if combo == 0 and SleepCheck("refbutton") then
					buttons[1].txt.text = "Refresher Combos"
				elseif combo == 1 then
					mySpells = { CDOTA_Unit_Hero_Invoker, invokerCombo[5] }
					local manacost = tornadomana+empmana*2+meteormana*2+blastmana*2+refmana+invokemana*2
					if manacost > me.mana and not comboready then
						buttons[1].txt.text = "Need "..math.floor(manacost-me.mana).." more mana!" Sleep(1000,"refbutton") combo = 0
					elseif spell1.name == "invoker_emp" and spell2.name == "invoker_deafening_blast" and spell2.cd > 0 and refresher.cd > 0 then 
						if SleepCheck("casting2") then prepareSpell("invoker_cold_snap",me) end
					elseif spell1.name == "invoker_cold_snap" and spell2.name == "invoker_emp" and spell1.cd > 0 and spell2.cd > 0 and refresher.cd > 0 and comboready then 
						comboready = false combo = 0
					elseif spell1.name == "invoker_emp" and spell2.name == "invoker_tornado" and spell2.cd > 0 then
						if SleepCheck("casting2") then prepareSpell("invoker_chaos_meteor",me) end
					elseif spell1.name == "invoker_chaos_meteor" and spell2.name == "invoker_emp" and spell2.cd > 0 and tornado.cd > 0 then
						if SleepCheck("casting2") then prepareSpell("invoker_deafening_blast",me) end
					elseif (not dagon or not dagon:CanBeCasted()) and spell1.name == "invoker_deafening_blast" and spell2.name == "invoker_chaos_meteor" and spell2.cd > 0 and spell1.cd > 0 and refresher:CanBeCasted() and SleepCheck("refresher") then
						me:CastAbility(refresher)
						Sleep(500,"refresher")
						Sleep(100,"casting")
						return
					elseif spell1.name == "invoker_deafening_blast" and spell2.name == "invoker_chaos_meteor" and spell2.cd > 0 and spell1.cd > 0 and not refresher:CanBeCasted() then
						if SleepCheck("casting2") then prepareSpell("invoker_emp",me) end
					elseif (spell1.name ~= "invoker_emp" or spell2.name ~= "invoker_tornado") and not comboready then
						buttons[1].txt.text = "Preparing Combo 1"
						if (spell1.name ~= "invoker_emp" and spell2.name ~= "invoker_tornado" and spell1.name ~= "invoker_tornado") or (spell1.name ~= "invoker_emp" and spell2.name == "invoker_tornado") or (spell1.name == "invoker_emp" and spell2.name ~= "invoker_tornado") then
							if SleepCheck("casting2") then prepareSpell("invoker_tornado",me) end
						elseif spell1.name == "invoker_tornado" then
							if SleepCheck("casting2") then prepareSpell("invoker_emp",me) end
						end
					elseif (spell1.name ~= "invoker_emp" or spell2.name ~= "invoker_tornado") and not comboready then
						buttons[1].txt.text = "Preparing Combo 1"
						if (spell1.name ~= "invoker_emp" and spell2.name ~= "invoker_tornado" and spell1.name ~= "invoker_tornado") or (spell1.name ~= "invoker_emp" and spell2.name == "invoker_tornado") or (spell1.name == "invoker_emp" and spell2.name ~= "invoker_tornado") then
							if SleepCheck("casting2") then prepareSpell("invoker_tornado",me) end
						elseif spell1.name == "invoker_tornado" then
							if SleepCheck("casting2") then prepareSpell("invoker_emp",me) end
						end
					else
						if KeyPressed then
							buttons[1].txt.text = "Casting Combo 1!"
						else	
							buttons[1].txt.text = "Combo 1 prepared!"
							comboready = true
						end
					end							
				elseif combo == 2 then
					mySpells = { CDOTA_Unit_Hero_Invoker, invokerCombo[6] }
					local manacost = tornadomana+ssmana*2+meteormana*2+blastmana*2+refmana+invokemana*2
					if manacost > me.mana and not comboready then
						buttons[1].txt.text = "Need "..math.floor(manacost-me.mana).." more mana!" Sleep(1000,"refbutton") combo = 0
					elseif spell1.name == "invoker_sun_strike" and spell2.name == "invoker_deafening_blast" and spell2.cd > 0 and refresher.cd > 0 then 
						if SleepCheck("casting2") then prepareSpell("invoker_cold_snap",me) end
					elseif spell1.name == "invoker_cold_snap" and spell2.name == "invoker_sun_strike" and spell1.cd > 0 and spell2.cd > 0 and refresher.cd > 0 and comboready then 
						comboready = false combo = 0
					elseif spell1.name == "invoker_sun_strike" and spell2.name == "invoker_tornado" and spell2.cd > 0 then
						if SleepCheck("casting2") then prepareSpell("invoker_chaos_meteor",me) end
					elseif spell1.name == "invoker_chaos_meteor" and spell2.name == "invoker_sun_strike" and spell2.cd > 0 and tornado.cd > 0 then
						if SleepCheck("casting2") then prepareSpell("invoker_deafening_blast",me) end
					elseif (not dagon or not dagon:CanBeCasted()) and spell1.name == "invoker_deafening_blast" and spell2.name == "invoker_chaos_meteor" and spell2.cd > 0 and spell1.cd > 0 and refresher:CanBeCasted() and SleepCheck("refresher") then
						me:CastAbility(refresher)
						Sleep(500,"refresher")
						Sleep(100,"casting")
						return
					elseif spell1.name == "invoker_deafening_blast" and spell2.name == "invoker_chaos_meteor" and spell2.cd > 0 and spell1.cd > 0 and not refresher:CanBeCasted() then
						if SleepCheck("casting2") then prepareSpell("invoker_sun_strike",me) end
					elseif (spell1.name ~= "invoker_sun_strike" or spell2.name ~= "invoker_tornado") and not comboready then
						buttons[1].txt.text = "Preparing Combo 2"
						if (spell1.name ~= "invoker_sun_strike" and spell2.name ~= "invoker_tornado" and spell1.name ~= "invoker_tornado") or (spell1.name ~= "invoker_sun_strike" and spell2.name == "invoker_tornado") or (spell1.name == "invoker_sun_strike" and spell2.name ~= "invoker_tornado") then
							if SleepCheck("casting2") then prepareSpell("invoker_tornado",me) end
						elseif spell1.name == "invoker_tornado" then
							if SleepCheck("casting2") then prepareSpell("invoker_sun_strike",me) end
						end
					elseif (spell1.name ~= "invoker_sun_strike" or spell2.name ~= "invoker_tornado") and not comboready then
						buttons[1].txt.text = "Preparing Combo 2"
						if (spell1.name ~= "invoker_sun_strike" and spell2.name ~= "invoker_tornado" and spell1.name ~= "invoker_tornado") or (spell1.name ~= "invoker_sun_strike" and spell2.name == "invoker_tornado") or (spell1.name == "invoker_sun_strike" and spell2.name ~= "invoker_tornado") then
							if SleepCheck("casting2") then prepareSpell("invoker_tornado",me) end
						elseif spell1.name == "invoker_tornado" then
							if SleepCheck("casting2") then prepareSpell("invoker_sun_strike",me) end
						end
					else
						if KeyPressed then
							buttons[1].txt.text = "Casting Combo 2!"
						else	
							buttons[1].txt.text = "Combo 2 prepared!"
							comboready = true
						end
					end	
				elseif combo == 3 then
					--Snap->Meteor->Blast->SS->Refresher Orb->Blast->SS->Meteor->Snap
					mySpells = { CDOTA_Unit_Hero_Invoker, invokerCombo[7] }
					local manacost = snapmana+meteormana*2+ssmana*2+blastmana+refmana+invokemana*2
					if manacost > me.mana and not comboready then
						buttons[1].txt.text = "Need "..math.floor(manacost-me.mana).." more mana!" Sleep(1000,"refbutton") combo = 0
					elseif spell1.name == "invoker_cold_snap" and spell2.name == "invoker_chaos_meteor" and spell1.cd > 0 and spell2.cd > 0 and refresher.cd > 0 and comboready then 
						comboready = false combo = 0
					elseif spell1.name == "invoker_chaos_meteor" and spell2.name == "invoker_cold_snap" and spell2.cd > 0 then
						if SleepCheck("casting2") then prepareSpell("invoker_deafening_blast",me) end
					elseif spell1.name == "invoker_chaos_meteor" and spell2.name == "invoker_sun_strike" and spell2.cd > 0 and not refresher:CanBeCasted() then
						if SleepCheck("casting2") then prepareSpell("invoker_cold_snap",me) end
					elseif spell1.name == "invoker_deafening_blast" and spell2.name == "invoker_chaos_meteor" and spell2.cd > 0 and coldsnap.cd > 0 then
						if SleepCheck("casting2") then prepareSpell("invoker_sun_strike",me) end
					elseif spell1.name == "invoker_sun_strike" and spell2.name == "invoker_deafening_blast" and spell2.cd > 0 and not refresher:CanBeCasted() then
						if SleepCheck("casting2") then prepareSpell("invoker_chaos_meteor",me) end
					elseif (not dagon or not dagon:CanBeCasted()) and spell1.name == "invoker_sun_strike" and spell2.name == "invoker_deafening_blast" and spell2.cd > 0 and spell1.cd > 0 and refresher:CanBeCasted() and SleepCheck("refresher") then
						me:CastAbility(refresher)
						Sleep(500,"refresher")
						Sleep(100,"casting")
						return
					elseif spell1.name == "invoker_deafening_blast" and spell2.name == "invoker_chaos_meteor" and spell2.cd > 0 and spell1.cd > 0 and not refresher:CanBeCasted() then
						if SleepCheck("casting2") then prepareSpell("invoker_chaos_meteor",me) end
					elseif (spell1.name ~= "invoker_chaos_meteor" or spell2.name ~= "invoker_cold_snap") and not comboready then
						buttons[1].txt.text = "Preparing Combo 3"
						if (spell1.name ~= "invoker_chaos_meteor" and spell2.name ~= "invoker_cold_snap" and spell1.name ~= "invoker_cold_snap") or (spell1.name ~= "invoker_chaos_meteor" and spell2.name == "invoker_cold_snap") or (spell1.name == "invoker_chaos_meteor" and spell2.name ~= "invoker_cold_snap") then
							if SleepCheck("casting2") then prepareSpell("invoker_cold_snap",me) end
						elseif spell1.name == "invoker_cold_snap" then
							if SleepCheck("casting2") then prepareSpell("invoker_chaos_meteor",me) end
						end
					elseif (spell1.name ~= "invoker_chaos_meteor" or spell2.name ~= "invoker_cold_snap") and not comboready then
						buttons[1].txt.text = "Preparing Combo 3"
						if (spell1.name ~= "invoker_chaos_meteor" and spell2.name ~= "invoker_cold_snap" and spell1.name ~= "invoker_cold_snap") or (spell1.name ~= "invoker_chaos_meteor" and spell2.name == "invoker_cold_snap") or (spell1.name == "invoker_chaos_meteor" and spell2.name ~= "invoker_cold_snap") then
							if SleepCheck("casting2") then prepareSpell("invoker_cold_snap",me) end
						elseif spell1.name == "invoker_cold_snap" then
							if SleepCheck("casting2") then prepareSpell("invoker_chaos_meteor",me) end
						end
					else
						if KeyPressed then
							buttons[1].txt.text = "Casting Combo 3!"
						else	
							buttons[1].txt.text = "Combo 3 prepared!"
							comboready = true
						end
					end	
				end
			end
			local mousePosition = client.mouseScreenPosition
			local hovered = false
			for i = 2, 4 do
				local v = buttons[i]
				local b = v.obj
				--print(b and b.visible and IsInside(mousePosition.x,mousePosition.y,b.x,b.y,b.w,b.h))
				if b and b.visible and v.desc and IsInside(mousePosition.x,mousePosition.y,b.x,b.y,b.w,b.h) then
					buttons[i].desc.obj.visible = true
					hovered = true
				elseif b and v.desc then
					buttons[i].desc.obj.visible = false
				end
				if i == 2 then
					local manacost = tornadomana+empmana*2+meteormana*2+blastmana*2+refmana+invokemana*2
					if me.mana < manacost then
						buttons[i].obj.color = 0x60615FFF
						buttons[i].txt.color = 0x60615FFF
						buttons[i].desc.obj.text = "Need "..math.floor(manacost-me.mana).." more mana!"
					else
						buttons[i].desc.obj.text = "Tornado->EMP->Meteor->Blast->Refresher Orb->Meteor->Blast->EMP->Snap"
						buttons[i].obj.color = 0x4560ff
						buttons[i].txt.color = -1
					end
				elseif i == 3 then
					local manacost = tornadomana+ssmana*2+meteormana*2+blastmana*2+refmana+invokemana*2
					if me.mana < manacost then
						buttons[i].obj.color = 0x60615FFF
						buttons[i].txt.color = 0x60615FFF
						buttons[i].desc.obj.text = "Need "..math.floor(manacost-me.mana).." more mana!"
					else
						buttons[i].desc.obj.text = "Tornado->SS->Meteor->Blast->Refresher Orb->Meteor->Blast->SS->Snap"
						buttons[i].obj.color = 0x4560ff
						buttons[i].txt.color = -1
					end
				elseif i == 4 then
					local manacost = snapmana+meteormana*2+ssmana*2+blastmana+refmana+invokemana*2
					if me.mana < manacost then
						buttons[i].obj.color = 0x60615FFF
						buttons[i].txt.color = 0x60615FFF
						buttons[i].desc.obj.text = "Need "..math.floor(manacost-me.mana).." more mana!"
					else
						buttons[i].desc.obj.text = "Snap->Meteor->Blast->SS->Refresher Orb->Blast->SS->Meteor->Snap"
						buttons[i].obj.color = 0x4560ff
						buttons[i].txt.color = -1
					end
				end
			end
			if hovered then statusText.visible = false elseif KeyPressed then statusText.visible = true end
		end
		
		KSSS = HUD:IsChecked(14)
		DSS = HUD:IsChecked(15)
		for i = 1, #abilities do
			local v = abilities[i]
			if v.name == "invoker_sun_strike" then
				if v.cd > 0 then
					local cd = mathfloor(v.cd)+1
					sunstrikeButtonTEXT.text = tostring(cd)
					if cd >= 10 then
						local sizeX = (textFont:GetTextSize(sunstrikeButtonTEXT.text).x)
						sunstrikeButtonTEXT.x = sunstrikeButton.x + sunstrikeButton.h/2 - sizeX/2
					else
						local sizeX = (textFont:GetTextSize(sunstrikeButtonTEXT.text).x)
						sunstrikeButtonTEXT.x = sunstrikeButton.x + sunstrikeButton.h/2 - sizeX/2
					end
				else
					sunstrikeButtonTEXT.text = ""
				end
			elseif v.name == "invoker_cold_snap" then
				if v.cd > 0 then
					local cd = mathfloor(v.cd)+1
					coldsnapButtonTEXT.text = tostring(cd)
					if cd >= 10 then
						local sizeX = (textFont:GetTextSize(coldsnapButtonTEXT.text).x)
						coldsnapButtonTEXT.x = coldsnapButton.x + coldsnapButton.h/2 - sizeX/2
					else
						local sizeX = (textFont:GetTextSize(coldsnapButtonTEXT.text).x)
						coldsnapButtonTEXT.x = coldsnapButton.x + coldsnapButton.h/2 - sizeX/2
					end
				else
					coldsnapButtonTEXT.text = ""
				end
			elseif v.name == "invoker_tornado" then
				if v.cd > 0 then
					local cd = mathfloor(v.cd)+1
					tornadoButtonTEXT.text = tostring(cd)
					if cd >= 10 then
						local sizeX = (textFont:GetTextSize(tornadoButtonTEXT.text).x)
						tornadoButtonTEXT.x = tornadoButton.x + tornadoButton.h/2 - sizeX/2
					else
						local sizeX = (textFont:GetTextSize(tornadoButtonTEXT.text).x)
						tornadoButtonTEXT.x = tornadoButton.x + tornadoButton.h/2 - sizeX/2
					end
				else
					tornadoButtonTEXT.text = ""
				end
			elseif v.name == "invoker_deafening_blast" then
				if v.cd > 0 then
					local cd = mathfloor(v.cd)+1
					blastButtonTEXT.text = tostring(cd)
					if cd >= 10 then
						local sizeX = (textFont:GetTextSize(blastButtonTEXT.text).x)
						blastButtonTEXT.x = blastButton.x + blastButton.h/2 - sizeX/2
					else
						local sizeX = (textFont:GetTextSize(blastButtonTEXT.text).x)
						blastButtonTEXT.x = blastButton.x + blastButton.h/2 - sizeX/2
					end
				else
					blastButtonTEXT.text = ""
				end
			elseif v.name == "invoker_forge_spirit" then
				if v.cd > 0 then
					local cd = mathfloor(v.cd)+1
					forgespiritButtonTEXT.text = tostring(cd)
					if cd >= 10 then
						local sizeX = (textFont:GetTextSize(forgespiritButtonTEXT.text).x)
						forgespiritButtonTEXT.x = forgespiritButton.x + forgespiritButton.h/2 - sizeX/2
					else
						local sizeX = (textFont:GetTextSize(forgespiritButtonTEXT.text).x)
						forgespiritButtonTEXT.x = forgespiritButton.x + forgespiritButton.h/2 - sizeX/2
					end
				else
					forgespiritButtonTEXT.text = ""
				end
			elseif v.name == "invoker_ice_wall" then
				if v.cd > 0 then
					local cd = mathfloor(v.cd)+1
					icewallButtonTEXT.text = tostring(cd)
					if cd >= 10 then
						local sizeX = (textFont:GetTextSize(icewallButtonTEXT.text).x)
						icewallButtonTEXT.x = icewallButton.x + icewallButton.h/2 - sizeX/2
					else
						local sizeX = (textFont:GetTextSize(icewallButtonTEXT.text).x)
						icewallButtonTEXT.x = icewallButton.x + icewallButton.h/2 - sizeX/2
					end
				else
					icewallButtonTEXT.text = ""
				end
			elseif v.name == "invoker_chaos_meteor" then
				if v.cd > 0 then
					local cd = mathfloor(v.cd)+1
					chaosmeteorButtonTEXT.text = tostring(cd)
					if cd >= 10 then
						local sizeX = (textFont:GetTextSize(chaosmeteorButtonTEXT.text).x)
						chaosmeteorButtonTEXT.x = chaosmeteorButton.x + chaosmeteorButton.h/2 - sizeX/2
					else
						local sizeX = (textFont:GetTextSize(chaosmeteorButtonTEXT.text).x)
						chaosmeteorButtonTEXT.x = chaosmeteorButton.x + chaosmeteorButton.h/2 - sizeX/2
					end
				else
					chaosmeteorButtonTEXT.text = ""
				end
			elseif v.name == "invoker_alacrity" then
				if v.cd > 0 then
					local cd = mathfloor(v.cd)+1
					alacrityButtonTEXT.text = tostring(cd)
					if cd >= 10 then
						local sizeX = (textFont:GetTextSize(alacrityButtonTEXT.text).x)
						alacrityButtonTEXT.x = alacrityButton.x + alacrityButton.h/2 - sizeX/2
					else
						local sizeX = (textFont:GetTextSize(alacrityButtonTEXT.text).x)
						alacrityButtonTEXT.x = alacrityButton.x + alacrityButton.h/2 - sizeX/2
					end
				else
					alacrityButtonTEXT.text = ""
				end
			elseif v.name == "invoker_emp" then
				if v.cd > 0 then
					local cd = mathfloor(v.cd)+1
					empButtonTEXT.text = tostring(cd)
					if cd >= 10 then
						local sizeX = (textFont:GetTextSize(empButtonTEXT.text).x)
						empButtonTEXT.x = empButton.x + empButton.h/2 - sizeX/2
					else
						local sizeX = (textFont:GetTextSize(empButtonTEXT.text).x)
						empButtonTEXT.x = empButton.x + empButton.h/2 - sizeX/2
					end
				else
					empButtonTEXT.text = ""
				end
			elseif v.name == "invoker_ghost_walk" then
				if v.cd > 0 then
					local cd = mathfloor(v.cd)+1
					ghostwalkButtonTEXT.text = tostring(cd)
					if cd >= 10 then
						local sizeX = (textFont:GetTextSize(ghostwalkButtonTEXT.text).x)
						ghostwalkButtonTEXT.x = ghostwalkButton.x + ghostwalkButton.h/2 - sizeX/2
					else
						local sizeX = (textFont:GetTextSize(ghostwalkButtonTEXT.text).x)
						ghostwalkButtonTEXT.x = ghostwalkButton.x + ghostwalkButton.h/2 - sizeX/2
					end
				else
					ghostwalkButtonTEXT.text = ""
				end
			end
		end
	end	
		
	if me.health < me.maxHealth*0.4 and not retreat and tempvictim then
		if not statusText2.visible then
			statusText2.text = "Hold "..string.char(config.Retreat).." to retreat!"
			local sizeX = (F14:GetTextSize(statusText2.text).x)/2
			statusText2.x = -sizeX
			statusText2.y = -60*monitor
			statusText2.entity = me
			statusText2.entityPosition = Vector(0,0,me.healthbarOffset)
			statusText2.visible = true
		end
	elseif statusText2.visible then
		statusText2.visible = false
	end
	
	if SleepCheck("channel") then
		for i = 1, #abilities do
			local v = abilities[i]
			local c = v:GetChannelTime(v.level) or 0
			if v.abilityPhase and c > 0 then
				channelactive = true
				Sleep(v:FindCastPoint()*1000+100,"casting")
				Sleep(v:FindCastPoint()*1000+100,"channel")
				return
			end
		end
	end
	
	if not tempmyhero then	
		myhero = MyHero(me)
	else				
		local range = tempmyhero:GetAttackRange()
		if KeyPressed then	
			if IsKeyDown(config.Retreat) then retreat = true combo = 0 else retreat = false end
			if IsKeyDown(config.Harras) then harras = true else harras = false end
			local CanMove, tempvictimVisible, tempvictimAlive = Animations.CanMove(me), (tempvictim and tempvictim.visible), (tempvictim and tempvictim.alive)
			local a1,a2,a3,a4,a5,a6 = abilities[1],abilities[2],abilities[3],abilities[4],abilities[5],abilities[6]
			--print(a1.name,a2.name,a3.name,a4.name,a5.name,a6.name)
			if resettime then
				resettime = nil	
			end
			
			if not tempvictim or ((not tempvictim.alive or tempvictim.health < 0) and (not targetlock or tempvictim.visible)) then
				if tempvictim then
					indicate[tempvictim.playerId].visible = false
				end
				victim = nil
				tempvictim = nil
				targetlock = false
				enemyHP = nil
			end
			
			local victimdistance = 999999
			--Update my position
			if SleepCheck("blink") then
				mePosition = me.position
			end
			if tempvictim then victimdistance = GetDistance2D(mePosition,tempvictim) end
			--local closeEnemies = entityList:GetEntities(function (v) return (v.type == LuaEntity.TYPE_HERO and not v:IsIllusion() and v.alive and v.team ~= me.team and v ~= tempvictim) end)
			local blink = me:FindItem("item_blink") or me:FindSpell("antimage_blink") or me:FindSpell("queenofpain_blink")
			
			--Get Target
			if not targetlock and (CanMove or not start or (not tempvictim or victimdistance > mathmax(range+50,500) or not tempvictimAlive or tempvictim.health < 0)) then
				start = true
				local type = "phys"
				if ID == CDOTA_Unit_Hero_Invoker or ID == CDOTA_Unit_Hero_EarthSpirit or ID == CDOTA_Unit_Hero_Lina or ID == CDOTA_Unit_Hero_Lion or ID == CDOTA_Unit_Hero_Zuus or ID == CDOTA_Unit_Hero_Tinker then type = "magic" end
				local lowestHP = targetFind:GetLowestEHP(config.TargetFindRange, type)
				if config.TargetLowestHP and lowestHP and (not tempvictim or ((tempvictim.creep or (GetDistance2D(me,tempvictim) > 600 and tempvictimVisible) or not tempvictimAlive or tempvictim.health < 0 or (lowestHP.health < tempvictim.health and tempvictimVisible)) and GetDistance2D(tempvictim,me) > range+100)) and SleepCheck("victim") then			
					victim = lowestHP
					enemyHP = victim.health
				end
				tempvictim = victim
				if (config.TargetClosestToMouse and tempvictim and GetDistance2D(tempvictim,me) > range+100 and tempvictimVisible) or (config.TargetClosestToMouse and not config.TargetLowestHP) or (tempvictim and (GetDistance2D(tempvictim,me) > range+100 or not tempvictimVisible)) then
					local closest = targetFind:GetClosestToMouse(me,config.TargetFindRange)
					if closest and (config.TargetClosestToMouse or (GetDistance2D(me,closest) < GetDistance2D(me,tempvictim) and GetDistance2D(me,tempvictim) > range+100 and (not blink or (not blink:CanBeCasted() and blink.cd > 3)))) then 
						victim = closest
						enemyHP = victim.health
					end
				end
				tempvictim = victim
				-- if not tempvictim or not tempvictim.hero then 					
					-- local creeps = entityList:GetEntities(function (v) return (v.courier or (v.creep and v.spawned) or (v.classId == CDOTA_BaseNPC_Creep_Neutral and v.spawned) or v.classId == CDOTA_BaseNPC_Tower or v.classId == CDOTA_BaseNPC_Venomancer_PlagueWard or v.classId == CDOTA_BaseNPC_Warlock_Golem or (v.classId == CDOTA_BaseNPC_Creep_Lane and v.spawned) or (v.classId == CDOTA_BaseNPC_Creep_Siege and v.spawned) or v.classId == CDOTA_Unit_VisageFamiliar or v.classId == CDOTA_Unit_Undying_Zombie or v.classId == CDOTA_Unit_SpiritBear or v.classId == CDOTA_Unit_Broodmother_Spiderling or v.classId == CDOTA_Unit_Hero_Beastmaster_Boar or v.classId == CDOTA_BaseNPC_Invoker_Forged_Spirit or v.classId == CDOTA_BaseNPC_Creep) and v.team ~= me.team and v.alive and v.health > 0 and GetDistance2D(v,me) <= mathmax(range*2+50,500) end)
					-- if GetType(creeps) == "Table" then
						-- tablesort(creeps, function (a,b) return a.health < b.health end)
						-- victim = creeps[1]
					-- end
				-- end
				-- tempvictim = victim
			end
			
			if tempvictim then
				anientiCount = 2
				Animations.entities[2] = tempvictim
				if indicate[tempvictim.playerId] then
					if not indicate[tempvictim.playerId].visible then
						 indicate[tempvictim.playerId].visible = true
					end
				else
					local xx = GetXX(tempvictim)
					x,y,h,w = xx-20+x_*tempvictim.playerId,0,x_,35*monitor
					indicate[tempvictim.playerId] = drawMgr:CreateRect(x,y,h,w,9911861800) 
				end
				for i = 1, 9 do	
					local v = indicate[i]
					if v and v.visible and i ~= tempvictim.playerId then
						indicate[i].visible = false
					end
				end
			end
			
			--Update target's health
			if tempvictim and enemyHP and tempvictim.health < enemyHP then enemyHP = tempvictim.health end
			if tempvictim and enemyHP and SleepCheck("casting") and tempvictim.health > enemyHP+200 then enemyHP = tempvictim.health end
			if not enemyHP and tempvictim then enemyHP = tempvictim.health end			
			--Update channeling status
			if me:IsChanneling() then channelactive = true end
			if SleepCheck("casting") and SleepCheck("channel") and not me:IsChanneling() then channelactive = false end
			--Pudge: Enable/Disable Rot
			local PudgeRot = me:FindSpell("pudge_rot")		
			if me:CanCast() and PudgeRot then
				if PudgeRot and PudgeRot:CanBeCasted() then
					if SleepCheck("rot2") and tempvictim and (victimdistance <= 350 or (tempvictim and tempvictim:DoesHaveModifier("modifier_pudge_meat_hook"))) and tempvictimVisible and tempvictimAlive and tempvictim.hero and not me:DoesHaveModifier("modifier_pudge_rot") and not tempvictim:DoesHaveModifier("modifier_pudge_rot") then
						me:SafeCastAbility(PudgeRot)
						Sleep(2000,"rot")
						Sleep(300,"rot2")
						return
					elseif SleepCheck("rot") and (not tempvictim or not tempvictimAlive or not tempvictimVisible or victimdistance > 350) and me:DoesHaveModifier("modifier_pudge_rot") then
						me:SafeCastAbility(PudgeRot)
						Sleep(500,"rot")
						return
					end
				end
			end
			--Armlet: Auto toggle
			if me:DoesHaveModifier("modifier_item_armlet_unholy_strength") and SleepCheck("item_armlet") and me:CanCast() then
				if (not tempvictim or victimdistance > 500 or not tempvictimVisible) and not retreat then
					me:CastItem("item_armlet")
					if tempvictim then
						local delay = mathmin(Animations.GetAttackTime(tempvictim)*1000 + Animations.getBackswingTime(tempvictim)*1000, 500)
						Sleep(Animations.GetAttackTime(tempvictim)*1000 + Animations.getBackswingTime(tempvictim)*1000,"item_armlet")
					else
						Sleep(1000,"item_armlet")
					end
					return
				elseif (tempvictim or retreat) and me.health < 250 and ((Animations.CanMove(tempvictim) or ((not tempvictim or victimdistance > tempvictim.attackRange+100 or not tempvictimVisible) and (not Animations.isAttacking(tempvictim) or tempvictim:GetTurnTime(me) > 0)) or me.health <= me:DamageTaken((tempvictim.dmgMax+tempvictim.dmgMin)/2, DAMAGE_PHYS, tempvictim)) or retreat) then
					me:CastItem("item_armlet")
					me:CastItem("item_armlet")
					if tempvictim then 
						local delay = mathmin(Animations.GetAttackTime(tempvictim)*1000 + Animations.getBackswingTime(tempvictim)*1000, 500)
						Sleep(Animations.GetAttackTime(tempvictim)*1000 + Animations.getBackswingTime(tempvictim)*1000,"item_armlet")
					else
						Sleep(1000,"item_armlet")
					end
					return
				end
			end	
			--Tusk Auto Snowball add
			if me:DoesHaveModifier("modifier_tusk_snowball_movement") or tuskSnowBall then	
				local closeAllies = entityList:GetEntities(function (v) return (v.hero or v.classId == CDOTA_BaseNPC_Invoker_Forged_Spirit or v.classId == CDOTA_Unit_SpiritBear or v.classId == CDOTA_BaseNPC_Warlock_Golem or v.classId == CDOTA_Unit_Broodmother_Spiderling) and v.GetDistance2D and v.alive and v.visible and v.team == me.team and v ~= me and not v:IsAttackImmune() and not v:IsInvul() and GetDistance2D(me,v) < 500 and not v:DoesHaveModifier("modifier_tusk_snowball_movement_friendly") end) 
				if #closeAllies > 0 then
					for i = 1, #closeAllies do	
						local v = closeAllies[i]
						if v and not v:IsAttackImmune() and not v:IsInvul() and SleepCheck(v.handle.."tusk") and SleepCheck("tusk") then
							me:Attack(v)
							Sleep(100,v.handle.."tusk")
							Sleep(25,"tusk")
							return
						end
					end
				else
					tuskSnowBall = false
				end
			end
			--Spirit Breaker: Anti Charge canceling
			if ID == CDOTA_Unit_Hero_SpiritBreaker or ID == CDOTA_Unit_Hero_Rubick then
				local charge = a1
				if ID == CDOTA_Unit_Hero_Rubick then charge = a4 end
				if charge and charge.abilityPhase and SleepCheck("charge") then
					Sleep(1000,"charge")
				end
			end
			local glimpsePos = false
			if disruptor then
				local glimpse = disruptor:FindSpell("disruptor_glimpse")
				local gcd = glimpse:GetCooldown(glimpse.level)
				gcd = gcd - 1.8 - client.latency/1000
				if glimpse.cd > gcd then glimpsePos = true else glimpsePos = false end
			end
			if tempvictim and (tempvictim:DoesHaveModifier("modifier_kunkka_x_marks_the_spot") or glimpsePos) then
				if not xposition then 
					if glimpsePos then
						if positionsTable[tempvictim.handle] then
							--local modif = tempvictim:FindModifier("modifier_disruptor_glimpse")
							local pos = positionsTable[tempvictim.handle]
							local time = gameTime-4
							local closest = nil
							local closesttime = nil
							for i,v in pairs(pos) do
								if not closest or math.abs(time-i) < closesttime then
									closest = v
									closesttime = math.abs(time-i)
								end
							end
							if closest then xposition = closest end
						end
					else
						xposition = tempvictim.position 
					end
				end
			elseif xposition and SleepCheck("kunkka_x_marks_the_spot") and not glimpsePos and SleepCheck("disruptor_glimpse") and not a3.abilityPhase and a3.name ~= "kunkka_return" then xposition = nil end
			-- if xposition then
				-- if not eff then 
					-- eff = Effect(xposition, "range_display" )
					-- eff:SetVector(1,Vector(500,0,0))
					-- eff:SetVector(0, xposition )
				-- else
					-- eff:SetVector(0, xposition )
				-- end
			-- end
			--Special Combo: Kunkka
			if ID == CDOTA_Unit_Hero_Kunkka and tempvictim then
				local torrent = a1
				local x_mark = a3	
				if x_mark.name == "kunkka_return" or xposition then
					if xposition and torrent.cd ~= 0 and mathfloor(torrent.cd*10) == 90 + mathfloor((client.latency/100)) and SleepCheck("casting2") and me:CanCast() then
						me:CastAbility(x_mark)
						Sleep(200+client.latency, "casting2")
						Sleep(200+client.latency, "casting")
						return
					end
					local ship = a4
					if torrent.cd ~= 0 and SleepCheck("casting") and ship:CanBeCasted() and me:CanCast() and xposition and GetDistance2D(me,xposition) > 750 then
						me:CastAbility(ship, xposition)
						local Dmg 
						if tempdamageTable[ship.name] then
							Dmg = tempdamageTable[ship.name][1]
							Dmg = tempvictim:DamageTaken(Dmg,DAMAGE_MAGC,me)
							enemyHP = enemyHP - Dmg
						end
						Sleep(ship:FindCastPoint()*1000+me:GetTurnTime(xposition)*1000,"casting")
						Sleep(ship:FindCastPoint()*1000+me:GetTurnTime(xposition)*1000,"moving")
						Sleep(6000,"stun")
						return
					end
				elseif xposition and SleepCheck("kunkka_x_marks_the_spot") and not x_mark.abilityPhase then
					xposition = nil
				end
			end
			if me:IsChanneling() or channelactive then 
				local glimmer_cape = me:FindItem("item_glimmer_cape")
				if glimmer_cape and glimmer_cape:CanBeCasted() and SleepCheck("glim") then
					me:CastAbility(glimmer_cape,me)
					Sleep(200,"glim")
				end
				return
			end
			local quas, wex, exort, spell1, spell2
			local prediction 
			if tempvictim and tempvictimVisible then
				prediction = SkillShotPredictedXYZ(tempvictim,500+client.latency)	
			elseif tempvictim then prediction = SkillShot.BlindSkillShotXYZ(me,tempvictim,1100,0.5+client.latency/1000) end
			if not prediction and tempvictim and tempvictimVisible then prediction = tempvictim.position end
			--print(prediction)
			local movespeed
			if tempvictim then movespeed = tempvictim.movespeed end
			if tempvictim and tempvictim.visible then
				if tempvictim.activity == LuaEntityNPC.ACTIVITY_MOVE then
					local pred = SkillShot.PredictedXYZ(tempvictim,1000)
					if pred then
						movespeed = GetDistance2D(tempvictim,pred)
					end
				end
			end
			local facing
			if tempvictim then
				facing = ((mathmax(mathabs(FindAngleR(me) - mathrad(FindAngleBetween(me, tempvictim))) - 0.20, 0)) == 0)
			end
			--Wips: Auto Aim with spirits
			if me:DoesHaveModifier("modifier_wisp_spirits") and tempvictim then
				local spirits = entityList:GetEntities({classId=CDOTA_Wisp_Spirit,alive=true,team=me.team,visible=true})
				tablesort(spirits, function (a,b) return a.handle > b.handle end)
				local spirit = nil
				for i = 1, #spirits do
					local v = spirits[i]
					if GetDistance2D(me,v) < 900 then spirit = v break end
				end
				if spirit then
					local spiritsin = me:FindSpell("wisp_spirits_in")
					local spiritsout = me:FindSpell("wisp_spirits_out")
					local mepred = SkillShotPredictedXYZ(me,client.latency)
					local vicpred = SkillShotPredictedXYZ(tempvictim,client.latency)
					if not tempvictimVisible then vicpred = SkillShot.BlindSkillShotXYZ(me,tempvictim,1100,client.latency/1000) end
					local dist = GetDistance2D(spirit,me)
					local vicdist = GetDistance2D(mepred,vicpred)
					if mathabs(dist-vicdist) < 100 then
						if spiritsin.toggled and SleepCheck("in") then me:SafeCastAbility(spiritsin) Sleep(250,"in")
						elseif spiritsout.toggled and SleepCheck("out") then me:SafeCastAbility(spiritsout) Sleep(250,"out") end
					elseif dist > vicdist and SleepCheck("in") and not spiritsin.toggled then me:SafeCastAbility(spiritsin) Sleep(250,"in")
					elseif dist < vicdist and SleepCheck("out") and not spiritsout.toggled then me:SafeCastAbility(spiritsout) Sleep(250,"out") end
				end
			end
			
			--Pudge hook cancel if no target
			if ID == CDOTA_Unit_Hero_Pudge and a1.abilityPhase and (not tempvictim or not tempvictimAlive) then
				me:Stop()
			end
			
			--SkillShots Canceling 
			if prediction then
				if not lastPrediction then lastPrediction = {prediction, tempvictim.rotR}
				elseif not tempvictim:DoesHaveModifier("modifier_eul_cyclone") and not tempvictim:DoesHaveModifier("modifier_invoker_tornado") then
					if ID == CDOTA_Unit_Hero_Pudge and not SleepCheck("pudge_meat_hook") then
						local hook = a1
						if hook.abilityPhase and ((GetDistance2D(lastPrediction[1],prediction) > mathabs(GetDistance2D(tempvictim,lastPrediction[1])-150) and mathabs((tempvictim.rotR) - lastPrediction[2]) > 0.5) or SkillShot.__GetBlock(me.position,lastPrediction[1],tempvictim,100,true)) then
							me:Stop()
						end
					elseif ID == CDOTA_Unit_Hero_Mirana and not SleepCheck("mirana_arrow") then
						local arrow = a2
						if arrow.abilityPhase and ((GetDistance2D(lastPrediction[1],prediction) > mathabs(GetDistance2D(tempvictim,lastPrediction[1])-115) and mathabs((tempvictim.rotR) - lastPrediction[2]) > 0.3) or SkillShot.__GetBlock(me.position,lastPrediction[1],tempvictim,115,false)) then
							me:Stop()
						end
					elseif ID == CDOTA_Unit_Hero_Rattletrap and not SleepCheck("rattletrap_hookshot") then
						local hookshot = a4
						if hookshot.abilityPhase and ((GetDistance2D(lastPrediction[1],prediction) > mathabs(GetDistance2D(tempvictim,lastPrediction[1])-125) and mathabs((tempvictim.rotR) - lastPrediction[2]) > 0.3) or SkillShot.__GetBlock(me.position,lastPrediction[1],tempvictim,125,true)) then
							me:Stop()
						end
					elseif ID == CDOTA_Unit_Hero_Lina and not SleepCheck("lina_light_strike_array") then
						local LightStrike = a2
						if LightStrike.abilityPhase and GetDistance2D(lastPrediction[1],prediction) > mathabs(GetDistance2D(tempvictim,lastPrediction[1])+112) then
							me:Stop()
						end
					elseif ID == CDOTA_Unit_Hero_Leshrac and not SleepCheck("leshrac_split_earth") then
						local SplitEarth = a1
						local radius = SplitEarth:GetSpecialData("radius")
						if SplitEarth.abilityPhase and GetDistance2D(lastPrediction[1],prediction) > radius+50 then
							me:Stop()
						end
					elseif ID == CDOTA_Unit_Hero_Sniper and not SleepCheck("sniper_shrapnel") then
						local shrapnel = a1
						local radius = shrapnel:GetSpecialData("radius")
						if shrapnel.abilityPhase and GetDistance2D(lastPrediction[1],prediction) > mathabs(GetDistance2D(tempvictim,lastPrediction[1])-radius/2) then
							me:Stop()
						end
					elseif ID == CDOTA_Unit_Hero_Kunkka and not SleepCheck("kunkka_torrent") and not xposition then
						local torrent = a1
						if torrent.abilityPhase and GetDistance2D(lastPrediction[1],prediction) > mathabs(GetDistance2D(tempvictim,lastPrediction[1])) then
							me:Stop()
						end
					elseif ID == CDOTA_Unit_Hero_Nevermore then
						if not SleepCheck("nevermore_shadowraze1") then
							local raze = a1
							if raze.abilityPhase and (GetDistance2D(lastPrediction[1],tempvictim) > 275 or me:GetTurnTime(lastPrediction[1]) > 0.01) then
								me:Stop()
							end
						elseif not SleepCheck("nevermore_shadowraze2") then
							local raze = a2
							if raze.abilityPhase and (GetDistance2D(lastPrediction[1],tempvictim) > 275 or me:GetTurnTime(lastPrediction[1]) > 0.01) then
								me:Stop()
							end
						elseif not SleepCheck("nevermore_shadowraze3") then
							local raze = a3
							if raze.abilityPhase and (GetDistance2D(lastPrediction[1],tempvictim) > 275 or me:GetTurnTime(lastPrediction[1]) > 0.01) then
								me:Stop()
							end
						end
					end
				end
			end
			local closestTrap = nil
			local meld, refraction
			local meDmg = 0
			if tempvictim then meDmg = tempvictim:DamageTaken((me.dmgMin + me.dmgMax)/2,DAMAGE_PHYS,me) end
			--Special Combo: Templar Assassin
			if ID == CDOTA_Unit_Hero_TemplarAssassin or ID == CDOTA_Unit_Hero_Rubick then
				if ID == CDOTA_Unit_Hero_TemplarAssassin then
					meld,refraction = a2,a1
				else
					meld,refraction = me:FindSpell("templar_assassin_meld"), me:FindSpell("templar_assassin_refraction")
				end
				local traps = entityList:GetEntities({classId=CDOTA_BaseNPC_Additive,alive=true,team=me.team,visible=true})
				for i = 1, #traps do
					local v = traps[i]
					local spell = v:GetAbility(1)
					if (spell and spell.name == "templar_assassin_self_trap" and spell:CanBeCasted()) then
						if not closestTrap or GetDistance2D(closestTrap, tempvictim) > GetDistance2D(v, tempvictim) then
							if GetDistance2D(v, tempvictim) <= 400 then
								closestTrap = v
							end
							if closestTrap and GetDistance2D(closestTrap, tempvictim) > 400 then
								closestTrap = nil
							end
						end
					end
				end
				local trap = a5
				if ID == CDOTA_Unit_Hero_Rubick then trap = me:FindSpell("templar_assassin_psionic_trap") end
				if trap and tempvictim and (not harras or victimdistance < range+100) and tempvictim.hero and CanBeSlowed(tempvictim) and (tempvictim and tempvictim:CanMove() and tempvictim.activity == LuaEntityNPC.ACTIVITY_MOVE) and (meDmg*2 < enemyHP or victimdistance > range) then
					local trapslow = tempvictim:FindModifier("modifier_templar_assassin_trap_slow")
					if (tempvictim:CanMove() and (not trapslow or trapslow.remainingTime <= (trap:FindCastPoint()*1.5 + client.latency/1000))) and chainStun(tempvictim,trap:FindCastPoint()+client.latency/1000) then
						if (closestTrap and GetDistance2D(closestTrap, tempvictim) <= 400) and SleepCheck("trap2") then
							local boom = closestTrap:GetAbility(1)
							if boom:CanBeCasted() then
								closestTrap:SafeCastAbility(boom)
								Sleep(trap:FindCastPoint()*1000 + 200 + client.latency, "trap2")
								Sleep(trap:FindCastPoint()*1000 + 200 + client.latency, "trap")
							end
						elseif not ((blink and blink:CanBeCasted()) and (prediction and GetDistance2D(prediction,me) > 500 and GetDistance2D(prediction,me) > range+50 and GetDistance2D(prediction,me) < 1700)) and (not a2 or not a2:CanBeCasted() or victimdistance > range+100) and me:CanCast() and victimdistance <= trap.castRange+375 and (not trapslow or trapslow.remainingTime <= (trap:FindCastPoint()*1.5)) and SleepCheck("trap") and trap:CanBeCasted() and chainStun(tempvictim,trap:FindCastPoint()+client.latency/1000) and SleepCheck("casting") and (not meld or not meld:CanBeCasted() or GetDistance2D(me,prediction)+50 > range) then
							local prediction = SkillShotPredictedXYZ(tempvictim,me:GetTurnTime(tempvictim)*1000+trap:FindCastPoint()*2000+client.latency)	
							local pos
							if tempvictimVisible then
								pos = prediction
								me:SafeCastAbility(trap, prediction)
							else
								local blind = SkillShot.BlindSkillShotXYZ(me,tempvictim,1100,trap:FindCastPoint()+client.latency/1000)
								if blind then
									pos = blind
									me:SafeCastAbility(trap, blind)
								else
									pos = Vector(tempvictim.position.x + (movespeed * (trap:FindCastPoint() + client.latency/1000) + 100) * mathcos(tempvictim.rotR), tempvictim.position.y + (movespeed * (trap:FindCastPoint() + client.latency/1000) + 100) * mathsin(tempvictim.rotR), tempvictim.position.z)
									me:SafeCastAbility(trap, pos)
								end
							end
							Sleep(trap:FindCastPoint()*1000 + me:GetTurnTime(pos)*1000 + 100, "casting")
							Sleep(trap:FindCastPoint()*1000 + me:GetTurnTime(pos)*1000, "moving")
							Sleep(trap:FindCastPoint()*1000 + 200 + client.latency, "trap")
							return
						end
					end
				end
			end
			--Special Combo: Brewmaster Ultimate
			if ID == CDOTA_Unit_Hero_Brewmaster or ID == CDOTA_Unit_Hero_Rubick then
				local ulti = a4
				if ID == CDOTA_Unit_Hero_Rubick then ulti = me:FindSpell("brewmaster_primal_split") end
				if ulti and ulti.cd > 0 then
					local dur = ulti:GetSpecialData("duration")
					if ulti.cd+dur > ulti:GetCooldown(ulti.level) then
						local splits = entityList:GetEntities(function (ent) return (ent.classId == CDOTA_Unit_Brewmaster_PrimalEarth or ent.classId == CDOTA_Unit_Brewmaster_PrimalFire or ent.classId == CDOTA_Unit_Brewmaster_PrimalStorm) and ent.controllable and ent.alive end)
						local BrewmasterComboTable = {
							{ CDOTA_Unit_Brewmaster_PrimalEarth, {{ 1, nil, true}, { 4, "radius", true }} },
							{ CDOTA_Unit_Brewmaster_PrimalStorm, {{ 4, nil, true}, { 1 }, { 3, 650 }} }
						}
						local l = #BrewmasterComboTable
						for z = 1, #splits do
							local split = splits[z]
							anientiCount = anientiCount + 1
							Animations.entities[anientiCount] = split
							local hand = split.handle
							if tempvictim and tempvictim.hero and tempvictimVisible then
								for i = 1, l do
									local table = BrewmasterComboTable[i]
									if table[1] == split.classId then
										local t2 = table[2]
										local l2 = #t2
										for i = 1, l2 do
											local data = t2[i]
											local slot = data[1] or data
											if slot then
												local spell
												if GetType(slot) == "string" then
													spell = split:FindSpell(slot)
												else
													spell = split:GetAbility(slot)
												end	
												if spell and spell:CanBeCasted() then
													local speed = spell:GetSpecialData("speed",spell.level)
													local range = spell.castRange
													if data[2] then
														distance = data[2]
													end
													local victimdistance = GetDistance2D(split,tempvictim)
													if distance then
														if GetType(distance) == "string" then
															distance = spell:GetSpecialData(distance,spell.level)
														end
													end
													local delay = spell:FindCastPoint()*1000
													local delay2 = delay/1000 + client.latency/1000
													local prediction = SkillShotPredictedXYZ(tempvictim,mathmax(delay, 100)+client.latency)
													if speed then delay2 = delay2 + (mathmin(range-50, GetDistance2D(split,prediction))/speed) end
													local cast = nil
													if SleepCheck(hand.."casting") and SleepCheck(hand..""..spell.name) and (not data[3] or chainStun(tempvictim, delay2)) then
														if spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_UNIT_TARGET) then
															if spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALLIED) and not DoesHaveModifier("modifier_"..spell.name) and not DoesHaveModifier("modifier_"..spell.name.."_debuff") and not spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALL) then
																cast = split:SafeCastAbility(spell,split)
															elseif (spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ENEMY) or spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_CUSTOM) or spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALL)) and not tempvictim:IsInvul() and not tempvictim:DoesHaveModifier("modifier_eul_cyclone") and not tempvictim:DoesHaveModifier("modifier_invoker_tornado") and not tempvictim:DoesHaveModifier("modifier_brewmaster_storm_cyclone") and victimdistance < mathmax(spell.castRange+500, 1000) and not tempvictim:DoesHaveModifier("modifier_"..spell.name) and not tempvictim:DoesHaveModifier("modifier_"..spell.name.."_debuff") then
																cast = split:SafeCastAbility(spell,tempvictim)
																delay = delay + split:GetTurnTime(tempvictim)*1000 + (mathmax(victimdistance-50-range,0)/split.movespeed)*1000
															end
														elseif spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NO_TARGET) and tempvictimVisible and not tempvictim:DoesHaveModifier("modifier_"..spell.name) 
														and (spell.name ~= "brewmaster_storm_wind_walk" or GetDistance2D(split,prediction) < distance) and (spell.name ~= "brewmaster_thunder_clap" or (prediction and GetDistance2D(split,prediction) < distance)) and not tempvictim:DoesHaveModifier("modifier_"..spell.name.."_debuff") and not DoesHaveModifier("modifier_"..spell.name) and not DoesHaveModifier("modifier_"..spell.name.."_debuff") then												
															cast = split:SafeCastAbility(spell)
														elseif spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_POINT) or spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_AOE) then
															if spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALLIED) and not spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ENEMY) then
																cast = split:SafeCastAbility(spell,split)
															else
																delay = delay + split:GetTurnTime(tempvictim)*1000
																local delay2 = delay + client.latency
																if data[2] then delay2 = delay2 + data[2]*1000 end
																local speed = spell:GetSpecialData("speed")
																local prediction
																if not speed then 
																	prediction = SkillShotPredictedXYZ(tempvictim,delay2)
																else
																	prediction = SkillShotSkillShotXYZ(mePosition,tempvictim,delay2,speed)
																end
																if prediction and GetDistance2D(prediction,mePosition) < spell.castRange+150 then
																	delay = delay + (mathmax(GetDistance2D(prediction,mePosition)-50-spell.castRange,0)/split.movespeed)*1000
																	cast = split:SafeCastAbility(spell,prediction)
																end
															end
														end
															
														if cast then
															if tempdamageTable[spell.name] then
																local Dmg = tempdamageTable[spell.name][1]
																Dmg = tempvictim:DamageTaken(Dmg,DAMAGE_MAGC,me)
																enemyHP = enemyHP - Dmg
															end
															if data[3] then Sleep(delay+300+client.latency,"stun") end
															Sleep(delay,hand.."casting")
															Sleep(delay,hand.."moving")
															Sleep(delay+client.latency+100, hand..""..spell.name)
														end
													end
												end
											end
										end
									end
								end
							end

							if not retreat and tempvictim and not Animations.CanMove(split) and GetDistance2D(split,tempvictim) <= mathmax(split.attackRange*2+50,500) and not tempvictim:IsInvul() and split:CanAttack() and not tempvictim:IsAttackImmune() and not tempvictim:DoesHaveModifier("modifier_bane_nightmare") then	
								if SleepCheck(hand.."moving") and SleepCheck(hand.."attack") then
									if not tempvictim:IsInvul() and not tempvictim:IsAttackImmune() and not tempvictim:DoesHaveModifier("modifier_bane_nightmare") then
										split:Attack(tempvictim)
										if GetDistance2D(split,tempvictim) < split.attackRange+50 then
											enemyHP = enemyHP - tempvictim:DamageTaken((split.dmgMin + split.dmgMax)/2,DAMAGE_PHYS,split)
										end
									else
										split:Follow(tempvictim)
									end
									Sleep(Animations.GetAttackTime(split)*1000,hand.."attack")
								end
							elseif not targetlock and SleepCheck(hand.."moving") and SleepCheck(hand.."move") then
								local mPos = client.mousePosition
								if retreat or (((not tempvictim or (GetDistance2D(split,mPos) > 300 and tempvictimVisible and GetDistance2D(tempvictim,split) < 1000))) and (not tempvictim or (tempvictimVisible and GetDistance2D(tempvictim,split) < 1000))) then
									split:Move(mPos)
								elseif prediction and GetDistance2D(prediction,split) < split.attackRange and (GetDistance2D(split,tempvictim)-range)/movespeed > Animations.getBackswingTime(split) then
									if not tempvictim:IsInvul() and split:CanAttack() and not tempvictim:IsAttackImmune() and not tempvictim:DoesHaveModifier("modifier_bane_nightmare") and (not tempvictim:CanMove() or GetDistance2D(split,prediction)-100 < GetDistance2D(split,tempvictim)) then
										split:Attack(tempvictim)
									else
										split:Move(mPos)
									end
								else
									split:Follow(tempvictim)
								end
								Sleep(Animations.getBackswingTime(split)*1000,hand.."move")
							end
						end
						return 
					end
				end
			end			
			--Special Combo: Controlling Summons/Neutrals
			-- local summons = entityList:GetEntities(function (v) return ((v.classId == CDOTA_BaseNPC_Invoker_Forged_Spirit or v.classId == CDOTA_Unit_Broodmother_Spiderling or v.classId == CDOTA_Unit_SpiritBear or v.classId == CDOTA_Unit_VisageFamiliar or 
			-- v.classId == CDOTA_BaseNPC_Creep_Neutral or v.classId == CDOTA_Unit_Hero_Beastmaster_Beasts or v.classId == CDOTA_Unit_Broodmother_Spiderling or v.name == "npc_dota_necronomicon_archer_1" or v.name == "npc_dota_necronomicon_archer_2" or v.name == "npc_dota_necronomicon_archer_3" or v.name == "npc_dota_necronomicon_warrior_1" or 
			-- v.name == "npc_dota_necronomicon_warrior_2" or v.name == "npc_dota_necronomicon_warrior_3" or (v.type == LuaEntity.TYPE_HERO and v:IsIllusion())) and v.alive and v.controllable and v.team == me.team) end)
			local entities = {}
			local spider,boar,forg,familiars,bear,necorwarriors,spirit,sigil,treants,golems = {},{},{},{},nil,{},nil,nil,{},{}
			if ID == CDOTA_Unit_Hero_Broodmother or ID == CDOTA_Unit_Hero_Rubick then
				spider = entityList:GetEntities({classId=CDOTA_Unit_Broodmother_Spiderling,alive=true,visible=true,team=me.team})
			elseif ID == CDOTA_Unit_Hero_Beastmaster or ID == CDOTA_Unit_Hero_Rubick then
				boar = entityList:GetEntities({classId=CDOTA_Unit_Hero_Beastmaster_Beasts,alive=true,visible=true,team=me.team})
			elseif ID == CDOTA_Unit_Hero_Invoker or ID == CDOTA_Unit_Hero_Rubick then
				forg = entityList:GetEntities({classId=CDOTA_BaseNPC_Invoker_Forged_Spirit,alive=true,visible=true,team=me.team})
			elseif ID == CDOTA_Unit_Hero_Visage or ID == CDOTA_Unit_Hero_Rubick then
				familiars = entityList:GetEntities({classId=CDOTA_Unit_VisageFamiliar,alive=true,visible=true,team=me.team})
			elseif ID == CDOTA_Unit_Hero_LoneDruid or ID == CDOTA_Unit_Hero_Rubick then
				bear = entityList:GetEntities({classId=CDOTA_Unit_SpiritBear,alive=true,team=me.team})[1]
			-- elseif ID == CDOTA_Unit_Hero_Elder_Titan then
				-- spirit = entityList:GetEntities({classId=CDOTA_Unit_Elder_Titan_AncestralSpirit, alive=true, team=me.team, visible=true})[1]
			elseif ID == CDOTA_Unit_Hero_Tusk or ID == CDOTA_Unit_Hero_Rubick then
				sigil = entityList:GetEntities({classId=CDOTA_BaseNPC_Tusk_Sigil,alive=true,team=me.team})[1]
			elseif ID == CDOTA_Unit_Hero_Furion or ID == CDOTA_Unit_Hero_Rubick then
				treants = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep,alive = true, visible = true, team = me.team})	
			elseif ID == CDOTA_Unit_Hero_Warlock or ID == CDOTA_Unit_Hero_Rubick then
				golems = entityList:GetEntities({classId=CDOTA_BaseNPC_Warlock_Golem,alive=true,team=me.team,visible=true})
			end
			local tornado = entityList:GetEntities(function (v) return (v.name == "npc_dota_enraged_wildkin_tornado" and v.alive and v.visible and v.team == me.team and v.controllable) end)[1]
			local heroes = entityList:GetEntities({type=LuaEntity.TYPE_HERO,alive=true,visible=true,illusion=true,team=me.team})
			local neutral = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Neutral,alive=true,visible=true,team=me.team})
			if me:FindItem("item_necronomicon_2") or me:FindItem("item_necronomicon_1") or me:FindItem("item_necronomicon_3") then
				necorwarriors = entityList:GetEntities(function (v) return ((v.name == "npc_dota_necronomicon_archer_1" or v.name == "npc_dota_necronomicon_archer_2" or v.name == "npc_dota_necronomicon_archer_3" or v.name == "npc_dota_necronomicon_warrior_1" or 
				v.name == "npc_dota_necronomicon_warrior_2" or v.name == "npc_dota_necronomicon_warrior_3") and v.alive and v.visible and v.team == me.team and v.controllable) end)
			end
			local entitiesCount = 0
			for i = 1, #heroes do local v = heroes[i] if v.controllable and v:IsIllusion() then entitiesCount = entitiesCount + 1 entities[entitiesCount] = v end end
			for i = 1, #necorwarriors do local v = necorwarriors[i] if v.controllable then entitiesCount = entitiesCount + 1 entities[entitiesCount] = v end end
			for i = 1, #spider do local v = spider[i] if v.controllable then entitiesCount = entitiesCount + 1 entities[entitiesCount] = v end end
			for i = 1, #boar do local v = boar[i] if v.controllable then entitiesCount = entitiesCount + 1 entities[entitiesCount] = v end end
			for i = 1, #forg do local v = forg[i] if v.controllable then entitiesCount = entitiesCount + 1 entities[entitiesCount] = v end end
			for i = 1, #neutral do local v = neutral[i] if v.controllable then entitiesCount = entitiesCount + 1 entities[entitiesCount] = v end end
			for i = 1, #familiars do local v = familiars[i] if v.controllable then entitiesCount = entitiesCount + 1 entities[entitiesCount] = v end end
			for i = 1, #treants do local v = treants[i] if v.controllable then entitiesCount = entitiesCount + 1 entities[entitiesCount] = v end end
			for i = 1, #golems do local v = golems[i] if v.controllable then entitiesCount = entitiesCount + 1 entities[entitiesCount] = v end end			
			if bear then entitiesCount = entitiesCount + 1 entities[entitiesCount] = bear end
			if sigil then entitiesCount = entitiesCount + 1 entities[entitiesCount] = sigil end
			--if spirit then entitiesCount = entitiesCount + 1 entities[entitiesCount] = spirit end
			if tornado then entitiesCount = entitiesCount + 1 entities[entitiesCount] = tornado end
			if #entities > 0 then
				local l = #itemcomboTable
				for i = 1, #entities do
					local v = entities[i]
					if v.classId ~= CDOTA_Unit_Elder_Titan_AncestralSpirit and v.name ~= "npc_dota_enraged_wildkin_tornado" and v.classId ~= CDOTA_BaseNPC_Tusk_Sigil then
						anientiCount = anientiCount + 1
						Animations.entities[anientiCount] = v
					end
					local hand = v.handle
					if v.classId == CDOTA_Unit_SpiritBear and tempvictim then
						for i = 1, l do
							local data = itemcomboTable[i]
							local itemname = data[1] or data
							local item = v:FindItem(itemname)
							if item and item:CanBeCasted() then
								if not tempdamageTable[itemname] then
									damageTable[itemname] = {AbilityDamageGetDamage(item)}
									tempdamageTable = damageTable
								end
								local Dmg = tempdamageTable[itemname][1]
								local type = AbilityDamageGetDmgType(item)
								if Dmg then
									Dmg = tempvictim:DamageTaken(Dmg,type,v)
								end
								local go = true
								if itemname == "item_phase_boots" then Dmg = nil end
								if itemname == "item_dust" and not CanGoInvis(tempvictim) then go = false end
								if (itemname == "item_diffusal_blade" or itemname == "item_diffusal_blade_2") then
									if not ( tempvictim:DoesHaveModifier("modifier_ghost_state") or tempvictim:DoesHaveModifier("modifier_item_ethereal_blade_slow") or tempvictim:DoesHaveModifier("modifier_omninight_guardian_angel")) then 
										go = false 
									end
								end
								if itemname == "item_arcane_boots" and (v.maxMana - v.mana) < 135 then go = false end
								if (not tempvictim:IsMagicImmune() or type == DAMAGE_PHYS) and not tempvictim:DoesHaveModifier("modifier_"..itemname) and not tempvictim:DoesHaveModifier("modifier_"..itemname.."_debuff") and go and 
								SleepCheck(itemname) and (not data[2] or chainStun(tempvictim,0) or (itemname == "item_blade_mail" and chainStun(tempvictim,0,"modifier_axe_berserkers_call"))) and 
								(not Dmg or data[2] or Dmg/4 < enemyHP or GetDistance2D(v,tempvictim) > v.attackRange+300) and ((GetDistance2D(v,tempvictim) > v.attackRange+300) or (Dmg and Dmg > 0) or ((not Dmg or Dmg < 1) and enemyHP > 100) or itemname == "item_phase_boots") then
									local cast
									local delay = 0
									if item:IsBehaviourType(LuaEntityAbility.BEHAVIOR_UNIT_TARGET) and go then
										if ((item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALLIED) and not item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ENEMY) and not item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALL))) then
											cast = v:SafeCastAbility(item,v)
										elseif (item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ENEMY) or item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_CUSTOM) or item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALL)) and not tempvictim:IsInvul() and not tempvictim:DoesHaveModifier("modifier_eul_cyclone") and not tempvictim:DoesHaveModifier("modifier_brewmaster_storm_cyclone") and not tempvictim:DoesHaveModifier("modifier_invoker_tornado") and victimdistance < mathmax(item.castRange+50, 500) then
											cast = v:SafeCastAbility(item,tempvictim)
											delay = delay + v:GetTurnTime(tempvictim)*1000
										end
									elseif item:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NO_TARGET) and (not data[3] or GetDistance2D(v,tempvictim) < data[3]) then
										cast = v:SafeCastAbility(item)
									elseif item:IsBehaviourType(LuaEntityAbility.BEHAVIOR_POINT) or item:IsBehaviourType(LuaEntityAbility.BEHAVIOR_AOE) then
										if item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALLIED) and not item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ENEMY) then
											cast = v:SafeCastAbility(item,v)
										else
											delay = delay + v:GetTurnTime(tempvictim)*1000
											local delay2 = delay + client.latency
											if data[2] then delay2 = delay2 + data[2]*1000 end
											local speed = item:GetSpecialData("speed")
											local prediction
											if not speed then 
												prediction = SkillShotPredictedXYZ(tempvictim,delay2)
											else
												prediction = SkillShotSkillShotXYZ(mePosition,tempvictim,delay2,speed)
											end
											if prediction and GetDistance2D(prediction,mePosition) < item.castRange+150 then
												delay = delay + (mathmax(GetDistance2D(prediction,mePosition)-50-item.castRange,0)/v.movespeed)*1000
												cast = v:SafeCastAbility(item,prediction)
											end
										end
									end
									if cast then
										Sleep(delay+client.latency+100, itemname)
										if Dmg then
											enemyHP = enemyHP - Dmg
										end
										return
									end
								end
							end
						end	
					end
					if v:CanCast() and not v:IsChanneling() then
						local abs = v.abilities
						for i = 1, #abs do
							local abi = abs[i]
							if abi:CanBeCasted() and SleepCheck(abi.name) then
								local name = abi.name
								if tempvictim and (name == "necronomicon_archer_mana_burn" or name == "satyr_trickster_purge" or name == "satyr_soulstealer_mana_burn" or name == "satyr_hellcaller_shockwave" or name == "harpy_storm_chain_lightning" or ((name == "mud_golem_hurl_boulder" or name == "dark_troll_warlord_ensnare") and chainStun(tempvictim,abi:FindCastPoint()+(100/Animations.maxCount)*0.001 - ((client.latency/1000)/(1 + (1 - 1/Animations.maxCount)))+v:GetTurnTime(tempvictim)+client.latency*0.01))) then
									v:CastAbility(abi,tempvictim)
									Sleep(abi:FindCastPoint()*1000+v:GetTurnTime(tempvictim)*1000+client.latency,hand.."moving")
									Sleep(600,name)
									if name == "dark_troll_warlord_ensnare" then
										Sleep(abi:FindCastPoint()*1000+client.latency+1000+v:GetTurnTime(tempvictim)*1000,"stun")
									elseif name == "mud_golem_hurl_boulder" then
										Sleep(abi:FindCastPoint()*1000+client.latency+GetDistance2D(v,tempvictim)/800+200+v:GetTurnTime(tempvictim)*1000,"stun")
									end
								elseif tempvictim and name == "enraged_wildkin_tornado" and prediction and GetDistance2D(v,tempvictim) < abi.castRange+100 then
									v:CastAbility(abi,prediction)
									Sleep(abi:FindCastPoint()*1000+v:GetTurnTime(tempvictim)*1000+client.latency+200,hand.."moving")
									Sleep(600,name)
								elseif name == "ogre_magi_frost_armor" then
									local allies = entityList:GetEntities(function (x) return (x.hero and x.alive and not x:IsIllusion() and GetDistance2D(v,x) < 1000 and not x:DoesHaveModifier("modifier_ogre_magi_frost_armor")) end)
									local ally = nil
									if #allies > 0 then
										tablesort(allies, function(a,b) return a.health < b.health end)
										ally = allies[1]
									end
									if ally then
										v:CastAbility(abi,ally)
										Sleep(abi:FindCastPoint()*1000+v:GetTurnTime(ally)*1000+client.latency+500,hand.."moving")
										Sleep(600,name)
									end
								elseif tempvictim and (name == "polar_furbolg_ursa_warrior_thunder_clap" or name == "centaur_khan_war_stomp" or name == "big_thunder_lizard_slam") and chainStun(tempvictim,abi:FindCastPoint()+(100/Animations.maxCount)*0.01 - ((client.latency/1000)/(1 + (1 - 1/Animations.maxCount)))+client.latency*0.001) then
									local radius = abi:GetSpecialData("radius")
									if prediction and GetDistance2D(v,prediction) < radius-50 then
										v:CastAbility(abi)
										Sleep(abi:FindCastPoint()*1000+client.latency,hand.."moving")
										Sleep(600,name)
										if name == "centaur_khan_war_stomp" then
											Sleep(abi:FindCastPoint()*1000+client.latency+1000,"stun")
										end
									elseif SleepCheck(hand.."moving") and prediction then
										v:Move(prediction)
										Sleep(200,hand.."moving")
									end
								elseif tempvictim and name == "visage_summon_familiars_stone_form" then
									if chainStun(tempvictim,0.5+client.latency*0.001+(100/Animations.maxCount)*0.01 - ((client.latency/1000)/(1 + (1 - 1/Animations.maxCount)))) then
										local asd = v:FindModifier("modifier_visage_summon_familiars_damage_charge")
										--print(asd.stacks)
										if (not asd or not asd.stacks or asd.stacks == 0) or retreat or v.health < 8 or tempvictim:IsAttackImmune() then
											--print("ddd")
											local radius = abi:GetSpecialData("stun_radius")
											local prediction = SkillShotPredictedXYZ(tempvictim,500+client.latency+(100/Animations.maxCount)*100 - ((client.latency/1000)/(1 + (1 - 1/Animations.maxCount)))*1000)
											if prediction and GetDistance2D(v,prediction) < radius-50 then
												v:CastAbility(abi)
												Sleep(500+client.latency,hand.."moving")
												Sleep(600,name)
												Sleep(500+client.latency+1000,"stun")
											elseif SleepCheck(hand.."moving") and prediction then
												v:Move(prediction)
												Sleep(200,hand.."moving")
											end
										end
									elseif SleepCheck(hand.."moving") and GetDistance2D(v,tempvictim) > 25 then
										v:Move(tempvictim.position)
										Sleep(200,hand.."moving")
									end									
								elseif tempvictim and name == "elder_titan_echo_stomp_spirit" and chainStun(tempvictim,abi:FindCastPoint()+client.latency*0.001+abi:GetChannelTime(abi.level)) then
									local radius = abi:GetSpecialData("radius")
									if GetDistance2D(v,tempvictim) < radius then
										v:CastAbility(abi)
										Sleep(abi:FindCastPoint()*1000+client.latency,hand.."moving")
										Sleep(600,name)
										Sleep(500,"casting")
										channelactive = true
									end
								elseif tempvictim and name == "big_thunder_lizard_frenzy" and GetDistance2D(tempvictim,v) <= 700 then
									v:CastAbility(abi)
									Sleep(abi:FindCastPoint()*1000+client.latency,hand.."moving")
									Sleep(600,name)
								end
							end
						end
					end
					if v.classId ~= CDOTA_Unit_Elder_Titan_AncestralSpirit and v.name ~= "npc_dota_enraged_wildkin_tornado" and v.classId ~= CDOTA_BaseNPC_Tusk_Sigil and not v:IsChanneling() then
						if Animations.GetAttackTime(v) > 0 and tempvictim and not Animations.CanMove(v) and GetDistance2D(v,tempvictim) <= mathmax(v.attackRange*2+50,700) and not tempvictim:IsInvul() and v:CanAttack() and not tempvictim:IsAttackImmune() and not tempvictim:DoesHaveModifier("modifier_bane_nightmare") then	
							if SleepCheck(hand.."moving") and SleepCheck(hand.."attack") then
								if not tempvictim:IsInvul() and not tempvictim:IsAttackImmune() and not tempvictim:DoesHaveModifier("modifier_bane_nightmare") then
									v:Attack(tempvictim)
									if GetDistance2D(v,tempvictim) < v.attackRange+50 then
										enemyHP = enemyHP - tempvictim:DamageTaken((v.dmgMin + v.dmgMax)/2,DAMAGE_PHYS,v)
									end
								else
									v:Follow(tempvictim)
								end
								Sleep(Animations.GetAttackTime(v)*1000,hand.."attack")
							end
						elseif Animations.GetAttackTime(v) > 0 and SleepCheck(hand.."moving") and SleepCheck(hand.."move") then
							local mPos = client.mousePosition
							if retreat or (((not tempvictim or ((GetDistance2D(v,mPos) > 300 or GetDistance2D(mPos, tempvictim) > 300) and tempvictimVisible and GetDistance2D(tempvictim,v) < 1000))) and (not tempvictim or (tempvictimVisible and GetDistance2D(tempvictim,v) < 1000)) and (not tempvictim or v:GetTurnTime(mPos)*2 < Animations.getBackswingTime(v))) then
								v:Move(mPos)
							elseif prediction and GetDistance2D(prediction,v) < v.attackRange and tempvictim and (GetDistance2D(v,tempvictim)-v.attackRange)/v.movespeed > Animations.getBackswingTime(v) then
								v:Move(mPos)
							elseif tempvictim then 
								v:Follow(tempvictim)
							end
							--print(math.abs(Animations.getBackswingTime(v))*1000)
							Sleep(math.abs(Animations.getBackswingTime(v))*1000,hand.."move")
						elseif tempvictim and SleepCheck(hand.."moving") and SleepCheck(hand.."attack") and not tempvictim:IsInvul() and v:CanAttack() and not tempvictim:IsAttackImmune() and not tempvictim:DoesHaveModifier("modifier_bane_nightmare") then
							v:Attack(tempvictim)
							Sleep(200,hand.."attack")
						end
					elseif SleepCheck(hand.."moving") and (v.name == "npc_dota_enraged_wildkin_tornado" or v.classId == CDOTA_BaseNPC_Tusk_Sigil) then
						if tempvictim and prediction then 
							local prev = SelectUnit(v)
							entityList:GetMyPlayer():Move(prediction)
							SelectBack(prev)
							Sleep(500,hand.."moving")
						end
					end
				end
			end	
			--Special Combo: Invoker
			if ID == CDOTA_Unit_Hero_Invoker then
				quas, wex, exort, spell1, spell2, invoke = a1, a2, a3, a4, a5, a6  
				if (not me:IsInvisible() or me.visibleToEnemy) and combo == 0 then
					
					--Build Recognition
					local build = {{wex, 2}, {quas, 1}, {exort, 3}}	
					tablesort(build, function(a,b) return a[1].level > b[1].level end)
					local spells = {}
					local spellsCount = 0
					local orbSpells = invokerCombo[build[1][2]]
					local cyclone = me:FindItem("item_cyclone")
					local tornado = me:FindItem("invoker_tornado")
					local octa = me:FindItem("item_octarine_core")
					function test(name) return((name ~= "invoker_tornado" or wex.level > 3) and (not harras or ((me:FindSpell(name).manacost+invoke.manacost) < me.mana*0.2 and victimdistance < range+100)) and (name ~= "invoker_chaos_meteor" or exort.level > 3 or (tempvictim and (tempvictim:IsStunned() or tempvictim:IsRooted() or movespeed < 200))) and (name ~= "invoker_ice_wall" or quas.level > 3) and (name ~= "invoker_emp" or wex.level > 3 or build[1][1] == wex) and (name ~= "invoker_sun_strike" or (exort.level > 3 and (tempvictim and (tempvictim:IsStunned() or tempvictim:IsRooted() or (cyclone and cyclone:CanBeCasted()) or (tornado and tornado:CanBeCasted()) or tempvictim:DoesHaveModifier("modifier_eul_cyclone") or tempvictim:DoesHaveModifier("modifier_invoker_tornado") or movespeed < 200 or enemyHP < 500)))) and (name ~= "invoker_ice_wall" or (name == "invoker_ice_wall" and tempvictim and (facing or GetDistance2D(me,prediction) < 450))) and (name ~= "invoker_alacrity" or (not retreat and wex.level > 3 and exort.level > 3)) and (name ~= "invoker_emp" or not retreat) and (name ~= "invoker_chaos_meteor" or not retreat) and (name ~= "invoker_tornado" or (name == "invoker_tornado" or not tempvictim or (not tempvictim:DoesHaveModifier("modifier_invoker_chaos_meteor_burn") and not tempvictim:DoesHaveModifier("modifier_invoker_ice_wall_slow_debuff") and not tempvictim:DoesHaveModifier("modifier_invoker_ice_wall_slow_aura"))))) end
					local canInvoke = ((spell2.cd > 3 or (tempvictim and spell2.cd ~= 0)) or spell2.name == "invoker_ghost_walk" or (retreat and spell2.name == "invoker_alacrity") or (spell2.name == "invoker_ice_wall" and victimdistance > 700))
					
					
					--Combo Recognition:
					--Ghost Walk for escaping
					if retreat and wex.level > 0 and quas.level > 0 and SleepCheck("casting2") then
						prepareSpell("invoker_ghost_walk", me)
					end
					
					--Tornado->Meteor/EMP->Blast
					if me:AghanimState() and quas.level > 5 then 
						local spell2cd = spell2:GetCooldown(spell2.level)
						if octa then
							spell2cd = spell2cd*0.75
						end
						spell2cd = spell2cd-7
						if spell1.name == "invoker_chaos_meteor" and spell2.name == "invoker_tornado" and tempvictim and spell2 and spell2.cd > spell2cd and canInvoke and wex.level > 0 and SleepCheck("casting2") then
							prepareSpell("invoker_emp", me)
						end
						if spell1.name == "invoker_emp" and spell2.name == "invoker_tornado" and tempvictim and spell2 and spell2.cd > spell2cd and canInvoke and wex.level > 0 and SleepCheck("casting2") then
							prepareSpell("invoker_chaos_meteor", me)
						end
						if (spell1.name == "invoker_emp" or spell1.name == "invoker_chaos_meteor") and spell2 and spell2.cd > spell2cd and (spell2.name == "invoker_emp" or spell2.name == "invoker_chaos_meteor") and canInvoke and wex.level > 0  and quas.level > 0 and SleepCheck("casting2") then
							prepareSpell("invoker_deafening_blast", me)
						end
					elseif (((spell1.name == "invoker_tornado" or spell1.name == "invoker_emp") and (spell2.name == "invoker_tornado" or spell2.name == "invoker_emp"))) and tempvictim and canInvoke and quas.level > 0 and SleepCheck("casting2") then
						prepareSpell("invoker_cold_snap", me)
					end
					
					--alacrity after vaginal injection
					if (spell1.name == "invoker_cold_snap" or spell2.name == "invoker_cold_snap") and tempvictim and canInvoke and wex.level > exort.level and wex.level > 0 and exort.level > 0 and SleepCheck("casting2") then
						local snap = me:FindSpell("invoker_cold_snap")
						local spell2cd = snap:GetCooldown(snap.level)
						if octa then
							spell2cd = spell2cd*0.75
						end
						spell2cd = spell2cd-3
						if snap and snap.cd > spell2cd then
							prepareSpell("invoker_alacrity", me)
						end
					end
					
					--Sunstrike KillSteal
					if victimdistance > range+50 and (not blink or blink.cd > 5) then
						local sunstrike = me:FindSpell("invoker_sun_strike")
						local Dmg = AbilityDamageGetDamage(sunstrike)
						if sunstrike and spell1 ~= sunstrike and spell2 ~= sunstrike and sunstrike.cd and sunstrike.cd == 0 and sunstrike.manacost and sunstrike.manacost < me.mana and Dmg and enemyHP and Dmg >= enemyHP then
							prepareSpell("invoker_sun_strike", me)
						end
					end
						
					--Blast after combos using tornado/euls
					if (((spell1.name == "invoker_sun_strike" or spell1.name == "invoker_chaos_meteor") and (spell2.name == "invoker_sun_strike" or spell2.name == "invoker_chaos_meteor")) or
						((spell1.name == "invoker_tornado" or spell1.name == "invoker_chaos_meteor") and (spell2.name == "invoker_tornado" or spell2.name == "invoker_chaos_meteor")) or
						((spell1.name == "invoker_tornado" or spell1.name == "invoker_emp") and (spell2.name == "invoker_tornado" or spell2.name == "invoker_emp")) or retreat) and canInvoke and wex.level > 0  and quas.level > 0 and SleepCheck("casting2") then
						local spell2cd = spell2:GetCooldown(spell2.level)
						if octa then
							spell2cd = spell2cd*0.75
						end
						spell2cd = spell2cd-7
						if spell2 and spell2.cd > spell2cd then
							prepareSpell("invoker_deafening_blast", me)
						end
					end
					
					--Meteor after Tornado
					if tempvictim and tempvictim:DoesHaveModifier("modifier_invoker_tornado") and canInvoke and wex.level > 0 and exort.level > 0 and SleepCheck("casting2") then
						prepareSpell("invoker_chaos_meteor", me)
					end
					
					--EMP after tornado from ghost walk
					if (((spell1.name == "invoker_tornado" or spell1.name == "invoker_ghost_walk") and (spell2.name == "invoker_tornado" or spell2.name == "invoker_ghost_walk"))) and tempvictim and tempvictim:DoesHaveModifier("modifier_invoker_tornado") and canInvoke and wex.level > 0 and SleepCheck("casting2") then
						prepareSpell("invoker_emp", me)
					end
					
					for i = 1,#orbSpells do
						local spell = orbSpells[i]
						local ent = me:FindSpell(spell[1])
						if ent then
							if ent:CanBeCasted() and (ent == spell1 or ent == spell2) then
								spellsCount = spellsCount + 1
								spells[spellsCount] = spell
							elseif ent.cd == 0 and ent.manacost+invoke.manacost < me.mana and (ent ~= spell1 and ent ~= spell2) and (canInvoke or spell1.name == "invoker_empty1" or spell1.name == "invoker_empty2" or spell2.name == "invoker_empty1" or spell2.name == "invoker_empty2") and SleepCheck("casting2") and test(ent.name) then	
								prepareSpell(ent.name, me)
							end
						end			
					end
					orbSpells = invokerCombo[build[2][2]]
					for i = 1,#orbSpells do
						local spell = orbSpells[i]
						local ent = me:FindSpell(spell[1])
						if ent then
							if ent:CanBeCasted() and (ent == spell1 or ent == spell2) then
								spellsCount = spellsCount + 1
								spells[spellsCount] = spell
							elseif ent.cd == 0 and ent.manacost+invoke.manacost < me.mana and (ent ~= spell1 and ent ~= spell2) and (canInvoke or spell1.name == "invoker_empty1" or spell1.name == "invoker_empty2" or spell2.name == "invoker_empty1" or spell2.name == "invoker_empty2") and SleepCheck("casting2") and test(ent.name) then	
								prepareSpell(ent.name, me)
							end
						end	
					end
					if build[3][1].level > 0 then
						orbSpells = invokerCombo[build[3][2]]
						for i = 1,#orbSpells do
							local spell = orbSpells[i]
							local ent = me:FindSpell(spell[1])
							if ent then
								if ent:CanBeCasted() and (ent == spell1 or ent == spell2) then
									spellsCount = spellsCount + 1
									spells[spellsCount] = spell
								elseif ent.cd == 0 and ent.manacost+invoke.manacost < me.mana and (ent ~= spell1 and ent ~= spell2) and (canInvoke or spell1.name == "invoker_empty1" or spell1.name == "invoker_empty2" or spell2.name == "invoker_empty1" or spell2.name == "invoker_empty2") and SleepCheck("casting2") and test(ent.name) then	
									prepareSpell(ent.name, me)
								end
							end	
						end
					end
					if quas.level > 0 and wex.level > 0 and exort.level > 0 then
						spellsCount = spellsCount + 1
						spells[spellsCount] = invokerCombo[4][1]
					end
					if retreat and quas.level > 0 and wex.level > 0 then
						spellsCount = spellsCount + 1
						spells[spellsCount] = invokerCombo[4][2]
					end
					for i = 1, spellsCount do
						local data = spells[i]
						local spell = data[1]
						if spell == "invoker_tornado" and spellsCount > 1 then
							if quas.level > 3 then
								spells[i] = spells[1]
								spells[1] = data
							else
								spells[i] = spells[2]
								spells[2] = data
							end
						end
					end
					mySpells = { CDOTA_Unit_Hero_Invoker, spells }
				end
			end
			
			--Ember Spirit: Searing Chains
			if ID == CDOTA_Unit_Hero_EmberSpirit and tempvictim then
				local chains = a1
				if chains and chains:CanBeCasted() and not SleepCheck("ember_spirit_sleight_of_fist") and GetDistance2D(mePosition,tempvictim) < 500 and SleepCheck(chains.name) then
					me:CastAbility(chains)
					Sleep(500,chains.name)
					return
				end
			end
			if tempvictim and tempvictim.hero and (not me:IsInvisible() or (a2.name == "templar_assassin_meld" and a2:CanBeCasted() and victimdistance < range)) and ((enemyHP > 0 and enemyHP > meDmg*2) or victimdistance > range+200) and me.alive and tempvictimAlive then
				local CanCast = me:CanCast()
				local al = #abilities
				local items = me.items
				local il = #items
				local manaboots = me:FindItem("item_arcane_boots")
				--Blink
				if tempvictim and tempvictimVisible and tempvictimAlive and blink and SleepCheck("blink") and GetDistance2D(prediction,me) > 500 and GetDistance2D(prediction,me) > range+50 and GetDistance2D(prediction,me) < 1700 and not me:IsStunned() and blink:CanBeCasted() and useblink and SleepCheck("casting") then
					local distance = blink:GetSpecialData("blink_range")
					local blinkPos = prediction
					if retreat then
						blinkPos = client.mousePosition
					end
					if GetDistance2D(prediction,me) > distance or retreat then
						blinkPos = (blinkPos - me.position) * (distance-1) / GetDistance2D(blinkPos,me) + me.position
					end
					if me:SafeCastAbility(blink,blinkPos) then
						Sleep(me:GetTurnTime(blinkPos)*1000+client.latency+400,"blink")
						Sleep(me:GetTurnTime(blinkPos)*1000+client.latency+100,"casting")
						Sleep(me:GetTurnTime(blinkPos)*1000+client.latency,"moving")
						mePosition = blinkPos
						return
					end
				end
				local dagon = me:FindDagon()
				local ethereal = me:FindItem("item_ethereal_blade")
				--Item Combo
				if SleepCheck("casting") and not me:IsStunned() and tempvictimVisible and (not meld or (not me:DoesHaveModifier("modifier_templar_assassin_meld") or SleepCheck("moving"))) then
					local l = #itemcomboTable
					for i = 1, l do
						local data = itemcomboTable[i]
						local itemname = data[1] or data
						local item = me:FindItem(itemname)
						if item and item:CanBeCasted() then
							local mainatr = 0
							if itemname == "item_ethereal_blade" then
								if not atr then atr = me.primaryAttribute end
								local atr = atr
								if atr == LuaEntityHero.ATTRIBUTE_STRENGTH then mainatr = me.strengthTotal
								elseif atr == LuaEntityHero.ATTRIBUTE_AGILITY then mainatr = me.agilityTotal
								elseif atr == LuaEntityHero.ATTRIBUTE_INTELLIGENCE then mainatr = me.intellectTotal
								end
							end
							if not tempdamageTable[itemname] or (itemname == "item_ethereal_blade" and tempdamageTable[itemname][2] ~= mainatr) then
								damageTable[itemname] = {AbilityDamageGetDamage(item), mainatr}
								tempdamageTable = damageTable
							end
							local Dmg = tempdamageTable[itemname][1]
							if itemname == "item_urn_of_shadows" then Dmg = 100 end
							local type = AbilityDamageGetDmgType(item)
							if Dmg then
								Dmg = tempvictim:DamageTaken(Dmg,type,me)
							end
							local go = true
							if itemname == "item_refresher" or (itemname == "item_cyclone" and ID == CDOTA_Unit_Hero_Tinker) then
								for z = 1, al do
									local ab = abilities[z]
									if ab.name ~= "tinker_march_of_the_machines" and ab.name ~= "tinker_rearm" and ab.name ~= "invoker_alacrity" and ab.name ~= "invoker_forge_spirit" and ab.name ~= "invoker_ice_wall" and ab.name ~= "invoker_ghost_walk" and ab.name ~= "invoker_cold_snap" and ab.name ~= "invoker_quas" and ab.name ~= "invoker_exort" and ab.name ~= "invoker_wex" and ab.name ~= "invoker_invoke" and ab.level > 0 and ab.cd == 0 and not ab:IsBehaviourType(LuaEntityAbility.BEHAVIOR_PASSIVE) then
										go = false
										break
									end
								end
								for z = 1, il do
									local ab = items[z]
									if ab.name ~= "item_blink" and ab.name ~= "item_travel_boots" and ab.name ~= itemname and ab.name ~= "item_travel_boots_2" and ab.name ~= "item_tpscroll" and ab.abilityData.itemCost > 1000 and ab:CanBeCasted() then
										go = false
										break
									end
								end
							end
							if itemname == "item_cyclone" then
								if not config.UseEul then go = false end
								for z = 1, al do
									local ab = abilities[z]
									local abcd = ab:GetCooldown(ab.level)
									local octa = me:FindItem("item_octarine_core")
									if octa then
										abcd = abcd*0.75
									end
									abcd = abcd-3
									local dmg 
									if tempdamageTable[ab.name] then
										dmg = tempdamageTable[ab.name][1]
									end
									if (ab.cd > abcd) and ab.cd ~= 0 and dmg and dmg > 0 then go = false end
								end
								if combo ~= 0 then go = false end
							end
							if itemname == "item_urn_of_shadows" and not me.visibleToEnemy and enemyHP > Dmg then go = false end
							if itemname ~= "item_veil_of_discord" and itemname ~= "item_soul_ring" and itemname ~= "item_arcane_boots" then
								local spell1,spell2 = a4,a5
								if (spell1.name == "invoker_tornado" and spell1:CanBeCasted()) or (spell2.name == "invoker_tornado" and spell2:CanBeCasted()) then
									go = false
								end
							end
							
							if (item == dagon or item == ethereal) and ID ~= CDOTA_Unit_Hero_Tinker and ((a4 and a4.name == "necrolyte_reapers_scythe" and a4:CanBeCasted()) or (data[4] and Dmg < enemyHP and not tempvictim:DoesHaveModifier("modifier_item_ethereal_blade_slow") and not tempvictim:DoesHaveModifier("modifier_necrolyte_reapers_scythe"))) then
								--print("aaaa")
								go = false
							end
							if itemname == "item_phase_boots" then Dmg = nil end
							if itemname == "item_force_staff" and not me:DoesHaveModifier("modifier_batrider_flaming_lasso_self") then go = false end
							if itemname == "item_dust" and not CanGoInvis(tempvictim) then go = false end
							if (itemname == "item_diffusal_blade" or itemname == "item_diffusal_blade_2") then
								if not (tempvictim:DoesHaveModifier("modifier_ghost_state") or tempvictim:DoesHaveModifier("modifier_item_ethereal_blade_slow") or tempvictim:DoesHaveModifier("modifier_omninight_guardian_angel")) then 
									go = false 
								end
							end
							if itemname == "item_arcane_boots" and (me.maxMana - me.mana) < 135 then go = false end
							local coldfeet
							if ID == CDOTA_Unit_Hero_AncientApparition then
								coldfeet = a1
							end
							if ID == CDOTA_Unit_Hero_Rubick then coldfeet = me:FindSpell("ancient_apparition_cold_feet") end
							
							if itemname == "item_cyclone" then 
								delay = 500 
								if xposition then 
									go = false 
								end 
								if coldfeet and coldfeet:CanBeCasted() then 
									go = false 
								end
								if ID == CDOTA_Unit_Hero_Skywrath_Mage then
									local mfcd = a4:GetCooldown(a4.level)
									local octa = me:FindItem("item_octarine_core")
									if octa then
										mfcd = mfcd*0.75
									end
									mfcd = mfcd-3
									if a4 and a4.cd > mfcd then go = false end
								end
								if ID == CDOTA_Unit_Hero_Invoker then
									local emp = me:FindSpell("invoker_emp")
									local empcd = emp:GetCooldown(emp.level)
									local blast = me:FindSpell("invoker_deafening_blast")
									local blastcd = blast:GetCooldown(blast.level)
									local meteor = me:FindSpell("invoker_chaos_meteor")
									local meteorcd = meteor:GetCooldown(meteor.level)
									local sunstrike = me:FindSpell("invoker_sun_strike")
									local sunstrikecd = sunstrike:GetCooldown(sunstrike.level)
									local octa = me:FindItem("item_octarine_core")
									local spell1,spell2 = a4,a5
									if (spell1.name == "invoker_tornado" and spell1:CanBeCasted()) or (spell2.name == "invoker_tornado" and spell2:CanBeCasted()) then
										go = false
									end
									if octa then
										empcd = empcd*0.75
										blastcd = blastcd*0.75
										meteorcd = meteorcd*0.75
										sunstrikecd = sunstrikecd*0.75
									end
									empcd = empcd-3
									blastcd = blastcd-3
									meteorcd = meteorcd-5
									sunstrikecd = sunstrikecd-3
									if (emp and emp.cd > empcd) or (blast and blast.cd > blastcd) or (meteor and meteor.cd > meteorcd) or (sunstrike and sunstrike.cd > sunstrikecd) then
										go = false
									end
								end
								if (ID == CDOTA_Unit_Hero_Pudge and (tempvictim:DoesHaveModifier("modifier_pudge_rot") or (a4 and a4:CanBeCasted() and victimdistance < 400) or (a1 and a1:CanBeCasted() and victimdistance+100 > item.castRange))) or tempvictim:DoesHaveModifier("modifier_invoker_chaos_meteor_burn") or tempvictim:DoesHaveModifier("modifier_invoker_cold_snap") or tempvictim:DoesHaveModifier("modifier_invoker_ice_wall_slow_debuff") or tempvictim:DoesHaveModifier("modifier_invoker_ice_wall_slow_aura") or not tempvictim:CanMove() or tempvictim:DoesHaveModifier("modifier_pudge_meat_hook") or tempvictim:IsHexed() or tempvictim:IsDisarmed() or tempvictim:IsSilenced() or movespeed < 250 or tempvictim:IsRooted() or tempvictim:DoesHaveModifier("modifier_ghost_state") or tempvictim:DoesHaveModifier("modifier_item_ethereal_blade_slow") then go = false end
							end
							if ID == CDOTA_Unit_Hero_Invoker then
								local tornado = me:FindSpell("invoker_tornado")
								local tornadocd = tornado:GetCooldown(tornado.level)
								if octa then
									tornadocd = tornadocd*0.75
								end
								tornadocd = tornadocd-((GetDistance2D(me,tempvictim))/1000+client.latency/1000)
								if tornado and tornado.cd > tornadocd then
									go = false
								end
							end
							local d = 0
							if itemname == "item_shivas_guard" then
								d = GetDistance2D(me,tempvictim)/350
							end
							if (not tempvictim:IsMagicImmune() or type == DAMAGE_PHYS or data[5]) and not tempvictim:DoesHaveModifier("modifier_"..itemname.."_debuff") and 
							(go and (itemname ~= "item_refresher" or (item.manacost*2 < me.mana or (manaboots and item.manacost*2 < (me.mana+135))))) and 
							SleepCheck(itemname) and ((not data[2] and not tempvictim:IsInvul() and not tempvictim:DoesHaveModifier("modifier_invoker_tornado") and not tempvictim:DoesHaveModifier("modifier_eul_cyclone")) or chainStun(tempvictim,client.latency*0.001+d+(100/Animations.maxCount)*0.01 - ((client.latency/1000)/(1 + (1 - 1/Animations.maxCount)))) or (itemname == "item_blade_mail" and chainStun(tempvictim,0,"modifier_axe_berserkers_call"))) and (not retreat or (Dmg and Dmg > enemyHP) or data[6] or data[3]) and 
							(not Dmg or data[2] or Dmg/4 < enemyHP or victimdistance > range) and ((victimdistance > range) or (Dmg and Dmg > 0) or ((not Dmg or Dmg < 1) and enemyHP > 100) or itemname == "item_phase_boots")
							and ((not me:DoesHaveModifier("modifier_spirit_breaker_charge_of_darkness") and SleepCheck("charge")) or itemname == "item_armlet") then
								local cast
								local delay = 0
								if itemname == "item_cyclone" then 
									delay = 500 
									if xposition then 
										go = false 
									end 
									if coldfeet and coldfeet:CanBeCasted() then 
										go = false 
									end
									if ID == CDOTA_Unit_Hero_Invoker then
										local emp = me:FindSpell("invoker_emp")
										local empcd = emp:GetCooldown(emp.level)
										local blast = me:FindSpell("invoker_deafening_blast")
										local blastcd = blast:GetCooldown(blast.level)
										local meteor = me:FindSpell("invoker_chaos_meteor")
										local meteorcd = meteor:GetCooldown(meteor.level)
										local sunstrike = me:FindSpell("invoker_sun_strike")
										local sunstrikecd = sunstrike:GetCooldown(sunstrike.level)
										local octa = me:FindItem("item_octarine_core")
										local spell1,spell2 = a4,a5
										if (spell1.name == "invoker_tornado" and spell1:CanBeCasted()) or (spell2.name == "invoker_tornado" and spell2:CanBeCasted()) then
											go = false
										end
										if octa then
											empcd = empcd*0.75
											blastcd = blastcd*0.75
											meteorcd = meteorcd*0.75
											sunstrikecd = sunstrikecd*0.75
										end
										empcd = empcd-3
										blastcd = blastcd-3
										meteorcd = meteorcd-5
										sunstrikecd = sunstrikecd-3
										if (emp and emp.cd > empcd) or (blast and blast.cd > blastcd) or (meteor and meteor.cd > meteorcd) or (sunstrike and sunstrike.cd > sunstrikecd) then
											go = false
										end
									end
									if ID == CDOTA_Unit_Hero_Pudge then
										local hook = me:FindSpell("pudge_meat_hook")
										local hookcd = hook:GetCooldown(hook.level)
										local octa = me:FindItem("item_octarine_core")
										if octa then
											hookcd = hookcd*0.75
										end
										hookcd = hookcd - 2
										if (hook and hook.cd > hookcd) then go = false end
									end
									if ID == CDOTA_Unit_Hero_Mirana then
										local arrow = me:FindSpell("mirana_arrow")
										local arrowcd = arrow:GetCooldown(arrow.level)
										local octa = me:FindItem("item_octarine_core")
										if octa then
											arrowcd = arrowcd*0.75
										end
										arrowcd = arrowcd - 5
										if (arrow and arrow.cd > arrowcd) or (arrow:CanBeCasted() and victimdistance+100 > item.castRange) then go = false end
									end
									if (ID == CDOTA_Unit_Hero_Pudge and (tempvictim:DoesHaveModifier("modifier_pudge_rot") or (a4 and a4:CanBeCasted() and victimdistance < 400) or (a1 and a1:CanBeCasted() and victimdistance+100 > item.castRange))) or tempvictim:DoesHaveModifier("modifier_invoker_chaos_meteor_burn") or tempvictim:DoesHaveModifier("modifier_invoker_cold_snap") or tempvictim:DoesHaveModifier("modifier_invoker_ice_wall_slow_debuff") or tempvictim:DoesHaveModifier("modifier_invoker_ice_wall_slow_aura") or not tempvictim:CanMove() or tempvictim:DoesHaveModifier("modifier_pudge_meat_hook") or tempvictim:IsHexed() or tempvictim:IsDisarmed() or tempvictim:IsSilenced() or tempvictim:IsRooted() or tempvictim:DoesHaveModifier("modifier_ghost_state") or tempvictim:DoesHaveModifier("modifier_item_ethereal_blade_slow") then go = false end
								end
								--if itemname == "item_ethereal_blade" and dagon and dagon:CanBeCasted() then delay = (mathmin(item.castRange-50,victimdistance-100)/item:GetSpecialData("projectile_speed"))*1000 end
								if dagon and itemname == dagon.name and ((not SleepCheck("stuneth") and ethereal) or (ethereal and ethereal:CanBeCasted())) then go = false end
								if item:IsBehaviourType(LuaEntityAbility.BEHAVIOR_UNIT_TARGET) and go then
									if ((item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALLIED) and not item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ENEMY) and not item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALL)) or itemname == "item_force_staff") then
										cast = me:SafeCastAbility(item,me)
									elseif (item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ENEMY) or item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_CUSTOM) or item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALL)) and not tempvictim:IsInvul() and not tempvictim:DoesHaveModifier("modifier_eul_cyclone") and not tempvictim:DoesHaveModifier("modifier_brewmaster_storm_cyclone") and not tempvictim:DoesHaveModifier("modifier_invoker_tornado") and (not retreat or victimdistance < item.castRange+50) then
										cast = me:SafeCastAbility(item,tempvictim)
										delay = delay + me:GetTurnTime(tempvictim)*1000 --+ (mathmax(victimdistance-50-item.castRange,0)/me.movespeed)*1000
									end
								elseif item:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NO_TARGET) and (not data[3] or victimdistance-50 < data[3]) and (itemname ~= "item_armlet" or not me:DoesHaveModifier("modifier_item_armlet_unholy_strength")) then
									cast = me:SafeCastAbility(item)
								elseif item:IsBehaviourType(LuaEntityAbility.BEHAVIOR_POINT) or item:IsBehaviourType(LuaEntityAbility.BEHAVIOR_AOE) then
									if item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALLIED) and not item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ENEMY) then
										cast = me:SafeCastAbility(item,me)
									else
										delay = delay + me:GetTurnTime(tempvictim)*1000
										local delay2 = delay + client.latency
										if data[2] then delay2 = delay2 + data[2]*1000 end
										local speed = item:GetSpecialData("speed")
										local prediction
										if not speed then 
											prediction = SkillShotPredictedXYZ(tempvictim,delay2)
										else
											prediction = SkillShotSkillShotXYZ(mePosition,tempvictim,delay2,speed)
										end
										if prediction then
											cast = me:SafeCastAbility(item,prediction)
										end
									end
								end
								if cast then
									if itemname == "item_cyclone" then
										Sleep(200, itemname)
										Sleep(200, "casting")
									else
										Sleep(mathmax(delay,200), itemname)
									end
									if victimdistance < item.castRange+50 or (data[3] and victimdistance-50 < data[3]) then
										Sleep(delay+client.latency,"casting")
										if itemname == "item_ethereal_blade" then Sleep(delay+(mathmin(item.castRange-100,victimdistance-100)/item:GetSpecialData("projectile_speed"))*1000, "stuneth") 
										elseif itemname == "item_cyclone" then Sleep(500, "stun") end
										if Dmg then
											enemyHP = enemyHP - Dmg
										end
										return
									end
									if itemname == "item_cyclone" then return end
								end
							end
						end
					end	
				end
				if ID == CDOTA_Unit_Hero_EarthSpirit then 
					if not a3:CanBeCasted() or SleepCheck("esstone") then esstone = false end
				end
				--Spell Combo
				if mySpells and SleepCheck("casting") and CanCast and not me:DoesHaveModifier("modifier_batrider_flaming_lasso_self") and not me:DoesHaveModifier("modifier_spirit_breaker_charge_of_darkness") and SleepCheck("charge") then	
					local t2 = mySpells[2]
					local l2 = #t2
					for i = 1, l2 do
						local data = t2[i]
						local slot = data[1] or data
						if slot then
							local spell
							if GetType(slot) == "string" then
								spell = me:FindSpell(slot)
							else
								spell = abilities[slot]
							end
							if spell and (spell.name == "troll_warlord_whirling_axes_melee" or spell.name == "troll_warlord_whirling_axes_ranged") then
								if ((spell.cd == 0 and not spell:CanBeCasted() and me.mana >= spell.manacost) or trolltoggle) and SleepCheck("toggle") and (victimdistance < spell.castRange or (victimdistance < 450)) then
									me:ToggleSpell(a1.name)
									Sleep(200+client.latency,"toggle")
									Sleep(client.latency,"casting")
									trolltoggle = false
									return
								end
							end
							if spell and spell:CanBeCasted() and (not meld or CanMove or (meld:CanBeCasted() and spell == meld) or victimdistance > range+50) then
								local distance = nil
								local delay = mathmax(spell:FindCastPoint()*1000, 50)
								if spell.name == "templar_assassin_refraction" then delay = 0 end
								if data[2] then
									distance = data[2]
								end
								if distance then
									if GetType(distance) == "string" then
										if spell.name == "invoker_tornado" then
											distance = spell:GetSpecialData(distance,wex.level)
										elseif spell.name == "invoker_deafening_blast" then
											distance = spell:GetSpecialData(distance,wex.level)
										else
											distance = spell:GetSpecialData(distance,spell.level)
										end
									end
								end
								local prediction 
								if tempvictimVisible then
									prediction = SkillShotPredictedXYZ(tempvictim,mathmax(delay, 100)+client.latency)
								else
									prediction = SkillShot.BlindSkillShotXYZ(me,tempvictim,1100,mathmax(delay, 100)/1000+client.latency/1000) 
								end
								local add = 0
								if data[4] then add = data[4] end
								if GetType(add) == "string" then
									add = spell:GetSpecialData(add,spell.level)
								end
								if me:DoesHaveModifier("modifier_ember_spirit_fire_remnant") and spell.name == "ember_spirit_sleight_of_fist" then go = false end
								local go = true
								if spell.name == "tinker_rearm" then
									for i = 1, al do
										local ab = abilities[i]
										if ab.name ~= "tinker_march_of_the_machines" and ab.name ~= "tinker_rearm" and ab:CanBeCasted() and not ab:IsBehaviourType(LuaEntityAbility.BEHAVIOR_PASSIVE) then
											go = false
											break
										end
									end
									for i = 1, il do
										local ab = items[i]
										if ab.name ~= "item_blink" and ab.name ~= "item_travel_boots" and ab.name ~= "item_refresher" and ab.name ~= "item_travel_boots_2" and ab.name ~= "item_tpscroll" and ab.abilityData.itemCost > 1000 and ab:CanBeCasted() then
											go = false
											break
										end
									end
								end
								local castRange = spell.castRange
								if spell.name == "phoenix_icarus_dive" then castRange = 1400 end
								local octa = me:FindItem("item_octarine_core")
								if spell.name == "invoker_tornado" then 
									castRange = distance 
									local emp = me:FindSpell("invoker_emp")
									local empcd = emp:GetCooldown(emp.level)
									local blast = me:FindSpell("invoker_deafening_blast")
									local blastcd = blast:GetCooldown(blast.level)
									local meteor = me:FindSpell("invoker_chaos_meteor")
									local meteorcd = meteor:GetCooldown(meteor.level)
									local sunstrike = me:FindSpell("invoker_sun_strike")
									local sunstrikecd = sunstrike:GetCooldown(sunstrike.level)
									if octa then
										empcd = empcd*0.75
										blastcd = blastcd*0.75
										meteorcd = meteorcd*0.75
										sunstrikecd = sunstrikecd*0.75
									end
									empcd = empcd-3
									blastcd = blastcd-3
									meteorcd = meteorcd-5
									sunstrikecd = sunstrikecd-3
									if (blink and blink:CanBeCasted()) or tempvictim:IsSilenced() or tempvictim:IsRooted() or tempvictim:IsStunned() or tempvictim:DoesHaveModifier("modifier_ghost_state") or tempvictim:DoesHaveModifier("modifier_item_ethereal_blade_slow") or tempvictim:DoesHaveModifier("modifier_invoker_chaos_meteor_burn") or tempvictim:DoesHaveModifier("modifier_invoker_cold_snap") or tempvictim:DoesHaveModifier("modifier_invoker_ice_wall_slow_debuff") or tempvictim:DoesHaveModifier("modifier_invoker_ice_wall_slow_aura") or (emp and emp.cd > empcd and quas.level > 3) or (blast and blast.cd > blastcd) or (meteor and meteor.cd > meteorcd) or (sunstrike and sunstrike.cd > sunstrikecd) then
										go = false
									end
								end
								if spell.name == "lone_druid_true_form" and retreat then go = false end
								if spell.name == "invoker_cold_snap" then
									local tornado = me:FindSpell("invoker_tornado")
									local tornadocd = tornado:GetCooldown(tornado.level)
									if octa then
										tornadocd = tornadocd*0.75
									end
									tornadocd = tornadocd-3
									if tornado and tornado.cd > tornadocd then go = false end
								end
								if spell.name == "pugna_decrepify" then
									local blast = a1
									if blast and blast:CanBeCasted() then 
										go = false
									end
								end
								if ID == CDOTA_Unit_Hero_Invoker and spell.name ~= "invoker_tornado" then
									local tornado = me:FindSpell("invoker_tornado")
									local tornadocd = tornado:GetCooldown(tornado.level)
									if octa then
										tornadocd = tornadocd*0.75
									end
									if spell.name == "invoker_emp" then tornadocd = tornadocd-((GetDistance2D(me,tempvictim)-350)/1000)
									else tornadocd = tornadocd-((GetDistance2D(me,tempvictim))/1000+client.latency/1000) end
									if tornado and tornado.cd > tornadocd then
										go = false
									end
								end								
								if spell.name == "shadow_shaman_ether_shock" and (a2:CanBeCasted() or (a3:CanBeCasted() and spell.manacost+a3.manacost > me.mana)) then go = false end
								if castRange < 1 then castRange = 9999999 end
								if spell.name == "earth_spirit_boulder_smash" then 
									local grip = a3
									if grip and grip:CanBeCasted() then
										castRange = 1200
									end 
								end
								if spell.name == "earth_spirit_rolling_boulder" then castRange = 1200 if not a1:CanBeCasted() and a4:CanBeCasted() then castRange = 3000 end end
								if spell.name == "slark_pounce" then castRange = 700 end
								if not tempdamageTable[spell.name] or tempdamageTable[spell.name][2] ~= spell.level or (me:AghanimState() and not tempdamageTable[spell.name][3]) then
									damageTable[spell.name] = {AbilityDamageGetDamage(spell), spell.level, me:AghanimState()}
									tempdamageTable = damageTable
								end
								local Dmg = tempdamageTable[spell.name][1]
								if ID == CDOTA_Unit_Hero_Invoker then Dmg = AbilityDamageGetDamage(spell) end
								if spell.name == "visage_soul_assumption" then
									local modif = me:FindModifier("modifier_visage_soul_assumption")
									if modif then
										Dmg = 20
										if modif.stacks > 0 then
											Dmg = Dmg + modif.stacks*65
										end
									end
								end
								if spell.name == "necrolyte_reapers_scythe" then
									if dagon and dagon:CanBeCasted() then
										if tempdamageTable[dagon.name] then
											Dmg = Dmg*(tempvictim.maxHealth - (enemyHP - tempvictim:DamageTaken(tempdamageTable[dagon.name][1],DAMAGE_MAGC,me))) + tempvictim:DamageTaken(tempdamageTable[dagon.name][1],DAMAGE_MAGC,me)
										else
											Dmg = Dmg*(tempvictim.maxHealth - (enemyHP - tempvictim:DamageTaken(AbilityDamageGetDamage(dagon),DAMAGE_MAGC,me))) + tempvictim:DamageTaken(AbilityDamageGetDamage(dagon),DAMAGE_MAGC,me)
										end
									elseif Dagon and Dagon:CanBeCasted() and ethereal and etherel:CanBeCasted() then
										if tempdamageTable[dagon.name] and tempdamageTable[ethereal.name] then
											Dmg = Dmg*(tempvictim.maxHealth - (enemyHP - tempvictim:DamageTaken(tempdamageTable[dagon.name][1],DAMAGE_MAGC,me) - tempvictim:DamageTaken(tempdamageTable[ethereal.name][1],DAMAGE_MAGC,me))) + tempvictim:DamageTaken(tempdamageTable[ethereal.name][1],DAMAGE_MAGC,me) + tempvictim:DamageTaken(tempdamageTable[dagon.name][1],DAMAGE_MAGC,me)
										else
											Dmg = Dmg*(tempvictim.maxHealth - (enemyHP - tempvictim:DamageTaken(AbilityDamageGetDamage(dagon),DAMAGE_MAGC,me) - tempvictim:DamageTaken(AbilityDamageGetDamage(ethereal),DAMAGE_MAGC,me))) + tempvictim:DamageTaken(AbilityDamageGetDamage(ethereal),DAMAGE_MAGC,me) + tempvictim:DamageTaken(AbilityDamageGetDamage(dagon),DAMAGE_MAGC,me)
										end
									else
										Dmg = Dmg*(tempvictim.maxHealth - enemyHP)
									end
									if ethereal and ethereal:CanBeCasted() then
										Dmg = Dmg*1.4
									end
								end
								local type = AbilityDamageGetDmgType(spell)
								if spell.name == "antimage_mana_void" then
									local missingMana = (tempvictim.maxMana - tempvictim.mana)
									Dmg = missingMana*Dmg
									if missingMana > tempvictim.maxMana*0.1 and tempvictim:DamageTaken(Dmg,type,me) < tempvictim.health then
										go = false
									end
								end
								if ID == CDOTA_Unit_Hero_StormSpirit then
									local Overload = me:DoesHaveModifier("modifier_storm_spirit_overload")
									local pull = a2
									if Overload and not CanMove and victimdistance < range+50 then
										go = false
									end
									if spell.name == "storm_spirit_ball_lightning" and (victimdistance < range+50 and (me.mana < (me.maxMana*0.6) or (pull and pull:CanBeCasted()))) or me:DoesHaveModifier("modifier_storm_spirit_ball_lightning") then
										go = false
									end
									if spell.name == "storm_spirit_static_remnant" and victimdistance > range+50 then
										go = false
									end
								end
								if spell.name == "storm_spirit_ball_lightning" and ID == CDOTA_Unit_Hero_Rubick and victimdistance < range+50 then
									go = false
								end
								if spell.name == "leshrac_pulse_nova" and me:DoesHaveModifier("modifier_leshrac_pulse_nova") then go = false end
								--print(a3 and a3:CanBeCasted(), (not (tempvictim:IsStunned() or tempvictim:IsRooted() or tempvictim:IsHexed() or not tempvictim:CanMove()) or not Animations.isAttacking(tempvictim) or tempvictim.activity ~= LuaEntityNPC.ACTIVITY_IDLE))
								if spell.name == "leshrac_split_earth" and a3 and a3:CanBeCasted() and (not (tempvictim:IsStunned() or tempvictim:IsRooted() or tempvictim:IsHexed() or not tempvictim:CanMove() or tempvictim:IsInvul()) and not Animations.isAttacking(tempvictim) and tempvictim.activity ~= LuaEntityNPC.ACTIVITY_IDLE) then go = false end 
								if spell.name == "invoker_emp" then
									if tempvictim.mana < Dmg then
										Dmg = tempvictim.mana
									end
									Dmg = Dmg/2
									if tempvictim.mana < 100 and combo ~= 1 then
										go = false
									end
								end
								if spell.name == "tusk_walrus_kick" then
									local base = entityList:GetEntities({classId = CDOTA_Unit_Fountain,team = me.team})[1]
									if not retreat then go = false end
									if GetDistance2D(me,base) > GetDistance2D(base,tempvictim) then go = true end
								end
								if spell.name == "phoenix_sun_ray" then
									Dmg = Dmg + tempvictim.maxHealth*(spell:GetSpecialData("hp_perc_dmg",spell.level)/100)
								end
								if Dmg and tempvictim then
									Dmg = tempvictim:DamageTaken(Dmg,type,me)
								end
								--Zeus's Static Field
								if ID == CDOTA_Unit_Hero_Zuus then
									local staticF = a3
									if staticF and staticF.level > 0 and victimdistance < 1250 then
										Dmg = Dmg + tempvictim:DamageTaken(((staticF:GetSpecialData("damage_health_pct",staticF.level)/100)*enemyHP),DAMAGE_MAGC,me)
									end
								end
								if spell.name == "necrolyte_reapers_scythe" and not (tempvictim and tempvictim:DoesHaveModifier("modifier_item_ethereal_blade_slow")) and enemyHP > Dmg then
									go = false
								end
								local channel = spell:GetChannelTime(spell.level) or 0
								if spell.name == "bane_fiends_grip" then channel = 0 end
								local speed = spell:GetSpecialData("speed", spell.level)
								if data[6] then 
									speed = spell:GetSpecialData(data[6], spell.level)
								end
								if spell.name == "earth_spirit_rolling_boulder" then speed = 800 if not a1:CanBeCasted() and a4:CanBeCasted() then speed = 1600 end end
								if spell.name == "invoker_cold_snap" then
									local tornado = me:FindSpell("invoker_tornado")
									local tornadocd = tornado:GetCooldown(tornado.level)
									if octa then
										tornadocd = tornadocd*0.75
									end
									tornadocd = tornadocd-((GetDistance2D(me,tempvictim))/1000+client.latency/1000)
									if tornado and tornado.cd > tornadocd then
										go = false
									end
								end
								if spell.name == "morphling_adaptive_strike" or spell.name == "morphling_waveform" then
									local eth = me:FindItem("item_ethereal_blade")
									if eth and eth:CanBeCasted() then
										go = false
									end
								end
								if spell.name == "shadow_demon_demonic_purge" and a1 and a1:CanBeCasted() and victimdistance <= a1.castRange+100 then go = false end
								if (retreat or harras) and (delay > 600 or channel > 0) then
									go = false
								end
								if spell.name == "ember_spirit_activate_fire_remnant" then
									local remnants = entityList:GetEntities(function (v) return (v.classId == CDOTA_BaseNPC_Additive and v.team == me.team and v.alive == true and v.name == "npc_dota_ember_spirit_remnant" and GetDistance2D(v,tempvictim) < 700) end)
									if #remnants <= 0 then go = false end
								end
								if spell.name == "earth_spirit_geomagnetic_grip" or spell.name == "earth_spirit_rolling_boulder" then
									local smash = a1
									if smash:CanBeCasted() and not smash.abilityPhase and a4:CanBeCasted() then go = false end
								end
								local raze1, raze2, raze3
								if ID == CDOTA_Unit_Hero_Nevermore then
									raze1, raze2, raze3 = SkillShot.InFront(me,200), SkillShot.InFront(me,450), SkillShot.InFront(me,700)
								end
								if spell.name == "disruptor_glimpse" then
									local pos = positionsTable[tempvictim.handle]
									local time = gameTime-4
									local closest = nil
									local closesttime = nil
									for i,v in pairs(pos) do
										if not closest or math.abs(time-i) < closesttime then
											closest = v
											closesttime = math.abs(time-i)
										end
									end
									--print(a1.name, GetDistance2D(tempvictim,closest))
									if GetDistance2D(tempvictim,closest) < 500 or GetDistance2D(me,closest) > victimdistance then go = false end
									local a3cd = a3:GetCooldown(a3.level)
									a3cd = a3cd - 3.800
									if a3.cd > a3cd then go = false end
									if not tempvictim:DoesHaveModifier("modifier_disruptor_thunder_strike") and a1:CanBeCasted() and victimdistance < a1.castRange+200 and not me.visibleToEnemy then go = false end
									--print(go)
								end
								if spell.name == "rubick_spell_steal" and a5 and (a5:CanBeCasted() or (a5.cd < 5 and a5.manacost < me.mana)) and a5.name ~= "rubick_empty1" then go = false end
								local speeddist = 0	
								local radius = spell:GetSpecialData('radius') or spell:GetSpecialData('area_of_effect') or distance or 100
								----
								if spell.name == "ember_spirit_fire_remnant" then speed = me.movespeed*2.5 if not config.EMBERUseUlti then go = false end end
								if speed then speeddist = math.abs(victimdistance-100)/speed end
								if ID == CDOTA_Unit_Hero_Lion and spell.name ~= "lion_voodoo" and a2 and a2:CanBeCasted() then go = false end
								if ID == CDOTA_Unit_Hero_ShadowShaman and spell.name ~= "shadow_shaman_voodoo" and a2 and a2:CanBeCasted() then go = false end
								if spell.name == "lion_impale" then speeddist = (victimdistance)/speed end
								if spell.name == "kunkka_torrent" and (a3:CanBeCasted() or a3.cd < 3) and a3.name == "kunkka_x_marks_the_spot" then go = false end
								--if spell.name == "earth_spirit_rolling_boulder" then speeddist = (victimdistance-100)/speed end
								if spell.name == "shadow_shaman_shackles" then channel = 0 end
								--if spell.name == "windrunner_powershot" then print((a1 and (a1:CanBeCasted() or a1.cd < 3)), (victimdistance+100 > a1.castRange and enemyHP <= Dmg), not chainStun(tempvictim,delay*0.001 + (100/Animations.maxCount)*0.001 + client.latency*0.001 + add + channel + me:GetTurnTime(tempvictim),nil,true)) end
								if spell.name == "windrunner_powershot" and ((a1 and enemyHP > Dmg and (a1:CanBeCasted() or a1.cd < 3 or not chainStun(tempvictim,delay*0.001 + (100/Animations.maxCount)*0.001 + client.latency*0.001 + add + channel + me:GetTurnTime(tempvictim),nil,true) or chainStun(tempvictim,delay*0.001 + (100/Animations.maxCount)*0.001 + client.latency*0.001 + add + me:GetTurnTime(tempvictim),nil,true)))) then go = false end
								if spell.name == "kunkka_ghostship" then
									if a3:CanBeCasted() and a3.name ~= "kunkka_return" then go = false end
									if a3.name == "kunkka_return" and not xposition then xposition = tempvictim.position end
								end
								if spell.name == "visage_soul_assumption" then 
									local modif = me:FindModifier("modifier_visage_soul_assumption")
									if not modif or (modif.stacks ~= spell.level+2 and Dmg < enemyHP) then
										go = false
									end
								end
								if spell.name == "disruptor_thunder_strike" and xposition and victimdistance > castRange then
									go = false
								end
								if spell.name == "gyrocopter_flak_cannon" then
									local closeEnemies = entityList:GetEntities(function (v) return (v.hero and not v:IsIllusion() and v.alive and v.team ~= me.team and v ~= tempvictim and GetDistance2D(me,v) < 1000) end)
									if #closeEnemies < 1 then
										go = false
									end
								end
								if spell.name == "dark_seer_ion_shell" then
									local closeEnemies = entityList:GetEntities(function (v) return (v.hero and v.alive and v ~= tempvictim and not v:DoesHaveModifier("modifier_dark_seer_ion_shell") and GetDistance2D(tempvictim,v) < 350) end)
									if #closeEnemies < 1 then
										go = false
									else
										tablesort(closeEnemies, function (a,b) return GetDistance2D(a,tempvictim) < GetDistance2D(b,tempvictim) end)
										local closest = closeEnemies[1]
										if closest then
											me:CastAbility(spell,closest) Sleep(300, "dark_seer_ion_shell") Sleep(delay, "casting") return
										end
									end
								end
								if spell.name == "dark_seer_surge" then
									local closeEnemies = entityList:GetEntities(function (v) return (v.hero and v.alive and v.team == me.team and v ~= tempvictim and GetDistance2D(tempvictim,v) < 1000) end)
									if #closeEnemies < 1 then
										go = false
									else
										tablesort(closeEnemies, function (a,b) return GetDistance2D(a,tempvictim) < GetDistance2D(b,tempvictim) end)
										local closest = closeEnemies[1]
										if closest then
											me:CastAbility(spell,closest) Sleep(300, "dark_seer_ion_shell") Sleep(delay, "casting") return
										end
									end
								end
								if spell.name == "dark_seer_wall_of_replica" then
									local closeEnemies = entityList:GetEntities(function (v) return (v.hero and not v:IsIllusion() and v.alive and v.team ~= me.team and v ~= tempvictim and GetDistance2D(tempvictim,v) < 700) end)
									if #closeEnemies < 3 then
										go = false
									end
								end
								if spell.name == "terrorblade_sunder" and SleepCheck("terrorblade_sunder") then
									local myPercent = me.health/me.maxHealth
									local possibleEnemies = entityList:GetEntities(function (v) return (v.hero and v.alive and GetDistance2D(me,v) < castRange+50 and v.health/v.maxHealth > (myPercent+0.3)) end)
									if myPercent > 0.5 then go = false
									elseif #possibleEnemies > 0 then
										local maxHP = nil
										for i = 1, #possibleEnemies do
											local v = possibleEnemies[i]
											if not maxHP or maxHP.health/maxHP.maxHealth < v.health/v.maxHealth then
												maxHP = v
											end
										end
										if maxHP then me:CastAbility(spell,maxHP) Sleep(300, "terrorblade_sunder") Sleep(delay, "casting") return
										else go = false end
									else
										go = false
									end
								end
								if spell.name == "warlock_fatal_bonds" then
									local closeUnits = entityList:GetEntities(function (v) return ((v.hero or v.creep) and v.team ~= me.team and v.alive and v ~= tempvictim and GetDistance2D(tempvictim,v) < 700) end)
									local closeEnemies = entityList:GetEntities(function (v) return (v.hero and v.alive and v.team ~= me.team and v ~= tempvictim and GetDistance2D(tempvictim,v) < 700) end)
									if #closeUnits < 2 and #closeEnemies < 1 then go = false
									elseif #closeUnits > 0 and victimdistance > castRange then
										tablesort(closeUnits, function (a,b) return GetDistance2D(a,me) < GetDistance2D(b,me) end)
										local closest = closeUnits[1]
										if closest and GetDistance2D(closest,me) < victimdistance then
											me:CastAbility(spell,closest) Sleep(300, "warlock_fatal_bonds") Sleep(delay, "casting") return
										end
									end
								end
								if spell.name == "ursa_enrage" and not retreat then
									local closeEnemies = entityList:GetEntities(function (v) return (v.hero and v.alive and v.team ~= me.team and v ~= tempvictim and GetDistance2D(tempvictim,v) < 700) end)
									if #closeEnemies < 1 then go = false end
								end
								if spell.name == "winter_wyvern_splinter_blast" then
									local closeUnits = entityList:GetEntities(function (v) return ((v.hero or v.creep) and v.team ~= me.team and v.alive and v ~= tempvictim and GetDistance2D(tempvictim,v) < 500) end)
									if #closeUnits < 1 then go = false
									elseif #closeUnits > 0 then
										tablesort(closeUnits, function (a,b) return GetDistance2D(a,tempvictim) < GetDistance2D(b,tempvictim) end)
										local closest = closeUnits[1]
										if closest then
											me:CastAbility(spell,closest) Sleep(300, "winter_wyvern_splinter_blast") Sleep(delay, "casting") return
										end
									end
								end
								if spell.name == "puck_ethereal_jaunt" then								
									local orb = FindEntity(entityList:GetEntities({classId=CDOTA_BaseNPC}),me,800,nil)
									if not orb then go = false
									elseif (GetDistance2D(tempvictim,orb) > 225 or GetDistance2D(me,orb)+200 < victimdistance) and GetDistance2D(PuckPosition,orb) < 1500 and (not retreat or GetDistance2D(PuckPosition,orb) < 1500) then go = false end
								end								
								if spell.name == "undying_tombstone" then
									local closeEnemies = entityList:GetEntities(function (v) return (v.hero and not v:IsIllusion() and v.alive and v.team ~= me.team and v ~= tempvictim and GetDistance2D(me,v) < 700) end)
									if #closeEnemies < 2 then
										go = false
									end
								end
								if spell.name == "earthshaker_echo_slam" then
									local closeUnits = entityList:GetEntities(function (v) return ((v.hero or v.creep) and v.team ~= me.team and v.alive and v ~= tempvictim and GetDistance2D(me,v) < 600) end)
									if #closeEnemies < 2 then
										go = false
									end
								end
								if spell.name == "undying_soul_rip" then
									local closeUnits = entityList:GetEntities(function (v) return ((v.hero or v.creep) and v.alive and v ~= tempvictim and GetDistance2D(me,v) < 1000) end)
									if #closeUnits < 3 then
										go = false
									end
								end
								--print(victimdistance, Dmg, range, castRange, enemyHP, delay, type) print(me.movespeed, spell.manacost, me.mana, Animations.maxCount, client.latency, add, channel, speeddist, me:GetTurnTime(tempvictim))
								local cast = nil
								local chanab = me:GetChanneledAbility()
								local chaindelay = delay*0.001 + (100/Animations.maxCount)*0.01 - ((client.latency/1000)/(1 + (1 - 1/Animations.maxCount))) + client.latency*0.001 + add + channel + speeddist + me:GetTurnTime(tempvictim)
								if spell.name == "phoenix_sun_ray" and me:DoesHaveModifier("modifier_phoenix_icarus_dive") then go = false end
								--print((1/Animations.maxCount)*3*(1 + (1 - 1/Animations.maxCount)))
								--print(SleepCheck(spell.name), ((not data[3] and spell.name ~= "invoker_sun_strike" and spell.name ~= "invoker_emp" and spell.name ~= "invoker_chaos_meteor") or (chainStun(tempvictim,chaindelay) and (spell.name ~= "earth_spirit_rolling_boulder" or victimdistance < 400))) and 
								--(not Dmg or data[3] or Dmg/4 < enemyHP or spell.name == "invoker_sun_strike" or spell.name == "ember_spirit_activate_fire_remnant" or (victimdistance > (range+200+(me.movespeed*(delay/1000))) and victimdistance < castRange+radius) or spell.name == "axe_culling_blade" or spell.name == "legion_commander_duel") and (spell.name ~= "sniper_assassinate" or victimdistance > range+100) and (spell.name ~= "shadow_shaman_mass_serpent_ward" or (victimdistance < castRange-50 and victimdistance > 300)) and (not data[5] or (spell.name ~= "axe_culling_blade" or Dmg >= tempvictim.health)) and ((victimdistance > (range+200+(me.movespeed*(delay/1000))) or (Dmg and Dmg > 0) or ((not Dmg or Dmg < 1) and enemyHP > 100))) and (not retreat or (Dmg and enemyHP and Dmg > enemyHP) or not data[11] or (data[3] and not data[11])))
								-- if spell.name == "invoker_chaos_meteor" then
									-- print((not data[3] and not tempvictim:IsInvul() and spell.name ~= "invoker_sun_strike" and spell.name ~= "invoker_emp" and spell.name ~= "invoker_chaos_meteor") , (chainStun(tempvictim,chaindelay) and (spell.name ~= "earth_spirit_rolling_boulder" or victimdistance < 400)))
								-- end
								if (not spell.abilityPhase or spell:FindCastPoint() <= 0) and not chanab and tempvictim and (not harras or (spell.manacost < me.mana*0.2 and victimdistance < range+100)) and (not tempvictim:IsMagicImmune() or type == DAMAGE_PHYS or data[10]) and go and SleepCheck(spell.name) and ((not data[3] and not tempvictim:IsInvul() and (ID == CDOTA_Unit_Hero_Invoker or SleepCheck("stuneth")) and ((not tempvictim:DoesHaveModifier("modifier_invoker_tornado") and not tempvictim:DoesHaveModifier("modifier_eul_cyclone")) or spell.name == "invoker_emp")) or (chainStun(tempvictim,chaindelay) and (spell.name ~= "earth_spirit_rolling_boulder" or victimdistance < 400))) and 
								(not Dmg or data[3] or Dmg/6 < enemyHP or spell.name == "invoker_sun_strike" or spell.name == "ember_spirit_activate_fire_remnant" or (victimdistance > (range+(me.movespeed*(delay/1000))) and victimdistance < castRange+radius) or spell.name == "axe_culling_blade" or spell.name == "legion_commander_duel") and (spell.name ~= "sniper_assassinate" or (victimdistance > range+100 and enemyHP < Dmg)) and (spell.name ~= "shadow_shaman_mass_serpent_ward" or (victimdistance > 100)) and (not data[5] or Dmg >= tempvictim.health) and ((victimdistance > (range+200+(me.movespeed*(delay/1000))) or (Dmg and Dmg > 0) or (not Dmg or Dmg < 1))) and (not retreat or (Dmg and enemyHP and Dmg > enemyHP) or not data[11] or (data[3] and not data[11])) then
									--print(spell.name)
									if spell.name == "shadow_shaman_shackles" then channel = spell:GetChannelTime(spell.level) end
									if spell.name == "bane_fiends_grip" then channel = spell:GetChannelTime(spell.level) end
									if spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_UNIT_TARGET) and spell.name ~= "magnataur_shockwave" and spell.name ~= "lion_impale" and tempvictimVisible and (spell.name ~= "earth_spirit_boulder_smash" or not a4:CanBeCasted()) and spell.name ~= "earth_spirit_geomagnetic_grip" then
										lastCastPrediction = nil
										if not me:IsMagicImmune() and spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALLIED) and not DoesHaveModifier("modifier_"..spell.name) and not DoesHaveModifier("modifier_"..spell.name.."_debuff") and not spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALL) and spell.name ~= "bloodseeker_bloodrage" then
											cast = me:SafeCastAbility(spell,me)
										elseif (spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ENEMY) or spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_CUSTOM) or spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALL)) and not tempvictim:IsInvul() and not tempvictim:DoesHaveModifier("modifier_eul_cyclone") and not tempvictim:DoesHaveModifier("modifier_invoker_tornado") and (victimdistance < mathmax(castRange+500, 1000) or spell.name == "kunkka_x_marks_the_spot") and (not retreat or victimdistance < castRange+50) and ((not tempvictim:DoesHaveModifier("modifier_"..spell.name) and not tempvictim:DoesHaveModifier("modifier_"..spell.name.."_debuff")) or spell.name == "bristleback_viscous_nasal_goo" or spell.name == "disruptor_glimpse") then
											if spell.name == "earth_spirit_boulder_smash" then	
												local remn = entityList:GetEntities({classId = CDOTA_Unit_Earth_Spirit_Stone})
												local found = false
												for i = 1, #remn do
													local v = remn[i]
													local calc1 = (mathfloor(mathsqrt((tempvictim.position.x-v.position.x)^2 + (tempvictim.position.y-v.position.y)^2)))
													local calc2 = (mathfloor(mathsqrt((me.position.x-v.position.x)^2 + (me.position.y-v.position.y)^2)))
													local calc4 = (mathfloor(mathsqrt((me.position.x-tempvictim.position.x)^2 + (me.position.y-tempvictim.position.y)^2)))
													if calc1 < calc4 and calc2 < calc4 and GetDistance2D(me,v) < 300 then
														found = true
														esstone = true
														cast = me:SafeCastAbility(spell,tempvictim)
														Sleep(me:GetTurnTime(tempvictim)*1000, "casting")
														Sleep(me:GetTurnTime(prediction)*1000+spell:FindCastPoint()*1000+((victimdistance+500)/speed)*1000+client.latency+200, "esstone")
														Sleep(me:GetTurnTime(prediction)*1000+client.latency+client.latency+spell:FindCastPoint()*1000, "moving")
														Sleep(me:GetTurnTime(tempvictim)*1000+spell:FindCastPoint()*1000+client.latency,spell.name)
														return
													end
												end
												local base = entityList:GetEntities({classId = CDOTA_Unit_Fountain,team = me.team})[1]
												if not found and victimdistance < 300 and GetDistance2D(me,base)+50 > GetDistance2D(tempvictim,base) then
													cast = me:SafeCastAbility(spell,tempvictim)
													Sleep(me:GetTurnTime(tempvictim)*1000, "casting")
													Sleep(me:GetTurnTime(prediction)*1000+client.latency+client.latency+spell:FindCastPoint()*1000, "moving")
													Sleep(me:GetTurnTime(tempvictim)*1000+spell:FindCastPoint()*1000+client.latency,spell.name)
													return
												end
											else
												cast = me:SafeCastAbility(spell,tempvictim)
												delay = delay + me:GetTurnTime(tempvictim)*1000 --+ (mathmax(victimdistance-50-castRange,0)/me.movespeed)*1000
												if spell.name == "spirit_breaker_charge_of_darkness" then Sleep(delay + me:GetTurnTime(tempvictim)*1000 + 1000, "charge") end
											end
										end
									elseif ((spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NO_TARGET) and spell.name ~= "slark_pounce" and spell.name ~= "nevermore_shadowraze1" and spell.name ~= "nevermore_shadowraze2" and spell.name ~= "nevermore_shadowraze3") or (spell.name == "invoker_deafening_blast" and quas.level == 7 and wex.level == 7 and exort.level == 7)) and tempvictimVisible and  
									((not tempvictim:DoesHaveModifier("modifier_"..spell.name) and (spell.name ~= "tinker_heat_seeking_missile" or not tempvictim:DoesHaveModifier("modifier_eul_cyclone")) and not tempvictim:DoesHaveModifier("modifier_"..spell.name.."_debuff") and not DoesHaveModifier("modifier_"..spell.name)) or spell.name == "bristleback_quill_spray") and tempvictimVisible and not DoesHaveModifier("modifier_"..spell.name.."_debuff") then
										lastCastPrediction = nil
										if spell.name == "invoker_ice_wall" and prediction and (GetDistance2D(me,prediction)-50) > 200 and (GetDistance2D(me,prediction)-50) < 610 then
											local mepred = SkillShotPredictedXYZ(me,client.latency+100)
											if not facing then
												mepred = (me.position - tempvictim.position) * 50 / GetDistance2D(me,tempvictim) + tempvictim.position
											end
											local v = {prediction.x-mepred.x,prediction.y-mepred.y}
											local mathacos = math.acos
											local a = mathacos(175/GetDistance2D(prediction,mepred))
											local vec1, vec2 = nil, nil
											if a ~= nil then
												local x1 = rotateX(v[1],v[2],a)
												local y1 = rotateY(v[1],v[2],a)
												if x1 and y1 then      
													local k = {x1*50/mathsqrt((x1*x1)+(y1*y1)),y1*50/mathsqrt((x1*x1)+(y1*y1))}
													vec1 = Vector(k[1]+mepred.x,k[2]+mepred.y,mepred.z)
												end
											end
											if not vec1 then vec1 = vec2 end
											if vec1 and vec2 and me:GetTurnTime(vec2) < me:GetTurnTime(vec1) then
												vec1 = vec2
											end
											if vec1 and GetDistance2D(me,vec1) > 0 then
												me:Move(mepred)
												me:Move(vec1,true)
												cast = me:SafeCastAbility(spell,true)
												Sleep((GetDistance2D(me,vec1)/me.movespeed)*1000+me:GetTurnTime(vec1)*1000+500, "casting")
												Sleep((GetDistance2D(me,vec1)/me.movespeed)*1000+me:GetTurnTime(vec1)*1000+500, "moving")
												return
											end
										elseif (spell.name ~= "templar_assassin_meld" or (not retreat and not CanMove and GetDistance2D(mePosition,SkillShotPredictedXYZ(tempvictim,client.latency+spell:FindCastPoint()*1000+me:GetTurnTime(tempvictim)*1000)) <= range+50)) then													
											if spell.name ~= "invoker_ice_wall" or (retreat or facing) then
												local prediction = SkillShotSkillShotXYZ(mePosition,tempvictim,delay,999999)
												if prediction and (not distance or GetDistance2D(prediction,mePosition) < distance or a2.name == "elder_titan_return_spirit") then
													cast = me:SafeCastAbility(spell)
												end
											end
											if spell.name == "templar_assassin_meld" then
												me:Attack(tempvictim)
												delay = delay + me:GetTurnTime(tempvictim)*1000 + Animations.GetAttackTime(me)*1000
												Sleep(delay + me:GetTurnTime(tempvictim)*1000 + Animations.GetAttackTime(me)*1000 + client.latency, "casting")
											end
										end
									elseif spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_POINT) or spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_AOE) or spell.name == "slark_pounce" or (spell.name == "nevermore_shadowraze1" and prediction and GetDistance2D(prediction,raze1) < 250) or (spell.name == "nevermore_shadowraze2" and prediction and GetDistance2D(prediction,raze2) < 250) or (spell.name == "nevermore_shadowraze3" and prediction and GetDistance2D(prediction,raze3) < 250) then
										--print(spell.name, prediction, )
										if not me:IsMagicImmune() and spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALLIED) and not spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ENEMY) and spell.name ~= "earth_spirit_geomagnetic_grip" then
											lastCastPrediction = nil
											cast = me:SafeCastAbility(spell,me.position)
										elseif ((prediction and tempvictimAlive and (GetDistance2D(prediction,mePosition) < castRange+radius or (xposition and GetDistance2D(xposition,me) < castRange+radius))) or (spell.name == "earth_spirit_rolling_boulder" and retreat)) then
											delay = delay + me:GetTurnTime(tempvictim)*1000
											local delay2 = delay + client.latency + channel*1000 + ((1 / Animations.maxCount) * 3 * (1 + (1 - 1/ Animations.maxCount)))*1000
											if data[4] then delay2 = delay2 + data[4]*1000 end
											local prediction
											if not speed or speed == 0 then speed = 9999999 end
											if tempvictimVisible then
												if data[7] then
													local radius = spell:GetSpecialData(data[8], spell.level)
													prediction = SkillShotBlockableSkillShotXYZ(mePosition,tempvictim,speed,delay2,radius,data[9])
													if prediction then
														prediction = SkillShotBlockableSkillShotXYZ(mePosition,tempvictim,speed,delay2+me:GetTurnTime(prediction)*1000,radius,data[9])
													end
												else
													prediction = SkillShotSkillShotXYZ(mePosition,tempvictim,delay2,speed,radius)
													if prediction then
														prediction = SkillShotSkillShotXYZ(mePosition,tempvictim,delay2+me:GetTurnTime(prediction)*1000,speed,radius)
													end
												end
											else
												if data[7] then
													local radius = spell:GetSpecialData(data[8], spell.level)
													prediction = SkillShot.BlockableBlindSkillShotXYZ(me,tempvictim,speed,delay2/1000,radius,data[9])
												else
													prediction = SkillShot.BlindSkillShotXYZ(me,tempvictim,speed,delay2/1000)
												end
											end
											if spell.name == "rubick_telekinesis_land" then prediction = me.position end
											if xposition then prediction = xposition end
											if prediction or (spell.name == "earth_spirit_rolling_boulder" and retreat) then
												local preddist = 0
												if spell.name == "skywrath_mage_mystic_flare" then
													if (not chainStun(tempvictim, delay2, nil, true) and (not tempvictim:IsStunned() and not tempvictim:IsHexed() and not tempvictim:IsRooted()) and enemyHP > Dmg and not tempvictim:DoesHaveModifier("modifier_skywrath_mage_concussive_shot_slow")) or tempvictim:DoesHaveModifier("modifier_eul_cyclone") or tempvictim:DoesHaveModifier("modifier_invoker_tornado") then
														go = false
													end
												end
												if spell.name == "storm_spirit_ball_lightning" then
													local pull = a2
													local manaReq = (15 + me.maxMana*0.07 + ((preddist*0.01)*(12+(me.maxMana*0.0075))))
													if me.mana < manaReq then
														go = false
													elseif pull and pull:CanBeCasted() and (me.mana-pull.manacost) < manaReq then
														go = false
													end
												end
												if spell.name == "ember_spirit_fire_remnant" then
													if me.mana < 150 or (victimdistance < 500 and not retreat) then go = false end
													if retreat then prediction = client.mousePosition
														prediction = (prediction - me.position) * 1500 / GetDistance2D(prediction,me) + me.position
													else
														local ulti = me:FindSpell("ember_spirit_activate_fire_remnant")
														if not tempdamageTable["ember_spirit_activate_fire_remnant"] or tempdamageTable["ember_spirit_activate_fire_remnant"][2] ~= ulti.level then
															damageTable["ember_spirit_activate_fire_remnant"] = {AbilityDamageGetDamage(ulti), ulti.level, me:AghanimState()}
															tempdamageTable = damageTable
														end
														local ultiDamage = tempdamageTable["ember_spirit_activate_fire_remnant"][1]
														ultiDamage = tempvictim:DamageTaken(ultiDamage,DAMAGE_MAGC,me)
														if me.mana < 260 and enemyHP > ultiDamage then go = false end
														if ((me.mana > 650 and enemyHP < ultiDamage*3) or (me.mana > 300 and enemyHP < ultiDamage*2)) and (tempvictim:IsStunned() or tempvictim:IsRooted()) and victimdistance < 500 and speed > 500 then delay = 0 go = true  
														else 
														local remnants = entityList:GetEntities({classId=CDOTA_BaseNPC_Additive, team=me.team, alive=true})
														for i = 1, #remnants do
															local v = remnants[i]
															if GetDistance2D(v,prediction) < 500 then
																go = false
															end
														end
														delay = delay + (victimdistance/speed)*1000 - (victimdistance/1300)*1000 end
													end
												end
												if prediction then preddist = GetDistance2D(prediction,mePosition) end
												if preddist < castRange+radius then
													if preddist > castRange then	
														if ID == CDOTA_Unit_Hero_EmberSpirit then
															prediction = (prediction - mePosition) * ((castRange+300) - (radius/2)) / preddist + mePosition
														elseif spell.name ~= "tusk_ice_shards" then
															prediction = (prediction - mePosition) * (castRange-100) / preddist + mePosition
														end
													end
													if ID == CDOTA_Unit_Hero_Invoker then
														local tornado = me:FindSpell("invoker_tornado")
														if tornado then
															local tornadocd = tornado:GetCooldown(tornado.level)
															if octa then
																tornadocd = tornadocd*0.75
															end
															tornadocd = tornadocd-((GetDistance2D(me,tempvictim))/1000+client.latency/1000)-0.1
															if tornado and (tornado.cd > tornadocd or tornado:CanBeCasted()) then
																prediction = tempvictim.position
															end
														end
													end
													if spell.name == "tusk_ice_shards" then
														prediction = (prediction - tempvictim.position) * (GetDistance2D(prediction,tempvictim)+200) / GetDistance2D(prediction,tempvictim) + tempvictim.position
													elseif spell.name == "earthshaker_fissure" then
														prediction = (prediction - tempvictim.position) * (GetDistance2D(prediction,tempvictim)+225) / GetDistance2D(prediction,tempvictim) + tempvictim.position
													end
													if spell.name == "invoker_emp" and GetDistance2D(prediction,tempvictim) > 675 then
														prediction = (prediction - tempvictim.position) * (GetDistance2D(prediction,tempvictim)/2) / GetDistance2D(prediction,tempvictim) + tempvictim.position
														if combo ~= 0 and combo ~= 3 then prediction = client.mousePosition end
													end
													if spell.name == "bloodseeker_blood_bath" and GetDistance2D(prediction,tempvictim) > 300 then
														prediction = (prediction - tempvictim.position) * (GetDistance2D(prediction,tempvictim)/2) / GetDistance2D(prediction,tempvictim) + tempvictim.position
														if combo ~= 0 and combo ~= 3 then prediction = client.mousePosition end
													end
													if ID == CDOTA_Unit_Hero_Rubick and spell.name ~= "rubick_telekinesis_land" then
														if tempvictim:DoesHaveModifier("modifier_rubick_telekinesis") then
															prediction = (mePosition - tempvictim.position) * (math.min(victimdistance,275)) / GetDistance2D(me,tempvictim.position) + tempvictim.position
														end
													end
													if spell.name == "invoker_sun_strike" then
														local spell1,spell2 = a4, a5							
														if (not chainStun(tempvictim, delay2, nil, true) and not tempvictim:IsStunned() and not tempvictim:IsRooted() and not tempvictim:DoesHaveModifier("modifier_eul_cyclone") and not tempvictim:IsHexed() and not tempvictim:DoesHaveModifier("modifier_invoker_tornado")) and enemyHP > Dmg then
															go = false
														end
														if GetDistance2D(prediction,tempvictim) > 50 and ((((spell1.name == "invoker_cold_snap" and spell1:CanBeCasted()) or (spell2.name == "invoker_cold_snap" and spell2:CanBeCasted()))) or tempvictim:DoesHaveModifier("modifier_invoker_ice_wall_slow_debuff") or tempvictim:DoesHaveModifier("modifier_invoker_cold_snap") or tempvictim:DoesHaveModifier("modifier_invoker_cold_snap_freeze")) then
															if victimdistance < range/1.5 then
																prediction = (prediction - tempvictim.position) * (GetDistance2D(prediction,tempvictim)/2) / GetDistance2D(prediction,tempvictim) + tempvictim.position
															else
																prediction = (prediction - tempvictim.position) * (GetDistance2D(prediction,tempvictim)/1.5) / GetDistance2D(prediction,tempvictim) + tempvictim.position
															end
															go = true
														end
														if tempvictim.activity == LuaEntityNPC.ACTIVITY_MOVE and directiontable[tempvictim.handle] and directiontable[tempvictim.handle][3] < 3 then go = false end
														--local refresher = me:FindItem("item_refresher")
														--if combo == 3 or combo == 2 then
														local blast = me:FindSpell("invoker_deafening_blast")
														if blast then
															local blastcd = blast:GetCooldown(blast.level)
															if octa then
																blastcd = blastcd*0.75
															end
															blastcd = blastcd-((GetDistance2D(me,tempvictim)+100)/1100+client.latency/1000)
															if blast and (blast.cd > blastcd or blast:CanBeCasted() or tempvictim:DoesHaveModifier("modifier_invoker_deafening_blast_knockback")) then
																if tempvictim:DoesHaveModifier("modifier_invoker_deafening_blast_knockback") then
																	prediction = (tempvictim.position - me.position) * (GetDistance2D(tempvictim,me)+100) / GetDistance2D(tempvictim,me) + me.position
																elseif GetDistance2D(tempvictim,prediction) > 50 then																
																	prediction = (prediction - me.position) * (GetDistance2D(prediction,me)+200) / GetDistance2D(prediction,me) + me.position
																else
																	prediction = (tempvictim.position - me.position) * (GetDistance2D(tempvictim,me)+200) / GetDistance2D(tempvictim,me) + me.position
																end
															end
														end
														--end
														-- if combo == 2 then
															-- if refresher.cd > 0 and comboready and GetDistance2D(tempvictim,prediction) > 50 then
																-- prediction = (prediction - me.position) * (GetDistance2D(prediction,me)+100) / GetDistance2D(prediction,me) + me.position
															-- end
														-- end
													end
													if spell.name == "invoker_chaos_meteor" then
														--print(gameTime)
														local spell1,spell2 = a4, a5
														if ((not chainStun(tempvictim, delay2, nil, true) and combo == 0) and not tempvictim:IsStunned() and not tempvictim:IsHexed() and not tempvictim:IsRooted() and not tempvictim:DoesHaveModifier("modifier_eul_cyclone") and not tempvictim:DoesHaveModifier("modifier_invoker_tornado")) and (enemyHP > Dmg/4 or victimdistance > 500) then
															go = false
														end
														if ((spell1.name == "invoker_deafening_blast" and spell1:CanBeCasted()) or (spell2.name == "invoker_deafening_blast" and spell2:CanBeCasted())) then
															go = true
														end
														if GetDistance2D(prediction,tempvictim) > 50 and ((((spell1.name == "invoker_cold_snap" and spell1:CanBeCasted()) or (spell2.name == "invoker_cold_snap" and spell2:CanBeCasted())) and victimdistance < range/1.5) or tempvictim:DoesHaveModifier("modifier_invoker_ice_wall_slow_debuff") or tempvictim:DoesHaveModifier("modifier_invoker_cold_snap")) then
															prediction = (prediction - tempvictim.position) * (GetDistance2D(prediction,tempvictim)/2) / GetDistance2D(prediction,tempvictim) + tempvictim.position
															go = true
														end
														--if combo ~= 0 and combo ~= 3 then prediction = client.mousePosition end
														if comb == 3 then
															local blast = me:FindSpell("invoker_deafening_blast")
															local blastcd = blast:GetCooldown(blast.level)
															if octa then
																blastcd = blastcd*0.75
															end
															blastcd = blastcd-((GetDistance2D(me,tempvictim)+100)/1100+client.latency/1000)
															if blast and (blast.cd > blastcd or blast:CanBeCasted() or tempvictim:DoesHaveModifier("modifier_invoker_deafening_blast_knockback")) then
																if tempvictim:DoesHaveModifier("modifier_invoker_deafening_blast_knockback") then
																	prediction = (tempvictim.position - me.position) * (GetDistance2D(tempvictim,me)+50) / GetDistance2D(tempvictim,me) + me.position
																elseif GetDistance2D(tempvictim,prediction) > 50 then																
																	prediction = (prediction - me.position) * (GetDistance2D(prediction,me)+100) / GetDistance2D(prediction,me) + me.position
																else
																	prediction = (tempvictim.position - me.position) * (GetDistance2D(tempvictim,me)+100) / GetDistance2D(tempvictim,me) + me.position
																end
															end
														end
													end
													-- if spell.name == "dark_seer_vacuum" then
														-- local closeEnemies = entityList:GetEntities(function (v) return (v.hero and not v:IsIllusion() and v.alive and v.team ~= me.team and v ~= tempvictim and GetDistance2D(tempvictim,
														-- PredictedXYZ(v,delay)) < radius*2+50) end)
														-- --print(radius)
														-- if #closeEnemies > 0 then
															-- local avpos = nil
															-- for i = 1, #closeEnemies do	
																-- if not avpos then avpos = SkillShotPredictedXYZ(closeEnemies[i],delay)
																-- else avpos = avpos + SkillShotPredictedXYZ(closeEnemies[i],delay) end
															-- end
															-- avpos = avpos/#closeEnemies
															-- prediction = (prediction + avpos)/2
														-- else
															-- prediction = (mePosition - prediction) * (radius/2-200) / GetDistance2D(me,prediction) + prediction
														-- end
													-- end
													if spell.name == "puck_illusory_orb" and retreat then prediction = client.mousePosition end
													--if spell.name == "invoker_tornado" and combo ~= 0 and combo ~= 3 then prediction = client.mousePosition end
													if spell.name == "ember_spirit_sleight_of_fist" and prediction then
														local position = nil
														local unitnum = 0
														local closest = nil
														if a1 and a1:CanBeCasted() and enemyHP > Dmg then
															local units = {}
															local unitsCount = 0
															local lanecreeps = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Lane,team=me:GetEnemyTeam(),visible=true})
															local fam = entityList:GetEntities({classId=CDOTA_Unit_VisageFamiliar,team=me:GetEnemyTeam(),visible=true})
															local boar = entityList:GetEntities({classId=CDOTA_Unit_Hero_Beastmaster_Boar,team=me:GetEnemyTeam(),visible=true})
															local forg = entityList:GetEntities({classId=CDOTA_BaseNPC_Invoker_Forged_Spirit,team=me:GetEnemyTeam(),visible=true})
															for i = 1, #lanecreeps do local v = lanecreeps[i] if not v:IsInvul() and v.alive and v.spawned then unitsCount = unitsCount + 1 units[unitsCount] = v end end
															for i = 1, #fam do local v = fam[i] if not v:IsInvul() and v.alive and not v:IsAttackImmune() then unitsCount = unitsCount + 1 units[unitsCount] = v end end
															for i = 1, #boar do local v = boar[i] if not v:IsInvul() and v.alive and not v:IsAttackImmune() then unitsCount = unitsCount + 1 units[unitsCount] = v end end 
															for i = 1, #forg do local v = forg[i] if not v:IsInvul() and v.alive and not v:IsAttackImmune() then unitsCount = unitsCount + 1 units[unitsCount] = v end end
															for i = 1, unitsCount do
																local v = units[i]
																if GetDistance2D(v,prediction) < (radius/2)+300 then
																	if not position then
																		position = v.position
																		unitnum = 1
																	else
																		position = position + v.position
																		unitnum = unitnum + 1
																	end
																	if not closest or GetDistance2D(v,prediction) < GetDistance2D(closest,prediction) then
																		closest = v
																	end
																end
															end
														end
														if closest then
															prediction = (prediction - closest.position) * (GetDistance2D(closest,prediction)+200+(radius/2)) / GetDistance2D(prediction,closest) + closest.position
														end
														if GetDistance2D(tempvictim,prediction) > ((radius/2)+200) then	
															prediction = (prediction - mePosition) * (castRange+200) / GetDistance2D(me,prediction) + mePosition
														end
													end
													if ((prediction and GetDistance2D(prediction,mePosition) < castRange+100) or (spell.name == "earth_spirit_rolling_boulder" and retreat)) and go then
														if spell.name ~= "slark_pounce" and spell.name ~= "nevermore_shadowraze1" and spell.name ~= "nevermore_shadowraze2" and spell.name ~= "nevermore_shadowraze3" and spell.name ~= "earth_spirit_boulder_smash" then
														--	if spell.name == "invoker_sun_strike" then print("asd") end
															if radius and radius > 0 and not data[7] then
																local closeEnemies = entityList:GetEntities(function (v) return (v.hero and not v:IsIllusion() and v.alive and v.team ~= me.team and v ~= tempvictim and GetDistance2D(tempvictim,SkillShotPredictedXYZ(v,delay)) < radius*2+50) end)
																--print(radius)
																if #closeEnemies > 0 then
																	local avpos = nil
																	for i = 1, #closeEnemies do	
																		if not avpos then avpos = SkillShotPredictedXYZ(closeEnemies[i],delay)
																		else avpos = avpos + SkillShotPredictedXYZ(closeEnemies[i],delay) end
																	end
																	avpos = avpos/#closeEnemies
																	prediction = (prediction + avpos)/2
																--else
																	--prediction = (mePosition - prediction) * (radius/2-200) / GetDistance2D(me,prediction) + prediction
																end
															end
															if spell.name == "earth_spirit_rolling_boulder" then
																local smash = a1
																local smashcd = smash:GetCooldown(smash.level)
																if octa then
																	smashcd = smashcd*0.75
																end
																smashcd = smashcd-2
																if smash and (smash.cd > smashcd or smash.abilityPhase) and tempvictimVisible then
																	prediction = SkillShotSkillShotXYZ(mePosition,tempvictim,0.00001,1600,radius)
																end
																if retreat or EStoMouse then
																	prediction = client.mousePosition
																end
																local remn = entityList:GetEntities({classId = CDOTA_Unit_Earth_Spirit_Stone})
																local found = false
																for i = 1, #remn do
																	local v = remn[i]
																	local calc1 = (mathfloor(mathsqrt((prediction.x-v.position.x)^2 + (prediction.y-v.position.y)^2)))
																	local calc2 = (mathfloor(mathsqrt((me.position.x-v.position.x)^2 + (me.position.y-v.position.y)^2)))
																	local calc4 = (mathfloor(mathsqrt((me.position.x-prediction.x)^2 + (me.position.y-prediction.y)^2)))
																	if calc1 < calc4 and calc2 < calc4 and GetDistance2D(me,v) < 360 then
																		found = true
																		cast = me:SafeCastAbility(spell,prediction)
																		Sleep(spell:FindCastPoint()*1000+600,"moving")
																		Sleep(spell:FindCastPoint()*1000+600,spell.name)
																		return
																	end
																end
																if not found and (victimdistance > 800 or retreat) then
																	local stone = a4
																	if stone and stone:CanBeCasted() and SleepCheck("stone") then
																		local vector = (prediction - me.position) * 200 / GetDistance2D(prediction,me) + me.position
																		me:CastAbility(stone, vector)
																		cast = me:SafeCastAbility(spell,prediction)
																		Sleep(spell:FindCastPoint()*1000+600,"moving")
																		Sleep(spell:FindCastPoint()*1000+600,spell.name)
																		Sleep(100+client.latency,"stone")
																		return
																	end
																elseif not found then
																	cast = me:SafeCastAbility(spell,prediction)
																	Sleep(spell:FindCastPoint()*1000+600,"moving")
																	Sleep(spell:FindCastPoint()*1000+600,spell.name)
																	return
																end
															end
															if spell.name == "earth_spirit_geomagnetic_grip" then
																local remn = entityList:GetEntities({classId = CDOTA_Unit_Earth_Spirit_Stone, alive=true, visible = true})
																local found = nil
																for i = 1, #remn do
																	local v = remn[i]
																	if not found and GetDistance2D(tempvictim,v) < 300 and GetDistance2D(me,tempvictim) <= GetDistance2D(me,v) then
																		found = v
																	end
																	if GetDistance2D(me,v) < castRange+50 then
																		local calc1 = (mathfloor(mathsqrt((v.position.x-tempvictim.position.x)^2 + (v.position.y-tempvictim.position.y)^2)))
																		local calc2 = (mathfloor(mathsqrt((me.position.x-tempvictim.position.x)^2 + (me.position.y-tempvictim.position.y)^2)))
																		local calc4 = (mathfloor(mathsqrt((me.position.x-v.position.x)^2 + (me.position.y-v.position.y)^2)))
																		if GetDistance2D(me,v) <= (GetDistance2D(me,tempvictim)+GetDistance2D(tempvictim,v)) and GetDistance2D(me,v)+500 > (GetDistance2D(me,tempvictim)+GetDistance2D(tempvictim,v)) then
																			found = v
																		end
																		if not found and calc1 < calc4 and calc2 < calc4 and GetDistance2D(me,v) < castRange+50 then
																			found = v
																		end
																	end
																end	
																local smash = a1
																if found or esstone then
																	if found then
																		local vec = (found.position - me.position) * (GetDistance2D(found,me)+client.latency*1.2) / GetDistance2D(found,me) + me.position
																		cast = me:SafeCastAbility(spell,vec)
																		cast = me:SafeCastAbility(spell,found.position)
																	end
																	lastCastPrediction = tempvictim.position
																 elseif GetDistance2D(prediction,me) < castRange+50 then
																	local stone = a4
																	if stone and stone:CanBeCasted() and SleepCheck("stone") then
																		me:CastAbility(stone, prediction)
																		cast = me:SafeCastAbility(spell,prediction)
																		lastCastPrediction = prediction
																		Sleep(100+client.latency,"stone")
																	end
																end
															elseif spell.name ~= "kunkka_ghostship" or GetDistance2D(me,prediction) > 750 then
																if spell.name == "magnataur_skewer" then
																	prediction = (prediction - me.position) * 1400 / GetDistance2D(prediction,me) + me.position
																end
																lastPrediction = {prediction, tempvictim.rotR}
																lastCastPrediction = prediction
																cast = me:SafeCastAbility(spell,prediction)
																delay = delay + (mathmax(GetDistance2D(prediction,mePosition)-50-castRange,0)/me.movespeed)*1000
																if spell.name == "ancient_apparition_ice_blast" then delay = delay + (mathmax(GetDistance2D(prediction,mePosition)-50,0)/speed)*1000 end
																if spell.name == "ember_spirit_sleight_of_fist" then
																	delay = me:GetTurnTime(prediction)*1000
																end
															end
														elseif ((spell.name ~= "nevermore_shadowraze1" and spell.name ~= "nevermore_shadowraze2" and spell.name ~= "nevermore_shadowraze3") or (not retreat or Dmg > enemyHP)) and (meDmg < Dmg or victimdistance > range+100 or ID == CDOTA_Unit_Hero_EarthSpirit) then
															if not speed or speed == 0 then speed = 9999999 end
															if ID == CDOTA_Unit_Hero_EarthSpirit then
																if not tempvictimVisible then
																	prediction = SkillShot.BlindSkillShotXYZ(me,tempvictim,speed,me:GetTurnTime(prediction)+client.latency/1000+(100/Animations.maxCount)/1000 - ((client.latency/1000)/(1 + (1 - 1/Animations.maxCount))))
																else
																	prediction = SkillShotSkillShotXYZ(mePosition,tempvictim,me:GetTurnTime(prediction)*1000+client.latency+(100/Animations.maxCount) - ((client.latency/1000)/(1 + (1 - 1/Animations.maxCount)))*1000,speed,radius)
																end
															elseif not tempvictimVisible then
																prediction = SkillShot.BlindSkillShotXYZ(me,tempvictim,speed,me:GetTurnTime(prediction)+client.latency/1000+(100/me.movespeed)+(100/Animations.maxCount)/1000 - ((client.latency/1000)/(1 + (1 - 1/Animations.maxCount))))
															else
																prediction = SkillShotSkillShotXYZ(mePosition,tempvictim,me:GetTurnTime(prediction)*1000+client.latency+(100/me.movespeed)*1000+(100/Animations.maxCount) - ((client.latency/1000)/(1 + (1 - 1/Animations.maxCount)))*1000,speed,radius)
															end
															if spell.name == "slark_pounce" and retreat then
																prediction = client.mousePosition
															end
															if SleepCheck("movetoprediction") and prediction and (spell.name ~= "earth_spirit_boulder_smash" or a4:CanBeCasted()) and (GetDistance2D(me,prediction) < castRange+100 or (distance and GetDistance2D(me,prediction) < distance+100)) then
																-- local mepred = SkillShotPredictedXYZ(me,client.latency+100)
																-- if not facing then
																	-- mepred = (me.position - tempvictim.position) * 25 / GetDistance2D(me,tempvictim) + tempvictim.position
																-- end
																-- local vector = (prediction - mepred) * 25 / GetDistance2D(prediction,mepred) + mepred
																local vector = prediction
																if GetDistance2D(me,vector) < 200 then 
																	vector = (me.position - vector) * 500 / GetDistance2D(me.position,vector) + vector
																end
																if victimdistance < 150 then me:Attack(tempvictim)
																else me:Move(vector) end
																Sleep(me:GetTurnTime(prediction)*1000+client.latency+delay, "moving")
																Sleep(200, "movetoprediction")
															end
															if prediction and ((mathmax(mathabs(FindAngleR(me) - mathrad(FindAngleBetween(me, prediction))) - 0.40, 0)) == 0 or spell.name == "earth_spirit_boulder_smash") and (spell.name ~= "slark_pounce" or ((mathmax(mathabs(FindAngleR(me) - mathrad(FindAngleBetween(me, prediction))) - 0.10, 0)) == 0))  then
																if spell.name == "earth_spirit_boulder_smash" then
																	if EStoMouse and not retreat then prediction = client.mousePosition end
																	local stone = a4
																	local remn = entityList:GetEntities({classId = CDOTA_Unit_Earth_Spirit_Stone})
																	local found = false
																	local foundStone = nil
																	for i = 1, #remn do
																		local v = remn[i]
																		local calc1 = (mathfloor(mathsqrt((tempvictim.position.x-v.position.x)^2 + (tempvictim.position.y-v.position.y)^2)))
																		local calc2 = (mathfloor(mathsqrt((me.position.x-v.position.x)^2 + (me.position.y-v.position.y)^2)))
																		local calc4 = (mathfloor(mathsqrt((me.position.x-tempvictim.position.x)^2 + (me.position.y-tempvictim.position.y)^2)))
																		if calc1 < calc4 and calc2 < calc4 and GetDistance2D(me,v) < 300 then
																			found = true
																			foundStone = v
																		end
																	end
																	if (stone and stone:CanBeCasted()) or found then
																		esstone = true
																		if not found and SleepCheck("stone") then
																			local vector = (prediction - me.position) * 200 / GetDistance2D(prediction,me) + me.position
																			me:CastAbility(stone, vector)
																			Sleep(100+client.latency,"stone")
																		end
																		cast = me:SafeCastAbility(spell,prediction)
																		if foundStone then
																			Sleep(me:GetTurnTime(prediction)*1000+spell:FindCastPoint()*1000, "casting")
																		else
																			Sleep(me:GetTurnTime(prediction)*1000+spell:FindCastPoint()*1000, "casting")
																		end
																		Sleep(me:GetTurnTime(prediction)*1000+spell:FindCastPoint()*1000+((GetDistance2D(me,prediction))/speed)*1000+client.latency+1000, "esstone")
																		Sleep(me:GetTurnTime(prediction)*1000+spell:FindCastPoint()*1000+client.latency, spell.name)
																		Sleep(me:GetTurnTime(prediction)*1000+client.latency+client.latency+spell:FindCastPoint()*1000, "moving")
																		return
																	end
																else
																	lastPrediction = {prediction, tempvictim.rotR}
																	cast = me:SafeCastAbility(spell)
																end
																if cast then
																	Sleep(me:GetTurnTime(prediction)*1000+client.latency+spell:FindCastPoint()*1000, "casting")
																	Sleep(me:GetTurnTime(prediction)*1000+client.latency+2000, spell.name)
																	return
																end
															end
															return
														end
													end
												end
											end
										end
									end
								end
								if cast then
									--if spell.name == "kunkka_ghostship" then Sleep(3000,"stun") end
									if spell.name == "batrider_flaming_lasso" then delay = delay + 200 end
									if spell.name == "invoker_ghost_walk" then Sleep(1000, "casting") Sleep(1000, "casting2") Sleep(1000, "casting3") end
									if spell.name == "invoker_sun_strike" then Sleep(delay+100,"moving") end 
									if spell.name ~= "ancient_apparition_ice_blast" and spell.name ~= "pudge_meat_hook" then
										if spell.name ~= "ember_spirit_sleight_of_fist" then
											Sleep(delay-spell:FindCastPoint()*1000+client.latency,"moving")
										else
											mePosition = tempvictim.position
											Sleep(spell:FindCastPoint()*1000+client.latency+300,"blink")
											Sleep(spell:FindCastPoint()*1000+client.latency+300,"moving")
										end
									end
									if spell.name == "riki_blink_strike" then Sleep(delay+client.latency+Animations.GetAttackTime(me)*1000+Animations.getBackswingTime(me)*1000, spell.name) end
									if spell.name == "earth_spirit_geomagnetic_grip" then Sleep(100, spell.name) return end
									if spell.name == "leshrac_pulse_nova" then Sleep(500, spell.name) return end
									if spell.name == "kunkka_torrent" then Sleep(500,spell.name) end
									if channel and channel > 0 then if victimdistance < castRange+150 or (distance and victimdistance < distance+150) or (lastCastPrediction and GetDistance2D(mePosition,lastCastPrediction) < castRange+150) then channelactive = true delay = delay + 600 if spell.name ~= "pudge_dismember" then Sleep(delay + channel*1000 + 200, spell.name) end end
									elseif data[3] and spell.name ~= "ember_spirit_fire_remnant" and spell.name ~= "ancient_apparition_cold_feet" and spell.name ~= "invoker_emp" and spell.name ~= "ursa_earthshock" and spell.name ~= "earth_spirit_boulder_smash" and spell.name ~= "earth_spirit_geomagnetic_grip" and spell.name ~= "earth_spirit_rolling_boulder" and spell.name ~= "kunkka_torrent" then Sleep(delay+mathmax(add,0.4)*1000+client.latency,"stun") end
									if spell.name == "ember_spirit_fire_remnant" then
										local ultiDamage = tempdamageTable["ember_spirit_activate_fire_remnant"][1]
										ultiDamage = tempvictim:DamageTaken(ultiDamage,DAMAGE_MAGC,me)
										if me.mana > 650 and enemyHP < ultiDamage*3 and (tempvictim:IsStunned() or tempvictim:IsRooted()) and victimdistance < 500 and speed > 500 then delay = 0   
										else 
										Sleep(delay + (victimdistance/speed)*1000, spell.name) end
									elseif spell.name == "kunkka_x_marks_the_spot" then
										Sleep(1000, spell.name)
									elseif spell.name == "rubick_telekinesis_land" then
										Sleep(1000, spell.name)
									elseif spell.name ~= "pudge_dismember" then
										--print(delay)
										Sleep(delay, spell.name)
									end
									if spell.name == "troll_warlord_whirling_axes_ranged" then
										local melee = me:FindSpell("troll_warlord_whirling_axes_melee")
										if melee.cd > 0 then
											trolltoggle = true
										end
									end
									--print(spell.name)
									--if spell.name == "huskar_life_break" and not me:DoesHaveModifier("modifier_item_armlet_unholy_strength") then Sleep(delay+500,"item_armlet") end
									--if spell.name == "pudge_dismember" then delay = delay + 500 end
									--if spell.name == "phoenix_sun_ray" then print(Dmg) end
									if spell.name == "phoenix_launch_fire_spirit" then Sleep(2000,spell.name) end
									if spell.name == "phoenix_icarus_dive" then Sleep(1000,"phoenix_icarus_dive_stop") Sleep(1000,"phoenix_sun_ray") end
									if spell.name ~= "ember_spirit_sleight_of_fist" and spell.name ~= "earth_spirit_geomagnetic_grip" then
										if victimdistance < castRange+150 or (distance and victimdistance < distance+150) or (lastCastPrediction and GetDistance2D(mePosition,lastCastPrediction) < castRange+150) then
											if spell.name == "tusk_snowball" then tuskSnowBall = true end
											if spell.name == "windrunner_shackleshot" and a2 and a2:CanBeCasted() then Sleep(delay+((victimdistance)/speed)*1000+750+client.latency,"stun") Sleep(delay+((victimdistance)/speed)*1000+500,"casting") end
											if spell.name == "invoker_tornado" then Sleep(delay+((victimdistance)/speed)*1000+100,"stun") end
											if spell.name == "kunkka_x_marks_the_spot" then Sleep(1000, spell.name) Sleep(delay+client.latency+200, "stun") end
											if spell.name == "rattletrap_hookshot" then Sleep(delay+((victimdistance-50)/speed)*1000+mathmax(client.latency,1000),"blink") end
											if ID ~= CDOTA_Unit_Hero_Pudge then											
												Sleep(delay+client.latency,"casting")
											end
											if spell.name == "puck_illusory_orb" then Sleep(3000, "blink") PuckPosition = me.position end
											if Dmg then
												if spell.name ~= "invoker_ice_wall" then
													enemyHP = enemyHP - Dmg
												else
													enemyHP = enemyHP - Dmg/2
												end
											end
											return
										end
									end
								end
							end
						end
					end
				end
			end
			
			if me:IsChanneling() or (tempvictim and (tempvictim:DoesHaveModifier("modifier_pudge_meat_hook") or a4.abilityPhase) and ID == CDOTA_Unit_Hero_Pudge) then return end
			
			--Orb Walk
			--print(not me:DoesHaveModifier("modifier_phoenix_sun_ray") , (not retreat or (tempvictim and meDmg > enemyHP and victimdistance < range)) , not me:DoesHaveModifier("modifier_spirit_breaker_charge_of_darkness") , SleepCheck("charge") , me.alive , not CanMove , not me:DoesHaveModifier("modifier_batrider_flaming_lasso_self") , tempvictim , victimdistance <= mathmax(range*2+50,500) , tempvictimVisible , not tempvictim:IsInvul() , me:CanAttack() , not tempvictim:IsAttackImmune() , not tempvictim:DoesHaveModifier("modifier_bane_nightmare") )
			if not me:DoesHaveModifier("modifier_phoenix_sun_ray") and (not retreat or (tempvictim and meDmg > enemyHP and victimdistance < range)) and not me:DoesHaveModifier("modifier_spirit_breaker_charge_of_darkness") and SleepCheck("charge") and me.alive and not CanMove and not me:DoesHaveModifier("modifier_batrider_flaming_lasso_self") and tempvictim and victimdistance <= mathmax(range*2+50,500) and tempvictimVisible and not tempvictim:IsInvul() and me:CanAttack() and not tempvictim:IsAttackImmune() and not tempvictim:DoesHaveModifier("modifier_bane_nightmare") then	
				--print("asd")
				if tick > tempattack and SleepCheck("moving") then
					if (not meld or not meld:CanBeCasted() or me:DoesHaveModifier("modifier_templar_assassin_meld") or enemyHP < meDmg) and (not a1 or a1.name ~= "mirana_starfall" or not a1:CanBeCasted() or enemyHP < meDmg) and not tempvictim:IsInvul() and not tempvictim:IsAttackImmune() and not tempvictim:DoesHaveModifier("modifier_bane_nightmare") then
						if ID == CDOTA_Unit_Hero_Invoker and exort and exort.level > 0 and SleepCheck("casting3") then
							if not me:IsInvisible() and setOrbs("exort", me) then
								Sleep(250,"casting3")
							end
						end
						if (not me:DoesHaveModifier("modifier_bloodseeker_rupture") or victimdistance <= range) then
							if not me:DoesHaveModifier("modifier_item_armlet_unholy_strength") and SleepCheck("item_armlet") and (not me:DoesHaveModifier("modifier_huskar_life_break_charge") and (ID ~= CDOTA_Unit_Hero_Huskar or not a4.abilityPhase)) then
								--print(not me:DoesHaveModifier("modifier_huskar_life_break_charge") , a4.abilityPhase)
								local armlet = me:FindItem("item_armlet")
								if armlet then
									me:CastItem("item_armlet")
									Sleep(client.latency+100,"item_armlet")
									return
								end
							end
							if xposition then
								if GetDistance2D(xposition,me) > 700 then me:Move(xposition)
								end
							elseif me:DoesHaveModifier("modifier_gyrocopter_flak_cannon") and victimdistance > range+100 then
								local closeUnits = entityList:GetEntities(function (v) return ((v.hero or v.creep) and v.alive and v.team ~= me.team and v ~= tempvictim and GetDistance2D(me,v) < range) end)
								if #closeUnits > 0 then
									me:AttackMove(SkillShot.InFront(me,500))
								else
									myhero:Hit(tempvictim,me)
								end
							elseif ID == CDOTA_Unit_Hero_Kunkka and a2.cd == 0 then
								local closeUnits = entityList:GetEntities(function (v) return ((v.hero or v.creep) and v.alive and v.team ~= me.team and v ~= tempvictim and GetDistance2D(me,v) < range) end)
								if #closeUnits > 0 then
									local attackableUnit = nil
									for i = 1, #closeUnits do
										local v = closeUnits[i]
										local calc1 = (mathfloor(mathsqrt((tempvictim.position.x-v.position.x)^2 + (tempvictim.position.y-v.position.y)^2)))
										local calc2 = (mathfloor(mathsqrt((me.position.x-v.position.x)^2 + (me.position.y-v.position.y)^2)))
										local calc4 = (mathfloor(mathsqrt((me.position.x-tempvictim.position.x)^2 + (me.position.y-tempvictim.position.y)^2)))
										if calc1 < calc4 and calc2 < calc4 and GetDistance2D(me,v) < 300 then
											attackableUnit = v
										end
									end
									if attackableUnit then
										me:Attack(attackableUnit)
									else
										myhero:Hit(tempvictim,me)
									end
								else
									myhero:Hit(tempvictim,me)
								end
							else
								myhero:Hit(tempvictim,me)
							end
						else
							player:HoldPosition()
						end
						if victimdistance <= range+50 and SleepCheck("casting") then
							enemyHP = enemyHP - meDmg
							Sleep(Animations.GetAttackTime(me)*1000+client.latency+me:GetTurnTime(tempvictim)*1000,"casting")
						end
					elseif not me:DoesHaveModifier("modifier_templar_assassin_meld") or not meld then
						if not me:DoesHaveModifier("modifier_bloodseeker_rupture") then
							me:Follow(tempvictim)
						else
							player:HoldPosition()
						end
					end
					attack = tick + Animations.maxCount + client.latency
					type = nil
				end
			elseif not me:DoesHaveModifier("modifier_spirit_breaker_charge_of_darkness") and SleepCheck("charge") and me.alive and not me:DoesHaveModifier("modifier_bloodseeker_rupture") and tick > tempmove and SleepCheck("moving") and (SleepCheck("casting") or ID ~= CDOTA_Unit_Hero_TemplarAssassin) and (not meld or not me:DoesHaveModifier("modifier_templar_assassin_meld") or SleepCheck("casting")) then
				local mPos = client.mousePosition
				if ID == CDOTA_Unit_Hero_Invoker and quas and quas.level > 0 and SleepCheck("casting3") and ((not tempvictim and (me.maxHealth-me.health) > 100) or ((not wex or wex.level == 0) and (not exort or exort.level == 0))) and not retreat then
					if not me:IsInvisible() and setOrbs("quas", me) then
						Sleep(250, "casting3")
					end
				elseif exort and exort.level > 0 and SleepCheck("casting3") and (not wex or wex.level == 0) then
					if not me:IsInvisible() and setOrbs("exort", me) then
						Sleep(250, "casting3")
					end
				elseif wex and wex.level > 0 and SleepCheck("casting3") then
					if not me:IsInvisible() and setOrbs("wex", me) then
						Sleep(250, "casting3")
					end
				end
				--print(((not targetlock and config.MoveToEnemyWhenLocked) or retreat) , (not tempvictim or (GetDistance2D(me,mPos) > 300 and GetDistance2D(tempvictim,mPos) > 300 and tempvictimVisible and GetDistance2D(tempvictim,me) < 1000 and (me:GetTurnTime(mPos)*2 < Animations.getBackswingTime(me) or me.activity ~= LuaEntityNPC.ACTIVITY_MOVE))) , (temptype and temptype == 1) , (not tempvictim or (tempvictimVisible and GetDistance2D(tempvictim,me) < 1000)))
				if xposition or ((not targetlock and config.MoveToEnemyWhenLocked) or retreat) or ((((not tempvictim or (GetDistance2D(me,mPos) > 300 and GetDistance2D(tempvictim,mPos) > 300 and tempvictimVisible and GetDistance2D(tempvictim,me) < 1000 and (me:GetTurnTime(mPos)*2 < Animations.getBackswingTime(me) or me.activity ~= LuaEntityNPC.ACTIVITY_MOVE))) or (temptype and temptype == 1)) and (not tempvictim or (tempvictimVisible and GetDistance2D(tempvictim,me) < 1000)))) then
					me:Move(mPos)
					type = 1
				elseif (config.AutoMoveToEnemy or not tempvictimVisible or (prediction and GetDistance2D(me,prediction) > range and GetDistance2D(prediction,tempvictim) > 100) or GetDistance2D(me,tempvictim) > 1000) and GetDistance2D(me,mPos) > 100 then
					me:Follow(tempvictim)
					follow = tick + 6000
				end
				move = tick + Animations.maxCount + client.latency
				start = false
			end
		--Target Reset
		else
			if victim then
				if config.AutoLock or targetlock then
					if not resettime then
						resettime = gameTime
					elseif (gameTime - resettime) >= 6 then
						indicate[victim.playerId].visible = false
						victim = nil
						resettime = nil	
						targetlock = false		
					end
					start = false
				else
					indicate[victim.playerId].visible = false
					victim = nil
					resettime = nil	
					targetlock = false	
				end
			end
		end 
		--Reseting farmed/visible/stacking state of camps
		local neutrals = entityList:GetEntities({team=LuaEntity.TEAM_NEUTRAL})
		local allies = entityList:GetEntities({type = LuaEntity.TYPE_HERO, team = me.team, alive=true})
		local drawMgr3D = drawMgr3D
		local tempJungleCamps = JungleCamps
		for i = 1, #tempJungleCamps do
			local camp = tempJungleCamps[i]
			local block = false
			local farmed = true
			local creepscount = 0
			local wolf = false
			local nowolf = true
			local moving = false
			local outofcamp = false
			for k = 1, #neutrals do
				local ent = neutrals[k]
				if ent.health and ent.alive and ent.spawned and GetDistance2D(ent,camp.position) < 800 then						
					farmed = false
					JungleCamps[camp.id].farmed = false
					tempJungleCamps = JungleCamps
				end
				if ent.spawned and ent.alive and GetDistance2D(ent,camp.position) < 800 then
					creepscount = creepscount + 1
					if ent:IsRanged() then isranged = true end
					if ent.name == "npc_dota_neutral_alpha_wolf" or ent.name == "npc_dota_neutral_giant_wolf" then
						wolf = true
					else
						nowolf = true
					end
					if ent.activity == LuaEntityNPC.ACTIVITY_MOVE then moving = true end
					if GetDistance2D(ent,camp.position) > 500 then outofcamp = true end
				end
			end
			for m = 1, #allies do
				local v = allies[m]
				if GetDistance2D(v,camp.position) < 500 and v.alive then
					block = true
				end
				if farmed and GetDistance2D(v,camp.position) < 500 then
					JungleCamps[camp.id].farmed = true
					tempJungleCamps = JungleCamps
				end
				if GetDistance2D(v,camp.position) < 300 then
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
				campSigns[camp.id] = drawMgr3D:CreateText(camp.position, Vector(0,0,0), Vector2D(0,0), 0x66FF33FF, "Camp "..camp.id.." Available!", F14)
			else
				campSigns[camp.id].drawObj.visible = client:ScreenPosition(camp.position);
				if not JungleCamps[camp.id].calculatedStack then JungleCamps[camp.id].calculatedStack = camp.stackTime end
				if creepscount > 0 and (not JungleCamps[camp.id].calculatedStack or (gameTime % 60 < JungleCamps[camp.id].calculatedStack and gameTime % 60 > 6 and (not moving or not outofcamp))) then					
					JungleCamps[camp.id].calculatedStack = camp.stackTime
					if camp.calculatedStack then stackTime = math.floor(camp.calculatedStack*100)/100 end
					if wolf and not nowolf then
						JungleCamps[camp.id].calculatedStack = JungleCamps[camp.id].calculatedStack + 1
					elseif nowolf and wolf then
						if creepscount > 4 then
							JungleCamps[camp.id].calculatedStack = JungleCamps[camp.id].calculatedStack + 0.09*creepscount
						else
							JungleCamps[camp.id].calculatedStack = JungleCamps[camp.id].calculatedStack  + 0.2*creepscount
						end
					end
					if creepscount > 5 then
						JungleCamps[camp.id].calculatedStack  = JungleCamps[camp.id].calculatedStack - creepscount*0.02
					end
					if isranged then
						JungleCamps[camp.id].calculatedStack  = JungleCamps[camp.id].calculatedStack  - 0.2
					end
					if not JungleCamps[camp.id].stacks then JungleCamps[camp.id].stacks = math.floor(creepscount/3+0.35) end
					if JungleCamps[camp.id].count and gameTime > 40 and JungleCamps[camp.id].count < creepscount then JungleCamps[camp.id].stacks = JungleCamps[camp.id].stacks + 1 end
					JungleCamps[camp.id].count = creepscount
				end
				if not JungleCamps[camp.id].stacks then JungleCamps[camp.id].stacks = math.floor(creepscount/3+0.3) end
				if not JungleCamps[camp.id].count then JungleCamps[camp.id].count = creepscount end
				if tempJungleCamps[camp.id].farmed then
					campSigns[camp.id].drawObj.text = "Camp "..camp.id.." farmed!"
					campSigns[camp.id].drawObj.color = 0xFF6600FF
					JungleCamps[camp.id].stacks = 1
					JungleCamps[camp.id].count = 0
				elseif tempJungleCamps[camp.id].visible then
					campSigns[camp.id].drawObj.text = "Camp "..camp.id.." visible! | Stack Time: XX:"..JungleCamps[camp.id].calculatedStack.." | Stacks: ~"..JungleCamps[camp.id].stacks.." ("..JungleCamps[camp.id].count.." creeps)"
					campSigns[camp.id].drawObj.color = 0xFFFF00FF
				else
					campSigns[camp.id].drawObj.text = "Camp "..camp.id.." available! | Stack Time: XX:"..JungleCamps[camp.id].calculatedStack.." | Stacks: ~"..JungleCamps[camp.id].stacks.." ("..JungleCamps[camp.id].count.." creeps)"
					campSigns[camp.id].drawObj.color = 0x66FF33FF
				end
			end
		end	
		--Stacking
		if IsKeyDown(config.StackKey) and not client.chat then
			for i = 1,#player.selection do
				local selected = player.selection[i]
				if not stackTable[selected.handle] and SleepCheck(selected.handle) then 
					local camp = getClosestCamp(selected)
					if camp then
						JungleCamps[camp.id].stacked = selected.handle
						stackTable[selected.handle] = {}
						stackTable[selected.handle].camp = camp
						stackTable[selected.handle].draw = drawMgr:CreateText(0,0,0xFFFF00FF,"Stacking",F14)
						stackTable[selected.handle].draw.entity = selected
						stackTable[selected.handle].draw.entityPosition = Vector(0,0,selected.healthbarOffset)
						stackTable[selected.handle].draw.visible = true
						Sleep(500, selected.handle)	
					end
				elseif SleepCheck(selected.handle) then
					JungleCamps[stackTable[selected.handle].camp.id].stacked = false
					JungleCamps[stackTable[selected.handle].camp.id].calculatedStack = nil
					stackTable[selected.handle].camp = nil
					stackTable[selected.handle].draw.visible = false
					stackTable[selected.handle].draw = nil
					stackTable[selected.handle] = nil
					Sleep(500, selected.handle)	
				end
			end
		end
		for i,v in pairs(stackTable) do
			local selected = entityList:GetEntity(i)
			local camp = v.camp
			if (not selected or not selected.alive or not selected.visible) and camp then 
				JungleCamps[stackTable[i].camp.id].stacked = false
				stackTable[i].camp = nil
				stackTable[i].draw.visible = false
				stackTable[i].draw = nil
				JungleCamps[camp.id].calculatedStack = nil
				break 
			end
			local creeptohit = nil
			local creepsnear = {}
			local creepscount = 0
			local isranged = false
			local wolf = false
			local nowolf = true
			local moving = false
			if camp then
				for i = 1, #neutrals do
					local creep = neutrals[i]
					if creep.spawned and creep.alive and GetDistance2D(creep,selected) <= 1200 and GetDistance2D(creep,camp.position) < 300 then
						creepscount = creepscount + 1
						creepsnear[creepscount] = creep
						if not creeptohit or GetDistance2D(selected, creep) < GetDistance2D(selected, creeptohit) then
							creeptohit = creep
						end
						if creep:IsRanged() then isranged = true end
						if creep.name == "npc_dota_neutral_alpha_wolf" or creep.name == "npc_dota_neutral_giant_wolf" then
							wolf = true
						else
							nowolf = true
						end
						--print(creep.activity)
						if creep.activity == LuaEntityNPC.ACTIVITY_MOVE or Animations.isAttacking(creep) then moving = true end
					end
				end
				--print(moving)
				local stackDuration = 0
				local moveTime = nil
				local range1
				if selected == me then range1 = range else
				range1 = selected.attackRange end
				local stackTime = camp.stackTime
				if camp.calculatedStack then stackTime = camp.calculatedStack end
				--print(creeptohit)
				if creeptohit and creeptohit.alive then
					stackDuration = mathmin((GetDistance2D(creeptohit,camp.stackPosition)+(creepscount*25))/mathmin(creeptohit.movespeed,selected.movespeed), 7)
					if creeptohit:IsRanged() and creepscount > 6 then
						stackDuration = mathmin((GetDistance2D(creeptohit,camp.stackPosition)+creeptohit.attackRange+(creepscount*75))/mathmin(creeptohit.movespeed,selected.movespeed), 7)
					elseif creeptohit:IsRanged() then
						stackDuration = mathmin((GetDistance2D(creeptohit,camp.stackPosition)+creeptohit.attackRange+(creepscount*25))/mathmin(creeptohit.movespeed,selected.movespeed), 7)
					end
					moveTime = stackTime - (GetDistance2D(selected,creeptohit)-200)/selected:GetMovespeed() + selected:GetTurnTime(creeptohit.position)
					if selected:IsRanged() then
						if heroInfo[selected.name] and heroInfo[selected.name].projectileSpeed then
							moveTime = stackTime - math.min(range1+100, GetDistance2D(selected,creeptohit))/heroInfo[selected.name].projectileSpeed - Animations.GetAttackTime(selected) - selected:GetTurnTime(creeptohit.position) - mathmax(((GetDistance2D(creeptohit,selected)-50)-range),0)/selected:GetMovespeed()
						else
							moveTime = stackTime - (range1-50)/700 - Animations.GetAttackTime(selected) - selected:GetTurnTime(camp.position) - mathmax(((GetDistance2D(creeptohit,selected)-50)-range),0)/selected.movespeed
						end
					end
					if selected:IsRanged() and range < 340 and isranged then
						moveTime = moveTime - 0.25
					end
					moveTime = moveTime - client.latency*0.001
					-- if stackDuration > 0 then
						-- moveTime = 60 - stackDuration - (GetDistance2D(selected,camp.position)-150)/selected.movespeed + selected:GetTurnTime(camp.stackPosition) - client.latency*0.001 - (100/Animations.maxCount)*0.001 + ((client.latency/1000)/(1 + (1 - 1/Animations.maxCount)))
						-- if selected:IsRanged() then
							-- if heroInfo[selected.name] and heroInfo[selected.name].projectileSpeed then
								-- moveTime = 60 - stackDuration - (range-50)/heroInfo[selected.name].projectileSpeed - Animations.GetAttackTime(selected) - selected:GetTurnTime(camp.position) - mathmax(((GetDistance2D(creeptohit,selected)-50)-range),0)/selected.movespeed
							-- else
								-- moveTime = 60 - stackDuration - (range-50)/700 - Animations.GetAttackTime(selected) - selected:GetTurnTime(camp.position) - mathmax(((GetDistance2D(creeptohit,selected)-50)-range),0)/selected.movespeed
							-- end
						-- end
					-- end
				end
				
				if SleepCheck(i.."stack") and SleepCheck(i.."-move") then
					-- if not moveTime or gameTime % 60 < moveTime or gameTime % 60 > 59 then
						-- if GetDistance2D(selected,camp.waitPosition) > 50 then
							-- selected:Move(camp.waitPosition)
						-- end
					-- elseif (not creeptohit or not creeptohit.visible) then
						-- if GetDistance2D(selected,camp.position) > 50 then
							-- selected:Move(camp.position)
						-- end
					-- end
					-- Sleep(750,i.."-move")
					if not moveTime or gameTime % 60 < moveTime then
						if camp.farmed then
							if GetDistance2D(selected,camp.stackPosition) > 50 then
								selected:Move(camp.stackPosition)
							end
						elseif GetDistance2D(selected,camp.waitPosition) > 50 then
							selected:Move(camp.waitPosition)
						end
					elseif (not creeptohit or not creeptohit.visible) then
						if camp.farmed then
							if GetDistance2D(selected,camp.stackPosition) > 50 then
								selected:Move(camp.stackPosition)
							end
						elseif GetDistance2D(selected,camp.position) > 50 then
							selected:Move(camp.position)
						end
					end
					Sleep(1000,i.."-move")
				end
				-- if creeptohit and creeptohit.alive then
					-- JungleCamps[camp.id].calculatedStack = moveTime
				-- end
				if moveTime and gameTime % 60 >= moveTime then
					if creeptohit and creeptohit.alive then
						if SleepCheck(i.."-moveStack") and gameTime % 60 < 56 and gameTime % 60 >= camp.stackTime-0.5 and moving and (not selected:IsRanged() or Animations.isAttacking(selected)) then	
							-- local pos = (camp.stackPosition - creeptohit.position) * (GetDistance2D(camp.stackPosition,creeptohit) + creeptohit.attackRange) / GetDistance2D(camp.stackPosition,creeptohit) + camp.stackPosition
							-- selected:Move(pos)
							-- Sleep((GetDistance2D(selected,pos)/selected.movespeed)*1000,i.."-moveStack")
							-- Sleep((59 - (gameTime % 60))*1000,i.."stack")
							local pos = (camp.stackPosition - creeptohit.position) * (GetDistance2D(camp.stackPosition,creeptohit) + 500) / GetDistance2D(camp.stackPosition,creeptohit) + camp.stackPosition
							if Animations.isAttacking(selected) then
								selected:Move(pos)
							else
								selected:Move(pos,true)
							end
							Sleep((GetDistance2D(selected,pos)/selected.movespeed)*1000,i.."-moveStack")
							Sleep((60 - (gameTime % 60))*1000,i.."stack")
						elseif SleepCheck(i.."stack") and SleepCheck(i.."-attack") then
							if selected:IsRanged() then
								if not Animations.CanMove(selected) and (not moving or gameTime % 60 < camp.stackTime-0.5) then
									selected:Attack(creeptohit)
									Sleep(Animations.GetAttackTime(selected)*1000+(mathmax(((GetDistance2D(creeptohit,selected)-50)-range),0)/selected.movespeed)*1000+selected:GetTurnTime(camp.position)*1000,i.."-attack")
								else
									selected:Move(camp.stackPosition)
									Sleep((60 - (gameTime % 60))*1000 + client.latency,i.."-attack")
									Sleep((60 - (gameTime % 60))*1000 + client.latency,i.."-move")
								end
							else
								-- local pos = (creeptohit.position - selected.position) * (-200) / GetDistance2D(selected,creeptohit) + creeptohit.position
								-- selected:Move(pos)
								-- selected:Move(camp.stackPosition,true)
								-- Sleep(5000,i.."-attack")
								local pos = (creeptohit.position - selected.position) * (-200) / GetDistance2D(selected,creeptohit) + creeptohit.position
								local pos2 = (camp.stackPosition - creeptohit.position) * (GetDistance2D(camp.stackPosition,creeptohit) + 500) / GetDistance2D(camp.stackPosition,creeptohit) + camp.stackPosition
								selected:Move(pos)
								if camp.id == 5 then pos2 = camp.stackPosition end
								selected:Move(pos2,true)
								Sleep((60 - (gameTime % 60))*1000 + client.latency,i.."-attack")
								Sleep((60 - (gameTime % 60))*1000 + client.latency,i.."-move")
							end
						end
					end
				end
			end
		end
	end
end

function invokeSunstrike(button, button2, text) 
	local me = entityList:GetMyHero()
	prepareSpell("invoker_sun_strike",me,true)
	return true
end

function invokeColdsnap(button, button2, text) 
	local me = entityList:GetMyHero()
	prepareSpell("invoker_cold_snap",me,true)
	return true
end

function invokeGhostwalk(button, button2, text) 
	local me = entityList:GetMyHero()
	prepareSpell("invoker_ghost_walk",me,true)
	return true
end

function invokeIcewall(button, button2, text) 
	local me = entityList:GetMyHero()
	prepareSpell("invoker_ice_wall",me,true)
	return true
end

function invokeEmp(button, button2, text) 
	local me = entityList:GetMyHero()
	prepareSpell("invoker_emp",me,true)
	return true
end

function invokeChaosmeteor(button, button2, text) 
	local me = entityList:GetMyHero()
	prepareSpell("invoker_chaos_meteor",me,true)
	return true
end

function invokeTornado(button, button2, text) 
	local me = entityList:GetMyHero()
	prepareSpell("invoker_tornado",me,true)
	return true
end

function invokeAlacrity(button, button2, text) 
	local me = entityList:GetMyHero()
	prepareSpell("invoker_alacrity",me,true)
	return true
end

function invokeBlast(button, button2, text) 
	local me = entityList:GetMyHero()
	prepareSpell("invoker_deafening_blast",me,true)
	return true
end

function invokeForgespirit(button, button2, text) 
	local me = entityList:GetMyHero()
	prepareSpell("invoker_forge_spirit",me,true)
	return true
end

function chainStun(target, delay, except, onlychain)
	local chain = false
	local stunned = false
	local modifiers_table = {"modifier_shadow_demon_disruption", "modifier_obsidian_destroyer_astral_imprisonment_prison", 
		"modifier_eul_cyclone", "modifier_invoker_tornado", "modifier_bane_nightmare", "modifier_shadow_shaman_shackles", 
		"modifier_crystal_maiden_frostbite", "modifier_ember_spirit_searing_chains", "modifier_axe_berserkers_call",
		"modifier_lone_druid_spirit_bear_entangle_effect", "modifier_meepo_earthbind", "modifier_naga_siren_ensnare",
		"modifier_storm_spirit_electric_vortex_pull", "modifier_treant_overgrowth", "modifier_cyclone",
		"modifier_sheepstick_debuff", "modifier_shadow_shaman_voodoo", "modifier_lion_voodoo", "modifier_brewmaster_storm_cyclone",
		"modifier_puck_phase_shift", "modifier_dark_troll_warlord_ensnare" , "modifier_invoker_deafening_blast_knockback"}
	local modifiers = target.modifiers
	local length = #modifiers_table
	table.sort(modifiers, function (a,b) return a.remainingTime > b.remainingTime end)
	for i = 1, #modifiers do
		local m = modifiers[i]
		for z = 1, length do
			local k = modifiers_table[z]
			if m and (m.stunDebuff or m.name == k) and (not except or m.name ~= except) and m.name ~= "modifier_invoker_cold_snap" then
				stunned = true
				local remainingTime = m.remainingTime
				if m.name == "modifier_eul_cyclone" or m.name == "modifier_invoker_tornado" then remainingTime = m.remainingTime+0.07 end
				--print(remainingTime,delay)
				if remainingTime > 0 and remainingTime <= delay then					
					--print(m.name,remainingTime,delay)
					chain = true
				else
					chain = false
				end
			end
		end
	end
	--print((not (stunned or target:IsStunned()) or chain), (onlychain and chain), SleepCheck("stun"))
	return (((not (stunned or target:IsStunned() or target:IsRooted() or not target:CanMove() or target:IsHexed()) or chain) and SleepCheck("stun") and not onlychain) or (onlychain and chain))
end

function stunDuration(target)
	local modifiers_table = {"modifier_shadow_demon_disruption", "modifier_obsidian_destroyer_astral_imprisonment_prison", 
		"modifier_eul_cyclone", "modifier_invoker_tornado", "modifier_bane_nightmare", "modifier_shadow_shaman_shackles", 
		"modifier_crystal_maiden_frostbite", "modifier_ember_spirit_searing_chains", "modifier_axe_berserkers_call",
		"modifier_lone_druid_spirit_bear_entangle_effect", "modifier_meepo_earthbind", "modifier_naga_siren_ensnare",
		"modifier_storm_spirit_electric_vortex_pull", "modifier_treant_overgrowth", "modifier_cyclone",
		"modifier_sheepstick_debuff", "modifier_shadow_shaman_voodoo", "modifier_lion_voodoo", "modifier_brewmaster_storm_cyclone",
		"modifier_puck_phase_shift", "modifier_dark_troll_warlord_ensnare" , "modifier_invoker_deafening_blast_knockback"}
	local modifiers = target.modifiers
	local length = #modifiers_table
	table.sort(modifiers, function (a,b) return a.remainingTime > b.remainingTime end)
	for i = 1, #modifiers do
		local m = modifiers[i]
		for z = 1, length do
			local k = modifiers_table[z]
			if m and (m.stunDebuff or m.name == k) and m.name ~= "modifier_invoker_cold_snap" then
				local remainingTime = m.remainingTime
				if m.name == "modifier_eul_cyclone" then remainingTime = m.remainingTime+0.07 end
				return remainingTime
			end
		end
	end
	if target:IsChanneling() then
		local ab = target:GetChanneledAbility()
		return ab:GetChannelTime(ab.level) - ab.channelTime
	end
	local abilities = target.abilities
	for i = 1, #abilities do
		local v = abilities[i]
		if v.abilityPhase then
			return v:FindCastPoint()
		end
	end
	return 0
end

class 'MyHero'

function MyHero:__init(heroEntity)
	self.heroEntity = heroEntity
	local name = heroEntity.name
	if not heroInfo[name] then
		return nil
	end
end

function MyHero:GetAttackRange()
	local bonus = 0
	if self.heroEntity.classId == CDOTA_Unit_Hero_TemplarAssassin then	
		local psy = self.heroEntity:GetAbility(3)
		psyrange = {60,120,180,240}		
		if psy and psy.level > 0 then		
			bonus = psyrange[psy.level]			
		end
	elseif self.heroEntity.classId == CDOTA_Unit_Hero_Sniper then	
		local aim = self.heroEntity:GetAbility(3)
		aimrange = {100,200,300,400}		
		if aim and aim.level > 0 then		
			bonus = aimrange[aim.level]			
		end		
	elseif self.heroEntity.classId == CDOTA_Unit_Hero_Enchantress then
		if enablemodifiers then
			local impetus = self.heroEntity:GetAbility(4)
			if impetus.level > 0 and self.heroEntity:AghanimState() then
				bonus = 190
			end
		end
	elseif self.heroEntity.classId == CDOTA_Unit_Hero_LoneDruid then
		local lonetrue = self.heroEntity:FindSpell("lone_druid_true_form")
		if self.heroEntity.attackRange < 130 and (not (lonetrue and lonetrue.level > 0) or not self.heroEntity:DoesHaveModifier("modifier_lone_druid_true_form")) then
			bonus = 423
		end
	end
	local winter = self.heroEntity:FindSpell("winter_wyvern_arctic_burn")
	if winter and winter.level > 0 and self.heroEntity:DoesHaveModifier("modifier_winter_wyvern_arctic_burn") then
		bonus = winter:GetSpecialData("attack_range_bonus")
	end
	local dragon = self.heroEntity:FindSpell("dragon_knight_elder_dragon_form")
	if dragon and dragon.level > 0 and self.heroEntity:DoesHaveModifier("modifier_dragon_knight_dragon_form") then
		bonus = 372
	end
	local terrormorph = self.heroEntity:FindSpell("terrorblade_metamorphosis")
	if terrormorph and terrormorph.level > 0 and self.heroEntity:DoesHaveModifier("modifier_terrorblade_metamorphosis") then
		bonus = 422
	end
	return self.heroEntity.attackRange + bonus
end

function MyHero:Hit(target)
	if target and target.team ~= self.heroEntity.team then
		if target and target.hero then
			if self.heroEntity.classId == CDOTA_Unit_Hero_Clinkz then
				local searinga = self.heroEntity:GetAbility(2)
				if searinga.level > 0 and self.heroEntity.mana > 10 then
					self.heroEntity:SafeCastAbility(searinga, target)
				else self.heroEntity:Attack(target) end
			elseif self.heroEntity.classId == CDOTA_Unit_Hero_DrowRanger and not target:IsMagicImmune() then
				local frost = self.heroEntity:GetAbility(1)
				if frost.level > 0 and self.heroEntity.mana > 12 then
					self.heroEntity:SafeCastAbility(frost, target)
				else self.heroEntity:Attack(target) end
			elseif self.heroEntity.classId == CDOTA_Unit_Hero_Viper and not target:IsMagicImmune() then
				local poison = self.heroEntity:GetAbility(1)
				if poison.level > 0 and self.heroEntity.mana > 21 then
					self.heroEntity:SafeCastAbility(poison, target)
				else self.heroEntity:Attack(target) end  
			elseif self.heroEntity.classId == CDOTA_Unit_Hero_Huskar and not target:IsMagicImmune() then
				local burning = self.heroEntity:GetAbility(2)
				if burning.level > 0 and self.heroEntity.health > 15 then
					self.heroEntity:SafeCastAbility(burning, target)
				else self.heroEntity:Attack(target) end
			elseif self.heroEntity.classId == CDOTA_Unit_Hero_Silencer and not target:IsMagicImmune() then
				local glaives = self.heroEntity:GetAbility(2)
				if glaives.level > 0 and self.heroEntity.mana > 15 then
					self.heroEntity:SafeCastAbility(glaives, target)
				else self.heroEntity:Attack(target) end
			elseif self.heroEntity.classId == CDOTA_Unit_Hero_Jakiro and not target:IsMagicImmune() then
				local liquid = self.heroEntity:GetAbility(3)
				if liquid.level > 0 and liquid:CanBeCasted() then
					self.heroEntity:SafeCastAbility(liquid, target)
				else self.heroEntity:Attack(target) end
			elseif self.heroEntity.classId == CDOTA_Unit_Hero_Obsidian_Destroyer and not target:IsMagicImmune() then
				local arcane = self.heroEntity:GetAbility(1)
				if arcane.level > 0 and self.heroEntity.mana > 100 then
					self.heroEntity:SafeCastAbility(arcane, target)
				else self.heroEntity:Attack(target) end
			elseif self.heroEntity.classId == CDOTA_Unit_Hero_Enchantress and not target:IsMagicImmune() then
				local impetus = self.heroEntity:GetAbility(4)
				local impemana = {55,60,65}
				if impetus.level > 0 and self.heroEntity.mana > impemana[impetus.level] then
					self.heroEntity:SafeCastAbility(impetus, target)
				else self.heroEntity:Attack(target) end
			else
				self.heroEntity:Attack(target)
			end
		else
			self.heroEntity:Attack(target)
		end
	end
end

--Return max value from table
function max(t, fn)
    if #t == 0 then return nil, nil end
    local key, value = 1, t[1]
    for i = 2, #t do
        if fn(value, t[i]) then
            key, value = i, t[i]
        end
    end
    return key, value
end

--Invoker: Spell Invoking
function prepareSpell(name,me,click)
	local abilities = me.abilities
	local spell = me:FindSpell(name)
	local quas, wex, exort, invoke, spell1 = abilities[1], abilities[2], abilities[3], abilities[6], abilities[4]  
	if not invoke:CanBeCasted() or not me:CanCast() or (spell1.cd <= spell.cd and not click and not retreat and combo == 0) then return end
	if name == "invoker_cold_snap" and quas.level > 0 then
		me:CastAbility(quas) me:CastAbility(quas) me:CastAbility(quas)
		me:CastAbility(invoke)
		Sleep(100+client.latency, "casting")
		Sleep(200+client.latency, "casting2")
		return true
	elseif name == "invoker_ice_wall" and quas.level > 0 and exort.level > 0 then
		me:CastAbility(quas) me:CastAbility(quas) me:CastAbility(exort)
		me:CastAbility(invoke)
		Sleep(100+client.latency, "casting")
		Sleep(200+client.latency, "casting2")
		return true
	elseif name == "invoker_forge_spirit" and quas.level > 0 and exort.level > 0 then
		me:CastAbility(quas) me:CastAbility(exort) me:CastAbility(exort)
		me:CastAbility(invoke)
		Sleep(100+client.latency, "casting")
		Sleep(200+client.latency, "casting2")
		return true
	elseif name == "invoker_sun_strike" and exort.level > 0 then
		me:CastAbility(exort) me:CastAbility(exort) me:CastAbility(exort)
		me:CastAbility(invoke)
		Sleep(100+client.latency, "casting")
		Sleep(200+client.latency, "casting2")
		return true
	elseif name == "invoker_chaos_meteor" and exort.level > 0 and wex.level > 0 then
		me:CastAbility(exort) me:CastAbility(exort) me:CastAbility(wex)
		me:CastAbility(invoke)
		Sleep(100+client.latency, "casting")
		Sleep(200+client.latency, "casting2")
		return true
	elseif name == "invoker_deafening_blast" and quas.level > 0 and exort.level > 0 and wex.level > 0 then
		me:CastAbility(quas) me:CastAbility(wex) me:CastAbility(exort)
		me:CastAbility(invoke)
		Sleep(100+client.latency, "casting")
		Sleep(200+client.latency, "casting2")
		return true
	elseif name == "invoker_alacrity" and exort.level > 0 and wex.level > 0 then
		me:CastAbility(wex) me:CastAbility(wex) me:CastAbility(exort)
		me:CastAbility(invoke)
		Sleep(100+client.latency, "casting")
		Sleep(200+client.latency, "casting2")
		return true
	elseif name == "invoker_tornado" and quas.level > 0 and wex.level > 0 then
		me:CastAbility(quas) me:CastAbility(wex) me:CastAbility(wex)
		me:CastAbility(invoke)
		Sleep(100+client.latency, "casting")
		Sleep(200+client.latency, "casting2")
		return true
	elseif name == "invoker_emp" and wex.level > 0 then
		me:CastAbility(wex) me:CastAbility(wex) me:CastAbility(wex)
		me:CastAbility(invoke)
		Sleep(100+client.latency, "casting")
		Sleep(200+client.latency, "casting2")
		return true
	elseif name == "invoker_ghost_walk" and wex.level > 0 and quas.level > 0 then
		me:CastAbility(wex) me:CastAbility(quas) me:CastAbility(quas)
		me:CastAbility(invoke)
		if SleepCheck("casting3") then
			if not me:IsInvisible() and setOrbs("wex", me) then
				Sleep(250, "casting3")
			end
		end
		Sleep(100+client.latency, "casting")
		Sleep(200+client.latency, "casting2")
		return true
	end
end

--Invoker: Orb switching
function setOrbs(orb, me)
	local modif = me.modifiers
	local count = 0
	local spell = me:FindSpell("invoker_"..orb)
	for i = 1, #modif do
		local mod = modif[i]
		if mod.name == "modifier_invoker_"..orb.."_instance" then
			count = count + 1
		end
	end
	if me:IsInvisible() then return false end
	if count == 0 then
		me:CastAbility(spell) me:CastAbility(spell) me:CastAbility(spell)
		return true
	elseif count == 1 then
		me:CastAbility(spell) me:CastAbility(spell)
		return true
	elseif count == 2 then
		me:CastAbility(spell)
		return true
	end
	return false
end

function getBlockPositions(target,rotR,unit)
	local rotR1,rotR2 = -rotR,(-3-rotR)
	local infront = Vector(target.position.x+unit.movespeed*math.cos(rotR), target.position.y+unit.movespeed*math.sin(rotR), target.position.z)
	local behind = Vector(target.position.x+(-unit.movespeed/2)*math.cos(rotR), target.position.y+(-unit.movespeed/2)*math.sin(rotR), target.position.z)
	return Vector(infront.x+90*math.cos(rotR1), infront.y+90*math.sin(rotR1), infront.z),
	Vector(infront.x+90*math.cos(rotR2), infront.y+90*math.sin(rotR2), infront.z),
	Vector(behind.x+120*math.cos(rotR1), behind.y+120*math.sin(rotR1), behind.z),
	Vector(behind.x+120*math.cos(rotR2), behind.y+120*math.sin(rotR2), behind.z),infront
end

function getClosestCamp(me)
	local closest = nil
	local tempJungleCamps = JungleCamps
	local mouPos = client.mousePosition
	for i = 1, #tempJungleCamps do
		local camp = tempJungleCamps[i]	
		if not camp.farmed then
			if (not closest and (not camp.stacked or camp.stacked == me.handle)) or (closest and GetDistance2D(mouPos,camp.waitPosition) < GetDistance2D(mouPos,closest.waitPosition) and (not camp.stacked or camp.stacked == me.handle)) or camp.stacked == me.handle then
				closest = camp
			end
		end
	end
	return closest
end

function CanGoInvis(hero) 
	local invis = hero:FindSpell("bounty_hunter_wind_walk") or hero:FindSpell("clinkz_skeleton_walk") or hero:FindItem("item_invis_sword") or hero:FindItem("item_silver_edge") or hero:FindItem("item_glimmer_cape") or hero:FindItem("item_moon_shard")
	local riki = hero:FindSpell("riki_permanent_invisibility")
	return (invis and invis:CanBeCasted()) or riki
end

function CanBeSlowed(target)
	return not target:IsMagicImmune() and not target:IsInvul() and not target:DoesHaveModifier("modifier_rune_haste") and not target:DoesHaveModifier("modifier_lycan_shapeshift") and not target:DoesHaveModifier("modifier_centaur_stampede")
end
	
function rotateX(x,y,angle)
    return x*math.cos(angle) - y*math.sin(angle)
end
       
function rotateY(x,y,angle)
    return y*math.cos(angle) + x*math.sin(angle)
end

function GetXX(ent)
	local team = ent.team
	if team == 2 then		
		return client.screenSize.x/txxG + 1
	elseif team == 3 then
		return client.screenSize.x/txxB 
	end
end

function IsMouseOnButton(x,y,h,w)
	local mx = client.mouseScreenPosition.x
	local my = client.mouseScreenPosition.y
	return mx > x and mx <= x + w and my > y and my <= y + h
end

----Check Version
function Version()
	local file = io.open(SCRIPT_PATH.."/MoonesComboScript_Version.lua", "r")
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
		versionSign.text = "        "
		versionSign.color = -1
		return false
	end
end	

function FindEntity(cast,me,dayvision,m1)
	for i = 1, #cast do
		local z = cast[i]
		if (not dayvision or z.dayVision == dayvision) and (not m1 or z:DoesHaveModifier(m1)) then
			return z
		end
	end
	return nil
end

function Load()
	
	--VersionInfo
	local up,ver,beta,info = Version()
	if up then
		if beta ~= "" then
			versionSign.text = "Your version of Moones's Combo Script is up-to-date! (v"..currentVersion.." "..Beta..")"
		else
			versionSign.text = "Your version of Moones's Combo Script is up-to-date! (v"..currentVersion..")"
		end
		versionSign.color = 0x66FF33FF
		if info then
			infoSign.text = info
			infoSign.visible = true
		end
	end
	if outdated then
		if beta ~= "" then
			versionSign.text = "Your version of Moones's Combo Script is OUTDATED (Yours: v"..currentVersion.." "..Beta.." Current: v"..ver.." "..beta.."), send me email to moones@email.cz to get current one!"
		else
			versionSign.text = "Your version of Moones's Combo Script is OUTDATED (Yours: v"..currentVersion.." "..Beta.." Current: v"..ver.."), send me email to moones@email.cz to get current one!"
		end
		versionSign.color = 0xFF6600FF
		if info then
			infoSign.text = info
			infoSign.visible = true
		end
	end
	versionSign.visible = true
	
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me then 
			script:Disable()
		else
			local mathfloor = math.floor
			if mathfloor(client.screenRatio*100) == 177 then testX = 1600 tinfoHeroSize = 55 tinfoHeroDown = 25.714 txxB = 2.535 txxG = 3.485
			elseif mathfloor(client.screenRatio*100) == 166 then testX = 1280 tinfoHeroSize = 47.1 tinfoHeroDown = 25.714 txxB = 2.558 txxG = 3.62
			elseif mathfloor(client.screenRatio*100) == 160 then testX = 1280 tinfoHeroSize = 48.5 tinfoHeroDown = 25.714 txxB = 2.579 txxG = 3.74
			elseif mathfloor(client.screenRatio*100) == 133 then testX = 1024 tinfoHeroSize = 47 tinfoHeroDown = 25.714 txxB = 2.78 txxG = 4.63
			elseif mathfloor(client.screenRatio*100) == 125 then testX = 1280 tinfoHeroSize = 58 tinfoHeroDown = 25.714 tinfoHeroSS = 23 txxB = 2.747 txxG = 4.54
			else testX = 1600 tinfoHeroSize = 55 tinfoHeroDown = 25.714 tinfoHeroSS = 22 txxB = 2.535 txxG = 3.485 end
			rate = client.screenSize.x/testX
			con = rate
			if rate < 1 then rate = 1 end
			x_ = tinfoHeroSize*(con)
			y_ = client.screenSize.y/tinfoHeroDown
			monitor = client.screenSize.x/1600
			atr = nil
			statusText.visible = false
			myhero = nil
			reg = true
			victim = nil
			if HUD and (HUD:IsClosed() or HUD:IsMinimized()) and me.classId == CDOTA_Unit_Hero_Invoker then
				HUD:Open()
			end
			start = false
			useblink = config.UseBlink
			myId = me.classId
			sleep = 0 
			xposition = nil
			comboready = false
			lastCastPrediction = nil
			resettime = nil
			targetlock = false
			type = nil
			enemyHP = nil
			mySpells = nil
			retreat = false
			lastPrediction = nil
			stackTable = {}
			combo = 0
			esstone = false
			harras = false
			trolltoggle = false
			JungleCamps = {
				{position = Vector(-1131,-4044,127), stackPosition = Vector(-2750.94,-3517.86,128), waitPosition = Vector(-1401.69,-3791.52,128), team = 2, id = 1, farmed = false, lvlReq = 8, visible = false, visTime = 0, stacking = false, stacked = nil, stackTime = 54.5},
				{position = Vector(-366,-2945,127), stackPosition = Vector(-534.219,-1795.27,128), waitPosition = Vector(-408,-2731,127), team = 2, id = 2, farmed = false, lvlReq = 3, visible = false, visTime = 0, stacking = false, stacked = nil, stackTime = 55},
				{position = Vector(1606.45,-3433.36,256), stackPosition = Vector(1598.19,-5117.22,256), waitPosition = Vector(1541.87,-4265.38,256), team = 2, id = 3, farmed = false, lvlReq = 8, visible = false, visTime = 0, stacking = false, stacked = nil, stackTime = 54.5},
				{position = Vector(3126,-3439,256), stackPosition = Vector(5284.49,-3922,256), waitPosition = Vector(3231,-3807,256), team = 2, id = 4, farmed = false, lvlReq = 3, visible = false, visTime = 0, stacking = false, stacked = nil, stackTime = 53.1},
				{position = Vector(3031.03,-4480.06,256), stackPosition = Vector(3774.15,-6700.85,256), waitPosition = Vector(3030,-4975,256), team = 2, id = 5, farmed = false, lvlReq = 1, visible = false, visTime = 0, stacking = false, stacked = nil, stackTime = 53},
				{position = Vector(-2991,191,256), stackPosition = Vector(-3351,-1798,205), waitPosition = Vector(-2684,-23,256), team = 2, id = 6, farmed = false, lvlReq = 12, visible = false, visTime = 0, ancients = true, stacking = false, stacked = nil, stackTime = 54},
				{position = Vector(1167,3295,256), stackPosition = Vector(570.86,4515.96,256), waitPosition = Vector(1011,3656,256), team = 3, id = 7, farmed = false, lvlReq = 8, visible = false, visTime = 0, stacking = false, stacked = nil, stackTime = 54},
				{position = Vector(-244,3629,256), stackPosition = Vector(236.481,5000.22,256), waitPosition = Vector(-523,4041,256), team = 3, id = 8, farmed = false, lvlReq = 3, visible = false, visTime = 0, stacking = false, stacked = nil, stackTime = 54.5},
				{position = Vector(-1588,2697,127), stackPosition = Vector(-1302,3689.41,136.411), waitPosition = Vector(-1491,2986,127), team = 3, id = 9, farmed = false, lvlReq = 3, visible = false, visTime = 0, stacking = false, stacked = nil, stackTime = 53},
				{position = Vector(-3157.74,4475.46,256), stackPosition = Vector(-3296.1,5508.48,256), waitPosition = Vector(-3086,4924,256), team = 3, id = 10, farmed = false, lvlReq = 1, visible = false, visTime = 0, stacking = false, stacked = nil, stackTime = 54},
				{position = Vector(-4382,3612,256), stackPosition = Vector(-3026.54,3819.69,132.345), waitPosition = Vector(-4200,3850,256), team = 3, id = 11, farmed = false, lvlReq = 8, visible = false, visTime = 0, stacking = false, stacked = nil, stackTime = 53},
				{position = Vector(4026,-709.943,128), stackPosition = Vector(2636,-1017,127), waitPosition = Vector(3583,-736,127), team = 3, id = 12, farmed = false, lvlReq = 12, visible = false, visTime = 0,  ancients = true, stacking = false, stacked = nil, stackTime = 54}
			}
			camp = nil
			tuskSnowBall = false
			positionsTable = {}
			PuckPosition = nil
			directiontable = {}
			LastCastedTable = {}
			indicate = {}
			damageTable = {}
			comboTable = {
				{ CDOTA_Unit_Hero_Ursa, {{ 1, "shock_radius", true}, { 2, nil, false, nil, false, nil, false, nil, nil, true, true }, { 5, 350, false, nil, false, nil, false, nil, nil, true }} },
				{ CDOTA_Unit_Hero_Bloodseeker, {{ 4, nil, false, nil, false, nil, false, nil, nil, true }, { 2 , nil, false, 2.6}, { 1, nil, false, nil, false, nil, false, nil, nil, true, true }} },
				{ CDOTA_Unit_Hero_Lina, {{ 2, nil, true , 0.5}, { 1, nil, true, nil, false, "dragon_slave_speed", nil, nil, nil, nil, true }, { 4, nil, false, nil, killsteal, nil, nil, nil, nil, nil, true }} },
				{ CDOTA_Unit_Hero_Zuus, {{ 2, nil, true }, { 1, nil, nil, nil, nil, nil, nil, nil, nil, nil, true }, { 4, nil, true, -0.1, killsteal, nil, nil, nil, nil, nil, true }} },
				{ CDOTA_Unit_Hero_Tinker, {{ 2 , "radius"}, { 1 }, { 4, nil, nil, nil, nil, nil, nil, nil, nil, nil, true }} },
				{ CDOTA_Unit_Hero_Lion, {{ 1, 450, true }, { 2, nil, true }, { 4, nil, false, nil, killsteal, nil, nil, nil, nil, nil, true }} },
				{ CDOTA_Unit_Hero_ShadowShaman, {{ 2, nil, true }, { 3, nil, true, nil, nil, nil, nil, nil, nil, nil, true }, { 1, nil, nil, nil, nil, nil, nil, nil, nil, nil, true }, { 4 }} },
				{ CDOTA_Unit_Hero_Axe, {{ 1, "radius", true }, { 2 }, { 4, nil, false, nil, true, nil, false, nil, nil, true }} },
				{ CDOTA_Unit_Hero_Necrolyte, {{ 1, "area_of_effect" }, { 4 }} },
				{ CDOTA_Unit_Hero_PhantomAssassin, {{ 1, nil, true, nil, false, "dagger_speed" }, { 2, nil, nil, nil, nil, nil, nil, nil, nil, nil, true }} },
				{ CDOTA_Unit_Hero_Pudge, {{ 1, nil, true, nil, false, "hook_speed", true, "hook_width", true, true }, { 4, nil, true, nil, nil, nil, nil, nil, nil, true, true }} },
				{ CDOTA_Unit_Hero_Earthshaker, {{ 4, 625, true}, { 2, 350, true }, { 1, nil, true, -0.1 }} },
				{ CDOTA_Unit_Hero_Skywrath_Mage, {{ 2, "launch_radius", true }, { 3 }, { 4, nil, false, 0.2 }, { 1 }} },
				{ CDOTA_Unit_Hero_Leshrac, {{ 1, nil, true, 0.35}, { 2, "radius" }, { 3, nil, true }, { 4, "radius" }} },
				{ CDOTA_Unit_Hero_Windrunner, {{ 1, nil, true, nil, false, "arrow_speed" }, { 2, nil, true, nil, false, "arrow_speed" }} },
				{ CDOTA_Unit_Hero_Rattletrap, {{ 4, nil, true, nil, false, nil, true, "latch_radius", true, true }, { 1, "radius", true, 0.7 }, { 3 }, { 2, 125, true, 0.1 }} },
				{ CDOTA_Unit_Hero_Ogre_Magi, {{ 4, nil, true }, { 1, nil, true }, { 2, nil, true, nil, false, "projectile_speed" }, { 3 }} },
				{ CDOTA_Unit_Hero_Kunkka, {{ "kunkka_x_marks_the_spot", nil, false, 0.1 }, { 1, nil, true, 1.7 }, { 4, nil, false, nil, false, "ghostship_speed" }} },
				{ CDOTA_Unit_Hero_Slardar, {{ 2, "crush_radius", true}, { 1, nil, true }, { 4 }} },
				{ CDOTA_Unit_Hero_Bane, {{ "bane_nightmare", nil, true, 1 }, { 4, nil, true}, { "bane_enfeeble" , nil, true }, { 2, nil, true }} },
				{ CDOTA_Unit_Hero_Bristleback, {{ 1 }, { 2, "radius", false, nil, false, nil, false, nil, nil, true }} },
				{ CDOTA_Unit_Hero_Centaur, {{ 1, "radius" }, { 2 }} },
				{ CDOTA_Unit_Hero_Clinkz, {{ 1, 630 }} },
				{ CDOTA_Unit_Hero_CrystalMaiden, {{ 1, nil, true, -0.1 }, { 2, nil, true }} },
				{ CDOTA_Unit_Hero_DeathProphet, {{ 1, nil, true }, { 2, nil, true, -0.1 }} },
				{ CDOTA_Unit_Hero_DoomBringer, {{ 2, "radius" }, { 4, nil, true }, { 3, nil, true}} },
				{ CDOTA_Unit_Hero_DragonKnight, {{ 2, nil, true }, { 1, nil, true }} },
				{ CDOTA_Unit_Hero_DrowRanger, {{ 2, nil, true, nil, false, "wave_speed" }} },
				{ CDOTA_Unit_Hero_Furion, {{ 1, nil, true, -0.1 }} },
				{ CDOTA_Unit_Hero_Huskar, {{ 4, nil, false, nil, false, "charge_speed" }} },
				{ CDOTA_Unit_Hero_Jakiro, {{ 2, nil, true, 0.5 }, { 1, nil, true }} },
				{ CDOTA_Unit_Hero_Lich, {{ 1, nil, true }, { 2 }} },
				{ CDOTA_Unit_Hero_Life_Stealer, {{ 3, nil, true }} },
				{ CDOTA_Unit_Hero_Luna, {{ 1, nil, true }} },
				{ CDOTA_Unit_Hero_Mirana, {{ 2, nil, true, nil, false, "arrow_speed", true, "arrow_width", "ally" }, { 1, 400 }} },
				{ CDOTA_Unit_Hero_Morphling, {{ 1 }, { 2, nil, true, nil, false, "projectile_speed" }} },
				{ CDOTA_Unit_Hero_NightStalker, {{ 1, nil, true }, { 2, nil, true}} },
				{ CDOTA_Unit_Hero_Nyx_Assassin, {{ 1, nil, true }, { 2 }} },
				{ CDOTA_Unit_Hero_QueenOfPain, {{ 1, nil, true, nil, false, "projectile_speed" }, { 3 , "area_of_effect" }, { 4, nil, true, nil, false, "speed" }} },
				{ CDOTA_Unit_Hero_Razor, {{ 2 }, { 1, "radius" }} },
				{ CDOTA_Unit_Hero_Riki, {{ 1, nil, true, -0.1 }, { 4 }} },
				{ CDOTA_Unit_Hero_Sniper, {{ 1, "radius", true, 1.4 }, { 4, nil, false, nil, true }} },
				{ CDOTA_Unit_Hero_SpiritBreaker, {{ 1, nil, true, nil, false, "movement_speed" }, { 4, nil, true }} },
				{ CDOTA_Unit_Hero_Sven, {{ "sven_storm_bolt", nil, true, nil, false, "bolt_speed" }} },
				{ CDOTA_Unit_Hero_Tidehunter, {{ 1, nil, true, nil, false, "projectile_speed" }, { 3, "radius"}} },
				{ CDOTA_Unit_Hero_Tiny, {{ 1, nil, true, 0.5 }, { 2 }} },
				{ CDOTA_Unit_Hero_Invoker, {} },
				{ CDOTA_Unit_Hero_TemplarAssassin, {{ 2, nil, nil, nil, nil, nil, nil, nil, nil, nil, true }, { 1 }} },
				{ CDOTA_Unit_Hero_Abaddon, {{ 2 }, { 1 }} },
				{ CDOTA_Unit_Hero_AncientApparition, {{ 1, nil, true, 4 }, { 2, nil, true }, { "ancient_apparition_ice_blast", nil, true, 2.01}, { "ancient_apparition_ice_blast_release" }} },
				{ CDOTA_Unit_Hero_AntiMage, {{ 4, nil, false, nil, true }} },
				{ CDOTA_Unit_Hero_Batrider, {{ 4, nil, true, "duration", false, nil, false, nil, nil, true }, { 1, nil, false, 0.2 }, { 2, nil, true, 0.3 }} },
				{ CDOTA_Unit_Hero_Beastmaster, {{ "beastmaster_primal_roar", nil, true }, { 1, nil, true }, { "beastmaster_call_of_the_wild_boar", nil, true }} },
				{ CDOTA_Unit_Hero_BountyHunter, {{ 4 }, { 1, nil, true, nil, true }} },
				{ CDOTA_Unit_Hero_Broodmother, {{ 1 }} },
				{ CDOTA_Unit_Hero_ChaosKnight, {{ 2, nil, true, nil, nil, nil, nil, nil, nil, nil, true }, { 1, nil, true }} },
				{ CDOTA_Unit_Hero_Elder_Titan, {{ "elder_titan_ancestral_spirit", nil, true }, { 1, "radius", true }, { "elder_titan_earth_splitter" }} },
				{ CDOTA_Unit_Hero_Enchantress, {{ 2, nil, true }} },
				{ CDOTA_Unit_Hero_Enigma, {{ 1, nil, true}, { 3 }} },
				{ CDOTA_Unit_Hero_Legion_Commander, {{ 2 }, { 1, nil, true }, { 4 }} },
				{ CDOTA_Unit_Hero_Magnataur, {{ 1, nil, nil, nil, nil, "shock_speed" }, { 3, nil, true, nil, nil, "skewer_speed" }} },
				{ CDOTA_Unit_Hero_Medusa, {{ 1 }} },
				{ CDOTA_Unit_Hero_Naga_Siren, {{ 2, nil, true, nil, false, "net_speed", nil, nil, nil, true }, { 3, "radius" }} },
				{ CDOTA_Unit_Hero_Omniknight, {{ 1, "radius" }, { 2 }} },
				{ CDOTA_Unit_Hero_Pugna, {{ 1, nil, true }, { 2, nil, true }} },
				{ CDOTA_Unit_Hero_Shadow_Demon, {{ 5, nil, true}, { 1, nil, true }, { 2 }, { 3 }} },
				{ CDOTA_Unit_Hero_SkeletonKing, {{ 1, nil, true, nil, false, "blast_speed" }} },
				{ CDOTA_Unit_Hero_Spectre, {{ 1 }} },
				{ CDOTA_Unit_Hero_VengefulSpirit, {{ 1, nil, true, nil, false, "magic_missile_speed"}, { 2 }} },
				{ CDOTA_Unit_Hero_Venomancer, {{ 1, nil, true }, { 3 }} },
				{ CDOTA_Unit_Hero_Brewmaster, {{ 1, "radius", true }, { 2, nil, true }} },
				{ CDOTA_Unit_Hero_StormSpirit, {{ 4, nil, true, nil, false, "ball_lightning_move_speed" }, { 2, nil, true }, { 1 }} },
				{ CDOTA_Unit_Hero_EmberSpirit, {{ "ember_spirit_fire_remnant" }, { "ember_spirit_activate_fire_remnant" }, { 2, "radius"}, { 1, "radius", true }, { 3, "radius"}} },
				{ CDOTA_Unit_Hero_Slark, {{ 1, "radius"}, { 2, "pounce_radius", true, nil, false, "pounce_speed" }} },
				{ CDOTA_Unit_Hero_Nevermore, {{ 1, "shadowraze_range"}, { 2, "shadowraze_range"}, { 3, "shadowraze_range"}} },
				{ CDOTA_Unit_Hero_Weaver, {{ 1, "radius"}, { 2 }} },
				{ CDOTA_Unit_Hero_TrollWarlord, {{ "troll_warlord_whirling_axes_ranged", nil, true, nil, false, "axe_speed"}, { "troll_warlord_whirling_axes_melee", "max_range" }} },
				{ CDOTA_Unit_Hero_EarthSpirit, {{ 1, nil, true }, { 3, nil, false }, { 2, nil, false, 0.6 }} },
				{ CDOTA_Unit_Hero_LoneDruid, {{ "lone_druid_rabid" }, { "lone_druid_true_form_battle_cry", 700 }} },
				{ CDOTA_Unit_Hero_Wisp, {{ "wisp_spirits", 1300 }} },
				{ CDOTA_Unit_Hero_Chen, {{ "chen_penitence" }, { "chen_test_of_faith" }} },
				{ CDOTA_Unit_Hero_Phoenix, {{ 1, nil, true }, { 2, nil, true, nil, nil, "spirit_speed" }, { "phoenix_sun_ray", nil, false, nil, true }, { "phoenix_sun_ray_toggle_move" }} },
				{ CDOTA_Unit_Hero_Tusk, {{ 2, nil, true, nil, false, "snowball_speed" }, { "tusk_ice_shards", nil, true, nil, false, "shard_speed" }, { 3, nil, true }, { "tusk_walrus_punch", nil, false }, { "tusk_walrus_kick", nil, true }} },				
				{ CDOTA_Unit_Hero_Visage, {{ 1, nil, true }, { 2 }} },
				{ CDOTA_Unit_Hero_Gyrocopter, {{ 2, nil, true, 3, false, "speed" }, { 1, "radius" }, { 3, "radius" }} },
				{ CDOTA_Unit_Hero_Undying, {{ 1 }, { 2 }, { 3, "radius" }} },
				{ CDOTA_Unit_Hero_Terrorblade, {{ 4 }, { 1, nil, true }, { 3 }, { 2 }} },
				{ CDOTA_Unit_Hero_Puck, {{ "puck_waning_rift", "radius", true }, { "puck_illusory_orb", nil, false, nil, false, "orb_speed" }, { "puck_ethereal_jaunt" }} },
				{ CDOTA_Unit_Hero_Treant, {{ 2, nil, true }} },
				{ CDOTA_Unit_Hero_PhantomLancer, {{ 1, nil, true, nil, false, "lance_speed" }} },
				{ CDOTA_Unit_Hero_Silencer, {{ 3, nil, true, 4 }, { 2 }} },
				{ CDOTA_Unit_Hero_Disruptor, {{ "disruptor_kinetic_field", nil, true, 1.2 }, { 1 }, { "disruptor_glimpse", nil, true }} },
				{ CDOTA_Unit_Hero_KeeperOfTheLight, {{ "keeper_of_the_light_illuminate" }, { "keeper_of_the_light_spirit_form_illuminate" }, { "keeper_of_the_light_mana_leak", nil, true }, { "keeper_of_the_light_blinding_light", nil, true }} },
				{ CDOTA_Unit_Hero_Oracle, {{ 1, nil, true, nil, false, "bolt_speed" }, { "oracle_purifying_flames", nil, false, nil, true }} },
				{ CDOTA_Unit_Hero_SandKing, {{ 1, nil, true, nil, false, "burrow_speed" }} },
				{ CDOTA_Unit_Hero_Warlock, {{ 1 }, { 2 }} },
				{ CDOTA_Unit_Hero_DarkSeer, {{ 1, "radius", true }, { 4 }, { 2 }, { 3, nil, true }} },
				{ CDOTA_Unit_Hero_Winter_Wyvern, {{ 2 }} },
				{ CDOTA_Unit_Hero_Rubick, {{ 1, nil, true }, { "rubick_telekinesis_land" }, { "ursa_earthshock", "shock_radius", true}, 
																			{ "ursa_overpower", nil, false, nil, false, nil, false, nil, nil, true, true }, 
																			{ "ursa_enrage", 350, false, nil, false, nil, false, nil, nil, true },
																			{ "bloodseeker_rupture", nil, false, nil, false, nil, false, nil, nil, true }, 
																			{ "bloodseeker_blood_bath" , nil, false, 2.6}, 
																			{ "bloodseeker_bloodrage", nil, false, nil, false, nil, false, nil, nil, true, true },
  																			{ "lina_light_strike_array", nil, true , 0.5}, 
																			{ "lina_dragon_slave", nil, true, nil, false, "dragon_slave_speed", nil, nil, nil, nil, true }, 
																			{ "lina_laguna_blade", nil, false, nil, killsteal, nil, nil, nil, nil, nil, true }, 
																			{ "zuus_lightning_bolt", nil, true }, 
																			{ "zuus_arc_lightning", nil, nil, nil, nil, nil, nil, nil, nil, nil, true }, 
																			{ "zuus_thundergods_wrath", nil, true, -0.1, killsteal, nil, nil, nil, nil, nil, true },
																			{ "tinker_heat_seeking_missile" , "radius"}, 
																			{ "tinker_laser" }, 
																			{ "tinker_rearm", nil, nil, nil, nil, nil, nil, nil, nil, nil, true }, 
																			{ "lion_voodoo", 450, true }, 
																			{ "lion_impale", nil, true }, 
																			{ "lion_finger_of_death", nil, false, nil, killsteal, nil, nil, nil, nil, nil, true },
																			{ "shadow_shaman_voodoo", nil, true }, 
																			{ "shadow_shaman_shackles", nil, true, nil, nil, nil, nil, nil, nil, nil, true }, 
																			{ "shadow_shaman_ether_shock", nil, nil, nil, nil, nil, nil, nil, nil, nil, true }, 
																			{ "shadow_shaman_mass_serpent_ward" },
																			{ "axe_berserkers_call", "radius", true }, 
																			{ "axe_battle_hunger" }, 
																			{ "axe_culling_blade", nil, false, nil, true, nil, false, nil, nil, true },
																			{ "necrolyte_death_pulse", "area_of_effect" }, 
																			{ "necrolyte_reapers_scythe" },
																			{ "phantom_assassin_stifling_dagger", nil, true, nil, false, "dagger_speed" }, 
																			{ "phantom_assassin_phantom_strike", nil, nil, nil, nil, nil, nil, nil, nil, nil, true },
																			{ "pudge_meat_hook", nil, true, nil, false, "hook_speed", true, "hook_width", true, true }, 
																			{ "pudge_dismember", nil, true, nil, nil, nil, nil, nil, nil, true, true },
																			{ "earthshaker_echo_slam", 625, true}, 
																			{ "earthshaker_enchant_totem", 350, true }, 
																			{ "earthshaker_fissure", nil, true, -0.1 },
																			{ "skywrath_mage_concussive_shot", "launch_radius", true }, 
																			{ "skywrath_mage_ancient_seal" }, 
																			{ "skywrath_mage_mystic_flare", nil, false, 0.2 }, 
																			{ "skywrath_mage_ancient_seal" },
																			{ "leshrac_split_earth", nil, true, 0.35}, 
																			{ "leshrac_diabolic_edict", "radius" }, 
																			{ "leshrac_lightning_storm", nil, true }, 
																			{ "leshrac_pulse_nova", "radius" },
																			{ "windrunner_shackleshot", nil, true, nil, false, "arrow_speed" }, 
																			{ "windrunner_powershot", nil, true, nil, false, "arrow_speed" },
																			{ "rattletrap_hookshot", nil, true, nil, false, nil, true, "latch_radius", true, true }, 
																			{ "rattletrap_battery_assault", "radius", true, 0.7 }, 
																			{ "rattletrap_rocket_flare" }, 
																			{ "rattletrap_power_cogs", 125, true, 0.1 },
																			{ "ogre_magi_unrefined_fireblast", nil, true }, 
																			{ "ogre_magi_fireblast", nil, true }, 
																			{ "ogre_magi_ignite", nil, true, nil, false, "projectile_speed" }, 
																			{ "ogre_magi_bloodlust" },
																			{ "kunkka_x_marks_the_spot", nil, false, 0.1 }, 
																			{ "kunkka_torrent", nil, true, 1.7 }, 
																			{ "kunkka_ghostship", nil, false, nil, false, "ghostship_speed" },
																			{ "slardar_slithereen_crush", "crush_radius", true}, 
																			{ "slardar_sprint", nil, true }, 
																			{ "slardar_amplify_damage" },
																			{ "bane_nightmare", nil, true, 1 }, 
																			{ "bane_fiends_grip", nil, true}, 
																			{ "bane_enfeeble" , nil, true }, 
																			{ "bane_brain_sap", nil, true },
																			{ "bristleback_viscous_nasal_goo" }, 
																			{ "bristleback_quill_spray", "radius", false, nil, false, nil, false, nil, nil, true },
																			{ "centaur_hoof_stomp", "radius", true }, 
																			{ "centaur_double_edge" },
																			{ "clinkz_strafe", 630 },
																			{ "crystal_maiden_freezing_field", nil, true, -0.1 }, 
																			{ "crystal_maiden_frostbite", nil, true },
																			{ "death_prophet_carrion_swarm", nil, true }, 
																			{ "death_prophet_silence", nil, true, -0.1 },
																			{ "doom_bringer_scorched_earth", "radius" }, 
																			{ "doom_bringer_doom", nil, true }, 
																			{ "doom_bringer_lvl_death", nil, true},
																			{ "dragon_knight_dragon_tail", nil, true }, 
																			{ "dragon_knight_breathe_fire", nil, true },
																			{ "drow_ranger_wave_of_silence", nil, true, nil, false, "wave_speed" },
																			{ "furion_sprout", nil, true, -0.1 },
																			{ "huskar_life_break", nil, false, nil, false, "charge_speed" },
																			{ "jakiro_ice_path", nil, true, 0.5 }, 
																			{ "jakiro_dual_breath", nil, true },
																			{ "lich_frost_nova", nil, true }, 
																			{ "lich_frost_armor" },
																			{ "life_stealer_open_wounds", nil, true },
																			{ "luna_lucent_beam", nil, true },
																			{ "mirana_arrow", nil, true, nil, false, "arrow_speed", true, "arrow_width", "ally" }, 
																			{ "mirana_starfall", 400 },
																			{ "morphling_waveform" }, 
																			{ "morphling_adaptive_strike", nil, true, nil, false, "projectile_speed" },
																			{ "night_stalker_void", nil, true }, 
																			{ "night_stalker_crippling_fear", nil, true },
																			{ "nyx_assassin_impale", nil, true }, 
																			{ "nyx_assassin_mana_burn" },
																			{ "queenofpain_shadow_strike", nil, true, nil, false, "projectile_speed" }, 
																			{ "queenofpain_scream_of_pain" , "area_of_effect" }, 
																			{ "queenofpain_sonic_wave", nil, true, nil, false, "speed" },
																			{ "razor_static_link" }, 
																			{ "razor_plasma_field", "radius" },
																			{ "riki_smoke_screen", nil, true, -0.1 }, 
																			{ "riki_blink_strike" },
																			{ "sniper_shrapnel", "radius", true, 1.4 }, 
																			{ "sniper_assassinate", nil, false, nil, true },
																			{ "spirit_breaker_charge_of_darkness", nil, true, nil, false, "movement_speed" }, 
																			{ "spirit_breaker_nether_strike", nil, true },
																			{ "sven_storm_bolt", nil, true, nil, false, "bolt_speed" },
																			{ "tidehunter_gush", nil, true, nil, false, "projectile_speed" }, 
																			{ "tidehunter_anchor_smash", "radius" },
																			{ "tiny_avalanche", nil, true, 0.5 }, 
																			{ "tiny_toss" },
																			{ "invoker_cold_snap"}, {"invoker_ice_wall", 590, true, 1},
																			{ "invoker_tornado", "travel_distance", true, nil, false, "travel_speed"}, {"invoker_emp", nil, false, 2.9},
																			{ "invoker_forge_spirit", 700}, {"invoker_sun_strike", nil, false, 1.7}, {"invoker_chaos_meteor", nil, false, 1.3}, {"invoker_alacrity", nil, nil, nil, nil, nil, nil, nil, nil, nil, true},
																			{ "invoker_deafening_blast", "travel_distance", true, nil, false, "travel_speed"}, {"invoker_ghost_walk", nil, true},
																			{ "templar_assassin_meld", nil, nil, nil, nil, nil, nil, nil, nil, nil, true }, 
																			{ "templar_assassin_refraction" },
																			{ "abaddon_aphotic_shield" }, { "abaddon_death_coil" },
																			{ "ancient_apparition_cold_feet", nil, true, 4 }, 
																			{ "ancient_apparition_ice_vortex", nil, true }, 
																			{ "ancient_apparition_ice_blast", nil, true, 2.01}, 
																			{ "ancient_apparition_ice_blast_release" },
																			{ "antimage_mana_void", nil, false, nil, true },
																			{ "batrider_flaming_lasso", nil, true, "duration", false, nil, false, nil, nil, true }, 
																			{ "batrider_sticky_napalm", nil, false, 0.2 }, 
																			{ "batrider_flamebreak", nil, true, 0.3 },
																			{ "beastmaster_primal_roar", nil, true }, 
																			{ "beastmaster_wild_axes", nil, true }, 
																			{ "beastmaster_call_of_the_wild_boar", nil, true },
																			{ "bounty_hunter_track" }, 
																			{ "bounty_hunter_shuriken_toss", nil, true, nil, true },
																			{ "broodmother_spawn_spiderlings" },
																			{ "chaos_knight_chaos_strike", nil, true, nil, nil, nil, nil, nil, nil, nil, true }, 
																			{ "chaos_knight_chaos_bolt", nil, true },
																			{ "elder_titan_ancestral_spirit", nil, true }, 
																			{ "elder_titan_echo_stomp", "radius", true }, 
																			{ "elder_titan_earth_splitter" },
																			{ "enchantress_enchant", nil, true },
																			{ "enigma_malefice", nil, true}, 
																			{ "enigma_midnight_pulse" },
																			{ "legion_commander_press_the_attack" }, 
																			{ "legion_commander_overwhelming_odds", nil, true }, 
																			{ "legion_commander_duel" },
																			{ "magnataur_shockwave", nil, nil, nil, nil, "shock_speed" }, 
																			{ "magnataur_skewer", nil, true, nil, nil, "skewer_speed" },
																			{ "medusa_mystic_snake" },
																			{ "naga_siren_ensnare", nil, true, nil, false, "net_speed", nil, nil, nil, true }, 
																			{ "naga_siren_rip_tide", "radius" },
																			{ "omniknight_purification" },
																			{ "omniknight_repel" },
																			{ "pugna_nether_blast", nil, true }, 
																			{ "pugna_decrepify", nil, true },
																			{ "shadow_demon_demonic_purge", nil, true}, 
																			{ "shadow_demon_disruption", nil, true }, 
																			{ "shadow_demon_soul_catcher" }, 
																			{ "shadow_demon_shadow_poison" },
																			{ "skeleton_king_hellfire_blast", nil, true, nil, false, "blast_speed" },
																			{ "spectre_spectral_dagger" },
																			{ "vengefulspirit_magic_missile", nil, true, nil, false, "magic_missile_speed"}, 
																			{ "vengefulspirit_wave_of_terror" },
																			{ "venomancer_venomous_gale", nil, true }, 
																			{ "venomancer_plague_ward" },
																			{ "brewmaster_thunder_clap", "radius", true }, 
																			{ "brewmaster_drunken_haze", nil, true },
																			{ "storm_spirit_ball_lightning", nil, true, nil, false, "ball_lightning_move_speed" }, 
																			{ "storm_spirit_electric_vortex", nil, true }, 
																			{ "storm_spirit_static_remnant" },
																			{ "ember_spirit_fire_remnant" }, 
																			{ "ember_spirit_activate_fire_remnant" }, 
																			{ "ember_spirit_sleight_of_fist", "radius"}, 
																			{ "ember_spirit_searing_chains", "radius", true }, 
																			{ "ember_spirit_flame_guard", "radius" },
																			{ "slark_dark_pact", "radius"}, 
																			{ "slark_pounce", "pounce_radius", true, nil, false, "pounce_speed" },
																			{ "nevermore_shadowraze1", "shadowraze_range" }, 
																			{ "nevermore_shadowraze2", "shadowraze_range" }, 
																			{ "nevermore_shadowraze3", "shadowraze_range" },
																			{ "weaver_the_swarm", "radius"}, 
																			{ "weaver_shukuchi" },
																			{ "troll_warlord_whirling_axes_ranged", nil, true, nil, false, "axe_speed"}, 
																			{ "troll_warlord_whirling_axes_melee", "max_range" },
																			{ "earth_spirit_boulder_smash", nil, true }, 
																			{ "earth_spirit_geomagnetic_grip", nil, false }, 
																			{ "earth_spirit_rolling_boulder", nil, false, 0.6 },
																			{ "lone_druid_rabid" }, { "lone_druid_true_form_battle_cry", 700 },
																			{ "wisp_spirits", 1300 },
																			{ "chen_penitence" }, { "chen_test_of_faith" },
																			{ "phoenix_icarus_dive", nil, true }, 
																			{ "phoenix_icarus_dive_stop" }, 
																			{ "phoenix_fire_spirits", nil, true, nil, nil, "spirit_speed" }, 
																			{ "phoenix_sun_ray", nil, false, nil, true }, 
																			{ "phoenix_sun_ray_toggle_move" },
																			{ "tusk_snowball", nil, true, nil, false, "snowball_speed" }, 
																			{ "tusk_ice_shards", nil, true, nil, false, "shard_speed" }, 
																			{ "tusk_frozen_sigil", nil, true }, 
																			{ "tusk_walrus_punch", nil, false }, 
																			{ "tusk_walrus_kick", nil, true },				
																			{ "visage_grave_chill", nil, true }, 
																			{ "visage_soul_assumption" }, 
																			{ "gyrocopter_homing_missile" , nil, true, 3, false, "speed" }, { "gyrocopter_rocket_barrage", "radius" }, 
																			{ "gyrocopter_flak_cannon", "radius" },
																			{ "undying_decay" }, 
																			{ "undying_soul_rip" }, 
																			{ "undying_tombstone", "radius" },
																			{ "terrorblade_sunder" }, 
																			{ "terrorblade_reflection", nil, true }, 
																			{ "terrorblade_metamorphosis" }, 
																			{ "terrorblade_conjure_image" },
																			{ "puck_waning_rift", "radius", true }, 
																			{ "puck_illusory_orb", nil, false, nil, false, "orb_speed" }, 
																			{ "puck_ethereal_jaunt" },
																			{ "treant_leech_seed", nil, true },
																			{ "phantom_lancer_spirit_lance", nil, true, nil, false, "lance_speed" },
																			{ "silencer_last_word", nil, true, 4 }, 
																			{ "silencer_curse_of_the_silent" },
																			{ "disruptor_kinetic_field", nil, true, 1.2 }, 
																			{ "disruptor_thunder_strike" }, 
																			{ "disruptor_glimpse", nil, true },
																			{ "keeper_of_the_light_illuminate" }, 
																			{ "keeper_of_the_light_spirit_form_illuminate" }, 
																			{ "keeper_of_the_light_mana_leak", nil, true }, 
																			{ "keeper_of_the_light_blinding_light", nil, true },
																			{ "oracle_fortunes_end", nil, true, nil, false, "bolt_speed" }, 
																			{ "oracle_purifying_flames", nil, false, nil, true },
																			{ "sandking_burrowstrike", nil, true, nil, false, "burrow_speed" },
																			{ "warlock_fatal_bonds" }, 
																			{ "warlock_shadow_word" },
																			{ "dark_seer_vacuum", "radius", true }, 
																			{ "dark_seer_wall_of_replica" }, 
																			{ "dark_seer_ion_shell" }, 
																			{ "dark_seer_surge", nil, true },
																			{ "winter_wyvern_splinter_blast" }, { 3 }} }
			}
			script:RegisterEvent(EVENT_FRAME, Main)
			script:RegisterEvent(EVENT_KEY, Key)
			script:UnregisterEvent(Load)
		end
	end	
end

function Close()
	statusText.visible = false
	myhero = nil
	atr = nil
	victim = nil
	myId = nil
	start = false
	resettime = nil
	damageTable = {}
	indicate = {}
	type = nil
	targetlock = false
	tuskSnowBall = false
	if HUD then
		HUD:Close()	
		HUD = nil
		buttons = {}
	end
	collectgarbage("collect")
	if reg then
		script:UnregisterEvent(Main)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK, Load)	
		reg = false
	end
end

script:RegisterEvent(EVENT_CLOSE, Close)
script:RegisterEvent(EVENT_TICK, Load)
