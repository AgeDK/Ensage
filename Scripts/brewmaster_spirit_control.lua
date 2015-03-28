--<<HippyFizz Brewmaster MOD Beta version 1.0.2>> 
require("libs.Utils")
require("libs.TargetFind")
require("libs.ScriptConfig")
require("libs.SkillShot")

config = ScriptConfig.new()
config:SetParameter("StunKey", "Z", config.TYPE_HOTKEY)
config:SetParameter("WindKey", "X", config.TYPE_HOTKEY)
config:SetParameter("InvisKey", "C", config.TYPE_HOTKEY)
config:SetParameter("CleanceKey", "B", config.TYPE_HOTKEY)
config:SetParameter("ComboKey", "V", config.TYPE_HOTKEY)
config:SetParameter("HideNotes", "H", config.TYPE_HOTKEY)
config:SetParameter("UseAghanimSkills", true)
config:SetParameter("Text X", 5)
config:SetParameter("Text Y", 45)
config:SetParameter("XX", 20)
config:SetParameter("YY", 0)
config:Load()

init = false
local cooldown = false
local manatick = false

local stun_key = config.StunKey
local wind_key = config.WindKey
local invis_key = config.InvisKey
local cleance_key = config.CleanceKey
local combo_key = config.ComboKey
local hide_hotes_key = config.HideNotes
local use_aghanim_skills = config.UseAghanimSkills

local stun_active = false
local wind_active = false
local invis_active = false
local cleance_active = false
local combo_active = false
local info_active = false

local main = {}
local selected = {}
local xx = config.XX
local yy = config.YY
local rate = client.screenSize.x/1600

main.rec = {} main.cyclone = {} main.boulder = {}
selected.cyclone_status = {} selected.boulder_status = {} selected.icon = {}

for i=1,5 do 
	selected.cyclone_status[i] = false
	selected.boulder_status[i] = false
end

Brewmaster_PrimalEarth = nil
Brewmaster_PrimalFire = nil
Brewmaster_PrimalStorm = nil

thunder_clap = nil
drunken_haze = nil
primal_split = nil

local CM_space_texture = "NyanUI/other/CM_space"
local CM_buttom_texture = "NyanUI/other/CM_buttom"

main.rec[1] = drawMgr:CreateRect(xx+350*rate,yy+8*rate,18*rate,18*rate,0xFFFFFF30,drawMgr:GetTextureId("NyanUI/miniheroes/brewmaster")) main.rec[1].visible = false
main.rec[2] = drawMgr:CreateRect(xx+320*rate,5*rate,215*rate,250*rate,0xFFFFFF30,drawMgr:GetTextureId("NyanUI/other/CM_status_1")) main.rec[2].visible = false
main.rec[3] = drawMgr:CreateRect(xx+490*rate,yy+72*rate,30*rate,30*rate,0x00000090,drawMgr:GetTextureId("NyanUI/spellicons/brewmaster_earth_hurl_boulder")) main.rec[3].visible = false
main.rec[4] = drawMgr:CreateRect(xx+450*rate,yy+72*rate,30*rate,30*rate,0xFFFFFF30,drawMgr:GetTextureId("NyanUI/spellicons/brewmaster_storm_cyclone")) main.rec[4].visible = false

local x,y = config:GetParameter("Text X"), config:GetParameter("Text Y")
local TitleFont = drawMgr:CreateFont("Title","Segoe UI",18,580) 
local ControlFont = drawMgr:CreateFont("Title","Segoe UI",14,500)
local text = drawMgr:CreateText(x,y,0x6CF58CFF,"HippyFizz Brewmaster MOD Beta",TitleFont) text.visible = false
local info = drawMgr:CreateText(x,y+16,0x6CF58CFF," Press  " .. string.char(hide_hotes_key) .." to show more info",ControlFont) info.visible = false
local button_message_1 = drawMgr:CreateText(x,y+16,0x6CF58CFF," >  " .. string.char(stun_key) .." stun enemy under mouse",ControlFont) button_message_1.visible = false
local button_message_2 = drawMgr:CreateText(x,y+32,0x6CF58CFF," >  " .. string.char(wind_key) .." wind enemy under mouse",ControlFont) button_message_2.visible = false
local button_message_3 = drawMgr:CreateText(x,y+48,0x6CF58CFF," >  " .. string.char(invis_key) .." use WINDWALK on BLUE ONE",ControlFont) button_message_3.visible = false
local button_message_4 = drawMgr:CreateText(x,y+64,0x6CF58CFF," >  " .. string.char(cleance_key) .." dispel magic under cursor",ControlFont) button_message_4.visible = false
local button_message_5 = drawMgr:CreateText(x,y+80,0x6CF58CFF," >  " .. string.char(combo_key) .." HOLD TO FULL AUTO COMBO",ControlFont) button_message_5.visible = false
local status = drawMgr:CreateText(x,y+100,0x2CFA02FF,"Script Status : Ready!",ControlFont) status.visible = false
local invis_status = drawMgr:CreateText(x,y+120,0xED5153FF,"WindWalk Status: Disable",ControlFont) invis_status.visible = false
local manawarning = drawMgr:CreateText(x,y+140,0xED5153FF,"",ControlFont) manawarning.visible = false

local activated = false

function Load_func()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Brewmaster then 
			script:Disable()
		else
		    registered = true
		    print("HippyFizz Brewmaster MOD Loaded")
			info.visible = true
			script:RegisterEvent(EVENT_TICK,Tick_func)
			script:RegisterEvent(EVENT_KEY,key)
			script:UnregisterEvent(Load_func)
		end
	end
end

function Close_func()
    collectgarbage("collect")
    if registered then
	    init = false
	    thunder_clap = nil
	    drunken_haze = nil
	    primal_split = nil
	    status.visible = false
	    invis_status.visible = false
	    manawarning.visible = false
	    button_message_1.visible = false
	    button_message_2.visible = false
	    button_message_3.visible = false
	    button_message_4.visible = false
	    button_message_5.visible = false
	    text.visible = false
	    info.visible = false
		main = {}
		selected = {}
	    script:UnregisterEvent(Tick)
	    script:UnregisterEvent(key)
	    script:RegisterEvent(EVENT_TICK,Load_func)
		registered = false
	end
end

function key(msg, code)
	if client.chat or client.console or client.loading or client.paused then return end
	
	if msg == LBUTTON_DOWN then
		if IsMouseOnButton(xx+350*rate,yy+8*rate,18*rate,18*rate) then
			activated = not activated
			return true
		elseif IsMouseOnButton(xx+457*rate,yy+105*rate,15*rate,15*rate) then
			selected.cyclone_status[1] = not selected.cyclone_status[1]
		elseif IsMouseOnButton(xx+457*rate,yy+135*rate,15*rate,15*rate) then
			selected.cyclone_status[2] = not selected.cyclone_status[2]
		elseif IsMouseOnButton(xx+457*rate,yy+165*rate,15*rate,15*rate) then
			selected.cyclone_status[3] = not selected.cyclone_status[3]
		elseif IsMouseOnButton(xx+457*rate,yy+195*rate,15*rate,15*rate) then
			selected.cyclone_status[4] = not selected.cyclone_status[4]
		elseif IsMouseOnButton(xx+457*rate,yy+225*rate,15*rate,15*rate) then
			selected.cyclone_status[5] = not selected.cyclone_status[5]
		elseif IsMouseOnButton(xx+497*rate,yy+105*rate,15*rate,15*rate) then
			selected.boulder_status[1] = not selected.boulder_status[1]
		elseif IsMouseOnButton(xx+497*rate,yy+135*rate,15*rate,15*rate) then
			selected.boulder_status[2] = not selected.boulder_status[2]
		elseif IsMouseOnButton(xx+497*rate,yy+165*rate,15*rate,15*rate) then
			selected.boulder_status[3] = not selected.boulder_status[3]
		elseif IsMouseOnButton(xx+497*rate,yy+195*rate,15*rate,15*rate) then
			selected.boulder_status[4] = not selected.boulder_status[4]
		elseif IsMouseOnButton(xx+497*rate,yy+225*rate,15*rate,15*rate) then
			selected.boulder_status[5] = not selected.boulder_status[5]
		end
	end
	
	if IsKeyDown(hide_hotes_key) then
		info_active = (msg == KEY_DOWN)
		info.visible = not info.visible
		button_message_1.visible = not button_message_1.visible
		button_message_2.visible = not button_message_2.visible
		button_message_3.visible = not button_message_3.visible
		button_message_4.visible = not button_message_4.visible
		button_message_5.visible = not button_message_5.visible
	end
	
	if code == stun_key then
		stun_active = (msg == KEY_DOWN)
		stun_func()
		status.text = "Script Status : enemy STUNED!"
		status.color = 0xED9A09FF
	end
	
	if code == wind_key then
		wind_active = (msg == KEY_DOWN)
		wind_func()
		status.text = "Script Status : enemy WINDED!"
		status.color = 0xED9A09FF
	end
	
	if code == invis_key then
		invis_active = (msg == KEY_DOWN)
		invis_func()
		invis_status.text = "WindWalk Status: Enable"
		invis_status.color = 0x2CFA02FF
	end
	
	if code == cleance_key then
		cleance_active = (msg == KEY_DOWN)
		cleane_func()
		status.text = "Script Status: Purge used!"
		status.color = 0xED9A09FF
	end
	
	if code == combo_key then
		combo_active = (msg == KEY_DOWN)
		blink_combo_func()
		stun_func()
		fire_rush()
		local AF = scepter_find()
		if use_aghanim_skills and AF then
			storm_haze()
			earth_clap()
		end
		status.text = "Script Status : Combo-ing!"
		status.color = 0xED9A09FF
    end
end

function Tick_func(tick)
	local me = entityList:GetMyHero()
	if not me then return end
	main.rec[1].visible = true
	
	local user_value = 105
	for i=1,5 do 
		if selected.cyclone_status[i] == false then 
			main.cyclone[i] = drawMgr:CreateRect(xx+457*rate,yy+user_value*rate,15*rate,15*rate,0xFFFFFF30,drawMgr:GetTextureId(CM_space_texture)) 
			main.cyclone[i].visible = true 
			user_value =  user_value+30
		else 
			main.cyclone[i] = drawMgr:CreateRect(xx+457*rate,yy+user_value*rate,15*rate,15*rate,0xFFFFFF30,drawMgr:GetTextureId(CM_buttom_texture)) 
			main.cyclone[i].visible = true
			user_value =  user_value+30
		end
	end
	local user_value = 105
	for i=1,5 do 
		if selected.boulder_status[i] == false then 
			main.boulder[i] = drawMgr:CreateRect(xx+497*rate,yy+user_value*rate,15*rate,15*rate,0xFFFFFF30,drawMgr:GetTextureId(CM_space_texture)) 
			user_value =  user_value+30
		else 
			main.boulder[i] = drawMgr:CreateRect(xx+497*rate,yy+user_value*rate,15*rate,15*rate,0xFFFFFF30,drawMgr:GetTextureId(CM_buttom_texture)) 
			user_value =  user_value+30
		end
	end
	local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,illusion = false,team = (5-me.team)})
	local user_value2 = 100
	if pcall(function() 
		for i=1,5 do
			local v = enemies[i]
			selected.icon[i]=drawMgr:CreateRect(xx+350*rate,yy+user_value2*rate,50*rate,25*rate,0xFFFFFF30,drawMgr:GetTextureId("NyanUI/heroes_horizontal/"..v.name:gsub("npc_dota_hero_",""))) 
			user_value2 = user_value2 + 30
		end
	end) then end
	if pcall(function() 
	if activated then
		main.rec[2].visible = true
		main.rec[3].visible = true
		main.rec[4].visible = true

		for i=1,5 do
			main.cyclone[i].visible = true
			main.boulder[i].visible = true
			selected.icon[i].visible = true
		end
	else
		main.rec[2].visible = false
		main.rec[3].visible = false
		main.rec[4].visible = false

		for i=1,5 do
			main.cyclone[i].visible = false
			main.boulder[i].visible = false
			selected.icon[i].visible = false
		end
	end
	end) then end
	if pcall(function()
		for i=1,5 do
			if selected.cyclone_status[i] == true then
				auto_wind(enemies[i])
			end
			if selected.boulder_status[i] == true then
				auto_stun(enemies[i])
			end
		end
	end) then end
	
	init_func()
	--[[stun_func()
	wind_func()
	invis_func()
	combo_func()
	cleane_func()]]
	
if pcall(function ()	
	local check_primal_split = me:DoesHaveModifier("modifier_brewmaster_primal_split")
	if check_primal_split then
		if Brewmaster_PrimalStorm:DoesHaveModifier("modifier_brewmaster_storm_wind_walk") and not Brewmaster_PrimalStorm:DoesHaveModifier("modifier_item_dustofappearance")then
			invis_status.text = "WindWalk Status: Enable"
			invis_status.color = 0x2CFA02FF
			invis_status.visible = true
		else 
			invis_status.text = "WindWalk Status: Disable"
			invis_status.color = 0xED5153FF
			invis_status.visible = true
		end else
		invis_status.text = "WindWalk Status: Disable"
		invis_status.color = 0xED5153FF
		invis_status.visible = true
	end
end) then 
end

end

function init_func()
	local me = entityList:GetMyHero()	
	thunder_clap = me:GetAbility(1)
	drunken_haze = me:GetAbility(2)
	primal_split = me:GetAbility(4)
		
	Brewmaster_PrimalEarth = initiate_earth()
	Brewmaster_PrimalFire = initiate_fire()
	Brewmaster_PrimalStorm = initiate_storm()
end

function initiate_earth()
	local me = entityList:GetMyHero()
	local earth = entityList:GetEntities({classId = CDOTA_Unit_Brewmaster_PrimalEarth, controllable = true, alive = true, team = me.team})[1]
	return earth
end

function initiate_fire()
	local me = entityList:GetMyHero()
	local fire = entityList:GetEntities({classId = CDOTA_Unit_Brewmaster_PrimalFire, controllable = true, alive = true, team = me.team})[1]
	return fire
end

function initiate_storm()
	local me = entityList:GetMyHero()
	local storm = entityList:GetEntities({classId = CDOTA_Unit_Brewmaster_PrimalStorm, controllable = true, alive = true, team = me.team})[1]
	return storm	
end

function blink_combo_func()
local me = entityList:GetMyHero()	
local Blink = me:FindItem("item_blink")
local Range = 250
local blink_range = 1200
local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = me:GetEnemyTeam(),alive=true,visible=true})

for i,v in ipairs(enemies) do
	if v.visible and v.alive and v.health > 0 then
		if SleepCheck("blink") and GetDistance2D(me,v) <= blink_range+150 and GetDistance2D(me,v) > Range then
		local bpos = v.position							
		if GetDistance2D(me,v) > blink_range then
			bpos = (v.position - me.position) * 1100 / GetDistance2D(me,v) + me.position
		end
		if pcall(function () 
		me:SafeCastItem(Blink.name,bpos)	
		end) then end		
	    Sleep(me:GetTurnTime(v)+client.latency,"blink")
		me:SafeCastAbility(thunder_clap,true)
		me:SafeCastAbility(primal_split,true)
		end
	end
end
end

function fire_rush()
local me = entityList:GetMyHero()
local check_primal_split = me:DoesHaveModifier("modifier_brewmaster_primal_split")
if check_primal_split then
	if pcall(function ()
	local cursor = targetFind:GetClosestToMouse(100,false)
	Brewmaster_PrimalFire:Attack(cursor)
	Brewmaster_PrimalEarth:Attack(cursor)
	Sleep(1000)
	end) then end
end
end

function stun_func()
local me = entityList:GetMyHero()
local check_primal_split = me:DoesHaveModifier("modifier_brewmaster_primal_split")
	if check_primal_split and SleepCheck("hurl_boulder") then 
	if pcall(function ()
		local v = targetFind:GetClosestToMouse(100)
		local hurl_boulder = Brewmaster_PrimalEarth:GetAbility(1)
		Brewmaster_PrimalEarth:SafeCastAbility(hurl_boulder,v,false)
		Sleep(1000, "hurl_boulder")
		end) then 
	end
	end
end

function wind_func()
local me = entityList:GetMyHero()
local check_primal_split = me:DoesHaveModifier("modifier_brewmaster_primal_split")
	if check_primal_split and SleepCheck("cyclone") then 
	if pcall(function ()
		local v = targetFind:GetClosestToMouse(100)
		local cyclone = Brewmaster_PrimalStorm:GetAbility(2)
			Brewmaster_PrimalStorm:SafeCastAbility(cyclone,v,false)
			Sleep(1000, "cyclone")
			end) then
	end
	end
end

function cleane_func()
local me = entityList:GetMyHero()
local check_primal_split = me:DoesHaveModifier("modifier_brewmaster_primal_split")
	if check_primal_split and SleepCheck("dispel_magic") then 
	local target = client.mousePosition
		local dispel_magic = Brewmaster_PrimalStorm:GetAbility(1)
		Brewmaster_PrimalStorm:SafeCastAbility(dispel_magic,target,false)
		Sleep(1000,"dispel_magic")
	end
end

function invis_func()
local me = entityList:GetMyHero()
local cursor = client.mousePosition
local check_primal_split = me:DoesHaveModifier("modifier_brewmaster_primal_split")
if check_primal_split and SleepCheck("windwalk") then
	local windwalk = Brewmaster_PrimalStorm:GetAbility(3)
	Brewmaster_PrimalStorm:SafeCastAbility(windwalk, false)
	Sleep(1000, "windwalk")
end
end

function auto_stun(use_skill_on_him)
	local me = entityList:GetMyHero()
	local check_primal_split = me:DoesHaveModifier("modifier_brewmaster_primal_split")
	if check_primal_split and SleepCheck("hurl_boulder") then 
		if pcall(function ()
			local hurl_boulder = Brewmaster_PrimalEarth:GetAbility(1)
			Brewmaster_PrimalEarth:SafeCastAbility(hurl_boulder,use_skill_on_him,false)
			Sleep(1000, "hurl_boulder")
				end) then 
		end		
end
end

function auto_wind(use_skill_on_him)
	local me = entityList:GetMyHero()
	local check_primal_split = me:DoesHaveModifier("modifier_brewmaster_primal_split")
	if check_primal_split and SleepCheck("cyclone") then 
		if pcall(function ()
			local cyclone = Brewmaster_PrimalStorm:GetAbility(2)
			Brewmaster_PrimalEarth:SafeCastAbility(cyclone,use_skill_on_him,false)
			Sleep(1000, "cyclone")
				end) then 
		end		
end
end

function IsMouseOnButton(x,y,h,w)
	local mx = client.mouseScreenPosition.x
	local my = client.mouseScreenPosition.y
	return mx > x and mx <= x + w and my > y and my <= y + h
end

function earth_clap()
	local me = entityList:GetMyHero()
	local check_primal_split = me:DoesHaveModifier("modifier_brewmaster_primal_split")
	if check_primal_split and SleepCheck("clap") then
	if pcall(function ()
		local v = targetFind:GetClosestToMouse(100)
		if GetDistance2D(me,v) < 300 then
			local clap = Brewmaster_PrimalEarth:GetAbility(4)
			Brewmaster_PrimalEarth:SafeCastAbility(clap,false)
			Sleep(client.latency, "clap")
		else return false end
	end) then return false end
	end
end

function storm_haze()
	local me = entityList:GetMyHero()
	local check_primal_split = me:DoesHaveModifier("modifier_brewmaster_primal_split")
	if check_primal_split and SleepCheck("haze") then
	if pcall(function ()
		local v = targetFind:GetClosestToMouse(100)
		local haze = Brewmaster_PrimalStorm:GetAbility(4)
		Brewmaster_PrimalStorm:SafeCastAbility(haze,v,false)
		Sleep(client.latency,"haze")
	end) then return false end
	end
end

function scepter_find()
	local me =entityList:GetMyHero()
	local scepter_value = me:FindItem("item_ultimate_scepter")
	if scepter_value == nil then
		return false
	else 
		return true
	end
end

script:RegisterEvent(EVENT_TICK,Load_func)
script:RegisterEvent(EVENT_CLOSE,Close_func///)
