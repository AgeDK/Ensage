require("libs.Utils")
local BsleepTick = nil

-- Setting
-- Enable Abuse Bottle?
local funcbottle = true
-- Enable Auto Phase Boots?
local funcphaseboots = true
-- Enable Auto Stick?
local funcstick = true
local stickuse = 0.2 -- 20% HP

function BTick( tick )
	if not client.connected or client.loading or client.console then
			return
	end
	
	if BsleepTick and BsleepTick > tick then
		return
	end
	
	local me = entityList:GetMyHero()
	if not me then
		return
	end
	
	local bottle = me:FindItem("item_bottle")
	local phaseboots = me:FindItem("item_phase_boots")
	local lowstick = me:FindItem("item_magic_stick")
	local gradestick = me:FindItem("item_magic_wand")
	
	local DruidBear = entityList:FindEntities({classId=CDOTA_Unit_SpiritBear,controllable=true,alive=true,visible=true})
	local Meepos = entityList:FindEntities({classId=TYPE_HERO,controllable=true,alive=true,visible=true,illusion=true})
	
	
	if  funcbottle and bottle and not me.invisible and not me:IsChanneling() and me:DoesHaveModifier("modifier_fountain_aura_buff") and not me:DoesHaveModifier("modifier_bottle_regeneration") then
		me:SafeCastItem("item_bottle")
	end
	
	if funcphaseboots and phaseboots and me.alive == true and phaseboots.state == -1 and me.unitState ~= 33554432 and me.unitState ~= 256 and me.unitState ~= 33554688 then
		me:SafeCastItem("item_phase_boots")
	end
	
	if funcstick and lowstick and me.alive == true and lowstick.charges > 0 and me.health/me.maxHealth < stickuse then
		me:SafeCastItem("item_magic_stick")
	end
	
	if funcstick and gradestick and me.alive == true and gradestick.charges > 0 and me.health/me.maxHealth < stickuse then
		me:SafeCastItem("item_magic_wand")
	end
	
	if #DruidBear > 0 then
		for _,v in ipairs(DruidBear) do
			if v.controllable and v.unitState ~= -1031241196 then
				local duingoboots = v:FindItem("item_phase_boots")
				if duingoboots and duingoboots.state == -1 then
					v:SafeCastItem("item_phase_boots")
				end
			end
		end
	end
	
	if #Meepos > 0 then
		for _,v in ipairs(Meepos) do
			if v.controllable and v.unitState ~= -1031241196 then
				local meepoboots = v:FindItem("item_phase_boots")
				if meepoboots and meepoboots.state == -1 then
					v:SafeCastItem("item_phase_boots")
				end
			end
		end
	end
	
	BsleepTick = tick + 500
	return
end
script:RegisterEvent(EVENT_TICK,BTick)
