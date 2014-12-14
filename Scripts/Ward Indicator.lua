require("libs.Utils")
require("libs.SideMessage")

local last = {}
local play = false

function Tick(tick)

	if client.console or not SleepCheck() then return end
	
	local me = entityList:GetMyHero() if not me then return end Sleep(1000)

	local smoke = entityList:GetEntities(function (ent) return ent.type == LuaEntity.TYPE_ITEM and ent.name == "item_ward_observer" and ent.owner.team ~= teams end)

	for i = #smoke+1, 1, -1 do
		if not last[i] then
			last[i] = {0,0}
		end
		if #smoke ~= last[i] then
			if smoke[i] then
				last[i] = {#smoke,smoke[i].owner.name}
			elseif type(last[i][2]) ~= "number" then
				SmokeSideMessage(last[i][2]:gsub("npc_dota_hero_",""),"item_ward_observer")
				last[i] = {0,0}
			end
		end
	end

end

function SmokeSideMessage(heroName)
	local test = sideMessage:CreateMessage(200,60)
	test:AddElement(drawMgr:CreateRect(10,10,72,40,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/heroes_horizontal/"..heroName)))
	test:AddElement(drawMgr:CreateRect(85,1,62,61,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/other/statpop_question")))
	test:AddElement(drawMgr:CreateRect(140,13,70,35,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/items/ward_observer")))
end

function Load()
	if PlayingGame() then
		script:RegisterEvent(EVENT_TICK,Tick)
		script:UnregisterEvent(Load)
		play = true
	end
end

function GameClose()
	if play then
		script:UnregisterEvent(Tick)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
	last = {}
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)
