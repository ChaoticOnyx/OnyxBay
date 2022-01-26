#define FRAME_DESTROYED 0
#define FRAME_NORMAL 1
#define FRAME_REINFORCED 2
#define FRAME_GRILLE 3

// Making things simple was never an option
/datum/windowpane
	var/material/glass/window_material = null
	var/obj/structure/window_frame/my_frame = null
	var/shardtype = /obj/item/material/shard

	var/name = "windowpane"
	var/icon_base = "window"
	var/damage_icon = null

	var/max_health = 17.5 // 35% of the material's integrity
	var/health = 17.5
	var/is_inner = FALSE
	var/state = 3
	var/reinforced = FALSE

	var/explosion_block = 0
	var/max_heat = T0C + 100

	var/preset_material

// These guys help us to save a bit of init time.
/datum/windowpane/glass/preset_material = MATERIAL_GLASS
/datum/windowpane/rglass/preset_material = MATERIAL_REINFORCED_GLASS
/datum/windowpane/plass/preset_material = MATERIAL_PLASS
/datum/windowpane/rplass/preset_material = MATERIAL_REINFORCED_PLASS

/datum/windowpane/New(obj/structure/window_frame/WF, material/M, inner = FALSE)
	..()
	my_frame = WF
	if(preset_material)
		set_material(get_material_by_name(preset_material))
	else
		set_material(M)
	is_inner = inner

/datum/windowpane/Destroy()
	if(!QDELETED(my_frame))
		if(my_frame.outer_pane == src)
			my_frame.outer_pane = null
		else if(my_frame.inner_pane == src)
			my_frame.inner_pane = null
	my_frame.set_state()
	my_frame.update_nearby_icons()
	my_frame = null
	. = ..()

/datum/windowpane/proc/dismantle()
	ASSERT(my_frame) // Such thing shall never happen. Period.
	window_material.place_sheet(get_turf(my_frame))
	qdel(src)

/datum/windowpane/proc/set_material(material/M)
	ASSERT(M)
	window_material = M
	name = "[M.display_name] windowpane"
	icon_base = M.window_icon_base
	max_health = M.integrity * 0.35
	health = max_health
	max_heat = M.melting_point

	if(window_material.is_reinforced())
		explosion_block += 1
		reinforced = TRUE

	if(max_heat >= (T0C + 2000))
		explosion_block += 1

/datum/windowpane/proc/take_damage(damage = 0, sound_effect = TRUE)
	var/initialhealth = health
	health = max(0, health - damage)

	if(health <= 0)
		shatter()
		return

	if(sound_effect)
		playsound(my_frame.loc, GET_SFX(SFX_GLASS_HIT), 100, 1)

	var/prev_damage_icon = damage_icon
	if(health < max_health * 0.25 && initialhealth >= max_health * 0.25)
		my_frame.visible_message("\The [my_frame]'s [name] looks like it's about to shatter!")
		damage_icon = "damage3"
	else if(health < max_health * 0.5 && initialhealth >= max_health * 0.5)
		my_frame.visible_message("\The [my_frame]'s [name] looks seriously damaged!")
		damage_icon = "damage2"
	else if(health < max_health * 0.75 && initialhealth >= max_health * 0.75)
		my_frame.visible_message("Cracks begin to appear in \the [my_frame]'s [name]!")
		damage_icon = "damage1"
	if(prev_damage_icon != damage_icon)
		my_frame.update_icon()
	return

/datum/windowpane/proc/shatter(display_message = TRUE)
	if(QDELETED(my_frame)) // Either we lost our frame, or it somehow got destroyed before we had a chance to shatter.
		qdel(src) // Should never happen, but we can't be sure as long as bombs and singulos exist.
		return

	playsound(my_frame, SFX_BREAK_WINDOW, 70, 1)
	if(display_message)
		my_frame.visible_message("[my_frame][is_inner ? "\'s inner windowpane" : ""] shatters!")

	var/obj/item/material/shard/S = window_material.place_shard(get_turf(my_frame))
	S.set_material(window_material.name)

	if(reinforced)
		new /obj/item/stack/rods(get_turf(my_frame))

	qdel(src)


// obj/structure/window_frame/grille may look weird but hey at least it's not obj/structure/stool/chair/bed
/obj/structure/window_frame
	name = "window frame"
	desc = "A simple window frame made of steel rods."
	icon = 'icons/obj/structures.dmi'
	icon_state = "winframe"
	var/icon_base = "winframe"
	var/icon_border = "winborder"
	density = FALSE
	anchored = FALSE
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	can_atmos_pass = ATMOS_PASS_PROC
	layer = WINDOW_FRAME_LAYER
	explosion_resistance = 1
	var/max_health = 8
	var/health = 8
	hitby_sound = 'sound/effects/grillehit.ogg'
	hitby_loudness_multiplier = 0.5

	var/frame_state = FRAME_NORMAL
	var/datum/windowpane/outer_pane = null
	var/datum/windowpane/inner_pane = null

	var/preset_outer_pane
	var/preset_inner_pane

	var/list/mobs_can_pass = list(
		/mob/living/bot,
		/mob/living/carbon/metroid,
		/mob/living/simple_animal/mouse,
		/mob/living/silicon/robot/drone
		)

/obj/structure/window_frame/Initialize()
	. = ..()
	if(preset_outer_pane)
		outer_pane = new preset_outer_pane(src)
		anchored = TRUE
	if(preset_inner_pane)
		inner_pane = new preset_inner_pane(src, inner = TRUE)
		anchored = TRUE
	// Dynamic explosion block depending on the number and material of panes.
	explosion_block = EXPLOSION_BLOCK_PROC
	update_nearby_tiles(need_rebuild = TRUE)
	update_nearby_icons()

/obj/structure/window_frame/GetExplosionBlock()
	. += outer_pane?.explosion_block
	. += inner_pane?.explosion_block

/obj/structure/window_frame/Destroy()
	QDEL_NULL(outer_pane)
	QDEL_NULL(inner_pane)
	. = ..()

/obj/structure/window_frame/ex_act(severity)
	switch(severity)
		if(1)
			// 25% chance for each pane to drop shards, 75% to just evaporate.
			if(outer_pane && prob(25))
				outer_pane.shatter(FALSE)
			if(inner_pane && prob(25))
				inner_pane.shatter(FALSE)
			qdel(src)
		if(2)
			if(outer_pane)
				if(inner_pane && prob(90 - (20 * outer_pane.explosion_block)))
					inner_pane.shatter(FALSE) // Outer pane can protect the inner one, depending on its explosion resistance.
				outer_pane.shatter(FALSE)
			else if(inner_pane)
				inner_pane.shatter(FALSE)
			else
				qdel(src) // Poor frame gets murdered here if not protected by windowpanes.
		if(1)
			if(prob(50))
				if(outer_pane)
					outer_pane.shatter(FALSE)
				else
					inner_pane?.shatter(FALSE) // Small explosions can't wreck both layers at once.

/obj/structure/window_frame/proc/set_state(new_state = null)
	if(new_state)
		frame_state = new_state
	switch(frame_state)
		if(FRAME_GRILLE)
			name = "[outer_pane ? "windowed " : ""]grille"
			desc = "A flimsy lattice of metal rods, with screws to secure it to the floor."
			icon_state = "grille"
			icon_base = "grille"
			icon_border = "winborder"
			hitby_loudness_multiplier = 1.5
			density = TRUE
			max_health = 12
		if(FRAME_REINFORCED)
			if(outer_pane)
				name = "[outer_pane ? "" : "unfinished "]reinforced window"
			else if(inner_pane)
				name = "unfinished reinforced window"
			else
				name = "reinforced window frame"
			desc = "A reinforced window frame made of steel rods, capable of holding two windowpanes at once."
			icon_state = "winframe_r"
			icon_base = "winframe_r"
			icon_border = "winborder_r"
			hitby_loudness_multiplier = 1.0
			density = TRUE
			max_health = 10
		if(FRAME_NORMAL)
			name = outer_pane ? "window" : "window frame"
			desc = "A simple window frame made of steel rods."
			icon_state = "winframe"
			icon_base = "winframe"
			icon_border = "winborder"
			hitby_loudness_multiplier = 0.5
			density = outer_pane ? TRUE : FALSE
			max_health = 8
		if(FRAME_DESTROYED)
			name = "broken grille"
			desc = "Not much left of a grille, but at least a single steel rod still can be salvaged from it."
			icon_state = "grille-b"
			icon_base = "grille-b"
			icon_border = "blank"
			hitby_loudness_multiplier = 0.5
			density = FALSE
			max_health = 6

	health = max_health // Simple reset is easier than inventing things.

// The scariest thing present. Let's just -=HoPe=- it's not -=ThAt=- performance-heavy.
/obj/structure/window_frame/update_icon()
	overlays.Cut()
	icon_state = icon_base

	if(frame_state == FRAME_DESTROYED)
		return

	layer = WINDOW_FRAME_LAYER

	if(inner_pane)
		var/list/dirs = list()
		if(inner_pane.state == 3)
			for(var/obj/structure/window_frame/W in orange(src, 1))
				if(W.inner_pane?.state == 3)
					dirs += get_dir(src, W)

		var/list/connections = dirs_to_corner_states(dirs)

		for(var/i = 1 to 4)
			var/image/I = image(icon, "[inner_pane.icon_base][connections[i]]", dir = 1<<(i-1))
			I.plane = DEFAULT_PLANE
			I.layer = WINDOW_INNER_LAYER
			overlays += I

		if(inner_pane.damage_icon)
			overlays += image(icon, inner_pane.damage_icon)

	if(outer_pane)
		var/list/dirs = list()
		if(outer_pane.state == 3)
			for(var/obj/structure/window_frame/W in orange(src, 1))
				if(W.outer_pane?.state == 3)
					dirs += get_dir(src, W)

		var/list/connections = dirs_to_corner_states(dirs)

		for(var/i = 1 to 4)
			var/image/I = image(icon, "[outer_pane.icon_base][connections[i]]", dir = 1<<(i-1))
			I.plane = DEFAULT_PLANE
			I.layer = WINDOW_OUTER_LAYER
			overlays += I

		if(outer_pane.damage_icon)
			overlays += image(icon, outer_pane.damage_icon)

	if(outer_pane?.state >= 1)
		var/list/dirs = list()
		for(var/obj/structure/window_frame/W in orange(src,1))
			if(W.outer_pane?.state >= 1)
				dirs += get_dir(src, W)

		var/list/connections = dirs_to_corner_states(dirs)

		for(var/i = 1 to 4)
			var/image/I = image(icon, "[icon_border][connections[i]]", dir = 1<<(i-1))
			I.plane = DEFAULT_PLANE
			I.layer = WINDOW_BORDER_LAYER
			overlays += I

//This proc is used to update the icons of nearby windows. It should not be confused with update_nearby_tiles(), which is an atmos proc!
/obj/structure/window_frame/proc/update_nearby_icons()
	update_icon()
	for(var/obj/structure/window_frame/W in orange(src, 1))
		W.update_icon()

/obj/structure/window_frame/Bumped(atom/user)
	if(frame_state == FRAME_GRILLE && ismob(user))
		shock(user, 70)
	..()

/obj/structure/window_frame/attack_hand(mob/user)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	user.do_attack_animation(src)

	var/damage_dealt = 1
	var/attack_message = "kicks"
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H.species.can_shred(H))
			attack_message = "mangles"
			damage_dealt = 5

	if(frame_state == FRAME_GRILLE && shock(user, 70))
		return

	if(MUTATION_HULK in user.mutations)
		damage_dealt += 5
	else
		damage_dealt += 1

	attack_generic(user, damage_dealt, attack_message)

/obj/structure/window_frame/CanPass(atom/movable/mover, turf/target)
	if(!(outer_pane || inner_pane) || (mover.pass_flags & PASS_FLAG_GLASS)) // Just a frame without windows OR we don't care about windows anyways.
		if(mover.pass_flags & PASS_FLAG_GRILLE)
			return TRUE // We pass the frame giving no fuck about its level.

		switch(frame_state)
			if(FRAME_GRILLE)
				if(istype(mover, /obj/item/projectile))
					return prob(30)
				if(mover.pass_flags & PASS_FLAG_GLASS)
					return prob(60)
			if(FRAME_REINFORCED)
				if(istype(mover, /obj/item/projectile))
					return TRUE
				if(mover.pass_flags & PASS_FLAG_GLASS)
					return TRUE
				var/mob/living/M = mover
				if(istype(M))
					if(M.lying)
						return ..()
					for(var/mob_type in mobs_can_pass)
						if(istype(M, mob_type))
							return ..()
					return issmall(M)
				return ..()
			else
				return TRUE

	return !density // No better way to pass, let's just beg it to be broken.

/obj/structure/window_frame/CanZASPass(turf/T, is_zone)
	return !(outer_pane || inner_pane)

/obj/structure/window_frame/bullet_act(obj/item/projectile/Proj)
	if(!Proj)
		return

	//Flimsy grilles aren't so great at stopping projectiles. However they can absorb some of the impact
	var/damage = Proj.get_structure_damage()
	var/passthrough = 0

	if(!damage)
		return

	if(outer_pane)
		..()
		outer_pane.take_damage(damage)
		return
	else if(inner_pane)
		..()
		inner_pane.take_damage(damage)
		return

	if(frame_state != FRAME_GRILLE)
		Proj.damage *= between(0, Proj.damage / 60, 1)
		passthrough = TRUE
	else
		//20% chance that the grille provides a bit more cover than usual. Support structure for example might take up 20% of the grille's area.
		//If they click on the grille itself then we assume they are aiming at the grille itself and the extra cover behaviour is always used.
		switch(Proj.damage_type)
			if(BRUTE)
				//bullets
				if(Proj.original == src || prob(20))
					Proj.damage *= between(0, Proj.damage / 60, 0.5)
					if(prob(max((damage - 10) / 25, 0)) * 100)
						passthrough = TRUE
				else
					Proj.damage *= between(0, Proj.damage / 60, 1)
					passthrough = TRUE
			if(BURN)
				// beams and other projectiles are either blocked completely by grilles or stop half the damage.
				if(!(Proj.original == src || prob(20)))
					Proj.damage *= 0.5
					passthrough = TRUE

		if(passthrough)
			. = PROJECTILE_CONTINUE
			damage = between(0, (damage - Proj.damage) * (Proj.damage_type == BRUTE? 0.4 : 1), 10) //if the bullet passes through then the grille avoids most of the damage

	health -= damage * 0.2
	spawn()
		healthcheck() //spawn to make sure we return properly if the grille is deleted

/obj/structure/window_frame/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/stack/material))
		var/obj/item/stack/material/ST = W
		if(ST.material.created_window)
			if(frame_state == FRAME_DESTROYED)
				to_chat(user, SPAN("notice", "You don't feel like \the [src] can hold a windowpane by any means."))
				return
			if(outer_pane)
				to_chat(user, SPAN("notice", "You can't seem to find a way to place another windowpane in \the [src]."))
				if(frame_state == FRAME_REINFORCED && !inner_pane)
					to_chat(user, SPAN("notice", "Strangely enough, \the [src] is missing the inner windowpane. Replacing it requires unstalling the outer pane first."))
				return
			if(!anchored)
				to_chat(user, SPAN("notice", "\The [src] must be secured to the floor first."))
			var/is_inner = FALSE
			if(frame_state == FRAME_REINFORCED && !inner_pane)
				is_inner = TRUE

			for(var/obj/structure/window/WINDOW in loc) // No layering frames with regular sided windows. Nah. Nope. No way.
				to_chat(user, SPAN("warning", "\The [WINDOW] interferes with your attempts to place a windowpane."))
				return
			to_chat(user, SPAN("notice", "You start placing the [is_inner ? "inner " : ""]windowpane into \the [src]."))
			if(do_after(user, 20, src))
				for(var/obj/structure/window/WINDOW in loc) // checking this for a 2nd time to check if a window was made while we were waiting.
					to_chat(user, SPAN("warning", "\The [WINDOW] interferes with your attempts to place a windowpane."))
					return
				if(outer_pane || (is_inner && inner_pane))
					to_chat(user, SPAN("warning", "\The [src] already has a windowpane. Someone's beat you to it."))
					return
				if(!anchored)
					to_chat(user, SPAN("notice", "\The [src] must be secured to the floor first."))
				if(frame_state == FRAME_DESTROYED)
					to_chat(user, SPAN("notice", "Something tells you that \the [src] cannot hold a windowpane anymore."))
					return

				if(ST.use(1))
					if(is_inner)
						to_chat(user, SPAN("notice", "You place the inner windowpane into \the [src]."))
						inner_pane = new /datum/windowpane(src, ST.material, TRUE)
						inner_pane.state = 0
					else
						to_chat(user, SPAN("notice", "You place the windowpane into \the [src]."))
						outer_pane = new /datum/windowpane(src, ST.material)
						outer_pane.state = 0
					set_state()
					update_nearby_icons()
			return

	var/datum/windowpane/affected = null
	if(outer_pane)
		affected = outer_pane // Let's try the outer windowpane first
	else if(inner_pane)
		affected = inner_pane // ... and try the inner one if the outer is missing

	if(affected)
		if(W.item_flags & ITEM_FLAG_NO_BLUDGEON)
			return

		if(isScrewdriver(W))
			if(affected.state >= 2)
				affected.state = 5 - affected.state
				update_nearby_icons()
				playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
				to_chat(user, (affected.state == 3 ? SPAN("notice", "You have fastened \the [affected.name]'s outer bolts.") : SPAN("notice", "You have unfastened \the [affected.name]'s outer bolts.")))
			else if(affected.state <= 1)
				affected.state = 1 - affected.state
				update_nearby_icons()
				playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
				to_chat(user, (affected.state == 1 ? SPAN("notice", "You have fastened \the [affected.name] to the frame.") : SPAN("notice", "You have unfastened \the [affected.name] from the frame.")))
			return

		if(isCrowbar(W) && (affected.state == 1 || affected.state == 2))
			affected.state = 3 - affected.state
			update_nearby_icons()
			playsound(loc, 'sound/items/Crowbar.ogg', 75, 1)
			to_chat(user, (affected.state == 2 ? SPAN("notice", "You have pried \the [affected.name] into the frame.") : SPAN("notice", "You have pried \the [affected.name] out of the frame.")))
			return

		if(isWrench(W) && affected.state == 0)
			var/pane_name = affected.name // Windowpane gets deleted during dismantle() so we want to keep its name for the message.
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
			affected.dismantle()
			visible_message(SPAN("notice", "[user] dismantles \the [pane_name] from \the [src].")) // Showing the message AFTER dismantle() so it's "...from the window frame" and not "...from the window".
			return

		user.setClickCooldown(W.update_attack_cooldown())
		user.do_attack_animation(src)
		if((W.damtype == BRUTE || W.damtype == BURN) && W.force >= 3)
			visible_message(SPAN("danger", "[src] has been hit by [user] with [W]."))
			affected.take_damage(W.force * (affected.reinforced ? 0.5 : 1))
		else
			visible_message(SPAN("danger", "[user] hits [src] with [W], but it bounces off!"))
			playsound(loc, GET_SFX(SFX_GLASS_HIT), 75, 1)
		return

	if(isWirecutter(W))
		if(!shock(user, 100))
			switch(frame_state)
				if(FRAME_DESTROYED)
					visible_message(SPAN("notice", "[user] salvages \the [src]."))
					new /obj/item/stack/rods(get_turf(src))
					qdel(src)
				if(FRAME_NORMAL)
					visible_message(SPAN("notice", "[user] disassembles \the [src]."))
					new /obj/item/stack/rods(get_turf(src), 2)
					qdel(src)
				if(FRAME_REINFORCED)
					set_state(FRAME_NORMAL)
					visible_message(SPAN("notice", "[user] removes the reinforced lattice from \the [src]."))
					new /obj/item/stack/rods(get_turf(src))
				if(FRAME_GRILLE)
					set_state(FRAME_NORMAL) // Straight back to normal, skipping the reinforced state.
					visible_message(SPAN("notice", "[user] removes the grille from \the [src]."))
					new /obj/item/stack/rods(get_turf(src), 2)
			update_nearby_icons()
			playsound(loc, 'sound/items/Wirecutter.ogg', 100, 1)
		return

	if((isScrewdriver(W)) && (istype(loc, /turf/simulated) || anchored))
		if(!shock(user, 90))
			playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
			anchored = !anchored
			update_nearby_icons()
			user.visible_message(SPAN("notice", "[user] [anchored ? "fastens" : "unfastens"] \the [src]."), \
								 SPAN("notice", "You have [anchored ? "fastened \the [src] to" : "unfastened \the [src] from"] the floor."))
		return

	if(!(W.obj_flags & OBJ_FLAG_CONDUCTIBLE) || !shock(user, 70))
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		user.do_attack_animation(src)
		playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
		switch(W.damtype)
			if("fire")
				health -= W.force
			if("brute")
				health -= W.force * 0.1
		healthcheck()
		return

	return ..()


/obj/structure/window_frame/proc/healthcheck()
	if(health <= 0)
		if(frame_state == FRAME_GRILLE)
			new /obj/item/stack/rods(get_turf(src), rand(1, 3))
			set_state(FRAME_DESTROYED)
		else
			new /obj/item/stack/rods(get_turf(src), rand(1, frame_state + 1)) // Losing some rods when destroyed instead of disassembling.
			qdel(src)
	return

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise
/obj/structure/window_frame/proc/shock(mob/user, prb)
	if(frame_state != FRAME_GRILLE) // Well maybe reinforced frames should have a chance to shook whomever crawls through them but for now nah.
		return FALSE
	if(outer_pane)
		return FALSE
	if(!anchored) // unanchored grilles are never connected
		return FALSE
	if(!prob(prb))
		return FALSE
	if(!in_range(src, user)) // To prevent TK and mech users from getting shocked
		return FALSE
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(!C)
		return FALSE

	if(electrocute_mob(user, C, src))
		if(C.powernet)
			C.powernet.trigger_warning()
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		if(user.stunned)
			return TRUE

	return FALSE

/obj/structure/window_frame/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(outer_pane)
		if(exposed_temperature > outer_pane.max_heat)
			outer_pane.take_damage(1, FALSE)
	else if(inner_pane)
		if(exposed_temperature > inner_pane.max_heat)
			inner_pane.take_damage(1, FALSE)
	else if(exposed_temperature > T0C + 1500)
		health -= 1
		healthcheck()
	..()

/obj/structure/window_frame/blob_act(damage)
	if(outer_pane)
		outer_pane.take_damage(damage)
	else if(inner_pane)
		inner_pane.take_damage(damage)
	else
		health -= damage
		healthcheck()

/obj/structure/window_frame/attack_generic(mob/user, damage, attack_verb)
	visible_message(SPAN("danger", "[user] [attack_verb] \the [src]!"))
	attack_animation(user)
	if(outer_pane)
		outer_pane.take_damage(damage)
	else if(inner_pane)
		inner_pane.take_damage(damage)
	else
		health -= damage
		spawn()
			healthcheck()
		return TRUE


// Mapping presetties
/obj/structure/window_frame/reinforced
	frame_state = FRAME_REINFORCED
	name = "reinforced window frame"
	desc = "A reinforced window frame made of steel rods, capable of holding two windowpanes at once."
	icon_state = "winframe_r"
	icon_base = "winframe_r"
	icon_border = "winborder_r"
	hitby_loudness_multiplier = 1.0
	density = TRUE
	max_health = 10

// Pretty much the same as the old grille, but smarter.
/obj/structure/window_frame/grille
	frame_state = FRAME_GRILLE
	name = "grille"
	desc = "A flimsy lattice of metal rods, with screws to secure it to the floor."
	icon_state = "grille"
	icon_base = "grille"
	icon_border = "winborder"
	hitby_loudness_multiplier = 1.5
	density = TRUE
	max_health = 12

/obj/structure/window_frame/broken
	frame_state = FRAME_DESTROYED
	name = "broken grille"
	desc = "Not much left of a grille, but at least a single steel rod still can be salvaged from it."
	icon_state = "grille-b"
	icon_base = "grille-b"
	icon_border = "blank"
	hitby_loudness_multiplier = 0.5
	density = FALSE
	max_health = 6

/obj/structure/window_frame/broken/Initialize()
	. = ..()
	health = rand(1, max_health) // In the destroyed but not utterly threshold.
	healthcheck() // Send this to healthcheck just in case we want to do something else with it.

// The simpliest window to exist. To be used in totally-no-safety-required areas.
/obj/structure/window_frame/glass
	name = "window"
	density = TRUE
	icon_state = "winframe-glass"
	preset_outer_pane = /datum/windowpane/glass

// Regular window with reinforced glass. Default window for most occasions.
/obj/structure/window_frame/rglass
	name = "window"
	density = TRUE
	icon_state = "winframe-rglass"
	preset_outer_pane = /datum/windowpane/rglass

// Reinforced window with two reinforced glass panes. Mostly used for hulls.
/obj/structure/window_frame/reinforced/hull
	name = "reinforced window"
	icon_state = "winframe_r-rglass"
	preset_outer_pane = /datum/windowpane/rglass
	preset_inner_pane = /datum/windowpane/rglass

// Reinforced window with two reinforced plass panes. Totally the best choice to constrain extremely high temperatures (combustion chamber/engine/etc.)
/obj/structure/window_frame/reinforced/thermal
	name = "reinforced window"
	icon_state = "winframe_r-rplass"
	preset_outer_pane = /datum/windowpane/rplass
	preset_inner_pane = /datum/windowpane/rplass

/obj/structure/window_frame/grille/glass
	name = "windowed grille"
	icon_state = "grille-glass"
	preset_outer_pane = /datum/windowpane/glass

// Can't hold the second windowpane, but can be used to shock people.
/obj/structure/window_frame/grille/rglass
	name = "windowed grille"
	icon_state = "grille-rglass"
	preset_outer_pane = /datum/windowpane/rglass

#undef FRAME_DESTROYED
#undef FRAME_NORMAL
#undef FRAME_REINFORCED
#undef FRAME_GRILLE
