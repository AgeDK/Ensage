--<<Re-worked show side message enemy item>>
--[[
	------------------------------------------
    → Script : Enemy Item Notification
    → Version: 2.0
    → Edited By: lucastx
	→ Original By: DeadlyLone
	→ Modified By: ALIEN
    -------------------------------------------

	Description:
	------------
		Shows enemy items on side screen (same as item buying shown for team-mates)
]]--

--→ CODE


-- Libs necessary
require('libs.TickCounter2')
require('libs.SideMessage')


pepeka = 1

function Tick()
	local playing = PlayingGame()
	if pepeka == 1 then
		TickCounter.Start()
		ItemTick(playing)
		TickCounter.CalculateAvg()
		
	end
end

-- Items that will show on side message
-- if you wanna add more items you can see the list here: http://dota2.gamepedia.com/Cheats


declarePurchase = {
	item_blink                = true,
	item_ward_observer        = true,
	item_ward_sentry          = true,
	item_gem                  = true,
	item_cheese               = true,
	item_travel_boots         = true,
	item_phase_boots          = true,
	item_power_treads         = true,
	item_hand_of_midas        = true,
	item_mekansm              = true,
	item_vladmir              = true,
	item_pipe                 = true,
	item_urn_of_shadows       = true,
	item_sheepstick           = true,
	item_orchid               = true,
	item_cyclone              = true,
	item_force_staff          = true,
	item_dagon                = true,
	item_dagon_2              = true,
	item_dagon_3              = true,
	item_dagon_4              = true,
	item_dagon_5              = true,
	item_necronomicon         = true,
	item_necronomicon_2       = true,
	item_necronomicon_3       = true,
	item_ultimate_scepter     = true,
	item_refresher            = true,
	item_assault              = true,
	item_heart                = true,
	item_black_king_bar       = true,
	item_shivas_guard         = true,
	item_bloodstone           = true,
	item_sphere               = true,
	item_vanguard             = true,
	item_blade_mail           = true,
	item_hood_of_defiance     = true,
	item_rapier               = true,
	item_monkey_king_bar      = true,
	item_radiance             = true,
	item_butterfly            = true,
	item_greater_crit         = true,
	item_basher               = true,
	item_bfury                = true,
	item_manta                = true,
	item_armlet               = true,
	item_invis_sword          = true,
	item_sange_and_yasha      = true,
	item_satanic              = true,
	item_mjollnir             = true,
	item_skadi                = true,
	item_maelstrom            = true,
	item_desolator            = true,
	item_mask_of_madness      = true,
	item_diffusal_blade       = true,
	item_ethereal_blade       = true,
	item_soul_ring            = true,
	item_arcane_boots         = true,
	item_ancient_janggo       = true,
	item_medallion_of_courage = true,
	item_smoke_of_deceit      = true,
	item_veil_of_discord      = true,
	item_rod_of_atos          = true,
	item_abyssal_blade        = true,
	item_heavens_halberd      = true,
	item_tranquil_boots       = true,
	item_glimmer_cape         = true,
	item_guardian_greaves     = true,
	item_lotus_orb            = true,
	item_moon_shard           = true,
	item_octarine_core        = true,
	item_silver_edge          = true
}

items = {}

-- Don't change anything below

function ItemTick(playing)
	if playing then
		enemyItems = entityList:FindEntities(function (ent) return ent.item and declarePurchase[ent.name] == true and ent.purchaser ~= nil and not ent.owner.illusion and ent.owner.name ~= "npc_dota_roshan" and ent.purchaser.team ~= entityList:GetMyHero().team and not items[ent.handle] end)
		for i,v in ipairs(enemyItems) do
			items[v.handle] = true
			if items.init then
				GenerateSideMessage(v.purchaser.name:gsub("npc_dota_hero_",""),v.name:gsub("item_",""))
			end
		end
		if not items.init then 
			items.init = true
		end
	elseif items.init then
		items = {}
	end
end

function GenerateSideMessage(heroName,itemName)
	local test = sideMessage:CreateMessage(205,50) -- Side message size
	test:AddElement(drawMgr:CreateRect(006,0,75,42,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/heroes_horizontal/"..heroName)))
	test:AddElement(drawMgr:CreateRect(078,0,64,32,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/other/arrow_item_bought")))
	test:AddElement(drawMgr:CreateRect(142,0,86,43,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/items/"..(itemName))))
end
script:RegisterEvent(EVENT_TICK,Tick)

-- end of script.
