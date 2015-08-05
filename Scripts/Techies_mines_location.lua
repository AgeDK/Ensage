--<<Techies Mine Placement Helper>>
-- // Credits atifaslam for going ingame and getting all the coordinates :)

--Blue Positions-Rare Spots – Greatly rewarding – Never Cleared
BluePositions = {
Vector(-5841,5649,256),
Vector(-2297,4815,256),
Vector(-3809,4724,256),
Vector(-5629,2890,134),
Vector(1411,4261,256),
Vector(1705,2558,127),
Vector(2419,3155,127),
Vector(-1210,680,-17),
Vector(-2936,-1030,256),
Vector(-4024,-224,256),
Vector(-4834,355,256),
Vector(-2314,-3605,127),
Vector(-1207,-2376,126),
Vector(-854,-2979,127),
Vector(398,-1534,127),
Vector(-502,-4723,256),
Vector(1554,-4929,256),
Vector(3392,-5480,256),
Vector(3649,-3987,256),
Vector(5437,-2840,179),
Vector(2399,-1252,127),
Vector(771,-1006,-16),
Vector(1727,51,127),
Vector(2007,398,127),
Vector(4951,969,256),
Vector(4734,324,256),
Vector(5991,-5829,256),
Vector(6346,-4705,256)
}

--Red Positions-Common Spots – Hardly rewarding – Mostly cleared
RedPositions = {
Vector(6883,-4374,256),
Vector(6885,-3846,256),
Vector(2321,-3267,255),
Vector(-2261,1769,-16),
Vector(-145,1709,256),
Vector(-6734,4678,256),
Vector(-6820,4059,256),
Vector(3001,-2487,-16)
}

--Orange Positions-Uncommon Spots – Greatly Rewarding – Difficult to clear
OrangePositions = {
Vector(5119,-4624,256),
Vector(5370,-3323,256),
Vector(822,-2529,256),
Vector(171,-2526,247),
Vector(3694,-719,127),
Vector(3637,1106,269),
Vector(1101,2124,256),
Vector(-1001,1298,127),
Vector(-652,2859,254),
Vector(-1213,3993,256),
Vector(-1755,3464,127),
Vector(-3291,3796,255),
Vector(-5575,3619,256),
Vector(-5613,4827,256),
Vector(-3004,1580,128),
Vector(-3689,1336,256),
Vector(-2061,917,116),
Vector(-2287,419,257),
Vector(-3441,-1688,247)
}

--Green Positions-Remote Mine Positions
GreenPositions = {
Vector(-6634,-3019,261),
Vector(-4379,-3860,273),
Vector(-3473,-6130,269),
Vector(-1737,-3018,127),
Vector(1118,-5044,256),
Vector(2358,-3923,256),
Vector(3851,-2014,0),
Vector(3351,-158,256),
Vector(-631,-207,-16),
Vector(-2633,-338,256),
Vector(-4410,4228,256),
Vector(110,2451,256),
Vector(-11,4319,256),
Vector(3189,5688,256),
Vector(3952,3488,265),
Vector(6255,2637,256)
}

--Purple Positions-Courier Snipe Locations //MAYBE


local Activated = true
local Blue = {}
local Red = {}
local Orange = {}
local Green = {}

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Techies then 
			script:Disable()
		else
			Activated = true
			AddEffects()
			ShowMenu()
			script:UnregisterEvent(Load)
		end
	end
end

function Close()
	collectgarbage("collect")
	if Activated then
		RemoveEffects()
		RemoveMenu()
		Activated = false
	end
end

function ShowMenu()
--Later
end

function RemoveMenu()
--Later
end

function AddEffects()
	for k,v in ipairs(BluePositions) do
		Blue[k] = drawMgr3D:CreateRect(v, Vector(0,0,0), Vector2D(0,0), Vector2D(50,50), -1, drawMgr:GetTextureId("NyanUI/other/TechiesBlue"))
		Blue[k].visible = true
	end
	for k,v in ipairs(OrangePositions) do
		Orange[k] = drawMgr3D:CreateRect(v, Vector(0,0,0), Vector2D(0,0), Vector2D(50,50), -1, drawMgr:GetTextureId("NyanUI/other/TechiesOrange"))
		Orange[k].visible = true
	end
	for k,v in ipairs(RedPositions) do
		Red[k] = drawMgr3D:CreateRect(v, Vector(0,0,0), Vector2D(0,0), Vector2D(50,50), -1, drawMgr:GetTextureId("NyanUI/other/TechiesRed"))
		Red[k].visible = true
	end
	for k,v in ipairs(GreenPositions) do
		Green[k] = drawMgr3D:CreateRect(v, Vector(0,0,0), Vector2D(0,0), Vector2D(50,50), -1, drawMgr:GetTextureId("NyanUI/other/TechiesGreen"))
		Green[k].visible = true
	end
end

function RemoveEffects()
	for k,v in ipairs(BluePositions) do
		Blue[k].visible = false
	end
	for k,v in ipairs(OrangePositions) do
		Orange[k].visible = false
	end
	for k,v in ipairs(RedPositions) do
		Red[k].visible = false
	end
	for k,v in ipairs(GreenPositions) do
		Green[k].visible = false
	end
	
	Blue = {}
	Red = {}
	Orange = {}
	Green = {}
end

script:RegisterEvent(EVENT_TICK, Load)
script:RegisterEvent(EVENT_CLOSE, Close)
