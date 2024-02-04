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
		hud_used = new /datum/hud(src)

	hud_used.show_hud(HUD_STYLE_STANDART)

/datum/hud
	/// The mob this hud belongs to
	var/mob/mymob

	/// Displayed version of the HUD
	var/hud_version = HUD_STYLE_STANDART

	/// Used to toggle the hud (F12)
	var/hud_shown = TRUE
	/// Used to show mob's inventory
	var/inventory_shown = TRUE

	/// Used to toggle action buttons
	var/action_buttons_hidden = FALSE

	var/atom/movable/screen/movable/action_button/hide_toggle/hide_actions_toggle
	var/atom/movable/screen/lingchemdisplay
	var/atom/movable/screen/r_hand_hud_object
	var/atom/movable/screen/l_hand_hud_object
	var/atom/movable/screen/action_intent
	var/atom/movable/screen/move_intent

	/// List of status objects (healths, toxin and etc.)
	var/list/atom/movable/screen/infodisplay

	/// List of all static buttons
	var/list/atom/movable/screen/static_inventory
	/// List of all equipment slot buttons
	var/list/atom/movable/screen/toggleable_inventory
	/// List of all buttons that never exit the view
	var/list/atom/movable/screen/always_visible_inventory

	var/atom/movable/screen/holomap_obj

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
	infodisplay = null
	static_inventory = null
	toggleable_inventory = null
	always_visible_inventory = null
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

	holomap_obj = new /atom/movable/screen/holomap
	LAZYADD(always_visible_inventory, holomap_obj)

	FinalizeInstantiation(ui_style, ui_color, ui_alpha)

/datum/hud/proc/FinalizeInstantiation(ui_style, ui_color, ui_alpha)
	return

/// Triggered when F12 is pressed (Unless someone changed something in the DMF)
/mob/verb/button_pressed_F12()
	set name = "F12"
	set hidden = TRUE

	if(!client)
		return

	if(client.view != world.view)
		return

	if(!hud_used)
		to_chat(usr, SPAN_WARNING("This mob type does not use a HUD."))
		return

	hud_used.show_hud()

/// Used to switch between HUD "styles", cycles  if `0` passed
/datum/hud/proc/show_hud(hud_style = 0)
	if(!ismob(mymob))
		return FALSE

	if(!mymob.client)
		return FALSE

	hud_style = clamp(hud_style, 0, HUD_STYLE_TOTAL)
	hud_version = hud_style > 0 ? hud_style : hud_version + 1
	if(hud_version > HUD_STYLE_TOTAL)
		hud_version = HUD_STYLE_STANDART

	switch(hud_version)
		if(HUD_STYLE_STANDART)
			hud_shown = TRUE
			if(length(infodisplay))
				mymob.client.screen |= infodisplay
			if(length(static_inventory))
				mymob.client.screen |= static_inventory
			if(length(toggleable_inventory) && inventory_shown)
				mymob.client.screen |= toggleable_inventory
			if(length(always_visible_inventory))
				mymob.client.screen |= always_visible_inventory
			if(action_intent)
				action_intent.screen_loc = ui_acti
		if(HUD_STYLE_REDUCED)
			hud_shown = FALSE
			if(length(infodisplay))
				mymob.client.screen |= infodisplay
			if(length(static_inventory))
				mymob.client.screen -= static_inventory
			if(length(toggleable_inventory))
				mymob.client.screen -= toggleable_inventory
			if(length(always_visible_inventory))
				mymob.client.screen |= always_visible_inventory
			if(l_hand_hud_object)
				mymob.client.screen += l_hand_hud_object
			if(r_hand_hud_object)
				mymob.client.screen += r_hand_hud_object
			if(action_intent)
				mymob.client.screen += action_intent
				action_intent.screen_loc = ui_acti_alt
			if(mymob.gun_setting_icon)
				mymob.client.screen += mymob.gun_setting_icon
		if(HUD_STYLE_NONE)
			hud_shown = FALSE
			if(length(infodisplay))
				mymob.client.screen -= infodisplay
			if(length(static_inventory))
				mymob.client.screen -= static_inventory
			if(length(toggleable_inventory))
				mymob.client.screen -= toggleable_inventory
			if(length(always_visible_inventory))
				mymob.client.screen |= always_visible_inventory

	mymob.update_action_buttons()

	hidden_inventory_update()
	persistant_inventory_update()
	reorganize_alerts()

	return TRUE

// Re-render all alerts
/datum/hud/proc/reorganize_alerts(mob/viewmob)
	var/mob/screenmob = viewmob || mymob
	if(!screenmob.client)
		return
	var/list/alerts = mymob.alerts
	if(!hud_shown)
		for(var/i in 1 to alerts.len)
			screenmob.client.screen -= alerts[alerts[i]]
		return 1
	for(var/i in 1 to alerts.len)
		var/atom/movable/screen/movable/alert/alert = alerts[alerts[i]]
		if(alert.icon_state == "template")
			alert.icon = ui_style2icon(screenmob.client.prefs.UI_style)
		switch(i)
			if(1)
				. = ui_alert1
			if(2)
				. = ui_alert2
			if(3)
				. = ui_alert3
			if(4)
				. = ui_alert4
			if(5)
				. = ui_alert5 // Right now there's 5 slots
			else
				. = ""
		alert.screen_loc = .
		screenmob.client.screen |= alert
	return 1

/atom/movable/screen/movable/alert/Click(location, control, params)
	if(!usr || !usr.client)
		return FALSE
	if(usr != owner)
		return FALSE
	if(master && click_master)
		return usr.client.Click(master, location, control, params)

	return TRUE

/atom/movable/screen/movable/alert/_examine_text(mob/user, infix, suffix)
	.="[name]"
	.+=" - [SPAN("info", desc)]"
	return FALSE

/atom/movable/screen/movable/alert/Destroy()
	. = ..()
	severity = 0
	master = null
	owner = null
	screen_loc = ""


/mob/proc/add_click_catcher()
	if(!client.void)
		client.void = create_click_catcher()
	if(!client.screen)
		client.screen = list()
	client.screen |= client.void

/mob/new_player/add_click_catcher()
	return
