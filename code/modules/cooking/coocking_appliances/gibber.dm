/obj/machinery/gibber
	name = "gibber"
	desc = "The name isn't descriptive enough?"

	icon = 'icons/obj/machines/gibber.dmi'
	icon_state = "gibber"
	layer = BELOW_OBJ_LAYER

	density = TRUE
	anchored = TRUE

	idle_power_usage = 2 WATTS
	active_power_usage = 500 WATTS

	component_types = list(
		/obj/item/stock_parts/micro_laser,
		/obj/item/stock_parts/matter_bin,
		/obj/item/circuitboard/gibber
	)

	/// Direction to spit meat and gibs in.
	var/gib_throw_dir = WEST

	/// Time to gib a single entity.
	var/gib_time
	/// Whether the machine is processing pigs.
	var/operating = FALSE
	/// Max mount of mobs that can fit into the machine.
	var/mob_capacity
	/// List of mobs to be gibbed.
	var/list/mob/mobs_to_process

/obj/machinery/gibber/on_update_icon()
	ClearOverlays()
	if(panel_open)
		AddOverlays("gibber-panel")

	if(stat & (NOPOWER|BROKEN))
		return

	if(operating)
		AddOverlays("gibber-use")
	else if(length(mobs_to_process))
		AddOverlays("gibber-jam")
	else
		AddOverlays("gibber-idle")

	var/should_glow = update_glow()
	if(should_glow)
		AddOverlays(emissive_appearance(icon, "[icon_state]_ea"))

/obj/machinery/gibber/proc/update_glow()
	if(inoperable(MAINT))
		set_light(0)
		return FALSE

	var/color = COLOR_YELLOW
	if(operating)
		color = COLOR_GREEN
	if(length(mobs_to_process))
		color = COLOR_NT_RED

	set_light(0.7, 0.1, 1, 2, color)
	return TRUE

/obj/machinery/gibber/RefreshParts()
	var/time_modifier = 0
	for(var/obj/item/stock_parts/micro_laser/ML in component_parts)
		time_modifier += ML.rating
	gib_time = max(4 SECONDS - 10 * (time_modifier - 1), 1 SECOND)

	var/capacity_modifier = 0
	for(var/obj/item/stock_parts/matter_bin/MB in component_parts)
		capacity_modifier += MB.rating
	mob_capacity = clamp(capacity_modifier * (capacity_modifier - 1), 1, 12)

/obj/machinery/gibber/Initialize()
	. = ..()

	add_think_ctx("finish_processing", CALLBACK(src, nameof(.proc/finish_processing)), 0)
	update_icon()
	RefreshParts()

/obj/machinery/gibber/Destroy()
	if(operating)
		for(var/atom/A in contents - mobs_to_process - component_parts)
			qdel(A) // No drops for cheaters...
	if(length(mobs_to_process))
		for(var/mob/M in mobs_to_process)
			M.forceMove(loc)
	return ..()

/obj/machinery/gibber/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return

	if(operating)
		to_chat(user, SPAN("danger", "\The [src] is locked and running, wait for it to finish!"))
		return

	if(!length(mobs_to_process))
		to_chat(user, SPAN("danger", "\The [src] has nothing grindable inside!"))
		return

	process_mobs(user)

/obj/machinery/gibber/attackby(obj/item/W, mob/user)
	if(operating)
		return ..()

	if(default_deconstruction_screwdriver(user, W))
		return

	if(default_deconstruction_crowbar(user, W))
		return

	if(default_part_replacement(user, W))
		return

	if(istype(W, /obj/item/grab))
		var/obj/item/grab/G = W
		if(!G.force_danger())
			to_chat(user, SPAN("danger", "You need a better grip to do that!"))
			return

		add_to_contents(user, G.affecting)
		G.delete_self()
		return

	if(istype(W, /obj/item/organ))
		if(!user.drop(W))
			return

		user.visible_message(SPAN("danger", "\The [user] feeds \the [W] into \the [src], obliterating it."))
		qdel(W)
		return

	return ..()

/obj/machinery/gibber/relaymove(mob/user)
	if(!empty_contents())
		return

	user.visible_message(
		SPAN("danger", "[user] flies out from \the [src], thus emptying its contents"),
		SPAN("warning", "You successfully knock out \the [src]s hatch, thus saving your life!")
	)

/obj/machinery/gibber/MouseDrop_T(mob/target, mob/user)
	if(user.stat || user.restrained())
		return

	add_to_contents(user, target)

/obj/machinery/gibber/verb/eject()
	set category = "Object"
	set name = "Empty Gibber"
	set src in oview(1)

	if(usr.is_ic_dead())
		return

	if(usr.loc == src)
		return

	empty_contents()
	add_fingerprint(usr)

/obj/machinery/gibber/proc/empty_contents()
	if(operating)
		return FALSE

	for(var/mob/M in mobs_to_process)
		M.dropInto(loc)
		if(M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE

	LAZYCLEARLIST(mobs_to_process)
	update_icon()
	return TRUE

/obj/machinery/gibber/proc/move_inside(mob/victim)
	victim.forceMove(src)
	LAZYADD(mobs_to_process, victim)

	if(victim.client)
		victim.client.perspective = EYE_PERSPECTIVE
		victim.client.eye = src

/obj/machinery/gibber/proc/do_move_inside_checks(mob/user, mob/living/victim, loud = TRUE)
	if(isnull(user) && loud)
		return FALSE

	if(isnull(victim))
		return FALSE

	if(length(mobs_to_process) >= mob_capacity)
		if(loud) to_chat(user, SPAN("danger", "\The [src] is full, empty it first!"))
		return FALSE

	if(operating)
		if(loud) to_chat(user, SPAN("danger","\The [src] is locked and running, wait for it to finish."))
		return FALSE

	if(!iscarbon(victim) && !isanimal(victim))
		if(loud) to_chat(user, SPAN("danger","This is not suitable for \the [src]!"))
		return FALSE

	if(victim.abiotic(TRUE))
		if(loud) to_chat(user, SPAN("danger","\The [victim] may not have any abiotic items on."))
		return FALSE

	return TRUE

/obj/machinery/gibber/proc/add_to_contents(mob/user, mob/living/victim)
	if(!do_move_inside_checks(user, victim))
		return

	user.visible_message(SPAN("danger", "\The [user] starts to put \the [victim] into \the [src]!"))
	add_fingerprint(user)
	if(do_after(user, 30, src) && victim.Adjacent(src) && user.Adjacent(src) && victim.Adjacent(user) && length(mobs_to_process) < mob_capacity)
		user.visible_message(SPAN("danger", "\The [user] stuffs \the [victim] into \the [src]!"))
		move_inside(victim)
		update_icon()

/obj/machinery/gibber/proc/process_mobs(mob/user = null)
	if(operating)
		return

	if(!length(mobs_to_process))
		visible_message(SPAN("danger", "You hear a loud metallic grinding sound."))
		playsound(loc, 'sound/signals/error4.ogg', 50, TRUE)
		return

	visible_message(SPAN("danger", "You hear a loud squelchy grinding sound."))
	playsound(loc, 'sound/machines/juicer.ogg', 50, TRUE)
	use_power_oneoff(1000)
	update_icon()

	operating = TRUE
	for(var/mob/pig in mobs_to_process)
		create_mob_drop(pig)

	set_next_think_ctx("finish_processing", world.time + length(mobs_to_process) * gib_time, user)

/obj/machinery/gibber/proc/create_mob_drop(mob/victim)
	if(istype(victim, /mob/living/simple_animal/hostile/faithless))
		new /obj/item/ectoplasm(src)
		return

	if(ismetroid(victim))
		var/mob/living/carbon/metroid/M = victim
		var/extract_type = M.GetCoreType()
		new extract_type(src)
		return

	var/slab_owner = victim.name

	var/slab_count = 3
	var/slab_nutrition = 20
	var/robotic_slab_count = 0
	var/slab_type = /obj/item/reagent_containers/food/meat

	if(iscarbon(victim))
		var/mob/living/carbon/C = victim
		slab_nutrition = C.nutrition / 15
	if(isanimal(victim))
		var/mob/living/simple_animal/S = victim
		if(S.meat_amount)
			slab_count = S.meat_amount
		if(S.meat_type)
			slab_type = S.meat_type
	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		slab_count = 0
		slab_owner = H.real_name
		slab_type = H.species.meat_type
		for(var/obj/item/organ/external/O in H.organs)
			if(O.is_stump())
				continue

			if(istype(O, /obj/item/organ/external/chest))
				var/obj/item/organ/external/chest/C = O
				if(BP_IS_ROBOTIC(O))
					robotic_slab_count += C.butchering_capacity
				else
					slab_count += C.butchering_capacity
				continue

			if(BP_IS_ROBOTIC(O))
				robotic_slab_count++
			else
				slab_count++

	if(slab_count > 0)
		if(issmall(victim))
			slab_nutrition *= 0.5

		slab_nutrition /= slab_count

		var/reagent_transfer_amt
		if(victim.reagents)
			reagent_transfer_amt = round(victim.reagents.total_volume / slab_count, 1)

		for(var/i = 1 to slab_count)
			var/obj/item/reagent_containers/food/meat/new_meat = new slab_type(src, rand(3, 8))
			if(!istype(new_meat))
				continue

			new_meat.SetName("[slab_owner] [new_meat.name]")
			new_meat.reagents.add_reagent(/datum/reagent/nutriment, slab_nutrition)
			if(!victim.reagents)
				continue

			victim.reagents.trans_to_obj(new_meat, reagent_transfer_amt)

	for(var/i = 1 to robotic_slab_count)
		new /obj/item/stack/material/steel(src, rand(3, 5))

/obj/machinery/gibber/proc/finish_processing(mob/user, slipshod = TRUE, gore = TRUE)
	for(var/mob/pig in mobs_to_process)
		if(user) admin_attack_log(user, pig, "Gibbed the victim", "Was gibbed", "gibbed")
		pig.gib(do_gibs = gore)
		qdel(pig)

	operating = FALSE

	playsound(loc, 'sound/effects/splat.ogg', 50, 1)
	LAZYCLEARLIST(mobs_to_process)
	update_icon()

	for(var/obj/O in contents - component_parts)
		if(istype(O, /obj/item/organ) && prob(80))
			qdel(O)
			continue

		O.dropInto(loc)
		if(!slipshod || !throw_dir)
			continue

		O.throw_at(get_edge_target_turf(src, gib_throw_dir), rand(0, 3), 0.5)

#define GIBBER_THINK_DELTA (15 SECONDS)

/obj/machinery/gibber/industrial
	name = "Industrial Gibber"

	icon_state = "ind_gibber"

	component_types = list(
		/obj/item/circuitboard/industrial_gibber,
		/obj/item/stock_parts/micro_laser,
		/obj/item/stock_parts/manipulator,
		/obj/item/stock_parts/matter_bin
	)

	gib_throw_dir = null

	var/scoops_per_attempt = 1

/obj/machinery/gibber/industrial/on_update_icon()
	ClearOverlays()
	if(stat & (NOPOWER|BROKEN))
		return

	if(operating)
		AddOverlays("ind_gibber-use")
	else if(length(mobs_to_process))
		AddOverlays("ind_gibber-jam")

	var/should_glow = update_glow()
	if(should_glow)
		if(operating || length(mobs_to_process))
			AddOverlays(emissive_appearance(icon, "[icon_state]_usejam_ea"))
		else
			AddOverlays(emissive_appearance(icon, "[icon_state]_ea"))

/obj/machinery/gibber/industrial/update_glow()
	if(stat & MAINT)
		set_light(0)
		return FALSE

	var/color = COLOR_NT_RED
	if(operating)
		color = COLOR_GREEN

	set_light(0.7, 0.1, 1, 2, color)
	return TRUE

/obj/machinery/gibber/industrial/Initialize()
	. = ..()

	set_next_think(world.time)
	add_think_ctx("pickup", CALLBACK(src, nameof(.proc/perform_pickup)), world.time + GIBBER_THINK_DELTA)

/obj/machinery/gibber/industrial/RefreshParts()
	. = ..()

	var/scoop_modifier = 0
	for(var/obj/item/stock_parts/manipulator/MM in component_parts)
		scoop_modifier += MM.rating
	scoops_per_attempt = scoop_modifier

/obj/machinery/gibber/industrial/finish_processing(mob/user, slipshod = FALSE, gore = FALSE)
	. = ..(user, slipshod, gore)
	flick("ind_gibber-out", src)
	set_next_think_ctx("pickup", world.time + GIBBER_THINK_DELTA)

/obj/machinery/gibber/industrial/proc/perform_pickup()
	if(operating)
		return

	var/scoops_left = scoops_per_attempt
	for(var/mob/living/possible_prey in range(1, src))
		if(scoops_left <= 0)
			break

		if(!possible_prey?.is_ic_dead() || !do_move_inside_checks(null, possible_prey, FALSE))
			continue

		move_inside(possible_prey)
		scoops_left--

	if(scoops_left <= 0)
		flick("ind_gibber-in", src)
		process_mobs()
		return

	set_next_think_ctx("pickup", world.time + GIBBER_THINK_DELTA)

#undef GIBBER_THINK_DELTA
