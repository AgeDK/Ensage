require("libs.ScriptConfig")
require("libs.Utils")

config = ScriptConfig.new()
config:SetParameter("AutoDagger", "D", config.TYPE_HOTKEY)
config:Load()

local toggleKey = config.AutoDagger

local activ = true
local reg = false

local damage = {60,100,140,180}

local monitor = client.screenSize.x/1600
local F14 = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText = drawMgr:CreateText(10*monitor,560*monitor,-1,"(" .. string.char(toggleKey) .. ") Dagger auto last hit: On",F14) statusText.visible = false

local hotkeyText
if string.byte("A") <= toggleKey and toggleKey <= string.byte("D") then
	hotkeyText = string.char(toggleKey)
else
	hotkeyText = ""..toggleKey
end

function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	if IsKeyDown(toggleKey) then
		activ = not activ
		if activ then
			statusText.text = "(" .. hotkeyText .. ") Dagger auto last hit: On"
		else
			statusText.text = "(" .. hotkeyText .. ") Dagger auto last hit: Off"
		end
	end
end

function Tick()
    if not SleepCheck() then return end
	
	local me = entityList:GetMyHero()
	if not (me and activ) then return end

	local dagger = me:GetAbility(1)
		if not dagger or dagger.level == 0 or dagger.state ~= -1 then
	    return
    end		
		
	local creeps = entityList:FindEntities({classId=CDOTA_BaseNPC_Creep_Lane,team=TEAM_ENEMY,alive=true,visible=true,team = me:GetEnemyTeam()})
		
	    for i,v in ipairs(creeps) do	
		
		if GetDistance2D(v,me) < 1200 and dagger:CanBeCasted() and me:CanCast() and (v.health > 0 and v.health < damage[dagger.level]) then
		    CastSpell(dagger,v)
	        Sleep(250)
            return	
		end
	end	
end

function CastSpell(spell,v)
	if spell.state == LuaEntityAbility.STATE_READY then
		entityList:GetMyPlayer():UseAbility(spell,v)
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId ~= CDOTA_Unit_Hero_PhantomAssassin then 
			script:Disable() 
		else
			statusText.visible = true
			reg = true
			script:RegisterEvent(EVENT_TICK,Tick)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(Load)
		end
	end
end

function GameClose()
	collectgarbage("collect")
	if reg then
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		reg = false
		statusText.visible = false
	end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
