--<<Naga auto farm/stack/creepwave cut>>

--[[ Naga Farm script by Moones ]]--

require("libs.ScriptConfig")
require("libs.Utils")
require("libs.EasyHUD")
require("libs.SkillShot")

local currentVersion = 0.45
local Beta = ""

local config = ScriptConfig.new()
config:SetParameter("StackKey", "F", config.TYPE_HOTKEY)
config:SetParameter("FarmJungleKey", "I", config.TYPE_HOTKEY)
config:SetParameter("CreepCutKey", "U", config.TYPE_HOTKEY)
config:SetParameter("AutoModeKey", "D", config.TYPE_HOTKEY)
config:SetParameter("ComboScriptKey", "G", config.TYPE_HOTKEY)
config:SetParameter("OpenMenu", "M", config.TYPE_HOTKEY)
config:SetParameter("EnableHotkeys", true, config.TYPE_BOOL)
config:SetParameter("VersionInfoPosX", 670, config.TYPE_NUMBER)
config:SetParameter("VersionInfoPosY", 750, config.TYPE_NUMBER)
config:Load()

local player,me,JungleCamps,enemyTeam,meTeam,reg,stack,myId,Q,E,ERadius,cut,farm,auto,HUD,autoE,enemyjungle,radiance,octa,manta,travels
local topLaneData = {} local midLaneData = {} local botLaneData = {} local dataSaved = false local dataUpdated = false local buttons = {}
local creepwaves = {{position = Vector(0,0,0), visible = false, cutted = nil, dead = false, id = 1},
{position = Vector(0,0,0), visible = false, cutted = nil, dead = false, id = 2},
{position = Vector(0,0,0), visible = false, cutted = nil, dead = false, id = 3},
{position = Vector(0,0,0), visible = false, cutted = nil, dead = false, id = 4},
{position = Vector(0,0,0), visible = false, cutted = nil, dead = false, id = 5},
{position = Vector(0,0,0), visible = false, cutted = nil, dead = false, id = 6}}

local F14 = drawMgr:CreateFont("F14","Tahoma",13,800)
local versionSign = drawMgr:CreateText(client.screenSize.x*config.VersionInfoPosX/1000,client.screenSize.y*config.VersionInfoPosY/1000,0x66FF33FF,"",F14)
local F12 = drawMgr:CreateFont("F12","Tahoma",12,800)
local infoSign = drawMgr:CreateText(client.screenSize.x*config.VersionInfoPosX/1000,(client.screenSize.y*config.VersionInfoPosY/1000)+20,-1,"",F12)
local victims = {}

function Key(msg,code)
if client.chat or client.console or not PlayingGame() then return end
if msg == KEY_UP then
if code == config.StackKey and config.EnableHotkeys then
stack = not stack
if stack then
buttons[1].obj.color = 0x05999990
buttons[2].obj.color = 0x60615FFF
buttons[3].obj.color = 0x60615FFF
buttons[4].obj.color = 0x60615FFF
else
buttons[1].obj.color = 0x60615FFF
end
elseif code == config.CreepCutKey and config.EnableHotkeys then
cut = not cut
if cut then
buttons[4].obj.color = 0x05999990
buttons[2].obj.color = 0x60615FFF
buttons[3].obj.color = 0x60615FFF
buttons[1].obj.color = 0x60615FFF
else
buttons[4].obj.color = 0x60615FFF
end
elseif code == config.FarmJungleKey and config.EnableHotkeys then
farm = not farm
if farm then
buttons[2].obj.color = 0x60615FFF
buttons[1].obj.color = 0x60615FFF
buttons[4].obj.color = 0x60615FFF
buttons[3].obj.color = 0x05999990
else
buttons[3].obj.color = 0x60615FFF
end
elseif code == config.AutoModeKey and config.EnableHotkeys then
auto = not auto
if auto then
buttons[2].obj.color = 0x05999990
buttons[1].obj.color = 0x60615FFF
buttons[3].obj.color = 0x60615FFF
buttons[4].obj.color = 0x60615FFF
else
buttons[2].obj.color = 0x60615FFF
end
elseif code == config.OpenMenu and HUD then
HUD:Open()
end
end
end

function buttonClick(b1,b2,t)
if b1.color == 0x60615FFF then
b1.color = 0x05999990
else
b1.color = 0x60615FFF
end
if t.text == "Stack" then
stack = not stack
buttons[2].obj.color = 0x60615FFF
buttons[3].obj.color = 0x60615FFF
buttons[4].obj.color = 0x60615FFF
elseif t.text == "AutoMode" then
auto = not auto
buttons[1].obj.color = 0x60615FFF
buttons[3].obj.color = 0x60615FFF
buttons[4].obj.color = 0x60615FFF
elseif t.text == "Farm Jungle" then
farm = not farm
buttons[2].obj.color = 0x60615FFF
buttons[1].obj.color = 0x60615FFF
buttons[4].obj.color = 0x60615FFF
elseif t.text == "Cut Creepwaves" then
cut = not cut
buttons[2].obj.color = 0x60615FFF
buttons[3].obj.color = 0x60615FFF
buttons[1].obj.color = 0x60615FFF
end
end

function Main()

--VersionInfo
if client.gameTime > 1 then
versionSign.visible = false
infoSign.visible = false
else
local up,ver,beta,info = Version()
if up then
if beta ~= "" then
versionSign.text = "Your version of Naga Farm Script is up-to-date! (v"..currentVersion.." "..Beta..")"
else
versionSign.text = "Your version of Naga Farm Script is up-to-date! (v"..currentVersion..")"
end
versionSign.color = 0x66FF33FF
if info then
infoSign.text = info
infoSign.visible = true
end
end
if outdated then
if beta ~= "" then
versionSign.text = "Your version of Naga Farm is OUTDATED (Yours: v"..currentVersion.." "..Beta.." Current: v"..ver.." "..beta..")"
else
versionSign.text = "Your version of Naga Farm is OUTDATED (Yours: v"..currentVersion.." "..Beta.." Current: v"..ver..")"
end
versionSign.color = 0xFF6600FF
if info then
infoSign.text = info
infoSign.visible = true
end
end
versionSign.visible = true
end

if not PlayingGame() or client.paused or IsKeyDown(config.ComboScriptKey) or IsKeyDown(17) or not me or client.shopOpen then if not me then me = entityList:GetMyHero() end return end
local me = me local ID = me.classId if ID ~= myId then Close() end local player = player
local mathmin,mathmax,mathcos,mathsin,mathceil,mathrad,mathsqrt,mathabs,mathrad,mathfloor,mathatan,mathdeg = math.min,math.max,math.cos,math.sin,math.ceil,math.rad,math.sqrt,math.abs,math.rad,math.floor,math.atan,math.deg
if not enemyTeam then enemyTeam = me:GetEnemyTeam() end if not meTeam then meTeam = me.team end local GetDistance2D = GetDistance2D
local gameTime = client.gameTime
if not octa then octa = me:FindItem("item_octarine_core") end
local illusions = entityList:GetEntities({type=LuaEntity.TYPE_HERO,classId=CDOTA_Unit_Hero_Naga_Siren,team=meTeam,visible=true,illusion=true,alive=true})
if not radiance then radiance = me:FindItem("item_radiance") end

--GUI
if not HUD then
local hudW = client.screenSize.x*0.0072+400
local hudH = 45
HUD = EasyHUD.new(client.screenSize.x*0.39,client.screenSize.y*0.75,hudW,hudH,"Naga Script Menu",05000000,94563580,true,true)
buttons[1] = {} buttons[2] = {} buttons[3] = {} buttons[4] = {} buttons[5] = {} buttons[6] = {}
buttons[1].id, buttons[1].obj = HUD:AddButton(HUD.w*0.02,HUD.h*0.25,50,25,0x60615FFF,"Stack",buttonClick)
buttons[2].id, buttons[2].obj = HUD:AddButton(HUD.w*0.02+52,HUD.h*0.25,60,25,0x60615FFF,"AutoMode",buttonClick)
buttons[3].id, buttons[3].obj = HUD:AddButton(HUD.w*0.02+114,HUD.h*0.25,70,25,0x60615FFF,"Farm Jungle",buttonClick)
buttons[4].id, buttons[4].obj = HUD:AddButton(HUD.w*0.02+186,HUD.h*0.25,90,25,0x60615FFF,"Cut Creepwaves",buttonClick)
buttons[5].id, buttons[5].obj = HUD:AddCheckbox(HUD.w*0.02+280,HUD.h*0.18,15,15,"Enable auto E",nil,autoE);
buttons[6].id, buttons[6].obj = HUD:AddCheckbox(HUD.w*0.02+280,HUD.h*0.18+15,15,15,"Farm enemy jungle",nil,enemyjungle);
else
autoE = HUD:IsChecked(buttons[5].id+1)
enemyjungle = HUD:IsChecked(buttons[6].id+1)
cut = buttons[4].obj.color == 0x05999990
farm = buttons[3].obj.color == 0x05999990
auto = buttons[2].obj.color == 0x05999990
stack = buttons[1].obj.color == 0x05999990
end

local neutrals = entityList:GetEntities({team=LuaEntity.TEAM_NEUTRAL,alive=true})
local allies = entityList:GetEntities({type = LuaEntity.TYPE_HERO, team = meTeam, alive=true})
local enemies = entityList:GetEntities({type = LuaEntity.TYPE_HERO, team = enemyTeam, alive=true, visible = true})
local lanecreeps = entityList:GetEntities({classId = CDOTA_BaseNPC_Creep_Lane,visible = true,alive = true})
local towers = entityList:GetEntities({classId=CDOTA_BaseNPC_Tower,visible=true,team=enemyTeam,alive=true})
local towerCount = #towers
local racks = entityList:GetEntities({classId=CDOTA_BaseNPC_Barracks,team=enemyTeam,visible=true,alive=true})
local racksCount = #racks

--After 7:30 min mark creeps on offlanes/hardlanes dont change their movespeed
if gameTime > 450 and gameTime < 451 and not dataUpdated then
local team = "Dire"
if meTeam == LuaEntity.TEAM_DIRE then team = "Radiant" end
local topLanedata = io.open(SCRIPT_PATH.."/CreepsPathData/"..team.."TopLane2.txt", "r")
if topLanedata then
local count = 0
topLaneData = {}
while true do
local time, posX, posY, posZ = topLanedata:read("*number", "*number", "*number", "*number")
if not time or not posX or not posY or not posZ then break end
count = count + 1
topLaneData[count] = {time, Vector(posX, posY, posZ)}
end
topLanedata:close()
else
print("Please download CreepsPathData in order to use this script!")
script:Disable()
end
local botLanedata = io.open(SCRIPT_PATH.."/CreepsPathData/"..team.."BotLane2.txt", "r")
botLaneData = {}
if botLanedata then
local count = 0
while true do
local time, posX, posY, posZ = botLanedata:read("*number", "*number", "*number", "*number")
if not time or not posX or not posY or not posZ then dataUpdated = true break end
count = count + 1
botLaneData[count] = {time, Vector(posX, posY, posZ)}
end
botLanedata:close()
end
end

if gameTime > 0 and SleepCheck("pred") then
Sleep(500,"pred")
local seconds = gameTime % 60
local seconds2 = (gameTime + 30) % 60

if seconds < 1 then
creepwaves[1].visible = true
creepwaves[3].visible = true
creepwaves[5].visible = true
creepwaves[1].dead = false
creepwaves[3].dead = false
creepwaves[5].dead = false
end
if seconds2 < 1 then
creepwaves[2].visible = true
creepwaves[4].visible = true
creepwaves[6].visible = true
creepwaves[2].dead = false
creepwaves[4].dead = false
creepwaves[6].dead = false
end

seconds = (gameTime + 1) % 60
seconds2 = (gameTime + 31) % 60

local topLaneData,midLaneData,botLaneData = topLaneData,midLaneData,botLaneData

--Update position
if dataSaved then
local position, position2 = nil, nil
for i = 1, #topLaneData do
local data = topLaneData[i]
local time, pos = data[1], data[2]
if time <= seconds and creepwaves[1].visible then
position = pos
end
if time <= seconds2 and creepwaves[2].visible then
position2 = pos
end
end
if position then
creepwaves[1].position = position
end
if position2 then
creepwaves[2].position = position2
end
position, position2 = nil, nil
for i = 1, #midLaneData do
local data = midLaneData[i]
local time, pos = data[1], data[2]
if time <= seconds and creepwaves[3].visible then
position = pos
end
if time <= seconds2 and creepwaves[4].visible then
position2 = pos
end
end
if position then
creepwaves[3].position = position
end
if position2 then
creepwaves[4].position = position2
end
position, position2 = nil, nil
for i = 1, #botLaneData do
local data = botLaneData[i]
local time, pos = data[1], data[2]
if time <= seconds and creepwaves[5].visible then
position = pos
end
if time <= seconds2 and creepwaves[6].visible then
position2 = pos
end
end
if position then
creepwaves[5].position = position
end
if position2 then
creepwaves[6].position = position2
end
end
end

local illusionCount = #illusions
local creepCount = #lanecreeps
if SleepCheck("asd") then
for z = 1, 6 do
local wave = creepwaves[z]
local closestCreep = nil
for i = 1, creepCount do
local v = lanecreeps[i]
if v.spawned and wave.position ~= Vector(0,0,0) then
if GetDistance2D(wave.position,v) < 500 then
creepwaves[z].visible = false
creepwaves[z].position = v.position
end
if GetDistance2D(v,wave.position) < 700 and (not closestCreep or GetDistance2D(wave.position,creep) < GetDistance2D(closestCreep,wave.position)) then
closestCreep = v.position
end
end
end
if not creepwaves[z].visible and not closestCreep then
creepwaves[z].dead = true
end
if (not octa and math.floor(Q.cd) == 10) or illusionCount <= 0 then
creepwaves[z].cutted = nil
elseif octa and Q.cd == 0 then
creepwaves[z].cutted = nil
end
end
end

local tempJungleCamps = JungleCamps
local neutralsCount = #neutrals
local alliescount = #allies
if SleepCheck("asd") then
Sleep(100,"asd")
for i = 1, #tempJungleCamps do
local camp = tempJungleCamps[i]
local block = false
local farmed = true
for k = 1, neutralsCount do
local ent = neutrals[k]
if ent.alive and ent.spawned and GetDistance2D(ent,camp.position) < 800 then
farmed = false
JungleCamps[camp.id].farmed = false
tempJungleCamps = JungleCamps
end
end
for m = 1, alliescount do
local v = allies[m]
if GetDistance2D(v,camp.position) < 500 and v.alive then
block = true
end
if farmed and GetDistance2D(v,camp.position) < 500 then
JungleCamps[camp.id].farmed = true
tempJungleCamps = JungleCamps
end
if GetDistance2D(v,camp.position) < 300 then
JungleCamps[camp.id].visible = v.visibleToEnemy
tempJungleCamps = JungleCamps
end
end
if gameTime < 30 then
JungleCamps[camp.id].farmed = true
tempJungleCamps = JungleCamps
end
if (gameTime % 60 > 0.5 and gameTime % 60 < 2) or (gameTime > 30 and gameTime < 32) then
if camp.farmed then
if not block then
JungleCamps[camp.id].farmed = false
tempJungleCamps = JungleCamps
end
end
if camp.stacking then
JungleCamps[camp.id].stacking = false
tempJungleCamps = JungleCamps
end
end
if camp.visible then
if (gameTime - camp.visTime) > 30 then
JungleCamps[camp.id].visible = false
tempJungleCamps = JungleCamps
end
end

if (not octa and math.floor(Q.cd) == 10) or illusionCount <= 0 then
JungleCamps[camp.id].stacked = nil
elseif octa and Q.cd == 0 then
JungleCamps[camp.id].stacked = nil
end
end
end

if (not octa and math.floor(Q.cd) == 10) or illusionCount <= 0 then
victims = {}
elseif octa and Q.cd == 0 then
victims = {}
end

local enemycount = #enemies
local table = {}
local projectiles = entityList:GetProjectiles({})
local projectilCount = #projectiles
local movespeed = me.movespeed
if not travels then travels = me:FindItem("item_travel_boots") or me:FindItem("item_travel_boots_2")
else movespeed = movespeed + 100 end
if not manta then manta = me:FindItem("item_manta")
else movespeed = movespeed + movespeed*0.1 end
local prev = player.selection
for i = 1, illusionCount do
local illusion = illusions[i]
local modif = illusion:FindModifier("modifier_illusion")
if illusion.controllable and modif then
local time = modif.remainingTime - 5
local hand = illusion.handle
local closestCreep = nil
local closestNeutral = nil
local closestallyCreep = nil
local closeEnemy = nil
local dpos = nil
local closestTower = nil
local closestRacks = nil
local creepscount = 0
local averagecreeppos = nil
local neutralscount = 0
local averageneutralpos = nil
local ranged = false
if auto or cut or farm then
for z = 1, creepCount do
local creep = lanecreeps[z]
if creep.spawned and creep.team ~= meTeam then
if creep.visible and creep.classId ~= CDOTA_BaseNPC_Creep_Siege and GetDistance2D(illusion,creep) < 500 and (not table[i]) then
table[i] = GetDistance2D(illusion,creep) <= ERadius and not creep:IsInvul() and creep.health > illusion.dmgMin
end
if not closestCreep or GetDistance2D(illusion,closestCreep) > GetDistance2D(illusion,creep) then
closestCreep = creep
end
elseif creep.team == meTeam then
if not closestallyCreep or GetDistance2D(illusion,closestallyCreep) > GetDistance2D(illusion,creep) then
closestallyCreep = creep
end
end
if creep.visible and creep.spawned and GetDistance2D(creep,illusion) <= 500 and creep.visible and creep.team == enemyTeam then
creepscount = creepscount + 1
if not averagecreeppos then
averagecreeppos = creep.position
else
averagecreeppos = creep.position + averagecreeppos
end
end
end
end
if auto or farm or stack then
for z = 1, neutralsCount do
local creep = neutrals[z]
if creep.spawned and creep.alive and not creep.ancient then
if creep.visible and not creep.ancient and GetDistance2D(illusion,creep) < 500 and (not table[i]) then
table[i] = GetDistance2D(illusion,creep) <= ERadius and not creep:IsInvul() and creep.health > illusion.dmgMin
end
if not closestNeutral or GetDistance2D(illusion,closestNeutral) > GetDistance2D(illusion,creep) then
closestNeutral = creep
end
if creep:IsRanged() then ranged = true end
end
if creep.visible and creep.spawned and GetDistance2D(creep,illusion) <= 500 and creep.visible then
neutralscount = neutralscount + 1
if not averageneutralpos then
averageneutralpos = creep.position
else
averageneutralpos = creep.position + averageneutralpos
end
end
end
end
if not averagecreeppos and closestCreep then averagecreeppos = closestCreep.position end
if not averageneutralpos and closestNeutral then averageneutralpos = closestNeutral.position end
if cut or farm or (radiance and auto and (not victims[i] or not victims[i].alive)) then
for z = 1, enemycount do
local enemy = enemies[z]
if enemy.visible and enemy.alive and GetDistance2D(illusion,enemy) < 500 and (not table[i]) then
table[i] = GetDistance2D(illusion,enemy) <= ERadius and not enemy:IsInvul()
end
if (not victims[i] or not victims[i].alive) and enemy.health < illusion.maxHealth and GetDistance2D(illusion,enemy) < 700 and (not closeEnemy or GetDistance2D(illusion,closeEnemy) > GetDistance2D(illusion,enemy)) then
closeEnemy = enemy
elseif enemy.health > illusion.maxHealth and GetDistance2D(illusion,enemy) < 700 and (not dpos or GetDistance2D(illusion,dpos) > GetDistance2D(illusion,enemy)) then
dpos = enemy.position
end
end
end
if cut or auto then
for z = 1, towerCount do
local v = towers[z]
if GetDistance2D(illusion,v) < 700 and (not closestTower or GetDistance2D(illusion,closestTower) > GetDistance2D(illusion,v)) then
closestTower = v
end
end
end
if cut or auto then
for z = 1, racksCount do
local v = racks[z]
if GetDistance2D(illusion,v) < 700 and not v:IsAttackImmune() and not v:IsInvul() and not v:DoesHaveModifier("modifier_backdoor_protection_active") and (not closestRacks or GetDistance2D(illusion,closestRacks) > GetDistance2D(illusion,v)) then
closestRacks = v
end
end
end
local attackedbytower = false
local closestTower = nil
if auto or cut or farm then
--Unaggro
for i = 1, projectilCount do
local p = projectiles[i]
local sour = p.source
if sour and sour.classId == CDOTA_BaseNPC_Tower and p.target and p.target == illusion and GetDistance2D(illusion,sour) <= sour.attackRange+25 then
attackedbytower = true
closestTower = sour
local sourHand = sour.handle
if SleepCheck(hand.."unaggro") and SleepCheck(sourHand) then
if closestallyCreep and GetDistance2D(closestallyCreep,sour) <= sour.attackRange+25 then
SelectUnit(illusion)
player:Attack(closestallyCreep)
Sleep((GetDistance2D(illusion,p.position)/p.speed)*1000,sourHand)
Sleep(250, hand.."unaggro")
Sleep(500, hand.."attack")
end
elseif SleepCheck(hand.."unaggro2") and SleepCheck(hand.."-casting") and illusion.activity == LuaEntityNPC.ACTIVITY_MOVE then
SelectUnit(illusion)
player:HoldPosition()
Sleep((GetDistance2D(illusion,p.position)/p.speed)*1000,hand.."unaggro2")
Sleep(500, hand.."attack")
end
end
end
end
if victims[i] and victims[i].alive and GetDistance2D(illusion,victims[i]) < 700 then closeEnemy = victims[i] else victims[i] = nil end
if auto then
local closestWave = getClosestWave(illusion)
local camp = getClosestCamp(illusion)
if camp and ((camp.stacked and camp.stacked ~= hand) or camp.farmed) then camp = getClosestCamp(illusion) end
if closestWave and ((closestWave.cutted and closestWave.cutted ~= hand) or closestWave.dead) then closestWave = getClosestWave(illusion) end
if SleepCheck(hand.."attack") then
if closestRacks then
SelectUnit(illusion)
player:Attack(closestRacks)
Sleep(1000,hand.."attack")
elseif dpos and ((closestWave and GetDistance2D(closestWave.position,illusion) < 500 and closestCreep and GetDistance2D(closestCreep,illusion) < 500) or (camp and GetDistance2D(camp.position,illusion) < 500)) then
local pos = (illusion.position - dpos) * (GetDistance2D(illusion,dpos) + 5000) / GetDistance2D(illusion,dpos) + illusion.position
SelectUnit(illusion)
player:Move(pos)
Sleep(500,hand.."attack")
elseif closestTower then
if attackedbytower and (not closestallyCreep or GetDistance2D(closestallyCreep,closestTower) > closestTower.attackRange+500) and (closestWave and GetDistance2D(closestWave.position,illusion) < 500 and closestCreep and GetDistance2D(closestCreep,illusion) < 500) then
local pos = (illusion.position - closestTower.position) * (closestTower.attackRange+500) / GetDistance2D(illusion,closestTower) + illusion.position
SelectUnit(illusion)
player:Move(pos)
Sleep(500,hand.."attack")
elseif closestallyCreep and GetDistance2D(closestallyCreep,closestTower) < closestTower.attackRange+500 then
SelectUnit(illusion)
player:Attack(closestTower)
Sleep(500,hand.."attack")
end
elseif closeEnemy and closeEnemy.health < illusion.maxHealth then
victims[i] = closeEnemy
SelectUnit(illusion)
player:Attack(closeEnemy)
Sleep(500,hand.."attack")
elseif closestWave and illusion.acitivty ~= LuaEntityNPC.ACTIVITY_ATTACK and GetDistance2D(illusion,closestWave.position)/movespeed < time and (not camp or GetDistance2D(closestWave.position,illusion) < GetDistance2D(camp.position,illusion) or camp.farmed or (camp.stacked and camp.stacked ~= hand)) and not closestWave.dead and (not closestWave.cutted or closestWave.cutted == hand) then
creepwaves[closestWave.id].cutted = hand
if GetDistance2D(illusion,closestWave.position) > 1000 then
SelectUnit(illusion)
player:Move(closestWave.position)
player:AttackMove(closestWave.position,true)
else
if averagecreeppos then averagecreeppos = averagecreeppos/creepscount end
if closestCreep and illusion.recentDamage > 0 and GetDistance2D(closestWave.position,illusion) < 300 and (1000 > illusion.health or (creepscount*(closestCreep.health) > illusion.health)) then
if averagecreeppos then
local pos = (illusion.position - averagecreeppos) * (500) / GetDistance2D(illusion,averagecreeppos) + illusion.position
SelectUnit(illusion)
player:Move(pos)
player:Attack(closestCreep,true)
Sleep(500,hand.."attack")
end
elseif (illusion.activity == LuaEntityNPC.ACTIVITY_IDLE or illusion.activity == LuaEntityNPC.ACTIVITY_IDLE1) and illusion.recentDamage == 0 then
SelectUnit(illusion)
player:Move(averagecreeppos)
player:AttackMove(averagecreeppos,true)
end
end
Sleep(500,hand.."attack")
Sleep(client.latency+illusion:GetTurnTime(closestWave.position)*1000,hand.."latency")
elseif camp and GetDistance2D(illusion,camp.position)/movespeed < time and not camp.farmed and (not camp.stacked or camp.stacked == hand) then
if illusion.health > 1000 or radiance then
JungleCamps[camp.id].stacked = hand
end
if (not closestNeutral or GetDistance2D(closestNeutral,camp.position) > 700) and SleepCheck(hand.."move") and GetDistance2D(camp.position,illusion) > 1000 then
SelectUnit(illusion)
player:Move(camp.position)
player:AttackMove(camp.position,true)
Sleep(1000,hand.."move")
end
if closestNeutral and SleepCheck(hand.."attack") and GetDistance2D(closestNeutral,camp.position) < 500 then
if averageneutralpos then averageneutralpos = averageneutralpos/neutralscount end
local front = SkillShot.InFront(closestNeutral, 500)
--print(GetDistance2D(closestNeutral,illusion), GetDistance2D(front,illusion) , closestNeutral.health, illusion.health)
if SleepCheck(hand.."asd") and SleepCheck("asaa") and GetDistance2D(closestNeutral,illusion) < 300 and not ranged and illusion.recentDamage > 0 and GetDistance2D(front,illusion) < GetDistance2D(front,closestNeutral) and closestNeutral.visible and (closestNeutral.health > illusion.health or (neutralscount*(closestNeutral.health) > illusion.health)) then
if averageneutralpos then
local pos = (illusion.position - averageneutralpos) * (300) / GetDistance2D(illusion,averageneutralpos) + illusion.position
SelectUnit(illusion)
player:Move(pos)
player:Attack(closestNeutral,true)
Sleep(500,hand.."attack")
Sleep(1000,hand.."asd")
Sleep(2000,"asaa")
end
elseif (illusion.activity == LuaEntityNPC.ACTIVITY_IDLE or illusion.activity == LuaEntityNPC.ACTIVITY_IDLE1) and illusion.recentDamage == 0 then
SelectUnit(illusion)
player:Attack(closestNeutral)
Sleep(500,hand.."attack")
end
elseif (illusion.activity == LuaEntityNPC.ACTIVITY_IDLE or illusion.activity == LuaEntityNPC.ACTIVITY_IDLE1) and closestCreep and SleepCheck(hand.."move") then
SelectUnit(illusion)
player:Move(averagecreeppos)
player:AttackMove(averagecreeppos,true)
Sleep(1000,hand.."attack")
Sleep(client.latency+illusion:GetTurnTime(closestCreep.position)*1000,hand.."latency")
end
elseif (illusion.activity == LuaEntityNPC.ACTIVITY_IDLE or illusion.activity == LuaEntityNPC.ACTIVITY_IDLE1) and closestNeutral and GetDistance2D(closestNeutral,illusion) < 500 then
SelectUnit(illusion)
player:Attack(closestNeutral)
player:AttackMove(closestNeutral.position,true)
Sleep(1000,hand.."attack")
elseif (illusion.activity == LuaEntityNPC.ACTIVITY_IDLE or illusion.activity == LuaEntityNPC.ACTIVITY_IDLE1) and closestCreep then
SelectUnit(illusion)
player:Move(averagecreeppos)
player:AttackMove(averagecreeppos,true)
Sleep(1000,hand.."attack")
Sleep(client.latency+illusion:GetTurnTime(closestCreep.position)*1000,hand.."latency")
elseif (illusion.activity == LuaEntityNPC.ACTIVITY_IDLE or illusion.activity == LuaEntityNPC.ACTIVITY_IDLE1) and closestNeutral then
SelectUnit(illusion)
player:Attack(closestNeutral)
player:AttackMove(closestNeutral.position,true)
Sleep(1000,hand.."attack")
Sleep(client.latency+illusion:GetTurnTime(closestNeutral.position)*1000,hand.."latency")
end
end
elseif cut then
local closestWave = getClosestWave(illusion)
if closestWave and ((closestWave.cutted and closestWave.cutted ~= hand) or closestWave.dead) then closestWave = getClosestWave(illusion) end
if SleepCheck(hand.."attack") then
if closestRacks then
SelectUnit(illusion)
player:Attack(closestRacks)
Sleep(1000,hand.."attack")
elseif dpos and closestWave and GetDistance2D(closestWave.position,illusion) < 500 and closestCreep and GetDistance2D(closestCreep,illusion) < 500 then
local pos = (illusion.position - dpos) * (GetDistance2D(illusion,dpos) + 5000) / GetDistance2D(illusion,dpos) + illusion.position
SelectUnit(illusion)
player:Move(pos)
Sleep(500,hand.."attack")
elseif closestTower then
if attackedbytower and (not closestallyCreep or GetDistance2D(closestallyCreep,closestTower) > closestTower.attackRange+500) and (closestWave and GetDistance2D(closestWave.position,illusion) < 500 and closestCreep and GetDistance2D(closestCreep,illusion) < 500) then
local pos = (illusion.position - closestTower.position) * (closestTower.attackRange+500) / GetDistance2D(illusion,closestTower) + illusion.position
SelectUnit(illusion)
player:Move(pos)
Sleep(500,hand.."attack")
elseif closestallyCreep and GetDistance2D(closestallyCreep,closestTower) < closestTower.attackRange+500 then
SelectUnit(illusion)
player:Attack(closestTower)
Sleep(500,hand.."attack")
end
elseif closeEnemy and closeEnemy.health < illusion.maxHealth and (not closestWave or GetDistance2D(closestWave.position,illusion) < 500) then
victims[i] = closeEnemy
SelectUnit(illusion)
player:Attack(closeEnemy)
Sleep(500,hand.."attack")
elseif closestWave and GetDistance2D(illusion,closestWave.position)/movespeed < time then
creepwaves[closestWave.id].cutted = hand
if GetDistance2D(illusion,closestWave.position) > 1000 then
SelectUnit(illusion)
player:Move(closestWave.position)
player:AttackMove(closestWave.position,true)
else
if averagecreeppos then averagecreeppos = averagecreeppos/creepscount end
if SleepCheck(hand.."asd") and SleepCheck("asaa") and closestCreep and illusion.recentDamage > 0 and GetDistance2D(closestWave.position,illusion) < 300 and (closestCreep.health > illusion.health or (creepscount*(closestCreep.health) > illusion.health)) then
if averagecreeppos then
local pos = (illusion.position - averagecreeppos) * (300) / GetDistance2D(illusion,averagecreeppos) + illusion.position
SelectUnit(illusion)
player:Move(pos)
player:Attack(closestCreep,true)
Sleep(500,hand.."attack")
Sleep(2000,"asaa")
Sleep(1000,hand.."asd")
end
elseif (illusion.activity == LuaEntityNPC.ACTIVITY_IDLE or illusion.activity == LuaEntityNPC.ACTIVITY_IDLE1) and illusion.recentDamage == 0 then
SelectUnit(illusion)
player:Move(averagecreeppos)
player:AttackMove(averagecreeppos,true)
end
end
Sleep(500,hand.."attack")
Sleep(client.latency+illusion:GetTurnTime(closestWave.position)*1000,hand.."latency")
elseif closestCreep then
SelectUnit(illusion)
player:Move(averagecreeppos)
player:AttackMove(averagecreeppos,true)
Sleep(1000,hand.."attack")
Sleep(client.latency+illusion:GetTurnTime(closestCreep.position)*1000,hand.."latency")
end
end
elseif farm then
--if not closestCreep then closestCreep = closestNeutral end
local selected = illusion
local camp = getClosestCamp(selected)
if not camp or ((camp.stacked and camp.stacked ~= hand) or camp.farmed or (not enemyjungle and camp.team ~= meTeam)) then camp = getClosestCamp(selected) end
if not camp then camp = getClosestCamp(selected,false,true) end
--print(camp)
if camp and not camp.farmed and (not camp.stacked or camp.stacked == hand) and (GetDistance2D(illusion,camp.position)/movespeed < time or GetDistance2D(illusion,camp.position) < 700) then
if illusion.health > 1000 or radiance then
JungleCamps[camp.id].stacked = hand
end
if (not closestNeutral or GetDistance2D(closestNeutral,camp.position) > 700) and SleepCheck(hand.."move") and GetDistance2D(camp.position,illusion) > 1000 then
SelectUnit(illusion)
player:Move(camp.position)
player:AttackMove(camp.position,true)
Sleep(1000,hand.."move")
end
if closestNeutral and SleepCheck(hand.."attack") and GetDistance2D(closestNeutral,camp.position) < 500 then
if averageneutralpos then averageneutralpos = averageneutralpos/neutralscount end
local front = SkillShot.InFront(closestNeutral, 500)
--print(GetDistance2D(closestNeutral,illusion), GetDistance2D(front,illusion) , closestNeutral.health, illusion.health)
if SleepCheck("asaa") and SleepCheck(hand.."asd") and GetDistance2D(closestNeutral,illusion) < 300 and illusion.recentDamage > 0 and not ranged and GetDistance2D(front,illusion) < GetDistance2D(front,closestNeutral) and closestNeutral.visible and (closestNeutral.health > illusion.health or (neutralscount*(closestNeutral.health) > illusion.health)) then
--print(illusion.recentDamage)
if averageneutralpos then
local pos = (illusion.position - averageneutralpos) * (300) / GetDistance2D(illusion,averageneutralpos) + illusion.position
SelectUnit(illusion)
player:Move(pos)
player:Attack(closestNeutral,true)
Sleep(500,hand.."attack")
Sleep(1000,hand.."asd")
Sleep(2000,"asaa")
end
elseif (illusion.activity == LuaEntityNPC.ACTIVITY_IDLE or illusion.activity == LuaEntityNPC.ACTIVITY_IDLE1) and illusion.recentDamage == 0 then
SelectUnit(illusion)
player:Attack(closestNeutral)
Sleep(500,hand.."attack")
end
end
elseif closestNeutral and SleepCheck(hand.."attack") and GetDistance2D(closestNeutral,illusion) < 500 then
SelectUnit(illusion)
player:Attack(closestNeutral)
Sleep(1000,hand.."attack")
elseif closestCreep and SleepCheck(hand.."attack") then
SelectUnit(illusion)
player:Attack(closestCreep)
Sleep(1000,hand.."attack")
Sleep(client.latency+illusion:GetTurnTime(closestCreep)*1000,hand.."latency")
end
elseif stack then
--Stacking
local selected = illusion
local camp = getClosestCamp(selected,true)
local creepscount = 0
if not camp or ((camp.stacked and camp.stacked ~= hand) or camp.farmed or camp.team ~= meTeam) then camp = getClosestCamp(selected,true) end
if camp and (not camp.stacked or camp.stacked == hand) and camp.team == meTeam then
JungleCamps[camp.id].stacked = hand
for i = 1, neutralsCount do
local creep = neutrals[i]
if creep.visible and creep.spawned and GetDistance2D(creep,selected) <= 1200 and creep.visible and GetDistance2D(creep,camp.position) < 300 then
creepscount = creepscount + 1
end
end
local stackDuration = 0
local moveTime = nil
if closestNeutral and GetDistance2D(closestNeutral,camp.position) > 500 then closestNeutral = nil end
if closestNeutral and closestNeutral.alive then
if creepscount > 6 then
stackDuration = mathmin((GetDistance2D(closestNeutral,camp.stackPosition)+(creepscount*75))/mathmin(closestNeutral.movespeed,movespeed), 7)
else
stackDuration = mathmin((GetDistance2D(closestNeutral,camp.stackPosition)+(creepscount*25))/mathmin(closestNeutral.movespeed,movespeed), 7)
end
if closestNeutral:IsRanged() and creepscount > 6 then
stackDuration = mathmin((GetDistance2D(closestNeutral,camp.stackPosition)+closestNeutral.attackRange+(creepscount*75))/mathmin(closestNeutral.movespeed,movespeed), 7)
elseif closestNeutral:IsRanged() then
stackDuration = mathmin((GetDistance2D(closestNeutral,camp.stackPosition)+closestNeutral.attackRange+(creepscount*25))/mathmin(closestNeutral.movespeed,movespeed), 7)
end
moveTime = 50 - (GetDistance2D(selected,camp.position)-150)/movespeed + selected:GetTurnTime(camp.stackPosition)
if stackDuration > 0 then
moveTime = 60 - stackDuration - (GetDistance2D(selected,camp.position)-150)/movespeed + selected:GetTurnTime(camp.stackPosition) - client.latency*0.001 - (100/Animations.maxCount)*0.001 + ((client.latency/1000)/(1 + (1 - 1/Animations.maxCount)))
end
end
if SleepCheck(hand.."stack") and SleepCheck(hand.."-move") then
if not moveTime or gameTime % 60 < moveTime then
if camp.farmed then
if GetDistance2D(selected,camp.stackPosition) > 50 then
SelectUnit(illusion)
player:Move(camp.stackPosition)
end
elseif GetDistance2D(selected,camp.waitPosition) > 50 then
SelectUnit(illusion)
player:Move(camp.waitPosition)
end
elseif (not closestNeutral or not closestNeutral.visible) then
if camp.farmed then
if GetDistance2D(selected,camp.stackPosition) > 50 then
SelectUnit(illusion)
player:Move(camp.stackPosition)
end
elseif GetDistance2D(selected,camp.position) > 50 then
SelectUnit(illusion)
player:Move(camp.position)
end
end
Sleep(1000,hand.."-move")
end
if moveTime and gameTime % 60 >= moveTime then
if closestNeutral and closestNeutral.alive then
if SleepCheck(hand.."-moveStack") and (gameTime % 60 > (60 - stackDuration) and gameTime % 60 < 57) and GetDistance2D(closestNeutral,selected) < 300 then
local pos = (camp.stackPosition - closestNeutral.position) * (GetDistance2D(camp.stackPosition,closestNeutral) + 500) / GetDistance2D(camp.stackPosition,closestNeutral) + camp.stackPosition
SelectUnit(illusion)
player:Move(pos)
Sleep((GetDistance2D(selected,pos)/movespeed)*1000,hand.."-moveStack")
Sleep((60 - (gameTime % 60))*1000,hand.."stack")
elseif SleepCheck(hand.."stack") and SleepCheck(hand.."-attack") then
local pos = (closestNeutral.position - selected.position) * (-200) / GetDistance2D(selected,closestNeutral) + closestNeutral.position
local pos2 = (camp.stackPosition - closestNeutral.position) * (GetDistance2D(camp.stackPosition,closestNeutral) + 500) / GetDistance2D(camp.stackPosition,closestNeutral) + camp.stackPosition
SelectUnit(illusion)
player:Move(pos)
if camp.id == 5 then pos2 = camp.stackPosition end
player:Move(pos2,true)
Sleep((60 - (gameTime % 60))*1000 + client.latency,hand.."-attack")
Sleep((60 - (gameTime % 60))*1000 + client.latency,hand.."-move")
--Sleep(((GetDistance2D(pos,camp.stackPosition)+GetDistance2D(pos,illusion))/movespeed)*1000+client.latency,hand.."stack")
--Sleep(((GetDistance2D(pos,camp.stackPosition)+GetDistance2D(pos,illusion))/movespeed)*1000+client.latency,hand.."-moveStack")
end
end
end
end
end
end
end
if (cut or auto or farm or stack) and illusionCount > 0 and prev[1] ~= player.selection[1] then SelectBack(prev) end
local useE = 0
local useanyway = false
local tablecount = #table
for i = 1, tablecount do
local data = table[i]
if data == true then useE = useE + 1 end
if me.health < 1000 and data == true then useanyway = true break end
if not octa and Q.cd < 12 and data == true then useanyway = true break
elseif octa and Q.cd < 2 and Q.cd > (client.latency/1000+0.1) and data == true then useanyway = true break end
end
--print(tablecount)
if SleepCheck("fuck") then
--print(client.mousePosition)
Sleep(1000,"fuck")
end

if ((not octa and Q.cd < 35) or (octa and Q.cd < 25)) and not me:IsChanneling() and not me:IsInvisible() and not stack and autoE and (useE == illusionCount or useanyway) and useE > 0 and SleepCheck("E") and E:CanBeCasted() and me:CanCast() then
me:CastAbility(E) Sleep(200,"E")
end
end

function getClosestCamp(ilu,stack,any)
local closest = nil
local tempJungleCamps = JungleCamps
for i = 1, #tempJungleCamps do
local camp = tempJungleCamps[i]
if (not closest or GetDistance2D(ilu.position,camp.position) < GetDistance2D(ilu.position,closest.position)) and (not camp.stacked or any) and not camp.farmed and not camp.ancients and (not stack or camp.team == ilu.team) and (not stack or (enemyjungle or camp.team == ilu.team)) then
closest = camp
end
if camp.stacked and camp.stacked == ilu.handle and (not stack or camp.team == ilu.team) and (not stack or (enemyjungle or camp.team == ilu.team)) then
closest = camp
break
end
end
return closest
end

function getClosestWave(ilu)
local creepwaves = creepwaves
local closest = nil
for i = 1, 6 do
local wave = creepwaves[i]
if (not closest or GetDistance2D(wave.position,ilu) < GetDistance2D(closest.position,ilu)) and not wave.cutted and not wave.dead and wave.position ~= Vector(0,0,0) then
closest = wave
end
if wave.cutted and wave.cutted == ilu.handle then
closest = wave
break
end
end
return closest
end

----Check Version
function Version()
local file = io.open(SCRIPT_PATH.."/NagaFarm_Version.lua", "r")
local ver = nil
if file then
ver = file:read("*number")
file:read("*line")
beta = file:read("*line")
info = file:read("*line")
file:close()
end
if ver then
local bcheck = ""..beta
if ver == currentVersion and bcheck == Beta then
outdated = false
return true,ver,beta,info
elseif ver > currentVersion or bcheck ~= Beta then
outdated = true
return false,ver,beta,info
end
else
versionSign.text = "You didn't download version info file from Moones' repository. Please do so to keep the script updated."
versionSign.color = -1
return false
end
end

function Load()

--VersionInfo
local up,ver,beta,info = Version()
if up then
if beta ~= "" then
versionSign.text = "Your version of Naga Farm Script is up-to-date! (v"..currentVersion.." "..Beta..")"
else
versionSign.text = "Your version of Naga Farm Script is up-to-date! (v"..currentVersion..")"
end
versionSign.color = 0x66FF33FF
if info then
infoSign.text = info
infoSign.visible = true
end
end
if outdated then
if beta ~= "" then
versionSign.text = "Your version of Naga Farm Script is OUTDATED (Yours: v"..currentVersion.." "..Beta.." Current: v"..ver.." "..beta.."), send me email to moones@email.cz to get current one!"
else
versionSign.text = "Your version of Naga Farm Script is OUTDATED (Yours: v"..currentVersion.." "..Beta.." Current: v"..ver.."), send me email to moones@email.cz to get current one!"
end
versionSign.color = 0xFF6600FF
if info then
infoSign.text = info
infoSign.visible = true
end
end
versionSign.visible = true

if PlayingGame() then
me = entityList:GetMyHero()
player = entityList:GetMyPlayer()
if not player or not me or me.classId ~= CDOTA_Unit_Hero_Naga_Siren then
versionSign.visible = false
infoSign.visible = false
script:Disable()
else
Q,E = me:GetAbility(1), me:GetAbility(3)
ERadius = E:GetSpecialData("radius")-50
topLaneData = {} midLaneData = {} botLaneData = {} dataUpdated = false
cut,stack,farm,auto,autoE,enemyjungle,radiance,octa,manta,travels = false,false,false,false,true,true,nil,nil,nil,nil
topLaneData = {}
midLaneData = {}
botLaneData = {}
victims = {}
dataSaved = false
local team = "Dire"
if me.team == LuaEntity.TEAM_DIRE then team = "Radiant" end
if not dataSaved then
local topLanedata = io.open(SCRIPT_PATH.."/CreepsPathData/"..team.."TopLane.txt", "r")
if topLanedata then
local count = 0
while true do
local time, posX, posY, posZ = topLanedata:read("*number", "*number", "*number", "*number")
if not time or not posX or not posY or not posZ then break end
count = count + 1
topLaneData[count] = {time, Vector(posX, posY, posZ)}
end
topLanedata:close()
else
print("Please download CreepsPathData in order to use this script!")
script:Disable()
end
local midLanedata = io.open(SCRIPT_PATH.."/CreepsPathData/"..team.."MidLane.txt", "r")
if midLanedata then
local count = 0
while true do
local time, posX, posY, posZ = midLanedata:read("*number", "*number", "*number", "*number")
if not time or not posX or not posY or not posZ then break end
count = count + 1
midLaneData[count] = {time, Vector(posX, posY, posZ)}
end
midLanedata:close()
end
local botLanedata = io.open(SCRIPT_PATH.."/CreepsPathData/"..team.."BotLane.txt", "r")
if botLanedata then
local count = 0
while true do
local time, posX, posY, posZ = botLanedata:read("*number", "*number", "*number", "*number")
if not time or not posX or not posY or not posZ then dataSaved = true break end
count = count + 1
botLaneData[count] = {time, Vector(posX, posY, posZ)}
end
botLanedata:close()
end
end

creepwaves[1].visible = false
creepwaves[3].visible = false
creepwaves[5].visible = false
creepwaves[2].visible = false
creepwaves[4].visible = false
creepwaves[6].visible = false

if HUD and (HUD:IsClosed() or HUD:IsMinimized()) then
HUD:Open()
end

JungleCamps = {
{position = Vector(-1131,-4044,127), stackPosition = Vector(-2750.94,-3517.86,128), waitPosition = Vector(-1401.69,-3791.52,128), team = 2, id = 1, farmed = false, lvlReq = 8, visible = false, visTime = 0, stacking = false, stacked = nil},
{position = Vector(-366,-2945,127), stackPosition = Vector(-534.219,-1795.27,128), waitPosition = Vector(-408,-2731,127), team = 2, id = 2, farmed = false, lvlReq = 3, visible = false, visTime = 0, stacking = false, stacked = nil},
{position = Vector(1606.45,-3433.36,256), stackPosition = Vector(1598.19,-5117.22,256), waitPosition = Vector(1541.87,-4265.38,256), team = 2, id = 3, farmed = false, lvlReq = 8, visible = false, visTime = 0, stacking = false, stacked = nil},
{position = Vector(3126,-3439,256), stackPosition = Vector(5284.49,-3922,256), waitPosition = Vector(3231,-3807,256), team = 2, id = 4, farmed = false, lvlReq = 3, visible = false, visTime = 0, stacking = false, stacked = nil},
{position = Vector(3031.03,-4480.06,256), stackPosition = Vector(3774.15,-6700.85,256), waitPosition = Vector(3030,-4975,256), team = 2, id = 5, farmed = false, lvlReq = 1, visible = false, visTime = 0, stacking = false, stacked = nil},
{position = Vector(-2991,191,256), stackPosition = Vector(-3351,-1798,205), waitPosition = Vector(-2684,-23,256), team = 2, id = 6, farmed = false, lvlReq = 12, visible = false, visTime = 0, ancients = true, stacking = false, stacked = nil},
{position = Vector(1167,3295,256), stackPosition = Vector(570.86,4515.96,256), waitPosition = Vector(1011,3656,256), team = 3, id = 7, farmed = false, lvlReq = 8, visible = false, visTime = 0, stacking = false, stacked = nil},
{position = Vector(-244,3629,256), stackPosition = Vector(236.481,5000.22,256), waitPosition = Vector(-523,4041,256), team = 3, id = 8, farmed = false, lvlReq = 3, visible = false, visTime = 0, stacking = false, stacked = nil},
{position = Vector(-1588,2697,127), stackPosition = Vector(-1302,3689.41,136.411), waitPosition = Vector(-1491,2986,127), team = 3, id = 9, farmed = false, lvlReq = 3, visible = false, visTime = 0, stacking = false, stacked = nil},
{position = Vector(-3157.74,4475.46,256), stackPosition = Vector(-3296.1,5508.48,256), waitPosition = Vector(-3086,4924,256), team = 3, id = 10, farmed = false, lvlReq = 1, visible = false, visTime = 0, stacking = false, stacked = nil},
{position = Vector(-4382,3612,256), stackPosition = Vector(-3026.54,3819.69,132.345), waitPosition = Vector(-3995,3984,256), team = 3, id = 11, farmed = false, lvlReq = 8, visible = false, visTime = 0, stacking = false, stacked = nil},
{position = Vector(4026,-709.943,128), stackPosition = Vector(2636,-1017,127), waitPosition = Vector(3583,-736,127), team = 3, id = 12, farmed = false, lvlReq = 12, visible = false, visTime = 0, ancients = true, stacking = false, stacked = nil}
}
reg = true
myId = me.classId
script:RegisterEvent(EVENT_FRAME, Main)
script:RegisterEvent(EVENT_KEY, Key)
script:UnregisterEvent(Load)
end
end
end

function Close()
if reg then
player,me,JungleCamps,enemyTeam,meTeam,reg,stack = nil,nil,{},nil,nil,false,false
if HUD then
HUD:Close()
end
script:UnregisterEvent(Main)
script:UnregisterEvent(Key)
script:RegisterEvent(EVENT_TICK, Load)
reg = false
end
end

script:RegisterEvent(EVENT_CLOSE, Close)
script:RegisterEvent(EVENT_TICK, Load)
