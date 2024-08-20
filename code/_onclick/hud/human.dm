/mob/living/carbon/human
	hud_type = /datum/hud/human

/datum/hud/human/FinalizeInstantiation(ui_style='icons/hud/style/midnight.dmi', ui_color = "#ffffff", ui_alpha = 255)
	var/mob/living/carbon/human/target = mymob
	var/datum/hud_data/hud_data
	if(!istype(target))
		hud_data = new()
	else
		hud_data = target.species.hud

	if(hud_data.icon)
		ui_style = hud_data.icon

	infodisplay = list()
	static_inventory = list()
	toggleable_inventory = list()

	var/atom/movable/screen/using
	var/atom/movable/screen/inventory/inv_box

	// Draw the various inventory equipment slots.
	var/has_hidden_gear
	for(var/gear_slot in hud_data.gear)

		inv_box = new /atom/movable/screen/inventory()
		inv_box.icon = ui_style
		inv_box.color = ui_color
		inv_box.alpha = ui_alpha

		var/list/slot_data =  hud_data.gear[gear_slot]
		inv_box.SetName(slot_data["name"])
		inv_box.screen_loc =  slot_data["loc"]
		inv_box.slot_id =     slot_data["slot"]
		inv_box.icon_state =  slot_data["state"]

		if(slot_data["dir"])
			inv_box.set_dir(slot_data["dir"])

		if(slot_data["toggle"])
			toggleable_inventory += inv_box
			has_hidden_gear = 1
		else
			static_inventory += inv_box

	if(has_hidden_gear)
		using = new /atom/movable/screen()
		using.SetName("toggle")
		using.icon = ui_style
		using.icon_state = "other"
		using.screen_loc = ui_inventory
		using.color = ui_color
		using.alpha = ui_alpha
		static_inventory += using

	// Draw the attack intent dialogue.
	if(hud_data.has_a_intent)

		using = new /atom/movable/screen/intent()
		using.icon = ui_style
		static_inventory += using
		action_intent = using

		static_inventory |= using

	if(hud_data.has_m_intent)
		using = new /atom/movable/screen()
		using.SetName("mov_intent")
		using.icon = ui_style
		using.icon_state = (mymob.m_intent == M_RUN ? "running" : "walking")
		using.screen_loc = ui_movi
		using.color = ui_color
		using.alpha = ui_alpha
		static_inventory += using
		move_intent = using

	if(hud_data.has_drop)
		using = new /atom/movable/screen()
		using.SetName("drop")
		using.icon = ui_style
		using.icon_state = "act_drop"
		using.screen_loc = ui_drop_throw
		using.color = ui_color
		using.alpha = ui_alpha
		static_inventory += using

	if(hud_data.has_rest)
		using = new /atom/movable/screen()
		using.SetName("rest")
		using.icon = ui_style
		using.icon_state = "rest"
		using.screen_loc = ui_rest_act
		using.color = ui_color
		using.alpha = ui_alpha
		static_inventory += using


	if(hud_data.has_hands)

		using = new /atom/movable/screen()
		using.SetName("Equip")
		using.icon = ui_style
		using.icon_state = "act_equip"
		using.screen_loc = ui_equip
		using.color = ui_color
		using.alpha = ui_alpha
		static_inventory += using

		inv_box = new /atom/movable/screen/inventory()
		inv_box.SetName("Right Hand")
		inv_box.icon = ui_style
		inv_box.icon_state = "r_hand_inactive"
		if(mymob && !mymob.hand)	//This being 0 or null means the right hand is in use
			inv_box.icon_state = "r_hand_active"
		inv_box.screen_loc = ui_rhand
		inv_box.slot_id = slot_r_hand
		inv_box.color = ui_color
		inv_box.alpha = ui_alpha

		r_hand_hud_object = inv_box
		static_inventory += inv_box

		inv_box = new /atom/movable/screen/inventory()
		inv_box.SetName("Left Hand")
		inv_box.icon = ui_style
		inv_box.icon_state = "l_hand_inactive"
		if(mymob && mymob.hand)	//This being 1 means the left hand is in use
			inv_box.icon_state = "l_hand_active"
		inv_box.screen_loc = ui_lhand
		inv_box.slot_id = slot_l_hand
		inv_box.color = ui_color
		inv_box.alpha = ui_alpha
		l_hand_hud_object = inv_box
		static_inventory += inv_box

		using = new /atom/movable/screen/inventory()
		using.SetName("Swap Hands")
		using.icon = ui_style
		using.icon_state = "hand1"
		using.screen_loc = ui_swaphand1
		using.color = ui_color
		using.alpha = ui_alpha
		static_inventory += using

		using = new /atom/movable/screen/inventory()
		using.SetName("Swap Hands")
		using.icon = ui_style
		using.icon_state = "hand2"
		using.screen_loc = ui_swaphand2
		using.color = ui_color
		using.alpha = ui_alpha
		static_inventory += using

	if(hud_data.has_resist)
		using = new /atom/movable/screen()
		using.SetName("resist")
		using.icon = ui_style
		using.icon_state = "act_resist"
		using.screen_loc = ui_pull_resist
		using.color = ui_color
		using.alpha = ui_alpha
		static_inventory += using

	if(hud_data.has_throw)
		mymob.throw_icon = new /atom/movable/screen()
		mymob.throw_icon.icon = ui_style
		mymob.throw_icon.icon_state = "act_throw_off"
		mymob.throw_icon.SetName("throw")
		mymob.throw_icon.screen_loc = ui_drop_throw
		mymob.throw_icon.color = ui_color
		mymob.throw_icon.alpha = ui_alpha
		static_inventory += mymob.throw_icon

		mymob.pullin = new /atom/movable/screen()
		mymob.pullin.icon = ui_style
		mymob.pullin.icon_state = "pull0"
		mymob.pullin.SetName("pull")
		mymob.pullin.screen_loc = ui_pull_resist
		static_inventory += mymob.pullin

	if(hud_data.has_block)
		mymob.block_icon = new /atom/movable/screen()
		mymob.block_icon.icon = ui_style
		mymob.block_icon.icon_state = "act_block0"
		mymob.block_icon.SetName("block")
		mymob.block_icon.screen_loc = ui_block
		mymob.block_icon.color = ui_color
		mymob.block_icon.alpha = ui_alpha
		static_inventory += mymob.block_icon

	if(hud_data.has_blockswitch)
		mymob.blockswitch_icon = new /atom/movable/screen()
		mymob.blockswitch_icon.icon = ui_style
		mymob.blockswitch_icon.icon_state = "act_blockswitch0"
		mymob.blockswitch_icon.SetName("blockswitch")
		mymob.blockswitch_icon.screen_loc = ui_blockswitch
		mymob.blockswitch_icon.color = ui_color
		mymob.blockswitch_icon.alpha = ui_alpha
		static_inventory += mymob.blockswitch_icon

	if(hud_data.has_internals)
		mymob.internals = new /atom/movable/screen()
		mymob.internals.icon = ui_style
		mymob.internals.icon_state = "internal0"
		mymob.internals.SetName("internal")
		mymob.internals.screen_loc = ui_internal
		infodisplay |= mymob.internals

	if(hud_data.has_warnings)
		mymob.oxygen = new /atom/movable/screen()
		mymob.oxygen.icon = ui_style
		mymob.oxygen.icon_state = "oxy0"
		mymob.oxygen.SetName("oxygen")
		mymob.oxygen.screen_loc = ui_oxygen
		infodisplay |= mymob.oxygen

		mymob.toxin = new /atom/movable/screen()
		mymob.toxin.icon = ui_style
		mymob.toxin.icon_state = "tox0"
		mymob.toxin.SetName("toxin")
		mymob.toxin.screen_loc = ui_toxin
		infodisplay |= mymob.toxin

		mymob.fire = new /atom/movable/screen()
		mymob.fire.icon = ui_style
		mymob.fire.icon_state = "fire0"
		mymob.fire.SetName("fire")
		mymob.fire.screen_loc = ui_fire
		infodisplay |= mymob.fire

	if(hud_data.has_pain)
		mymob.pains = new /atom/movable/screen()
		mymob.pains.icon = 'icons/hud/common/screen_pain.dmi'
		mymob.pains.icon_state = "pain0"
		mymob.pains.SetName("pain")
		mymob.pains.screen_loc = ui_health
		infodisplay |= mymob.pains

	if(hud_data.has_health)
		mymob.healths = new /atom/movable/screen()
		mymob.healths.icon = ui_style
		mymob.healths.icon_state = "health"
		mymob.healths.SetName("health")
		mymob.healths.screen_loc = ui_health
		infodisplay |= mymob.healths

	if(hud_data.has_pressure)
		mymob.pressure = new /atom/movable/screen()
		mymob.pressure.icon = ui_style
		mymob.pressure.icon_state = "pressure0"
		mymob.pressure.SetName("pressure")
		mymob.pressure.screen_loc = ui_pressure
		infodisplay |= mymob.pressure

	if(hud_data.has_bodytemp)
		mymob.bodytemp = new /atom/movable/screen()
		mymob.bodytemp.icon = ui_style
		mymob.bodytemp.icon_state = "temp1"
		mymob.bodytemp.SetName("body temperature")
		mymob.bodytemp.screen_loc = ui_temp
		infodisplay |= mymob.bodytemp

	if(target.isSynthetic())
		target.cells = new /atom/movable/screen()
		target.cells.icon = 'icons/hud/mob/screen_robot.dmi'
		target.cells.icon_state = "charge-empty"
		target.cells.SetName("cell")
		target.cells.screen_loc = ui_nutrition
		infodisplay |= target.cells

	else if(hud_data.has_nutrition)
		mymob.nutrition_icon = new /atom/movable/screen()
		mymob.nutrition_icon.icon = ui_style
		mymob.nutrition_icon.icon_state = "nutrition0"
		mymob.nutrition_icon.SetName("nutrition")
		mymob.nutrition_icon.screen_loc = ui_nutrition
		infodisplay |= mymob.nutrition_icon

	if(hud_data.has_poise)
		mymob.poise_icon = new /atom/movable/screen()
		mymob.poise_icon.icon = 'icons/hud/common/screen_poise.dmi'
		mymob.poise_icon.icon_state = "50"
		mymob.poise_icon.SetName("poise")
		mymob.poise_icon.screen_loc = ui_health
		infodisplay |= mymob.poise_icon


	mymob.pain = new /atom/movable/screen/fullscreen/pain( null )
	infodisplay |= mymob.pain

	mymob.zone_sel = new /atom/movable/screen/zone_sel( null )
	mymob.zone_sel.icon = ui_style
	mymob.zone_sel.color = ui_color
	mymob.zone_sel.alpha = ui_alpha
	mymob.zone_sel.ClearOverlays()
	mymob.zone_sel.AddOverlays(image('icons/hud/common/screen_zone_sel.dmi', "[mymob.zone_sel.selecting]"))
	static_inventory |= mymob.zone_sel

	//Handle the gun settings buttons
	mymob.gun_setting_icon = new /atom/movable/screen/gun/mode(null)
	mymob.gun_setting_icon.icon = ui_style
	mymob.gun_setting_icon.color = ui_color
	mymob.gun_setting_icon.alpha = ui_alpha
	static_inventory |= mymob.gun_setting_icon

	mymob.item_use_icon = new /atom/movable/screen/gun/item(null)
	mymob.item_use_icon.icon = ui_style
	mymob.item_use_icon.color = ui_color
	mymob.item_use_icon.alpha = ui_alpha

	mymob.gun_move_icon = new /atom/movable/screen/gun/move(null)
	mymob.gun_move_icon.icon = ui_style
	mymob.gun_move_icon.color = ui_color
	mymob.gun_move_icon.alpha = ui_alpha

	mymob.radio_use_icon = new /atom/movable/screen/gun/radio(null)
	mymob.radio_use_icon.icon = ui_style
	mymob.radio_use_icon.color = ui_color
	mymob.radio_use_icon.alpha = ui_alpha

	inventory_shown = FALSE

/mob/living/carbon/human/rejuvenate()
	. = ..()
	full_pain = 0
	// And restore all internal organs...
	for (var/obj/item/organ/internal/I in internal_organs)
		I.rejuvenate()
