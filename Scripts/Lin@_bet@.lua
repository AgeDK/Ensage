require("libs.ScriptConfig")
require("libs.TargetFind")
require("libs.Utils")
require("libs.Skillshot")
require("libs.Animations")

config = ScriptConfig.new()
config:SetParameter("HotKey", "32", config.TYPE_HOTKEY)
config:Load()

toggleKey = config.HotKey

local play = false local myhero = nil local victim = nil local combo = 0 local move = 0 local follow = false

function Tick(tick)
	if not PlayingGame() then return end
	local me = entityList:GetMyHero()
	local ID = me.classId if ID ~= myhero then return end

	if IsKeyDown(toggleKey) and not client.chat then
		follow = true
		local victim = targetFind:GetClosestToMouse(me,2000)
		if victim and tick > move then
			if follow then
				me:Follow(victim)
				move = tick + 350
			end
			if GetDistance2D(victim,me) <= 500 then
				me:Attack(victim)
				follow = false
				move = tick + 350
			end
			local Q = me:GetAbility(1)
			local W = me:GetAbility(2)
			local euls = me:FindItem("item_cyclone")
			if tick > combo and SleepCheck("combo") then
				if euls and euls:CanBeCasted() and GetDistance2D(victim,me) <= euls.castRange then
					me:CastAbility(euls,victim)
					combo = tick + 1700
					Sleep(1000+me:GetTurnTime(victim)*1000,"combo")
				end
				if W and W:CanBeCasted() and euls and euls.cd > 1 then
					local distance = GetDistance2D(victim, me)
					local delay = ((625-Animations.getDuration(W)*1000)+client.latency+me:GetTurnTime(victim)*1000)
					local speed = 1100
					local xyz = SkillShot.SkillShotXYZ(me,victim,delay,speed)
					if xyz and distance <= W.castRange then 
						me:CastAbility(W,xyz)
						Sleep(1000+me:GetTurnTime(victim)*1000,"combo")
					end
				end
				if Q and Q:CanBeCasted() and W and W.cd > 1 then
					local distance = GetDistance2D(victim, me)
					local delay = ((800-Animations.getDuration(Q)*1000)+client.latency+me:GetTurnTime(victim)*1000)
					local speed = 2100
					local xyz = SkillShot.SkillShotXYZ(me,victim,delay,speed)
					if xyz and distance <= Q.castRange then 
						me:CastAbility(Q,xyz)
						Sleep(1000+me:GetTurnTime(victim)*1000,"combo")
					end
				end
			end
		end
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId ~= CDOTA_Unit_Hero_Lina then 
			script:Disable() 
		else
			play = true
			victim = nil		
			myhero = me.classId
			script:RegisterEvent(EVENT_TICK,Tick)
			script:UnregisterEvent(Load)
		end
	end
end

function Close()
	myhero = nil
	victim = nil
	follow = false
	collectgarbage("collect")
	if play then
		script:UnregisterEvent(Tick)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_TICK,Load)
