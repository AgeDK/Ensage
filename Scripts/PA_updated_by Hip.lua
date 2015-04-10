--<<Edited PA script by HippyFizz | Version: 2.0>>
--[[
----------------------------------------------
| Original Phantom Assassin Script was made by edwynxero |
----------------------------------------------
================= Version 2.0 ================
Description:
------------
Phantom Assassin Ultimate Combo
- Stifling Dagger
- Phantom Strike
- Abbysal Blade (use '[' and ']' to add and minus HP TO AUTO ABYSSAL})
Features
- Auto use medalion
- Avoid target BKB, Ghost, Dazzle, Windrunner etc
- Excludes Illusions
- One Key Combo Initiator (keep key pressed to continue combo)
]]--

--LIBRARIES
require("libs.ScriptConfig")
require("libs.TargetFind")
require("libs.Utils")

--CONFIGURATION
config = ScriptConfig.new()
--[[config:SetParameter("AvoidDazzleGrave", true,config.TYPE_BOOL)
config:SetParameter("AvoidBKB",true,config.TYPE_BOOL)]]
config:SetParameter("ComboKey", "R", config.TYPE_HOTKEY)
config:SetParameter("AbyssBtn", "E", config.TYPE_HOTKEY)
config:SetParameter("TargetLeastHP", false,config.TYPE_BOOL)
config:SetParameter("AutoAbyssal",false,config.TYPE_BOOL)
config:SetParameter("HpToAbyssal", 0.50)
config:SetParameter("PlusHpToAbyss", 219, config.TYPE_HOTKEY)
config:SetParameter("MinusHpToAbyss",221, config.TYPE_HOTKEY)
config:Load()

--SETTINGS
local comboKey = config.ComboKey
local abyssal_btn = config.AbyssBtn
local hp_to_use_abyssal = config.HpToAbyssal
local plus_hp = config.PlusHpToAbyss
local minus_hp = config.MinusHpToAbyss
local getLeastHP = config.TargetLeastHP
local avoid_bkb = config.AvoidBKB
local avoid_grave = config.AvoidDazzleGrave
local auto_abyssal = config.AutoAbyssal
local registered= false
local range = 1000

local avoid_1 
local avoid_2 
local info = {}
local TitleFont = drawMgr:CreateFont("Title","Segoe UI",18,580) 
local ControlFont = drawMgr:CreateFont("Title","Segoe UI",14,500)
info[1] = drawMgr:CreateText(5,45,0x6CF58CFF," Press  " .. string.char(comboKey) .." to use combo",ControlFont) info[1].visible = false
info[2] = drawMgr:CreateText(5,60,0x6CF58CFF," Press  " .. string.char(abyssal_btn) .." to Abyssal target under cursor",ControlFont) info[2].visible = false
info[3] = drawMgr:CreateText(5,75,0x6CF58CFF," Auto Abyssal when target has " ..(hp_to_use_abyssal*100).."% HP",ControlFont) info[3].visible = false
--CODE
local target    = nil
local active    = false

--[[Loading Script...]]
function onLoad()
	if PlayingGame() then
		local me = entityList:GetMyHero()
			if not me or me.classId ~= CDOTA_Unit_Hero_PhantomAssassin then
				script:Disable()
			else
				print("PA loaded")
				registered = true
				info[1].visible = true
				script:RegisterEvent(EVENT_TICK,Main)
				script:RegisterEvent(EVENT_KEY,Key)
				script:UnregisterEvent(onLoad)
			end
	end
end

--check if comboKey is pressed
function Key(msg,code)
	if client.chat or client.console or client.loading then return end
		
	if code == comboKey then
		active = (msg == KEY_DOWN)
		return true
	end
	
	if code == abyssal_btn then
		use_abyssal()
	end
	
	if IsKeyDown(plus_hp) then	
		if hp_to_use_abyssal < 1 then
			hp_to_use_abyssal = hp_to_use_abyssal + 0.05
			local user_value = hp_to_use_abyssal*100
			info[3].text = "Auto Abyssal when target has "..tostring(user_value).."% HP"
		end
	end
	
	if IsKeyDown(minus_hp) then
		if hp_to_use_abyssal > 0.051 then
			hp_to_use_abyssal = hp_to_use_abyssal - 0.05
			local user_value = hp_to_use_abyssal*100
			info[3].text = "Auto Abyssal when target has "..tostring(user_value).."% HP"
		end
	end
end

function Main(tick)
	if not SleepCheck() then return end

	local me = entityList:GetMyHero()
	local medalion = medalion_find()
	local asd = abyssal_find()
	if asd ~= false then
		info[2].visible = true
		if auto_abyssal then
			info[3].visible = true
		else
			info[3].visible = false
		end
	else
		info[2].visible = false
		info[3].visible = false
	end
	if not me then return end

	-- Get hero abilities --
	local StiflingDagger = me:GetAbility(1)
	local PhantomStrike = me:GetAbility(2)
	
	if active then
		if not inCombo then 
			if getLeastHP then
				target = targetFind:GetLowestEHP(range,"phys")
			else
				target = FindTarget()
			end
		end
		--[[if avoid_bkb and not target==nil then
			avoid_1 = target:IsMagicDmgImmune()
		else
			avoid_1 = false
		end
		if avoid_grave and not target==nil then
			avoid_2 = target:DoesHaveModifier("modifier_dazzle_shallow_grave")
		else 
			avoid_2 = false
		end]]
		
		-- Do the combo! --
		if target then
			if target.alive and target.visible and target:GetDistance2D(me) < range 
			and not target:IsPhysDmgImmune() 
			and not target:IsMagicDmgImmune()
			and not target:DoesHaveModifier("modifier_dazzle_shallow_grave") 
			and not target:DoesHaveModifier("modifier_windrunner_windrun") 
			and (me:IsMagicDmgImmune() or not target:DoesHaveModifier("modifier_item_blade_mail_reflect")) then
				inCombo = true
				if auto_abyssal and target.health/target.maxHealth < hp_to_use_abyssal then
					use_abyssal()
				end
				me:SafeCastAbility(StiflingDagger,target)
				me:SafeCastAbility(PhantomStrike,target)
				if medalion == false then
				else
					me:SafeCastItem("item_medallion_of_courage",target)
				end
				me:Attack(target)
				Sleep(200)
				return
			else
				inCombo = false
			end
		end
	end
end

function FindTarget()
	-- Get visible enemies --
	local me = entityList:GetMyHero()
	local enemies = entityList:FindEntities({type=LuaEntity.TYPE_HERO,team = me:GetEnemyTeam(),alive=true,visible=true,illusion=false})
	local closest = nil

	if enemies[2] == nil then
		for i,v in ipairs(enemies) do
			distance = GetDistance2D(v,me)
			if distance <= range then 
				if closest == nil then
					closest = v
				elseif distance < GetDistance2D(closest,me) then
					closest = v
				end
			end
		end
	else
		for i,v in ipairs(enemies) do
			if pcall(function()
				distance = GetDistance2D(v,me)
				if distance <= range then 
					if closest == nil and not v:IsPhysDmgImmune() and not v:IsMagicDmgImmune() 
					and not v:DoesHaveModifier("modifier_dazzle_shallow_grave")
					and not v:DoesHaveModifier("modifier_windrunner_windrun") 
					and (me:IsMagicDmgImmune() or not v:DoesHaveModifier("modifier_item_blade_mail_reflect")) then
						closest = v
					elseif closest~=nil then
						if distance < GetDistance2D(closest,me) and not v:IsMagicDmgImmune()  
						and not v:DoesHaveModifier("modifier_dazzle_shallow_grave")  
						and not v:DoesHaveModifier("modifier_windrunner_windrun") 
						and (me:IsMagicDmgImmune() or not v:DoesHaveModifier("modifier_item_blade_mail_reflect")) then
							closest = v
						end
					end
				end
					end) then
			end
		end
	end
	if closest == nil then return false
	else return closest
	end
end

function onClose()
	collectgarbage("collect")
	if registered then
		info[1].visible = false
		info[2].visible = false
		info[3].visible = false
		target = nil
		active = false
		script:UnregisterEvent(Main)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,onLoad)
		registered = false
	end
end

function medalion_find()
	local me = entityList:GetMyHero()
	if me == nil then return false end
	local user_value = me:FindItem("item_medallion_of_courage")
	if user_value == nil then
		return false
	else 
		return user_value
	end
end

function abyssal_find()
	local me = entityList:GetMyHero()
	if me == nil then return false end
	local user_value = me:FindItem("item_abyssal_blade")
	if user_value == nil then
		return false
	else 
		return user_value
	end	
end

function use_abyssal()
	local abyssal = abyssal_find()
	if abyssal == false then return false end
	local me = entityList:GetMyHero()
	local cursor = targetFind:GetClosestToMouse(50)
	me:CastItem(abyssal.name,cursor,false)
end

script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)
