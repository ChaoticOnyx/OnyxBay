
/obj/item/reagent_containers/vessel/glass
	name = "glass" // Name when empty
	base_name = "glass"
	desc = "A generic drinking glass." // Description when empty
	icon = DRINK_ICON_FILE
	base_icon = "square" // Base icon name
	item_state = "glass_empty"
	center_of_mass ="x=16;y=9"
	filling_states = "20;40;60;80;100"
	force = 5.0
	mod_weight = 0.45
	mod_reach = 0.25
	mod_handy = 0.65
	volume = 30
	matter = list(MATERIAL_GLASS = 65)
	can_be_splashed = TRUE
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = "5;10;15;30"
	lid_type = null
	label_icon = TRUE
	overlay_icon = TRUE
	brittle = TRUE
	can_flip = TRUE

	var/list/extras = list() // List of extras. Two extras maximum
	var/rim_pos // Position of the rim for fruit slices. list(y, x_left, x_right)

	drop_sound = SFX_DROP_GLASS
	pickup_sound = SFX_PICKUP_GLASS

/obj/item/reagent_containers/vessel/glass/_examine_text(mob/M)
	. = ..()

	for(var/I in extras)
		if(istype(I, /obj/item/glass_extra))
			. += "\nThere is \a [I] in \the [src]."
		else if(istype(I, /obj/item/reagent_containers/food/fruit_slice))
			. += "\nThere is \a [I] on the rim."
		else
			. += "\nThere is \a [I] somewhere on the glass. Somehow."

	if(has_ice())
		. += "\nThere is some ice floating in the drink."

	if(has_fizz())
		. += "\nIt is fizzing slightly."

/obj/item/reagent_containers/vessel/glass/proc/has_ice()
	if(reagents?.reagent_list.len > 0)
		var/datum/reagent/R = reagents.get_master_reagent()
		if(!((R.type == /datum/reagent/drink/ice) || ("ice" in R.glass_special))) // if it's not a cup of ice, and it's not already supposed to have ice in, see if the bartender's put ice in it
			if(reagents.has_reagent(/datum/reagent/drink/ice, reagents.total_volume / 10)) // 10% ice by volume
				return TRUE
	return FALSE

/obj/item/reagent_containers/vessel/glass/proc/has_fizz()
	if(reagents?.reagent_list.len > 0)
		var/datum/reagent/R = reagents.get_master_reagent()
		if(!("fizz" in R.glass_special))
			var/totalfizzy = 0
			for(var/datum/reagent/re in reagents.reagent_list)
				if("fizz" in re.glass_special)
					totalfizzy += re.volume
			if(totalfizzy >= reagents.total_volume / 5) // 20% fizzy by volume
				return TRUE
	return FALSE

/obj/item/reagent_containers/vessel/glass/proc/has_vapor()
	if(reagents?.reagent_list.len > 0)
		var/datum/reagent/R = reagents.get_master_reagent()
		if(!("vapor" in R.glass_special))
			var/totalvape = 0
			for(var/datum/reagent/re in reagents.reagent_list)
				if("vapor" in re.glass_special)
					totalvape += re.volume
			if(totalvape >= volume * 0.6) // 60% vapor by container volume
				return TRUE
	return FALSE

/obj/item/reagent_containers/vessel/glass/proc/can_add_extra(obj/item/glass_extra/GE)
	if(reagents?.reagent_list.len > 0)
		var/datum/reagent/R = reagents.get_master_reagent()
		if(R.glass_required == base_icon)
			return FALSE
	if(!("[base_icon]_[GE.glass_addition]left" in icon_states(DRINK_ICON_FILE)))
		return FALSE
	if(!("[base_icon]_[GE.glass_addition]right" in icon_states(DRINK_ICON_FILE)))
		return FALSE
	return TRUE

/obj/item/reagent_containers/vessel/glass/on_update_icon()
	underlays.Cut()
	ClearOverlays()
	icon = DRINK_ICON_FILE
	icon_state = base_icon

	if(length(reagents?.reagent_list))
		can_flip = FALSE
		var/datum/reagent/R = reagents.get_master_reagent()

		SetName("[base_name] of [R.glass_name ? R.glass_name : "something"]")
		desc = R.glass_desc ? R.glass_desc : initial(desc)

		if(R.glass_required == base_icon)
			desc = "[desc] It's classicaly served."
		if((R.glass_required == base_icon) && R.glass_icon_state)
			icon = DRINK_COCKTAILICON_FILE
			icon_state = R.glass_icon_state
			return
		else
			var/list/under_liquid = list()
			var/list/over_liquid = list()

			var/amnt = get_filling_state()

			if(has_ice())
				over_liquid |= "[base_icon][amnt]_ice"

			if(has_fizz())
				over_liquid |= "[base_icon][amnt]_fizz"

			if(has_vapor())
				over_liquid |= "[base_icon]_vapor"

			for(var/S in R.glass_special)
				if("[base_icon]_[S]" in icon_states(DRINK_ICON_FILE))
					under_liquid |= "[base_icon]_[S]"
				else if("[base_icon][amnt]_[S]" in icon_states(DRINK_ICON_FILE))
					over_liquid |= "[base_icon][amnt]_[S]"

			for(var/k in under_liquid)
				underlays += image(DRINK_ICON_FILE, src, k, -3)

			var/image/filling = image(DRINK_ICON_FILE, src, "[base_icon][amnt][R.glass_icon]", -2)
			filling.color = reagents.get_color()
			underlays += filling

			for(var/k in over_liquid)
				underlays += image(DRINK_ICON_FILE, src, k, -1)
	else
		SetName(initial(name))
		desc = initial(desc)
		can_flip = TRUE

	if(overlay_icon)
		AddOverlays(image(icon, src, overlay_icon))

	var/side = "left"
	for(var/item in extras)
		if(istype(item, /obj/item/glass_extra))
			var/obj/item/glass_extra/GE = item
			var/image/I = image(DRINK_ICON_FILE, src, "[base_icon]_[GE.glass_addition][side]")
			if(GE.glass_color)
				I.color = GE.glass_color
			if(GE.isoverlaying)
				AddOverlays(I)
			else
				underlays += I
		else if(rim_pos && istype(item, /obj/item/reagent_containers/food/fruit_slice))
			var/obj/FS = item
			var/image/I = image(FS)

			var/list/rim_pos_data = cached_key_number_decode(rim_pos)
			var/fsy = rim_pos_data["y"] - 20
			var/fsx = rim_pos_data[side == "left" ? "x_left" : "x_right"] - 16

			I.SetTransform(scale = 0.5, offset_x = fsx, offset_y = fsy)
			underlays += I
		else
			continue
		side = "right"

/obj/item/reagent_containers/vessel/glass/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/material/kitchen/utensil/spoon))
		if(user.a_intent == I_HURT)
			user.visible_message(SPAN("warning", "[user] bashes \the [src] with a spoon, shattering it to pieces! What a rube."))
			playsound(src, SFX_BREAK_WINDOW, 30, 1)
			if(reagents)
				user.visible_message(SPAN("notice", "The contents of \the [src] splash all over [user]!"))
				reagents.splash(user, reagents.total_volume)
			qdel(src)
			return
		user.visible_message(SPAN("notice", "[user] gently strikes \the [src] with a spoon, calling the room to attention."))
		playsound(src, "sound/items/wineglass.ogg", 65, 1)
	else
		return ..()
