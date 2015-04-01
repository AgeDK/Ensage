require("libs.Utils")
require("libs.ScriptConfig")

config = ScriptConfig.new()
config:SetParameter("Hotkey", "T", config.TYPE_HOTKEY)
config:SetParameter("SoulRing", true)
config:SetParameter("Self", 0.5)
config:SetParameter("Team", 0.8)
config:SetParameter("Tower", 0.3)
config:Load()

toggleKey = config.Hotkey
UseSoulRing = config.SoulRing
HealthSelf = config.Self
HealthTeam = config.Team
HealthTower = config.Tower

local play = false
local activated = false
local Font = drawMgr:CreateFont("myFont","Tahoma",14,500)
local statusText = drawMgr:CreateText(50,30,0x6CF58CFF,"Auto Heal: Off",Font) statusText.visible = false

function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	if IsKeyDown(toggleKey) then
		activated = not activated
		if activated then
			statusText.text = "Auto Heal: On"
		else
			statusText.text = "Auto Heal: Off"
		end
	end
end

function Tick( tick )
	if not PlayingGame() or not SleepCheck() then return end 
    local me = entityList:GetMyHero()
    if not me or not activated then return end

	local heal = me:GetAbility(3)

	if me.alive and not me:IsChanneling() and heal and heal:CanBeCasted() then
		if me.health/me.maxHealth < HealthSelf then
			statusText.text = ""..me.name
			SoulRingf()
			me:CastAbility(heal,me)
			Sleep(1000)
			return
		end		
			
		local allyhero = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = me.team,alive=true,visible=true,illusion=false})
		table.sort( allyhero, function (a,b) return a.health < b.health end )
		for i,v in ipairs(allyhero) do
			if v.health/v.maxHealth < HealthTeam then
				statusText.text = ""..v.name:gsub("npc_dota_hero_","")
				SoulRingf()
				me:CastAbility(heal,v)
				Sleep(1000)
				return
			end
		end
			
		local tower = entityList:GetEntities({classId=CDOTA_BaseNPC_Tower,team = me.team,alive=true,visible=true})
		table.sort( tower, function (a,b) return a.health < b.health end )
		for i,v in ipairs(tower) do
			if v.health/v.maxHealth < HealthTower then
				statusText.text = ""..v.name
				SoulRingf()
				me:CastAbility(heal,v)
				Sleep(1000)
				return
			end
		end
	end
end

function SoulRingf()
	local me = entityList:GetMyHero()
	local ring = me:FindItem("item_soul_ring")
	if UseSoulRing and ring and ring:CanBeCasted() then
		me:CastAbility(ring)
		return
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId ~= CDOTA_Unit_Hero_Treant then 
			script:Disable() 
		else
			play = true
			statusText.visible = true
			script:RegisterEvent(EVENT_KEY,Key)
			script:RegisterEvent(EVENT_TICK,Tick)
			script:UnregisterEvent(Load)
		end
	end	
end

function Close()
	statusText.visible = false
	activated = false
	collectgarbage("collect")
	if play then
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end
 
script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_TICK,Load)
