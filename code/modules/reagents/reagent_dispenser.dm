
/obj/structure/reagent_dispensers
	name = "Dispenser"
	desc = "..."
	icon = 'icons/obj/reagent_tanks.dmi'
	icon_state = "watertank"
	density = 1
	anchored = 0
	pull_sound = SFX_PULL_MACHINE
	pull_slowdown = PULL_SLOWDOWN_LIGHT

	var/initial_capacity = 1000
	var/initial_reagent_types  // A list of reagents and their ratio relative the initial capacity. list(/datum/reagent/water = 0.5) would fill the dispenser halfway to capacity.
	var/amount_per_transfer_from_this = 10
	var/possible_transfer_amounts = "10;25;50;100;500"
	var/filling_overlay_levels = 0

/obj/structure/reagent_dispensers/attackby(obj/item/W, mob/user)
	return

/obj/structure/reagent_dispensers/New()
	create_reagents(initial_capacity)

	if(!possible_transfer_amounts)
		src.verbs -= /obj/structure/reagent_dispensers/verb/set_APTFT

	for(var/reagent_type in initial_reagent_types)
		var/reagent_ratio = initial_reagent_types[reagent_type]
		reagents.add_reagent(reagent_type, reagent_ratio * initial_capacity)

	..()

/obj/structure/reagent_dispensers/examine(mob/user, infix)
	. = ..()

	if(get_dist(src, user) > 2)
		return

	. += SPAN_NOTICE("It contains:")
	if(reagents && reagents.reagent_list.len)
		for(var/datum/reagent/R in reagents.reagent_list)
			. += SPAN_NOTICE("[R.volume] units of [R.name]")
	else
		. += SPAN_NOTICE("Nothing.")

/obj/structure/reagent_dispensers/verb/set_APTFT() //set amount_per_transfer_from_this
	set name = "Set transfer amount"
	set category = "Object"
	set src in view(1)
	var/N = input("Amount per transfer from this:","[src]") as null|anything in cached_number_list_decode(possible_transfer_amounts)
	if (N)
		amount_per_transfer_from_this = N

/obj/structure/reagent_dispensers/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				new /obj/effect/effect/water(src.loc)
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				new /obj/effect/effect/water(src.loc)
				qdel(src)
				return
	return

/obj/structure/reagent_dispensers/AltClick(mob/user)
	if(possible_transfer_amounts)
		if(CanPhysicallyInteract(user))
			set_APTFT()
	else
		return ..()

/obj/structure/reagent_dispensers/on_reagent_change()
	..()
	update_icon()

/obj/structure/reagent_dispensers/on_update_icon()
	ClearOverlays()
	if(filling_overlay_levels)
		if(reagents?.reagent_list?.len)
			var/reagents_amt = 0
			for(var/datum/reagent/R in reagents.reagent_list)
				reagents_amt += R.volume
			AddOverlays(image(icon, src, "[icon_state]-[ceil(reagents_amt / (initial_capacity / filling_overlay_levels))]"))
		else
			AddOverlays(image(icon, src, "[icon_state]-0"))

//Dispensers
/obj/structure/reagent_dispensers/watertank
	name = "watertank"
	desc = "A tank containing water."
	icon_state = "watertank"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = "10;25;50;100"
	initial_capacity = 5000
	initial_reagent_types = list(/datum/reagent/water = 1)
	atom_flags = ATOM_FLAG_CLIMBABLE
	filling_overlay_levels = 7
	turf_height_offset = 25

/obj/structure/reagent_dispensers/fueltank
	name = "fueltank"
	desc = "A tank containing fuel."
	icon_state = "weldtank"
	amount_per_transfer_from_this = 10
	var/modded = FALSE
	var/obj/item/device/assembly_holder/rig = null
	initial_reagent_types = list(/datum/reagent/fuel = 1)
	atom_flags = ATOM_FLAG_CLIMBABLE
	filling_overlay_levels = 6
	turf_height_offset = 25

/obj/structure/reagent_dispensers/fueltank/Destroy()
	QDEL_NULL(rig)
	return ..()

/obj/structure/reagent_dispensers/fueltank/examine(mob/user, infix)
	. = ..()

	if(get_dist(src, user) > 2)
		return

	if(modded)
		. += SPAN("warning", "Fuel faucet is wrenched open, leaking the fuel!")
	if(rig)
		. += SPAN("notice", "There is some kind of device rigged to the tank.")

/obj/structure/reagent_dispensers/fueltank/attack_hand(mob/user)
	if(rig)
		user.visible_message(
		  SPAN("notice", "\The [user] begins to detach [rig] from \the [src]."),
		  SPAN("notice", "You begin to detach [rig] from \the [src].")
		)
		if(do_after(user, 20, src, , luck_check_type = LUCK_CHECK_COMBAT))
			user.visible_message(
			  SPAN("notice", "\The [user] detaches \the [rig] from \the [src]."),
			  SPAN("notice", "You detach [rig] from \the [src]")
			)
			rig.forceMove(get_turf(user))
			rig = null
			ClearOverlays()

/obj/structure/reagent_dispensers/fueltank/attackby(obj/item/W, mob/user)
	add_fingerprint(user)
	if(isWrench(W))
		user.visible_message(
		  "[user] wrenches [src]'s faucet [modded ? "closed" : "open"].",
		  "You wrench [src]'s faucet [modded ? "closed" : "open"]"
		)
		modded = !modded
		if(modded)
			message_admins("[key_name_admin(user)] opened fueltank at [loc.loc.name] ([loc.x],[loc.y],[loc.z]), leaking fuel. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[loc.x];Y=[loc.y];Z=[loc.z]'>JMP</a>)")
			log_game("[key_name(user)] opened fueltank at [loc.loc.name] ([loc.x],[loc.y],[loc.z]), leaking fuel.")
			leak_fuel(amount_per_transfer_from_this)
	else if(istype(W, /obj/item/device/assembly_holder))
		if(rig)
			to_chat(user, SPAN("warning", "There is another device in the way."))
			return ..()
		user.visible_message(
		  "\The [user] begins rigging [W] to \the [src].",
		  "You begin rigging [W] to \the [src]"
		)
		if(do_after(user, 20, src))
			if(!user.drop(W, src))
				return

			var/obj/item/device/assembly_holder/H = W
			if(istype(H.a_left, /obj/item/device/assembly/igniter) || istype(H.a_right, /obj/item/device/assembly/igniter))
				message_admins("[key_name_admin(user)] rigged fueltank at [loc.loc.name] ([loc.x],[loc.y],[loc.z]) for explosion. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[loc.x];Y=[loc.y];Z=[loc.z]'>JMP</a>)")
				log_game("[key_name(user)] rigged fueltank at [loc.loc.name] ([loc.x],[loc.y],[loc.z]) for explosion.")

			rig = W

			user.visible_message(
			  SPAN("notice", "The [user] rigs [W] to \the [src]."),
			  SPAN("notice", "You rig [W] to \the [src].")
			)
			update_icon()
	else if(W.get_temperature_as_from_ignitor())
		log_and_message_admins("triggered a fueltank explosion with [W].")
		user.visible_message(
		  SPAN("danger", "[user] puts [W] to [src]!"),
		  SPAN("danger", "You put \the [W] to \the [src] and with a moment of lucidity you realize, this might not have been the smartest thing you've ever done.")
		)
		explode()

		return
	return ..()

/obj/structure/reagent_dispensers/fueltank/on_update_icon()
	..()
	if(rig)
		var/icon/rig_icon = getFlatIcon(rig)
		rig_icon.Shift(NORTH,1)
		rig_icon.Shift(EAST,6)
		AddOverlays(rig_icon)

/obj/structure/reagent_dispensers/fueltank/bullet_act(obj/item/projectile/Proj)
	if(Proj.get_structure_damage())
		if(istype(Proj.firer))
			var/turf/turf = get_turf(src)
			if(turf)
				var/area/area = turf.loc || "*unknown area*"
				message_admins("[key_name_admin(Proj.firer)] shot a fueltank in \the [area] ([turf.x],[turf.y],[turf.z]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[turf.x];Y=[turf.y];Z=[turf.z]'>JMP</a>).")
				log_game("[key_name(Proj.firer)] shot a fueltank in \the [area] ([turf.x],[turf.y],[turf.z]).")
			else
				message_admins("[key_name_admin(Proj.firer)] shot a fueltank outside the world.")
				log_game("[key_name(Proj.firer)] shot a fueltank outside the world.")

		if(!istype(Proj ,/obj/item/projectile/beam/lasertag) && !istype(Proj ,/obj/item/projectile/beam/practice) )
			explode()

/obj/structure/reagent_dispensers/fueltank/ex_act()
	explode()

/obj/structure/reagent_dispensers/fueltank/proc/explode()
	if (reagents.total_volume > 500)
		explosion(src.loc,1,2,4,sfx_to_play=SFX_EXPLOSION_FUEL)
	else if (reagents.total_volume > 100)
		explosion(src.loc,0,1,3,sfx_to_play=SFX_EXPLOSION_FUEL)
	else if (reagents.total_volume > 50)
		explosion(src.loc,-1,1,2,sfx_to_play=SFX_EXPLOSION_FUEL)
	if(src)
		qdel(src)

/obj/structure/reagent_dispensers/fueltank/fire_act(datum/gas_mixture/air, temperature, volume)
	if (modded)
		explode()
	else if (temperature > (500 CELSIUS))
		explode()
	return ..()

/obj/structure/reagent_dispensers/fueltank/Move()
	. = ..()
	if (. && modded)
		leak_fuel(amount_per_transfer_from_this/10.0)

/obj/structure/reagent_dispensers/fueltank/proc/leak_fuel(amount)
	if (reagents.total_volume == 0)
		return

	amount = min(amount, reagents.total_volume)
	reagents.remove_reagent(/datum/reagent/fuel,amount)
	new /obj/effect/decal/cleanable/liquid_fuel(src.loc, amount,1)

/obj/structure/reagent_dispensers/composttank
	name = "compost tank"
	desc = "A tank containing compost. Can be used to recycle excessive seeds."
	icon_state = "compost"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = "5;10;25;50"
	initial_capacity = 500
	initial_reagent_types = list(/datum/reagent/toxin/fertilizer/compost = 1)
	atom_flags = ATOM_FLAG_CLIMBABLE
	turf_height_offset = 25

/obj/structure/reagent_dispensers/composttank/attackby(obj/item/W, mob/user)
	src.add_fingerprint(user)
	if(istype(W,/obj/item/seeds))
		user.visible_message("[user] places [W] into \the [src].", \
							 "You place [W] into \the [src].")
		reagents.add_reagent(/datum/reagent/toxin/fertilizer/compost, 3)
		qdel(W)
	return ..()

/obj/structure/reagent_dispensers/peppertank
	name = "Pepper Spray Refiller"
	desc = "Refills pepper spray canisters."
	icon_state = "peppertank"
	anchored = 1
	density = 0
	amount_per_transfer_from_this = 45
	initial_reagent_types = list(/datum/reagent/capsaicin/condensed = 1)


/obj/structure/reagent_dispensers/water_cooler
	name = "Water-Cooler"
	desc = "A machine that dispenses water to drink."
	amount_per_transfer_from_this = 5
	icon = 'icons/obj/water_cooler.dmi'
	icon_state = "water_cooler"
	possible_transfer_amounts = null
	anchored = 1
	initial_capacity = 500
	initial_reagent_types = list(/datum/reagent/water = 1)


/obj/structure/reagent_dispensers/water_cooler/attackby(obj/item/W, mob/user)
	if(isWrench(W))
		add_fingerprint(user)
		if(anchored)
			user.visible_message("\The [user] begins unsecuring \the [src] from the floor.", "You start unsecuring \the [src] from the floor.")
		else
			user.visible_message("\The [user] begins securing \the [src] to the floor.", "You start securing \the [src] to the floor.")

		if(do_after(user, 20, src))
			if(!src) return
			to_chat(user, "<span class='notice'>You [anchored? "un" : ""]secured \the [src]!</span>")
			anchored = !anchored
		return
	else
		return ..()

/obj/structure/reagent_dispensers/beerkeg
	name = "beer keg"
	desc = "A beer keg."
	icon_state = "beertankTEMP"
	amount_per_transfer_from_this = 10
	initial_reagent_types = list(/datum/reagent/ethanol/beer = 1)
	atom_flags = ATOM_FLAG_CLIMBABLE
	pull_slowdown = PULL_SLOWDOWN_MEDIUM
	turf_height_offset = 16

/obj/structure/reagent_dispensers/virusfood
	name = "Virus Food Dispenser"
	desc = "A dispenser of virus food."
	icon_state = "virusfoodtank"
	amount_per_transfer_from_this = 10
	anchored = 1
	initial_reagent_types = list(/datum/reagent/nutriment/virus_food = 1)

/obj/structure/reagent_dispensers/acid
	name = "Sulphuric Acid Dispenser"
	desc = "A dispenser of acid for industrial processes."
	icon_state = "acidtank"
	amount_per_transfer_from_this = 10
	anchored = 1
	initial_reagent_types = list(/datum/reagent/acid = 1)
