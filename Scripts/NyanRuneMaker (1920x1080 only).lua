local nLast = 0	
local runes = {}
runes[-2272] = drawMgr:CreateRect(104,901,16,16,-1) runes[-2272].visible = false 
runes[3008] = drawMgr:CreateRect(198,978,16,16,-1) runes[3008].visible = false 
  
function Main()
    if not client.connected or client.loading or client.console then return end
	local nRunes = entityList:FindEntities({classId=CDOTA_Item_Rune})
	if #nRunes ~= nLast then 
		runes[-2272].visible = false 
		runes[3008].visible = false 
	else
		return
	end

	for i,rune in ipairs(nRunes) do
		local runename = ""
			
		if rune.runeType == 0 then runename = "doubledamage" 
		elseif rune.runeType == 1 then runename = "haste" 
		elseif rune.runeType == 2 then runename = "illusion" 
		elseif rune.runeType == 3 then runename = "invis"
		elseif rune.runeType == 4 then runename = "regen"
		elseif rune.runeType == 5 then runename = "bounty"
		end
		
		runes[rune.position.x].textureId = drawMgr:GetTextureId("NyanUI/minirunes/translucent/"..runename.."_t75") 
		runes[rune.position.x].visible = true	
	end		
	nLast = #nRunes
end

function GameClose()
	nLast = 0
	runes = {}
end
 
script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Main)
