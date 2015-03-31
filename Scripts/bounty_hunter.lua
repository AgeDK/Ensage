require("libs.Utils")
require("libs.ScriptConfig")

config = ScriptConfig.new()
config:SetParameter("hpTrack", 0.4)
config:SetParameter("killSteal", true)
config:Load()

timeTrack = config.hpTrack
lasthit = config.killSteal

local play = false local dmg = {100,200,250,325}

function Tick(tick)
    if not PlayingGame() then return end
    local me = entityList:GetMyHero() local Toss = me:GetAbility(1) local Track = me:GetAbility(4)
    local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO, visible = true, alive = true, team = me:GetEnemyTeam(), illusion=false})
    for i,v in ipairs(enemies) do
    	local distance = GetDistance2D(me,v)
		if v.health > 0 and distance <= 1300 then
			local buff = v:DoesHaveModifier("modifier_bounty_hunter_track") or me:DoesHaveModifier("modifier_bounty_hunter_wind_walk")
			local invis = v:FindItem("item_invis_sword") or v:FindItem("item_shadow_amulet") local invisBottle = v:FindItem("item_bottle")
			
			if SleepCheck("Toss") and lasthit and Toss:CanBeCasted() and Toss.level > 0 and v.health+v.healthRegen < dmg[Toss.level]*(1-v.magicDmgResist) and distance < 650 then
				me:CastAbility(Toss,v) Sleep(700,"Toss")
			end

			if SleepCheck("Track") and Track and Track:CanBeCasted() and not buff and distance <= 1200 then
				if invisBottle and invisBottle.storedRune == 3 then me:CastAbility(Track,v) Sleep(700,"Track") Sleep(700,"Track")
				elseif invis and v:CanCast() then me:CastAbility(Track,v) Sleep(700,"Track")
				elseif v.name == "npc_dota_hero_riki" then me:CastAbility(Track,v) Sleep(700,"Track")
				elseif v.name == "npc_dota_hero_clinkz" then me:CastAbility(Track,v) Sleep(700,"Track")
				elseif v.name == "npc_dota_hero_nyx_assassin" then me:CastAbility(Track,v) Sleep(700,"Track")
				elseif v.name == "npc_dota_hero_templar_assassin" then me:CastAbility(Track,v) Sleep(700,"Track")
				elseif v.name == "npc_dota_hero_broodmother" then me:CastAbility(Track,v) Sleep(700,"Track")
				elseif v.name == "npc_dota_hero_weaver" then me:CastAbility(Track,v) Sleep(700,"Track")
				elseif v.name == "npc_dota_hero_treant" then me:CastAbility(Track,v) Sleep(700,"Track")
				elseif v.name == "npc_dota_hero_sand_king" then me:CastAbility(Track,v) Sleep(700,"Track")
				elseif v.name == "npc_dota_hero_invoker" then me:CastAbility(Track,v) Sleep(700,"Track")
				elseif v.health/v.maxHealth < timeTrack then me:CastAbility(Track,v) Sleep(700,"Track") end
			end
		end
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId ~= CDOTA_Unit_Hero_BountyHunter then 
			script:Disable() 
		else
			play = true
			script:RegisterEvent(EVENT_TICK,Tick)
			script:UnregisterEvent(Load)
		end
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
