#define STAGE_BASIC 0
#define STAGE_DETONATOR 1
#define STAGE_READY 2
/obj/item/grenade/chem_grenade
	name = "grenade casing"
	icon_state = "chemg"
	item_state = "chemg"
	desc = "A hand made chemical grenade."
	w_class = ITEM_SIZE_SMALL
	force = 2.0
	det_time = null
	unacidable = 1
	var/stage = STAGE_BASIC
	var/state = 0
	var/list/beakers = new /list()
	var/list/allowed_containers = list(/obj/item/reagent_containers/vessel/beaker, /obj/item/reagent_containers/vessel/bottle/chemical)
	var/affected_area = 3

/obj/item/grenade/chem_grenade/Initialize()
	. = ..()
	if(stage == STAGE_BASIC)
		QDEL_NULL(detonator) // Yea, we surely don't need it, if chemnade is not ready.
	create_reagents(1000)

/obj/item/grenade/chem_grenade/attack_self(mob/user)
	if(stage != STAGE_READY)
		if(detonator)
			detonator.detached()
			user.pick_or_drop(detonator)
			detonator = null
			det_time = null
			stage = STAGE_BASIC
			update_icon()
		else if(beakers.len)
			for(var/obj/B in beakers)
				if(istype(B))
					beakers -= B
					user.pick_or_drop(B)
		SetName("unsecured grenade with [beakers.len] containers[detonator?" and detonator":""]")
	if(stage == STAGE_READY && !active && clown_check(user))
		if(safety_pin)
			user.pick_or_drop(safety_pin)
			safety_pin = null
			playsound(loc, 'sound/weapons/pin_pull.ogg', 40, 1)
			to_chat(user, SPAN("warning", "You remove the safety pin!"))
			update_icon()
			return
		to_chat(user, SPAN("warning", "You prime \the [name]!"))

		msg_admin_attack("[user.name] ([user.ckey]) primed \a [src]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

		activate()
		add_fingerprint(user)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.throw_mode_on()

/obj/item/grenade/chem_grenade/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/safety_pin) && user.is_item_in_hands(W) && stage == STAGE_READY && !active)
		if(QDELETED(safety_pin))
			to_chat(user, SPAN("notice", "You insert [W] in place."))
			playsound(loc, 'sound/weapons/pin_insert.ogg', 40, 1)
			broken = FALSE
			safety_pin = W
			user.drop(W, src)
			update_icon()
	if(istype(W,/obj/item/device/assembly_holder) && stage != STAGE_READY)
		var/obj/item/device/assembly_holder/det = W
		if(istype(det.a_left,det.a_right.type) || (!isigniter(det.a_left) && !isigniter(det.a_right)))
			to_chat(user, SPAN("warning", "Assembly must contain one igniter."))
			return
		if(!det.secured)
			to_chat(user, SPAN("warning", "Assembly must be secured with screwdriver."))
			return
		to_chat(user, SPAN("notice", "You add [W] to the metal casing."))
		playsound(loc, 'sound/items/Screwdriver2.ogg', 25, -3)
		user.drop(det, src)
		detonator = det
		if(istimer(detonator.a_left))
			var/obj/item/device/assembly/timer/T = detonator.a_left
			det_time = 10*T.time
		if(istimer(detonator.a_right))
			var/obj/item/device/assembly/timer/T = detonator.a_right
			det_time = 10*T.time
		stage = STAGE_DETONATOR
		update_icon()
		SetName("unsecured grenade with [beakers.len] containers[detonator?" and detonator":""]")
	else if(isScrewdriver(W))
		if(stage != STAGE_READY)
			if(beakers.len)
				to_chat(user, SPAN("notice", "You lock the assembly."))
				SetName("grenade")
			else
				to_chat(user, SPAN("notice", "You lock the empty assembly."))
				SetName("fake grenade")
			playsound(loc, 'sound/items/Screwdriver.ogg', 25, -3)
			stage = STAGE_READY
			update_icon()
		else
			if(QDELETED(safety_pin) && has_pin && !active)
				if(prob(5))
					to_chat(user, SPAN("warning", "Your hand slips off the lever, triggering grenade!"))
					detonate()
					return
				broken = TRUE
				to_chat(user, SPAN("warning", "You broke grenade, while trying to remove detonator!"))
			if(active)
				if(do_after(usr, 50, src, luck_check_type = LUCK_CHECK_COMBAT))
					active = FALSE
					update_icon()
				else
					to_chat(user, SPAN("warning", "You fail to fix assembly, and activate it instead."))
					detonate()
					return
			to_chat(user, SPAN("notice", "You unlock the assembly."))
			playsound(loc, 'sound/items/Screwdriver.ogg', 25, -3)
			SetName("unsecured grenade with [beakers.len] containers[detonator?" and detonator":""]")
			stage = STAGE_DETONATOR
			update_icon()
	else if(is_type_in_list(W, allowed_containers) && stage != STAGE_READY)
		if(beakers.len == 2)
			to_chat(user, SPAN("warning", "The grenade can not hold more containers."))
			return
		else
			if(W.reagents.total_volume)
				if(!user.drop(W, src))
					return
				to_chat(user, SPAN("notice", "You add \the [W] to the assembly."))
				beakers += W
				stage = STAGE_DETONATOR
				SetName("unsecured grenade with [beakers.len] containers[detonator?" and detonator":""]")
			else
				to_chat(user, SPAN("warning", "\The [W] is empty."))

/obj/item/grenade/chem_grenade/examine(mob/user, infix)
	. = ..()

	if(detonator)
		. += "It has \the [detonator] atached."

/obj/item/grenade/chem_grenade/detonate()
	if(stage != STAGE_READY) return
	var/has_reagents = 0
	for(var/obj/item/reagent_containers/vessel/G in beakers)
		if(G.reagents.total_volume) has_reagents = 1
	broken = TRUE
	if(!has_reagents)
		update_icon()
		playsound(loc, 'sound/items/Screwdriver2.ogg', 50, 1)
		spawn(0) //Otherwise det_time is erroneously set to 0 after this
			if(istimer(detonator.a_left)) //Make sure description reflects that the timer has been reset
				var/obj/item/device/assembly/timer/T = detonator.a_left
				det_time = 10*T.time
			if(istimer(detonator.a_right))
				var/obj/item/device/assembly/timer/T = detonator.a_right
				det_time = 10*T.time
		return

	playsound(loc, 'sound/effects/bamf.ogg', 50, 1)

	for(var/obj/item/reagent_containers/vessel/G in beakers)
		G.reagents.trans_to_obj(src, G.reagents.total_volume)

	if(src.reagents.total_volume) //The possible reactions didnt use up all reagents.
		var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
		steam.set_up(10, 0, get_turf(src))
		steam.attach(src)
		steam.start()

		for(var/atom/A in view(affected_area, loc))
			if( A == src ) continue
			src.reagents.touch(A)

	if(istype(loc, /mob/living/carbon)) // drop dat grenade if it goes off in your hand
		var/mob/living/carbon/C = loc
		C.drop(src)
		C.throw_mode_off()

	set_invisibility(INVISIBILITY_MAXIMUM) //Why am i doing this?
	spawn(50)		   //To make sure all reagents can work
		qdel(src)	   //correctly before deleting the grenade.

/obj/item/grenade/chem_grenade/on_update_icon()
	if(active)
		icon_state = initial(icon_state) + "_active"
		return
	if(stage == STAGE_DETONATOR)
		icon_state = initial(icon_state) + "_ass"
		return
	if(stage == STAGE_BASIC)
		icon_state = initial(icon_state)
		return
	if(QDELETED(safety_pin))
		icon_state = initial(icon_state) + "_primed"
		return
	icon_state = initial(icon_state) + "_locked"

/obj/item/grenade/chem_grenade/large
	name = "large chem grenade"
	desc = "An oversized grenade that affects a larger area."
	icon_state = "large_grenade"
	allowed_containers = list(/obj/item/reagent_containers/vessel)
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 3)
	affected_area = 4

/obj/item/grenade/chem_grenade/metalfoam
	name = "metal-foam grenade"
	desc = "Used for emergency sealing of air breaches."
	stage = STAGE_READY

/obj/item/grenade/chem_grenade/metalfoam/Initialize()
	. = ..()
	var/obj/item/reagent_containers/vessel/beaker/B1 = new(src)
	var/obj/item/reagent_containers/vessel/beaker/B2 = new(src)

	B1.reagents.add_reagent(/datum/reagent/aluminum, 30)
	B2.reagents.add_reagent(/datum/reagent/foaming_agent, 10)
	B2.reagents.add_reagent(/datum/reagent/acid/polyacid, 10)

	detonator = new /obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	update_icon()

/obj/item/grenade/chem_grenade/incendiary
	name = "incendiary grenade"
	desc = "Used for clearing rooms of living things."
	stage = STAGE_READY

/obj/item/grenade/chem_grenade/incendiary/Initialize()
	. = ..()
	var/obj/item/reagent_containers/vessel/beaker/B1 = new(src)
	var/obj/item/reagent_containers/vessel/beaker/B2 = new(src)

	B1.reagents.add_reagent(/datum/reagent/aluminum, 15)
	B1.reagents.add_reagent(/datum/reagent/fuel,20)
	B2.reagents.add_reagent(/datum/reagent/toxin/plasma, 15)
	B2.reagents.add_reagent(/datum/reagent/acid, 15)
	B1.reagents.add_reagent(/datum/reagent/fuel,20)

	detonator = new /obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	update_icon()

/obj/item/grenade/chem_grenade/antiweed
	name = "weedkiller grenade"
	desc = "Used for purging large areas of invasive plant species. Contents under pressure. Do not directly inhale contents."
	stage = STAGE_READY

/obj/item/grenade/chem_grenade/antiweed/Initialize()
	. = ..()
	var/obj/item/reagent_containers/vessel/beaker/B1 = new(src)
	var/obj/item/reagent_containers/vessel/beaker/B2 = new(src)

	B1.reagents.add_reagent(/datum/reagent/toxin/plantbgone, 25)
	B1.reagents.add_reagent(/datum/reagent/potassium, 25)
	B2.reagents.add_reagent(/datum/reagent/phosphorus, 25)
	B2.reagents.add_reagent(/datum/reagent/sugar, 25)

	detonator = new /obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	icon_state = "grenade"

/obj/item/grenade/chem_grenade/cleaner
	name = "cleaner grenade"
	desc = "BLAM!-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	stage = STAGE_READY

/obj/item/grenade/chem_grenade/cleaner/Initialize()
	. = ..()
	var/obj/item/reagent_containers/vessel/beaker/B1 = new(src)
	var/obj/item/reagent_containers/vessel/beaker/B2 = new(src)

	B1.reagents.add_reagent(/datum/reagent/surfactant, 40)
	B2.reagents.add_reagent(/datum/reagent/water, 40)
	B2.reagents.add_reagent(/datum/reagent/space_cleaner, 10)

	detonator = new /obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	update_icon()

/obj/item/grenade/chem_grenade/teargas
	name = "tear gas grenade"
	desc = "Concentrated Capsaicin. Contents under pressure. Use with caution."
	stage = STAGE_READY

/obj/item/grenade/chem_grenade/teargas/Initialize()
	. = ..()
	var/obj/item/reagent_containers/vessel/beaker/large/B1 = new(src)
	var/obj/item/reagent_containers/vessel/beaker/large/B2 = new(src)

	B1.reagents.add_reagent(/datum/reagent/phosphorus, 40)
	B1.reagents.add_reagent(/datum/reagent/potassium, 40)
	B1.reagents.add_reagent(/datum/reagent/capsaicin/condensed, 40)
	B2.reagents.add_reagent(/datum/reagent/sugar, 40)
	B2.reagents.add_reagent(/datum/reagent/capsaicin/condensed, 80)

	detonator = new /obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	update_icon()

#undef STAGE_READY
#undef STAGE_DETONATOR
#undef STAGE_BASIC
