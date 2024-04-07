#define FRAME_DESTROYED 1
#define FRAME_NORMAL 2
#define FRAME_REINFORCED 3
#define FRAME_GRILLE 4
#define FRAME_ELECTRIC 5
#define FRAME_RELECTRIC 6

// Making things simple was never an option
/datum/windowpane
	var/material/glass/window_material = null
	var/obj/structure/window_frame/my_frame = null
	var/shardtype = /obj/item/material/shard

	var/name = "windowpane"
	var/icon_base = "window"
	var/damage_state = 0

	var/max_health = 20 // 40% of the material's integrity
	var/health = 20
	var/stored_silicate = 0 // Leftover silicate absorbs a bit of damage done to a windowpane.
	var/is_inner = FALSE
	var/state = 2
	var/tinted = FALSE // Electrochromic tint, not to be confused with the "opacity" variable
	var/reinforced = FALSE
	var/opacity = FALSE

	var/explosion_block = 0
	var/max_heat = 100 CELSIUS

	var/preset_material

// These guys help us to save a bit of init time.
/datum/windowpane/glass/preset_material = MATERIAL_GLASS
/datum/windowpane/rglass/preset_material = MATERIAL_REINFORCED_GLASS
/datum/windowpane/plass/preset_material = MATERIAL_PLASS
/datum/windowpane/rplass/preset_material = MATERIAL_REINFORCED_PLASS
/datum/windowpane/black/preset_material = MATERIAL_BLACK_GLASS
/datum/windowpane/rblack/preset_material = MATERIAL_REINFORCED_BLACK_GLASS

/datum/windowpane/New(obj/structure/window_frame/WF, material/M, inner = FALSE)
	..()
	my_frame = WF
	if(preset_material)
		set_material(get_material_by_name(preset_material))
	else
		set_material(M)
	is_inner = inner

/datum/windowpane/Destroy()
	if(my_frame)
		if(my_frame.outer_pane == src)
			my_frame.outer_pane = null
		else if(my_frame.inner_pane == src)
			my_frame.inner_pane = null
		my_frame.set_state()
		my_frame.update_nearby_icons()
		my_frame.update_nearby_tiles()
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
	max_health = M.integrity * 0.4
	health = max_health
	max_heat = M.melting_point
	opacity = (M.opacity < 1.0) ? FALSE : TRUE

	if(window_material.is_reinforced())
		explosion_block += 1
		reinforced = TRUE

	if(max_heat >= (2000 CELSIUS))
		explosion_block += 1

/datum/windowpane/proc/apply_silicate(volume)
	if(health < max_health)
		health = min(health + volume * 3, max_health)
		my_frame.visible_message(health == max_health ? "Silicate mended some cracks on \the [my_frame]'s [name]." :
														"\The [my_frame]'s [name] looks fully repaired.")
	else
		stored_silicate = min(stored_silicate + volume, 100)

/datum/windowpane/proc/take_damage(damage = 0, sound_effect = TRUE)
	var/initialhealth = health

	if(stored_silicate)
		damage *= (1 - stored_silicate / 200)

	health = max(0, health - damage)

	if(health <= 0)
		shatter()
		return

	if(sound_effect)
		playsound(my_frame.loc, GET_SFX(SFX_GLASS_HIT), 100, 1)

	var/prev_damage_state = damage_state
	if(health < max_health * 0.25 && initialhealth >= max_health * 0.25)
		my_frame.visible_message("\The [my_frame]'s [name] looks like it's about to shatter!")
		damage_state = 3
	else if(health < max_health * 0.5 && initialhealth >= max_health * 0.5)
		my_frame.visible_message("\The [my_frame]'s [name] looks seriously damaged!")
		damage_state = 2
	else if(health < max_health * 0.75 && initialhealth >= max_health * 0.75)
		my_frame.visible_message("Cracks begin to appear in \the [my_frame]'s [name]!")
		damage_state = 1
	if(prev_damage_state != damage_state)
		my_frame.update_icon()
	return

/datum/windowpane/proc/shatter(display_message = TRUE)
	if(QDELETED(my_frame)) // Either we lost our frame, or it somehow got destroyed before we had a chance to shatter.
		qdel(src) // Should never happen, but we can't be sure as long as bombs and singulos exist.
		return

	playsound(my_frame, GET_SFX(SFX_BREAK_WINDOW), 70, 1)
	if(display_message)
		my_frame.visible_message("[my_frame][is_inner ? "\'s inner windowpane" : ""] shatters!")

	var/shard_material = window_material.name
	switch(window_material.name)
		if(MATERIAL_REINFORCED_GLASS)
			shard_material = MATERIAL_GLASS
		if(MATERIAL_REINFORCED_PLASS)
			shard_material = MATERIAL_PLASS
		if(MATERIAL_REINFORCED_BLACK_GLASS)
			shard_material = MATERIAL_BLACK_GLASS
	new /obj/item/material/shard(get_turf(my_frame), shard_material)

	if(reinforced)
		new /obj/item/stack/rods(get_turf(my_frame))

	qdel(src)

// Sets tint to new_state if it's TRUE or FALSE, otherwise just switches it.
/datum/windowpane/proc/set_tint(new_state = -1)
	tinted = (new_state == -1) ? !tinted : new_state
	my_frame.update_icon()

/datum/windowpane/proc/get_damage_desc()
	if(health == max_health)
		return SPAN("notice", "It looks [pick("intact", "normal", "fine", "alright")].")
	switch(damage_state)
		if(1)
			return SPAN("warning", "It has a few cracks.")
		if(2)
			return SPAN("warning", "It looks seriously damaged.")
		if(3)
			return SPAN("danger", "It looks like it's about to shatter!")
	return SPAN("notice", "It looks a bit [pick("shabby", "battered", "frayed", "chipped")].")

// obj/structure/window_frame/grille may look weird but hey at least it's not obj/structure/stool/chair/bed
/obj/structure/window_frame
	name = "window frame"
	desc = "A simple window frame made of steel rods."
	icon = 'icons/obj/structures.dmi'
	icon_state = "winframe"
	var/icon_base = "winframe"
	var/icon_border = "winborder"
	density = FALSE
	anchored = TRUE
	opacity = FALSE
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	can_atmos_pass = ATMOS_PASS_PROC
	layer = WINDOW_FRAME_LAYER
	explosion_resistance = 1

	rad_resist_type = /datum/rad_resist/window

	var/max_health = 8
	var/health = 8
	var/pane_melee_mult = 1.0 // Stronger frames protect their windowpanes from some damage.
	hitby_loudness_multiplier = 0.5

	var/frame_state = FRAME_NORMAL
	var/datum/windowpane/outer_pane = null // Normal windowpane for most frames.
	var/datum/windowpane/inner_pane = null // Inner windowpane, used by reinforced frames.

	var/preset_outer_pane
	var/preset_inner_pane

	var/cable_color = COLOR_RED
	var/electrochromic = TRUE // Disallows toggling tint when false. Should always be true by default unless manually toggled.
	var/obj/item/device/assembly/signaler/signaler = null

	var/obj/structure/window_frame/recursive_tint_origin = null // Used by the recursive_tint() proc.
	var/last_recursion = 0

	var/list/mobs_can_pass = list(
		/mob/living/bot,
		/mob/living/carbon/metroid,
		/mob/living/simple_animal/mouse,
		/mob/living/silicon/robot/drone
		)

/datum/rad_resist/window
	alpha_particle_resist = 100 MEGA ELECTRONVOLT
	beta_particle_resist = 0.1 MEGA ELECTRONVOLT
	hawking_resist = 0.1 ELECTRONVOLT

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
	recursive_tint_origin = null
	QDEL_NULL(signaler)
	update_nearby_icons()
	update_nearby_tiles()
	. = ..()

/obj/structure/window_frame/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			// 25% chance for each pane to drop shards, 75% to just evaporate.
			if(outer_pane && prob(25))
				outer_pane.shatter(FALSE)
			if(inner_pane && prob(25))
				inner_pane.shatter(FALSE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if(outer_pane)
				if(inner_pane && prob(90 - (20 * outer_pane.explosion_block)))
					inner_pane.shatter(FALSE) // Outer pane can protect the inner one, depending on its explosion resistance.
				outer_pane.shatter(FALSE)
			else if(inner_pane)
				inner_pane.shatter(FALSE)
			else
				signaler?.forceMove(get_turf(src))
				qdel(src) // Poor frame gets murdered here if not protected by windowpanes.
		if(EXPLODE_LIGHT)
			if(prob(50))
				if(outer_pane)
					outer_pane.shatter(FALSE)
				else
					inner_pane?.shatter(FALSE) // Small explosions can't wreck both layers at once.

/obj/structure/window_frame/proc/set_state(new_state = null)
	if(new_state)
		frame_state = new_state
	switch(frame_state)
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
			pane_melee_mult = 0.9
		if(FRAME_NORMAL)
			name = outer_pane ? "window" : "window frame"
			desc = "A simple window frame made of steel rods."
			icon_state = "winframe"
			icon_base = "winframe"
			icon_border = "winborder"
			hitby_loudness_multiplier = 0.5
			density = outer_pane ? TRUE : FALSE
			max_health = 8
			pane_melee_mult = 1.0
		if(FRAME_GRILLE)
			name = "[outer_pane ? "windowed " : ""]grille"
			desc = "A flimsy lattice of metal rods, with screws to secure it to the floor."
			icon_state = "grille"
			icon_base = "grille"
			icon_border = "winborder"
			hitby_loudness_multiplier = 1.5
			density = TRUE
			max_health = 12
			pane_melee_mult = 0.7
		if(FRAME_DESTROYED)
			name = "broken grille"
			desc = "Not much left of a grille, but at least a single steel rod still can be salvaged from it."
			icon_state = "grille-b"
			icon_base = "grille-b"
			icon_border = "blank"
			hitby_loudness_multiplier = 0.5
			density = FALSE
			max_health = 6
		if(FRAME_ELECTRIC)
			name = outer_pane ? "electrochromic window" : "wired window frame"
			desc = "A window frame with some wiring attached to it, used to create electrochromic windows."
			icon_state = "winframe_e"
			icon_base = "winframe_e"
			icon_border = "winborder"
			hitby_loudness_multiplier = 0.5
			density = outer_pane ? TRUE : FALSE
			max_health = 8
			pane_melee_mult = 1.0
		if(FRAME_RELECTRIC)
			name = outer_pane ? "reinforced electrochromic window" : "wired reinforced window frame"
			desc = "A reinforced window frame with some wiring attached to it."
			icon_state = "winframe_re"
			icon_base = "winframe_re"
			icon_border = "winborder_r"
			hitby_loudness_multiplier = 1.0
			density = TRUE
			max_health = 10
			pane_melee_mult = 0.9

	health = max_health // Simple reset is easier than inventing things.

	// The unobvious thing below makes it impossible to interact with things which are located
	// on the same tile as an assembled window or a grille. With exceptions like firedoors.
	if(outer_pane || inner_pane)
		atom_flags |= ATOM_FLAG_FULLTILE_OBJECT
	else
		atom_flags &= ~ATOM_FLAG_FULLTILE_OBJECT

// The scariest thing present. Let's just -=HoPe=- it's not -=ThAt=- performance-heavy.
/obj/structure/window_frame/on_update_icon()
	ClearOverlays()
	underlays.Cut()
	icon_state = icon_base
	var/new_opacity = FALSE

	if(frame_state == FRAME_DESTROYED)
		return

	layer = WINDOW_FRAME_LAYER

	if(frame_state == FRAME_ELECTRIC || frame_state == FRAME_RELECTRIC)
		var/image/I = OVERLAY(icon, "[icon_base]_cable", color = cable_color)
		AddOverlays(I)

	if(signaler)
		AddOverlays(OVERLAY(icon, "winframe_signaler"))

	if(inner_pane)
		var/connections = 0
		for(var/I in GLOB.cardinal)
			var/obj/structure/window_frame/W = locate() in get_step(src, I)
			if(!istype(W))
				continue
			if(W.inner_pane?.state >= 2)
				connections += get_dir(src, W)

		var/image/I = image(GLOB.bitmask_icon_sheets["[inner_pane.icon_base]"], "[connections]")
		I.layer = WINDOW_INNER_LAYER
		AddOverlays(I)

		if(inner_pane.tinted)
			new_opacity = TRUE
			AddOverlays(OVERLAY(icon, "winframe_tint", layer = WINDOW_INNER_LAYER))

		if(inner_pane.damage_state)
			AddOverlays(OVERLAY(icon, "winframe_damage[inner_pane.damage_state]", layer = WINDOW_INNER_LAYER))

		if(inner_pane.opacity)
			new_opacity = TRUE

	if(outer_pane)
		if(outer_pane.reinforced)
			underlays += OVERLAY(icon, "winframe_shadow")

		var/connections = 0
		for(var/I in GLOB.cardinal)
			var/obj/structure/window_frame/W = locate() in get_step(src, I)
			if(!istype(W))
				continue
			if(W.outer_pane?.state >= 2)
				connections += get_dir(src, W)

		var/image/I = image(GLOB.bitmask_icon_sheets["[outer_pane.icon_base]"], "[connections]")
		I.layer = WINDOW_OUTER_LAYER
		AddOverlays(I)

		if(outer_pane.tinted)
			new_opacity = TRUE
			AddOverlays(OVERLAY(icon, "winframe_tint", layer = WINDOW_OUTER_LAYER))

		if(outer_pane.damage_state)
			AddOverlays(OVERLAY(icon, "winframe_damage[outer_pane.damage_state]", layer = WINDOW_OUTER_LAYER))

		if(outer_pane.opacity)
			new_opacity = TRUE

	if(outer_pane?.state >= 1)
		var/connections = 0
		for(var/I in GLOB.cardinal)
			var/obj/structure/window_frame/W = locate() in get_step(src, I)
			if(!istype(W))
				continue
			if(W.outer_pane?.state >= 1)
				connections += get_dir(src, W)

		var/image/I = image(GLOB.bitmask_icon_sheets["[icon_border]"], "[connections]")
		I.layer = WINDOW_BORDER_LAYER
		AddOverlays(I)

	if(opacity != new_opacity)
		set_opacity(new_opacity)

//This proc is used to update the icons of nearby window frames. It should not be confused with update_nearby_tiles(), which is an atmos proc!
/obj/structure/window_frame/proc/update_nearby_icons()
	update_icon()
	for(var/obj/structure/window_frame/W in orange(src, 1))
		W.update_icon()

/obj/structure/window_frame/examine(mob/user, infix)
	. = ..()

	if(outer_pane)
		if(frame_state == FRAME_REINFORCED)
			. += "It has an outer [outer_pane.name] installed. [outer_pane.get_damage_desc()]"
		else
			. += "It has a [outer_pane.name] installed. [outer_pane.get_damage_desc()]"

	if(inner_pane)
		. += "It has an inner [inner_pane.name] installed. [inner_pane.get_damage_desc()]"

	if(signaler)
		. += "There is a signaler attached to the wiring."

/obj/structure/window_frame/Bumped(atom/user)
	if(ismob(user))
		shock(user, 70)
	..()

/obj/structure/window_frame/CanPass(atom/movable/mover, turf/target)
	if(!(outer_pane || inner_pane) || (mover.pass_flags & PASS_FLAG_GLASS)) // Just a frame without windows OR we don't care about windows anyways.
		if(mover.pass_flags & PASS_FLAG_GRILLE)
			return TRUE // We pass the frame giving no fuck about its state.

		switch(frame_state)
			if(FRAME_GRILLE)
				if(istype(mover, /obj/item/projectile))
					return prob(30)
				if(mover.pass_flags & PASS_FLAG_GLASS)
					return prob(60)
			if(FRAME_REINFORCED, FRAME_RELECTRIC)
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

/obj/structure/window_frame/attack_hand(mob/user)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)

	var/datum/windowpane/affected = null
	if(outer_pane)
		affected = outer_pane // Let's try the outer windowpane first
	else if(inner_pane)
		affected = inner_pane // ... and try the inner one if the outer is missing

	if(affected)
		if(MUTATION_HULK in user.mutations)
			user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
			user.visible_message(SPAN("danger", "[user] smashes through \the [src]!"))
			user.do_attack_animation(src)
			affected.shatter()

		else if(MUTATION_STRONG in user.mutations)
			user.visible_message(SPAN("danger", "[user] smashes through \the [src]!"))
			user.do_attack_animation(src)
			affected.shatter()

		else if(user.a_intent == I_HURT)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				if(H.species.can_shred(H))
					attack_generic(H, 25, "shreds")
					return

			playsound(loc, GET_SFX(SFX_GLASS_HIT), 80, 1)
			user.do_attack_animation(src)
			user.visible_message(SPAN("danger", "\The [user] bangs against \the [src]!"),\
								 SPAN("danger", "You bang against \the [src]!"),\
								 SPAN("danger", "You hear a banging sound."))
		else
			playsound(loc, GET_SFX(SFX_GLASS_KNOCK), 80, 1)
			user.visible_message("<b>[user.name]</b> knocks on \the [src].",
								"You knock on \the [src].",
								"You hear a knocking sound.")
		return

	playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	user.do_attack_animation(src)

	var/damage_dealt = 2
	var/attack_message = "kicks"
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H.species.can_shred(H))
			attack_message = "mangles"
			damage_dealt = 5

	if(shock(user, 70))
		return

	if(MUTATION_HULK in user.mutations)
		damage_dealt += 5

	if(MUTATION_STRONG in user.mutations)
		damage_dealt += 5

	attack_generic(user, damage_dealt, attack_message)

/obj/structure/window_frame/attack_generic(mob/user, damage, attack_verb = "attacks")
	visible_message(SPAN("danger", "[user] [attack_verb] \the [src]!"))
	attack_animation(user)
	if(outer_pane)
		outer_pane.take_damage(damage * pane_melee_mult)
	else if(inner_pane)
		inner_pane.take_damage(damage * pane_melee_mult)
	else
		health -= damage
		spawn()
			healthcheck()
		return TRUE

/obj/structure/window_frame/attackby(obj/item/W, mob/user)
	// We'll use this for all the kinds of stuff below.
	var/datum/windowpane/affected = null
	if(outer_pane)
		affected = outer_pane
	else if(inner_pane)
		affected = inner_pane

	if(user.a_intent != I_HELP)
		if(W.item_flags & ITEM_FLAG_NO_BLUDGEON)
			return

		user.setClickCooldown(W.update_attack_cooldown())
		user.do_attack_animation(src)
		if(affected)
			if((W.damtype == BRUTE || W.damtype == BURN) && W.force >= 3)
				visible_message(SPAN("danger", "[src] has been hit by [user] with [W]."))
				affected.take_damage(W.force * (affected.reinforced ? 0.5 : 1) * pane_melee_mult)
			else
				visible_message(SPAN("danger", "[user] hits [src] with [W], but it bounces off!"))
				playsound(loc, GET_SFX(SFX_GLASS_HIT), 75, 1)
			return
		else
			if((W.obj_flags & OBJ_FLAG_CONDUCTIBLE) && shock(user, 70))
				to_chat(user, SPAN("danger", "You try to hit \the [src], but get electrocuted!"))
				return
			playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
			visible_message(SPAN("danger", "[src] has been hit by [user] with [W]."))
			switch(W.damtype)
				if("fire")
					health -= W.force
				if("brute")
					health -= W.force * 0.1
			healthcheck()
			return

	if(istype(W, /obj/item/stack/material))
		var/obj/item/stack/material/ST = W
		if(ST.material.created_window)
			if(frame_state == FRAME_DESTROYED)
				to_chat(user, SPAN("notice", "You don't feel like \the [src] can hold a windowpane by any means."))
				return
			if(outer_pane)
				to_chat(user, SPAN("notice", "You can't seem to find a way to place another windowpane in \the [src]."))
				if(frame_state == FRAME_REINFORCED && !inner_pane)
					to_chat(user, SPAN("notice", "Strangely enough, \the [src] is missing the inner windowpane. Replacing it requires uninstalling the outer pane first."))
				return
			if(!anchored)
				to_chat(user, SPAN("notice", "\The [src] must be secured to the floor first."))
				return
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
					add_fingerprint(user)
					set_state()
					update_nearby_icons()
					update_nearby_tiles()
					shove_everything(shove_items = FALSE)
			return

	if(affected)
		var/old_state = affected.state
		if(isScrewdriver(W) && affected.state >= 1)
			to_chat(user, (affected.state == 1 ? SPAN("notice", "You begin fastening \the [affected.name] to the frame.") : SPAN("notice", "You begin unfastening \the [affected.name] from the frame.")))
			if(!do_after(user, 10, src))
				return
			if(QDELETED(affected) || affected.state != old_state)
				return
			affected.state = 3 - affected.state
			update_nearby_icons()
			playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
			to_chat(user, (affected.state == 2 ? SPAN("notice", "You have fastened \the [affected.name] to the frame.") : SPAN("notice", "You have unfastened \the [affected.name] from the frame.")))
			return

		if(isCrowbar(W) && affected.state <= 1)
			to_chat(user, (affected.state == 0 ? SPAN("notice", "You begin prying \the [affected.name] into the frame.") : SPAN("notice", "You begin prying \the [affected.name] out of the frame.")))
			if(!do_after(user, 10, src))
				return
			if(QDELETED(affected) || affected.state != old_state)
				return
			affected.state = 1 - affected.state
			update_nearby_icons()
			playsound(loc, 'sound/items/Crowbar.ogg', 75, 1)
			to_chat(user, (affected.state == 1 ? SPAN("notice", "You have pried \the [affected.name] into the frame.") : SPAN("notice", "You have pried \the [affected.name] out of the frame.")))
			return

		if(isWrench(W) && affected.state == 0)
			to_chat(user, SPAN("notice", "You begin dismantling \the [affected.name] from \the [src]."))
			if(!do_after(user, 15, src))
				return
			if(QDELETED(affected) || affected.state != old_state)
				return
			playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)
			visible_message(SPAN("notice", "[user] dismantles \the [affected.name] from \the [src].")) // Showing the message before dismantle() so it's "...from the window" and not "...from the window frame".
			affected.dismantle()
			return

		return

	if(isWirecutter(W))
		if(shock(user, 100))
			to_chat(user, SPAN("danger", "You try to cut \the [src], but it electrocutes you instead!"))
			return
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
			if(FRAME_ELECTRIC, FRAME_RELECTRIC)
				set_state((frame_state == FRAME_ELECTRIC) ? FRAME_NORMAL : FRAME_REINFORCED)
				visible_message(SPAN("notice", "[user] removes the wiring from \the [src]."))
				if(signaler)
					signaler.forceMove(get_turf(src))
					signaler = null
				new /obj/item/stack/cable_coil(get_turf(src), 1, cable_color)
				outer_pane?.set_tint(FALSE)
		update_nearby_icons()
		playsound(loc, 'sound/items/Wirecutter.ogg', 100, 1)
		return

	if(istype(W, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = W
		switch(frame_state)
			if(FRAME_NORMAL)
				to_chat(user, SPAN("notice", "You begin reinforcing the frame."))
				add_fingerprint(user)
				if(!do_after(user, 10, src))
					return
				if(frame_state != FRAME_NORMAL)
					return
				if(R.use(1))
					to_chat(user, SPAN("notice", "You've reinforced the frame."))
					set_state(FRAME_REINFORCED)
					update_nearby_icons()
				return
			if(FRAME_REINFORCED)
				to_chat(user, SPAN("notice", "You begin constructing a grille."))
				add_fingerprint(user)
				if(!do_after(user, 10, src))
					return
				if(frame_state != FRAME_REINFORCED)
					return
				if(R.use(1))
					to_chat(user, SPAN("notice", "You've constructed a grille."))
					set_state(FRAME_GRILLE)
					update_nearby_icons()
					shove_everything(shove_items = FALSE)
				return

	if(isCoil(W))
		var/obj/item/stack/cable_coil/CC = W
		if(frame_state == FRAME_NORMAL || frame_state == FRAME_REINFORCED)
			var/old_state = frame_state
			to_chat(user, SPAN("notice", "You begin wiring \the [src]."))
			add_fingerprint(user)
			if(!do_after(user, 20, src))
				return
			if(frame_state != old_state)
				return
			var/CC_color = CC.color
			if(CC.use(1))
				to_chat(user, SPAN("notice", "You've mounted some wiring onto the frame."))
				cable_color = CC_color
				set_state((frame_state == FRAME_NORMAL) ? FRAME_ELECTRIC : FRAME_RELECTRIC)
				electrochromic = TRUE
				update_nearby_icons()
			return

	if(isMultitool(W))
		if(frame_state == FRAME_ELECTRIC || frame_state == FRAME_RELECTRIC)
			electrochromic = !electrochromic
			to_chat(user, SPAN("notice", "\The [src] will[electrochromic ? " " : " no longer "]toggle its tint when signalled now."))
			return

	if(istype(W, /obj/item/device/assembly/signaler))
		if(signaler)
			to_chat(user, SPAN("notice", "\The [src] already has another [signaler] attached."))
			return
		to_chat(user, SPAN("notice", "You've attached \the [W] to \the [src]."))
		user.drop(W, src)
		signaler = W
		update_icon()
		return

	if((isScrewdriver(W)) && (istype(loc, /turf/simulated) || anchored))
		if(shock(user, 90))
			to_chat(user, SPAN("danger", "You try to [anchored ? "unfasten" : "fasten"] \the [src] and get electrocuted!"))
			return
		if(!anchored)
			for(var/obj/structure/window_frame/WF in loc)
				if(WF == src)
					continue
				to_chat(user, SPAN("warning", "There are too many frames in this location."))
				return

		playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
		anchored = !anchored
		update_nearby_icons()
		user.visible_message(SPAN("notice", "[user] [anchored ? "fastens" : "unfastens"] \the [src]."), \
							 SPAN("notice", "You have [anchored ? "fastened \the [src] to" : "unfastened \the [src] from"] the floor."))
		if(anchored)
			shove_everything(shove_items = FALSE)
		return

	if((W.obj_flags & OBJ_FLAG_CONDUCTIBLE) && shock(user, 70))
		to_chat(user, SPAN("danger", "You touch \the [src] with \the [W] and get electrocuted!"))
		return

/obj/structure/window_frame/proc/healthcheck()
	if(health <= 0)
		switch(frame_state)
			if(FRAME_GRILLE)
				new /obj/item/stack/rods(get_turf(src), rand(1, 3))
				set_state(FRAME_DESTROYED)
				update_nearby_icons()
			if(FRAME_ELECTRIC, FRAME_RELECTRIC)
				new /obj/item/stack/rods(get_turf(src), rand(1, frame_state + 1))
				if(signaler)
					signaler.forceMove(get_turf(src))
					signaler = null
				new /obj/item/stack/cable_coil/single(get_turf(src))
				qdel(src)
			else
				new /obj/item/stack/rods(get_turf(src), rand(1, frame_state + 1)) // Losing some rods when destroyed instead of disassembling.
				qdel(src)
	return

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise
/obj/structure/window_frame/proc/shock(mob/user, prb)
	if(frame_state != FRAME_GRILLE && frame_state != FRAME_ELECTRIC && frame_state != FRAME_RELECTRIC) // Well maybe reinforced frames should have a chance to shook whomever crawls through them but for now nah.
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
		if(user.stunned || user.weakened)
			return TRUE

	return FALSE

/obj/structure/window_frame/hitby(atom/movable/AM, speed, nomsg)
	..(AM, speed, TRUE)
	var/tforce = 0
	if(ismob(AM)) // All mobs have a multiplier and a size according to mob_defines.dm
		var/mob/I = AM
		tforce = I.mob_size * I.throw_multiplier
	else if(isobj(AM))
		var/obj/item/I = AM
		tforce = I.throwforce

	if(tforce < 3 && prob(95)) // A tiny chance to get out of a locked-down room by throwing your boxers at windows before the round ends.
		visible_message(SPAN("warning", "[AM] bounces off \the [src]."))
		return
	visible_message(SPAN("warning", "[src] was hit by \the [AM]."))

	if(outer_pane)
		outer_pane.take_damage(tforce * (outer_pane.reinforced ? 0.5 : 1) * pane_melee_mult)
	else if(inner_pane)
		inner_pane.take_damage(tforce * (inner_pane.reinforced ? 0.5 : 1) * pane_melee_mult)
	else
		health -= tforce * 0.1
		healthcheck()

/obj/structure/window_frame/play_hitby_sound(atom/movable/AM)
	hitby_sound = 'sound/effects/grillehit.ogg'
	if(outer_pane || inner_pane)
		hitby_sound = SFX_GLASS_HIT
	..()

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

/obj/structure/window_frame/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(outer_pane)
		if(exposed_temperature > outer_pane.max_heat)
			outer_pane.take_damage(1, FALSE)
	else if(inner_pane)
		if(exposed_temperature > inner_pane.max_heat)
			inner_pane.take_damage(1, FALSE)
	else if(exposed_temperature > (1500 CELSIUS))
		health -= 1
		healthcheck()
	..()

/obj/structure/window_frame/blob_act(damage)
	if(outer_pane)
		outer_pane.take_damage(damage * pane_melee_mult)
	else if(inner_pane)
		inner_pane.take_damage(damage * pane_melee_mult)
	else
		health -= damage
		healthcheck()

/obj/structure/window_frame/proc/toggle_tint()
	if(frame_state != FRAME_ELECTRIC && frame_state != FRAME_RELECTRIC)
		return
	if(electrochromic && outer_pane)
		outer_pane.set_tint(!outer_pane.tinted)

/obj/structure/window_frame/proc/signaler_pulse()
	if(frame_state == FRAME_RELECTRIC)
		spawn()
			recursive_tint(src)

// Recursively toggles nearby window frames' tint.
// Infinite loop protection is kinda shaky, if the server lags too
// much, we should just pray for the infinite recursion catcher
/obj/structure/window_frame/proc/recursive_tint(obj/structure/window_frame/origin)
	if(world.time - last_recursion < 5) // First we check for the cooldown.
		return
	last_recursion = world.time
	if(origin)
		recursive_tint_origin = origin // And then we'll be checking for the frame that started the recursion. For extra safety. Because byond.
	else
		recursive_tint_origin = src
	toggle_tint()
	for(var/obj/structure/window_frame/W in orange(src, 1))
		if((W.frame_state == FRAME_ELECTRIC || W.frame_state == FRAME_RELECTRIC) && W.recursive_tint_origin != origin)
			W.recursive_tint(recursive_tint_origin)
	spawn(5)
		recursive_tint_origin = null

// Who even needs this casual button when we can use chad signalers?
/obj/machinery/button/window_frame_tint
	name = "window tint control"
	icon = 'icons/obj/power.dmi'
	icon_state = "light0"
	desc = "A remote control switch for electrochromic windows."
	var/range = 7

/obj/machinery/button/window_frame_tint/attack_hand(mob/user)
	if(..())
		return TRUE
	user.setClickCooldown(5)
	toggle_tint()

/obj/machinery/button/window_frame_tint/proc/toggle_tint()
	use_power_oneoff(5)
	var/area/my_area = get_area(src)
	for(var/obj/structure/window_frame/WF in range(src, range))
		if(get_area(WF) == my_area)
			spawn()
				WF.toggle_tint()

/obj/machinery/button/window_frame_tint/on_update_icon()
	icon_state = "light0"


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
	pane_melee_mult = 0.9

	rad_resist_type = /datum/rad_resist/none

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
	pane_melee_mult = 0.7

	rad_resist_type = /datum/rad_resist/window_frame_grille

/datum/rad_resist/window_frame_grille
	alpha_particle_resist = 100 MEGA ELECTRONVOLT
	beta_particle_resist = 0 MEGA ELECTRONVOLT
	hawking_resist = 0 ELECTRONVOLT

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

	rad_resist_type = /datum/rad_resist/none

/obj/structure/window_frame/broken/Initialize()
	. = ..()
	health = rand(1, max_health) // In the destroyed but not utterly threshold.
	healthcheck() // Send this to healthcheck just in case we want to do something else with it.

/obj/structure/window_frame/electric
	frame_state = FRAME_ELECTRIC
	name = "wired window frame"
	desc = "A window frame with some wiring attached to it, used to create electrochromic windows."
	icon_state = "winframe_e"
	icon_base = "winframe_e"
	icon_border = "winborder"
	density = FALSE

	rad_resist_type = /datum/rad_resist/none

/obj/structure/window_frame/relectric
	frame_state = FRAME_RELECTRIC
	name = "wired reinforced window frame"
	desc = "A reinforced window frame with some wiring attached to it."
	icon_state = "winframe_re"
	icon_base = "winframe_re"
	icon_border = "winborder_r"
	hitby_loudness_multiplier = 1.0
	density = TRUE
	max_health = 10
	pane_melee_mult = 0.9

	rad_resist_type = /datum/rad_resist/none

// The simpliest window to exist. To be used in totally-no-safety-required areas.
/obj/structure/window_frame/glass
	name = "window"
	icon_state = "winframe-glass"
	density = TRUE
	atom_flags = ATOM_FLAG_FULLTILE_OBJECT
	preset_outer_pane = /datum/windowpane/glass

	rad_resist_type = /datum/rad_resist/window_frame_glass

/datum/rad_resist/window_frame_glass
	alpha_particle_resist = 100 MEGA ELECTRONVOLT
	beta_particle_resist = 0.2 MEGA ELECTRONVOLT
	hawking_resist = 0 ELECTRONVOLT

// Regular window with reinforced glass. Default window for most occasions.
/obj/structure/window_frame/rglass
	name = "window"
	icon_state = "winframe-rglass"
	density = TRUE
	atom_flags = ATOM_FLAG_FULLTILE_OBJECT
	preset_outer_pane = /datum/windowpane/rglass

	rad_resist_type = /datum/rad_resist/window_frame_rglass

/datum/rad_resist/window_frame_rglass
	alpha_particle_resist = 120 MEGA ELECTRONVOLT
	beta_particle_resist = 0.4 MEGA ELECTRONVOLT
	hawking_resist = 0.2 ELECTRONVOLT

/obj/structure/window_frame/black
	name = "window"
	icon_state = "winframe-black"
	opacity = TRUE
	density = TRUE
	atom_flags = ATOM_FLAG_FULLTILE_OBJECT
	preset_outer_pane = /datum/windowpane/black

	rad_resist_type = /datum/rad_resist/window_frame_black

/datum/rad_resist/window_frame_black
	alpha_particle_resist = 100 MEGA ELECTRONVOLT
	beta_particle_resist = 0.2 MEGA ELECTRONVOLT
	hawking_resist = 0.2 ELECTRONVOLT

/obj/structure/window_frame/rblack
	name = "window"
	icon_state = "winframe-rblack"
	opacity = TRUE
	density = TRUE
	atom_flags = ATOM_FLAG_FULLTILE_OBJECT
	preset_outer_pane = /datum/windowpane/rblack

	rad_resist_type = /datum/rad_resist/window_frame_rblack

/datum/rad_resist/window_frame_rblack
	alpha_particle_resist = 100 MEGA ELECTRONVOLT
	beta_particle_resist = 0.4 MEGA ELECTRONVOLT
	hawking_resist = 0.2 ELECTRONVOLT

// Reinforced window with two reinforced glass panes. Mostly used for hulls.
/obj/structure/window_frame/reinforced/hull
	name = "reinforced window"
	icon_state = "winframe_r-rglass"
	atom_flags = ATOM_FLAG_FULLTILE_OBJECT
	preset_outer_pane = /datum/windowpane/rglass
	preset_inner_pane = /datum/windowpane/rglass

	rad_resist_type = /datum/rad_resist/window_frame_rhull

/datum/rad_resist/window_frame_rhull
	alpha_particle_resist = 200 MEGA ELECTRONVOLT
	beta_particle_resist = 0.8 MEGA ELECTRONVOLT
	hawking_resist = 0.4 ELECTRONVOLT

// Reinforced window with two reinforced plass panes. Totally the best choice to constrain extremely high temperatures (combustion chamber/engine/etc.)
/obj/structure/window_frame/reinforced/thermal
	name = "reinforced window"
	icon_state = "winframe_r-rplass"
	atom_flags = ATOM_FLAG_FULLTILE_OBJECT
	preset_outer_pane = /datum/windowpane/rplass
	preset_inner_pane = /datum/windowpane/rplass

	rad_resist_type = /datum/rad_resist/window_frame_rthermal

/datum/rad_resist/window_frame_rthermal
	alpha_particle_resist = 250 MEGA ELECTRONVOLT
	beta_particle_resist = 1 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/structure/window_frame/reinforced/unfinished
	name = "unfinished reinforced window"
	icon_state = "winframe_ru-rglass"
	atom_flags = ATOM_FLAG_FULLTILE_OBJECT
	preset_outer_pane = null
	preset_inner_pane = /datum/windowpane/rglass

/obj/structure/window_frame/grille/glass
	name = "windowed grille"
	icon_state = "grille-glass"
	atom_flags = ATOM_FLAG_FULLTILE_OBJECT
	preset_outer_pane = /datum/windowpane/glass

	rad_resist_type = /datum/rad_resist/window_frame_gglass

/datum/rad_resist/window_frame_gglass
	alpha_particle_resist = 100 MEGA ELECTRONVOLT
	beta_particle_resist = 0.2 MEGA ELECTRONVOLT
	hawking_resist = 0.1 ELECTRONVOLT

// Can't hold the second windowpane, but can be used to shock people.
/obj/structure/window_frame/grille/rglass
	name = "windowed grille"
	icon_state = "grille-rglass"
	atom_flags = ATOM_FLAG_FULLTILE_OBJECT
	preset_outer_pane = /datum/windowpane/rglass

	rad_resist_type = /datum/rad_resist/window_frame_grglass

/datum/rad_resist/window_frame_grglass
	alpha_particle_resist = 120 MEGA ELECTRONVOLT
	beta_particle_resist = 0.4 MEGA ELECTRONVOLT
	hawking_resist = 0.2 ELECTRONVOLT

/obj/structure/window_frame/electric/glass
	name = "electrochromic window"
	icon_state = "winframe_e-glass"
	density = TRUE
	atom_flags = ATOM_FLAG_FULLTILE_OBJECT
	preset_outer_pane = /datum/windowpane/glass

	rad_resist_type = /datum/rad_resist/window_frame_gglass

/obj/structure/window_frame/electric/rglass
	name = "electrochromic window"
	icon_state = "winframe_e-rglass"
	density = TRUE
	atom_flags = ATOM_FLAG_FULLTILE_OBJECT
	preset_outer_pane = /datum/windowpane/rglass

	rad_resist_type = /datum/rad_resist/window_frame_grglass

/obj/structure/window_frame/relectric/glass
	name = "reinforced electrochromic window"
	icon_state = "winframe_re-glass"
	atom_flags = ATOM_FLAG_FULLTILE_OBJECT
	preset_outer_pane = /datum/windowpane/glass

	rad_resist_type = /datum/rad_resist/window_frame_gglass

/obj/structure/window_frame/relectric/rglass
	name = "reinforced electrochromic window"
	icon_state = "winframe_re-rglass"
	atom_flags = ATOM_FLAG_FULLTILE_OBJECT
	preset_outer_pane = /datum/windowpane/rglass

	rad_resist_type = /datum/rad_resist/window_frame_grglass

/obj/structure/window_frame/indestructible
	name = "window"
	icon_state = "winframe-rglass"
	density = TRUE
	atom_flags = ATOM_FLAG_FULLTILE_OBJECT
	preset_outer_pane = /datum/windowpane/rglass

/obj/structure/window_frame/indestructible/hull
	name = "reinforced window"
	desc = "A reinforced window frame made of steel rods, capable of holding two windowpanes at once."
	frame_state = FRAME_REINFORCED
	icon_state = "winframe_r-rglass"
	icon_base = "winframe_r"
	icon_border = "winborder_r"
	preset_inner_pane = /datum/windowpane/rglass

/obj/structure/window_frame/indestructible/grille
	name = "windowed grille"
	desc = "A flimsy lattice of metal rods, with screws to secure it to the floor."
	frame_state = FRAME_GRILLE
	icon_state = "grille-rglass"
	icon_base = "grille"
	icon_border = "winborder"

/obj/structure/window_frame/indestructible/attack_hand()
	return

/obj/structure/window_frame/indestructible/attack_generic()
	return

/obj/structure/window_frame/indestructible/attackby()
	return

/obj/structure/window_frame/indestructible/ex_act()
	return

/obj/structure/window_frame/indestructible/hitby()
	return


#undef FRAME_DESTROYED
#undef FRAME_NORMAL
#undef FRAME_REINFORCED
#undef FRAME_GRILLE
#undef FRAME_ELECTRIC
#undef FRAME_RELECTRIC
