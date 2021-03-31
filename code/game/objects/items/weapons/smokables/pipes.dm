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

/obj/item/clothing/mask/smokable/pipe/New()
	..()
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
		START_PROCESSING(SSobj, src)
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
			to_chat(M, "<span class='notice'>Your [name] goes out, and you empty the ash.</span>")

/obj/item/clothing/mask/smokable/pipe/attack_self(mob/user as mob)
	if(lit == 1)
		user.visible_message("<span class='notice'>[user] puts out [src].</span>", "<span class='notice'>You put out [src].</span>")
		lit = 0
		update_icon()
		STOP_PROCESSING(SSobj, src)
	else if(smoketime)
		var/turf/location = get_turf(user)
		user.visible_message("<span class='notice'>[user] empties out [src].</span>", "<span class='notice'>You empty out [src].</span>")
		new /obj/effect/decal/cleanable/ash(location)
		smoketime = 0
		reagents.clear_reagents()
		SetName("empty [initial(name)]")

/obj/item/clothing/mask/smokable/pipe/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	if(istype(W, /obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/G = W
		if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/grown))
			G = W
			if(!G.dry)
				to_chat(user, SPAN("notice", "[G] must be dried before you stuff it into [src]."))
				return
		else if(!istype(W, /obj/item/weapon/reagent_containers/food/snacks/tobacco))
			return
		if(smoketime)
			to_chat(user, SPAN("notice", "[src] is already packed."))
			return
		smoketime = 180
		if(G.reagents)
			G.reagents.trans_to_obj(src, G.reagents.total_volume)
		SetName("[G.name]-packed [initial(name)]")
		qdel(G)

	user.update_inv_wear_mask(0)
	user.update_inv_l_hand(0)
	user.update_inv_r_hand(1)

/obj/item/clothing/mask/smokable/pipe/can_be_lit_with(obj/W)
	for(var/ignitor_type in list(/obj/item/weapon/flame/lighter, /obj/item/weapon/flame/lighter/zippo, /obj/item/weapon/weldingtool, /obj/item/device/assembly/igniter, /obj/item/weapon/flame/candle, /obj/item/clothing/mask/smokable/cigarette, /obj/item/weapon/reagent_containers/glass/rag))
		if(istype(W, ignitor_type))
			return ..()

	if(istype(W, /obj/machinery/light))
		var/obj/machinery/light/mounted = W
		var/obj/item/weapon/light/bulb = mounted.lightbulb
		return bulb && istype(bulb, /obj/item/weapon/light/bulb) && bulb.status == 2 && !(mounted.stat & BROKEN)
	return FALSE

/obj/item/clothing/mask/smokable/pipe/generate_lighting_message(obj/tool, mob/holder)
	if(!holder || !tool)
		return ..()
	if(src.loc != holder)
		return ..()

	if(istype(tool, /obj/item/weapon/flame/lighter/zippo))
		return SPAN("rose", "With much care, [holder] lights \his [name] with \a [tool].")
	if(istype(tool, /obj/item/weapon/flame/candle))
		return SPAN_NOTICE("[holder] lights \his [name] with a hot wax from \a [tool].")
	if(istype(tool, /obj/item/weapon/weldingtool))
		return SPAN_NOTICE("[holder] recklessly \his [name] with \a [tool].")
	if(istype(tool, /obj/item/weapon/reagent_containers/glass/rag))
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
