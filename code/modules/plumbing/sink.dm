/obj/structure/sink
	name = "sink"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "sink"
	desc = "A sink used for washing one's hands and face."
	anchored = TRUE
	//Something's being washed at the moment
	var/busy = FALSE

/obj/structure/sink/Initialize(mapload)
	. = ..()

	create_reagents(100, src)
	AddComponent(/datum/component/plumbing/simple_demand, extend_pipe_to_edge = FALSE)

/obj/structure/sink/examine(mob/user,infix)
	. = ..()
	. += SPAN_NOTICE("[reagents.total_volume]/[reagents.maximum_volume] liquids remaining.")

/obj/structure/sink/MouseDrop_T(obj/item/thing, mob/user)
	..()
	if(!istype(thing) || !thing.is_open_container())
		return ..()

	if(!user.Adjacent(src))
		return ..()

	if(!thing.reagents || thing.reagents.total_volume == 0)
		to_chat(usr, SPAN_WARNING("\The [thing] is empty."))
		return

	visible_message(SPAN_NOTICE("\The [usr] tips the contents of \the [thing] into \the [src]."))
	thing.reagents.trans_to_holder(reagents, thing.reagents.total_volume)
	thing.update_icon()

/obj/structure/sink/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(!ishuman(user))
		return

	if(!Adjacent(user))
		return

	if(reagents.total_volume < 5)
		show_splash_text(user, "Is dry!", SPAN_WARNING("\The [src] is dry!"))
		return

	if(busy)
		show_splash_text(user, "Already washing!", SPAN_WARNING("\The [src] is already occupied by someone else."))
		return

	var/selected_zone = check_zone(user.zone_sel.selecting)
	var/washing = "hands"
	if(selected_zone == BP_HEAD)
		washing = "face"

	if(selected_zone in list(BP_L_FOOT, BP_R_FOOT))
		washing = "feet"

	var/datum/gender/gender = gender_datums[user.gender]
	user.visible_message(SPAN_NOTICE("[user] starts washing [gender.his] [washing]."), \
						SPAN_NOTICE("You start washing your [washing]."))
	busy = TRUE

	playsound(get_turf(src), 'sound/effects/using/sink/washing1.ogg', 75)
	if(!do_after(user, 4 SECONDS, target = src) || QDELETED(src))
		busy = FALSE
		return

	busy = FALSE
	playsound(get_turf(src), 'sound/effects/using/sink/washing1.ogg', 75)
	var/datum/reagents/tempr = new /datum/reagents(5, GLOB.temp_reagents_holder)
	reagents.trans_to_holder(tempr, 5)
	if(washing == "face")
		if(istype(user.wear_mask))
			if(!user.wear_mask.can_get_wet)
				return

			user.wear_mask.make_wet(tempr, 2)
			user.wear_mask.clean_blood()
			user.update_inv_wear_mask()

		if(user.head?.can_get_wet)
			user.head.make_wet(tempr, 2)
			user.head.clean_blood()
			user.update_inv_head()

		var/obj/item/organ/external/head/H = user.organs_by_name[BP_HEAD]
		if(istype(H) && H.forehead_graffiti && H.graffiti_style)
			H.forehead_graffiti = null
			H.graffiti_style = null
			H.color = null
			user.lip_style = null
			return

		tempr.trans_to(user, tempr.total_volume)

	else if(washing == "hands")
		if(user.r_hand?.can_get_wet)
			user.r_hand.make_wet(tempr, 1)
			user.r_hand.clean_blood()
			user.update_inv_r_hand()

		if(user.l_hand?.can_get_wet)
			user.l_hand.make_wet(tempr, 1)
			user.l_hand.clean_blood()
			user.update_inv_l_hand()

		if(user.gloves?.can_get_wet && !(user.wear_suit?.flags_inv & HIDEGLOVES))
			user.gloves.make_wet(tempr, 1)
			user.gloves.clean_blood()
			user.update_inv_gloves()

		user.bloody_hands = null
		user.bloody_hands_mob = null
		tempr.trans_to(user, tempr.total_volume)

	else if(washing == "feet")
		if(user?.shoes?.can_get_wet && !(user.wear_suit?.flags_inv & HIDESHOES))
			user.shoes.make_wet(tempr, 1)
			user.shoes.clean_blood()
		else
			var/obj/item/organ/external/l_foot = user.organs_by_name[BP_L_FOOT]
			var/obj/item/organ/external/r_foot = user.organs_by_name[BP_R_FOOT]
			var/no_legs = FALSE
			if((!l_foot || (l_foot && (l_foot.is_stump()))) && (!r_foot || (r_foot && (r_foot.is_stump()))))
				no_legs = TRUE
			if(!no_legs)
				user.track_blood = 0
				user.feet_blood_color = null
				user.feet_blood_DNA = null
				user.update_inv_shoes(TRUE)
				tempr.trans_to(user, tempr.total_volume)

	user.visible_message(SPAN_NOTICE("[user] washes [gender.his] [washing] using [src]."), \
						SPAN_NOTICE("You wash your [washing] using [src]."))
	qdel(tempr)

/obj/structure/sink/attackby(obj/item/O as obj, mob/living/user as mob)
	if(busy)
		to_chat(user, SPAN_WARNING("Someone's already washing here."))
		return

	var/obj/item/reagent_containers/RG = O
	if(istype(RG) && RG.is_open_container())
		if(RG.reagents.total_volume == RG.volume)
			to_chat(user, SPAN_NOTICE("\The [RG] is already full!"))
			return
		playsound(loc, 'sound/effects/using/sink/filling1.ogg', 75)
		reagents.trans_to_holder(RG.reagents, min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
		user.visible_message(SPAN_NOTICE("[user] fills \the [RG] using \the [src]."), SPAN_NOTICE("You fill \the [RG] using \the [src]."))
		return

	else if (istype(O, /obj/item/melee/baton))
		var/obj/item/melee/baton/B = O
		if(B.bcell)
			if(B.bcell.charge > 0 && B.status == 1)
				flick("baton_active", src)
				user.Stun(10)
				user.stuttering = 10
				user.Weaken(10)
				if(isrobot(user))
					var/mob/living/silicon/robot/R = user
					R.cell.charge -= 20
				else
					B.deductcharge(B.hitcost)

				playsound(get_turf(src), GET_SFX(SFX_SPARK_SMALL), 50, TRUE, -1)
				user.visible_message(SPAN_DANGER("[user] was stunned by \his wet [O]!"))
				return

	var/turf/location = user.loc
	if(!isturf(location))
		return

	var/obj/item/I = O
	if(!I || !istype(I,/obj/item))
		return

	to_chat(usr, SPAN_NOTICE("You start washing \the [I]."))

	playsound(loc, 'sound/effects/using/sink/washing1.ogg', 75)

	busy = TRUE
	if(!do_after(user, 4 SECONDS, src) || QDELETED(src) || QDELETED(I))
		busy = FALSE
		return

	busy = FALSE

	if(user.get_active_hand() != I)
		return

	I.clean_blood()
	I.make_wet(reagents, 5)

	if(istype(O, /obj/item/organ/external/head))
		var/obj/item/organ/external/head/head = O
		head.forehead_graffiti = null
		head.graffiti_style = null
		head.color = null

	user.visible_message( \
		SPAN_NOTICE("[user] washes \a [I] using \the [src]."), \
		SPAN_NOTICE("You wash \a [I] using \the [src]."))

/obj/structure/sink/kitchen
	name = "kitchen sink"
	icon_state = "sink_alt"

/obj/structure/sink/puddle	//splishy splashy ^_^
	name = "puddle"
	icon_state = "puddle"
	desc = "A small pool of some liquid, ostensibly water."

/obj/structure/sink/puddle/attack_hand(mob/M as mob)
	icon_state = "puddle-splash"
	..()
	icon_state = "puddle"

/obj/structure/sink/puddle/attackby(obj/item/O as obj, mob/user as mob)
	icon_state = "puddle-splash"
	..()
	icon_state = "puddle"
