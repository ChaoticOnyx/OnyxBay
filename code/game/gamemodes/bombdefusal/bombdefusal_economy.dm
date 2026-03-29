// ========== BOMB DEFUSAL - ECONOMY & BUY MENU ==========

// Buy menu item definition
/datum/bombdefusal_shop_item
	var/name
	var/category
	var/price
	var/item_type
	var/required_role = null  // If set, only this role can buy it
	var/required_side = null  // If set (BOMBDEFUSAL_TEAM_T or _CT), only that side can buy it
	var/mag_type = null  // If set, spawn extra mags of this type with the weapon
	var/mag_count = 2    // How many extra mags
	var/spare_type = null // For single-casing guns: loose ammo type to spawn as spares
	var/spare_count = 0   // How many loose rounds to spawn

/datum/bombdefusal_shop_item/New(n, cat, p, itype, role = null, side = null, mags = null, mag_amt = 2, spares = null, spare_amt = 0)
	name = n
	category = cat
	price = p
	item_type = itype
	required_role = role
	required_side = side
	mag_type = mags
	mag_count = mag_amt
	spare_type = spares
	spare_count = spare_amt

// Shop catalog - populated on mode init
/datum/game_mode/bombdefusal/var/list/datum/bombdefusal_shop_item/shop_catalog = list()

/datum/game_mode/bombdefusal/proc/init_shop_catalog()
	shop_catalog = list()
	// Pistols - available to all roles
	shop_catalog += new /datum/bombdefusal_shop_item("9mm Compact",          BOMBDEFUSAL_CAT_PISTOLS, 300,  /obj/item/gun/projectile/pistol/holdout, mags = /obj/item/ammo_magazine/mc9mm)
	shop_catalog += new /datum/bombdefusal_shop_item(".38 Revolver",        BOMBDEFUSAL_CAT_PISTOLS, 300,  /obj/item/gun/projectile/revolver/detective, mags = /obj/item/ammo_magazine/c38)
	shop_catalog += new /datum/bombdefusal_shop_item(".45 Pistol",          BOMBDEFUSAL_CAT_PISTOLS, 500,  /obj/item/gun/projectile/pistol/secgun, mags = /obj/item/ammo_magazine/c45m)
	shop_catalog += new /datum/bombdefusal_shop_item("Silenced Pistol",     BOMBDEFUSAL_CAT_PISTOLS, 750,  /obj/item/gun/projectile/pistol/silenced, mags = /obj/item/ammo_magazine/c45m)
	shop_catalog += new /datum/bombdefusal_shop_item("Military .45",        BOMBDEFUSAL_CAT_PISTOLS, 700,  /obj/item/gun/projectile/pistol/colt/officer, mags = /obj/item/ammo_magazine/c45m)
	shop_catalog += new /datum/bombdefusal_shop_item(".50 Magnum",          BOMBDEFUSAL_CAT_PISTOLS, 800,  /obj/item/gun/projectile/pistol/magnum_pistol, mags = /obj/item/ammo_magazine/a50, mag_amt = 1)
	// SMGs - available to all roles
	shop_catalog += new /datum/bombdefusal_shop_item(".45 Machine Pistol",  BOMBDEFUSAL_CAT_SMGS, 1050, /obj/item/gun/projectile/automatic/machine_pistol/mini_uzi, mags = /obj/item/ammo_magazine/c45uzi)
	shop_catalog += new /datum/bombdefusal_shop_item("9mm SMG",             BOMBDEFUSAL_CAT_SMGS, 1250, /obj/item/gun/projectile/automatic/wt550, mags = /obj/item/ammo_magazine/mc9mmt)
	shop_catalog += new /datum/bombdefusal_shop_item("10mm SMG",            BOMBDEFUSAL_CAT_SMGS, 1700, /obj/item/gun/projectile/automatic/c20r, mags = /obj/item/ammo_magazine/a10mm)
	// Rifles - Rifleman only
	shop_catalog += new /datum/bombdefusal_shop_item("Bolt Rifle",          BOMBDEFUSAL_CAT_RIFLES, 1700, /obj/item/gun/projectile/bolt_action, role = BOMBDEFUSAL_ROLE_RIFLEMAN, mags = /obj/item/ammo_magazine/c792)
	shop_catalog += new /datum/bombdefusal_shop_item("5.56mm Assault Rifle", BOMBDEFUSAL_CAT_RIFLES, 2700, /obj/item/gun/projectile/automatic/as75, role = BOMBDEFUSAL_ROLE_RIFLEMAN, mags = /obj/item/ammo_magazine/c556)
	shop_catalog += new /datum/bombdefusal_shop_item("7.62mm Bullpup",      BOMBDEFUSAL_CAT_RIFLES, 3100, /obj/item/gun/projectile/automatic/z8, role = BOMBDEFUSAL_ROLE_RIFLEMAN, mags = /obj/item/ammo_magazine/a762)
	// Heavy - Support only
	shop_catalog += new /datum/bombdefusal_shop_item("Double-Barrel Shotgun", BOMBDEFUSAL_CAT_HEAVY, 1200, /obj/item/gun/projectile/shotgun/doublebarrel/pellet, role = BOMBDEFUSAL_ROLE_SUPPORT, spares = /obj/item/ammo_casing/shotgun/pellet, spare_amt = 4)
	shop_catalog += new /datum/bombdefusal_shop_item("Combat Shotgun",      BOMBDEFUSAL_CAT_HEAVY,   1800, /obj/item/gun/projectile/shotgun/pump/combat, role = BOMBDEFUSAL_ROLE_SUPPORT, spares = /obj/item/ammo_casing/shotgun/pellet, spare_amt = 7)
	shop_catalog += new /datum/bombdefusal_shop_item("Anti-Materiel Rifle", BOMBDEFUSAL_CAT_HEAVY,   4750, /obj/item/gun/projectile/heavysniper, role = BOMBDEFUSAL_ROLE_SUPPORT, spares = /obj/item/ammo_casing/a145, spare_amt = 3)
	shop_catalog += new /datum/bombdefusal_shop_item("L6 SAW",              BOMBDEFUSAL_CAT_HEAVY,   5750, /obj/item/gun/projectile/automatic/l6_saw, role = BOMBDEFUSAL_ROLE_SUPPORT, mags = /obj/item/ammo_magazine/box/a556)
	shop_catalog += new /datum/bombdefusal_shop_item("Energy Barrier",      BOMBDEFUSAL_CAT_HEAVY,   500,  /obj/item/device/energybarrier/arena, role = BOMBDEFUSAL_ROLE_SUPPORT)
	// Gear - available to all roles
	shop_catalog += new /datum/bombdefusal_shop_item("Ballistic Vest",      BOMBDEFUSAL_CAT_GEAR,    650,  /obj/item/clothing/suit/armor/vest/bombdefusal_t,  side = BOMBDEFUSAL_TEAM_T)
	shop_catalog += new /datum/bombdefusal_shop_item("Ballistic Helmet",    BOMBDEFUSAL_CAT_GEAR,    350,  /obj/item/clothing/head/helmet/bombdefusal_t,       side = BOMBDEFUSAL_TEAM_T)
	shop_catalog += new /datum/bombdefusal_shop_item("Tactical Vest",       BOMBDEFUSAL_CAT_GEAR,    650,  /obj/item/clothing/suit/armor/vest/bombdefusal_ct, side = BOMBDEFUSAL_TEAM_CT)
	shop_catalog += new /datum/bombdefusal_shop_item("SWAT Helmet",         BOMBDEFUSAL_CAT_GEAR,    350,  /obj/item/clothing/head/helmet/bombdefusal_ct,      side = BOMBDEFUSAL_TEAM_CT)
	shop_catalog += new /datum/bombdefusal_shop_item("Defuse Kit",          BOMBDEFUSAL_CAT_GEAR,    400,  /obj/item/wirecutters)
	shop_catalog += new /datum/bombdefusal_shop_item("Frag Grenade",        BOMBDEFUSAL_CAT_GEAR,    300,  /obj/item/grenade/frag)
	shop_catalog += new /datum/bombdefusal_shop_item("Extra Frag Grenade",  BOMBDEFUSAL_CAT_GEAR,    250,  /obj/item/grenade/frag, role = BOMBDEFUSAL_ROLE_SUPPORT)
	shop_catalog += new /datum/bombdefusal_shop_item("Flashbang",           BOMBDEFUSAL_CAT_GEAR,    200,  /obj/item/grenade/flashbang)
	shop_catalog += new /datum/bombdefusal_shop_item("Smoke Grenade",       BOMBDEFUSAL_CAT_GEAR,    300,  /obj/item/grenade/smokebomb)
	shop_catalog += new /datum/bombdefusal_shop_item("Night Vision",        BOMBDEFUSAL_CAT_GEAR,    1250, /obj/item/clothing/glasses/hud/standard/night/active)
	// Ammo - role-matched to weapons
	shop_catalog += new /datum/bombdefusal_shop_item("9mm Pistol Magazine", BOMBDEFUSAL_CAT_AMMO,    50,   /obj/item/ammo_magazine/mc9mm)
	shop_catalog += new /datum/bombdefusal_shop_item(".38 Speed Loader",    BOMBDEFUSAL_CAT_AMMO,    50,   /obj/item/ammo_magazine/c38)
	shop_catalog += new /datum/bombdefusal_shop_item(".45 Magazine",        BOMBDEFUSAL_CAT_AMMO,    100,  /obj/item/ammo_magazine/c45m)
	shop_catalog += new /datum/bombdefusal_shop_item(".45 Stick Magazine",  BOMBDEFUSAL_CAT_AMMO,    100,  /obj/item/ammo_magazine/c45uzi)
	shop_catalog += new /datum/bombdefusal_shop_item(".50 Magazine",        BOMBDEFUSAL_CAT_AMMO,    150,  /obj/item/ammo_magazine/a50)
	shop_catalog += new /datum/bombdefusal_shop_item("9mm Magazine",        BOMBDEFUSAL_CAT_AMMO,    125,  /obj/item/ammo_magazine/mc9mmt)
	shop_catalog += new /datum/bombdefusal_shop_item("10mm Magazine",       BOMBDEFUSAL_CAT_AMMO,    150,  /obj/item/ammo_magazine/a10mm)
	shop_catalog += new /datum/bombdefusal_shop_item("7.92mm Clip",         BOMBDEFUSAL_CAT_AMMO,    100,  /obj/item/ammo_magazine/c792, role = BOMBDEFUSAL_ROLE_RIFLEMAN)
	shop_catalog += new /datum/bombdefusal_shop_item("5.56mm Magazine",     BOMBDEFUSAL_CAT_AMMO,    200,  /obj/item/ammo_magazine/c556, role = BOMBDEFUSAL_ROLE_RIFLEMAN)
	shop_catalog += new /datum/bombdefusal_shop_item("7.62mm Magazine",     BOMBDEFUSAL_CAT_AMMO,    200,  /obj/item/ammo_magazine/a762, role = BOMBDEFUSAL_ROLE_RIFLEMAN)
	shop_catalog += new /datum/bombdefusal_shop_item("5.56mm Ammo Box",    BOMBDEFUSAL_CAT_AMMO,    350,  /obj/item/ammo_magazine/box/a556, role = BOMBDEFUSAL_ROLE_SUPPORT)
	shop_catalog += new /datum/bombdefusal_shop_item("12g Shotgun Shell",   BOMBDEFUSAL_CAT_AMMO,    25,   /obj/item/ammo_casing/shotgun/pellet, role = BOMBDEFUSAL_ROLE_SUPPORT)
	// Medical - Medic only
	shop_catalog += new /datum/bombdefusal_shop_item("Arena Medkit",        BOMBDEFUSAL_CAT_MEDICAL, 1000, /obj/item/bombdefusal_medkit, role = BOMBDEFUSAL_ROLE_MEDIC)
	shop_catalog += new /datum/bombdefusal_shop_item("Combat Defib",        BOMBDEFUSAL_CAT_MEDICAL, 2000, /obj/item/defibrillator/compact/combat/loaded, role = BOMBDEFUSAL_ROLE_MEDIC)
	shop_catalog += new /datum/bombdefusal_shop_item("Arena Stimulant",     BOMBDEFUSAL_CAT_MEDICAL, 400,  /obj/item/bombdefusal_injector)

/datum/game_mode/bombdefusal/proc/show_buy_menu(mob/user, datum/bombdefusal_player_data/pd, force_open = FALSE)
	if(!pd || !pd.match)
		return
	var/datum/bombdefusal_match/match = pd.match
	if(!force_open && match.match_state != BOMBDEFUSAL_STATE_BUY && match.match_state != BOMBDEFUSAL_STATE_FREEZE)
		to_chat(user, "<span class='warning'>Buy phase is over!</span>")
		return

	if(!shop_catalog.len)
		init_shop_catalog()

	var/list/html = list()
	html += "<html><head><meta charset='utf-8'><title>Buy Menu</title>"
	html += "<style>"
	html += "body { background: #1a1a2e; color: #eee; font-family: 'Courier New', monospace; margin: 10px; }"
	html += "h1 { color: #FFD700; text-align: center; margin: 5px; }"
	html += "h2 { color: #e94560; margin: 10px 0 5px 0; border-bottom: 1px solid #333; }"
	html += ".money { color: #00FF00; font-size: 20px; text-align: center; margin: 5px; }"
	html += ".item { background: #16213e; padding: 5px 10px; margin: 2px 0; display: flex; justify-content: space-between; align-items: center; border: 1px solid #333; }"
	html += ".item:hover { border-color: #e94560; }"
	html += ".btn { background: #e94560; color: white; padding: 3px 12px; border: none; cursor: pointer; text-decoration: none; font-size: 12px; }"
	html += ".btn:hover { background: #ff6b6b; }"
	html += ".btn-disabled { background: #555; cursor: not-allowed; }"
	html += ".price { color: #FFD700; }"
	html += ".locked { color: #666; }"
	html += "</style></head><body>"

	html += "<h1>BUY MENU</h1>"
	html += "<div class='money'>$[pd.money]</div>"

	// Role selector
	html += "<div style='text-align: center; margin: 5px 0;'>"
	html += "<span style='color: #aaa;'>Role: </span>"
	var/list/all_roles = list(BOMBDEFUSAL_ROLE_RIFLEMAN, BOMBDEFUSAL_ROLE_MEDIC, BOMBDEFUSAL_ROLE_SUPPORT)
	var/can_swap = (pd.last_role_swap_round <= 0) || (match.current_round_num - pd.last_role_swap_round >= 2)
	for(var/r in all_roles)
		if(pd.role == r)
			html += "<span style='color: #FFD700; font-weight: bold; margin: 0 5px; padding: 2px 8px; border: 1px solid #FFD700;'>[r]</span>"
		else if(can_swap)
			html += "<a class='btn' style='margin: 0 3px; font-size: 11px;' href='?src=\ref[src];action=set_role;role=[r]'>[r]</a>"
		else
			html += "<span class='btn btn-disabled' style='margin: 0 3px; font-size: 11px;'>[r]</span>"
	if(!can_swap)
		var/rounds_left = 2 - (match.current_round_num - pd.last_role_swap_round)
		html += "<br><span style='color: #a00; font-size: 10px;'>Role locked for [rounds_left] more round(s)</span>"
	html += "</div>"

	var/current_cat = ""
	for(var/datum/bombdefusal_shop_item/item in shop_catalog)
		if(item.category != current_cat)
			current_cat = item.category
			html += "<h2>[current_cat]</h2>"

		var/can_buy = TRUE
		var/reason = ""
		if(!pd.can_afford(item.price))
			can_buy = FALSE
			reason = "Can't afford"
		if(item.required_role && pd.role != item.required_role)
			can_buy = FALSE
			reason = "[item.required_role] only"
		if(item.required_side && pd.team.current_side != item.required_side)
			can_buy = FALSE
			reason = "[item.required_side] only"

		html += "<div class='item'>"
		if(can_buy)
			html += "<span>[item.name] - <span class='price'>$[item.price]</span></span>"
			html += "<a class='btn' href='?src=\ref[src];action=buy_item;item=\ref[item]'>BUY</a>"
		else
			html += "<span class='locked'>[item.name] - $[item.price] ([reason])</span>"
			html += "<span class='btn btn-disabled'>BUY</span>"
		html += "</div>"

	html += "</body></html>"

	show_browser(user, html.Join(""), "window=bombdefusal_buy;size=400x600")

/datum/game_mode/bombdefusal/proc/handle_buy_topic(mob/user, list/href_list)
	var/datum/bombdefusal_player_data/pd = get_player_data_by_mob(user)
	if(!pd || !pd.match)
		log_debug("Bombdefusal buy failed - player data not found. Mind: [user.mind ? "yes" : "no"], ckey: [user.ckey]")
		return

	var/datum/bombdefusal_match/match = pd.match
	var/is_admin = user.client && user.client.holder
	if(!is_admin && match.match_state != BOMBDEFUSAL_STATE_BUY && match.match_state != BOMBDEFUSAL_STATE_FREEZE)
		to_chat(user, "<span class='warning'>Buy phase is over!</span>")
		return

	var/datum/bombdefusal_shop_item/item = locate(href_list["item"])
	if(!item)
		log_debug("Bombdefusal buy: Item ref not found: [href_list["item"]]")
		return

	// Validate
	if(!pd.can_afford(item.price))
		to_chat(user, "<span class='warning'>Not enough money!</span>")
		show_buy_menu(user, pd)
		return

	if(item.required_role && pd.role != item.required_role)
		to_chat(user, "<span class='warning'>This item requires [item.required_role] role!</span>")
		show_buy_menu(user, pd)
		return

	if(item.required_side && pd.team.current_side != item.required_side)
		to_chat(user, "<span class='warning'>This item is not available to your side!</span>")
		show_buy_menu(user, pd)
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
	show_buy_menu(user, pd)

/datum/game_mode/bombdefusal/proc/handle_set_role(mob/user, list/href_list)
	var/datum/bombdefusal_player_data/pd = get_player_data_by_mob(user)
	if(!pd || !pd.match)
		return

	var/datum/bombdefusal_match/match = pd.match
	// Can only switch roles during freeze or buy phase
	if(match.match_state != BOMBDEFUSAL_STATE_BUY && match.match_state != BOMBDEFUSAL_STATE_FREEZE)
		to_chat(user, "<span class='warning'>You can only switch roles during the buy phase!</span>")
		return

	var/new_role = href_list["role"]
	if(!(new_role in list(BOMBDEFUSAL_ROLE_RIFLEMAN, BOMBDEFUSAL_ROLE_MEDIC, BOMBDEFUSAL_ROLE_SUPPORT)))
		return

	if(pd.role == new_role)
		return

	// Can only swap role once per 2 rounds
	var/rounds_since_swap = match.current_round_num - pd.last_role_swap_round
	if(pd.last_role_swap_round > 0 && rounds_since_swap < 2)
		to_chat(user, "<span class='warning'>You can only switch roles once every 2 rounds! ([2 - rounds_since_swap] round(s) remaining)</span>")
		show_buy_menu(user, pd)
		return

	pd.role = new_role
	pd.last_role_swap_round = match.current_round_num
	to_chat(user, "<span class='notice'>Role changed to <b>[new_role]</b>!</span>")
	show_buy_menu(user, pd)
