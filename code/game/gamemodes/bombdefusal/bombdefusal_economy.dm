// ========== BOMB DEFUSAL - ECONOMY & BUY MENU ==========

// .50 AE knockdown nerf — bombdefusal-specific projectile/casing/mag/gun chain
/obj/item/projectile/bullet/pistol/strong/bombdefusal
	poisedamage = 0 // No knockdown
	damage = 40

/obj/item/ammo_casing/a50/bombdefusal
	projectile_type = /obj/item/projectile/bullet/pistol/strong/bombdefusal

/obj/item/ammo_magazine/a50/bombdefusal
	ammo_type = /obj/item/ammo_casing/a50/bombdefusal

/obj/item/gun/projectile/pistol/magnum_pistol/bombdefusal
	magazine_type = /obj/item/ammo_magazine/a50/bombdefusal
	allowed_magazines = list(/obj/item/ammo_magazine/a50, /obj/item/ammo_magazine/a50/bombdefusal)

// AWP / Anti-Materiel Rifle stun nerf — bombdefusal-specific .145 chain
/obj/item/projectile/bullet/rifle/a145/bombdefusal
	poisedamage = 0 // No knockdown
	stun = 0
	weaken = 0

/obj/item/ammo_casing/a145/bombdefusal
	projectile_type = /obj/item/projectile/bullet/rifle/a145/bombdefusal

/obj/item/gun/projectile/heavysniper/bombdefusal
	ammo_type = /obj/item/ammo_casing/a145/bombdefusal


// Buy menu item definition
/datum/bombdefusal_shop_item
	var/name
	var/category
	var/price
	var/item_type
	var/required_side = null  // If set (BOMBDEFUSAL_TEAM_T or _CT), only that side can buy it
	var/mag_type = null  // If set, spawn extra mags of this type with the weapon
	var/mag_count = 2    // How many extra mags
	var/spare_type = null // For single-casing guns: loose ammo type to spawn as spares
	var/spare_count = 0   // How many loose rounds to spawn

/datum/bombdefusal_shop_item/New(n, cat, p, itype, side = null, mags = null, mag_amt = 2, spares = null, spare_amt = 0)
	name = n
	category = cat
	price = p
	item_type = itype
	required_side = side
	mag_type = mags
	mag_count = mag_amt
	spare_type = spares
	spare_count = spare_amt

// Shop catalog - populated on mode init
/datum/game_mode/bombdefusal/var/list/datum/bombdefusal_shop_item/shop_catalog = list()

/datum/game_mode/bombdefusal/proc/init_shop_catalog()
	shop_catalog = list()
	// Pistols
	shop_catalog += new /datum/bombdefusal_shop_item("9mm Compact",          BOMBDEFUSAL_CAT_PISTOLS, 300,  /obj/item/gun/projectile/pistol/holdout, mags = /obj/item/ammo_magazine/mc9mm)
	shop_catalog += new /datum/bombdefusal_shop_item(".38 Revolver",        BOMBDEFUSAL_CAT_PISTOLS, 300,  /obj/item/gun/projectile/revolver/detective, mags = /obj/item/ammo_magazine/c38)
	shop_catalog += new /datum/bombdefusal_shop_item(".45 Pistol",          BOMBDEFUSAL_CAT_PISTOLS, 500,  /obj/item/gun/projectile/pistol/secgun, mags = /obj/item/ammo_magazine/c45m)
	shop_catalog += new /datum/bombdefusal_shop_item("Silenced Pistol",     BOMBDEFUSAL_CAT_PISTOLS, 750,  /obj/item/gun/projectile/pistol/silenced, mags = /obj/item/ammo_magazine/c45m)
	shop_catalog += new /datum/bombdefusal_shop_item("Military .45",        BOMBDEFUSAL_CAT_PISTOLS, 700,  /obj/item/gun/projectile/pistol/colt/officer, mags = /obj/item/ammo_magazine/c45m)
	shop_catalog += new /datum/bombdefusal_shop_item(".50 Magnum",          BOMBDEFUSAL_CAT_PISTOLS, 1000, /obj/item/gun/projectile/pistol/magnum_pistol/bombdefusal, mags = /obj/item/ammo_magazine/a50/bombdefusal, mag_amt = 1)
	// SMGs
	shop_catalog += new /datum/bombdefusal_shop_item(".45 Machine Pistol",  BOMBDEFUSAL_CAT_SMGS, 1050, /obj/item/gun/projectile/automatic/machine_pistol/mini_uzi, mags = /obj/item/ammo_magazine/c45uzi)
	shop_catalog += new /datum/bombdefusal_shop_item("9mm SMG",             BOMBDEFUSAL_CAT_SMGS, 1250, /obj/item/gun/projectile/automatic/wt550, mags = /obj/item/ammo_magazine/mc9mmt)
	shop_catalog += new /datum/bombdefusal_shop_item("10mm SMG",            BOMBDEFUSAL_CAT_SMGS, 1700, /obj/item/gun/projectile/automatic/c20r, mags = /obj/item/ammo_magazine/a10mm)
	// Rifles
	shop_catalog += new /datum/bombdefusal_shop_item("Bolt Rifle",          BOMBDEFUSAL_CAT_RIFLES, 1700, /obj/item/gun/projectile/bolt_action, mags = /obj/item/ammo_magazine/c792)
	shop_catalog += new /datum/bombdefusal_shop_item("5.56mm Assault Rifle", BOMBDEFUSAL_CAT_RIFLES, 2700, /obj/item/gun/projectile/automatic/as75, mags = /obj/item/ammo_magazine/c556)
	shop_catalog += new /datum/bombdefusal_shop_item("7.62mm Bullpup",      BOMBDEFUSAL_CAT_RIFLES, 3100, /obj/item/gun/projectile/automatic/z8, mags = /obj/item/ammo_magazine/a762)
	// Heavy
	shop_catalog += new /datum/bombdefusal_shop_item("Double-Barrel Shotgun", BOMBDEFUSAL_CAT_HEAVY, 1200, /obj/item/gun/projectile/shotgun/doublebarrel/pellet, spares = /obj/item/ammo_casing/shotgun/pellet, spare_amt = 4)
	shop_catalog += new /datum/bombdefusal_shop_item("Combat Shotgun",      BOMBDEFUSAL_CAT_HEAVY,   1800, /obj/item/gun/projectile/shotgun/pump/combat, spares = /obj/item/ammo_casing/shotgun/pellet, spare_amt = 7)
	shop_catalog += new /datum/bombdefusal_shop_item("Anti-Materiel Rifle", BOMBDEFUSAL_CAT_HEAVY,   4750, /obj/item/gun/projectile/heavysniper/bombdefusal, spares = /obj/item/ammo_casing/a145/bombdefusal, spare_amt = 3)
	shop_catalog += new /datum/bombdefusal_shop_item("L6 SAW",              BOMBDEFUSAL_CAT_HEAVY,   5750, /obj/item/gun/projectile/automatic/l6_saw, mags = /obj/item/ammo_magazine/box/a556)
	shop_catalog += new /datum/bombdefusal_shop_item("Energy Barrier",      BOMBDEFUSAL_CAT_HEAVY,   500,  /obj/item/device/energybarrier/arena)
	// Gear
	shop_catalog += new /datum/bombdefusal_shop_item("Ballistic Vest",      BOMBDEFUSAL_CAT_GEAR,    650,  /obj/item/clothing/suit/armor/vest/bombdefusal_t,  side = BOMBDEFUSAL_TEAM_T)
	shop_catalog += new /datum/bombdefusal_shop_item("Ballistic Helmet",    BOMBDEFUSAL_CAT_GEAR,    350,  /obj/item/clothing/head/helmet/bombdefusal_t,       side = BOMBDEFUSAL_TEAM_T)
	shop_catalog += new /datum/bombdefusal_shop_item("Tactical Vest",       BOMBDEFUSAL_CAT_GEAR,    650,  /obj/item/clothing/suit/armor/vest/bombdefusal_ct, side = BOMBDEFUSAL_TEAM_CT)
	shop_catalog += new /datum/bombdefusal_shop_item("SWAT Helmet",         BOMBDEFUSAL_CAT_GEAR,    350,  /obj/item/clothing/head/helmet/bombdefusal_ct,      side = BOMBDEFUSAL_TEAM_CT)
	shop_catalog += new /datum/bombdefusal_shop_item("Defuse Kit",          BOMBDEFUSAL_CAT_GEAR,    400,  /obj/item/wirecutters, side = BOMBDEFUSAL_TEAM_CT)
	shop_catalog += new /datum/bombdefusal_shop_item("Night Vision",        BOMBDEFUSAL_CAT_GEAR,    1250, /obj/item/clothing/glasses/hud/standard/night/active)
	// Grenades
	shop_catalog += new /datum/bombdefusal_shop_item("Frag Grenade",        BOMBDEFUSAL_CAT_GRENADES, 300, /obj/item/grenade/frag)
	shop_catalog += new /datum/bombdefusal_shop_item("Flashbang",           BOMBDEFUSAL_CAT_GRENADES, 200, /obj/item/grenade/flashbang)
	shop_catalog += new /datum/bombdefusal_shop_item("Smoke Grenade",       BOMBDEFUSAL_CAT_GRENADES, 300, /obj/item/grenade/smokebomb)
	shop_catalog += new /datum/bombdefusal_shop_item("Incendiary",          BOMBDEFUSAL_CAT_GRENADES, 500, /obj/item/grenade/chem_grenade/incendiary)
	// Ammo
	shop_catalog += new /datum/bombdefusal_shop_item("9mm Pistol Magazine", BOMBDEFUSAL_CAT_AMMO,    50,   /obj/item/ammo_magazine/mc9mm)
	shop_catalog += new /datum/bombdefusal_shop_item(".38 Speed Loader",    BOMBDEFUSAL_CAT_AMMO,    50,   /obj/item/ammo_magazine/c38)
	shop_catalog += new /datum/bombdefusal_shop_item(".45 Magazine",        BOMBDEFUSAL_CAT_AMMO,    100,  /obj/item/ammo_magazine/c45m)
	shop_catalog += new /datum/bombdefusal_shop_item(".45 Stick Magazine",  BOMBDEFUSAL_CAT_AMMO,    100,  /obj/item/ammo_magazine/c45uzi)
	shop_catalog += new /datum/bombdefusal_shop_item(".50 Magazine",        BOMBDEFUSAL_CAT_AMMO,    800,  /obj/item/ammo_magazine/a50/bombdefusal)
	shop_catalog += new /datum/bombdefusal_shop_item("9mm Magazine",        BOMBDEFUSAL_CAT_AMMO,    125,  /obj/item/ammo_magazine/mc9mmt)
	shop_catalog += new /datum/bombdefusal_shop_item("10mm Magazine",       BOMBDEFUSAL_CAT_AMMO,    150,  /obj/item/ammo_magazine/a10mm)
	shop_catalog += new /datum/bombdefusal_shop_item("7.92mm Clip",         BOMBDEFUSAL_CAT_AMMO,    100,  /obj/item/ammo_magazine/c792)
	shop_catalog += new /datum/bombdefusal_shop_item("5.56mm Magazine",     BOMBDEFUSAL_CAT_AMMO,    200,  /obj/item/ammo_magazine/c556)
	shop_catalog += new /datum/bombdefusal_shop_item("7.62mm Magazine",     BOMBDEFUSAL_CAT_AMMO,    200,  /obj/item/ammo_magazine/a762)
	shop_catalog += new /datum/bombdefusal_shop_item("5.56mm Ammo Box",    BOMBDEFUSAL_CAT_AMMO,    350,  /obj/item/ammo_magazine/box/a556)
	shop_catalog += new /datum/bombdefusal_shop_item("12g Shotgun Shell",   BOMBDEFUSAL_CAT_AMMO,    25,   /obj/item/ammo_casing/shotgun/pellet)
	shop_catalog += new /datum/bombdefusal_shop_item("14.5mm Round",        BOMBDEFUSAL_CAT_AMMO,    300,  /obj/item/ammo_casing/a145/bombdefusal)
	// Medical
	shop_catalog += new /datum/bombdefusal_shop_item("Arena Medkit",        BOMBDEFUSAL_CAT_MEDICAL, 1000, /obj/item/bombdefusal_medkit)
	shop_catalog += new /datum/bombdefusal_shop_item("Arena Stimulant",     BOMBDEFUSAL_CAT_MEDICAL, 400,  /obj/item/bombdefusal_injector)

/datum/game_mode/bombdefusal/proc/show_buy_menu(mob/user, datum/bombdefusal_player_data/pd, force_open = FALSE, category = null)
	if(!pd || !pd.match)
		return
	var/datum/bombdefusal_match/match = pd.match
	if(!force_open && match.match_state != BOMBDEFUSAL_STATE_BUY && match.match_state != BOMBDEFUSAL_STATE_FREEZE)
		to_chat(user, "<span class='warning'>Buy phase is over!</span>")
		return

	if(!shop_catalog.len)
		init_shop_catalog()

	var/list/html = list()
	html += {"<html><head><meta charset='utf-8'><title>Buy Menu</title>
<style>
body { background: #1a1a1a url('data:image/svg+xml;utf8,<svg xmlns=\"http://www.w3.org/2000/svg\"/>'); color: #ff9933; font-family: Arial, sans-serif; margin: 0; padding: 0; }
.frame { background: rgba(20, 20, 25, 0.92); margin: 10px; padding: 12px; border: 1px solid #444; }
h1 { color: #ff9933; font-size: 18px; margin: 0 0 8px 0; padding-bottom: 6px; border-bottom: 1px solid #ff9933; text-transform: uppercase; letter-spacing: 1px; }
.topbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; }
.money { color: #ffd700; font-size: 18px; font-weight: bold; }
.side { color: #ccc; font-size: 12px; }
.cat-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 6px; }
.cat-btn { display: block; background: #2a2a2a; color: #ff9933; padding: 14px 16px; text-decoration: none; font-size: 13px; font-weight: bold; text-transform: uppercase; border: 1px solid #555; }
.cat-btn:hover { background: #c8102e; color: #fff; border-color: #c8102e; }
.cat-btn .num { color: #ffd700; margin-right: 8px; font-size: 14px; }
.item-list { display: flex; flex-direction: column; gap: 4px; }
.item { display: flex; justify-content: space-between; align-items: center; background: #2a2a2a; padding: 8px 12px; text-decoration: none; color: #ff9933; font-size: 13px; border: 1px solid #555; }
.item:hover { background: #c8102e; color: #fff; border-color: #c8102e; }
.item .num { color: #ffd700; margin-right: 8px; }
.item:hover .num { color: #fff; }
.item.locked { background: #1f1f1f; color: #666; border-color: #333; cursor: not-allowed; }
.item.locked:hover { background: #1f1f1f; color: #666; }
.price { color: #ffd700; font-weight: bold; }
.item:hover .price { color: #fff; }
.item.locked .price { color: #555; }
.back-btn { display: block; margin-top: 12px; background: #2a2a2a; color: #ff9933; padding: 10px 16px; text-decoration: none; font-size: 13px; font-weight: bold; text-transform: uppercase; border: 1px solid #555; text-align: center; }
.back-btn:hover { background: #444; color: #fff; }
.back-btn .num { color: #ffd700; margin-right: 8px; }
</style></head><body><div class='frame'>"}

	var/side_label = (pd.team.current_side == BOMBDEFUSAL_TEAM_T) ? "<font color='#ff4444'>TERRORISTS</font>" : "<font color='#4488ff'>COUNTER-TERRORISTS</font>"

	if(!category)
		// Category grid view
		html += "<h1>Buy Menu</h1>"
		html += "<div class='topbar'><span class='side'>[side_label]</span><span class='money'>$[pd.money]</span></div>"
		html += "<div class='cat-grid'>"
		var/list/cats_used = list()
		var/cat_num = 1
		for(var/datum/bombdefusal_shop_item/item in shop_catalog)
			if(item.category in cats_used)
				continue
			cats_used += item.category
			html += "<a class='cat-btn' href='?src=\ref[src];action=buy_cat;cat=[item.category]'><span class='num'>[cat_num]</span>[item.category]</a>"
			cat_num++
		html += "</div>"
		html += "<a class='back-btn' href='?src=\ref[src];action=buy_close'><span class='num'>0</span>CANCEL</a>"
	else
		// Item list for the chosen category
		html += "<h1>Buy [category]</h1>"
		html += "<div class='topbar'><span class='side'>[side_label]</span><span class='money'>$[pd.money]</span></div>"
		html += "<div class='item-list'>"
		var/item_num = 1
		for(var/datum/bombdefusal_shop_item/item in shop_catalog)
			if(item.category != category)
				continue

			var/can_buy = TRUE
			var/reason = ""
			if(!pd.can_afford(item.price))
				can_buy = FALSE
				reason = "Can't afford"
			if(item.required_side && pd.team.current_side != item.required_side)
				can_buy = FALSE
				reason = "[item.required_side] only"

			if(can_buy)
				html += "<a class='item' href='?src=\ref[src];action=buy_item;item=\ref[item];cat=[category]'><span><span class='num'>[item_num]</span>[item.name]</span><span class='price'>$[item.price]</span></a>"
			else
				html += "<div class='item locked'><span><span class='num'>[item_num]</span>[item.name] <small>([reason])</small></span><span class='price'>$[item.price]</span></div>"
			item_num++
		html += "</div>"
		html += "<a class='back-btn' href='?src=\ref[src];action=buy_back'><span class='num'>0</span>BACK</a>"

	html += "</div></body></html>"

	show_browser(user, html.Join(""), "window=bombdefusal_buy;size=500x600")

/datum/game_mode/bombdefusal/proc/handle_buy_topic(mob/user, list/href_list)
	var/datum/bombdefusal_player_data/pd = get_player_data_by_mob(user)
	if(!pd || !pd.match)
		log_debug("Bombdefusal buy failed - player data not found. Mind: [user.mind ? "yes" : "no"], ckey: [user.ckey]")
		return

	if(pd.is_dead)
		to_chat(user, "<span class='warning'>You can't buy while dead!</span>")
		return

	var/datum/bombdefusal_match/match = pd.match
	var/is_admin = user.client && user.client.holder
	if(!is_admin && match.match_state != BOMBDEFUSAL_STATE_BUY && match.match_state != BOMBDEFUSAL_STATE_FREEZE)
		to_chat(user, "<span class='warning'>Buy phase is over!</span>")
		return

	var/sub_action = href_list["action"]

	// Navigation actions
	if(sub_action == "buy_cat")
		show_buy_menu(user, pd, category = href_list["cat"])
		return
	if(sub_action == "buy_back")
		show_buy_menu(user, pd)
		return
	if(sub_action == "buy_close")
		if(user.client)
			close_browser(user, "window=bombdefusal_buy")
		return

	var/datum/bombdefusal_shop_item/item = locate(href_list["item"])
	if(!item)
		log_debug("Bombdefusal buy: Item ref not found: [href_list["item"]]")
		return

	var/return_cat = href_list["cat"] // Remember which category to return to after buying

	// Validate
	if(!pd.can_afford(item.price))
		to_chat(user, "<span class='warning'>Not enough money!</span>")
		show_buy_menu(user, pd)
		return

	if(item.required_side && pd.team.current_side != item.required_side)
		to_chat(user, "<span class='warning'>This item is not available to your side!</span>")
		show_buy_menu(user, pd)
		return

	// Block duplicate armor/helmet purchases
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(ispath(item.item_type, /obj/item/clothing/suit/armor) && H.wear_suit)
			to_chat(user, "<span class='warning'>You already have a vest equipped!</span>")
			show_buy_menu(user, pd, category = return_cat)
			return
		if(ispath(item.item_type, /obj/item/clothing/head/helmet) && H.head)
			to_chat(user, "<span class='warning'>You already have a helmet equipped!</span>")
			show_buy_menu(user, pd, category = return_cat)
			return

	// Purchase
	pd.spend_money(item.price)
	var/obj/item/new_item = new item.item_type(get_turf(user))

	// Set heal amounts from config if applicable
	if(istype(new_item, /obj/item/bombdefusal_medkit))
		var/obj/item/bombdefusal_medkit/mk = new_item
		mk.charges = cfg_medkit_charges
		mk.cooldown_time = cfg_medkit_cooldown
	else if(istype(new_item, /obj/item/bombdefusal_injector))
		var/obj/item/bombdefusal_injector/inj = new_item
		inj.heal_amount = cfg_injector_heal

	// Replace fire_sound with CS 1.6 weapon sounds for fun
	if(istype(new_item, /obj/item/gun/projectile))
		var/obj/item/gun/projectile/G = new_item
		var/cs_sound = null
		if(istype(G, /obj/item/gun/projectile/pistol/holdout))               cs_sound = 'sound/csgo/weapons/glock18-1.wav'
		else if(istype(G, /obj/item/gun/projectile/revolver/detective))      cs_sound = 'sound/csgo/weapons/deagle-1.wav'
		else if(istype(G, /obj/item/gun/projectile/pistol/secgun))           cs_sound = 'sound/csgo/weapons/usp1.wav'
		else if(istype(G, /obj/item/gun/projectile/pistol/silenced))         cs_sound = 'sound/csgo/weapons/usp1.wav'
		else if(istype(G, /obj/item/gun/projectile/pistol/colt/officer))     cs_sound = 'sound/csgo/weapons/p228-1.wav'
		else if(istype(G, /obj/item/gun/projectile/pistol/magnum_pistol))    cs_sound = 'sound/csgo/weapons/deagle-1.wav'
		else if(istype(G, /obj/item/gun/projectile/automatic/machine_pistol/mini_uzi)) cs_sound = 'sound/csgo/weapons/mac10-1.wav'
		else if(istype(G, /obj/item/gun/projectile/automatic/wt550))         cs_sound = 'sound/csgo/weapons/mp5-1.wav'
		else if(istype(G, /obj/item/gun/projectile/automatic/c20r))          cs_sound = 'sound/csgo/weapons/ump45-1.wav'
		else if(istype(G, /obj/item/gun/projectile/bolt_action))             cs_sound = 'sound/csgo/weapons/scout_fire-1.wav'
		else if(istype(G, /obj/item/gun/projectile/automatic/as75))          cs_sound = 'sound/csgo/weapons/m4a1-1.wav'
		else if(istype(G, /obj/item/gun/projectile/automatic/z8))            cs_sound = 'sound/csgo/weapons/ak47-1.wav'
		else if(istype(G, /obj/item/gun/projectile/shotgun/doublebarrel))    cs_sound = 'sound/csgo/weapons/m3-1.wav'
		else if(istype(G, /obj/item/gun/projectile/shotgun/pump/combat))     cs_sound = 'sound/csgo/weapons/xm1014-1.wav'
		else if(istype(G, /obj/item/gun/projectile/heavysniper))             cs_sound = 'sound/csgo/weapons/awp1.wav'
		else if(istype(G, /obj/item/gun/projectile/automatic/l6_saw))        cs_sound = 'sound/csgo/weapons/m249-1.wav'
		if(cs_sound)
			G.override_fire_sound = cs_sound

	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.put_in_hands(new_item)

		// Spawn extra magazines into backpack
		if(item.mag_type)
			for(var/i = 1 to item.mag_count)
				var/obj/item/mag = new item.mag_type(get_turf(H))
				if(!H.equip_to_storage(mag))
					H.put_in_hands(mag)

		// Spawn loose spare rounds (for revolvers, shotguns, etc.)
		if(item.spare_type && item.spare_count > 0)
			for(var/i = 1 to item.spare_count)
				var/obj/item/round = new item.spare_type(get_turf(H))
				if(!H.equip_to_storage(round))
					H.put_in_hands(round)

	sound_to(user, sound('sound/csgo/gun-pickup.mp3'))
	to_chat(user, "<span class='notice'>Purchased [item.name] for $[item.price]. Remaining: $[pd.money]</span>")
	show_buy_menu(user, pd, category = return_cat)
