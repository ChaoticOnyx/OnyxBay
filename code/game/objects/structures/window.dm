/obj/structure/window
	name = "panel"
	desc = "A glassy panel."
	icon = 'icons/obj/structures.dmi'
	density = 1
	can_atmos_pass = ATMOS_PASS_PROC
	w_class = ITEM_SIZE_NORMAL

	layer = SIDE_WINDOW_LAYER
	anchored = 1.0
	atom_flags = ATOM_FLAG_CHECKS_BORDER
	obj_flags = OBJ_FLAG_ANCHOR_BLOCKS_ROTATION
	var/maxhealth = 14.0
	var/maximal_heat = 100 CELSIUS 		// Maximal heat before this window begins taking damage from fire
	var/damage_per_fire_tick = 2.0 		// Amount of damage per fire tick. Regular windows are not fireproof so they might as well break quickly.
	var/health
	var/ini_dir = null
	var/state = 2
	var/reinf = 0
	var/polarized = 0
	var/basestate
	var/shardtype = /obj/item/material/shard
	var/glasstype = null // Set this in subtypes. Null is assumed strange or otherwise impossible to dismantle, such as for shuttle glass.
	var/silicate = 0 // number of units of silicate
	var/real_explosion_block // ignore this, just use explosion_block
	var/is_full_window = FALSE //TODO: Make full windows a separate type of window.

	hitby_sound = SFX_GLASS_HIT
	hitby_loudness_multiplier = 2.0
	pull_sound = SFX_PULL_STONE

/obj/structure/window/examine(mob/user, infix)
	. = ..()

	if(health == maxhealth)
		. += SPAN_NOTICE("It looks fully intact.")
	else
		var/perc = health / maxhealth
		if(perc > 0.75)
			. += SPAN_NOTICE("It has a few cracks.")
		else if(perc > 0.5)
			. += SPAN_NOTICE("It looks slightly damaged.")
		else if(perc > 0.25)
			. += SPAN_NOTICE("It looks moderately damaged.")
		else
			. += SPAN_DANGER("It looks heavily damaged.")

	if(silicate)
		if (silicate < 30)
			. += SPAN_NOTICE("It has a thin layer of silicate.")
		else if (silicate < 70)
			. += SPAN_NOTICE("It is covered in silicate.")
		else
			. += SPAN_NOTICE("There is a thick layer of silicate covering it.")

	rad_resist_type = /datum/rad_resist/window

/datum/rad_resist/window
	alpha_particle_resist = 664 MEGA ELECTRONVOLT
	beta_particle_resist = 4.8 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/structure/window/GetExplosionBlock()
	return reinf && (state == 5) ? real_explosion_block : 0

/obj/structure/window/proc/take_damage(damage = 0,  sound_effect = 1)
	var/initialhealth = health

	if(silicate)
		damage = damage * (1 - silicate / 200)

	health = max(0, health - damage)

	if(health <= 0)
		shatter()
	else
		if(sound_effect)
			playsound(loc, GET_SFX(SFX_GLASS_HIT), 100, 1)
		if(health < maxhealth / 4 && initialhealth >= maxhealth / 4)
			visible_message("[src] looks like it's about to shatter!" )
		else if(health < maxhealth / 2 && initialhealth >= maxhealth / 2)
			visible_message("[src] looks seriously damaged!" )
		else if(health < maxhealth * 3/4 && initialhealth >= maxhealth * 3/4)
			visible_message("Cracks begin to appear in [src]!" )
	return

/obj/structure/window/proc/apply_silicate(amount)
	if(health < maxhealth) // Mend the damage
		health = min(health + amount * 3, maxhealth)
		if(health == maxhealth)
			visible_message("[src] looks fully repaired." )
	else // Reinforce
		silicate = min(silicate + amount, 100)
		updateSilicate()

/obj/structure/window/proc/updateSilicate()
	if (overlays)
		ClearOverlays()

	var/image/img = image(src.icon, src.icon_state)
	img.color = "#ffffff"
	img.alpha = silicate * 255 / 100
	AddOverlays(img)

/obj/structure/window/proc/shatter(display_message = 1)
	playsound(src, SFX_BREAK_WINDOW, 70, 1)
	if(display_message)
		visible_message("[src] shatters!")

	if(!(atom_flags & ATOM_FLAG_HOLOGRAM))
		cast_new(shardtype, is_full_window ? 4 : 1, loc)
		if(reinf)
			cast_new(/obj/item/stack/rods, is_full_window ? 4 : 1, loc)

	qdel(src)
	return

/obj/structure/window/blob_act(damage)
	take_damage(damage)

/obj/structure/window/bullet_act(obj/item/projectile/Proj)

	var/proj_damage = Proj.get_structure_damage()
	if(!proj_damage) return

	..()
	take_damage(proj_damage)
	return


/obj/structure/window/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			shatter(0)
			return
		if(3.0)
			if(prob(50))
				shatter(0)
				return

/obj/structure/window/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.pass_flags & PASS_FLAG_GLASS)
		return TRUE
	if(is_full_window)
		return FALSE	//full tile window, you can't move into it!
	if(get_dir(loc, target) & dir)
		return !density
	return TRUE

/obj/structure/window/CanZASPass(turf/T, is_zone)
	if(is_full_window || get_dir(T, loc) == turn(dir, 180)) // Make sure we're handling the border correctly.
		return !anchored // If it's anchored, it'll block air.
	return TRUE // Don't stop airflow from the other sides.

// Basically CanPass(), but also checks for diagonal movement
// Currently only used by facehuggers
// TODO: Expand somehow so it can be used by other projectiles as well
//       It cannot be used in its current state because it will cause weird
//       corner-shooting sutiations (it probably should check for connected windows)
/obj/structure/window/proc/CanDiagonalPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.pass_flags & PASS_FLAG_GLASS)
		return TRUE
	if(is_full_window)
		return FALSE
	var/mover_dir = get_dir(loc, target)
	if((mover_dir & dir) || (mover_dir & turn(dir, -45)) || (mover_dir & turn(dir, 45)))
		return !density
	return TRUE

/obj/structure/window/CheckExit(atom/movable/O, turf/target)
	if(istype(O) && O.pass_flags & PASS_FLAG_GLASS)
		return 1
	if(get_dir(O.loc, target) == dir)
		return 0
	return 1

/obj/structure/window/proc/CheckDiagonalExit(atom/movable/mover, turf/target)
	if(istype(mover) && mover.pass_flags & PASS_FLAG_GLASS)
		return 1
	var/mover_dir = get_dir(mover.loc, target)
	if((mover_dir & dir) || (turn(mover_dir, -45) & dir) || (turn(mover_dir, 45) & dir))
		return 0
	return 1


/obj/structure/window/hitby(atom/movable/AM, speed, nomsg)
	..()
	var/tforce = 0
	if(ismob(AM)) // All mobs have a multiplier and a size according to mob_defines.dm
		var/mob/I = AM
		tforce = I.mob_size * 2 * I.throw_multiplier
	else if(isobj(AM))
		var/obj/item/I = AM
		tforce = I.throwforce
	if(reinf) tforce *= 0.25
	if(health - tforce <= 7 && !reinf)
		set_anchored(FALSE)
		step(src, get_dir(AM, src))
	take_damage(tforce, FALSE)

/obj/structure/window/attack_tk(mob/user as mob)
	user.visible_message("<span class='notice'>Something knocks on [src].</span>")
	playsound(loc, GET_SFX(SFX_GLASS_KNOCK), 50, 1)

/obj/structure/window/attack_hand(mob/user as mob)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	if(MUTATION_HULK in user.mutations)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
		user.visible_message("<span class='danger'>[user] smashes through [src]!</span>")
		user.do_attack_animation(src)
		shatter()

	else if(MUTATION_STRONG in user.mutations)
		user.visible_message(SPAN("danger", "[user] smashes through [src]!"))
		user.do_attack_animation(src)
		shatter()

	else if (user.a_intent && user.a_intent == I_HURT)

		if (istype(user,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			if(H.species.can_shred(H))
				attack_generic(H,25)
				return

		playsound(src.loc, GET_SFX(SFX_GLASS_HIT), 80, 1)
		user.do_attack_animation(src)
		user.visible_message("<span class='danger'>\The [user] bangs against \the [src]!</span>",
							"<span class='danger'>You bang against \the [src]!</span>",
							"You hear a banging sound.")
	else
		playsound(src.loc, GET_SFX(SFX_GLASS_KNOCK), 80, 1)
		user.visible_message("[user.name] knocks on \the [src.name].",
							"You knock on \the [src.name].",
							"You hear a knocking sound.")
	return

/obj/structure/window/attack_generic(mob/user, damage)
	if(istype(user))
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		user.do_attack_animation(src)
	if(!damage)
		return
	if(damage >= 10)
		visible_message("<span class='danger'>[user] smashes into [src]!</span>")
		take_damage(damage)
	else
		visible_message("<span class='notice'>\The [user] bonks \the [src] harmlessly.</span>")
	return 1

/obj/structure/window/attackby(obj/item/W as obj, mob/user as mob)
	if(!istype(W)) return//I really wish I did not need this

	if(W.item_flags & ITEM_FLAG_NO_BLUDGEON) return

	if(isScrewdriver(W))
		if(reinf && state >= 1)
			state = 3 - state
			update_nearby_icons()
			playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
			to_chat(user, (state == 1 ? "<span class='notice'>You have unfastened the window from the frame.</span>" : "<span class='notice'>You have fastened the window to the frame.</span>"))
		else if(reinf && state == 0)
			set_anchored(!anchored)
			playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
			to_chat(user, (anchored ? "<span class='notice'>You have fastened the frame to the floor.</span>" : "<span class='notice'>You have unfastened the frame from the floor.</span>"))
		else if(!reinf)
			set_anchored(!anchored)
			playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
			to_chat(user, (anchored ? "<span class='notice'>You have fastened the window to the floor.</span>" : "<span class='notice'>You have unfastened the window.</span>"))
	else if(isCrowbar(W) && reinf && state <= 1)
		state = 1 - state
		playsound(loc, 'sound/items/Crowbar.ogg', 75, 1)
		to_chat(user, (state ? "<span class='notice'>You have pried the window into the frame.</span>" : "<span class='notice'>You have pried the window out of the frame.</span>"))
	else if(isWrench(W) && !anchored && (!state || !reinf))
		if(!glasstype)
			to_chat(user, "<span class='notice'>You're not sure how to dismantle \the [src] properly.</span>")
		else
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
			visible_message("<span class='notice'>[user] dismantles \the [src].</span>")
			if(dir == SOUTHWEST)
				var/obj/item/stack/material/mats = new glasstype(loc)
				mats.amount = is_full_window ? 4 : 2
			else
				new glasstype(loc)
			qdel(src)
	else if(isCoil(W) && reinf && !polarized)
		var/obj/item/stack/cable_coil/C = W
		if (C.use(1))
			playsound(src.loc, GET_SFX(SFX_SPARK), 75, 1)
			var/obj/structure/window/reinforced/polarized/P = new(loc)
			P.set_dir(dir)
			P.health = health
			P.state = state
			qdel(src)
	else
		user.setClickCooldown(W.update_attack_cooldown())
		user.do_attack_animation(src)
		if((W.damtype == BRUTE || W.damtype == BURN) && W.force >= 3)
			visible_message(SPAN("danger", "[src] has been hit by [user] with [W]."))
			hit(W.force)
			if(health <= 7)
				set_anchored(FALSE)
				step(src, get_dir(user, src))
		else
			visible_message(SPAN("danger", "[user] hits [src] with [W], but it bounces off!"))
			playsound(loc, GET_SFX(SFX_GLASS_HIT), 75, 1)
	return

/obj/structure/window/proc/hit(damage, sound_effect = 1)
	if(reinf) damage *= 0.5
	take_damage(damage, sound_effect)
	return


/obj/structure/window/rotate(mob/user)
	if(is_full_window) // No point in rotating a window if it is full
		return

	..()
	update_nearby_tiles(need_rebuild=1) //Compel updates before
	updateSilicate()
	update_nearby_tiles(need_rebuild=1)

/obj/structure/window/rotate_counter(mob/user)
	if(is_full_window) // No point in rotating a window if it is full
		return

	..()
	update_nearby_tiles(need_rebuild=1) //Compel updates before
	updateSilicate()
	update_nearby_tiles(need_rebuild=1)

/obj/structure/window/New(Loc, start_dir=null, constructed=0)
	..()

	//player-constructed windows
	if (constructed)
		set_anchored(FALSE)

	if (start_dir)
		set_dir(start_dir)

	if(is_full_window)
		maxhealth *= 4

	health = maxhealth

	ini_dir = dir

	update_nearby_tiles(need_rebuild=1)
	update_nearby_icons()


/obj/structure/window/Destroy()
	set_density(0)
	update_nearby_tiles()
	var/turf/location = loc
	. = ..()
	for(var/obj/structure/window/W in orange(location, 1))
		W.update_icon()


/obj/structure/window/Move(newloc, direct)
	var/ini_dir = dir
	update_nearby_tiles(need_rebuild=1)
	. = ..()
	set_dir(ini_dir)
	update_nearby_tiles(need_rebuild=1)

/obj/structure/window/proc/set_anchored(new_anchored)
	if(anchored == new_anchored)
		return
	anchored = new_anchored
	update_nearby_icons()

//This proc is used to update the icons of nearby windows. It should not be confused with update_nearby_tiles(), which is an atmos proc!
/obj/structure/window/proc/update_nearby_icons()
	update_icon()
	for(var/obj/structure/window/W in orange(src, 1))
		W.update_icon()

//merges adjacent full-tile windows into one (blatant ripoff from game/smoothwall.dm)
/obj/structure/window/on_update_icon()
	//A little cludge here, since I don't know how it will work with slim windows. Most likely VERY wrong.
	//this way it will only update full-tile ones
	ClearOverlays()
	layer = FULL_WINDOW_LAYER
	if(!is_full_window)
		layer = SIDE_WINDOW_LAYER
		icon_state = "[basestate]"
		return
	var/list/dirs = list()
	if(anchored)
		for(var/obj/structure/window/W in orange(src,1))
			if(W.anchored && W.density && W.glasstype == src.glasstype && W.is_full_window) //Only counts anchored, not-destroyed fill-tile windows.
				dirs += get_dir(src, W)

	var/list/connections = dirs_to_corner_states(dirs)

	icon_state = ""
	for(var/i = 1 to 4)
		var/image/I = image(icon, "[basestate][connections[i]]", dir = 1<<(i-1))
		AddOverlays(I)

	return

/obj/structure/window/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > maximal_heat)
		hit(damage_per_fire_tick, 0)
	..()

/obj/structure/window/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		return list("delay" = 2 SECONDS, "cost" = 5)

	return FALSE

/obj/structure/window/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	if(rcd_data["[RCD_DESIGN_MODE]"] == RCD_DECONSTRUCT)
		qdel_self()
		return TRUE

	return FALSE

/obj/structure/window/basic
	name = "glass panel"
	desc = "It looks thin and flimsy. A few knocks with... anything, really should shatter it."
	icon_state = "window"
	basestate = "window"
	glasstype = /obj/item/stack/material/glass
	maximal_heat = 100 CELSIUS
	damage_per_fire_tick = 2.0
	maxhealth = 12.0

/obj/structure/window/plasmabasic
	name = "plass panel"
	desc = "A plasmasilicate alloy panel. It seems to be quite strong."
	basestate = "plasmawindow"
	explosion_block = 1
	icon_state = "plasmawindow"
	shardtype = /obj/item/material/shard/plasma
	glasstype = /obj/item/stack/material/glass/plass
	maximal_heat = 2000 CELSIUS
	damage_per_fire_tick = 1.0
	maxhealth = 40.0

/obj/structure/window/plasmareinforced
	name = "reinforced plass panel"
	desc = "A plasmasilicate alloy panel, with rods supporting it. It seems to be very strong."
	basestate = "plasmarwindow"
	icon_state = "plasmarwindow"
	shardtype = /obj/item/material/shard/plasma
	glasstype = /obj/item/stack/material/glass/rplass
	reinf = 1
	explosion_block = 2
	maximal_heat = 4000 CELSIUS
	damage_per_fire_tick = 1.0 // This should last for 80 fire ticks if the window is not damaged at all. The idea is that plass windows have something like ablative layer that protects them for a while.
	maxhealth = 80.0

/obj/structure/window/plasmareinforced/full
	dir = 5
	icon_state = "plasmawindow0"
	is_full_window = TRUE

/obj/structure/window/reinforced
	name = "reinforced glass panel"
	desc = "It looks rather strong. Might take a few good hits to shatter it."
	icon_state = "rwindow"
	basestate = "rwindow"
	maxhealth = 40.0
	reinf = 1
	maximal_heat = 750 CELSIUS
	explosion_block = 1
	damage_per_fire_tick = 2.0
	glasstype = /obj/item/stack/material/glass/reinforced


/obj/structure/window/New(Loc, constructed=0)
	..()

	//player-constructed windows
	if (constructed)
		state = 0

/obj/structure/window/Initialize()
	. = ..()
	layer = is_full_window ? FULL_WINDOW_LAYER : SIDE_WINDOW_LAYER
	// windows only block while reinforced and fulltile, so we'll use the proc
	real_explosion_block = explosion_block
	explosion_block = EXPLOSION_BLOCK_PROC

	AddElement(/datum/element/simple_rotation)

/obj/structure/window/reinforced/full
	dir = 5
	icon_state = "fwindow"
	is_full_window = TRUE

/obj/structure/window/reinforced/tinted
	name = "tinted window"
	desc = "It looks rather strong and opaque. Might take a few good hits to shatter it."
	icon_state = "twindow"
	basestate = "twindow"
	opacity = TRUE

/obj/structure/window/reinforced/tinted/full
	icon_state = "rblackwindow_preview"
	basestate = "rblackwindow"
	is_full_window = TRUE

/obj/structure/window/reinforced/tinted/frosted
	name = "frosted window"
	desc = "It looks rather strong and frosted over. Looks like it might take a few less hits then a normal reinforced window."
	icon_state = "fwindow"
	basestate = "fwindow"
	maxhealth = 30

/obj/structure/window/reinforced/trading
	name = "trading window"
	desc = "Perfect for those who are willing to leave their belongings behind. Not for long, though."
	icon_state = "pwindow"
	basestate = "pwindow"
	maxhealth = 30

/obj/structure/window/reinforced/trading/light
	icon_state = "pwindow_light"
	basestate = "pwindow_light"

/obj/structure/window/shuttle
	name = "shuttle window"
	desc = "It looks rather strong. Might take a few good hits to shatter it."
	icon = 'icons/obj/podwindows.dmi'
	icon_state = "window"
	basestate = "window"
	explosion_block = 3
	maxhealth = 40
	reinf = 1
	is_full_window = TRUE

/obj/structure/window/shuttle/on_update_icon()
	return

/obj/structure/window/miningpod
	name = "shuttle window"
	desc = "It looks rather strong. Might take a few good hits to shatter it."
	icon = 'icons/obj/podwindows.dmi'
	icon_state = "window-mine"
	basestate = "window-mine"
	reinf = 1
	maxhealth = 40
	explosion_block = 3
	dir = 5
	is_full_window = TRUE

/obj/structure/window/research
	name = "shuttle window"
	desc = "It looks rather strong. Might take a few good hits to shatter it."
	icon = 'icons/obj/podwindows.dmi'
	icon_state = "window-res"
	basestate = "window-res"
	reinf = 1
	maxhealth = 40
	explosion_block = 3
	dir = 5
	is_full_window = TRUE

/obj/structure/window/syndi
	name = "shuttle window"
	desc = "It looks rather strong. Might take a few good hits to shatter it."
	icon = 'icons/obj/podwindows.dmi'
	icon_state = "window-syndi"
	basestate = "window-syndi"
	reinf = 1
	maxhealth = 40
	explosion_block = 3
	dir = 5
	is_full_window = TRUE

/obj/structure/window/reinforced/polarized
	name = "electrochromic window"
	desc = "Adjusts its tint with voltage. Might take a few good hits to shatter it."
	var/id
	polarized = 1

/obj/structure/window/reinforced/polarized/full
	dir = 5
	icon_state = "fwindow"
	is_full_window = TRUE

/obj/structure/window/reinforced/polarized/attackby(obj/item/W as obj, mob/user as mob)
	if(isMultitool(W))
		var/t = sanitizeSafe(input(user, "Enter the ID for the window.", src.name, null), MAX_NAME_LEN)
		if (user.get_active_hand() != W)
			return
		if (!in_range(src, user) && src.loc != user)
			return
		t = sanitizeSafe(t, MAX_NAME_LEN)
		if (t)
			src.id = t
			to_chat(user, "<span class='notice'>The new ID of the window is [id]</span>")
		return
	..()

/obj/structure/window/reinforced/polarized/proc/toggle()
	if(opacity)
		animate(src, color="#ffffff", time=5)
		set_opacity(0)
	else
		animate(src, color="#222222", time=5)
		set_opacity(1)

/obj/structure/window/reinforced/crescent/attack_hand()
	return

/obj/structure/window/reinforced/crescent/attackby()
	return

/obj/structure/window/reinforced/crescent/ex_act()
	return

/obj/structure/window/reinforced/crescent/hitby()
	return

/obj/structure/window/reinforced/crescent/take_damage()
	return

/obj/structure/window/reinforced/crescent/shatter()
	return

/obj/machinery/button/windowtint
	name = "window tint control"
	icon = 'icons/obj/power.dmi'
	icon_state = "light0"
	desc = "A remote control switch for electrochromic windows."
	var/range = 7

/obj/machinery/button/windowtint/attack_hand(mob/user as mob)
	if(..())
		return 1

	toggle_tint()

/obj/machinery/button/windowtint/attackby(obj/item/device/W as obj, mob/user as mob)
	if(isMultitool(W))
		to_chat(user, "<span class='notice'>The ID of the button: [id]</span>")
		return

/obj/machinery/button/windowtint/proc/toggle_tint()
	use_power_oneoff(5)

	active = !active
	queue_icon_update()

	for(var/obj/structure/window/reinforced/polarized/W in range(src,range))
		if (W.id == src.id || !W.id)
			spawn(0)
				W.toggle()
				return

/obj/machinery/button/windowtint/power_change()
	. = ..()
	if(active && !powered(power_channel))
		toggle_tint()

/obj/machinery/button/windowtint/on_update_icon()
	icon_state = "light[active]"
