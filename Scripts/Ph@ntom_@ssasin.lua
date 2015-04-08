require("libs.ScriptConfig")
require("libs.TargetFind")
require("libs.Utils")

config = ScriptConfig.new()
config:SetParameter("combo", "32", config.TYPE_HOTKEY)
config:SetParameter("lasthit", "D", config.TYPE_HOTKEY)
config:Load()

hotkey1 = config.combo
hotkey2 = config.lasthit

local play = false local myhero = nil local victim = nil local start = false local resettime = nil local dmg = {60,100,140,180}
local monitor = client.screenSize.x/1600
local F14 = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local victimText = drawMgr:CreateText(-50*monitor,1*monitor,0xFFFF00FF,"Doing rape this kid!",F14) victimText.visible = false

function Tick(tick)
	if not PlayingGame() then return end
	local me = entityList:GetMyHero()
	local ID = me.classId if ID ~= myhero then return end

	if IsKeyDown(hotkey2) and not client.chat then
		local Q = me:GetAbility(1)
		local creeps = entityList:FindEntities({classId=CDOTA_BaseNPC_Creep_Lane,team=TEAM_ENEMY,alive=true,visible=true,team = me:GetEnemyTeam()})
		for i,v in ipairs(creeps) do
			if SleepCheck("lasthit") and Q and Q:CanBeCasted() and (v.health > 0 and v.health < dmg[Q.level]) and GetDistance2D(v,me) <= Q.castRange then
				me:CastAbility(Q,v)
				Sleep(1000+me:GetTurnTime(v)*1000,"lasthit")
			end
		end
	end

	if victim and victim.visible then 
		if not victimText.visible then
			victimText.entity = victim
			victimText.entityPosition = Vector(0,0,victim.healthbarOffset)
			victimText.visible = true
		end
	else
		victimText.visible = false
	end
	
	local attackRange = me.attackRange

	if IsKeyDown(hotkey1) and not client.chat then
		start = true
		local lowestHP = targetFind:GetLowestEHP(3000, phys)
		if lowestHP and (not victim or victim.creep or GetDistance2D(me,victim) > 600 or not victim.alive or lowestHP.health < victim.health) and SleepCheck("victim") then			
			victim = lowestHP
			Sleep(250,"victim")
		end
		if victim and GetDistance2D(victim,me) > attackRange+50 and victim.visible then
			local closest = targetFind:GetClosestToMouse(me,3000)
			if closest and (not victim or closest.handle ~= victim.handle) then 
				victim = closest
			end
		end

		if victim and SleepCheck("combo") then
			local Q = me:GetAbility(1) local W = me:GetAbility(2)
			local medallion = me:FindItem("item_medallion_of_courage")
			local abyssal = me:FindItem("item_abyssal_blade")
			local butterfly = me:FindItem("item_butterfly")
			local mom = me:FindItem("item_mask_of_madness")
			local satanic = me:FindItem("item_satanic")
			local disabled = victim:DoesHaveModifier("modifier_sheepstick_debuff") or victim:DoesHaveModifier("modifier_lion_voodoo_restoration") or victim:DoesHaveModifier("modifier_shadow_shaman_voodoo_restoration") or victim:IsStunned()
			if SleepCheck("follow") and GetDistance2D(victim,me) <= 3000 then
				me:Attack(victim)
				Sleep(1000+me:GetTurnTime(victim)*1000,"follow")
			end
			if Q and Q:CanBeCasted() and GetDistance2D(victim,me) <= Q.castRange then
				me:CastAbility(Q,victim)
				Sleep(1000+me:GetTurnTime(victim)*1000,"combo")
			end
			if W and W:CanBeCasted() and GetDistance2D(victim,me) <= W.castRange then
				me:CastAbility(W,victim)
				Sleep(1000+me:GetTurnTime(victim)*1000,"combo")
			end
			if medallion and medallion:CanBeCasted() and GetDistance2D(victim,me) <= me.attackRange then
				me:CastAbility(medallion,victim)
				Sleep(1000+me:GetTurnTime(victim)*1000,"combo")
			end
			if abyssal and abyssal:CanBeCasted() and GetDistance2D(victim,me) <= abyssal.castRange and not disabled then
				me:CastAbility(abyssal,victim)
				Sleep(1000+me:GetTurnTime(victim)*1000,"combo")
			end
			if butterfly and butterfly:CanBeCasted() and GetDistance2D(victim,me) <= 3000 then
				me:CastAbility(butterfly)
				Sleep(1000+me:GetTurnTime(victim)*1000,"combo")
			end
			if mom and mom:CanBeCasted() and GetDistance2D(victim,me) <= me.attackRange then
				me:CastAbility(mom)
				Sleep(1000+me:GetTurnTime(victim)*1000,"combo")
			end
			if satanic and satanic:CanBeCasted() and me.health/me.maxHealth <= 0.5 then
				me:CastAbility(satanic)
				Sleep(1000+me:GetTurnTime(victim)*1000,"combo")
			end
		end
	elseif victim then
		if not resettime then
			resettime = client.gameTime
		elseif (client.gameTime - resettime) >= 6 then
			victim = nil		
		end
		start = false
	end 
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId ~= CDOTA_Unit_Hero_PhantomAssassin then 
			script:Disable() 
		else
			play = true
			victim = nil
			start = false			
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
	resettime = nil
	collectgarbage("collect")
	if play then
		script:UnregisterEvent(Tick)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_TICK,Load)
