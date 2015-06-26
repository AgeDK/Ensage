require("libs.Utils")
require("libs.HotkeyConfig2")
require("libs.TargetFind")

local play = false local myhero = nil
ScriptConfig = ConfigGUI:New(script.name)
ScriptConfig:SetName("[Bounty Hunter]")
ScriptConfig:SetExtention(-.3)
script:RegisterEvent(EVENT_KEY, ScriptConfig.Key, ScriptConfig)
script:RegisterEvent(EVENT_TICK, ScriptConfig.Refresh, ScriptConfig)
ScriptConfig:SetVisible(false)
ScriptConfig:AddParam("active","WomboCombo",SGC_TYPE_ONKEYDOWN,false,false,32)
ScriptConfig:AddParam("aegis","Steal Aegis",SGC_TYPE_ONKEYDOWN,false,false,90)
ScriptConfig:AddParam("runes","Take Runes",SGC_TYPE_ONKEYDOWN,false,false,88)
ScriptConfig:AddParam("checksw","check Shadow Walk?",SGC_TYPE_TOGGLE,false,true,nil) -- soon

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId ~= CDOTA_Unit_Hero_BountyHunter then
			ScriptConfig:SetVisible(false)
			script:Disable() 
		else
			play = true
			myhero = me.classId
			script:RegisterEvent(EVENT_TICK,Tick)
			ScriptConfig:SetVisible(true)
			script:UnregisterEvent(Load)
		end
	end	
end

function Tick(tick)
    if not PlayingGame() then return end
    local me = entityList:GetMyHero()
    local ID = me.classId if ID ~= myhero then return end
	
	local dagon = me:FindDagon()
	local ethereal = me:FindItem("item_ethereal_blade")
	local orchid = me:FindItem("item_orchid")
	local sheep = me:FindItem("item_sheepstick")
	
	local spell = me:GetAbility(1)
	local spell4 = me:GetAbility(4)
    local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,visible=true,alive=true,team=me:GetEnemyTeam(),illusion=false})
	target = targetFind:GetClosestToMouse(100)
    for i,v in ipairs(enemies) do
		local distance = GetDistance2D(me,v)
		local buff = v:DoesHaveModifier("modifier_bounty_hunter_track") or me:DoesHaveModifier("modifier_bounty_hunter_wind_walk")
		
		if v:DoesHaveModifier("modifier_bounty_hunter_track") and v.health < v:DamageTaken(spell:GetSpecialData("bonus_damage",spell.level),DAMAGE_MAGC,me) and v~=target then
			tartrack = v
		end
		
		if me.alive and spell and spell:CanBeCasted() and v.health < v:DamageTaken(spell:GetSpecialData("bonus_damage",spell.level),DAMAGE_MAGC,me) and distance <= spell.castRange and  SleepCheck("autospell") then
			me:SafeCastAbility(spell,v)
			Sleep(400, "autospell")	
		end

		if me.alive and spell4 and spell4:CanBeCasted() and not buff and distance <= spell4.castRange and SleepCheck("autospell4") and v.health/v.maxHealth < 0.4 then
			me:SafeCastAbility(spell4,v)
			Sleep(400, "autospell4")
		end
		
		if me.alive and spell4 and spell4:CanBeCasted() and not buff and distance <= spell4.castRange and SleepCheck("autospell4") and InvisibleHeroes(v) then
			me:SafeCastAbility(spell4,v)
			Sleep(400, "autospell4")
		end
	end
	
    if ScriptConfig.active then			
		if target and target.alive and target.visible and GetDistance2D(me,target) <= 1200 then
			local heroes = entityList:GetEntities(function (target) return target.type==LuaEntity.TYPE_HERO and target.alive and target.visible and target.team~=me.team and me:GetDistance2D(target) <= 1200 end)
			local disabled = target:DoesHaveModifier("modifier_lion_voodoo_restoration") or target:DoesHaveModifier("modifier_shadow_shaman_voodoo_restoration") or target:IsStunned()
			if #heroes == 3 then
				me:SafeCastItem("item_black_king_bar")
			elseif #heroes == 4 then
				me:SafeCastItem("item_black_king_bar")
			elseif #heroes == 5 then
				me:SafeCastItem("item_black_king_bar")
			end
			
			if spell and spell:CanBeCasted() and tartrack and tartrack.alive and tartrack.visible and target.name ~= tartrack.name and tartrack:DoesHaveModifier("modifier_bounty_hunter_track") and not me:DoesHaveModifier("modifier_bounty_hunter_wind_walk")and target~=tartrack and GetDistance2D(target,tartrack) <= 1200 and GetDistance2D(me,target) <= spell.castRange and SleepCheck("spell") then
					if tartrack.health < tartrack:DamageTaken(spell:GetSpecialData("bonus_damage",spell.level),DAMAGE_MAGC,me) then
						me:SafeCastAbility(spell,target)
						Sleep(400, "spell")
					end
			end
			if SleepCheck("attack") and not target:DoesHaveModifier("modifier_item_ethereal_blade_slow") then
				me:Attack(target)
				Sleep(250,"attack")
			end
        end
    elseif ScriptConfig.aegis then
		local roshancheg = entityList:FindEntities({classId=CDOTA_Unit_Roshan})[1]
		local obnarujengem = false
		if roshancheg then
			if me.position ~= roshancheg.position and GetDistance2D(roshancheg,me) < 2000 then
				if SleepCheck("moving") and not obnarujengem then
					me:Move(roshancheg.position)
					Sleep(1000,"moving")
				end
			end
		end
		local items = entityList:GetEntities({type=LuaEntity.TYPE_ITEM_PHYSICAL})
		for i,v in ipairs(items) do
			local IH = v.itemHolds
			if IH.name == "item_aegis" and GetDistance2D(v,me) <= 400 then
				entityList:GetMyPlayer():Select(me)
				entityList:GetMyPlayer():TakeItem(v)
			end
		end
	elseif ScriptConfig.runes then
		local runes = entityList:GetEntities(function (ent) return ent.classId==CDOTA_Item_Rune and GetDistance2D(ent,me) < 100 end)[1]		
		if me.position ~= Vector(-2272,1792,0) and GetDistance2D(Vector(-2272,1792,0),me) < 800 then
			if SleepCheck("moving") then
				me:Move(Vector(-2272,1792,0))
				Sleep(1000,"moving")
			end
			if runes then entityList:GetMyPlayer():Select(me) entityList:GetMyPlayer():TakeRune(runes) end
		elseif me.position ~= Vector(3000,-2450,0) and GetDistance2D(Vector(3000,-2450,0),me) < 800 then
			if SleepCheck("moving") then
				me:Move(Vector(3000,-2450,0))
				Sleep(1000,"moving")
			end
			if runes then entityList:GetMyPlayer():Select(me) entityList:GetMyPlayer():TakeRune(runes) end
		end
	end
end

function InvisibleHeroes(v)
	local invisBottle = v:FindItem("item_bottle")
	local invisItem1 = v:FindItem("item_invis_sword")
	local invisItem2 = v:FindItem("item_glimmer_cape")
	local invisItem3 = v:FindItem("item_silver_edge")
	local invisItem4 = v:FindItem("item_shadow_amulet")
	if invisItem1 and invisItem1.state == LuaEntityAbility.STATE_READY then
		return true
	end
	if invisItem2 and invisItem2.state == LuaEntityAbility.STATE_READY then
		return true
	end
	if invisItem3 and invisItem3.state == LuaEntityAbility.STATE_READY then
		return true
	end
	if invisItem4 and invisItem4.state == LuaEntityAbility.STATE_READY then
		return true
	end
	if invisBottle and invisBottle.storedRune == 3 then
		return true
	end
	if v.name == "npc_dota_hero_riki" then
		if v:GetAbility(4).level ~=0 then
			return true
		end
	elseif v.name == "npc_dota_hero_clinkz" then
		if v:GetAbility(3).state == LuaEntityAbility.STATE_READY then
			return true
		end
	elseif v.name == "npc_dota_hero_nyx_assassin" then
		if v:GetAbility(3).state == LuaEntityAbility.STATE_READY then
			return true
		end
	elseif v.name == "npc_dota_hero_templar_assassin" then
		if v:GetAbility(2).state == LuaEntityAbility.STATE_READY then
			return true
		end
	elseif v.name == "npc_dota_hero_broodmother" then
		if v:GetAbility(2).state == LuaEntityAbility.STATE_READY then
			return true
		end
	elseif v.name == "npc_dota_hero_weaver" then
		if v:GetAbility(2).state == LuaEntityAbility.STATE_READY then
			return true
		end
	elseif v.name == "npc_dota_hero_treant" then
		if v:GetAbility(1).state == LuaEntityAbility.STATE_READY then
			return true
		end
	elseif v.name == "npc_dota_hero_sand_king" then
		if v:GetAbility(2).state == LuaEntityAbility.STATE_READY then
			return true
		end
	elseif v.name == "npc_dota_hero_invoker" then
		if v:GetAbility(4).name == "invoker_ghost_walk" or v:GetAbility(5).name == "invoker_ghost_walk" then
			if v:GetAbility(4).name == "invoker_ghost_walk" and v:GetAbility(4).state == LuaEntityAbility.STATE_READY then
				return true
			elseif v:GetAbility(5).name == "invoker_ghost_walk" and v:GetAbility(5).state == LuaEntityAbility.STATE_READY then
				return true
			end
		end
	end
	return false
end

function Close()
	myhero = nil
	collectgarbage("collect")
	if play then
		script:UnregisterEvent(Tick)
		script:RegisterEvent(EVENT_TICK,Load)
		ScriptConfig:SetVisible(true)
		play = false
	end
end

script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_TICK,Load)
