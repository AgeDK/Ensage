--<<EARTHSHAKER SIMPLE COMBO>>/ Im a begginer hehehe i dont think if it is work 

require("libs.Utils")
require("libs.ScriptConfig")


config = ScriptConfig.new()
config:SetParameter("ComboKey", "D", config.TYPE_HOTKEY)
config:SetParameter("StopKey", "S", config.TYPE_HOTKEY)
config:Load()




local ComboKey     = config.ComboKey
local StopKey      = config.StopKey
local active       = false

local registered   = false


local range 	= 1200
local target    = nil




local x,y = 1350, 50
local monitor = client.screenSize.x/1600
local font = drawMgr:CreateFont("font","Bold",12,300)

local statusText = drawMgr:CreateText(x*monitor,y*monitor,0x5DF5F5FF,"Earthshaker Combo || Press " .. string.char(ComboKey) .. " ||",font) statusText.visible = false







function onLoad()
        if PlayingGame() then
                local me = entityList:GetMyHero()
                if not me or me.classId ~= CDOTA_Unit_Hero_Earthshaker then
                              script:Disable()
                else
                              registered = true
                              statusText.visible = true
                              script:RegisterEvent(EVENT_TICK,Main)
                              script:RegisterEvent(EVENT_KEY,Key)
                              script:UnregisterEvent(onLoad)
                end
        end
end




function Key(msg,code)
        if client.chat or client.console or client.loading then return end

        if code == ComboKey then
                active = true
        end

        if code == StopKey then
                active = false
        end

end







function Main(tick)
    if not SleepCheck() then return end

    local me = entityList:GetMyHero()
    if not me then return end


    local SA = me:FindItem("item_shadow_amulet")
    local SB = me:FindItem("item_invis_sword") 
    local Blink = me:FindItem("item_blink")
    local Ult = me:Getability(4)
    local Firstskill = me:Getability(1)
    local SAModif = me:FindModifier("modifier_item_shadow_amulet_fade")



    if active then

        if me.alive and SA and SA:CanBeCasted() and not SAModif then
                me:CastAbility(SA,me)
                    Sleep(100)
                return
        end

        if me.alive and SAModif.elapsedTime >= (0.90 - (me:GetTurnTime(client.mousePosition))) then
                me:SafeCastAbility(Blink, client.mousePosition)
                me:SafeCastAbility(Ult,true)
                me:SafeCastability(Firstskill,true)
                        active = false
                return
        end

        if me.alive and SB then
                me:SafeCastAbility(Blink, client.mousePosition)
                me:SafeCastAbility(Ult,true)
                me:SafeCastability(Firstskill,true)
                me:SafeCastAbility(SB,true)
                        active = false
                return      
        end
    end

end


















function onClose()

	collectgarbage("collect")

	if registered then

	    statusText.visible = false
            script:UnregisterEvent(Main)

    	    script:UnregisterEvent(Key)

    	    script:RegisterEvent(EVENT_TICK,onLoad)
            registered = false

	end

end

script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)
