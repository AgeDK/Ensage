require("libs.Utils")

smash = string.byte("1")
roll = string.byte("2")
grip = string.byte("3")

function Key()

    if client.chat or not client.connected or client.loading or client.console then	return end
	
	local me = entityList:GetMyHero() if not me then return end
	
	if me.name ~= "npc_dota_hero_earth_spirit" then
		script:Disable()
	elseif IsKeyDown(smash) then
		local smash = me:GetAbility(1)
		local remnant = me:GetAbility(4)
		local t_ = client.mousePosition
		if remnant:CanBeCasted() and smash:CanBeCasted() and me:CanCast() then
			me:CastAbility(remnant,(t_ - me.position) * 150 / GetDistance2D(t_,me) + me.position,false)
			me:CastAbility(smash,(t_ - me.position) * 150 / GetDistance2D(t_,me) + me.position,true)
		end
	elseif IsKeyDown(roll) then
		local roll = me:GetAbility(2)
		local remnant = me:GetAbility(4)
		local t_ = client.mousePosition
		if remnant:CanBeCasted() and roll:CanBeCasted() and me:CanCast() then
			me:CastAbility(roll,t_,false)
			me:CastAbility(remnant,(t_ - me.position) * 150 / GetDistance2D(t_,me) + me.position,true)
		end
	elseif IsKeyDown(grip) then
		local grip = me:GetAbility(3)
		local remnant = me:GetAbility(4)
		local t_ = client.mousePosition
		if remnant:CanBeCasted() and grip:CanBeCasted() and me:CanCast() then
			me:CastAbility(remnant,t_,false)
			me:CastAbility(grip,t_,true)
		end
	end	
end

script:RegisterEvent(EVENT_KEY,Key)
