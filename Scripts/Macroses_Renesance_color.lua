require("libs.Utils")

local rec = {} 
local bag = {}
local rate = client.screenSize.x/1600 
local xx = 0 
local yy = 0 
local move = false 
local activate = true 

rec[1] = drawMgr:CreateRect(5*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/XY")) 
rec[2] = drawMgr:CreateRect(25*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/SRY")) 
rec[3] = drawMgr:CreateRect(45*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/g_TY")) 
rec[4] = drawMgr:CreateRect(65*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/NOW")) 
rec[5] = drawMgr:CreateRect(85*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/-BC")) 
rec[6] = drawMgr:CreateRect(105*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/or_IG")) 
rec[7] = drawMgr:CreateRect(125*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/PH")) 
rec[8] = drawMgr:CreateRect(145*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/R_T")) 
rec[9] = drawMgr:CreateRect(165*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/_P")) 
rec[10] = drawMgr:CreateRect(185*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/Go_Top")) 
rec[11] = drawMgr:CreateRect(205*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/P_T")) 
rec[12] = drawMgr:CreateRect(225*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/2Re_Top")) 
rec[13] = drawMgr:CreateRect(245*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/2Miss_Top")) 
rec[14] = drawMgr:CreateRect(265*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/Re_Top")) 
rec[15] = drawMgr:CreateRect(285*rate,60*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/Miss_Top")) 

rec[16] = drawMgr:CreateRect(5*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/FMM")) 
rec[17] = drawMgr:CreateRect(25*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/AD")) 
rec[18] = drawMgr:CreateRect(45*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/g_GJ")) 
rec[19] = drawMgr:CreateRect(65*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/NSW")) 
rec[20] = drawMgr:CreateRect(85*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/-BO")) 
rec[21] = drawMgr:CreateRect(105*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/or_G")) 
rec[22] = drawMgr:CreateRect(125*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/PHM")) 
rec[23] = drawMgr:CreateRect(145*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/R_C")) 
rec[24] = drawMgr:CreateRect(165*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/_W")) 
rec[25] = drawMgr:CreateRect(185*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/Go_Mid")) 
rec[26] = drawMgr:CreateRect(205*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/P_M")) 
rec[27] = drawMgr:CreateRect(225*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/2Re_Mid")) 
rec[28] = drawMgr:CreateRect(245*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/2Miss_Mid")) 
rec[29] = drawMgr:CreateRect(265*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/Re_Mid")) 
rec[30] = drawMgr:CreateRect(285*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/Miss_Mid")) 

rec[31] = drawMgr:CreateRect(285*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/JS")) 
rec[32] = drawMgr:CreateRect(285*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/AE")) 
rec[33] = drawMgr:CreateRect(285*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/g_BRB")) 
rec[34] = drawMgr:CreateRect(285*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/NS")) 
rec[35] = drawMgr:CreateRect(285*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/-DGU")) 
rec[36] = drawMgr:CreateRect(285*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/or_R")) 
rec[37] = drawMgr:CreateRect(285*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/PGM")) 
rec[38] = drawMgr:CreateRect(285*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/R_B")) 
rec[39] = drawMgr:CreateRect(285*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/_D")) 
rec[40] = drawMgr:CreateRect(285*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/Go_Bot")) 
rec[41] = drawMgr:CreateRect(285*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/P_B")) 
rec[42] = drawMgr:CreateRect(285*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/2Re_Bot")) 
rec[43] = drawMgr:CreateRect(285*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/2Miss_Bot")) 
rec[44] = drawMgr:CreateRect(285*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/Re_Bot")) 
rec[45] = drawMgr:CreateRect(285*rate,80*rate,20*rate,20*rate,0x000000FF,drawMgr:GetTextureId("NyanUI/macro/Miss_Bot")) 

bg = drawMgr:CreateRect(5*rate,60*rate,300*rate,60*rate,0x0000070) bg.visible = false

for i = 1, #rec do 
	rec[i].visible = false 
end 

function Tick(tick)  
	if SleepCheck() then	
		if move then 
			xx = client.mouseScreenPosition.x - 5*rate - 25 yy = client.mouseScreenPosition.y - 60*rate - 12 
			Clear()               
		end
		if activate then 
			if IsMouseOn(bg) then
				for i = 1,#rec do
					if IsMouseOn(rec[i]) then
						bag[i].visible = false
					elseif not bag[i].visible then
						bag[i].visible = true
					end
				end
			end
		end
		Sleep(100)
	end	
		
end 

function Key(msg,code)              

	if client.chat then return end 

	if msg == LBUTTON_DOWN then -- Left mouse 
	
		if activate and IsMouseOn(bg) then
			if IsMouseOn(rec[1]) then              
				 move = not move   
				 SaveGUIConfig() 
            elseif IsMouseOn(rec[2]) then
				client:ExecuteCmd("chatwheel_say 63")
				client:ExecuteCmd("chatwheel_say 68")
			elseif IsMouseOn(rec[3]) then
				client:ExecuteCmd("chatwheel_say 62")
				client:ExecuteCmd("say_team Thanks!")
			elseif IsMouseOn(rec[4]) then
				client:ExecuteCmd("chatwheel_say 3") -- Купите Варды
			elseif IsMouseOn(rec[5]) then
				client:ExecuteCmd("chatwheel_say 1")  
			elseif IsMouseOn(rec[6]) then
				client:ExecuteCmd("chatwheel_say 35")  -- Go Gank
			elseif IsMouseOn(rec[7]) then
				client:ExecuteCmd("chatwheel_say 5")  -- Help
			elseif IsMouseOn(rec[8]) then
				client:ExecuteCmd("chatwheel_say 84")   --  Top Rune
			elseif IsMouseOn(rec[9]) then
				client:ExecuteCmd("chatwheel_say 56")
			elseif IsMouseOn(rec[10]) then
				client:ExecuteCmd("say_team Я иду на Верхнюю Линию!")
			elseif IsMouseOn(rec[11]) then
				client:ExecuteCmd("say_team Пожалуйста давайте ПРОПУШИМ их Верхнюю Линию!")
			elseif IsMouseOn(rec[12]) then
				client:ExecuteCmd("say_team REturned 2 to TOP lane!")		
			elseif IsMouseOn(rec[13]) then
				client:ExecuteCmd("say_team 2 MISSing from the TOP lane!")	
			elseif IsMouseOn(rec[14]) then
				client:ExecuteCmd("say_team REturned 1 to TOP lane!")		
			elseif IsMouseOn(rec[15]) then
				client:ExecuteCmd("say_team 1 MISSing from the TOP lane!")
				
			elseif IsMouseOn(rec[16]) then	
			    client:ExecuteCmd("say Снова порван твой пердак, так как ТЫ поганый РАК")
			elseif IsMouseOn(rec[17]) then
				client:ExecuteCmd("dota_player_units_auto_attack 0")
				client:ExecuteCmd("say_team My AutoAttack Disabled")
			elseif IsMouseOn(rec[18]) then
				client:ExecuteCmd("say Отлично Сыграно!")
			elseif IsMouseOn(rec[19]) then
				client:ExecuteCmd("chatwheel_say 45")
				client:ExecuteCmd("chatwheel_say 41")
			elseif IsMouseOn(rec[20]) then
				client:ExecuteCmd("chatwheel_say 2")  -- Назад
			elseif IsMouseOn(rec[21]) then
				client:ExecuteCmd("chatwheel_say 59")
			elseif IsMouseOn(rec[22]) then
				client:ExecuteCmd("chatwheel_say 24")  -- Полечить
			elseif IsMouseOn(rec[23]) then
				client:ExecuteCmd("chatwheel_say 58")  -- Check Runes
			elseif IsMouseOn(rec[24]) then
				client:ExecuteCmd("chatwheel_say 21")
				client:ExecuteCmd("chatwheel_say 55")
			elseif IsMouseOn(rec[25]) then
				client:ExecuteCmd("say_team Я иду на Центральную Линию!")
			elseif IsMouseOn(rec[26]) then
				client:ExecuteCmd("say_team Пожалуйста давайте ПРОПУШИМ их Центральную Линию!")		
			elseif IsMouseOn(rec[27]) then
				client:ExecuteCmd("say_team REturned 2 to MID lane!")	
			elseif IsMouseOn(rec[28]) then
				client:ExecuteCmd("say_team 2 MISSing from the MID lane!")		
			elseif IsMouseOn(rec[29]) then
				client:ExecuteCmd("say_team REturned 1 to MID lane!")
			elseif IsMouseOn(rec[30]) then
				client:ExecuteCmd("say_team 1 MISSing from the MID lane!")
				
			elseif IsMouseOn(rec[31]) then	
			elseif IsMouseOn(rec[32]) then
				client:ExecuteCmd("dota_player_units_auto_attack 1")
				client:ExecuteCmd("say_team My AutoAttack Enabled")
			elseif IsMouseOn(rec[33]) then
				client:ExecuteCmd("chatwheel_say 19")
			elseif IsMouseOn(rec[34]) then
				client:ExecuteCmd("say_team Пожалуйста дай мне ЩИТ!")
			elseif IsMouseOn(rec[35]) then
				client:ExecuteCmd("chatwheel_say 15")     -- Не сдавайтесь
				client:ExecuteCmd("chatwheel_say 64")
			elseif IsMouseOn(rec[36]) then
				client:ExecuteCmd("chatwheel_say 53")
		    client:ExecuteCmd("say_team Ребята, давайте Убьём Рошана!")
			elseif IsMouseOn(rec[37]) then
				client:ExecuteCmd("chatwheel_say 26")  -- Мана
			elseif IsMouseOn(rec[38]) then
				client:ExecuteCmd("chatwheel_say 83")
			elseif IsMouseOn(rec[39]) then
				client:ExecuteCmd("chatwheel_say 70")
			elseif IsMouseOn(rec[40]) then
				client:ExecuteCmd("say_team Я иду на Нижнюю Линию!")
			elseif IsMouseOn(rec[41]) then
				client:ExecuteCmd("say_team Пожалуйста давайте ПРОПУШИМ их Нижнюю Линию!")		
			elseif IsMouseOn(rec[42]) then
				client:ExecuteCmd("say_team REturned 2 to BOT lane!")	
			elseif IsMouseOn(rec[43]) then
				client:ExecuteCmd("say_team 2 MISSing from the BOT lane!")		
			elseif IsMouseOn(rec[44]) then
				client:ExecuteCmd("say_team REturned 1 to BOT lane!")
			elseif IsMouseOn(rec[45]) then
				client:ExecuteCmd("say_team 1 MISSing from the BOT lane!")		          
			end	
		end
		if IsMouseOn(rec[31]) then 
			for i = 1,#rec do 
				if i ~= 31 then
					rec[i].visible = not rec[i].visible
					bag[i].visible = not bag[i].visible
				end
			end 
			activate = not activate 
		end
		
	end

end 

function IsMouseOn(obj) 
	local mx = client.mouseScreenPosition.x 
	local my = client.mouseScreenPosition.y 
	return mx > obj.x and mx <= obj.x + obj.w and my > obj.y and my <= obj.y + obj.h 
end 

function SaveGUIConfig() 
	local file = io.open(SCRIPT_PATH.."/libs/macroConfig.txt", "w+") 
	if file then 
		file:write(xx.."\n"..yy) 
		file:close() 
	end 
end 
                           
function LoadGUIConfig() 
	local file = io.open(SCRIPT_PATH.."/libs/macroConfig.txt", "r") 
	if file then 
		xx, yy = file:read("*number", "*number") 
		file:close()                
	end 
	if not xx then              
		xx = 0 yy = 0 
	end 
end 

function Clear() 
	bg.x = 25*rate + xx 
	bg.y = 60*rate + yy 
	for i = 1,#rec do 
		if i < 16 then 
			rec[i].x = 25*rate+20*(i-1)*rate + xx
			rec[i].y = 60*rate + yy
			bag[i].x = 25*rate+20*(i-1)*rate + xx
			bag[i].y = 60*rate + yy
	   elseif i < 31 then 
			rec[i].x = 25*rate+20*(i-16)*rate + xx
			rec[i].y = 80*rate + yy
			bag[i].x = 25*rate+20*(i-16)*rate + xx
			bag[i].y = 80*rate + yy
	   else 
			rec[i].x = 25*rate+20*(i-31)*rate + xx
			rec[i].y = 100*rate + yy
			bag[i].x = 25*rate+20*(i-31)*rate + xx
			bag[i].y = 100*rate + yy
	   end 
	end 
end 

function Load() 
	if PlayingGame() then 
		LoadGUIConfig() 
		bg.x = 25*rate + xx 
		bg.y = 60*rate + yy
		for i = 1,#rec do			 
			if i < 16 then 
				bag[i] = drawMgr:CreateRect(25*rate+20*(i-1)*rate + xx,60*rate + yy,21*rate,21*rate,0x0000080)
				rec[i].x = 25*rate+20*(i-1)*rate + xx 
				rec[i].y = 60*rate + yy                 
			elseif i < 31 then 
				bag[i] = drawMgr:CreateRect(25*rate+20*(i-16)*rate + xx,80*rate + yy ,21*rate,21*rate,0x0000080)
				rec[i].x = 25*rate+20*(i-16)*rate + xx 
				rec[i].y = 80*rate + yy              
			else 
				bag[i] = drawMgr:CreateRect(25*rate+20*(i-31)*rate + xx,100*rate + yy,21*rate,21*rate,0x0000080)
				rec[i].x = 25*rate+20*(i-31)*rate + xx 
				rec[i].y = 100*rate + yy 
			end 
			rec[i].visible = true 
		end
		play = true 
		script:RegisterEvent(EVENT_KEY,Key) 
		script:RegisterEvent(EVENT_TICK,Tick) 
		script:UnregisterEvent(Load) 
	end 
end 

function GameClose() 
	if play then 
		for i = 1,#rec do              
			rec[i].visible = false 
		end       
		bag = {}
		move = false 
		activate = true 
		script:UnregisterEvent(Key) 
		script:UnregisterEvent(Tick) 
		script:RegisterEvent(EVENT_TICK,Load) 
		play = false 
	end 
end 

script:RegisterEvent(EVENT_TICK,Load) 
script:RegisterEvent(EVENT_CLOSE,GameClose)
