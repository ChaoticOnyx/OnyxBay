/*
	The hud datum
	Used to show and hide huds for all the different mob types,
	including inventories and item quick actions.
*/

/mob
	var/hud_type = null
	var/datum/hud/hud_used = null
	var/list/master_planes = null

/mob/proc/InitializeHud()
	if(hud_used)
		qdel(hud_used)
	if(hud_type)
		hud_used = new hud_type(src)
	else
		hud_used = new /datum/hud

	InitializePlanes()
	UpdatePlanes()

/mob/proc/InitializePlanes()
	if (!master_planes)
		master_planes = list()

	var/list/planes = list(
		/obj/screen/plane_master/ambient_occlusion,
		/obj/screen/plane_master/mouse_invisible
	)

	for (var/plane_type in planes)
		var/obj/screen/plane_master/plane = new plane_type()

		master_planes["[plane.plane]"] = plane
		client.screen += plane

/mob/proc/UpdatePlanes()
	if (!master_planes)
		return

	for (var/plane_num in master_planes)
		var/obj/screen/plane_master/plane = master_planes[plane_num]
		plane.backdrop(src)

/datum/hud
	var/mob/mymob

	var/hud_shown = 1			//Used for the HUD toggle (F12)
	var/inventory_shown = 1		//the inventory
	var/show_intent_icons = 0
	var/hotkey_ui_hidden = 0	//This is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)

	var/obj/screen/lingchemdisplay
	var/obj/screen/r_hand_hud_object
	var/obj/screen/l_hand_hud_object
	var/obj/screen/action_intent
	var/obj/screen/move_intent

	var/list/adding
	var/list/other
	var/list/obj/screen/hotkeybuttons

	var/obj/screen/movable/action_button/hide_toggle/hide_actions_toggle
	var/action_buttons_hidden = 0

/datum/hud/New(mob/owner)
	mymob = owner
	instantiate()
	..()

/datum/hud/Destroy()
	. = ..()
	lingchemdisplay = null
	r_hand_hud_object = null
	l_hand_hud_object = null
	action_intent = null
	move_intent = null
	adding = null
	other = null
	hotkeybuttons = null
	mymob = null

/datum/hud/proc/hidden_inventory_update()
	if(!mymob) return
	if(ishuman(mymob))
		var/mob/living/carbon/human/H = mymob
		for(var/gear_slot in H.species.hud.gear)
			var/list/hud_data = H.species.hud.gear[gear_slot]
			if(inventory_shown && hud_shown)
				switch(hud_data["slot"])
					if(slot_head)
						if(H.head)      H.head.screen_loc =      hud_data["loc"]
					if(slot_shoes)
						if(H.shoes)     H.shoes.screen_loc =     hud_data["loc"]
					if(slot_l_ear)
						if(H.l_ear)     H.l_ear.screen_loc =     hud_data["loc"]
					if(slot_r_ear)
						if(H.r_ear)     H.r_ear.screen_loc =     hud_data["loc"]
					if(slot_gloves)
						if(H.gloves)    H.gloves.screen_loc =    hud_data["loc"]
					if(slot_glasses)
						if(H.glasses)   H.glasses.screen_loc =   hud_data["loc"]
					if(slot_w_uniform)
						if(H.w_uniform) H.w_uniform.screen_loc = hud_data["loc"]
					if(slot_wear_suit)
						if(H.wear_suit) H.wear_suit.screen_loc = hud_data["loc"]
					if(slot_wear_mask)
						if(H.wear_mask) H.wear_mask.screen_loc = hud_data["loc"]
			else
				switch(hud_data["slot"])
					if(slot_head)
						if(H.head)      H.head.screen_loc =      null
					if(slot_shoes)
						if(H.shoes)     H.shoes.screen_loc =     null
					if(slot_l_ear)
						if(H.l_ear)     H.l_ear.screen_loc =     null
					if(slot_r_ear)
						if(H.r_ear)     H.r_ear.screen_loc =     null
					if(slot_gloves)
						if(H.gloves)    H.gloves.screen_loc =    null
					if(slot_glasses)
						if(H.glasses)   H.glasses.screen_loc =   null
					if(slot_w_uniform)
						if(H.w_uniform) H.w_uniform.screen_loc = null
					if(slot_wear_suit)
						if(H.wear_suit) H.wear_suit.screen_loc = null
					if(slot_wear_mask)
						if(H.wear_mask) H.wear_mask.screen_loc = null

/datum/hud/proc/persistant_inventory_update()
	if(!mymob)
		return

	if(ishuman(mymob))
		var/mob/living/carbon/human/H = mymob
		for(var/gear_slot in H.species.hud.gear)
			var/list/hud_data = H.species.hud.gear[gear_slot]
			if(hud_shown)
				switch(hud_data["slot"])
					if(slot_s_store)
						if(H.s_store) H.s_store.screen_loc = hud_data["loc"]
					if(slot_wear_id)
						if(H.wear_id) H.wear_id.screen_loc = hud_data["loc"]
					if(slot_belt)
						if(H.belt)    H.belt.screen_loc =    hud_data["loc"]
					if(slot_back)
						if(H.back)    H.back.screen_loc =    hud_data["loc"]
					if(slot_l_store)
						if(H.l_store) H.l_store.screen_loc = hud_data["loc"]
					if(slot_r_store)
						if(H.r_store) H.r_store.screen_loc = hud_data["loc"]
			else
				switch(hud_data["slot"])
					if(slot_s_store)
						if(H.s_store) H.s_store.screen_loc = null
					if(slot_wear_id)
						if(H.wear_id) H.wear_id.screen_loc = null
					if(slot_belt)
						if(H.belt)    H.belt.screen_loc =    null
					if(slot_back)
						if(H.back)    H.back.screen_loc =    null
					if(slot_l_store)
						if(H.l_store) H.l_store.screen_loc = null
					if(slot_r_store)
						if(H.r_store) H.r_store.screen_loc = null


/datum/hud/proc/instantiate()
	if(!ismob(mymob)) return 0
	if(!mymob.client) return 0
	var/ui_style = ui_style2icon(mymob.client.prefs.UI_style)
	var/ui_color = mymob.client.prefs.UI_style_color
	var/ui_alpha = mymob.client.prefs.UI_style_alpha


	FinalizeInstantiation(ui_style, ui_color, ui_alpha)

	if(ishuman(mymob))
		if(RADAR in mymob.augmentations)
			addtimer(CALLBACK(src, .proc/hud_radar), 2)

/datum/hud/proc/hud_radar()
	var/mob/living/carbon/human/H = mymob
	if(mymob.radar_open)
		H.start_radar()
	else
		H.place_radar_closed()

/datum/hud/proc/FinalizeInstantiation(var/ui_style, var/ui_color, var/ui_alpha)
	return

//Triggered when F12 is pressed (Unless someone changed something in the DMF)
/mob/verb/button_pressed_F12(var/full = 0 as null)
	set name = "F12"
	set hidden = 1

	if(!hud_used)
		to_chat(usr, "<span class='warning'>This mob type does not use a HUD.</span>")
		return

	if(!ishuman(src))
		to_chat(usr, "<span class='warning'>Inventory hiding is currently only supported for human mobs, sorry.</span>")
		return

	if(!client) return
	if(client.view != world.view)
		return
	if(hud_used.hud_shown)
		hud_used.hud_shown = 0
		if(src.hud_used.adding)
			src.client.screen -= src.hud_used.adding
		if(src.hud_used.other)
			src.client.screen -= src.hud_used.other
		if(src.hud_used.hotkeybuttons)
			src.client.screen -= src.hud_used.hotkeybuttons

		//Due to some poor coding some things need special treatment:
		//These ones are a part of 'adding', 'other' or 'hotkeybuttons' but we want them to stay
		if(!full)
			src.client.screen += src.hud_used.l_hand_hud_object	//we want the hands to be visible
			src.client.screen += src.hud_used.r_hand_hud_object	//we want the hands to be visible
			src.client.screen += src.hud_used.action_intent		//we want the intent swticher visible
			src.hud_used.action_intent.screen_loc = ui_acti_alt	//move this to the alternative position, where zone_select usually is.
		else
			src.client.screen -= src.healths
			src.client.screen -= src.internals
			src.client.screen -= src.gun_setting_icon

		//These ones are not a part of 'adding', 'other' or 'hotkeybuttons' but we want them gone.
		src.client.screen -= src.zone_sel	//zone_sel is a mob variable for some reason.

	else
		hud_used.hud_shown = 1
		if(src.hud_used.adding)
			src.client.screen += src.hud_used.adding
		if(src.hud_used.other && src.hud_used.inventory_shown)
			src.client.screen += src.hud_used.other
		if(src.hud_used.hotkeybuttons && !src.hud_used.hotkey_ui_hidden)
			src.client.screen += src.hud_used.hotkeybuttons
		if(src.healths)
			src.client.screen |= src.healths
		if(src.internals)
			src.client.screen |= src.internals
		if(src.gun_setting_icon)
			src.client.screen |= src.gun_setting_icon

		src.hud_used.action_intent.screen_loc = ui_acti //Restore intent selection to the original position
		src.client.screen += src.zone_sel				//This one is a special snowflake

	hud_used.hidden_inventory_update()
	hud_used.persistant_inventory_update()
	update_action_buttons()

//Similar to button_pressed_F12() but keeps zone_sel, gun_setting_icon, and healths.
/mob/proc/toggle_zoom_hud()
	if(!hud_used)
		return
	if(!ishuman(src))
		return
	if(!client)
		return
	if(client.view != world.view)
		return

	if(hud_used.hud_shown)
		hud_used.hud_shown = 0
		if(src.hud_used.adding)
			src.client.screen -= src.hud_used.adding
		if(src.hud_used.other)
			src.client.screen -= src.hud_used.other
		if(src.hud_used.hotkeybuttons)
			src.client.screen -= src.hud_used.hotkeybuttons
		src.client.screen -= src.internals
		src.client.screen += src.hud_used.action_intent		//we want the intent swticher visible
	else
		hud_used.hud_shown = 1
		if(src.hud_used.adding)
			src.client.screen += src.hud_used.adding
		if(src.hud_used.other && src.hud_used.inventory_shown)
			src.client.screen += src.hud_used.other
		if(src.hud_used.hotkeybuttons && !src.hud_used.hotkey_ui_hidden)
			src.client.screen += src.hud_used.hotkeybuttons
		if(src.internals)
			src.client.screen |= src.internals
		src.hud_used.action_intent.screen_loc = ui_acti //Restore intent selection to the original position

	hud_used.hidden_inventory_update()
	hud_used.persistant_inventory_update()
	update_action_buttons()

/mob/proc/add_click_catcher()
	if(!client.void)
		client.void = create_click_catcher()
	if(!client.screen)
		client.screen = list()
	client.screen |= client.void

/mob/new_player/add_click_catcher()
	return

//radar stuff
/mob/living/carbon/human/proc/close_radar()
	radar_open = FALSE
	for(var/obj/screen/x in client.screen)
		if( (x.name == "radar" && x.icon == 'icons/misc/radar.dmi') || (x in radar_blips) )
			client.screen -= x
			qdel(x)

	place_radar_closed()

/mob/living/carbon/human/proc/place_radar_closed()
	var/obj/screen/closedradar = new()
	closedradar.icon = 'icons/misc/radar.dmi'
	closedradar.icon_state = "radarclosed"
	closedradar.screen_loc = "WEST,NORTH-1"
	closedradar.name = "radar closed"
	client.screen += closedradar

/mob/living/carbon/human/proc/start_radar()

	for(var/obj/screen/x in client.screen)
		if(x.name == "radar closed" && x.icon == 'icons/misc/radar.dmi')
			client.screen -= x
			qdel(x)

	var/obj/screen/cornerA = new()
	cornerA.icon = 'icons/misc/radar.dmi'
	cornerA.icon_state = "radar(1,1)"
	cornerA.screen_loc = "WEST,NORTH-2"
	cornerA.name = "radar"

	var/obj/screen/cornerB = new()
	cornerB.icon = 'icons/misc/radar.dmi'
	cornerB.icon_state = "radar(2,1)"
	cornerB.screen_loc = "WEST+1,NORTH-2"
	cornerB.name = "radar"

	var/obj/screen/cornerC = new()
	cornerC.icon = 'icons/misc/radar.dmi'
	cornerC.icon_state = "radar(1,2)"
	cornerC.screen_loc = "WEST,NORTH-1"
	cornerC.name = "radar"

	var/obj/screen/cornerD = new()
	cornerD.icon = 'icons/misc/radar.dmi'
	cornerD.icon_state = "radar(2,2)"
	cornerD.screen_loc = "WEST+1,NORTH-1"
	cornerD.name = "radar"

	client.screen += cornerA
	client.screen += cornerB
	client.screen += cornerC
	client.screen += cornerD

	radar_open = TRUE

	while(radar_open && (RADAR in augmentations))
		update_radar()
		sleep(6)

/mob/living/carbon/human/proc/update_radar()

	if(!client) return
	var/list/found_targets = list()

	var/max_dist = 29 // 29 tiles is the max distance

	// If the mob is inside a turf, set the center to the object they're in
	var/atom/distance_ref = src
	if(!isturf(src.loc))
		distance_ref = loc

	// Clear the radar_blips cache
	for(var/x in radar_blips)
		client.screen -= x
		qdel(x)
	radar_blips = list()

	var/starting_px = 3
	var/starting_py = 3

	for(var/mob/living/M in orange(max_dist, distance_ref))
		if(M.stat == 2) continue
		found_targets.Add(M)

	for(var/obj/mecha/M in orange(max_dist, distance_ref))
		if(!M.occupant) continue
		found_targets.Add(M)

	for(var/obj/structure/closet/C in orange(max_dist, distance_ref))
		for(var/mob/living/M in C.contents)
			if(M.stat == 2) continue
			found_targets.Add(M)

	// Loop through all living mobs in a range.
	for(var/atom/A in found_targets)

		var/a_x = A.x
		var/a_y = A.y

		if(!isturf(A.loc))
			a_x = A.loc.x
			a_y = A.loc.y

		var/blip_x = max_dist + (-( distance_ref.x-a_x ) ) + starting_px
		var/blip_y = max_dist + (-( distance_ref.y-a_y ) ) + starting_py
		var/obj/screen/blip = new()
		blip.icon = 'icons/misc/radar.dmi'
		blip.name = "Blip"
		blip.layer = 21
		blip.screen_loc = "WEST:[blip_x-1],NORTH-2:[blip_y-1]" // offset -1 because the center of the blip is not at the bottomleft corner (14)

		if(istype(A, /mob/living))
			var/mob/living/M = A
			if(ishuman(M))
				if(M:wear_id)
					var/job = M:wear_id:GetJobName()
					if(job == "Security Officer")
						blip.icon_state = "secblip"
						blip.name = "Security Officer"
					else if(job == "Captain" || job == "Research Director" || job == "Chief Engineer" || job == "Chief Medical Officer" || job == "Head of Security" || job == "Head of Personnel")
						blip.icon_state = "headblip"
						blip.name = "Station Head"
					else
						blip.icon_state = "civblip"
						blip.name = "Civilian"
				else
					blip.icon_state = "civblip"
					blip.name = "Civilian"

			else if(issilicon(M))
				blip.icon_state = "roboblip"
				blip.name = "Robotic Organism"

			else
				blip.icon_state = "unknownblip"
				blip.name = "Unknown Organism"

		else if(istype(A, /obj/mecha))
			blip.icon_state = "roboblip"
			blip.name = "Robotic Organism"

		radar_blips.Add(blip)
		client.screen += blip
