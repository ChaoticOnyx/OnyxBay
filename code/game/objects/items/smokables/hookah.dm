
// Hookah itself
/obj/item/reagent_containers/vessel/hookah
	name = "hookah"
	desc = "What was supposed to be a cyborg hull once, but ended up being a hookah because of an intern roboticist's genius. Nevertheless, the design was so breathtaking, it was adapted by Acme Co., resulting in the most iconic hookah of the 26th century."
	icon = 'icons/obj/hookah.dmi'
	icon_state = "hookah_preview"
	base_icon = "hookah"
	item_state = "beaker"
	center_of_mass = "x=16;y=5"
	force = 12.5
	mod_weight = 1.35
	mod_reach = 1.0
	mod_handy = 0.6
	w_class = ITEM_SIZE_LARGE
	matter = list(MATERIAL_GLASS = 5000)
	brittle = FALSE
	label_icon = FALSE
	overlay_icon = FALSE
	lid_type = null
	volume = 60

	var/obj/item/hookah_coal/HC = null
	var/obj/item/hookah_hose/H1 = null
	var/obj/item/hookah_hose/H2 = null
	var/coal_path = /obj/item/hookah_coal
	var/has_second_hose = TRUE
	var/lit = FALSE
	var/hose_color = null

	rad_resist_type = /datum/rad_resist/hookah

/datum/rad_resist/hookah
	alpha_particle_resist = 11.8 MEGA ELECTRONVOLT
	beta_particle_resist = 0.8 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/item/reagent_containers/vessel/hookah/Initialize()
	. = ..()
	if(ispath(coal_path))
		HC = new coal_path(src)
	fix_hoses()
	update_icon()

/obj/item/reagent_containers/vessel/hookah/on_update_icon()
	..()
	icon_state = base_icon

	if(HC)
		var/image/temp = image(icon, "[HC.icon_state]_over")
		temp.color = HC.color
		AddOverlays(temp)
		if(lit)
			AddOverlays(OVERLAY(icon, "[HC.icon_state]_over_lit", alpha, RESET_COLOR))

	if(H1?.loc == src)
		var/image/temp = image(icon, "[base_icon]_left_0")
		if(hose_color)
			temp.color = hose_color
		AddOverlays(temp)
	else
		var/image/temp = image(icon, "[base_icon]_left_1")
		if(hose_color)
			temp.color = hose_color
		AddOverlays(temp)
	if(has_second_hose)
		if(H2?.loc == src)
			var/image/temp = image(icon, "[base_icon]_right_0")
			if(hose_color)
				temp.color = hose_color
			AddOverlays(temp)
		else
			var/image/temp = image(icon, "[base_icon]_right_1")
			if(hose_color)
				temp.color = hose_color
			AddOverlays(temp)

/obj/item/reagent_containers/vessel/hookah/Destroy()
	. = ..()
	if(HC)
		QDEL_NULL(HC)
	if(H1)
		QDEL_NULL(H1)
	if(H2)
		QDEL_NULL(H2)

/obj/item/reagent_containers/vessel/hookah/think()
	if(!H1 || (has_second_hose && !H2))
		fix_hoses()

	if(!isturf(loc))
		reattach_hose()
		if(has_second_hose)
			reattach_hose(TRUE)
		set_next_think(0)
		return

	var/atom/A = ismob(H1.loc) ? H1.loc : H1
	if(!(Adjacent(A) || A.loc == src))
		reattach_hose()

	if(has_second_hose)
		A = ismob(H2.loc) ? H2.loc : H2
		if(!(Adjacent(A) || A.loc == src))
			reattach_hose(TRUE)

	update_icon()
	if(H1.loc != src || (has_second_hose && H2.loc != src))
		set_next_think(world.time + 1 SECOND)
	else
		set_next_think(0)

/obj/item/reagent_containers/vessel/hookah/attack_hand(mob/user)
	if(!H1 || (has_second_hose && !H2))
		fix_hoses()
	else if(H1.loc == src)
		user.put_in_hands(H1)
		to_chat(user, SPAN("notice", "You grab \the [src]'s [H1]."))
		set_next_think(world.time + 1 SECOND)
		update_icon()
	else if(H2?.loc == src)
		user.put_in_hands(H2)
		to_chat(user, SPAN("notice", "You grab \the [src]'s [H2]."))
		set_next_think(world.time + 1 SECOND)
		update_icon()
	else
		to_chat(user, SPAN("notice", "\The [src] is already in use!"))
	return TRUE

/obj/item/reagent_containers/vessel/hookah/MouseDrop(mob/user)
	if(!CanMouseDrop(src, usr))
		return
	if(user == usr && (user.contents.Find(src) || in_range(src, user)))
		if(ishuman(user) && !user.get_active_hand())
			var/mob/living/carbon/human/H = user
			var/obj/item/organ/external/temp = H.organs_by_name[BP_R_HAND]
			if(H.hand)
				temp = H.organs_by_name[BP_L_HAND]
			if(temp && !temp.is_usable())
				to_chat(user, SPAN("warning", "You try to pick up \the [src] with your [temp.name], but cannot!"))
				return
			if(user.pick_or_drop(src, loc))
				to_chat(user, SPAN("notice", "You pick up \the [src]."))
				reattach_hose()
				if(has_second_hose)
					reattach_hose(TRUE)
	return

/obj/item/reagent_containers/vessel/hookah/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/hookah_coal))
		if(HC)
			to_chat(user, "There is already a coal installed!")
			return
		if(!user.drop(W, src))
			return
		HC = W
		to_chat(user, "You attach \the [W] to \the [src].")
		update_icon()
	else if(istype(W, /obj/item/hookah_hose))
		var/obj/item/hookah_hose/HH = W
		if(HH.my_hookah != src)
			return
		if(HH == H1)
			reattach_hose()
		else if(HH == H2)
			reattach_hose(TRUE)
		else
			HH.qdel_self()
	else if(!lit && HC?.pulls_left && (W.get_temperature_as_from_ignitor() || istype(W, /obj/item/device/assembly/igniter)))
		light()
		user.visible_message("[user] lights \the [src]'s [HC] with \the [W].", \
							 "You light \the [src].")
	else
		return ..()

/obj/item/reagent_containers/vessel/hookah/proc/smoke(mob/living/M)
	if(HC.reagents?.total_volume && HC.pulls_left) // check if it has any reagents at all
		var/mob/living/carbon/human/C = M
		if(C.check_has_mouth()) // if it's in the human/monkey mouth, transfer reagents to the mob
			HC.reagents.trans_to_mob(C, HC.smoke_amount, CHEM_INGEST, (reagents.total_volume ? 0.5 : 1.0)) // No filter = full ingest
			if(reagents?.total_volume)
				reagents.trans_to_mob(C, 0.2, CHEM_BLOOD) // Poisonous hookah be scary
			else if(prob(25))
				C.emote("cough")
		new /obj/effect/effect/cig_smoke(C.loc)
		HC.pulls_left--
		if(!HC.pulls_left)
			die()
		update_icon()
	else
		die()

/obj/item/reagent_containers/vessel/hookah/proc/reattach_hose(second = FALSE)
	var/obj/item/hookah_hose/HH = second ? H2 : H1
	if(!HH)
		fix_hoses()
		return
	if(HH.loc == src)
		return

	if(ismob(HH.loc))
		var/mob/M = HH.loc
		M.drop(HH, src, TRUE)
	else
		HH.forceMove(src)
	update_icon()

/obj/item/reagent_containers/vessel/hookah/proc/fix_hoses()
	if(H1)
		QDEL_NULL(H1)
	if(H2)
		QDEL_NULL(H2)

	H1 = new /obj/item/hookah_hose(src)
	H1.my_hookah = src
	if(has_second_hose)
		H2 = new /obj/item/hookah_hose(src)
		H2.my_hookah = src
	update_icon()

/obj/item/reagent_containers/vessel/hookah/proc/light()
	lit = TRUE
	update_icon()

/obj/item/reagent_containers/vessel/hookah/proc/die()
	lit = FALSE
	update_icon()

/obj/item/reagent_containers/vessel/hookah/proc/remove_coal(mob/user = null)
	lit = FALSE
	if(!HC)
		return
	HC.forceMove(get_turf(src))
	if(user)
		user.pick_or_drop(HC)
		to_chat(user, SPAN("notice", "You take \the [HC] from \the [src]."))
	HC = null
	update_icon()

/obj/item/reagent_containers/vessel/hookah/AltClick()
	if(Adjacent(usr) && ishuman(usr))
		remove_coal(usr)

/obj/item/reagent_containers/vessel/hookah/verb/take_coal()
	set name = "Take Coal"
	set category = "Object"
	set src in view(1)

	if(Adjacent(usr) && ishuman(usr))
		remove_coal(usr)


/obj/item/reagent_containers/vessel/hookah/makeshift
	name = "makeshift hookah"
	desc = "What a monstrosity..."
	filling_states = null
	has_second_hose = FALSE
	icon_state = "makeshift_preview"
	base_icon = "makeshift"
	item_state = "bucket"
	coal_path = null

// Mouthpieces
/obj/item/hookah_hose
	name = "hookah mouthpiece"
	desc = "God knows how many tongues this thing has seen so far."
	icon = 'icons/obj/hookah.dmi'
	icon_state = "mouthpiece"
	w_class = ITEM_SIZE_NO_CONTAINER
	var/obj/item/reagent_containers/vessel/hookah/my_hookah = null

/obj/item/hookah_hose/dropped(mob/user)
	..()
	if(!my_hookah)
		qdel_self()
		return
	if(src == my_hookah.H1)
		my_hookah.reattach_hose()
	else if(src == my_hookah.H2)
		my_hookah.reattach_hose(TRUE)
	else
		qdel_self()

/obj/item/hookah_hose/attack(mob/living/M, mob/user, def_zone)
	if(!my_hookah)
		qdel_self()
		return
	if(M == user && ishuman(M))
		if(!my_hookah.HC)
			to_chat(user, SPAN("warning", "\The [my_hookah] has no coal installed!"))
			return
		if(!my_hookah.lit)
			to_chat(user, SPAN("warning", "\The [my_hookah]'s [my_hookah.HC] ain't lit!"))
			return

		var/mob/living/carbon/human/H = M
		var/obj/item/blocked = H.check_mouth_coverage()

		if(blocked)
			to_chat(H, SPAN("warning", "\The [blocked] is in the way!"))
			return TRUE

		user.visible_message("[user] takes a [pick("drag","puff","pull")] from \the [my_hookah].", \
							 "You take a [pick("drag","puff","pull")] on \the [my_hookah].")

		my_hookah.smoke(user)
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		return TRUE
	return ..()

// Coal
/obj/item/hookah_coal
	name = "electric hookah coal"
	desc = "No real coals aboard the station. Period."
	icon = 'icons/obj/hookah.dmi'
	icon_state = "hookah_coal"
	w_class = ITEM_SIZE_SMALL
	atom_flags = null
	var/chem_volume = 40
	var/pulls_left = 0
	var/smoke_amount = 0

/obj/item/hookah_coal/New()
	..()
	atom_flags |= ATOM_FLAG_OPEN_CONTAINER

/obj/item/hookah_coal/Initialize()
	. = ..()
	create_reagents(chem_volume) // making the cigarrete a chemical holder with a maximum volume of [chem_volume]

/obj/item/hookah_coal/on_update_icon()
	ClearOverlays()
	if(pulls_left)
		AddOverlays(OVERLAY(icon, "[icon_state]_fill", alpha, RESET_COLOR))

/obj/item/hookah_coal/attack_self(mob/user)
	if(smoke_amount)
		var/turf/location = get_turf(user)
		user.visible_message(SPAN("notice", "[user] empties out [src]."), SPAN("notice", "You empty out [src]."))
		new /obj/effect/decal/cleanable/ash(location)
		pulls_left = 0
		smoke_amount = 0
		reagents.clear_reagents()
		SetName("empty [initial(name)]")
		update_icon()

/obj/item/hookah_coal/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/reagent_containers/food))
		var/obj/item/reagent_containers/food/G = W
		if(istype(W, /obj/item/reagent_containers/food/grown))
			G = W
			if(!G.dry)
				to_chat(user, SPAN("notice", "[G] must be dried before you stuff it into [src]."))
				return
		else if(!istype(W, /obj/item/reagent_containers/food/tobacco))
			return
		if(pulls_left)
			to_chat(user, SPAN("notice", "[src] is already packed."))
			return
		pulls_left = 40
		if(G.reagents)
			G.reagents.trans_to_obj(src, G.reagents.total_volume)
		smoke_amount = reagents.total_volume / pulls_left
		SetName("[G.name]-packed [initial(name)]")
		update_icon()
		qdel(G)

/obj/item/hookah_coal/makeshift
	name = "makeshift hookah coal"
	desc = "It's an ashtray with holes. And a tiny handle."
	icon_state = "makeshift_coal"

// Makeshift hookah craft
/obj/item/hookah_construction
	name = "pipe in a bucket"
	desc = "Well... That's how adventures begin."
	icon = 'icons/obj/hookah.dmi'
	icon_state = "c_makeshift0"
	w_class = ITEM_SIZE_LARGE
	var/stage = 0

/obj/item/hookah_construction/on_update_icon()
	icon_state = "c_makeshift[stage]"

/obj/item/hookah_construction/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/tape_roll) && stage == 0)
		to_chat(user, SPAN("notice", "You somehow fix the pipe in place."))
		stage++
		update_icon()
		return
	else if(istype(W, /obj/item/pen) && !istype(W, /obj/item/pen/energy_dagger) && stage == 1)
		to_chat(user, SPAN("notice", "You disassemble \the [W] to make a valve and a mouthpiece."))
		qdel(W)
		stage++
		update_icon()
		return
	else if(isCoil(W))
		var/obj/item/stack/cable_coil/coil = W
		var/_color = coil.color
		coil.use(1)
		var/obj/item/reagent_containers/vessel/hookah/makeshift/M = new (get_turf(src))
		M.hose_color = _color
		M.update_icon()
		qdel_self()
		return
	return ..()
