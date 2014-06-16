--[[
 ______                __              ___                   _______                                                           __         __               __                __      __  ______            
|   __ \.---.-..-----.|__|.-----.    .'  _|.-----..----.    |   |   |.-----..----..-----..-----..-----.    .-----..----..----.|__|.-----.|  |_ .-----.    |  |--..--.--.    |  |--. |__||__    |.---.-.    
|   __ <|  _  ||__ --||  ||__ --|    |   _||  _  ||   _|    |       ||  -__||   _||  _  ||  -__||__ --|    |__ --||  __||   _||  ||  _  ||   _||__ --|    |  _  ||  |  |    |    <  |  ||    __||  _  | __ 
|______/|___._||_____||__||_____|    |__|  |_____||__|      |___|___||_____||__|  |_____||_____||_____|    |_____||____||__|  |__||   __||____||_____|    |_____||___  |    |__|__| |  ||______||___._||__|
                                                                                                                                  |__|                           |_____|           |___|              
]]
require("libs.Utils")
require("libs.TargetFind")
require("libs.HotkeyConfig")
sleepTick = {0,0,0}
Queue = {}
currentTick = nil
lastSpell = nil
x,y = 10,45
myFont = drawMgr:CreateFont("StormSpirit","Arial",14,400)
statusText = drawMgr:CreateText(x,y+50,0xffff00ff,"Target: ",myFont);
targetText = drawMgr:CreateText(x+38,y+50,0xff0000ff,"",myFont);
statusText.visible = false
targetText.visible = false
targetHandle = nil
 
ScriptConfig = ConfigGUI:New(script.name)
script:RegisterEvent(EVENT_KEY, ScriptConfig.Key, ScriptConfig)
script:RegisterEvent(EVENT_TICK, ScriptConfig.Refresh, ScriptConfig)
ScriptConfig:SetName("StormSpirit")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)
ScriptConfig:AddParam("combo","Wombo-Combo",SGC_TYPE_ONKEYDOWN,false,false,string.byte(" "))
 
function MainTick(tick)
	if (sleepTick[1] and sleepTick[1] < tick) then
		currentTick = tick
        if not client.connected or client.loading or client.console or client.paused then 
			return 
		end
        me = entityList:GetMyHero()	
		if not me then return end
		if not ProcessQueue() then
			return
		end
		
		if not targetHandle then 
			targetText.visible = false 
			statusText.visible = false
		end
	
		if not PlayingGame() then
			ScriptConfig:SetVisible(false)
			return
		end
		if me.name ~= "npc_dota_hero_storm_spirit" then
			ScriptConfig:SetVisible(false)
			script:Disable()
			return
		else
			GoUseTick()
		end
	end
end

function sleep(i,d)
    sleepTick[i] = currentTick + d
end
function ProcessQueue()
    if #Queue == 0 then return true end
    target = Queue[1][2]
    spell = Queue[1][1]
    delay = Queue[1][3]
   if (lastSpell and lastSpell.state == LuaEntityAbility.STATE_COOLDOWN) then table.remove(Queue,1) end
    if  (me.unitState > 33600000 or me.unitState == 16 )and target then
        if currentTick > sleepTick[2] then
            --me:Attack(target)
            sleepTick[2] = currentTick + 500
        end
        return false
    end
	
	if spell.name == "item_orchid" and target:DoesHaveModifier("modifier_sheepstick_debuff") then
		table.remove(Queue,1)
		return false
	elseif spell.name == "item_sheepstick" and target:DoesHaveModifier("modifier_orchid_malevolence_debuff") then
		table.remove(Queue,1)
		return false
	end
	
    Cast(spell,target)
    sleep(1,delay)
    lastSpell = spell
    table.remove(Queue,1)
end
function QueueSpell(spell,target,delay)
	if spell and spell.state ~= LuaEntityAbility.STATE_COOLDOWN then
		table.insert(Queue, {spell,target,delay})
	end
end
function CastItems(itemList,target,delay)
    for i,name in ipairs(itemList) do
        local item = me:FindItem(name)
        if (item ~= false) then
            QueueSpell(item,target,delay)
        end
    end
end
function getPosition(target)
	return Vector(target.position.x,target.position.y,target.position.z)
end
function Cast(spell,target)
    if spell ~= nil and spell.state == LuaEntityAbility.STATE_READY then
        if target then
            me:SafeCastAbility(spell,target)
        else
            me:SafeCastAbility(spell)
        end
    end
end

function GoUseTick()
	ScriptConfig:SetVisible(true)
    local _Q = me:GetAbility(1)
    local _W = me:GetAbility(2)
	local target = nil
	target = targetFind:GetLastMouseOver(600)
	if not target or not target.visible or not target.alive or not me.alive then
		targetHandle = nil
		targetText.visible = false
		statusText.visible = false
		return 
	end	
	if ScriptConfig.combo then
		targetText.text = client:Localize(target.name)
		targetText.visible = true
		statusText.visible = true
		targetHandle = target.handle
		
		if  #Queue == 0 then
			local distance = GetDistance2D(me,target)
			CastItems({"black_king_bar","item_shivas_guard"},nil,50)
			
			if distance <= 300 then 
				QueueSpell(_W,target,50)
			end
			
			if distance <= 260 then 
				QueueSpell(_Q,nil,50)
			end

			if distance <= 900 then
				CastItems({"item_orchid","item_sheepstick"},target,250)
			end
			me:Attack(target)
		end
	end
	sleep(1,250)
	return
end
function GameClose()
	targetHandle = nil
	sleepTick = {0,0,0}
	Queue = {}
	currentTick = nil
	lastSpell = nil
	statusText.visible = false
	targetText.visible = false
	ScriptConfig:SetVisible(false)
end
script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK, MainTick)
