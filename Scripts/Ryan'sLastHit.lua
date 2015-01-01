--[[
		Info
		Here
--]]

-- Libs --

require("libs.HeroInfo")

-- Config Variables --

-- You can find Key Codes here: http://goo.gl/23GHw --

local lastHitKey = 0xA0 -- Space Key. Key Code: '0xA0'.
local denyKey = 0x43 -- C Key. Key Code: '0x43'.
local lastHitAndDenyKey = 0x20 -- Space Bar. Key Code: '0x20'.

-- Global Variables --

local injectedMidMatch = true

local myHero = nil
local heroAbilities = nil
local creepTable = {}
local drawTable = {}

local isAttacking = false

local myAttackTickTable = {}
myAttackTickTable.attackRateTick = 0

-- Modifier Tables --

turnRateModifiers = {

	modifier_batrider_sticky_napalm = .70,
	modifier_medusa_stone_gaze_slow = .50

}

armorTypeModifiers = { 
	
	Normal = {Unarmored = 1.00, Light = 1.00, Medium = 1.50, Heavy = 1.25, Fortified = 0.70, Hero = 0.75},
	Pierce = {Unarmored = 1.50, Light = 2.00, Medium = 0.75, Heavy = 0.75, Fortified = 0.35, Hero = 0.50},
	Siege = {Unarmored = 1.00, Light = 1.00, Medium = 0.50, Heavy = 1.25, Fortified = 1.50, Hero = 0.75},
	Chaos = {Unarmored = 1.00, Light = 1.00, Medium = 1.00, Heavy = 1.00, Fortified = 0.40, Hero = 1.00},
	Hero = {Unarmored = 1.00, Light = 1.00, Medium = 1.00, Heavy = 1.00, Fortified = 0.50, Hero = 1.00},
	Magic = {Unarmored = 1.00, Light = 1.00, Medium = 1.00, Heavy = 1.00, Fortified = 1.00, Hero = 0.75}

}

-- Classes --

class 'Hero'

function Hero:__init(heroEntity)

	self.heroEntity = heroEntity

	local name = self.heroEntity.name:gsub(" ", "_")

	if not heroInfo[name] then
		return nil
	end

	if not heroInfo[name].projectileSpeed then
		self.isRanged = false
	else
		self.isRanged = true
		self.projectileSpeed = heroInfo[name].projectileSpeed
	end

	self.attackType = "Hero"
	self.armorType = "Hero"
	self.baseAttackRate = heroInfo[name].attackRate
	self.baseAttackPoint = heroInfo[name].attackPoint
	self.aggroRange = 1000
	self.baseTurnRate = heroInfo[name].turnRate

end

function Hero:Update()

	self:GetModifiers()

	self.attackRate = self:GetAttackRate()
	self.attackPoint = self:GetAttackPoint()
	self.attackRange = self:GetAttackRange()
	self.movementSpeed = self:GetMovementSpeed()
	self.turnRate = self:GetTurnRate()

end

function Hero:GetTurnRate()

	if self.modifierList then

		for modifierName, modifierPercent in pairs(turnRateModifiers) do
			if self.modifierList[modifierName] then
				return (1 - modifierPercent) * self.baseTurnRate
			end
		end

	end

	return self.baseTurnRate

end

function Hero:GetMovementSpeed()

	return self.heroEntity.moveSpeed

end

function Hero:GetAttackRange()

	return self.heroEntity.attackRange

end

function Hero:GetAttackPoint()

	return self.baseAttackPoint / (1 + (self.heroEntity.attackSpeed-100) / 100)

end

function Hero:GetAttackRate()

	return self.baseAttackRate / (1 + (self.heroEntity.attackSpeed-100) / 100)

end

function Hero:GetModifiers()

        local modifierCount = self.heroEntity.modifierCount
        if modifierCount == 0 then
                self.modifierList = nil
                return
        end

        self.modifierList = {}
        for i = 1, modifierCount do
                local name = self.heroEntity:GetModifierName(i)
                if name then
                        self.modifierList[name] = true
                end
        end

end

class 'Creep'

function Creep:__init(creepEntity)

	self.creepEntity = creepEntity
	self.HP = {}

	if self.creepEntity.name == "Creep Siege" then
		self.creepType = "Siege Creep"
		self.attackType = "Siege"
		self.armorType = "Fortified"
		self.isRanged = true
		self.baseAttackPoint = 0.7
		self.baseAttackRate = 2.7
		self.attackRange = creepEntity.attackRange + 25
		self.projectileSpeed = 1100
	elseif self.creepEntity.name == "Creep Lane" and (self.creepEntity.armor == 0 or self.creepEntity.armor == 1) then
		self.creepType = "Ranged Creep"
		self.attackType = "Pierce"
		self.armorType = "Unarmored"
		self.isRanged = true
		self.baseAttackPoint = 0.5
		self.baseAttackRate = 1
		self.attackRange = creepEntity.attackRange + 25
		self.projectileSpeed = 900
	elseif self.creepEntity.name == "Creep Lane" and (self.creepEntity.armor == 2 or self.creepEntity.armor == 3) then
		self.creepType = "Melee Creep"
		self.attackType = "Normal"
		self.armorType = "Unarmored"
		self.isRanged = false
		self.baseAttackPoint = 0.467
		self.baseAttackRate = 1
		self.attackRange = creepEntity.attackRange + 25
	end

	self.isKillable = false
	self.possibleNextAttackTicks = {}
	self.nextAttackTicks = {}

end

function Creep:GetTimeToHealth(health)

	numItems = 0
	for k,v in pairs(self.nextAttackTicks) do
		numItems = numItems + 1
	end

	if numItems > 0 then

		local sortedTable = { }
		for k, v in pairs(self.nextAttackTicks) do table.insert(sortedTable, v) end

		table.sort(sortedTable, function(a,b) return a[2]<b[2] end)
		
		local totalDamage = 0

		for i = 0, 2 do
			for _, nextAttackTickTable in ipairs(sortedTable) do

				if nextAttackTickTable[2] > GetTick() then
					totalDamage = totalDamage + (math.floor((nextAttackTickTable[1].creepEntity.damageMin * armorTypeModifiers[nextAttackTickTable[1].attackType][self.armorType]) * (1 - self.creepEntity.dmgResist))-4)

					if (self.creepEntity.health - totalDamage) <= health then
						return nextAttackTickTable[2] + (nextAttackTickTable[4] * i)
					end
				end

			end
		end
	end

	return nil

end

function Creep:Update()

	self.attackRate = self:GetAttackRate()

	self:UpdateHealth()

	for k, nextAttackTickTable in pairs(self.nextAttackTicks) do
		if (GetTick() >= nextAttackTickTable[3]-25) then
			self.nextAttackTicks[k] = nil
		end
	end

	self:MapDamageSources()

end

function Creep:GetAttackRate()

	return self.baseAttackRate / (1 + (self.creepEntity.attackSpeed-100) / 100)

end

function Creep:MapDamageSources()

	-- Mapping by Angles --

	for creepHandle, creepClass in pairs(creepTable) do
		if creepClass.baseAttackRate ~= nil and self.creepEntity.team ~= creepClass.creepEntity.team and creepClass.creepEntity.alive and GetDistance2D(self.creepEntity, creepClass.creepEntity) <= creepClass.attackRange then
			if math.abs(FindAngleR(creepClass.creepEntity) - math.rad(FindAngleBetween(creepClass.creepEntity, self.creepEntity))) < 0.015 then
				if not self.nextAttackTicks[creepClass.creepEntity.handle] then

					local nextAttackTick = creepClass.baseAttackRate*1000

					local timeToDamageHit = (((creepClass.projectileSpeed) and ((GetDistance2D(creepClass.creepEntity, self.creepEntity)/creepClass.projectileSpeed)*1000)) or 0) + GetTick() + creepClass.baseAttackPoint*1000

					--table.insert(drawTable, {self.creepEntity, {creepClass.creepEntity, timeToDamageHit}, 500})

					self.nextAttackTicks[creepClass.creepEntity.handle] = {creepClass, timeToDamageHit, GetTick() + nextAttackTick, nextAttackTick}
				
				end
			end
		end
	end

end

function Creep:UpdateHealth()

	self.HP.previous = self.HP.current or 0
	self.HP.current = self.creepEntity.health
	
end

-- Functions --

function DrawPixel(x, y, c)

	drawManager:DrawRect(x,y,1,1,c)

end

function DrawLine(x1, y1, x2, y2, c)

	local dx = x2 - x1
	local dy = y2 - y1

	if x1 <= x2 then 
		while x1 <= x2 do
			DrawPixel(x1, math.ceil(y2 - ((x2 - x1) * (dy / dx))), c)
			x1 = x1 + 1
		end
	elseif x1 >= x2 then
		while x1 >= x2 do
			DrawPixel(x1, math.ceil(y2 + ((x1 - x2) * (dy / dx))), c)
			x1 = x1 - 1
		end
	end

end

function PlayingGame()

	if not engineClient.ingame or engineClient.console then
		return false
	else
		return true
	end

end

function OnLoad()

	if #entityList:FindEntities({type=TYPE_HERO}) == 0 then
		heroSelect = true
		injectedMidMatch = false
	elseif injectedMidMatch == true then
		injectedMidMatch = false
		return true
	end
	
	if #entityList:FindEntities({type=TYPE_HERO}) == #entityList:FindEntities({classId=445}) and heroSelect == true then
		heroSelect = false
		return true
	end
	
	return false

end

function MoveToMouse()

	Move(engineClient.mousePosition)

end

function hasQuellingBlade()

	for i = 1, 6 do
		if me:HasItem(i) then
			local item = me:GetItem(i)
			if item and (item.name == "item_quelling_blade") then
				return true
			end
		end
	end

	return false

end

function FindAngleR(entity)

	if entity.rotR < 0 then

		return math.abs(entity.rotR)

	else

		return 2 * math.pi - entity.rotR

	end

end

function FindAngleBetween(first, second)

	xAngle = math.deg(math.atan(math.abs(second.x - first.x)/math.abs(second.y - first.y)))

	if first.x <= second.x and first.y >= second.y then

		return 90 - xAngle

	elseif first.x >= second.x and first.y >= second.y then

		return xAngle + 90

	elseif first.x >= second.x and first.y <= second.y then

		return 90 - xAngle + 180

	elseif first.x <= second.x and first.y <= second.y then

		return xAngle + 90 + 180

	end

	return nil

end

function GetDistance2D(a, b)

	return math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2))

end

function FindHeroAbilities()

	local heroTable = entityList:FindEntities({type=TYPE_HERO})
	for _, eHero in ipairs(heroTable) do
		local i = 1
		while eHero:GetAbility(i) ~= nil and eHero:GetAbility(i).name ~= nil do
			heroAbilities[eHero:GetAbility(i).name] = eHero:GetAbility(i)
			i = i + 1
		end
	end

end

function UpdateHeroes()

	myHero:Update()

	if myAttackTickTable.attackPointTick and GetTick() > myAttackTickTable.attackPointTick then

		isAttacking = false
		myAttackTickTable.attackPointTick = nil

	end


end

function UpdateCreeps()

	local entities = entityList:FindEntities({alive=true, visible=true, distance={me, myHero.aggroRange}})
	for _, dEntity in ipairs(entities) do
		if ((dEntity.name == "Creep Lane" and (dEntity.armor >= 0 or dEntity.armor <= 3)) or (dEntity.name == "Creep Siege")) and not creepTable[dEntity.handle] then
			creepTable[dEntity.handle] = Creep(dEntity)
		end
	end

	for creepHandle, creepClass in pairs(creepTable) do

		if not creepClass.creepEntity.alive or GetDistance2D(me, creepClass.creepEntity) > myHero.aggroRange then
			creepTable[creepHandle] = nil
		else

			creepClass:Update()

		end

	end

end

function CheckForLastHit()

	for creepHandle, creepClass in pairs(creepTable) do

		if (GetTick() >= myAttackTickTable.attackRateTick) and (((IsKeyDown(lastHitKey) or IsKeyDown(lastHitAndDenyKey)) and me.team ~= creepClass.creepEntity.team) or ((IsKeyDown(denyKey) or IsKeyDown(lastHitAndDenyKey)) and me.team == creepClass.creepEntity.team and creepClass.creepEntity.health < creepClass.creepEntity.maxHealth*0.50)) then
			
			local heroDmg = (math.floor(((me.damageMin+me.damageBonus) * armorTypeModifiers["Hero"][creepClass.armorType]) * (1 - creepClass.creepEntity.dmgResist))-4)
			local timeToHealth = creepClass:GetTimeToHealth(heroDmg)

			--print("TimeToHealth "..heroDmg..": "..timeToHealth - GetTick())

			local hasQuellingBlade = hasQuellingBlade()
					
			if myHero.isRanged then

				if hasQuellingBlade then

					heroDmg = heroDmg * 1.12

				end

				if heroDmg >= creepClass.creepEntity.health or (timeToHealth and timeToHealth <= (GetTick() + myHero.attackPoint*1000 + (GetDistance2D(me, creepClass.creepEntity)/myHero.projectileSpeed)*1000 + (math.max(math.abs(FindAngleR(me) - math.rad(FindAngleBetween(me, creepClass.creepEntity))) - 0.69, 0)/(myHero.turnRate*(1/0.03)))*1000 + (math.max((GetDistance2D(me, creepClass.creepEntity) - myHero.attackRange), 0)/myHero.movementSpeed)*1000)) then

					--print("Total Time Till Hit: "..(myHero.attackPoint*1000 + (GetDistance2D(me, creepClass.creepEntity)/myHero.projectileSpeed)*1000 + (math.max(math.abs(FindAngleR(me) - math.rad(FindAngleBetween(me, creepClass.creepEntity))) - 0.69, 0)/(myHero.turnRate*(1/0.03)))*1000 + (math.max((GetDistance2D(me, creepClass.creepEntity) - myHero.attackRange), 0)/myHero.movementSpeed)*1000))
					--print("Distance Time: "..((math.max((GetDistance2D(me, creepClass.creepEntity) - myHero.attackRange), 0)/myHero.movementSpeed)*1000))
					--print("Projectile Time: "..((GetDistance2D(me, creepClass.creepEntity)/myHero.projectileSpeed)*1000))
					--print("Attack Point Time: "..(myHero.attackPoint*1000))
					--print("Turning Time: "..((math.max(math.abs(FindAngleR(me) - math.rad(FindAngleBetween(me, creepClass.creepEntity))) - 0.69, 0)/(myHero.turnRate*(1/0.03)))*1000))
					--print("")

					Attack(creepClass.creepEntity)

					myAttackTickTable.attackRateTick = GetTick() + myHero.attackRate*1000

					isAttacking = true

					myAttackTickTable.attackPointTick = (GetTick() + myHero.attackPoint*1000 + (GetDistance2D(me, creepClass.creepEntity)/myHero.projectileSpeed)*1000 + (math.max(math.abs(FindAngleR(me) - math.rad(FindAngleBetween(me, creepClass.creepEntity))) - 0.69, 0)/(myHero.turnRate*(1/0.03)))*1000 + (math.max((GetDistance2D(me, creepClass.creepEntity) - myHero.attackRange), 0)/myHero.movementSpeed)*1000)

				end

			else

				if hasQuellingBlade then

					heroDmg = heroDmg * 1.32

				end

				if heroDmg >= creepClass.creepEntity.health or (timeToHealth and timeToHealth <= 333 + (GetTick() + (math.max((GetDistance2D(me, creepClass.creepEntity) - myHero.attackRange), 0)/myHero.movementSpeed)*1000 + myHero.attackPoint*1000 + (math.max(math.abs(FindAngleR(me) - math.rad(FindAngleBetween(me, creepClass.creepEntity))) - 0.69, 0)/(myHero.turnRate*(1/0.03)))*1000)) then
						
					--print("Total Time Till Hit: "..((math.max((GetDistance2D(me, creepClass.creepEntity) - myHero.attackRange), 0)/myHero.movementSpeed)*1000 + myHero.attackPoint*1000 + (math.max(math.abs(FindAngleR(me) - math.rad(FindAngleBetween(me, creepClass.creepEntity))) - 0.69, 0)/(myHero.turnRate*(1/0.03)))*1000))
					--print("Distance Time: "..((math.max((GetDistance2D(me, creepClass.creepEntity) - myHero.attackRange), 0)/myHero.movementSpeed)*1000))
					--print("Attack Point Time: "..(myHero.attackPoint*1000))
					--print("Turning Time: "..((math.max(math.abs(FindAngleR(me) - math.rad(FindAngleBetween(me, creepClass.creepEntity))), 0)/(myHero.turnRate*(1/0.03)))*1000))
					--print("")

					Attack(creepClass.creepEntity)

					myAttackTickTable.attackRateTick = GetTick() + myHero.attackRate*1000

					isAttacking = true

					myAttackTickTable.attackPointTick = 333 + (GetTick() + (math.max((GetDistance2D(me, creepClass.creepEntity) - myHero.attackRange), 0)/myHero.movementSpeed)*1000 + myHero.attackPoint*1000 + (math.max(math.abs(FindAngleR(me) - math.rad(FindAngleBetween(me, creepClass.creepEntity))) - 0.69, 0)/(myHero.turnRate*(1/0.03)))*1000)

				end

			end

		end

	end

end

-- Events --

function LoadTick()

	if not PlayingGame() then
		return
	end

	if OnLoad() then

		myHero = nil
		heroAbilities = nil
		creepTable = {}
		drawTable = {}
		script:RegisterEvent(EVENT_TICK, MainTick)

	end

end

function MainTick()

	if not PlayingGame() then
		return
	end

	if not heroAbilities then

		heroAbilities = {}
		FindHeroAbilities()

	end

	if not myHero then

		myHero = Hero(me)
		if not myHero then
			print("Ryan'sLastHit: Error. (Could not find hero name: "..me.name..".)")
		else
			print("Ryan'sLastHit: Found your hero: "..me.name..".")
			if myHero.isRanged then
				print("Ryan'sLastHit: Ranged hero data: {"..myHero.baseAttackRate..", "..myHero.baseAttackPoint..", "..myHero.projectileSpeed..", "..myHero.baseTurnRate.."}")
			elseif not myHero.isRanged then
				print("Ryan'sLastHit: Melee hero data: {"..myHero.baseAttackRate..", "..myHero.baseAttackPoint..", "..myHero.baseTurnRate.."}")
			end
		end

	else

		UpdateHeroes()
		UpdateCreeps()

		if (IsKeyDown(lastHitKey) or IsKeyDown(lastHitAndDenyKey) or IsKeyDown(denyKey)) and not IsChatOpen() then

			if not isAttacking then
				MoveToMouse()
			end

			CheckForLastHit()

		end

	end

end

function Draw()

	if not PlayingGame() then
		return
	end

	if #drawTable > 0 then

		for i, v in ipairs(drawTable) do

			local pos1 = Vector()
			local pos2 = Vector()
			
			if GetTick() >= v[2][2] then

				if GetTick() <= v[2][2] + v[3] then

					local percent = (GetTick() - v[2][2]) / v[3]

					v[2][1]:ScreenPosition(pos1)
					v[1]:ScreenPosition(pos2)

					if pos2.x > 0 and pos2.y > 0 and pos1.x > 0 and pos1.y > 0
						and pos2.x < 10000 and pos2.y < 10000 and pos1.x < 10000 and pos1.y < 10000 then

						if v[2][1].team == TEAM_DIRE then

							DrawLine(pos2.x, pos2.y, pos1.x, pos1.y, 0xFF0000FF)

						elseif v[2][1].team == TEAM_RADIANT then

							DrawLine(pos2.x, pos2.y, pos1.x, pos1.y, 0x00FF00FF)

						end

					end

				else

					table.remove(drawTable, i)

				end

			end
		end

	end

end

--script:RegisterEvent(EVENT_FRAME, Draw)
script:RegisterEvent(EVENT_TICK, LoadTick)
