xPosition,yPosition = 220,5
myFont = drawMgr:CreateFont("Roshancheg","Arial",13,400)
statusText = drawMgr:CreateText(xPosition,yPosition,0xFFFFFFFF,"",myFont);
registered = false

function Frame( tick )
	if not client.connected or client.loading or client.console then
		return
	end
	
	local me = entityList:GetMyHero() if not me then return end
	
	if me.name ~= "npc_dota_hero_rattletrap" then
		script:Disable()
		return
	end	
	local cursor = client.mousePosition
	
	if cursor == nil then
		return
	end
	
	local distToCursor = MyGetDistance2D(cursor, me.position)
	if distToCursor > 10e30 then --Outside of window
		return
	end
	
	local printMe = string.format("Rocket: %02f s",distToCursor/1500.0)
	statusText.text = printMe	
end

function Close()
	script:UnregisterEvent(Frame)
	statusText.visible = false
	registered = false
	collectgarbage("collect")
end

function Load()
	if registered then return end
	script:RegisterEvent(EVENT_FRAME,Frame)
	statusText.visible = true
	registered = true
end

if client.connected and not client.loading then
	Load()
end

function MyGetDistance2D(a,b)
	if not b then b = entityList:GetMyHero() end
	if a.x == nil or a.y == nil then
	return GetDistance2D(a.position,b)
	elseif b.x == nil or b.y == nil then
	return GetDistance2D(a,b.position)
	else
	return math.sqrt(math.pow(a.x-b.x,2)+math.pow(a.y-b.y,2))
	end
end

script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_LOAD,Load)
