#define MAX_W_CLASS ITEM_SIZE_NORMAL
#define MAX_STORAGE_SPACE DEFAULT_LARGEBOX_STORAGE
#define REAGENTS_MAX_VOLUME 100
#define BARREL_DAMAGE_NONE 0
#define BARREL_DAMAGE_MODERATE 1
#define BARREL_DAMAGE_CRITICAL 2
#define THROWFORCE_DAMAGE_THRESHOLD 35

/obj/structure/bed/chair/wheelchair/wheelcannon
	name = "wheelcannon"
	desc = "You sit in this. Either by will or force."
	icon = 'icons/obj/wheelchair.dmi'
	icon_state = "wheelcannon"
	anchored = FALSE

	pull_slowdown = PULL_SLOWDOWN_MEDIUM
	appearance_flags = DEFAULT_APPEARANCE_FLAGS | LONG_GLIDE
	atom_flags = ATOM_FLAG_OPEN_CONTAINER | ATOM_FLAG_NO_REACT

	var/obj/item/storage/item_storage

	var/obj/item/device/assembly_holder/assembly
	var/mutable_appearance/assembly_overlay = null

	var/barrel_damage = 0

	var/static/image/radial_detach = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_detach")
	var/static/image/radial_dump = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_dump")
	var/static/image/radial_eject = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_eject")

/obj/structure/bed/chair/wheelchair/wheelcannon/Initialize()
	. = ..()
	item_storage = new(src)
	item_storage.max_w_class = MAX_W_CLASS
	item_storage.max_storage_space = MAX_STORAGE_SPACE
	item_storage.use_sound = null
	reagents = new /datum/reagents(REAGENTS_MAX_VOLUME, src)

/obj/structure/bed/chair/wheelchair/wheelcannon/Destroy()
	QDEL_NULL(item_storage)
	QDEL_NULL(assembly)
	assembly_overlay = null
	return ..()

/obj/structure/bed/chair/wheelchair/wheelcannon/buckle_mob()
	return

/obj/structure/bed/chair/wheelchair/wheelcannon/examine(mob/user, infix)
	. = ..()

	. += SPAN_NOTICE("It has a pipe mounted!")
	switch(barrel_damage)
		if(0)
			. += SPAN_NOTICE("Its barrel looks intact.")
		if(1)
			. += SPAN_NOTICE("Its barrel is moderately damaged.")
		if(2)
			. += SPAN_NOTICE("Its barrel is badly damaged.")

	if(Adjacent(user, src))
		. += SPAN_NOTICE("Its reagent holder has [reagents.total_volume]u of reagents.")
		for(var/atom/content in item_storage.contents)
			. += SPAN_NOTICE("It has [SPAN_NOTICE("[content]")] loaded.")

/obj/structure/bed/chair/wheelchair/wheelcannon/on_update_icon()
	CutOverlays(assembly_overlay)
	if(!istype(assembly))
		return

	if(isnull(assembly_overlay))
		assembly_overlay = new(assembly)
		assembly_overlay.SetTransform(0.2)
		assembly_overlay.layer = ABOVE_HUMAN_LAYER
		assembly_overlay.appearance_flags |= KEEP_APART
	AddOverlays(assembly_overlay)

/obj/structure/bed/chair/wheelchair/wheelcannon/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/flame))
		var/obj/item/flame/flame = W
		if(flame.lit)
			shoot()
			return

	if(W.IsAssemblyHolder() && !assembly)
		attach_assembly(W, user)
		return

	if((W.atom_flags & ATOM_FLAG_OPEN_CONTAINER))
		return

	if(item_storage?.can_be_inserted(W, user))
		item_storage.handle_item_insertion(W)
		return

	return ..()

/obj/structure/bed/chair/wheelchair/wheelcannon/CtrlShiftClick(mob/user)
	. = ..()
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

/obj/structure/bed/chair/wheelchair/wheelcannon/proc/attach_assembly(obj/item/device/assembly_holder/assembly, mob/user)
	if(!user.drop(assembly, src))
		return

	src.assembly = assembly
	assembly_overlay = null // Will be regenerated in on_update_icon()
	update_icon()
	show_splash_text(user, "assembly attached", "Assembly attached to \the [src].")
	log_and_message_admins("has attached [assembly] to \the [src]", user, get_turf(src))

/obj/structure/bed/chair/wheelchair/wheelcannon/proc/detach_assembly(mob/user)
	var/turf/current_turf = get_turf(src)

	if(user?.Adjacent(current_turf))
		user.pick_or_drop(assembly, current_turf)
	else
		assembly.forceMove(current_turf)

	assembly = null
	assembly_overlay = null // Will be regenerated in on_update_icon()
	update_icon()
	show_splash_text(user, "assembly removed", "Removed assembly from \the [src].")

/obj/structure/bed/chair/wheelchair/wheelcannon/proc/shoot()
	if(!reagents.has_any_reagent(GLOB.wheelcannon_reagents))
		return FALSE

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

	if(pulling)
		var/turf/pulling_recoil_turf = get_step(recoil_turf, GLOB.flip_dir[dir])
		pulling.throw_at(istype(pulling_recoil_turf) ? pulling_recoil_turf : recoil_turf, world.view, 1, src, src)
		pulling.pulledby = null
		pulling = null

	Move(recoil_turf)
	QDEL_IN(particle, 1.5 SECONDS)

/obj/structure/bed/chair/wheelchair/wheelcannon/proc/explode()
	if(reagents.total_volume == REAGENTS_MAX_VOLUME)
		explosion(get_turf(src), 1, 2, 4, sfx_to_play = SFX_EXPLOSION_FUEL)
	else if(reagents.total_volume >= REAGENTS_MAX_VOLUME / 2)
		explosion(get_turf(src), 0, 1, 3, sfx_to_play = SFX_EXPLOSION_FUEL)
	else
		explosion(get_turf(src), -1, 1, 2, sfx_to_play = SFX_EXPLOSION_FUEL)

	if(!QDELETED(src))
		qdel_self()

/obj/structure/bed/chair/wheelchair/wheelcannon/proc/calc_throwforce()
	var/force = 0
	for(var/reagent in GLOB.wheelcannon_reagents)
		force += reagents.get_reagent_amount(reagent) * GLOB.wheelcannon_reagents[reagent]

	reagents.clear_reagents()

	return force

/obj/structure/bed/chair/wheelchair/wheelcannon/fire_act()
	shoot()
	return ..()

#undef MAX_W_CLASS
#undef MAX_STORAGE_SPACE
#undef REAGENTS_MAX_VOLUME
#undef BARREL_DAMAGE_NONE
#undef BARREL_DAMAGE_MODERATE
#undef BARREL_DAMAGE_CRITICAL
#undef THROWFORCE_DAMAGE_THRESHOLD
