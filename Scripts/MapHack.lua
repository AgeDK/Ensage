-- Toggle key is M

require("libs.Utils")
require("libs.Res")
 
local play = false
local activated = true
local active = false
local hero = {}
local check = {}
local cour = nil
local testItem = true
 
function Main(tick)
        if client.console or client.paused then return end
 
        if activated then
        
			local me = entityList:GetMyHero()
			if not me then return end

			
			if SleepCheck("gl") then
				Sleep(100,"gl")
				local vrag = entityList:GetEntities({type=LuaEntity.TYPE_HERO,alive=true,illusion=false,team=5-me.team})
				for i,v in ipairs(vrag) do
					if v.visible then                                                      
						if not check[v.handle] then
							check[v.handle] = tick + 2000
						end
						for z = 1,#hero do
							if hero[z].img.visible and hero[z].classId == v.classId then
									hero[z].img.visible = false
									hero[z].line.visible = false
							end
						end
					elseif check[v.handle] and check[v.handle] < tick then
							check[v.handle] = nil
					end
				end
			end
 
			if SleepCheck() then                      
				local courer = entityList:FindEntities({classId = CDOTA_Unit_Courier,team = me.team,alive=true})[1]                    
				if courer and courer.flying and not courer.visibleToEnemy and courer.courState ~= LuaEntityCourier.STATE_DELIVER then                  
					if not active then
						enemy = entityList:GetEntities(function (v) return v.type==LuaEntity.TYPE_HERO and v.alive and not v.illusion and not v.visible and v.team==5-me.team and not check[v.handle] end)
						table.sort(enemy, function (a,b) return a.position.x < b.position.x end )
						if enemy[1] then
							--if not cour or not cour.hero or (courer.courState ~= 0) then      
								if courer.courState == LuaEntityCourier.STATE_IDLE then
									cour = courer:GetAbility(1)
								elseif courer.courState == LuaEntityCourier.STATE_B2BASE then
									cour = courer:GetAbility(1)
								elseif courer.courState == 2 then
									cour = courer:GetAbility(2)
								elseif courer.courState == LuaEntityCourier.STATE_DELIVER then
									cour = courer.courStateEntity
								else
									cour = courer:GetAbility(1)    
								end
							--end
							active = true
							local shop = client.shopOpen
							courer:Move(Vector(0,0,0)) courer:Stop()
							Open(shop)
							hero[1].state = true
							Sleep(50+client.latency)
							return
						else
							Sleep(5000)
							return
						end
					else
						for i = 1, #enemy do                                  
							local v = enemy[i]
							if hero[i].state then
								if not hero[i].rot then
									local shop = client.shopOpen
									courer:Follow(v) courer:Stop() Open(shop)
									hero[i].rot = courer.rotR
									Sleep(client.latency+125)
									return
								else
									if hero[i].rot ~= courer.rotR then
										hero[i].start = true
										hero[i].rot = courer.rotR
										return
									elseif hero[i].start then
										local vec = Vector2D(courer.position.x + 13000 * math.cos(courer.rotR), courer.position.y + 13000 * math.sin(courer.rotR))
										local minimap1 = MapToMinimap(courer.position.x,courer.position.y)
										local minimap2 = MapToMinimap(vec.x,vec.y)
										hero[i].img.x = minimap2.x - 10 hero[i].img.y = minimap2.y - 10
										hero[i].line:SetPosition(minimap1,minimap2)
										--hero[i].line.color = GetColor(v)
										hero[i].img.textureId = drawMgr:GetTextureId("NyanUI/miniheroes/translucent/"..v.name:gsub("npc_dota_hero_","").."_t75")
										hero[i].img.visible = true hero[i].line.visible = true                                                                
										hero[i].sleep = tick + 2500 hero[i].classId = v.classId
										hero[i].state = false hero[i].start = nil hero[i].rot = nil
										if enemy[i+1] then
											hero[i+1].state = true
											--Sleep(client.latency+100)
										else
											EndIt(courer)
											Sleep(5000)
										end
									else
										GenerateSideMessage(v.name:gsub("npc_dota_hero_",""))
										hero[i].state = false
										hero[i].start = nil
										hero[i].rot = nil
										if enemy[i+1] then
											hero[i+1].state = true
											--Sleep(client.latency+100)
										else
											EndIt(courer)
											Sleep(5000)
										end
									end    
								end
							end
						end
					end
				end
			else
				if SleepCheck("250") then
					for i = 1, 5 do
						if hero[i].sleep and hero[i].sleep < tick then
							hero[i].img.visible = false
							hero[i].line.visible = false
						end
					end
				Sleep(500,"250")
				end
			end
		elseif hero[1].img.visible then
			for i = 1, 5 do
				hero[i].img.visible = false
				hero[i].line.visible = false
			end
		end
 
        --LatSleep(150,"global")
end
function EndIt(courer)
	active = false
	local shop = client.shopOpen
	if cour then
		if cour.x then                                                                                        
				courer:Move(cour)
		elseif cour.ability then
				courer:CastAbility(cour)
		elseif cour.hero then
			for k,z in ipairs(courer.items) do
				if z.purchaser.classId == cour.classId then
					courer:GiveItem(cour,z,true)
				end
			end
			courer:CastAbility(courer:GetAbility(1),true)
			if GetDistance2D(cour,courer)/courer.movespeed < 3 then
				cour = nil
			end
		end
	end
	Open(shop)
end
 
function GenerateSideMessage(heroName)
        local test = sideMessage:CreateMessage(200,60)
        test:AddElement(drawMgr:CreateRect(10,10,72,40,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/heroes_horizontal/"..heroName)))
        test:AddElement(drawMgr:CreateRect(85,16,62,31,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/other/arrow_usual")))
        test:AddElement(drawMgr:CreateRect(150,11,40,40,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/spellicons/brewmaster_storm_wind_walk")))
end
 
function Key(msg,code)
        if not client.chat and msg == KEY_DOWN and code == string.byte("M") then
                activated = not activated
        end
end
 
function Open(ye)
        if ye then client:OpenShop(client.shopTypeOpen) end
end
 
function Load()
        if PlayingGame() then
                for i = 1, 5 do
                        if not hero[i] then
                                hero[i] = {}
                                hero[i].state = false
                                hero[i].img = drawMgr:CreateRect(0,0,16,16,0xffffffff)
                                hero[i].img.visible = false
                                hero[i].line = drawMgr:CreateLine(0,0,0,0,0xffffff70)
                                hero[i].line.visible = false
                        end
                end
                script:RegisterEvent(EVENT_TICK,Main)
                script:RegisterEvent(EVENT_KEY,Key)
                script:UnregisterEvent(Load)
        end
end
 
function GameClose()
        if play then
                hero = {}
                check = {}
                cour = nil
                active = false
                script:UnregisterEvent(Main)
                script:UnregisterEvent(Key)
                script:RegisterEvent(EVENT_TICK,Load)
                play = false
        end
end
 
script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)
