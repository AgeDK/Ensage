require("libs.ScriptConfig")
require("libs.Utils")

local config = ScriptConfig.new()
config:SetParameter("aggro", "K", config.TYPE_HOTKEY)
config:SetParameter("unaggro", "L", config.TYPE_HOTKEY)
config:Load()

local play = false local sleep = 0

function Tick(tick)
	if not PlayingGame() then return end
	local me = entityList:GetMyHero()
	
	if tick > sleep and IsKeyDown(config.aggro) and not client.chat then
		for i, v in ipairs(entityList:GetEntities({type=LuaEntity.TYPE_HERO,team=me:GetEnemyTeam(),illusion=false})) do
			if v.alive then
				if GetDistance2D(v,me) <= 1200 then	
					entityList:GetMyPlayer():Attack(v)
					sleep = tick + 100
				end
			end
		end
	end
	if tick > sleep and IsKeyDown(config.unaggro) and not client.chat then
		for i,v in ipairs(entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Lane})) do
			if v.team == me.team and v.visible and v.alive then
				if GetDistance2D(v,me) < me.attackRange + 200 then
					entityList:GetMyPlayer():Attack(v)
					sleep = tick + 100
				end
			end
		end
	end	
end

function Load()
	if PlayingGame() then
        play = true
		script:RegisterEvent(EVENT_TICK,Tick)
        script:UnregisterEvent(Load)
	end
end

function Close()
    collectgarbage("collect")
	if play then
		script:UnregisterEvent(Tick)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,Close)
