local heroTable = {}
local illusionTable = {}
local me = nil
local loaded = false 
local sleepTick = 0

function OnLoadTick()
	if not client.connected or client.loading or client.console then
		return
	end
	
	if loaded == false then
		print("NyanShowIllusions: Loaded! ^__^")
		
		me = entityList:GetMyPlayer()
		if me == nil then return end
				
		loaded = true		
		script:RegisterEvent(EVENT_TICK, MainTick)	
	end
end

function MainTick(tick)
	if not client.connected or client.loading or client.console or tick < sleepTick then
		return
	end
	
	me = entityList:GetMyPlayer()
	
	local illusions = entityList:FindEntities({type=LuaEntity.TYPE_HERO,illusion=true,team = (5-me.team)})	--
	local clear = false
	for _, heroEntity in ipairs(illusions) do
		if not (heroEntity.type == 9 and heroEntity.meepoIllusion == false) then
			if heroEntity.visible and heroEntity.alive and heroEntity:GetProperty("CDOTA_BaseNPC","m_nUnitState") ~= -1031241196  then	
				if not illusionTable[heroEntity.handle] then
					illusionTable[heroEntity.handle] = {}
					illusionTable[heroEntity.handle].effect1 = Effect(heroEntity,"shadow_amulet_active_ground_proj")			
					illusionTable[heroEntity.handle].effect2 = Effect(heroEntity,"smoke_of_deceit_buff")
					illusionTable[heroEntity.handle].effect3 = Effect(heroEntity,"smoke_of_deceit_buff")			
					illusionTable[heroEntity.handle].effect4 = Effect(heroEntity,"smoke_of_deceit_buff")
				end
			else
				if illusionTable[heroEntity.handle] then
					illusionTable[heroEntity.handle] = nil
					clear = true
				end
			end
		end
	end
	
	if clear then
		collectgarbage("collect")
	end
 
	sleepTick = tick + 250
end	

function GameClose()
	heroTable = {}
	llusionTable = {}
	me = nil
	loaded = false 	
	script:UnregisterEvent(MainTick)	
	collectgarbage("collect")
end
 
script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK, OnLoadTick)
