#define FLIPPING_DURATION	7
#define FLIPPING_ROTATION	360
#define FLIPPING_INCREMENT	FLIPPING_ROTATION / 8

// -= Vessels =-
// A very basic, default type for *vesselous* types of reagent containers - drinking glasses, bottles, buckets, beakers etc.

/obj/item/reagent_containers/vessel
	name = "vessel"
	desc = "It can store liquids. Or, maybe, solids."
	icon = 'icons/obj/reagent_containers/vessels.dmi'
	icon_state = ""
	item_state = "null"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand_vessels.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand_vessels.dmi',
		)

	volume = 0.5 LITERS
	amount_per_transfer_from_this = 100
	possible_transfer_amounts = "5;10;15;25;30;60"
	w_class = ITEM_SIZE_SMALL
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	unacidable = TRUE // Most of these are made of glass
	pickup_sound = SFX_PICKUP_BOTTLE
	drop_sound = SFX_DROP_BOTTLE
	can_be_splashed = TRUE

	var/brittle = FALSE
	var/smash_weaken = 0 // Decides how much weakening it may inflict (if any) when smashing someone's head

	var/base_name = null // Name to put in front of stuff, i.e. "[base_name] of [contents]"
	var/base_desc = null
	var/base_icon = null // Base icon name for fill states
	var/filling_states   // List of percentages full that have icons
	var/overlay_icon = FALSE // Overlay drawn over the filling overlay, behind the label and lid overlays. Default values are TRUE/FALSE, actual state generates upon initialization if set to TRUE.

	var/dynamic_name = FALSE // Should it become a "vessel of something" when not empty.
	var/precise_measurement = FALSE // Decides whether one can measure contents' volume precisely.

	var/lid_type = /datum/vessel_lid/lid
	var/datum/vessel_lid/lid = null
	var/override_lid_state = null // Overrides the lid's default state if not null.
	var/override_lid_icon = null // Overrides the lid's generated icon_state if not null.

	var/start_label = null
	var/has_label = FALSE
	var/label_icon = FALSE

	//bottle flipping
	var/can_flip = FALSE
	var/last_flipping = 0
	var/image/flipping = null

	var/list/can_be_placed_into = list(
		/obj/machinery/chem_master/,
		/obj/machinery/chemical_dispenser,
		/obj/machinery/reagentgrinder,
		/obj/structure/table,
		/obj/structure/closet,
		/obj/structure/sink,
		/obj/item/storage,
		/obj/machinery/atmospherics/unary/cryo_cell,
		/obj/item/grenade/chem_grenade,
		/mob/living/bot/medbot,
		/obj/item/storage/secure/safe,
		/obj/structure/iv_drip,
		/obj/machinery/disease2/incubator,
		/obj/machinery/disposal,
		/mob/living/simple_animal/cow,
		/mob/living/simple_animal/hostile/retaliate/goat,
		/obj/machinery/computer/centrifuge,
		/obj/machinery/sleeper,
		/obj/machinery/smartfridge/,
		/obj/machinery/biogenerator,
		/obj/machinery/constructable_frame,
		/obj/machinery/radiocarbon_spectrometer
	)

/obj/item/reagent_containers/vessel/Initialize()
	. = ..()
	if(!base_icon)
		base_icon = icon_state
	if(!base_name)
		base_name = name
	if(!base_desc)
		base_desc = desc

	if(lid_type)
		lid = new lid_type()
		lid.setup(src, override_lid_state, override_lid_icon)

	if(label_icon)
		label_icon = "label_[base_icon]"
	if(overlay_icon)
		overlay_icon = "over_[base_icon]"

	if(start_label)
		SetName(base_name)
		AddComponent(/datum/component/label, start_label) // So the name isn't hardcoded and the label can be removed for reusability
	update_icon()

/obj/item/reagent_containers/vessel/Destroy()
	QDEL_NULL(lid)
	return ..()

/obj/item/reagent_containers/vessel/on_reagent_change()
	..()
	update_icon()

/obj/item/reagent_containers/vessel/pickup(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/vessel/dropped(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/vessel/attack_hand()
	..()
	update_icon()

/obj/item/reagent_containers/vessel/post_attach_label(datum/component/label/L)
	has_label = TRUE
	label_text = L.label_name
	update_icon()

/obj/item/reagent_containers/vessel/post_remove_label(datum/component/label/L)
	..()
	has_label = FALSE
	desc = base_desc
	label_text = ""
	update_icon()

/// Layers order:
// 1. Own icon_state
// 2. filling_states (if present)
// 3. overlay_icon (if present)
// 4. label_icon (if present)
// 5. lid.icon_state (if present)
/obj/item/reagent_containers/vessel/on_update_icon()
	ClearOverlays()
	if(reagents?.reagent_list.len > 0)
		if(dynamic_name)
			var/datum/reagent/R = reagents.get_master_reagent()
			update_name_label()
			SetName("[name] of [R.glass_name ? R.glass_name : "something"]")
			desc = R.glass_desc ? R.glass_desc : base_desc
		if(filling_states)
			var/image/filling = image(icon, src, "[base_icon][get_filling_state()]")
			filling.color = reagents.get_color()
			AddOverlays(filling)
	else
		update_name_label()
		desc = base_desc

	if(overlay_icon)
		AddOverlays(image(icon, src, overlay_icon))

	if(has_label && label_icon)
		AddOverlays(image(icon, src, label_icon))

	if(lid)
		AddOverlays(image(lid.icon, src, lid.get_icon_state()))

/obj/item/reagent_containers/vessel/proc/get_filling_state()
	var/percent = round((reagents.total_volume / volume) * 100)
	for(var/k in cached_number_list_decode(filling_states))
		if(percent <= k)
			return k

/obj/item/reagent_containers/vessel/update_name_label()
	if(!label_text || label_text == "")
		SetName(base_name)
	else
		SetName("[base_name] ([label_text])")

/obj/item/reagent_containers/vessel/examine(mob/user, infix)
	. = ..()

	. += "Can hold up to <b>[volume]</b>ml."

	if(get_dist(src, user) > 2)
		return

	if(precise_measurement)
		if(reagents?.reagent_list.len)
			. += SPAN_NOTICE("It contains <b>[reagents.total_volume]</b>ml of liquid.")
		else
			. += SPAN_NOTICE("It is empty.")
	else
		var/ratio = 0
		if(reagents?.total_volume)
			ratio = reagents.total_volume / volume
		var/ratio_text = ""
		switch(ratio)
			if(0)
				ratio_text = "empty"
			if(0.01 to 0.25)
				ratio_text = "almost empty"
			if(0.25 to 0.66)
				ratio_text = "half full"
			if(0.66 to 0.90)
				ratio_text = "almost full"
			else
				ratio_text = "full"
		. += SPAN_NOTICE("\The [src] is <b>[ratio_text]</b>!")

	if(lid)
		. += "\n[lid.get_examine_hint()]"

/obj/item/reagent_containers/vessel/attack_self(mob/user)
	..()
	if(lid?.toggle(user))
		update_icon()
		return

/obj/item/reagent_containers/vessel/attack(mob/M, mob/user, def_zone)
	if(force && !(item_flags & ITEM_FLAG_NO_BLUDGEON) && user.a_intent == I_HURT)
		return ..()

	if(clink_glasses(user, M, def_zone))
		return

	if(standard_feed_mob(user, M))
		return

	return FALSE

/obj/item/reagent_containers/vessel/proc/clink_glasses(mob/user, mob/target, zone)
	if(user == target)
		return FALSE
	if(user.a_intent != I_HELP)
		return FALSE
	if(zone != BP_R_HAND && zone != BP_L_HAND)
		return FALSE

	var/obj/item/reagent_containers/vessel/target_vessel

	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(zone == BP_R_HAND && isvessel(human_target.r_hand))
			target_vessel = human_target.r_hand
		else if(isvessel(human_target.l_hand))
			target_vessel = human_target.l_hand
		else if(isvessel(human_target.r_hand))
			target_vessel = human_target.r_hand

	else if(isrobot(target))
		var/mob/living/silicon/robot/robot_target = target
		if(isvessel(robot_target.module_active))
			target_vessel = robot_target.module_active

	else if(isliving(target))
		for(var/obj/item/reagent_containers/vessel/V in target)
			target_vessel = V
			break

	else
		return FALSE

	if(!target_vessel)
		return FALSE

	user.custom_emote(message = "reaches out to clink glasses with [target].")
	user.show_splash_text(target, "offers to clink!", force_skip_chat = TRUE)

	var/choice = show_radial_menu(target, user, list("accept" = image('icons/hud/radial.dmi', "radial_accept"), "decline" = image('icons/hud/radial.dmi', "radial_decline")), require_near = TRUE)

	if(!choice || choice == "decline")
		target.show_splash_text(user, "declined!", force_skip_chat = TRUE)
		target.custom_emote(message = "refuses to clink glasses with [user]!")
		return TRUE

	if(choice == "accept")
		target.show_splash_text(user, "accepted!", force_skip_chat = TRUE)
		user.custom_emote(message = "and <b>[target]</b> clink glasses! Cheers!")
		playsound(user.loc, GET_SFX(SFX_GLASSES_CLINK), 50, 1)

	if(!is_open_container() || !target_vessel.is_open_container())
		return TRUE

	if(!reagents.total_volume || !target_vessel.reagents.total_volume)
		return TRUE

	var/transfer_amount = rand(5, 25) // milliliters

	reagents.remove_any(transfer_amount)
	target_vessel.reagents.remove_any(transfer_amount)

	reagents.trans_to_holder(target_vessel.reagents, 1, transfer_amount, TRUE)
	target_vessel.reagents.trans_to_holder(reagents, 1, transfer_amount, TRUE)

	return TRUE

/obj/item/reagent_containers/vessel/standard_feed_mob(mob/user, mob/target, bypass_resist = FALSE)
	if(!is_open_container())
		to_chat(user, SPAN("notice", "You need to open \the [src] first."))
		return TRUE
	if(user.a_intent == I_HURT)
		return TRUE
	return ..()

/obj/item/reagent_containers/vessel/standard_dispenser_refill(mob/user, obj/structure/reagent_dispensers/target)
	if(!is_open_container())
		to_chat(user, SPAN("notice", "You need to open \the [src] first."))
		return TRUE
	return ..()

/obj/item/reagent_containers/vessel/standard_pour_into(mob/user, atom/target)
	if(!is_open_container())
		to_chat(user, SPAN("notice", "You need to open \the [src] first."))
		return TRUE
	return ..()

/obj/item/reagent_containers/vessel/self_feed_message(mob/user, feed_volume = 0)
	var/feed_desc = ""
	switch(feed_volume)
		if(50.01 to INFINITY)
			feed_desc = "swallow a mouth full"
		if(30.01 to 50)
			feed_desc = "take a gulp"
		if(15.01 to 30)
			feed_desc = "drink"
		if(5.01 to 15)
			feed_desc = "take a sip"
		if(0 to 5)
			feed_desc = "take a tiny sip"
	to_chat(user, SPAN("notice", "You [feed_desc] from \the [src]."))

/obj/item/reagent_containers/vessel/other_feed_message_finish(mob/user, mob/target, feed_volume = 0)
	user.visible_message("<span class='warning'>[user] has fed [target] \the [src]!</span>")
	var/feed_desc = "drink"
	switch(feed_volume)
		if(50.01 to INFINITY)
			feed_desc = "swallow a mouth full"
		if(30.01 to 50)
			feed_desc = "take a gulp"
		if(15.01 to 30)
			feed_desc = "drink"
		if(5.01 to 15)
			feed_desc = "take a sip"
		if(0 to 5)
			feed_desc = "take a tiny sip"
	target.visible_message(SPAN("warning", "[user] has fed [target] from \the [src]!"), SPAN("warning", "[user] has made you [feed_desc] from \the [src]!"))

/obj/item/reagent_containers/vessel/afterattack(obj/target, mob/user, proximity)
	if(!is_open_container() || !proximity) //Is the container open & are they next to whatever they're clicking?
		return //If not, do nothing.
	for(var/type in can_be_placed_into) //Is it something it can be placed into?
		if(istype(target, type))
			return
	if(standard_dispenser_refill(user, target)) //Are they clicking a water tank/some dispenser?
		return
	if(standard_pour_into(user, target)) //Pouring into another beaker?
		return
	return ..()

//when thrown on impact, brittle containers smash and spill their contents
/obj/item/reagent_containers/vessel/throw_impact(atom/hit_atom, datum/thrownthing/TT)
	..()
	if(brittle && TT.thrower && TT.thrower.a_intent != I_HELP)
		if(TT.speed < throw_speed || smash_check(TT.dist_travelled)) // not as reliable as smashing directly
			if(reagents)
				hit_atom.visible_message(SPAN("notice", "The contents of \the [src] splash all over [hit_atom]!"))
				reagents.splash(hit_atom, reagents.total_volume)
			smash(loc, hit_atom)

/obj/item/reagent_containers/vessel/proc/smash_check(distance)
	if(!brittle)
		return FALSE

	var/list/chance_table = list(95, 95, 90, 85, 75, 60, 40, 15) //starting from distance 0
	var/idx = max(distance + 1, 1) //since list indices start at 1
	if(idx > chance_table.len)
		return FALSE
	return prob(chance_table[idx])

/obj/item/reagent_containers/vessel/proc/smash(newloc, atom/against = null)
	if(ismob(loc))
		var/mob/M = loc
		M.drop(src, force = TRUE)

	//Creates a shattering noise and replaces the vessel with a broken_bottle
	var/obj/item/broken_bottle/B = new /obj/item/broken_bottle(newloc)
	if(prob(w_class * 2.5))
		new /obj/item/material/shard(newloc) // Create a glass shard at the target's location!
	B.SetName("broken [base_name]")
	B.icon_state = icon_state
	B.w_class = w_class
	B.force = force
	B.mod_weight = mod_weight
	B.mod_reach = mod_reach
	B.mod_handy = mod_handy

	var/icon/I = new(src.icon, src.icon_state)
	I.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
	I.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	B.icon = I

	playsound(src, SFX_BREAK_WINDOW, 70, 1)
	transfer_fingerprints_to(B)

	qdel(src)
	return B

/obj/item/reagent_containers/vessel/apply_hit_effect(mob/living/target, mob/living/user, hit_zone)
	var/blocked = ..()

	if(user.a_intent != I_HURT)
		return
	if(!smash_check(1))
		return //won't always break on the first hit

	// You are going to knock someone out for longer if they are not wearing a helmet.
	var/weaken_duration = 0
	if(blocked < 100)
		weaken_duration = smash_weaken + min(0, force - target.get_flat_armor(hit_zone, "melee") + 10)

	var/mob/living/carbon/human/H = target
	if(istype(H) && H.headcheck(hit_zone))
		var/obj/item/organ/affecting = H.get_organ(hit_zone) // headcheck should ensure that affecting is not null
		user.visible_message(SPAN("danger", "[user] smashes [src] into [H]'s [affecting.name]!"))
		if(weaken_duration)
			if(prob(100 - H.poise)) // 50% if poise is full, 100% is poise is empty
				target.apply_effect(min(weaken_duration, 5), WEAKEN, blocked) // Never weaken more than a flash!
	else
		user.visible_message(SPAN("danger", "\The [user] smashes [src] into [target]!"))

	//The reagents in the vessel splash all over the target, thanks for the idea Nodrak
	if(reagents)
		user.visible_message(SPAN("notice", "The contents of \the [src] splash all over [target]!"))
		reagents.splash(target, reagents.total_volume)

	//Finally, smash the bottle. This kills (qdel) the vessel.
	var/obj/item/broken_bottle/B = smash(target.loc, target)
	user.pick_or_drop(B, target.loc)

	return blocked


/obj/item/reagent_containers/vessel/verb/drink_whole()
	set category = "Object"
	set name = "Drink Down"

	var/mob/living/carbon/C = usr
	if(!iscarbon(C))
		return

	if(!istype(C.get_active_hand(), src))
		to_chat(C, SPAN("warning", "You need to hold \the [src] in hands!"))
		return

	if(is_open_container())
		if(!C.check_has_mouth())
			to_chat(C, SPAN("warning", "How do you intend to drink \the [src]? You don't have a mouth!"))
			return
		var/obj/item/blocked = C.check_mouth_coverage()
		if(blocked)
			to_chat(C, SPAN("warning", "\The [blocked] is in the way!"))
			return

		if(reagents.total_volume > MOUTH_CAPACITY)
			C.visible_message(\
				SPAN("notice", "[C] prepares to drink down [src]."),\
				SPAN("notice", "You prepare to drink down [src]."))
			playsound(C, 'sound/items/drinking.ogg', reagents.total_volume, 1)

		if(!do_after(C, max(1 SECOND, reagents.total_volume * 0.05)))
			if(!Adjacent(C))
				return
			standard_splash_mob(src, src)
			C.visible_message(\
				SPAN("danger", "[C] splashes \the [src]'s contents all over themself while trying drink it down."),\
				SPAN("danger", "You splash \the [src]'s contents on yourself!"))
			return

		else
			if(!Adjacent(C))
				return
			C.visible_message(\
				SPAN("notice", "[C] drinks down the whole [src]!"),\
				SPAN("notice", "You drink down the whole [src]!"))
			playsound(C, 'sound/items/drinking_after.ogg', reagents.total_volume, 1)
			reagents.trans_to_mob(C, reagents.total_volume, CHEM_INGEST)
	else
		to_chat(C, SPAN("notice", "You need to open \the [src] first!"))

/obj/item/reagent_containers/vessel/bullet_act(obj/item/projectile/Proj)
	if(Proj.get_structure_damage())
		if(brittle)
			visible_message(SPAN("warning", "\The [Proj] shatters \the [src]!"))
			smash(loc)
		else
			visible_message(SPAN("warning", "\The [Proj] hits \the [src]!"))
			throw_at(get_step(src, pick(GLOB.alldirs)), rand(2, 3), 1)
		return
	return PROJECTILE_CONTINUE

/obj/item/reagent_containers/vessel/equipped(mob/user)
	. = ..()
	if(can_flip && (user.a_intent == I_GRAB))
		bottleflip(user)

/obj/item/reagent_containers/vessel/dropped(mob/user)
	. = ..()
	if(flipping)
		item_state = initial(item_state)
		last_flipping = world.time
		if(!(MUTATION_BARTENDER in user.mutations) && prob(50))
			var/turf/flip_turf = get_turf(flipping)
			if(brittle)
				smash(flip_turf, flip_turf)
			else
				throw_impact(flip_turf, 1)
		else
			playsound(src, 'sound/effects/slap.ogg', 100, 1, -2)
		QDEL_NULL(flipping)

/obj/item/reagent_containers/vessel/proc/bottleflip(mob/user)
	playsound(src, 'sound/effects/woosh.ogg', 50, 1, -2)
	last_flipping = world.time
	var/this_flipping = last_flipping
	item_state = "invisible"
	user.update_inv_l_hand()
	user.update_inv_r_hand()
	if(flipping)
		qdel(flipping)
	var/pixOffX = 0
	var/fliplay = user.layer + 1
	var/rotate = 1
	var/anim_icon_state = initial(item_state)
	if (!anim_icon_state)
		anim_icon_state = initial(icon_state)
	if(user.active_hand == ACTIVE_HAND_RIGHT)
		switch(user.dir)
			if (NORTH)
				pixOffX = 3
				fliplay = user.layer - 1
				rotate = -1
			if (SOUTH)
				pixOffX = -4
			if (WEST)
				pixOffX = -7
			if (EAST)
				pixOffX = 2
				rotate = -1
	else
		switch(user.dir)
			if (NORTH)
				pixOffX = -4
				fliplay = user.layer - 1
			if (SOUTH)
				pixOffX = 3
				rotate = -1
			if (WEST)
				pixOffX = -2
			if (EAST)
				pixOffX = 7
				rotate = -1
	flipping = image('icons/obj/bottleflip.dmi', user, anim_icon_state, fliplay, user.dir, pixOffX)
	flipping = anim(target = user, a_icon = 'icons/obj/bottleflip.dmi', a_icon_state = anim_icon_state, sleeptime = FLIPPING_DURATION, offX = pixOffX, lay = fliplay)
	animate(flipping, pixel_y = 12, transform = turn(matrix(), rotate*FLIPPING_INCREMENT), time = FLIPPING_DURATION/8, easing = LINEAR_EASING)
	animate(pixel_y = 18, transform = turn(matrix(), rotate*2*FLIPPING_INCREMENT), time = FLIPPING_DURATION/8, easing = LINEAR_EASING)
	animate(pixel_y = 21, transform = turn(matrix(), rotate*3*FLIPPING_INCREMENT), time = FLIPPING_DURATION/8, easing = LINEAR_EASING)
	animate(pixel_y = 24, transform = turn(matrix(), rotate*4*FLIPPING_INCREMENT), time = FLIPPING_DURATION/8, easing = LINEAR_EASING)
	animate(pixel_y = 21, transform = turn(matrix(), rotate*5*FLIPPING_INCREMENT), time = FLIPPING_DURATION/8, easing = LINEAR_EASING)
	animate(pixel_y = 18, transform = turn(matrix(), rotate*6*FLIPPING_INCREMENT), time = FLIPPING_DURATION/8, easing = LINEAR_EASING)
	animate(pixel_y = 12, transform = turn(matrix(), rotate*7*FLIPPING_INCREMENT), time = FLIPPING_DURATION/8, easing = LINEAR_EASING)
	animate(pixel_y = 0, transform = turn(matrix(), rotate*8*FLIPPING_INCREMENT), time = FLIPPING_DURATION/8, easing = LINEAR_EASING)
	spawn(FLIPPING_DURATION)
		if(!flipping)
			return

		var/turf/flip_turf = get_turf(flipping)
		if(flip_turf != get_turf(user))
			to_chat(user, SPAN_WARNING("Your fail to catch back \the [src]."))
			user.drop(src, flip_turf, force = TRUE)
			QDEL_NULL(flipping)
			return

		if(loc == user && this_flipping == last_flipping) // Only the last flipping action will reset the bottle's vars
			if(!(MUTATION_BARTENDER in user.mutations) && prob(50))
				to_chat(user, SPAN_WARNING("Your fail to catch back \the [src]."))
				user.drop(src, flipping.loc, force = TRUE)
			else
				item_state = initial(item_state)
				user.update_inv_l_hand()
				user.update_inv_r_hand()
				user.ImmediateOverlayUpdate()
				playsound(src, 'sound/effects/slap.ogg', 50, 1, -2)
			QDEL_NULL(flipping)
			last_flipping = world.time

//Keeping this here for now, I'll ask if I should keep it here.
/obj/item/broken_bottle
	name = "Broken Bottle"
	desc = "What used to be a glass vessel earlier, with a sharp broken bottom."
	icon = 'icons/obj/reagent_containers/bottles.dmi'
	icon_state = "broken_bottle"
	force = 8.5
	mod_weight = 0.5
	mod_reach = 0.4
	mod_handy = 0.75
	armor_penetration = 20
	throwforce = 5
	throw_range = 5
	item_state = "beer"
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("stabbed", "slashed", "attacked")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharp = 1
	edge = 0
	unacidable = 1
	var/icon/broken_outline = icon('icons/obj/reagent_containers/vessels.dmi', "broken")

	drop_sound = SFX_DROP_GLASSSMALL
	pickup_sound = SFX_PICKUP_GLASSSMALL
