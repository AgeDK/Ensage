require("libs.Utils")
require("libs.ScriptConfig")

config = ScriptConfig.new()
config:SetParameter("Active", "F", config.TYPE_HOTKEY)
config:SetParameter("UseOrchid", true)
config:Load()

local toggleKey   = config.Active
local UseOrchid   = config.UseOrchid
local reg         = false
local activerino  = false
local monitor     = client.screenSize.x/1600
local F15         = drawMgr:CreateFont("F15","Tahoma",15*monitor,550*monitor)
local F14         = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText  = drawMgr:CreateText(10*monitor,560*monitor,-1,"Disable On Sight: Initiators",F14)
local statusText2 = drawMgr:CreateText(10*monitor,560*monitor,-1,"Disable On Sight: Any Enemy",F14)


function Key(msg,code)
	if client.chat then return end
	if IsKeyDown(toggleKey) then
		activerino = not activerino
	end
	if not activerino then
		statusText2.visible = false
		statusText.visible  = true
	else
		statusText.visible  = false
		statusText2.visible = true
	end
end

function Tick(tick)
	if not SleepCheck() then return end	Sleep(20)
	local me = entityList:GetMyHero()
	if not me then return end
	local ID = me.classId
	if ID == CDOTA_Unit_Hero_Lion then
		Disable(me,2,"lion_voodoo")
	elseif ID == CDOTA_Unit_Hero_ShadowShaman then		
		Disable(me,2,"shadow_shaman_voodoo")
	else
		Disable(me,nil,nil)
	end
end

function Disable(me,disable,nativeSpell)
	if me.alive and not me:IsChanneling() then
		local sheepstick = me:FindItem("item_sheepstick")
		local orchid     = me:FindItem("item_orchid")
		local enemies    = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = 5-me.team,alive=true,visible=true,illusion=false})
		for i,v in ipairs(enemies) do
			local blink = v:FindItem("item_blink")
			local SI	= v:IsSilenced()
			local MI 	= v:IsMagicImmune()

			if GetDistance2D(v,me) < 825 and sheepstick and sheepstick:CanBeCasted() then
				if activerino and not (MI or SI) then
					me:SafeCastItem("item_sheepstick",v)
					break
				end
				if blink and blink.cd > 11 and not (MI or SI) then
					me:SafeCastItem("item_sheepstick",v)
					break
				end

			elseif GetDistance2D(v,me) < 925 and UseOrchid and orchid and orchid:CanBeCasted() then
				if activerino and not (MI or SI) then
					me:SafeCastItem("item_orchid",v)
					break
				end
				if blink and blink.cd > 11 and not (MI or SI) then
					me:SafeCastItem("item_orchid",v)
					break
				end
			elseif disable ~= nil then
				local SpellDisable = me:GetAbility(disable)
				local SpellFind    = me:FindAbility(nativeSpell)

				if SpellFind:CanBeCasted() and GetDistance2D(v,me) < SpellDisable.castRange + 25 then
					if activerino and not (MI or SI) then
						me:SafeCastAbility(SpellDisable,v)
						break
					end
					if blink and blink.cd > 11 and not (MI or SI) then
						me:SafeCastAbility(SpellDisable,v)
						break
					end
				end
			end
		end
	end
end

function Load()
	if PlayingGame() then
		statusText.visible = true
		local me = entityList:GetMyHero()
		reg = true
		script:RegisterEvent(EVENT_TICK,Tick)
		script:RegisterEvent(EVENT_KEY,Key)
		script:UnregisterEvent(Load)
	end
end

function GameClose()
	DisableOnSight      = nil
	statusText.visible  = false
	statusText2.visible = false
	collectgarbage("collect")
	if reg then
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		reg = false
	end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
