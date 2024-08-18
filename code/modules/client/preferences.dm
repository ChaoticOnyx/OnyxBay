#define SAVE_RESET -1

/datum/preferences
	// doohickeys for savefiles
	var/is_guest = FALSE
	// Holder so it doesn't default to slot 1, rather the last one used
	var/default_slot = 1

	// Cache, mapping slot record ids to character names
	// Saves reading all the slot records when listing
	var/list/slot_names = null

	// NON-PREFERENCE STUFF
	var/warns = 0
	var/muted = 0
	var/last_ip
	var/last_id

	// Populated with an error message if loading fails.
	var/load_failed = null

	// GAME-PREFERENCES
	// Saved changlog filesize to detect if there was a change
	var/lastchangelog = ""

	// CHARACTER PREFERENCES
	// Used for the species selection window.
	var/species_preview
	// Traits which modifier characters for better or worse (mostly worse).
	var/list/traits

	var/client/client = null
	var/client_ckey = null

	var/datum/category_collection/player_setup_collection/player_setup
	var/datum/browser/panel

	var/list/char_render_holders // Should only be a key-value list of north/south/east/west = atom/movable/screen.
	var/static/list/preview_screen_locs = list(
		"1" = "character_preview_map:1,5:-12",
		"2" = "character_preview_map:1,3:15",
		"4"  = "character_preview_map:1,2:10",
		"8"  = "character_preview_map:1,1:5",
		"BG" = "character_preview_map:1,1 to 1,5"
	)

/datum/preferences/New(client/C)
	ASSERT(istype(C))

	client = C
	client_ckey = C.ckey

	..()

/datum/preferences/Destroy()
	QDEL_NULL_LIST(char_render_holders)
	return ..()

/datum/preferences/proc/setup()
	player_setup = new(src)
	gender = pick(MALE, FEMALE)
	real_name = random_name(gender,species)
	b_type = RANDOM_BLOOD_TYPE

	if(client)
		if(IsGuestKey(client.key))
			is_guest = TRUE
		else
			load_data()

	sanitize_preferences()

/datum/preferences/proc/load_data()
	load_failed = null
	var/stage = "pre"

	try
		var/pref_path = get_path(client_ckey, "client_preferences")

		if(!fexists(pref_path))
			stage = "migrate"
			// Try to migrate legacy savefile-based preferences
			if(!migrate_legacy_preferences())
				// If there's no old save, there'll be nothing to load.
				return

		stage = "load"
		load_preferences()
		load_character()

	catch(var/exception/E)
		load_failed = "{[stage]} [E]"
		throw E

/datum/preferences/proc/migrate_legacy_preferences()
	// We make some assumptions here:
	// - all relevant savefiles were version 17, which covers anything saved from 2018+
	// - legacy saves were only made on the current map
	// - a maximum of 40 slots were used

	var/legacy_pref_path = "data/player_saves/[copytext(client.ckey, 1, 2)]/[client.ckey]/preferences.sav"
	if(!fexists(legacy_pref_path))
		return 0

	var/savefile/S = new(legacy_pref_path)
	if(S["version"] != 17)
		return 0

	// Legacy version 17 ~= new version 1
	var/datum/pref_record_reader/dm_savefile/savefile_reader = new(S, 1)

	player_setup.load_preferences(savefile_reader)
	var/orig_slot = default_slot

	S.cd = "/exodus"
	for(var/slot = 1 to 40)
		if(!S.dir.Find("character[slot]"))
			continue
		S.cd = GLOB.using_map.character_load_path(S, slot)
		default_slot = slot
		player_setup.load_character(savefile_reader)
		save_character(override_key = "character_[GLOB.using_map.preferences_key()]_[slot]")
		S.cd = "/exodus"
	S.cd = "/"

	default_slot = orig_slot
	save_preferences()

	return 1

/datum/preferences/proc/get_content(mob/user)
	if(!SScharacter_setup.initialized)
		return

	if(!user?.client)
		return

	var/dat = "<center>"

	if(is_guest)
		dat += "Please create an account to save your preferences. If you have an account and are seeing this, please adminhelp for assistance."
	else if(load_failed)
		dat += "Loading your savefile failed. Please adminhelp for assistance."
	else
		dat += "Slot - "
		dat += "<a href='?src=\ref[src];load=1'>Load slot</a> - "
		dat += "<a href='?src=\ref[src];save=1'>Save slot</a> - "
		dat += "<a href='?src=\ref[src];resetslot=1'>Reset slot</a> - "
		dat += "<a href='?src=\ref[src];reload=1'>Reload slot</a>"

	dat += "<br>"
	dat += player_setup.header()
	dat += "<br><HR></center>"
	dat += player_setup.content(user)

	return dat

/datum/preferences/proc/open_setup_window(mob/user)
	if(!SScharacter_setup.initialized || SSatoms.init_state < INITIALIZATION_INNEW_REGULAR)
		to_chat(user, SPAN("notice", "Please, wait for the game to initialize!"))
		return

	if(!char_render_holders)
		update_preview_icon()
	show_character_previews()

	winshow(user, "preferences_window", TRUE)
	var/datum/browser/popup = new(user, "preferences_browser","Character Setup", 1000, 1000, src)
	var/content = {"
	<script type='text/javascript'>
		function update_content(data){
			document.getElementById('content').innerHTML = data;
		}
	</script>
	<div id='content'>[get_content(user)]</div>
	"}
	popup.set_content(content)
	popup.open(FALSE)
	onclose(user, "preferences_window", src)

	SSwarnings.show_warning(user.client, WARNINGS_NEWCOMERS, "window=Warning;size=360x240;can_resize=0;can_minimize=0")

/datum/preferences/proc/update_setup_window(mob/user)
	// TODO: Figure out how to make this work again. For now, I'm more than fed up with all this shit. ~ToTh
	//send_output(user, url_encode(get_content(user)), "preferences_browser.browser:update_content")
	open_setup_window(user)

/datum/preferences/proc/update_character_previews(mutable_appearance/MA)
	if(!client)
		return
	var/atom/movable/screen/BG = LAZYACCESS(char_render_holders, "BG")
	if(!BG)
		BG = new
		BG.appearance_flags = TILE_BOUND|PIXEL_SCALE|NO_CLIENT_COLOR
		BG.layer = TURF_LAYER
		BG.icon = 'icons/effects/preview_bg.dmi'
		LAZYSET(char_render_holders, "BG", BG)
		client.screen |= BG
	BG.icon_state = bgstate
	BG.screen_loc = preview_screen_locs["BG"]

	for(var/D in GLOB.cardinal)
		var/atom/movable/screen/O = LAZYACCESS(char_render_holders, "[D]")
		if(!O)
			O = new
			LAZYSET(char_render_holders, "[D]", O)
			client.screen |= O
		O.appearance = MA
		O.appearance_flags = PIXEL_SCALE|KEEP_TOGETHER
		O.dir = D
		O.screen_loc = preview_screen_locs["[D]"]
		O.plane = PREVIEW_PLANE

/datum/preferences/proc/show_character_previews()
	if(!client || !char_render_holders)
		return
	for(var/render_holder in char_render_holders)
		client.screen |= char_render_holders[render_holder]

/datum/preferences/proc/clear_character_previews()
	for(var/index in char_render_holders)
		var/atom/movable/screen/S = char_render_holders[index]
		client?.screen -= S
		qdel(S)
	char_render_holders = null

/datum/preferences/proc/process_link(mob/user, list/href_list)
	if(!user)
		return
	if(isliving(user))
		return

	if(href_list["preference"] == "open_whitelist_forum")
		if(config.link.forum)
			send_link(user, config.link.forum)
		else
			to_chat(user, "<span class='danger'>The forum URL is not set in the server configuration.</span>")
			return
	else if(href_list["close"])
		// User closed preferences window, cleanup anything we need to.
		clear_character_previews()
		return 1
	update_setup_window(usr)
	return 1

/datum/preferences/Topic(href, list/href_list)
	if(..())
		return 1

	if(href_list["save"])
		save_preferences()
		save_character()
	else if(href_list["reload"])
		load_preferences()
		load_character()
		sanitize_preferences()
	else if(href_list["load"])
		if(!IsGuestKey(usr.key))
			open_load_dialog(usr)
			return 1
	else if(href_list["changeslot"])
		load_character(text2num(href_list["changeslot"]))
		sanitize_preferences()
		close_load_dialog(usr)

		if(winget(usr, "preferences_browser", "is-visible") == "true")
			open_setup_window(usr)

		if(istype(client.mob, /mob/new_player))
			var/mob/new_player/M = client.mob
			M.new_player_panel()

	else if(href_list["resetslot"])
		if(real_name != input("This will reset the current slot. Enter the character's full name to confirm."))
			return 0
		load_character(SAVE_RESET)
		sanitize_preferences()
	else
		return 0

	update_setup_window(usr)
	return 1

/datum/preferences/proc/copy_to(mob/living/carbon/human/character, is_preview_copy = FALSE)
	// Sanitizing rather than saving as someone might still be editing when copy_to occurs.
	player_setup.sanitize_setup()
	character.set_species(species)
	if(be_random_name)
		real_name = random_name(gender,species)

	if(config.character_setup.humans_need_surnames)
		var/firstspace = findtext(real_name, " ")
		var/name_length = length(real_name)
		if(!firstspace)	//we need a surname
			real_name += " [pick(GLOB.last_names)]"
		else if(firstspace == name_length)
			real_name += "[pick(GLOB.last_names)]"

	character.fully_replace_character_name(real_name)

	var/datum/species/S = all_species[species]

	character.gender = gender
	character.change_body_build(S.get_body_build(gender, body))
	character.fix_body_build()
	character.age = age
	character.b_type = b_type
	character.body_height = body_height

	character.r_eyes = r_eyes
	character.g_eyes = g_eyes
	character.b_eyes = b_eyes

	character.h_style = h_style
	character.r_hair = r_hair
	character.g_hair = g_hair
	character.b_hair = b_hair
	character.r_s_hair = r_s_hair
	character.g_s_hair = g_s_hair
	character.b_s_hair = b_s_hair

	character.f_style = f_style
	character.r_facial = r_facial
	character.g_facial = g_facial
	character.b_facial = b_facial

	character.r_skin = r_skin
	character.g_skin = g_skin
	character.b_skin = b_skin

	character.s_tone = s_tone

	character.h_style = h_style
	character.f_style = f_style

	// Replace any missing limbs.
	for(var/name in BP_ALL_LIMBS)
		var/obj/item/organ/external/O = character.organs_by_name[name]
		if(!O && organ_data[name] != "amputated")
			var/list/organ_data = character.species.has_limbs[name]
			if(!islist(organ_data)) continue
			var/limb_path = organ_data["path"]
			O = new limb_path(character)

	// Destroy/cyborgize organs and limbs. The order is important for preserving low-level choices for robolimb sprites being overridden.
	for(var/name in BP_BY_DEPTH)
		var/status = organ_data[name]
		var/obj/item/organ/external/O = character.organs_by_name[name]
		if(!O)
			continue
		O.status = 0
		O.model = null
		if(status == "amputated")
			character.organs_by_name.Remove(O.organ_tag)
			character.organs -= O
			if(O.children) // This might need to become recursive.
				for(var/obj/item/organ/external/child in O.children)
					character.organs_by_name.Remove(child.organ_tag)
					character.organs -= child
		else if(status == "cyborg")
			if(rlimb_data[name])
				O.robotize(rlimb_data[name])
			else
				O.robotize()
		else //normal organ
			O.force_icon = null
			O.SetName(initial(O.name))
			O.desc = initial(O.desc)
	//For species that don't care about your silly prefs
	character.species.handle_limbs_setup(character)
	if(!is_preview_copy)
		for(var/name in list(BP_HEART,BP_EYES,BP_BRAIN,BP_LUNGS,BP_LIVER,BP_KIDNEYS,BP_STOMACH))
			var/status = organ_data[name]
			if(!status)
				continue
			var/obj/item/organ/I = character.internal_organs_by_name[name]
			if(I)
				if(status == "assisted")
					I.mechassist()
				else if(status == "mechanical")
					I.robotize()

	QDEL_NULL_LIST(character.worn_underwear)
	character.worn_underwear = list()

	for(var/underwear_category_name in all_underwear)
		var/datum/category_group/underwear/underwear_category = GLOB.underwear.categories_by_name[underwear_category_name]
		if(underwear_category)
			var/underwear_item_name = all_underwear[underwear_category_name]
			var/datum/category_item/underwear/UWD = underwear_category.items_by_name[underwear_item_name]
			var/metadata = all_underwear_metadata[underwear_category_name]
			var/obj/item/underwear/UW = UWD.create_underwear(metadata)
			if(UW)
				UW.ForceEquipUnderwear(character, FALSE)
		else
			all_underwear -= underwear_category_name

	character.backpack_setup = new(backpack, backpack_metadata["[backpack]"])

	for(var/N in character.organs_by_name)
		var/obj/item/organ/external/O = character.organs_by_name[N]
		O.markings.Cut()

	for(var/M in body_markings)
		var/datum/sprite_accessory/marking/mark_datum = GLOB.body_marking_styles_list[M]
		var/mark_color = "[body_markings[M]]"

		for(var/BP in mark_datum.body_parts)
			var/obj/item/organ/external/O = character.organs_by_name[BP]
			if(O)
				O.markings[mark_datum] = mark_color

	character.force_update_limbs()
	character.update_mutations(0)
	character.update_body(0)
	character.update_underwear(0)
	character.update_hair(0)
	character.update_facial_hair(0)
	character.update_deformities(0)
	character.update_icons()

	if(is_preview_copy)
		return

	character.flavor_texts["general"] = flavor_texts["general"]
	character.flavor_texts["head"] = flavor_texts["head"]
	character.flavor_texts["face"] = flavor_texts["face"]
	character.flavor_texts["eyes"] = flavor_texts["eyes"]
	character.flavor_texts["torso"] = flavor_texts["torso"]
	character.flavor_texts["arms"] = flavor_texts["arms"]
	character.flavor_texts["hands"] = flavor_texts["hands"]
	character.flavor_texts["legs"] = flavor_texts["legs"]
	character.flavor_texts["feet"] = flavor_texts["feet"]
	character.flavor_texts["action"] = flavor_texts["action"]

	character.med_record = med_record
	character.sec_record = sec_record
	character.gen_record = gen_record
	character.exploit_record = exploit_record

	character.home_system = home_system
	character.personal_background = background
	character.religion = religion

	if(!character.isSynthetic())
		character.set_nutrition(rand(140, 360) * character.body_build.stomach_capacity)

	return


/datum/preferences/proc/open_load_dialog(mob/user)
	var/dat  = list()
	dat += "<body>"
	dat += "<tt><center>"

	dat += "<b>Select a character slot to load</b><hr>"
	for(var/i = 1, i <= config.character_setup.character_slots, i++)
		var/name = (slot_names && slot_names[get_slot_key(i)]) || "Character[i]"
		if(i == default_slot)
			name = "<b>[name]</b>"
		dat += "<a href='?src=\ref[src];changeslot=[i]'>[name]</a><br>"

	dat += "<hr>"
	dat += "</center></tt>"
	panel = new(user, "Character Slots", "Character Slots", 300, 390, src)
	panel.set_content(jointext(dat,null))
	panel.open()

/datum/preferences/proc/close_load_dialog(mob/user)
	close_browser(user, "window=saves")
	panel.close()

/datum/preferences/proc/apply_post_login_preferences(client/update_client = null)
	client = client || update_client
	ASSERT(client)

	client.apply_fps(clientfps)

	client.update_chat_position(client.get_preference_value("INPUT_POSITION"))

	client.view_size.set_zoom()
	client.view_size.set_zoom_mode()
	client.view_size.set_default(get_screen_size(client.get_preference_value("WIDESCREEN") == GLOB.PREF_YES))

	client.attempt_fit_viewport()

	if(client.get_preference_value(/datum/client_preference/fullscreen_mode) != GLOB.PREF_NO)
		client.toggle_fullscreen(client.get_preference_value(/datum/client_preference/fullscreen_mode))

	if(client.get_preference_value(/datum/client_preference/tgui_chat) == GLOB.PREF_NO)
		winset(client, "output", "on-show=&is-disabled=0&is-visible=1")
		winset(client, "browseroutput", "is-disabled=1;is-visible=0")
	else
		client.tgui_panel.initialize()

	if(client.get_preference_value("STATUSBAR") != GLOB.PREF_YES)
		winset(client, "statusbar", "is-visible=0")
