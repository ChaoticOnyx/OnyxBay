/////////////////
//SMOKING PIPES//
/////////////////
/obj/item/clothing/mask/smokable/pipe
	name = "smoking pipe"
	desc = "A pipe, for smoking. Probably made of meershaum or something."
	icon_state = "pipeoff"
	item_state = "pipeoff"
	w_class = ITEM_SIZE_TINY
	icon_on = "pipeon"  //Note - these are in masks.dmi
	smoketime = 0
	chem_volume = 50
	filter_trans = 0.9

/obj/item/clothing/mask/smokable/pipe/Initialize()
	. = ..()
	name = "empty [initial(name)]"

/obj/item/clothing/mask/smokable/pipe/light(obj/used_tool, mob/holder)
	if(!src.lit && src.smoketime)
		src.lit = 1
		damtype = "fire"
		icon_state = icon_on
		item_state = icon_on
		var/turf/T = get_turf(src)
		T.visible_message(generate_lighting_message(used_tool, holder))
		smokeamount = reagents.total_volume / smoketime
		set_next_think(world.time)
		if(ismob(loc))
			var/mob/living/M = loc
			M.update_inv_wear_mask(0)
			M.update_inv_l_hand(0)
			M.update_inv_r_hand(1)

/obj/item/clothing/mask/smokable/pipe/die(nomessage = FALSE, nodestroy = FALSE)
	..()
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	if(ismob(loc))
		var/mob/living/M = loc
		if (!nomessage)
			to_chat(M, SPAN_NOTICE("Your [name] goes out, and you empty the ash."))


// Actually i take this from cigarette, but... who cares?
/obj/item/clothing/mask/smokable/pipe/attack(mob/living/M, mob/user, def_zone)

	if(lit && M == user && ishuman(M))

		var/mob/living/carbon/human/H = M
		var/obj/item/blocked = H.check_mouth_coverage()

		if(blocked)
			to_chat(H, SPAN("warning", "\The [blocked] is in the way!"))
			return TRUE

		user.visible_message("[user] takes a [pick("drag","puff","pull")] from \his [name].", \
							 "You take a [pick("drag","puff","pull")] on your [name].")

		smoke(3, TRUE)
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		return TRUE

	if(!lit && istype(M) && M.on_fire)
		user.do_attack_animation(M)
		light(M, user)
		return TRUE

	return ..()


/obj/item/clothing/mask/smokable/pipe/attack_self(mob/user)
	if(lit == 1)
		user.visible_message(SPAN_NOTICE("[user] puts out [src]."), SPAN_NOTICE("You put out [src]."))
		lit = 0
		update_icon()
		set_next_think(0)
	else if(smoketime)
		var/turf/location = get_turf(user)
		user.visible_message(SPAN_NOTICE("[user] empties out [src]."), SPAN_NOTICE("You empty out [src]."))
		new /obj/effect/decal/cleanable/ash(location)
		smoketime = 0
		reagents.clear_reagents()
		SetName("empty [initial(name)]")

/obj/item/clothing/mask/smokable/pipe/attackby(obj/item/W, mob/user)
	..()

	if(istype(W, /obj/item/reagent_containers/food))
		var/obj/item/reagent_containers/food/G = W
		if(istype(W, /obj/item/reagent_containers/food/grown))
			G = W
			if(!G.dry)
				to_chat(user, SPAN("notice", "[G] must be dried before you stuff it into [src]."))
				return
		else if(!istype(W, /obj/item/reagent_containers/food/tobacco))
			return
		if(smoketime)
			to_chat(user, SPAN("notice", "[src] is already packed."))
			return
		smoketime = 180
		if(G.reagents)
			G.reagents.trans_to_obj(src, G.reagents.total_volume)
		user.visible_message(SPAN_NOTICE("[user] stuffs [src] with [G]."), SPAN_NOTICE("You stuff [src] with [G]."))
		SetName("[G.name]-packed [initial(name)]")
		qdel(G)

	user.update_inv_wear_mask(0)
	user.update_inv_l_hand(0)
	user.update_inv_r_hand(1)

/obj/item/clothing/mask/smokable/pipe/can_be_lit_with(obj/W)
	if(istype(W, /obj/item/gun)) // This would blow all the shits out of the pipe
		return FALSE
	return ..()

/obj/item/clothing/mask/smokable/pipe/generate_lighting_message(obj/tool, mob/holder)
	if(!holder || !tool)
		return ..()
	if(src.loc != holder)
		return ..()

	if(istype(tool, /obj/item/flame/lighter/zippo))
		return SPAN("rose", "With much care, [holder] lights \his [name] with \a [tool].")
	if(istype(tool, /obj/item/flame/candle))
		return SPAN_NOTICE("[holder] lights \his [name] with a hot wax from \a [tool].")
	if(isitem(tool))
		var/obj/item/I = tool
		if(isWelder(I))
			return SPAN_NOTICE("[holder] recklessly \his [name] with \a [tool].")
	if(istype(tool, /obj/item/reagent_containers/rag))
		return SPAN_WARNING("[holder] puts a piece of \a [tool] into \a [name] to light it up.")
	if(istype(tool, /obj/item/clothing/mask/smokable/cigarette))
		return SPAN_NOTICE("[holder] dips \his [tool.name] into \a [name] to light it up.")
	if(istype(tool, /obj/machinery/light))
		return SPAN_NOTICE("[holder] cleverly lights \his [name] by a red-hot incandescent spiral inside the broken lightbulb.")

	return ..()

/obj/item/clothing/mask/smokable/pipe/cobpipe
	name = "corn cob pipe"
	desc = "A nicotine delivery system popularized by folksy backwoodsmen, kept popular in the modern age and beyond by space hipsters."
	icon_state = "cobpipeoff"
	item_state = "cobpipeoff"
	icon_on = "cobpipeon"  //Note - these are in masks.dmi
	chem_volume = 35
