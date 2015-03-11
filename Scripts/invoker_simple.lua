require("libs.Utils")

---------------config---------------
local Activated = false
local Spell = true
local ActivatedKey = string.byte("P")
local SpellKey = string.byte("L")
local xx = 10
local yy = 100
------------------------------------

list = { 
	{meteor,string.byte("D"),3,3,2,6},
	{snap,string.byte("Y"),1,1,1,6},
	{alacrity,string.byte("Z"),2,2,3,6},
	{emp,string.byte("C"),2,2,2,6},
	{tornado,string.byte("X"),2,2,1,6},
	{blast,string.byte("B"),1,2,3,6},
	{forge,string.byte("F"),3,3,1,6},
	{wall,string.byte("G"),1,1,3,6},
	{ss,string.byte("T"),3,3,3,6},
	{walk,string.byte("V"),1,1,2,6},
}

local icons = {}
local spells = {}

function Tick()

	if not client.connected or client.loading or client.console or not SleepCheck() then return end

	local me = entityList:GetMyHero()

	if not me then return end	
	
	if me.classId ~= CDOTA_Unit_Hero_Invoker then
		script:Disable()
	else
		if Spell then	
			local r = me:GetAbility(6)
			if not icons[10] then
				for i = 7, 16 do
					table.insert(icons, me:GetAbility(i))
				end
			end
			for i,v in ipairs(icons) do
				if not spells[i] then spells[i] = {}
				spells[i].icon = drawMgr:CreateRect(xx,yy+42*i,40,40,0x000000FF,drawMgr:GetTextureId("NyanUI/spellicons/"..v.name)) spells[i].icon.visible = false
				spells[i].rect = drawMgr:CreateRect(xx,yy+42*i,40,40,0x000000FF,true) spells[i].rect.visible = false
				spells[i].stat = drawMgr:CreateRect(xx+1,yy+42*i+1,38,38,0x000000FF) spells[i].stat.visible = false
				spells[i].txt = drawMgr:CreateText(xx+10,yy+42*i+7,0xFFFFFFff,"",drawMgr:CreateFont("F11","Arial",24,600)) spells[i].txt.visible = false	
				end
				spells[i].icon.visible = true
				spells[i].rect.visible = true
				if v.cd > 0 then						
					local cd = math.ceil(v.cd)
					if cd < 10 then	spells[i].txt.x = xx+10 elseif cd > 100 then spells[i].txt.x = xx+1 else spells[i].txt.x = xx+6 end
					spells[i].txt.text = ""..cd spells[i].txt.visible = true spells[i].txt.color = 0xFFFFFFff
					spells[i].stat.color  = 0xA1A4A150 spells[i].stat.visible = true
				elseif me.mana - v.manacost - r.manacost < 0 then					
					local mp = math.floor(math.ceil(v.manacost + r.manacost - me.mana))
					if mp < 10 then	spells[i].txt.x = xx+10 elseif mp > 100 then spells[i].txt.x = xx+1 else spells[i].txt.x = xx+6 end
					spells[i].txt.text = ""..mp spells[i].txt.visible = true spells[i].txt.color = 0xBBA9EEff
					spells[i].stat.color  = 0x047AFF20 spells[i].stat.visible = true
				else
					spells[i].txt.visible = false spells[i].stat.visible = false
				end				
			end
		else
			if icons[10] then
				GameClose()
			end	
		end
	end
	Sleep(250)
end

function Key(msg,code)
	
	if not client.chat then	
	
		if IsKeyDown(ActivatedKey) then
			Activated = not Activated 
		elseif IsKeyDown(SpellKey) then
			Spell = not Spell
		end
	
		if Activated then
			local me = entityList:GetMyHero()
			if me then
				local invoke = me:GetAbility(6)
				if invoke.state == -1 then
					for i,v in ipairs(list) do
						if (IsKeyDown(v[2]) and IsKeyDown(0x12)) then
							me:CastAbility(me:GetAbility(v[3]))
							me:CastAbility(me:GetAbility(v[4])) 
							me:CastAbility(me:GetAbility(v[5])) 
							me:CastAbility(me:GetAbility(v[6]))
						end
					end
				end
			end
		end
		
	end
	
end

function GameClose()
	icons = {}
	spells = {}
	collectgarbage("collect")
end


script:RegisterEvent(EVENT_CLOSE, GameClose)
script:RegisterEvent(EVENT_KEY,Key)
script:RegisterEvent(EVENT_TICK,Tick)
