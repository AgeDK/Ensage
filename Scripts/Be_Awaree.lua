require("libs.Utils")
require("libs.SideMessage")

local play = false local isMoonlightCasted = false

function Tick(tick)
    if not PlayingGame() or not SleepCheck() or not play then return end
	local hero = entityList:GetEntities({type=LuaEntity.TYPE_HERO})
	for i,v in ipairs(hero) do
		if v.team ~= team and not v:IsIllusion() then
			if v.classId == CDOTA_Unit_Hero_Mirana then
				MoonlightShadow(hero,team)
				Sleep(1700)
			end
		end
	end
end

function MoonlightShadow(hero,team)
	local target = nil
	for i,v in ipairs(hero) do
		if v.team ~= team and v.visible and v.alive then
			if isMoonlightCasted and not v:DoesHaveModifier("modifier_mirana_moonlight_shadow") then
				isMoonlightCasted = not isMoonlightCasted
			elseif not isMoonlightCasted and v:DoesHaveModifier("modifier_mirana_moonlight_shadow") then
				target = v
				isMoonlightCasted = not isMoonlightCasted
			end
		end
	end
	if target then
		GenerateSideMessage("mirana","mirana_invis")
	end
end

function GenerateSideMessage(heroName,spellName)
	local test = sideMessage:CreateMessage(180,50)
	test:AddElement(drawMgr:CreateRect(10,10,54,30,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/heroes_horizontal/"..heroName)))
	test:AddElement(drawMgr:CreateRect(70,12,62,31,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/other/arrow_usual")))
	test:AddElement(drawMgr:CreateRect(140,10,30,30,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/spellicons/"..spellName)))
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me then
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
		collectgarbage("collect")
		play = false
	end
end

script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_TICK,Load)
