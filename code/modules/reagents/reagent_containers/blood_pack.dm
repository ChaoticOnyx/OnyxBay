/obj/item/storage/box/bloodpacks
	name = "blood packs box"
	desc = "This box contains blood packs."
	icon_state = "bloodbags"
	startswith = list(/obj/item/reagent_containers/ivbag = 7)

/obj/item/reagent_containers/ivbag
	name = "\improper IV bag"
	desc = "Flexible bag for IV injectors."
	icon = 'icons/obj/bloodpack.dmi'
	icon_state = "empty"
	w_class = ITEM_SIZE_SMALL
	volume = 360
	possible_transfer_amounts = "0.2;1;2"
	amount_per_transfer_from_this = REM
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	var/being_feed = FALSE
	var/vampire_marks = null
	var/mob/living/carbon/human/attached

	drop_sound = SFX_DROP_FOOD
	pickup_sound = SFX_PICKUP_FOOD

/obj/item/reagent_containers/ivbag/Destroy()
	attached = null
	. = ..()

/obj/item/reagent_containers/ivbag/on_reagent_change()
	update_icon()
	if(reagents.total_volume > volume/2)
		w_class = ITEM_SIZE_NORMAL
	else
		w_class = ITEM_SIZE_SMALL



/obj/item/reagent_containers/ivbag/attack(mob/living/carbon/human/M, mob/living/carbon/human/user, target_zone)
	if (user == M && M.mind && M.mind.vampire)
		if (being_feed)
			to_chat(user, SPAN_NOTICE("You are already feeding on \the [src]."))
			return
		if (reagents.get_reagent_amount(/datum/reagent/blood))
			user.visible_message(SPAN_WARNING("[user] raises \the [src] up to their mouth and bites into it."), SPAN_NOTICE("You raise \the [src] up to your mouth and bite into it, starting to drain its contents.<br>You need to stand still."))
			being_feed = TRUE
			vampire_marks = TRUE
			while (do_after(user, 30, src, luck_check_type = LUCK_CHECK_MED))
				if(!user)
					return
				var/blood_taken = 0
				blood_taken = min(5, reagents.get_reagent_amount(/datum/reagent/blood)/4)

				reagents.remove_reagent(/datum/reagent/blood, blood_taken*4)
				user.mind.vampire.gain_blood(blood_taken)

				if (blood_taken)
					to_chat(user, SPAN_NOTICE("You have accumulated [user.mind.vampire.blood_usable] [user.mind.vampire.blood_usable > 1 ? "units" : "unit"] of usable blood. It tastes quite stale."))

				if (reagents.get_reagent_amount(/datum/reagent/blood) < 1)
					break
			user.visible_message(SPAN_WARNING("[user] licks \his fangs dry, lowering \the [src]."), SPAN_NOTICE("You lick your fangs clean of the tasteless blood."))
			being_feed = FALSE
	else
		..()

/obj/item/reagent_containers/ivbag/examine(mob/user, infix)
	. = ..()

	if(vampire_marks)
		. += SPAN_WARNING("There are teeth marks on it.")

/obj/item/reagent_containers/attackby(obj/item/W as obj, mob/user as mob)

/obj/item/reagent_containers/ivbag/on_update_icon()
	ClearOverlays()
	var/percent = round(reagents.total_volume / volume * 100)
	if(reagents.total_volume)
		var/image/filling = image('icons/obj/bloodpack.dmi', "[round(percent,25)]")
		filling.color = reagents.get_color()
		AddOverlays(filling)
	AddOverlays(image('icons/obj/bloodpack.dmi', "top"))
	if(attached)
		AddOverlays(image('icons/obj/bloodpack.dmi', "dongle"))

/obj/item/reagent_containers/ivbag/MouseDrop(over_object, src_location, over_location)
	if(!CanMouseDrop(over_object))
		return
	if(!ismob(loc))
		return
	if(attached)
		visible_message("\The [attached] is taken off \the [src]")
		attached = null
	else if(ishuman(over_object))
		visible_message(SPAN_WARNING("\The [usr] starts hooking \the [over_object] up to \the [src]."))
		if(do_after(usr, 30, , luck_check_type = LUCK_CHECK_MED))
			to_chat(usr, "You hook \the [over_object] up to \the [src].")
			attached = over_object
			set_next_think(world.time)
	update_icon()

/obj/item/reagent_containers/ivbag/think()
	if(!ismob(loc))
		return

	if(attached)
		if(!loc.Adjacent(attached))
			attached = null
			visible_message("\The [attached] detaches from \the [src]")
			update_icon()
			return
	else
		return

	var/mob/M = loc
	if(M.l_hand != src && M.r_hand != src)
		set_next_think(world.time + 1 SECOND)
		return

	if(!reagents.total_volume)
		set_next_think(world.time + 1 SECOND)
		return

	reagents.trans_to_mob(attached, amount_per_transfer_from_this, CHEM_BLOOD)
	update_icon()
	set_next_think(world.time + 1 SECOND)

/obj/item/reagent_containers/ivbag/nanoblood
	name = "nanoblood pack"

/obj/item/reagent_containers/ivbag/nanoblood/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/nanoblood, volume)

/obj/item/reagent_containers/ivbag/blood
	name = "blood pack"
	var/blood_type = null

/obj/item/reagent_containers/ivbag/blood/Initialize()
	. = ..()
	if(blood_type)
		name = "blood pack [blood_type]"
		reagents.add_reagent(/datum/reagent/blood, volume, list("donor" = null, "blood_DNA" = null, "blood_type" = blood_type, "trace_chem" = null, "virus2" = list(), "antibodies" = list()))

/obj/item/reagent_containers/ivbag/blood/APlus
	blood_type = "A+"

/obj/item/reagent_containers/ivbag/blood/AMinus
	blood_type = "A-"

/obj/item/reagent_containers/ivbag/blood/BPlus
	blood_type = "B+"

/obj/item/reagent_containers/ivbag/blood/BMinus
	blood_type = "B-"

/obj/item/reagent_containers/ivbag/blood/OPlus
	blood_type = "O+"

/obj/item/reagent_containers/ivbag/blood/OMinus
	blood_type = "O-"
