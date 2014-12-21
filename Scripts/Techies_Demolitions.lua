-- Useful infomation to plan your Techies strategies
-- By Zanko
-- Version 1.0 - 6th December 2014

require("libs.ScriptConfig")
require("libs.Utils")



config = ScriptConfig.new()
config:SetParameter("ShowMineRequired", true)
config:SetParameter("Active", "K", config.TYPE_HOTKEY)

config:Load()


local showMineRequired = config.showMineRequired

-------- Initialize Variables --------

local sleepTick = 0


local landMineDamageArray = {225, 300, 375, 450}
local remoteMineDamageArray = {300, 450, 600}
local suicideDamageArray = {500, 650, 850, 1150}
local landMineDamage = 0
local remoteMineDamage = 0
local ShowMineRequired = config.ShowMineRequired
local heroInfoPanel = {}
local upLandMine = false
local upRemoteMine = false

local screenResolution = client.screenSize
local screenAspectRatio = client.screenRatio

local drawFromTopRatio = 0.0481481481
local nextDrawRatioX = 0.034375
local nextDrawRatioY = 0.013
local iconSize = 8
local offsetX = 1.02
local offsetY = 1.02

local F10 = drawMgr:CreateFont("F10", "Arial", 8.5 * screenAspectRatio, 8.5 * screenAspectRatio)


function Tick( tick )

	if not client.connected or client.loading or client.console or tick < sleepTick then 
		return 
	end
	
	sleepTick = tick + 200 -- 4 Times a second
	
	me = entityList:GetMyHero()
	enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO})
	
	if not me or me.name ~= "npc_dota_hero_techies"  then

		return
	end
	
	local scepterCheck = me:FindItem("item_ultimate_scepter")
	
	--Obtain Techies' Land Mines Damage
	if me:GetAbility(1).level ~= 0 then
		upLandMine = true
		landMineDamage = landMineDamageArray[me:GetAbility(1).level]
	end
	
	--Obtain Techies' Remote Mines Damage
	if me:GetAbility(6).level ~= 0 then
		upRemoteMine = true
		if scepterCheck then
			remoteMineDamage = remoteMineDamageArray[me:GetAbility(6).level] + 150
		else 
			remoteMineDamage = remoteMineDamageArray[me:GetAbility(6).level]
		end
	end
	
	if me:GetAbility(3).level ~= 0 then
		upSuicide = true
		suicideDamage = suicideDamageArray[me:GetAbility(3).level]
	end
	
	if ShowMineRequired then
		CalculateTechiesInformation()
	end
end

function CalculateTechiesInformation()
	local xRatio = WhereToDraw()
	local onRadiant = IsRadiant()
	for i = 1, #enemies do
		local heroInfo = enemies[i]
		if not heroInfo.illusion then
			local uniqueIdentifier = heroInfo.handle
			local playerIconLocation = heroInfo.playerId
			if uniqueIdentifier ~= me.handle then
				if heroInfo.alive then
					if not heroInfoPanel[playerIconLocation] then 
					

						heroInfoPanel[playerIconLocation] = {}
						if onRadiant and playerIconLocation < 5 then
							heroInfoPanel[playerIconLocation].neededLandMine = drawMgr:CreateText(xRatio * screenResolution.x * 1.013 + nextDrawRatioX * screenResolution.x * playerIconLocation,
							                                                   screenResolution.y * drawFromTopRatio,
																			   -1,"",
																			   F10)
							heroInfoPanel[playerIconLocation].neededLandMine.visible = false

							heroInfoPanel[playerIconLocation].neededRemoteMine = drawMgr:CreateText(xRatio * screenResolution.x * 1.016 + nextDrawRatioX * screenResolution.x * playerIconLocation,
							                                                                        screenResolution.y * drawFromTopRatio + nextDrawRatioY * screenResolution.y,
																									-1,"",
																									F10)
							heroInfoPanel[playerIconLocation].neededRemoteMine.visible = false
							
							heroInfoPanel[playerIconLocation].canSuicide = drawMgr:CreateText(xRatio * screenResolution.x * 1.013 + nextDrawRatioX * screenResolution.x * playerIconLocation,
							                                                                        screenResolution.y * drawFromTopRatio + nextDrawRatioY * screenResolution.y * 2,
																									-1,"",
																									F10)
							heroInfoPanel[playerIconLocation].canSuicide.visible = false
						
						---Draw Land Mine Icons
							heroInfoPanel[playerIconLocation].landMineIcon = drawMgr:CreateRect(xRatio * screenResolution.x / offsetX + nextDrawRatioX * screenResolution.x * playerIconLocation,
							                               screenResolution.y * drawFromTopRatio / offsetY,
														   iconSize * screenAspectRatio,
							                               iconSize * screenAspectRatio,
														   0x00000095)
							heroInfoPanel[playerIconLocation].landMineIcon.textureId = drawMgr:GetTextureId("NyanUI/other/npc_dota_techies_land_mine")
							heroInfoPanel[playerIconLocation].landMineIcon.visible = true
							
							
						---Draw Remote Mine Icons
							heroInfoPanel[playerIconLocation].remoteMineIcon = drawMgr:CreateRect(xRatio * screenResolution.x / offsetX + nextDrawRatioX * screenResolution.x * playerIconLocation,
							                               screenResolution.y * drawFromTopRatio / offsetY + nextDrawRatioY * screenResolution.y,
														   iconSize * screenAspectRatio,
														   iconSize * screenAspectRatio,
														   0x00000095)
							heroInfoPanel[playerIconLocation].remoteMineIcon.textureId = drawMgr:GetTextureId("NyanUI/other/npc_dota_techies_remote_mine")
							heroInfoPanel[playerIconLocation].remoteMineIcon.visible = true
						
						---Draw Suicide Icons
							heroInfoPanel[playerIconLocation].suicideIcon = drawMgr:CreateRect(xRatio * screenResolution.x / offsetX + nextDrawRatioX * screenResolution.x * playerIconLocation,
							                               screenResolution.y * drawFromTopRatio / (offsetY * 0.95) + nextDrawRatioY * screenResolution.y * 2,
														   iconSize * screenAspectRatio,
														   iconSize * screenAspectRatio,
														   0x00000095)
							heroInfoPanel[playerIconLocation].suicideIcon.textureId = drawMgr:GetTextureId("NyanUI/spellicons/techies_suicide")
							heroInfoPanel[playerIconLocation].suicideIcon.visible = true
							
						--------------------------------------------------- DRAW ON RADIANT -------------------------------------------------------------------
						elseif not onRadiant and playerIconLocation > 4 then
						
							heroInfoPanel[playerIconLocation].neededLandMine = drawMgr:CreateText(xRatio * screenResolution.x + nextDrawRatioX * screenResolution.x * (playerIconLocation - 5 ),
							                                                                      screenResolution.y * drawFromTopRatio,
																								  -1,"",
																								  F10)
							heroInfoPanel[playerIconLocation].neededLandMine.visible = false
							
							heroInfoPanel[playerIconLocation].neededRemoteMine = drawMgr:CreateText(xRatio * screenResolution.x + nextDrawRatioX * screenResolution.x * (playerIconLocation - 5),
							                                                                        screenResolution.y * drawFromTopRatio + nextDrawRatioY * screenResolution.y,
																									-1,"",
																									F10)
							heroInfoPanel[playerIconLocation].neededRemoteMine.visible = false
							
							heroInfoPanel[playerIconLocation].canSuicide = drawMgr:CreateText(xRatio * screenResolution.x + nextDrawRatioX * screenResolution.x * (playerIconLocation - 5),
							                                                                        screenResolution.y * drawFromTopRatio + nextDrawRatioY * screenResolution.y * 2,
																									-1,"",
																									F10)
							heroInfoPanel[playerIconLocation].canSuicide.visible = false
							
			
							
						---Draw Land Mine Icons
						
							
							heroInfoPanel[playerIconLocation].landMineIcon = drawMgr:CreateRect(xRatio * screenResolution.x / offsetX + nextDrawRatioX * screenResolution.x * (playerIconLocation - 5), 
														   screenResolution.y * drawFromTopRatio / offsetY,
														   iconSize * screenAspectRatio,
														   iconSize * screenAspectRatio,
														   0x00000095)
							heroInfoPanel[playerIconLocation].landMineIcon.textureId = drawMgr:GetTextureId("NyanUI/other/npc_dota_techies_land_mine")
							heroInfoPanel[playerIconLocation].landMineIcon.visible = true
							
							
						---Draw Remote Mine Icons
							heroInfoPanel[playerIconLocation].remoteMineIcon = drawMgr:CreateRect(xRatio * screenResolution.x / offsetX + nextDrawRatioX * screenResolution.x * (playerIconLocation - 5),
							                               screenResolution.y * drawFromTopRatio / offsetY + nextDrawRatioY * screenResolution.y,
														   iconSize * screenAspectRatio,
														   iconSize * screenAspectRatio,
														   0x00000095)
							heroInfoPanel[playerIconLocation].remoteMineIcon.textureId = drawMgr:GetTextureId("NyanUI/other/npc_dota_techies_remote_mine")
							heroInfoPanel[playerIconLocation].remoteMineIcon.visible = true
						
						---Draw Suicide Icons
							heroInfoPanel[playerIconLocation].suicideIcon = drawMgr:CreateRect(xRatio * screenResolution.x / offsetX + nextDrawRatioX * screenResolution.x * (playerIconLocation - 5),
							                               screenResolution.y * drawFromTopRatio / (offsetY * 0.95) + nextDrawRatioY * screenResolution.y * 2,
														   iconSize * screenAspectRatio,
														   iconSize * screenAspectRatio,
														   0x00000095)
							heroInfoPanel[playerIconLocation].suicideIcon.textureId = drawMgr:GetTextureId("NyanUI/spellicons/techies_suicide")
							heroInfoPanel[playerIconLocation].suicideIcon.visible = true
							
						end
						--------------------------------------------------- DRAW ON RADIANT END ---------------------------------------------------------------
						
					end
				
					if upLandMine then
						local landMineDamageDeal = (1 - heroInfo.dmgResist) * landMineDamage
						local numberOfLandMineRequired = math.ceil(heroInfo.health / landMineDamageDeal)
						if onRadiant and playerIconLocation < 5 then
							heroInfoPanel[playerIconLocation].neededLandMine.text = tostring(numberOfLandMineRequired)
							heroInfoPanel[playerIconLocation].neededLandMine.visible = true
						elseif not onRadiant and playerIconLocation > 4 then
							heroInfoPanel[playerIconLocation].neededLandMine.text = tostring(numberOfLandMineRequired)
							heroInfoPanel[playerIconLocation].neededLandMine.visible = true
						end
					end
					
					if upRemoteMine then
						local remoteMineDamageDeal = (1 - heroInfo.magicDmgResist) * remoteMineDamage
						local numberOfRemoteMineRequired = math.ceil(heroInfo.health / remoteMineDamageDeal)
						if onRadiant and playerIconLocation < 5 then
							heroInfoPanel[playerIconLocation].neededRemoteMine.text = tostring(numberOfRemoteMineRequired)
							heroInfoPanel[playerIconLocation].neededRemoteMine.visible = true
						elseif not onRadiant and playerIconLocation > 4 then
							heroInfoPanel[playerIconLocation].neededRemoteMine.text = tostring(numberOfRemoteMineRequired)
							heroInfoPanel[playerIconLocation].neededRemoteMine.visible = true
							
						end
					end
					
					if upSuicide then
						local suicideDamageDeal = (1 - heroInfo.dmgResist	) * suicideDamage
						if onRadiant and playerIconLocation < 5 then
							if suicideDamageDeal > heroInfo.health then
								heroInfoPanel[playerIconLocation].canSuicide.text = "Yes"
								heroInfoPanel[playerIconLocation].canSuicide.visible = true
							else
								heroInfoPanel[playerIconLocation].canSuicide.text = "No"
								heroInfoPanel[playerIconLocation].canSuicide.visible = true
							end
						elseif not onRadiant and playerIconLocation > 4 then
							if suicideDamageDeal > heroInfo.health then
								heroInfoPanel[playerIconLocation].canSuicide.text = "Yes"
								heroInfoPanel[playerIconLocation].canSuicide.visible = true
							else
								heroInfoPanel[playerIconLocation].canSuicide.text = "No"
								heroInfoPanel[playerIconLocation].canSuicide.visible = true
							end
							
						end
					end
					
				end
			end
		end
	end

end


function WhereToDraw()
	local teamIndicator = me.team
	if teamIndicator == 2 then -- If I'm on Dire, Draw on Radiant	
		return 0.572
	elseif teamIndicator == 3 then -- If I'm on Radiant, Draw on Dire	
		return 0.287
	end
end

function IsRadiant()
	local teamIndicator = me.team
	if teamIndicator == 2 then -- If I'm on Radiant, true	
		return false
	elseif teamIndicator == 3 then -- If I'm not on Radiant, false
		return true
	end
end

function GameClose()
	sleepTick = 0
	landMineDamageArray = {}
	remoteMineDamageArray = {}
	suicideDamageArray = {}
	landMineDamage = 0
	remoteMineDamage = 0
	heroInfoPanel = {}
	upLandMine = false
	upRemoteMine = false
	drawFromTopRatio = 0
	nextDrawRatioX = 0
	nextDrawRatioY = 0
	iconSize = 0
	offsetX = 0
	offsetY = 0
	collectgarbage("collect")
end


script:RegisterEvent(EVENT_TICK,Tick)
script:RegisterEvent(EVENT_CLOSE,GameClose)

