var/list/loadout_categories = list()
var/list/gear_datums = list()
var/list/hash_to_gear = list()

/datum/preferences
	var/list/gear_list //Custom/fluff item loadouts.
	var/gear_slot = 1  //The current gear save slot
	var/datum/gear/trying_on_gear
	var/list/trying_on_tweaks = new
	var/loadout_is_busy = FALSE // All these gear tweaks be slow as anything. Let's just force things to yield, sparing us from sanitizing and resanitizing stuff.
	var/max_loadout_points
	var/max_augmentation_points
	var/total_lpoints_cost
	var/total_aug_points

/datum/preferences/proc/Gear()
	return gear_list[gear_slot]

/datum/loadout_category
	var/category = ""
	var/list/gear = list()

/datum/loadout_category/New(cat)
	category = cat
	..()

/hook/startup/proc/populate_gear_list()

	//create a list of gear datums to sort
	for(var/geartype in typesof(/datum/gear)-/datum/gear)
		var/datum/gear/G = geartype
		if(!initial(G.display_name))
			continue
		if(GLOB.using_map.loadout_blacklist && (geartype in GLOB.using_map.loadout_blacklist))
			continue

		var/use_name = initial(G.display_name)
		var/use_category = initial(G.sort_category)

		if(!loadout_categories[use_category])
			loadout_categories[use_category] = new /datum/loadout_category(use_category)
		var/datum/loadout_category/LC = loadout_categories[use_category]
		G = new geartype()
		gear_datums[use_name] = G
		hash_to_gear[G.gear_hash] = G
		LC.gear[use_name] = gear_datums[use_name]

	loadout_categories = sortAssoc(loadout_categories)
	for(var/loadout_category in loadout_categories)
		var/datum/loadout_category/LC = loadout_categories[loadout_category]
		LC.gear = sortAssoc(LC.gear)
	return 1

/datum/category_item/player_setup_item/loadout
	name = "Loadout"
	sort_order = 1
	var/datum/loadout_tgui/tgui_loadout


/datum/category_item/player_setup_item/loadout/load_character(datum/pref_record_reader/R)
	pref.gear_list = R.read("gear_list")
	pref.gear_slot = R.read("gear_slot")

/datum/category_item/player_setup_item/loadout/save_character(datum/pref_record_writer/W)
	W.write("gear_list", pref.gear_list)
	W.write("gear_slot", pref.gear_slot)

/datum/category_item/player_setup_item/loadout/proc/valid_gear_choices(max_cost)
	. = list()
	var/mob/preference_mob = preference_mob()
	for(var/gear_name in gear_datums)
		var/datum/gear/G = gear_datums[gear_name]
		var/okay = 1
		if(G.whitelisted && preference_mob)
			okay = 0
			for(var/species in G.whitelisted)
				if(is_species_whitelisted(preference_mob, species))
					okay = 1
					break
		if(!okay)
			continue
		if(max_cost && G.cost > max_cost)
			continue
		. += gear_name

/datum/category_item/player_setup_item/loadout/sanitize_character()
	pref.gear_slot = sanitize_integer(pref.gear_slot, 1, config.character_setup.loadout_slots, initial(pref.gear_slot))
	if(!islist(pref.gear_list)) pref.gear_list = list()

	if(pref.gear_list.len < config.character_setup.loadout_slots)
		pref.gear_list.len = config.character_setup.loadout_slots

	pref.max_loadout_points = config.character_setup.max_loadout_points
	var/patron_tier = pref.client.donator_info.get_full_patron_tier()
	if(!isnull(patron_tier) && patron_tier != PATREON_NONE && patron_tier != PATREON_CARGO)
		pref.max_loadout_points += config.character_setup.extra_loadout_points

	for(var/index = 1 to config.character_setup.loadout_slots)
		var/list/gears = pref.gear_list[index]

		if(istype(gears))
			for(var/gear_name in gears)
				if(!(gear_name in gear_datums))
					gears -= gear_name

			var/total_cost = 0
			for(var/gear_name in gears)
				if(!gear_datums[gear_name])
					gears -= gear_name
				else if(!(gear_name in valid_gear_choices()))
					gears -= gear_name
				else
					var/datum/gear/G = gear_datums[gear_name]
					if(total_cost + G.cost > pref.max_loadout_points)
						gears -= gear_name
					else
						total_cost += G.cost
		else
			pref.gear_list[index] = list()

/datum/category_item/player_setup_item/loadout/get_lp_cost()
	var/list/gears = pref.gear_list[pref.gear_slot]
	for(var/i = 1; i <= gears.len; i++)
		var/datum/gear/G = gear_datums[gears[i]]
		if(G)
			. += G.cost

/datum/category_item/player_setup_item/loadout/content(mob/user)
	. = list()

	if(!user.client)
		return

	// Auto-open the TGUI loadout manager
	open_tgui_loadout(user)

	var/total_cost = pref.get_lp_cost()
	var/fcolor = "#3366cc"
	if(total_cost < pref.max_loadout_points)
		fcolor = "#e67300"

	. += "<center>"
	. += "<h3>Loadout Manager</h3>"
	. += "<p>The Loadout Manager is open in a separate window.</p>"
	if(pref.max_loadout_points < INFINITY)
		. += "<p><font color='[fcolor]'>[total_cost]/[pref.max_loadout_points]</font> loadout points spent in Set [pref.gear_slot].</p>"
	. += "<a href='?src=\ref[src];open_loadout=1'><b>Re-open Loadout Manager</b></a>"
	. += "</center>"
	. = jointext(., null)


/datum/category_item/player_setup_item/loadout/proc/open_tgui_loadout(mob/user)
	if(!tgui_loadout)
		tgui_loadout = new /datum/loadout_tgui(pref, user)
	tgui_loadout.tgui_interact(user)

/datum/category_item/player_setup_item/loadout/OnTopic(href, href_list, mob/user)
	ASSERT(istype(user))

	if(href_list["open_loadout"])
		open_tgui_loadout(user)
		return TOPIC_NOACTION

	if(href_list["get_opyxes"])
		SSdonations.show_donations_info(user)
		return TOPIC_NOACTION

	return ..()


/datum/gear
	var/display_name       //Name/index. Must be unique.
	var/gear_hash          //MD5 hash of display_name. Used to get item in Topic calls. See href problem with ' symbol
	var/description        //Description of this gear. If left blank will default to the description of the pathed item.
	var/path               //Path to item.
	var/cost = 1           //Number of points used. Items in general cost 1 point, storage/armor/gloves/special use costs 2 points.
	var/price              //Price of item, opyxes
	var/discount           //Discount to a price
	var/patron_tier        //Patron tier restriction
	var/slot               //Slot to equip to.
	var/list/allowed_roles //Roles that can spawn with this item.
	var/whitelisted        //Term to check the whitelist for..
	var/sort_category = "General"
	var/subgroup           //Visual subgroup header within a category. Items sharing the same subgroup are displayed under a common label.
	var/flags              //Special tweaks in new
	var/list/gear_tweaks = list() //List of datums which will alter the item after it has been spawned.

/datum/gear/New()
	gear_hash = md5(display_name)
	if(FLAGS_EQUALS(flags, GEAR_HAS_TYPE_SELECTION|GEAR_HAS_SUBTYPE_SELECTION))
		CRASH("May not have both type and subtype selection tweaks")
	if(!description)
		var/obj/O = path
		description = initial(O.desc)
	if(flags & GEAR_HAS_COLOR_SELECTION)
		gear_tweaks += gear_tweak_free_color_choice()
	if(flags & GEAR_HAS_TYPE_SELECTION)
		gear_tweaks += new /datum/gear_tweak/path/type(path)
	if(flags & GEAR_HAS_SUBTYPE_SELECTION)
		gear_tweaks += new /datum/gear_tweak/path/subtype(path)

/datum/gear/proc/is_allowed_to_equip(mob/user)
	ASSERT(user && user.client)
	ASSERT(user.client.donator_info)
	if(price && (!user.client.donator_info.is_item_available_as_for_patron(price) && !user.client.donator_info.has_item(type)))
		return FALSE
	if(patron_tier && !user.client.donator_info.patreon_tier_available(patron_tier))
		return FALSE
	if(!is_allowed_to_display(user))
		return FALSE

	return TRUE

/datum/gear/proc/get_description(metadata)
	. = description
	for(var/datum/gear_tweak/gt in gear_tweaks)
		. = gt.tweak_description(., metadata["[gt]"])

// used when we forbid seeing gear in menu without any messages.
/datum/gear/proc/is_allowed_to_display(mob/user)
	return TRUE

/datum/gear/proc/is_departmental()
	for(var/datum/gear_tweak/gt in gear_tweaks)
		if(istype(gt, /datum/gear_tweak/departmental))
			return TRUE

	return FALSE

/datum/gear/proc/set_selected_jobs(job_high, selected_jobs)
	if(job_high && !istype(job_high,/datum/job))
		CRASH("Expected /datum/job, got [job_high]")
	if(selected_jobs && !islist(selected_jobs))
		CRASH("Expected list, got [selected_jobs]")
	for(var/datum/gear_tweak/departmental/gt in gear_tweaks)
		if(!istype(gt, /datum/gear_tweak/departmental))
			continue

		gt.set_selected_jobs(job_high, selected_jobs)

/datum/gear_data
	var/path
	var/location

/datum/gear_data/New(path, location)
	src.path = path
	src.location = location

/datum/gear/proc/spawn_item(location, metadata)
	var/datum/gear_data/gd = new(path, location)
	for(var/datum/gear_tweak/gt in gear_tweaks)
		gt.tweak_gear_data(metadata["[gt]"], gd)
	var/item = new gd.path(gd.location)
	for(var/datum/gear_tweak/gt in gear_tweaks)
		gt.tweak_item(item, metadata["[gt]"])
	return item

/datum/gear/proc/spawn_on_mob(mob/living/carbon/human/H, metadata)
	var/obj/item/item = spawn_item(H, metadata)

	if(isunderwear(item))
		var/obj/item/underwear/UW = item
		UW.ForceEquipUnderwear(H)
		to_chat(H, SPAN_NOTICE("Equipping you with \the [item]!"))

	if(H.equip_to_slot_if_possible(item, slot, del_on_fail = 1, force = 1))
		to_chat(H, SPAN_NOTICE("Equipping you with \the [item]!"))
		return TRUE

	return FALSE

/datum/gear/proc/spawn_as_accessory_on_mob(mob/living/carbon/human/H, metadata)
	var/obj/item/item = spawn_item(H, metadata)

	if(H.equip_to_slot_or_del(item, slot_tie))
		return TRUE

	return FALSE

/datum/gear/proc/spawn_in_storage_or_drop(mob/living/carbon/human/H, metadata)
	var/obj/item/item = spawn_item(H, metadata)

	var/atom/placed_in = H.equip_to_storage(item)
	if(placed_in)
		to_chat(H, "<span class='notice'>Placing \the [item] in your [placed_in.name]!</span>")
	else if(H.equip_to_appropriate_slot(item))
		to_chat(H, "<span class='notice'>Placing \the [item] in your inventory!</span>")
	else if(H.put_in_hands(item))
		to_chat(H, "<span class='notice'>Placing \the [item] in your hands!</span>")
	else
		to_chat(H, "<span class='danger'>Dropping \the [item] on the ground!</span>")
		item.forceMove(get_turf(H))
		item.add_fingerprint(H)
