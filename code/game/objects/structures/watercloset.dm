#define SHOWER_MAX_WORKING_TIME 30 SECONDS
#define MIST_SPAWN_DELAY 10 SECONDS
#define SHOWER_WASH_FLOOR_INTERVAL 10 SECONDS

/obj/structure/toilet
	name = "toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably clean."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet00"
	base_icon_state = "toilet"
	density = 0
	anchored = 1
	var/open = 0			//if the lid is up
	var/cistern = 0			//if the cistern bit is open
	var/w_items = 0			//the combined w_class of all the items in the cistern
	var/mob/living/swirlie = null	//the mob being given a swirlie

/obj/structure/toilet/New()
	..()
	open = round(rand(0, 1))

/obj/structure/toiler/Initialize()
	. = ..()
	update_icon()

/obj/structure/toilet/attack_hand(mob/living/user as mob)
	if(swirlie)
		usr.visible_message("<span class='danger'>[user] slams the toilet seat onto [swirlie.name]'s head!</span>", "<span class='notice'>You slam the toilet seat onto [swirlie.name]'s head!</span>", "You hear reverberating porcelain.")
		swirlie.adjustBruteLoss(8)
		return

	if(cistern && !open)
		if(!contents.len)
			to_chat(user, "<span class='notice'>The cistern is empty.</span>")
			return
		else
			var/obj/item/I = pick(contents)
			if(ishuman(user))
				user.pick_or_drop(I)
			else
				I.dropInto(loc)
			to_chat(user, "<span class='notice'>You find \an [I] in the cistern.</span>")
			w_items -= I.w_class
			return

	open = !open
	update_icon()

/obj/structure/toilet/on_update_icon()
	icon_state = "[base_icon_state][open][cistern]"

/obj/structure/toilet/attackby(obj/item/I as obj, mob/living/user as mob)
	if(isCrowbar(I))
		to_chat(user, "<span class='notice'>You start to [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"].</span>")
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
		if(do_after(user, 30, src))
			user.visible_message("<span class='notice'>[user] [cistern ? "replaces the lid on the cistern" : "lifts the lid off the cistern"]!</span>", "<span class='notice'>You [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]!</span>", "You hear grinding porcelain.")
			cistern = !cistern
			update_icon()
			return

	if(cistern && !istype(user,/mob/living/silicon/robot)) //STOP PUTTING YOUR MODULES IN THE TOILET.
		if(I.w_class > ITEM_SIZE_NORMAL)
			to_chat(user, "<span class='notice'>\The [I] does not fit.</span>")
			return
		if(w_items + I.w_class > 5)
			to_chat(user, "<span class='notice'>The cistern is full.</span>")
			return
		if(!user.drop(I, src))
			return
		w_items += I.w_class
		to_chat(user, "You carefully place \the [I] into the cistern.")
		return

/obj/structure/toilet/gold
	name = "golden toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one is LUXURIOUS."
	icon_state = "goldtoilet00"
	base_icon_state = "goldtoilet"


/obj/structure/urinal
	name = "urinal"
	desc = "The HU-452, an experimental urinal."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "urinal"
	density = 0
	anchored = 1

/obj/machinery/shower
	name = "shower"
	desc = "The best in class HS-451 shower unit has three temperature settings, one more than the HS-450 which preceded it."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower"
	density = FALSE
	anchored = TRUE
	use_power = 0
	layer = ABOVE_WINDOW_LAYER
	var/watertemp = "normal"	//freezing, normal, or boiling
	var/is_washing = 0
	/// Used to track when it should stop processing automatically.
	var/time_enabled
	/// Tracks interval at which it should wash the floor
	var/next_wash_time
	var/list/temperature_settings = list("normal" = 310, "boiling" = 100 CELSIUS, "freezing" = 0 CELSIUS)
	/// Mist effect will be spawned only once per activation.
	var/hasmist = FALSE

/obj/machinery/shower/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel_self()
		if(EXPLODE_HEAVY)
			if(prob(50))
				if(prob(50))
					new /obj/item/shower_parts(get_turf(src))
				qdel_self()
		if(EXPLODE_LIGHT)
			if(prob(25))
				new /obj/item/shower_parts(get_turf(src))
				qdel_self()

/obj/machinery/shower/Initialize(mapload, ...)
	. = ..()
	create_reagents(50)

//add heat controls? when emagged, you can freeze to death in it?

/obj/item/shower_parts
	name = "shower parts"
	desc = "It has everything you need to assemble your own shower. Isn't it beautiful?"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower_parts"

/obj/item/shower_parts/attack_self(mob/user)
	add_fingerprint(user)

	if(!isturf(user.loc))
		return

	place_shower(user)

/obj/item/shower_parts/proc/place_shower(mob/user)
	if(!in_use)
		to_chat(user, SPAN("notice", "Assembling shower..."))
		in_use = TRUE
		if(!do_after(user, 1 SECOND))
			in_use = FALSE
			return
		var/obj/machinery/shower/S = new /obj/machinery/shower(user.loc)
		to_chat(user, SPAN("notice", "You assemble a shower"))
		in_use = FALSE
		S.add_fingerprint(user)
		qdel_self()
	return

/obj/machinery/shower/attack_hand(mob/M as mob)
	if(is_processing)
		STOP_PROCESSING(SSmachines, src)
	else
		time_enabled = world.time
		hasmist = FALSE
		START_PROCESSING(SSmachines, src)

	update_icon()

/obj/machinery/shower/attackby(obj/item/I as obj, mob/user as mob)
	if(isScrewdriver(I))
		if(is_processing)
			to_chat(user, SPAN("warning", "The first thing to do is to turn off the water."))
			return

		playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
		new /obj/item/shower_parts(get_turf(src))
		qdel_self()

	if(I.type == /obj/item/device/analyzer)
		to_chat(user, SPAN_NOTICE("The water temperature seems to be [watertemp]."))
		return

	if(isWrench(I))
		var/newtemp = tgui_input_list(user, "What setting would you like to set the temperature valve to?", "Water Temperature Valve", temperature_settings)
		if(!Adjacent(user))
			return

		to_chat(user, SPAN_NOTICE("You begin to adjust the temperature valve with \the [I]."))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, 50, src))
			watertemp = newtemp
			user.visible_message(SPAN_NOTICE("\The [user] adjusts \the [src] with \the [I]."), SPAN_NOTICE("You adjust the shower with \the [I]."))
			add_fingerprint(user)
		return

	return ..()

/obj/machinery/shower/on_update_icon()	//this is terribly unreadable, but basically it makes the shower mist up
	ClearOverlays()					//once it's been on for a while, in addition to handling the water overlay.

	if(is_processing)
		AddOverlays(image('icons/obj/watercloset.dmi', src, "water", MOB_LAYER + 1, dir))

//Yes, showers are super powerful as far as washing goes.
/obj/machinery/shower/proc/wash(atom/movable/O)
	if(!is_processing)
		return

	if(isliving(O))
		var/mob/living/L = O
		L.ExtinguishMob()
		L.fire_stacks = -20 //Douse ourselves with water to avoid fire more easily

	if(iscarbon(O))
		var/mob/living/carbon/M = O
		if(M.r_hand)
			M.r_hand.clean_blood()
		if(M.l_hand)
			M.l_hand.clean_blood()
		if(M.back)
			if(M.back.clean_blood())
				M.update_inv_back(0)

		//flush away reagents on the skin
		if(M.touching)
			var/remove_amount = M.touching.maximum_volume * M.reagent_permeability() //take off your suit first
			M.touching.remove_any(remove_amount)

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/washgloves = 1
			var/washshoes = 1
			var/washmask = 1
			var/washears = 1
			var/washglasses = 1

			if(H.wear_suit)
				washgloves = !(H.wear_suit.flags_inv & HIDEGLOVES)
				washshoes = !(H.wear_suit.flags_inv & HIDESHOES)

			if(H.head)
				washmask = !(H.head.flags_inv & HIDEMASK)
				washglasses = !(H.head.flags_inv & HIDEEYES)
				washears = !(H.head.flags_inv & HIDEEARS)

			if(H.wear_mask)
				if (washears)
					washears = !(H.wear_mask.flags_inv & HIDEEARS)
				if (washglasses)
					washglasses = !(H.wear_mask.flags_inv & HIDEEYES)

			if(H.head)
				if(H.head.clean_blood())
					H.update_inv_head(0)
			if(H.wear_suit)
				if(H.wear_suit.clean_blood())
					H.update_inv_wear_suit(0)
			else if(H.w_uniform)
				if(H.w_uniform.clean_blood())
					H.update_inv_w_uniform(0)
			if(H.gloves && washgloves)
				if(H.gloves.clean_blood())
					H.update_inv_gloves(0)
			if(H.shoes && washshoes)
				if(H.shoes.clean_blood())
					H.update_inv_shoes(0)
			if(H.wear_mask && washmask)
				if(H.wear_mask.clean_blood())
					H.update_inv_wear_mask(0)
			if(H.glasses && washglasses)
				if(H.glasses.clean_blood())
					H.update_inv_glasses(0)
			if(H.l_ear && washears)
				if(H.l_ear.clean_blood())
					H.update_inv_ears(0)
			if(H.r_ear && washears)
				if(H.r_ear.clean_blood())
					H.update_inv_ears(0)
			if(H.belt)
				if(H.belt.clean_blood())
					H.update_inv_belt(0)
			H.clean_blood(washshoes)

			var/obj/item/organ/external/head/head = H.organs_by_name[BP_HEAD]
			if(istype(head))
				head.forehead_graffiti = null
				head.graffiti_style = null
		else
			if(M.wear_mask)						//if the mob is not human, it cleans the mask without asking for bitflags
				if(M.wear_mask.clean_blood())
					M.update_inv_wear_mask(0)
			M.clean_blood()
	else
		O.clean_blood()

	if(isturf(loc))
		var/turf/tile = loc
		for(var/obj/effect/E in tile)
			if(istype(E,/obj/effect/rune) || istype(E,/obj/effect/decal/cleanable) || istype(E,/obj/effect/overlay))
				qdel(E)

	reagents.splash(O, 10)

/obj/machinery/shower/Process()
	if(world.time >= time_enabled + SHOWER_MAX_WORKING_TIME)
		STOP_PROCESSING(SSmachines, src)
		update_icon()
		return

	if(!hasmist && world.time >= time_enabled + MIST_SPAWN_DELAY && temperature_settings[watertemp] > (20 CELSIUS))
		new /obj/effect/mist/showermist(get_turf(src))
		hasmist = TRUE

	for(var/thing in loc)
		var/atom/movable/AM = thing
		var/mob/living/L = thing
		if(istype(AM) && AM.simulated)
			wash(AM)
			if(istype(L))
				process_heat(L)

	if(world.time >= next_wash_time)
		next_wash_time = world.time + SHOWER_WASH_FLOOR_INTERVAL
		wash_floor()

	reagents.add_reagent(/datum/reagent/water, reagents.get_free_space())

/obj/machinery/shower/proc/wash_floor()
	var/turf/T = get_turf(src)
	reagents.splash(T, reagents.total_volume)
	T.clean(src)

/obj/machinery/shower/proc/process_heat(mob/living/M)
	if(!is_processing || !istype(M))
		return

	var/temperature = temperature_settings[watertemp]
	var/temp_adj = between(BODYTEMP_COOLING_MAX, temperature - M.bodytemperature, BODYTEMP_HEATING_MAX)
	M.bodytemperature += temp_adj

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(temperature >= H.species.heat_level_1)
			to_chat(H, SPAN_DANGER("The water is searing hot!"))
		else if(temperature <= H.species.cold_level_1)
			to_chat(H, SPAN_WARNING("The water is freezing cold!"))

/obj/effect/mist
	name = "mist"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mist"

	layer = ABOVE_HUMAN_LAYER
	anchored = TRUE
	mouse_opacity = 0

/obj/effect/mist/showermist/Initialize(mapload, ...) // This mist self-deletes after some time, ridding us of tracking mist in shower's Process()
	. = ..()
	QDEL_IN(src, SHOWER_MAX_WORKING_TIME)

/obj/item/bikehorn/rubberducky
	name = "rubber ducky"
	desc = "Rubber ducky you're so fine, you make bathtime lots of fuuun. Rubber ducky I'm awfully fooooond of yooooouuuu~"	//thanks doohl
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	item_state = "rubberducky"
	slot_flags = SLOT_HEAD



/obj/structure/sink
	name = "sink"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "sink"
	desc = "A sink used for washing one's hands and face."
	anchored = 1
	var/busy = 0 	//Something's being washed at the moment

/obj/structure/sink/MouseDrop_T(obj/item/thing, mob/user)
	..()
	if(!istype(thing) || !thing.is_open_container())
		return ..()
	if(!usr.Adjacent(src))
		return ..()
	if(!thing.reagents || thing.reagents.total_volume == 0)
		to_chat(usr, "<span class='warning'>\The [thing] is empty.</span>")
		return
	// Clear the vessel.
	visible_message("<span class='notice'>\The [usr] tips the contents of \the [thing] into \the [src].</span>")
	thing.reagents.clear_reagents()
	thing.update_icon()

/obj/structure/sink/attack_hand(mob/user as mob)
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.organs_by_name[BP_R_HAND]
		if (user.hand)
			temp = H.organs_by_name[BP_L_HAND]
		if(temp && !temp.is_usable())
			to_chat(user, "<span class='notice'>You try to move your [temp.name], but cannot!</span>")
			return

	if(isrobot(user) || isAI(user))
		return

	if(!Adjacent(user))
		return

	if(busy)
		to_chat(user, "<span class='warning'>Someone's already washing here.</span>")
		return

	playsound(loc, 'sound/effects/using/sink/washing1.ogg', 75)
	to_chat(usr, "<span class='notice'>You start washing your hands.</span>")

	busy = 1
	if(!do_after(user, 40,src))
		busy = 0
		return
	busy = 0

	if(!Adjacent(user)) return		//Person has moved away from the sink

	user.clean_blood()
	if(ishuman(user))
		user:update_inv_gloves()
	for(var/mob/V in viewers(src, null))
		V.show_message("<span class='notice'>[user] washes their hands using \the [src].</span>")

/obj/structure/sink/ShiftClick(mob/user)
	. = ..()
	var/obj/O = user.get_active_hand()
	if(istype(O, /obj/item/mop))
		if(O.reagents.total_volume == 0)
			to_chat(user, "<span class='warning'>[O] is dry, you can't squeeze anything out!</span>")
			return
		if(reagents.total_volume == reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[src] is full!</span>")
			return
		O.reagents.remove_any(O.reagents.total_volume * SQUEEZING_DISPERSAL_RATIO)
		O.reagents.trans_to(src, O.reagents.total_volume)
		to_chat(user, "<span class='notice'>You squeeze the liquids from [O] to [src].</span>")

/obj/structure/sink/attackby(obj/item/O as obj, mob/living/user as mob)
	if(busy)
		to_chat(user, "<span class='warning'>Someone's already washing here.</span>")
		return

	var/obj/item/reagent_containers/RG = O
	if (istype(RG) && RG.is_open_container())
		if(RG.reagents.total_volume == RG.volume)
			to_chat(user, SPAN("notice", "\The [RG] is already full!"))
			return
		playsound(loc, 'sound/effects/using/sink/filling1.ogg', 75)
		RG.reagents.add_reagent(/datum/reagent/water, min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
		user.visible_message("<span class='notice'>[user] fills \the [RG] using \the [src].</span>","<span class='notice'>You fill \the [RG] using \the [src].</span>")
		return 1

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
				user.visible_message( \
					"<span class='danger'>[user] was stunned by \his wet [O]!</span>", \
					"<span class='userdanger'>[user] was stunned by \his wet [O]!</span>")
				return 1
	else if(istype(O, /obj/item/mop))
		playsound(loc, 'sound/effects/using/sink/filling1.ogg', 75)
		O.reagents.add_reagent(/datum/reagent/water, 5)
		to_chat(user, "<span class='notice'>You wet \the [O] in \the [src].</span>")
		playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
		return

	var/turf/location = user.loc
	if(!isturf(location)) return

	var/obj/item/I = O
	if(!I || !istype(I,/obj/item)) return

	to_chat(usr, "<span class='notice'>You start washing \the [I].</span>")

	playsound(loc, 'sound/effects/using/sink/washing1.ogg', 75)

	busy = 1
	if(!do_after(user, 40,src))
		busy = 0
		return
	busy = 0

	if(user.loc != location) return				//User has moved
	if(!I) return 								//Item's been destroyed while washing
	if(user.get_active_hand() != I) return		//Person has switched hands or the item in their hands

	O.clean_blood()

	if(istype(O, /obj/item/organ/external/head))
		var/obj/item/organ/external/head/head = O
		head.forehead_graffiti = null
		head.graffiti_style = null

	user.visible_message( \
		"<span class='notice'>[user] washes \a [I] using \the [src].</span>", \
		"<span class='notice'>You wash \a [I] using \the [src].</span>")


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

#undef SHOWER_MAX_WORKING_TIME
#undef MIST_SPAWN_DELAY
#undef SHOWER_WASH_FLOOR_INTERVAL
