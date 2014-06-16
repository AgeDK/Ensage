local sleepTick = 0
local target = nil
local scriptSetting = 1 -- if == 1 then stop, after aggro & unaggro, 
			-- if == 2 then move to your mousePosition after this.

function MainBody( tick )
	if not client.connected or client.loading or client.console or client.chat or (sleepTick and tick < sleepTick) then return end
	target = entityList:GetMyPlayer()
	
	if IsKeyDown(75) then -- pressing "k" button to aggro
		sleepTick = tick + 100
		local enemies = entityList:FindEntities({type=LuaEntity.TYPE_HERO,illusion=false,team=(5-entityList:GetMyPlayer().team)})	
		for _, enemyEntity in ipairs(enemies) do
			if enemyEntity.alive then	
				NextAction(enemyEntity,target)
				return
			end
		end
	end
	
	if IsKeyDown(76) then -- pressing "l" button to un-aggro
		sleepTick = tick + 100
		local allycreeps = entityList:FindEntities({type=LuaEntity.TYPE_NPC,creep=true,team=(entityList:GetMyPlayer().team)})
		for _, allyCreepEntity in ipairs(allycreeps) do
			if allyCreepEntity.alive and allyCreepEntity.unitState ~= 8389120 then	
				NextAction(allyCreepEntity,target)
				return
			end
		end
	end	
end

function NextAction(_target,_me)
	_me:Attack(_target)
	if scriptSetting == 1 then
		_me:HoldPosition()	
	elseif scriptSetting == 2 then
		_me:Move(client.mousePosition)	
	end
end

function GameClose()
	sleepTick = 0
	target = nil
end
 
script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,MainBody)
