--<<Automatic: Midas, Phase boots, bottle in fountain, Magic stick and Bloodstone if low hp>>
require("libs.Utils")

local play = false

function Tick(tick)
    if not PlayingGame() then return end
    local me = entityList:GetMyHero() local bloodstone = me:FindItem("item_bloodstone") local bottle = me:FindItem("item_bottle")
	local phaseboots = me:FindItem("item_phase_boots") local midas = me:FindItem("item_hand_of_midas")
	local stick = me:FindItem("item_magic_stick") or me:FindItem("item_magic_wand")
	local creeps = entityList:FindEntities({classId=CDOTA_BaseNPC_Creep_Neutral,controllable=false,alive=true,illusion=false})
	if SleepCheck("bloodstone") and me.alive and not me:IsInvisible() and not me:IsChanneling() then
		if enableBloodstone and bloodstone and bloodstone:CanBeCasted() and me.health/me.maxHealth < 0.04 then
			me:CastAbility(bloodstone,me.position) Sleep(700,"bloodstone")
		elseif SleepCheck("bottle") and bottle and bottle:CanBeCasted() and me:DoesHaveModifier("modifier_fountain_aura_buff") and not me:DoesHaveModifier("modifier_bottle_regeneration") and (me.health < me.maxHealth or me.mana < me.maxMana) then
			me:CastAbility(bottle) Sleep(700,"bottle")
		elseif SleepCheck("phaseboots") and phaseboots and phaseboots:CanBeCasted() then
			me:CastAbility(phaseboots) Sleep(700,"phaseboots")
		elseif SleepCheck("stick") and stick and stick:CanBeCasted() and stick.charges > 0 and me.health/me.maxHealth < 0.3 then
			me:CastAbility(stick) Sleep(700,"stick") end
		if SleepCheck("midas") and midas and midas:CanBeCasted() then
			for _,v in ipairs(creeps) do
				if GetDistance2D(me,v) < 700 and v.level >= 5 and v.team ~= me.team and v.visible and v.spawned and not v.ancient and v.health > 0 then
					me:CastAbility(midas,v) Sleep(700,"midas")
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

script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_TICK,Load)
