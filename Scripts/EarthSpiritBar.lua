local xx,yy = -15,-48
local modcolor = 0xFFFFFFFF

local mod_text = {}
local mod_name = "modifier_earth_spirit_magnetize"

function Tick(tick)
	if not (IsIngame() or SleepCheck()) then return end

	local me = entityList:GetMyHero()

	if not me then return end
	local enemy = entityList:GetEntities({type=LuaEntity.TYPE_HERO, illusion=false})
	for i,v in ipairs(enemy) do
		local offset = v.healthbarOffset
		if offset == -1 then return end

		if not mod_text[v.handle] then
			mod_text[v.handle] = drawMgr:CreateText(xx,yy,modcolor,"",drawMgr:CreateFont("F15","Arial",15,400)) 
			mod_text[v.handle].visible = false 
			mod_text[v.handle].entity = v 
			mod_text[v.handle].entityPosition = Vector(0,0,offset)
		end

		if v.alive and v.visible and v.health > 0 then
			local magnetize = FindMagnetize(v)
			if magnetize then
				mod_text[v.handle].text = ""..magnetize
				mod_text[v.handle].color = modcolor
				mod_text[v.handle].visible = true
			else
				mod_text[v.handle].visible = false
			end
		else
			mod_text[v.handle].visible = false
		end
	end
end

function FindMagnetize(v)
	local modifier = v.modifiers
	for i = #modifier, 1, -1 do
		local v = v.modifiers[i]
		if v.debuff then
			if v.name == mod_name then
				return math.floor(v.remainingTime*10)/10
			end
		end
	end
	return false
end

function GameClose()
	mod_text = {}
	collectgarbage("collect")
end

script:RegisterEvent(EVENT_TICK,Tick) 
script:RegisterEvent(EVENT_CLOSE,GameClose)
