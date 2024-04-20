#define MAX_W_CLASS ITEM_SIZE_NORMAL
#define MAX_STORAGE_SPACE DEFAULT_LARGEBOX_STORAGE
#define REAGENTS_MAX_VOLUME 100
#define BARREL_DAMAGE_NONE 0
#define BARREL_DAMAGE_MODERATE 1
#define BARREL_DAMAGE_CRITICAL 2
#define THROWFORCE_DAMAGE_THRESHOLD 35
GLOBAL_LIST_INIT(wheelcannon_reagents, list(/datum/reagent/ethanol = 0.35, /datum/reagent/toxin/plasma = 1.2, /datum/reagent/acetone = 0.35))

/obj/structure/bed/chair/wheelchair
	name = "wheelchair"
	desc = "You sit in this. Either by will or force."
	icon = 'icons/obj/wheelchair.dmi'
	base_icon_state = "wheelchair"
	icon_state = "wheelchair"
	var/cannon_icon_state = "wheelcannon"
	anchored = 0
	buckle_movable = 1
	movement_handlers = list(
		/datum/movement_handler/deny_stairs,
		/datum/movement_handler/deny_multiz,
		/datum/movement_handler/delay = list(4),
		/datum/movement_handler/move_relay_self
	)
	foldable = FALSE
	pull_slowdown = PULL_SLOWDOWN_MEDIUM
	appearance_flags = DEFAULT_APPEARANCE_FLAGS | LONG_GLIDE

	var/has_cannon = FALSE
	var/obj/item/storage/item_storage

	var/obj/item/device/assembly_holder/assembly
	var/mutable_appearance/assembly_overlay = null

	var/image/wheel_overlay = null

	var/driving = FALSE
	var/mob/living/pulling = null
	var/bloodiness

	var/barrel_damage = 0

	var/static/image/radial_detach = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_detach")
	var/static/image/radial_dump = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_dump")
	var/static/image/radial_eject = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_eject")

/obj/structure/bed/chair/wheelchair/examine(mob/user, infix)
	. = ..()

	if(has_cannon)
		. += SPAN_NOTICE("It has a pipe mounted!")
		switch(barrel_damage)
			if(0)
				. += SPAN_NOTICE("Its barrel looks intact.")
			if(1)
				. += SPAN_NOTICE("Its barrel is moderately damaged.")
			if(2)
				. += SPAN_NOTICE("Its barrel is badly damaged.")

	if(has_cannon && Adjacent(user, src))
		. += SPAN_NOTICE("Its reagent holder has [reagents.total_volume]u of reagents.")
		for(var/atom/content in item_storage.contents)
			. += SPAN_NOTICE("It has [SPAN_NOTICE("[content]")] loaded.")

/obj/structure/bed/chair/wheelchair/examine_more(mob/user)
	. = ..()
	. += SPAN_NOTICE("Load with items. Fuel with ethanol, plasma or acetone.")
	. += SPAN_NOTICE("Igniter can be also attached. Alt + RightClick to detach it")

/obj/structure/bed/chair/wheelchair/Destroy()
	pulling = null
	assembly_overlay = null
	wheel_overlay = null
	QDEL_NULL(item_storage)
	QDEL_NULL(assembly)
	return ..()

/obj/structure/bed/chair/wheelchair/on_update_icon()
	if(has_cannon)
		icon_state = cannon_icon_state
	else
		icon_state = base_icon_state

	CutOverlays(assembly_overlay)
	if(istype(assembly))
		if(isnull(assembly_overlay))
			assembly_overlay = new(assembly)
			assembly_overlay.SetTransform(0.2)
			assembly_overlay.layer = ABOVE_HUMAN_LAYER
			assembly_overlay.appearance_flags |= KEEP_APART
		AddOverlays(assembly_overlay)

	CutOverlays(wheel_overlay)
	if(!has_cannon)
		wheel_overlay = image(icon = 'icons/obj/wheelchair.dmi', icon_state = "w_overlay", dir = dir, layer = ABOVE_HUMAN_LAYER)
		AddOverlays(wheel_overlay)
	if(buckled_mob)
		buckled_mob.set_dir(dir)

/obj/structure/bed/chair/wheelchair/set_dir()
	..()
	update_icon()

/obj/structure/bed/chair/wheelchair/attackby(obj/item/W, mob/user)
	if(!isnull(reagents) && istype(W, /obj/item/reagent_containers) && W.is_open_container())
		var/obj/item/reagent_containers/container = W
		if(!W.reagents?.total_volume)
			show_splash_text(user, "container empty!", "\The [W] has no reagents!")
			return

		var/free_amount = reagents?.get_free_space()
		if(free_amount <= 0)
			show_splash_text(user, "container is full!", "\The [src] can't hold more reagents!")
			return

		var/transfer_amount = min(container.amount_per_transfer_from_this, free_amount)
		W.reagents.trans_to(src, transfer_amount)
		return

	if(isassembly(W) && !istype(assembly))
		attach_assembly(W, user)
		return

	if(item_storage?.can_be_inserted(W, user))
		item_storage.handle_item_insertion(W)
		return

	else if(isWrench(W) || istype(W, /obj/item/stack) || isWirecutter(W))
		return

	..()

/obj/structure/bed/chair/wheelchair/AltRightClick(mob/user)
	if(!has_cannon)
		return

	var/list/options = list()

	if(assembly)
		options["Detach Assembly"] = radial_detach

	if(LAZYLEN(item_storage.contents))
		options["Eject Ammo"] = radial_eject

	if(reagents?.total_volume)
		options["Dump Reagents"] = radial_dump

	var/choice

	if(length(options) < 1)
		return

	if(length(options) == 1)
		choice = options[1]
	else
		choice = show_radial_menu(user, src, options, require_near = TRUE)

	switch(choice)
		if("Detach Assembly")
			detach_assembly(user)
		if("Eject Ammo")
			var/turf/T = get_turf(src)
			for(var/obj/item/I in item_storage?.contents)
				item_storage.remove_from_storage(I, T, TRUE)
			item_storage.finish_bulk_removal()
		if("Dump Reagents")
			reagents?.clear_reagents()

/obj/structure/bed/chair/wheelchair/proc/attach_assembly(obj/item/device/assembly_holder/assembly, mob/user)
	if(!user.drop(assembly, src))
		return

	src.assembly = assembly
	assembly_overlay = null // Will be regenerated in on_update_icon()
	show_splash_text(user, "assembly attached", "Assembly attached to \the [src].")
	log_and_message_admins("has attached [assembly] to \the [src]", user, get_turf(src))

/obj/structure/bed/chair/wheelchair/proc/detach_assembly(mob/user)
	var/turf/current_turf = get_turf(src)

	if(user?.Adjacent(current_turf))
		user.pick_or_drop(assembly, current_turf)
	else
		assembly.forceMove(current_turf)

	assembly = null
	assembly_overlay = null // Will be regenerated in on_update_icon()
	show_splash_text(user, "assembly removed", "Removed assembly from \the [src].")

/obj/structure/bed/chair/wheelchair/attack_hand(mob/living/user)
	shoot()

	return ..()

/obj/structure/bed/chair/wheelchair/MouseDrop_T(atom/movable/dropping, mob/living/user)
	if(istype(dropping, /obj/structure/disposalconstruct))
		show_splash_text(user, "attaching...", "You start attaching \the [dropping] to \the [src]...")
		if(!do_after(user, 10 SECONDS, src, TRUE))
			return

		if(QDELETED(src) || QDELETED(dropping) || QDELETED(user))
			return

		show_splash_text(user, "pipe attached!", "Attached \the [dropping] to \the [src]!")
		qdel(dropping)
		init_item_storage()
		has_cannon = TRUE
		update_icon()

	..()

/obj/structure/bed/chair/wheelchair/relaymove(mob/user, direction)
	// Redundant check?
	if(user.stat || user.stunned || user.weakened || user.paralysis || user.lying || user.restrained())
		if(user == pulling)
			pulling = null
			user.pulledby = null
			to_chat(user, SPAN_WARNING("You lost your grip!"))
		return

	if(buckled_mob && pulling && user == buckled_mob)
		if(pulling.stat || pulling.stunned || pulling.weakened || pulling.paralysis || pulling.lying || pulling.restrained())
			pulling.pulledby = null
			pulling = null
	if(user.pulling && (user == pulling))
		pulling = null
		user.pulledby = null
		return

	if(propelled)
		return

	if(pulling && (get_dist(src, pulling) > 1))
		pulling = null
		user.pulledby = null
		if(user == pulling)
			return

	if(pulling && (get_dir(src.loc, pulling.loc) == direction))
		to_chat(user, SPAN_WARNING("You cannot go there."))
		return

	if(pulling && buckled_mob && (buckled_mob == user))
		to_chat(user, SPAN_WARNING("You cannot drive while being pushed"))
		return

	// Let's roll
	driving = 1
	var/turf/T = null
	//--1---Move occupant---1--//
	if(buckled_mob)
		buckled_mob.buckled = null
		step(buckled_mob, direction)
		buckled_mob.buckled = src
	//--2----Move driver----2--//
	if(pulling)
		T = pulling.loc
		if(get_dist(src, pulling) >= 1)
			step(pulling, get_dir(pulling.loc, src.loc))
	//--3--Move wheelchair--3--//
	step(src, direction)
	if(buckled_mob) // Make sure it stays beneath the occupant
		Move(buckled_mob.loc)
	set_dir(direction)
	if(pulling) // Driver
		if(pulling.loc == src.loc) // We moved onto the wheelchair? Revert!
			pulling.forceMove(T)
		else
			spawn(0)
			if(get_dist(src, pulling) > 1) // We are too far away? Losing control.
				pulling = null
				user.pulledby = null
			pulling.set_dir(get_dir(pulling, src)) // When everything is right, face the wheelchair
	if(bloodiness)
		create_track()
	driving = 0

/obj/structure/bed/chair/wheelchair/Move(newloc, direct)
	. = ..()
	if(!.)
		return

	if(buckled_mob)
		var/mob/living/occupant = buckled_mob
		if(!driving)
			if (occupant && (src.loc != occupant.loc))
				if (propelled)
					for (var/mob/O in src.loc)
						if (O != occupant)
							Bump(O)
				else
					unbuckle_mob()
			if (pulling && (get_dist(src, pulling) > 1))
				pulling.pulledby = null
				to_chat(pulling, SPAN_WARNING("You lost your grip"))
				pulling = null
		else
			if (occupant && (src.loc != occupant.loc))
				src.forceMove(occupant.loc) // Failsafe to make sure the wheelchair stays beneath the occupant after driving

/obj/structure/bed/chair/wheelchair/attack_hand(mob/living/user)
	if (pulling)
		MouseDrop(usr)
	else
		user_unbuckle_mob(user)
	return

/obj/structure/bed/chair/wheelchair/CtrlClick(mob/user)
	if(in_range(src, user))
		if(!ishuman(user) || user.incapacitated(INCAPACITATION_DEFAULT | INCAPACITATION_BUCKLED_PARTIALLY))
			return

		if(user == buckled_mob)
			to_chat(user, SPAN_WARNING("You realize you are unable to push the wheelchair you sit in."))
			return

		if(!pulling)
			pulling = user
			user.pulledby = src
			if(user.pulling)
				user.stop_pulling()
			user.set_dir(get_dir(user, src))
			to_chat(user, "You grip \the [name]'s handles.")
		else
			to_chat(usr, "You let go of \the [name]'s handles.")
			pulling.pulledby = null
			pulling = null
		return

/obj/structure/bed/chair/wheelchair/Bump(atom/A)
	..()
	if(!buckled_mob)
		return

	if(propelled || (pulling && (pulling.a_intent == I_HURT)))
		var/mob/living/occupant = unbuckle_mob()

		if (pulling && (pulling.a_intent == I_HURT))
			occupant.throw_at(A, 3, 1, pulling)
		else if (propelled)
			occupant.throw_at(A, 3, 1)

		var/def_zone = ran_zone()
		var/blocked = occupant.run_armor_check(def_zone, "melee")
		occupant.throw_at(A, 3, 1)
		occupant.apply_effect(6, STUN, blocked)
		occupant.apply_effect(6, WEAKEN, blocked)
		occupant.apply_effect(6, STUTTER, blocked)
		occupant.apply_damage(10, BRUTE, def_zone, blocked)
		playsound(src.loc, 'sound/effects/fighting/punch1.ogg', 50, 1, -1)
		if(istype(A, /mob/living))
			var/mob/living/victim = A
			def_zone = ran_zone()
			blocked = victim.run_armor_check(def_zone, "melee")
			victim.apply_effect(6, STUN, blocked)
			victim.apply_effect(6, WEAKEN, blocked)
			victim.apply_effect(6, STUTTER, blocked)
			victim.apply_damage(10, BRUTE, def_zone, blocked)
		if(pulling)
			occupant.visible_message(SPAN_DANGER("[pulling] has thrusted \the [name] into \the [A], throwing \the [occupant] out of it!"))
			admin_attack_log(pulling, occupant, "Crashed their victim into \an [A].", "Was crashed into \an [A].", "smashed into \the [A] using")
		else
			occupant.visible_message(SPAN_DANGER("[occupant] crashed into \the [A]!"))

/obj/structure/bed/chair/wheelchair/proc/create_track()
	var/obj/effect/decal/cleanable/blood/tracks/B = new(loc)
	var/newdir = get_dir(get_step(loc, dir), loc)
	if(newdir == dir)
		B.set_dir(newdir)
	else
		newdir = newdir | dir
		if(newdir == 3)
			newdir = 1
		else if(newdir == 12)
			newdir = 4
		B.set_dir(newdir)
	bloodiness--

/obj/structure/bed/chair/wheelchair/bullet_act(obj/item/projectile/Proj, def_zone)
	if(buckled_mob)
		return buckled_mob.bullet_act(Proj, def_zone)
	return ..()

/obj/structure/bed/chair/wheelchair/buckle_mob(mob/M as mob, mob/user as mob)
	if(has_cannon)
		return

	if(M == pulling)
		pulling = null
		usr.pulledby = null

	..()

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.update_organ_movespeed()

/obj/structure/bed/chair/wheelchair/unbuckle_mob()
	if(ishuman(buckled_mob))
		var/mob/living/carbon/human/H = buckled_mob
		H.update_organ_movespeed()

	return ..()

/obj/structure/bed/chair/wheelchair/proc/init_item_storage()
	item_storage = new(src)
	item_storage.max_w_class = MAX_W_CLASS
	item_storage.max_storage_space = MAX_STORAGE_SPACE
	item_storage.use_sound = null
	reagents = new /datum/reagents(REAGENTS_MAX_VOLUME, src)
	atom_flags |= ATOM_FLAG_OPEN_CONTAINER | ATOM_FLAG_NO_REACT

/obj/structure/bed/chair/wheelchair/proc/can_shoot()
	if(!has_cannon)
		return FALSE

	if(!reagents.has_any_reagent(GLOB.wheelcannon_reagents))
		return FALSE

	if(!LAZYLEN(item_storage.contents))
		return FALSE

	return TRUE

/obj/structure/bed/chair/wheelchair/proc/shoot()
	if(!can_shoot())
		return

	if(barrel_damage > BARREL_DAMAGE_CRITICAL && prob(80))
		explode()
		return

	else if(barrel_damage > BARREL_DAMAGE_NONE && barrel_damage <= BARREL_DAMAGE_CRITICAL && prob(5))
		explode()
		return

	var/turf/center_target = get_turf(src)

	for(var/i = 1 to world.view)
		var/turf/T = get_step(center_target, dir)
		if(!istype(T) || T.contains_dense_objects(check_mobs = FALSE))
			break

		center_target = T

	if(!istype(center_target))
		return

	var/list/target_turfs = list(center_target)
	target_turfs += get_step(center_target, EAST)
	target_turfs += get_step(center_target, WEST)

	playsound(get_turf(src), 'sound/effects/explosions/wheelcannon_shoot.ogg', 100, TRUE)

	var/atom/movable/particle_emitter/fire_smoke/light/particle = new /atom/movable/particle_emitter/fire_smoke/light(get_turf(src))

	var/throwforce = calc_throwforce()

	if(throwforce >= THROWFORCE_DAMAGE_THRESHOLD && prob(70))
		barrel_damage = BARREL_DAMAGE_CRITICAL
	else if(prob(60))
		barrel_damage++

	for(var/obj/item/O in item_storage.contents)
		item_storage.remove_from_storage(O, loc)
		O.forceMove(get_turf(src))
		O.dir = dir // It's dumb, but it works. Kinda.
		var/turf/target = pick(target_turfs)
		var/atom/target_atom = safepick(target.contents)
		O.throw_at(istype(target_atom) ? target_atom : target, world.view, 1, usr ? usr : src, src, pick(BP_ALL_LIMBS), throwforce)

	var/turf/recoil_turf = get_step(get_turf(src), GLOB.flip_dir[dir])
	if(!istype(recoil_turf))
		return

	Move(recoil_turf)
	QDEL_IN(particle, 1.5 SECONDS)

/obj/structure/bed/chair/wheelchair/proc/explode()
	if(reagents.total_volume == REAGENTS_MAX_VOLUME)
		explosion(get_turf(src), 1, 2, 4, sfx_to_play = SFX_EXPLOSION_FUEL)
	else if(reagents.total_volume >= REAGENTS_MAX_VOLUME / 2)
		explosion(get_turf(src), 0, 1, 3, sfx_to_play = SFX_EXPLOSION_FUEL)
	else
		explosion(get_turf(src), -1, 1, 2, sfx_to_play = SFX_EXPLOSION_FUEL)

	if(!QDELETED(src))
		qdel_self()

/obj/structure/bed/chair/wheelchair/proc/calc_throwforce()
	var/force = 0
	for(var/reagent in GLOB.wheelcannon_reagents)
		force += reagents.get_reagent_amount(reagent) * GLOB.wheelcannon_reagents[reagent]

	reagents.clear_reagents()

	return force

#undef MAX_W_CLASS
#undef MAX_STORAGE_SPACE
#undef REAGENTS_MAX_VOLUME
#undef BARREL_DAMAGE_NONE
#undef BARREL_DAMAGE_MODERATE
#undef BARREL_DAMAGE_CRITICAL
#undef THROWFORCE_DAMAGE_THRESHOLD
