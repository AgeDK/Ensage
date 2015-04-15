require("libs.ScriptConfig")
require("libs.TargetFind")
require("libs.Utils")


config = ScriptConfig.new()
config:SetParameter("HotKey", "32", config.TYPE_HOTKEY)
config:SetParameter("HomeKey", "D", config.TYPE_HOTKEY)
config:Load()

toggleKey = config.HotKey
homeKey = config.HomeKey


local play = false local myhero = nil local victim = nil

function Tick(tick)
	if not PlayingGame() then return end
	local me = entityList:GetMyHero()
	local ID = me.classId if ID ~= myhero then return end

	local Q = me:GetAbility(1)
	local E = me:GetAbility(3)
	local R = me:GetAbility(4)

	local victim = targetFind:GetClosestToMouse(me,2000)

	if me.team == LuaEntity.TEAM_RADIANT then
		foun = Vector(-7272,-6757,270)
	else
		foun = Vector(7200,6624,256)
	end

	if IsKeyDown(homeKey) and not client.chat then
		local travel = me:FindItem("item_tpscroll") or me:FindItem("item_travel_boots")
		if E and E:CanBeCasted() and SleepCheck("home") then
			me:CastAbility(E,me)
			Sleep(250+client.latency, "home")
		end
		if travel and travel:CanBeCasted() then
			me:CastAbility(travel,foun)
			Sleep(250+client.latency, "home")
		end
	end
	
	if victim and SleepCheck("combo") then

		if E.name == "kunkka_x_marks_the_spot" and Q and Q:CanBeCasted() and E.level > 0 and E.abilityPhase then
			me:CastAbility(Q,victim.position)
			Sleep(250+client.latency, "combo")
		end
		if E.name == "kunkka_return" and me:CanCast() and math.floor(Q.cd*10) == 110 + math.floor((client.latency/1100)) then
			me:CastAbility(E)
			Sleep(250+client.latency, "combo")
		end

		if IsKeyDown(toggleKey) and not client.chat then

			if E.name == "kunkka_x_marks_the_spot" and E:CanBeCasted() and me:CanCast() then
				me:CastAbility(E,victim)
				lastpos = victim.position
				Sleep(250+client.latency, "combo")
			end
			if R and R:CanBeCasted() and me:CanCast() and E.level > 0 and E.abilityPhase then
				me:CastAbility(R,lastpos)
				Sleep(250+client.latency, "combo")
			end
			if Q and Q:CanBeCasted() and me:CanCast() and R.level > 0 and R.abilityPhase then
				me:CastAbility(Q,lastpos)
				Sleep(250+client.latency, "combo")
			end
			if E.name == "kunkka_return" and me:CanCast() and math.floor(Q.cd*10) == 110 + math.floor((client.latency/1100)) then
				me:CastAbility(E)
				Sleep(250+client.latency, "combo")
			end
		end
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId ~= CDOTA_Unit_Hero_Kunkka then 
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
	start = false
	collectgarbage("collect")
	if play then
		script:UnregisterEvent(Tick)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_TICK,Load)
