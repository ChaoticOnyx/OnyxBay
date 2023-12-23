
/obj/item/reagent_containers/vessel/golden_cup
	desc = "A golden cup."
	name = "golden cup"
	icon_state = "golden_cup"
	item_state = "" //nope :(
	w_class = ITEM_SIZE_HUGE
	force = 14
	throwforce = 10
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = null
	volume = 150
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	lid_type = null

/obj/item/reagent_containers/vessel/bucket
	desc = "It's a bucket."
	name = "bucket"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "bucket"
	item_state = "bucket"
	center_of_mass = "x=16;y=9"
	force = 8.5
	mod_weight = 0.75
	mod_reach = 0.5
	mod_handy = 0.75
	matter = list(MATERIAL_STEEL = 4000)
	w_class = ITEM_SIZE_NORMAL
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = "10;20;30;60;120;150;180"
	volume = 180
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	unacidable = FALSE
	lid_type = null

/obj/item/reagent_containers/vessel/bucket/full
	startswith = list(/datum/reagent/water)

/obj/item/reagent_containers/vessel/bucket/attackby(obj/D, mob/user)
	if(isprox(D))
		to_chat(user, "You add [D] to [src].")
		qdel(D)
		user.pick_or_drop(new /obj/item/bucket_sensor)
		qdel(src)
		return
	else if(istype(D, /obj/item/pipe))
		to_chat(user, "You put \the [D] into \the [src].")
		new /obj/item/hookah_construction(get_turf(src))
		qdel(D)
		qdel_self()
		return
	else if(istype(D, /obj/item/mop) || (atom_flags & ATOM_FLAG_OPEN_CONTAINER))
		if(reagents.total_volume < 1)
			to_chat(user, SPAN("warning", "\The [src] is empty!"))
		else
			reagents.trans_to_obj(D, 5)
			to_chat(user, SPAN("notice", "You wet \the [D] in \the [src]."))
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
		return
	else
		return ..()

/obj/item/reagent_containers/vessel/coffee
	name = "\improper Robust Coffee"
	desc = "Careful, the beverage you're about to enjoy is extremely hot."
	icon_state = "coffee"
	item_state = "coffee"
	center_of_mass = "x=15;y=10"
	startswith = list(/datum/reagent/drink/coffee = 30)
	lid_type = null
	unacidable = FALSE

/obj/item/reagent_containers/vessel/takeaway
	name = "takeaway cup"
	desc = "A regular takeaway cup with handy lid."
	icon_state = "takeaway_cup"
	item_state = "takeaway_cup"
	volume = 30
	filling_states = "50;65;80;100"
	possible_transfer_amounts = "5;10;15;30"
	center_of_mass = "x=17;y=12"
	pickup_sound = 'sound/effects/using/bottles/papercup.ogg'
	lid_type = /datum/vessel_lid/takeaway
	unacidable = FALSE
	var/writing = null

/obj/item/reagent_containers/vessel/takeaway/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/pen))
		if(writing)
			return
		var/t = tgui_input_text(user, "Write something on the cup...", name, writing, MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && loc != usr)
			return
		writing = t
		desc += " The writing on the sleeve reads, '[writing]'."
		user.visible_message(SPAN("notice", "\The [user] writes something on \the [src]."))
		update_icon()
		return
	..()

/obj/item/reagent_containers/vessel/takeaway/on_update_icon()
	..()
	if(writing)
		AddOverlays(OVERLAY(icon, "[icon_state]_named", alpha))

/obj/item/reagent_containers/vessel/tea
	name = "cup of Duke Purple Tea"
	desc = "An insult to Duke Purple is an insult to the Space Queen! Any proper gentleman will fight you, if you sully this tea."
	icon_state = "teacup"
	item_state = "coffee"
	center_of_mass = "x=16;y=14"
	filling_states = "100"
	base_name = "cup"
	base_icon = "teacup"
	startswith = list(/datum/reagent/drink/tea = 30)
	lid_type = null
	unacidable = FALSE

/obj/item/reagent_containers/vessel/ice
	name = "cup of ice"
	desc = "Careful, cold ice, do not chew."
	icon_state = "coffee"
	item_state = "coffee"
	center_of_mass = "x=15;y=10"
	startswith = list(/datum/reagent/drink/ice = 30)
	lid_type = null
	unacidable = FALSE

/obj/item/reagent_containers/vessel/h_chocolate
	name = "cup of Dutch hot coco"
	desc = "Made in Space South America."
	icon_state = "hot_coco"
	item_state = "coffee"
	center_of_mass = "x=15;y=13"
	startswith = list(/datum/reagent/drink/hot_coco = 30)
	lid_type = null
	unacidable = FALSE

/obj/item/reagent_containers/vessel/dry_ramen
	name = "cup ramen"
	gender = PLURAL
	desc = "Just add 10u water, self heats! A taste that reminds you of your school years."
	icon_state = "ramen"
	item_state = "ramen"
	center_of_mass = "x=16;y=11"
	startswith = list(/datum/reagent/drink/dry_ramen = 30)
	lid_type = /datum/vessel_lid/paper
	unacidable = FALSE

/obj/item/reagent_containers/vessel/chickensoup
	name = "cup of chicken soup"
	desc = "Just add 10u water, self heats! Keep yourself warm!"
	icon_state = "chickensoup"
	item_state = "ramen"
	center_of_mass = "x=16;y=11"
	startswith = list(/datum/reagent/drink/chicken_powder = 30)
	lid_type = /datum/vessel_lid/paper
	unacidable = FALSE

/obj/item/reagent_containers/vessel/sillycup
	name = "paper cup"
	desc = "A paper water cup."
	icon_state = "water_cup"
	item_state = "water_cup"
	possible_transfer_amounts = null
	volume = 10
	matter = list(MATERIAL_CARDBOARD = 100)
	center_of_mass = "x=16;y=12"
	filling_states = "50;100"
	lid_type = null
	unacidable = FALSE

/obj/item/reagent_containers/vessel/shaker
	name = "shaker"
	desc = "A metal shaker to mix drinks in."
	icon_state = "shaker"
	item_state = "shaker"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = "5;10;15;25;30;60" //Professional bartender should be able to transfer as much as needed
	volume = 120
	center_of_mass = "x=17;y=10"
	lid_type = /datum/vessel_lid/cap
	override_lid_state = LID_CLOSED
	precise_measurement = TRUE
	can_flip = TRUE
	atom_flags = ATOM_FLAG_NO_REACT
	var/shaking = FALSE

/obj/item/reagent_containers/vessel/shaker/attack_hand(mob/user)
	if(!iscarbon(user))
		return ..()

	var/mob/living/carbon/C = user
	if(C.a_intent == I_GRAB)
		return ..()

	if(C.l_hand == src && !C.get_active_hand())
		shake(user)
		return

	else if(C.r_hand == src && !C.get_active_hand())
		shake(user)
		return

	else
		return ..()

/obj/item/reagent_containers/vessel/shaker/proc/shake(mob/user)
	if(!reagents?.total_volume)
		to_chat(user, SPAN_WARNING("You won't shake an empty shaker now, will you?"))
		return

	if(lid?.state != LID_CLOSED)
		to_chat(user, SPAN_WARNING("On second thought shaking it with an open lid is not a good idea..."))
		return

	if(!shaking)
		shaking = TRUE
		var/adjective = pick(
			"furiously",
			"passionately",
			"with vigor",
			"with determination",
			"like a devil",
			"with care and love",
			"like there is no tomorrow")
		user.visible_message(SPAN_NOTICE("\The [user] shakes \the [src] [adjective]!"), SPAN_NOTICE("You shake \the [src] [adjective]!"))
		ClearOverlays()
		icon_state = "shaker_shaking"
		if(iscarbon(loc))
			var/mob/living/carbon/M = loc
			M.update_inv_l_hand()
			M.update_inv_r_hand()
		playsound(loc, 'sound/effects/shaker.ogg', 50, 1)
		if(do_after(user, 30, src))
			atom_flags ^= ATOM_FLAG_NO_REACT
			reagents?.process_reactions()
			atom_flags |= ATOM_FLAG_NO_REACT
			shaking = FALSE
		icon_state = base_icon
		update_icon()
		if(iscarbon(loc))
			var/mob/living/carbon/M = loc
			M.update_inv_l_hand()
			M.update_inv_r_hand()

/obj/item/reagent_containers/vessel/shaker/MouseDrop(obj/over_object, mob/user = usr) // Braindead copypasta from obj/item/storage
	if(!canremove)
		return

	if(iscarbon(user) || isrobot(user))
		if(!(istype(over_object, /obj/screen)))
			return ..()

		if(loc != user)
			return

		add_fingerprint(user)
		switch(over_object.name)
			if(BP_R_HAND)
				if(user.drop(src))
					user.put_in_r_hand(src)
			if(BP_L_HAND)
				if(user.drop(src))
					user.put_in_l_hand(src)

/obj/item/reagent_containers/vessel/teapot
	name = "teapot"
	desc = "An elegant teapot. It simply oozes class."
	icon_state = "teapot"
	item_state = "teapot"
	amount_per_transfer_from_this = 10
	volume = 120
	center_of_mass = "x=17;y=7"
	lid_type = null

/obj/item/reagent_containers/vessel/pitcher
	name = "pitcher"
	desc = "Everyone's best friend in the morning."
	icon_state = "pitcher"
	volume = 120
	amount_per_transfer_from_this = 10
	center_of_mass = "x=16;y=9"
	filling_states = "15;30;50;70;85;100"
	lid_type = null
	precise_measurement = TRUE

/obj/item/reagent_containers/vessel/skullgoblet
	name = "skull goblet"
	desc = "Great for dancing on the barrows of your enemies."
	icon_state = "skullcup"
	item_state = "skullmask"
	w_class = ITEM_SIZE_NORMAL
	volume = 50
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	lid_type = null
	unacidable = FALSE

/obj/item/reagent_containers/vessel/skullgoblet/gold
	name = "golden skull goblet"
	desc = "<b>Perfect</b> for dancing on the barrows of your enemies."
	icon_state = "skullcup_gold"
	unacidable = FALSE

/obj/item/reagent_containers/vessel/fitnessflask
	name = "fitness shaker"
	desc = "Big enough to contain enough protein to get perfectly swole. Don't mind the bits."
	icon_state = "fitness-cup_black"
	base_icon = "fitness-cup"
	volume = 100
	matter = list(MATERIAL_PLASTIC = 2000)
	filling_states = "1;20;30;40;50;60;70;80;90;100"
	possible_transfer_amounts = "5;10;15;25"
	lid_type = null
	precise_measurement = TRUE
	unacidable = FALSE
	var/lid_color = "black"

/obj/item/reagent_containers/vessel/fitnessflask/Initialize()
	. = ..()
	lid_color = pick("black", "red", "blue")
	update_icon()

/obj/item/reagent_containers/vessel/fitnessflask/on_update_icon()
	..()
	icon_state = "[base_icon]_[lid_color]"

/obj/item/reagent_containers/vessel/fitnessflask/proteinshake
	name = "protein shake"

/obj/item/reagent_containers/vessel/fitnessflask/proteinshake/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/nutriment, 30)
	reagents.add_reagent(/datum/reagent/iron, 10)
	reagents.add_reagent(/datum/reagent/nutriment/protein, 15)
	reagents.add_reagent(/datum/reagent/water, 45)
