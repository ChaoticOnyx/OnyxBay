/*
	Defines a firing mode for a gun.

	A firemode is created from a list of fire mode settings. Each setting modifies the value of the gun var with the same name.
	If the fire mode value for a setting is null, it will be replaced with the initial value of that gun's variable when the firemode is created.
	Obviously not compatible with variables that take a null value. If a setting is not present, then the corresponding var will not be modified.
*/
/datum/firemode
	var/name = "default"
	var/list/settings = list()

/datum/firemode/New(obj/item/gun/gun, list/properties = null)
	..()
	if(!properties) return

	for(var/propname in properties)
		var/propvalue = properties[propname]

		if(propname == "mode_name")
			name = propvalue
		else if(isnull(propvalue))
			settings[propname] = gun.vars[propname] //better than initial() as it handles list vars like burst_accuracy
		else
			settings[propname] = propvalue

/datum/firemode/proc/apply_to(obj/item/gun/gun)
	for(var/propname in settings)
		gun.vars[propname] = settings[propname]

//Parent gun type. Guns are weapons that can be aimed at mobs and act over a distance
/obj/item/gun
	name = "gun"
	desc = "Its a gun. It's pretty terrible, though."
	icon = 'icons/obj/guns/gun.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand_guns.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand_guns.dmi',
		)
	icon_state = ""
	item_state = "gun"
	obj_flags =  OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	matter = list(MATERIAL_STEEL = 2000)
	w_class = ITEM_SIZE_NORMAL
	throwforce = 5
	throw_range = 5
	force = 7.5
	mod_weight = 0.75
	mod_reach = 0.65
	mod_handy = 0.85
	origin_tech = list(TECH_COMBAT = 1)
	attack_verb = list("struck", "hit", "bashed")
	zoomdevicename = "scope"

	var/burst = 1
	var/fire_delay = 6 	//delay after shooting before the gun can be used again
	var/burst_delay = 2	//delay between shots, if firing in bursts
	var/move_delay = 1
	var/fire_sound = 'sound/effects/weapons/gun/gunshot.ogg'
	var/far_fire_sound = null
	var/fire_sound_text = "gunshot"
	var/screen_shake = 0 //shouldn't be greater than 2 unless zoomed
	var/silenced = 0
	var/accuracy = 0   //accuracy is measured in tiles. +1 accuracy means that everything is effectively one tile closer for the purpose of miss chance, -1 means the opposite. launchers are not supported, at the moment.
	var/scoped_accuracy = null
	var/list/burst_accuracy = list(0) //allows for different accuracies for each shot in a burst. Applied on top of accuracy
	var/list/dispersion = list(0)
	var/one_hand_penalty
	var/wielded_item_state
	var/combustion = TRUE //whether it creates hotspot when fired

	var/next_fire_time = 0

	var/sel_mode = 1 //index of the currently selected mode
	var/list/firemodes = list()

	//aiming system stuff
	var/keep_aim = 1 	//1 for keep shooting until aim is lowered
						//0 for one bullet after tarrget moves and aim is lowered
	var/multi_aim = 0 //Used to determine if you can target multiple people.
	var/tmp/list/mob/living/aim_targets //List of who yer targeting.
	var/tmp/mob/living/last_moved_mob //Used to fire faster at more than one person.
	var/tmp/told_cant_shoot = 0 //So that it doesn't spam them with the fact they cannot hit them.
	var/tmp/lock_time = -100

	var/tmp/last_safety_check = -INFINITY
	var/safety_state = 1
	var/has_safety = TRUE
	var/safety_icon 	   //overlay to apply to gun based on safety state, if any

	var/autofire_enabled = FALSE
	var/atom/autofiring_at
	var/mob/autofiring_by
	var/autofiring_timer

	drop_sound = SFX_DROP_GUN
	pickup_sound = SFX_PICKUP_GUN

/obj/item/gun/Initialize()
	. = ..()
	for(var/i in 1 to firemodes.len)
		firemodes[i] = new /datum/firemode(src, firemodes[i])

	if(isnull(scoped_accuracy))
		scoped_accuracy = accuracy

	if(config.misc.toogle_gun_safety)
		verbs |= /obj/item/gun/proc/toggle_safety_verb

/obj/item/gun/Destroy()
	// autofire timer is automatically cleaned up
	autofiring_at = null
	autofiring_by = null
	aim_targets = null
	last_moved_mob = null
	QDEL_NULL_LIST(firemodes)
	. = ..()

/obj/item/gun/proc/set_autofire(atom/fire_at, mob/fire_by)
	. = TRUE
	if(!istype(fire_at) || !istype(fire_by))
		. = FALSE
	else if(QDELETED(fire_at) || QDELETED(fire_by) || QDELETED(src))
		. = FALSE
	else if(!autofire_enabled)
		. = FALSE
	if(.)
		autofiring_at = fire_at
		autofiring_by = fire_by
		if(!autofiring_timer)
			autofiring_timer = addtimer(CALLBACK(src, nameof(.proc/handle_autofire)), burst_delay, (TIMER_STOPPABLE | TIMER_LOOP | TIMER_UNIQUE | TIMER_OVERRIDE))
	else
		clear_autofire()

/obj/item/gun/proc/clear_autofire()
	autofiring_at = null
	autofiring_by = null
	if(autofiring_timer)
		deltimer(autofiring_timer)
		autofiring_timer = null

/obj/item/gun/proc/handle_autofire()
	set waitfor = FALSE
	. = TRUE
	if(QDELETED(autofiring_at) || QDELETED(autofiring_by))
		. = FALSE
	else if(autofiring_by.get_active_hand() != src || autofiring_by.incapacitated())
		. = FALSE
	else if(!autofiring_by.client || !(autofiring_by in view(autofiring_by.client.view, autofiring_by)))
		. = FALSE
	if(!.)
		clear_autofire()
	else if(can_autofire())
		autofiring_by.set_dir(get_dir(src, autofiring_at))
		Fire(autofiring_at, autofiring_by, null, (get_dist(autofiring_at, autofiring_by) <= 1), FALSE, FALSE)

/obj/item/gun/update_twohanding()
	if(one_hand_penalty)
		update_icon() // In case item_state is set somewhere else.
	..()

/obj/item/gun/on_update_icon()
	if(wielded_item_state)
		var/mob/living/M = loc
		if(istype(M))
			if(M.can_wield_item(src) && is_held_twohanded(M))
				item_state_slots[slot_l_hand_str] = wielded_item_state
				item_state_slots[slot_r_hand_str] = wielded_item_state
			else
				item_state_slots[slot_l_hand_str] = initial(item_state)
				item_state_slots[slot_r_hand_str] = initial(item_state)
	update_held_icon()

/obj/item/gun/equipped(mob/living/user, slot)
	..()
	update_safety_icon()
	clear_autofire()

/obj/item/gun/dropped(mob/living/user)
	ClearOverlays()
	clear_autofire()
	..()
	update_icon()

//Checks whether a given mob can use the gun
//Any checks that shouldn't result in handle_click_empty() being called if they fail should go here.
//Otherwise, if you want handle_click_empty() to be called, check in consume_next_projectile() and return null there.
/obj/item/gun/proc/special_check(mob/user)

	if(!istype(user, /mob/living))
		return FALSE
	if(!user.IsAdvancedToolUser())
		return FALSE

	var/mob/living/M = user
	if(is_pacifist(user))
		to_chat(user, SPAN("warning", "You can't you're pacifist!"))
		return 0
	if(MUTATION_HULK in M.mutations)
		to_chat(M, "<span class='danger'>Your fingers are much too large for the trigger guard!</span>")
		return FALSE

	if(safety())
		handle_click_safety(user)
		return FALSE
	if((MUTATION_CLUMSY in M.mutations) && prob(40) && !clumsy_unaffected) //Clumsy handling
		var/obj/P = consume_next_projectile()
		if(P)
			if(process_projectile(P, user, user, pick(BP_L_FOOT, BP_R_FOOT)))
				handle_post_fire(user, user)
				user.visible_message(
					"<span class='danger'>\The [user] shoots \himself in the foot with \the [src]!</span>",
					"<span class='danger'>You shoot yourself in the foot with \the [src]!</span>"
					)
				M.drop_active_hand()
		else
			handle_click_empty(user)
		return FALSE
	return 1

/obj/item/gun/emp_act(severity)
	for(var/obj/O in contents)
		O.emp_act(severity)

/obj/item/gun/afterattack(atom/A, mob/living/user, adjacent, params)
	if(adjacent) return //A is adjacent, is the user, or is on the user's person

	if(!user.aiming)
		user.aiming = new(user)

	if(user && user.client && user.aiming && user.aiming.active && user.aiming.aiming_at != A)
		PreFire(A,user,params) //They're using the new gun system, locate what they're aiming at.
		return

	Fire(A,user,params) //Otherwise, fire normally.

/obj/item/gun/attack(atom/A, mob/living/user, def_zone)
	if(ishuman(A) && user.zone_sel.selecting == BP_MOUTH && user.a_intent != I_HURT && !weapon_in_mouth)
		handle_war_crime(user, A)
	if (A == user && user.zone_sel.selecting == BP_MOUTH && !mouthshoot)
		handle_suicide(user)
	else if(user.a_intent == I_HURT) //point blank shooting
		Fire(A, user, pointblank=1)
	else
		return ..() //Pistolwhippin'

/obj/item/gun/proc/Fire(atom/target, atom/movable/firer, clickparams, pointblank = FALSE, reflex = FALSE, target_zone = BP_CHEST)
	if(!firer || !target)
		return

	if(target.z != firer.z)
		return

	if(ismob(firer))
		add_fingerprint(firer)

		if(!special_check(firer))
			return

	if(world.time < next_fire_time)
		if(world.time % 3) //to prevent spam
			to_chat(firer, SPAN_WARNING("[src] is not ready to fire again!"))
		return

	var/shoot_time = (burst - 1)* burst_delay

	var/held_twohanded = TRUE

	if(ismob(firer))
		var/mob/user = firer
		user.setClickCooldown(shoot_time) //no clicking on things while shooting
		user.setMoveCooldown(shoot_time) //no moving while shooting either
		held_twohanded = user.can_wield_item(src) && src.is_held_twohanded(user)

	next_fire_time = world.time + shoot_time

	//actually attempt to shoot
	var/turf/targloc = get_turf(target) //cache this in case target gets deleted during shooting, e.g. if it was a securitron that got destroyed.
	var/fired = FALSE
	for(var/i in 1 to burst)
		var/obj/projectile = consume_next_projectile(firer)
		if(!projectile)
			handle_click_empty(firer)
			break

		fired = TRUE
		process_accuracy(projectile, firer, target, i, held_twohanded)

		if(pointblank)
			process_point_blank(projectile, firer, target)

		if(process_projectile(projectile, firer, target, target_zone, clickparams))
			var/burstfire = 0
			if(burst > 1) // It ain't a burst? Then just act normally
				if(i > 1)
					burstfire = -1  // We've already seen the BURST message, so shut up
				else
					burstfire = 1 // We've yet to see the BURST message
			handle_post_fire(firer, target, pointblank, reflex, burstfire)
			update_icon()

		if(i < burst)
			sleep(burst_delay)

		if(!(target && target.loc))
			target = targloc
			pointblank = 0

	//update timing
	var/turf/T = get_turf(firer)
	var/area/A = get_area(T)
	if(ismob(firer))
		var/mob/user = firer

		if(((istype(T, /turf/space)) || (A.has_gravity == FALSE)) && fired)
			user.inertia_dir = get_dir(target, src)
			user.setMoveCooldown(shoot_time) //no moving while shooting either
			step(user, user.inertia_dir) // they're in space, move em in the opposite direction

		user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
		user.setMoveCooldown(move_delay)

	next_fire_time = world.time + fire_delay

//obtains the next projectile to fire
/obj/item/gun/proc/consume_next_projectile()
	return null

//used by aiming code
/obj/item/gun/proc/can_hit(atom/target as mob, mob/living/user as mob)
	if(!special_check(user))
		return 2
	//just assume we can shoot through glass and stuff. No big deal, the player can just choose to not target someone
	//on the other side of a window if it makes a difference. Or if they run behind a window, too bad.
	return check_trajectory(target, user)

//called if there was no projectile to shoot
/obj/item/gun/proc/handle_click_empty(mob/user)
	if (user)
		user.visible_message("*click click*", "<span class='danger'>*click*</span>")
	else
		src.visible_message("*click click*")
	playsound(src.loc, 'sound/effects/weapons/gun/gun_empty.ogg', 75)

/obj/item/gun/proc/handle_click_safety(mob/user)
	user.visible_message(SPAN_WARNING("[user] squeezes the trigger of \the [src] but it doesn't move!"), SPAN_WARNING("You squeeze the trigger but it doesn't move!"), range = 3)

//called after successfully firing
/obj/item/gun/proc/handle_post_fire(atom/movable/firer, atom/target, pointblank = 0, reflex = 0, burstfire = 0)

	if(!silenced && (burstfire != -1))
		if(reflex)
			firer.visible_message(
				"<span class='reflex_shoot'><b>\The [firer] fires \the [src][pointblank ? " point blank at \the [target]":""][burstfire == 1 ? " in a burst":""] by reflex!</b></span>",
				"<span class='reflex_shoot'>You fire \the [src] by reflex!</span>",
				"You hear a [fire_sound_text]!"
			)
		else
			firer.visible_message(
				"<span class='danger'>\The [firer] fires \the [src][pointblank ? " point blank at \the [target]":""][burstfire == 1 ? " in a burst":""]!</span>",
				"<span class='warning'>You fire \the [src]!</span>",
				"You hear a [fire_sound_text]!"
				)

	if(ismob(firer))
		var/mob/user = firer

		if(one_hand_penalty && (burstfire != -1))
			if(!src.is_held_twohanded(user))
				switch(one_hand_penalty)
					if(1)
						if(prob(50)) //don't need to tell them every single time
							to_chat(user, "<span class='warning'>Your aim wavers slightly.</span>")
					if(2)
						to_chat(user, "<span class='warning'>Your aim wavers as you fire \the [src] with just one hand.</span>")
					if(3)
						to_chat(user, "<span class='warning'>You have trouble keeping \the [src] on target with just one hand.</span>")
					if(4 to INFINITY)
						to_chat(user, "<span class='warning'>You struggle to keep \the [src] on target with just one hand!</span>")
			else if(!user.can_wield_item(src))
				switch(one_hand_penalty)
					if(1)
						if(prob(50)) //don't need to tell them every single time
							to_chat(user, "<span class='warning'>Your aim wavers slightly.</span>")
					if(2)
						to_chat(user, "<span class='warning'>Your aim wavers as you try to hold \the [src] steady.</span>")
					if(3)
						to_chat(user, "<span class='warning'>You have trouble holding \the [src] steady.</span>")
					if(4 to INFINITY)
						to_chat(user, "<span class='warning'>You struggle to hold \the [src] steady!</span>")

		if(screen_shake)
			INVOKE_ASYNC(GLOBAL_PROC, /proc/directional_recoil, user, screen_shake+1, Get_Angle(user, target))

	if(combustion)
		var/turf/curloc = get_turf(src)
		curloc.hotspot_expose(700, 5)

	update_icon()


/obj/item/gun/proc/process_point_blank(obj/projectile, mob/user, atom/target)
	var/obj/item/projectile/P = projectile
	if(!istype(P))
		return //default behaviour only applies to true projectiles

	//default point blank multiplier
	var/max_mult = 1.3

	//determine multiplier due to the target being grabbed
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		for(var/obj/item/grab/G in H.grabbed_by)
			if(G.point_blank_mult() > max_mult)
				max_mult = G.point_blank_mult()
		if(H.lying)
			max_mult *= 1.5
	P.damage *= max_mult
	P.accuracy += 4

/obj/item/gun/proc/process_accuracy(obj/projectile, atom/movable/firer, atom/target, burst, held_twohanded)
	var/obj/item/projectile/P = projectile
	if(!istype(P))
		return //default behaviour only applies to true projectiles

	var/acc_mod = burst_accuracy[min(burst, burst_accuracy.len)]
	var/disp_mod = dispersion[min(burst, dispersion.len)]

	if(one_hand_penalty)
		if(!held_twohanded)
			acc_mod += -ceil(one_hand_penalty/2)
			disp_mod += one_hand_penalty*0.5 //dispersion per point of two-handedness

	// Shooting precisely while trying to turtle yourself up with a shield is hard
	var/mob/user = firer
	if(istype(user) && user.blocking)
		acc_mod -= 1
		disp_mod += 1

	//Accuracy modifiers
	P.accuracy = accuracy + acc_mod
	P.dispersion = disp_mod

	//accuracy bonus from aiming
	if (aim_targets && (target in aim_targets))
		//If you aim at someone beforehead, it'll hit more often.
		//Kinda balanced by fact you need like 2 seconds to aim
		//As opposed to no-delay pew pew
		P.accuracy += 2

//does the actual launching of the projectile
/obj/item/gun/proc/process_projectile(obj/projectile, atom/movable/firer, atom/target, target_zone, params=null)
	var/obj/item/projectile/P = projectile
	if(!istype(P))
		return 0 //default behaviour only applies to true projectiles

	if(params)
		P.set_clickpoint(params)

	//shooting while in shock
	var/shock_dispersion = 0
	if(istype(firer, /mob/living/carbon/human))
		var/mob/living/carbon/human/mob = firer
		if(mob.shock_stage > 120)
			shock_dispersion = rand(-4,4)
		else if(mob.shock_stage > 70)
			shock_dispersion = rand(-2,2)
	P.dispersion += shock_dispersion

	var/launched = !P.launch(target, target_zone, firer, params, src)
	if(launched)
		play_fire_sound(firer, P)

	return launched

/obj/item/gun/proc/play_fire_sound(atom/movable/firer, obj/item/projectile/P)
	var/shot_sound = (istype(P) && P.fire_sound)? P.fire_sound : fire_sound

	if (!silenced)
		playsound(loc, shot_sound, rand(85, 95), extrarange = 10, falloff = 1) // it should be LOUD // TODO: Normalize all fire sound files so every volume is closely same
	else
		playsound(loc, shot_sound, rand(10, 20), extrarange = -3, falloff = 0.35) // it should be quiet

//Suicide handling.
/obj/item/gun/var/mouthshoot = 0 //To stop people from suiciding twice... >.>
/obj/item/gun/proc/handle_suicide(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/M = user

	mouthshoot = 1
	M.visible_message("<span class='danger'>[user] sticks their gun in their mouth, ready to pull the trigger...</span>")
	if(!do_after(user, 40, progress=0))
		M.visible_message("<span class='notice'>[user] decided life was worth living</span>")
		mouthshoot = 0
		return
	if(istype(src, /obj/item/gun/flamer))
		user.adjust_fire_stacks(15)
		user.IgniteMob()
		user.death()
		log_and_message_admins("[key_name(user)] commited suicide using \a [src]")
		playsound(user, 'sound/weapons/gunshot/flamethrower/flamer_fire.ogg', 50, 1)
		mouthshoot = 0
		return
	var/obj/item/projectile/in_chamber = consume_next_projectile()
	if (istype(in_chamber) && process_projectile(in_chamber, user, user, BP_MOUTH))
		user.visible_message("<span class = 'warning'>[user] pulls the trigger.</span>")
		var/shot_sound = in_chamber.fire_sound? in_chamber.fire_sound : fire_sound
		if(silenced)
			playsound(user, shot_sound, 10, 1)
		else
			playsound(user, shot_sound, 50, 1)
		if(istype(in_chamber, /obj/item/projectile/beam/lasertag))
			user.show_message("<span class = 'warning'>You feel rather silly, trying to commit suicide with a toy.</span>")
			mouthshoot = 0
			return
		if(istype(in_chamber, /obj/item/projectile/energy/floramut))
			user.show_message(SPAN("warning", "Sorry, you are not a flower."))
			mouthshoot = 0
			return

		in_chamber.on_hit(M)
		if (in_chamber.damage_type != PAIN)
			log_and_message_admins("[key_name(user)] commited suicide using \a [src]")
			user.apply_damage(in_chamber.damage*2.5, in_chamber.damage_type, BP_HEAD, 0, in_chamber.damage_flags(), used_weapon = "Point blank shot in the mouth with \a [in_chamber]")
			user.death()
		else
			to_chat(user, "<span class = 'notice'>Ow...</span>")
			user.apply_effect(110,PAIN,0)
		QDEL_NULL(in_chamber)
		mouthshoot = 0
		return
	else
		handle_click_empty(user)
		mouthshoot = 0
		return
/obj/item/gun/var/weapon_in_mouth = FALSE

/obj/item/gun/proc/handle_war_crime(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/obj/item/grab/G = user.get_inactive_hand()
	if(G?.affecting == target)
		if(!G?.current_grab?.can_absorb)
			to_chat(user, SPAN_NOTICE("You need a better grab for this."))
			return

		var/obj/item/organ/external/head/head = target.organs_by_name[BP_HEAD]
		if(!istype(head))
			to_chat(user, SPAN_NOTICE("You can't shoot in [target]'s mouth because you can't find their head."))
			return

		var/obj/item/clothing/head/helmet = target.get_equipped_item(slot_head)
		var/obj/item/clothing/mask/mask = target.get_equipped_item(slot_wear_mask)
		if((istype(helmet) && (helmet.body_parts_covered & HEAD)) || (istype(mask) && (mask.body_parts_covered & FACE)))
			to_chat(user, SPAN_NOTICE("You can't shoot in [target]'s mouth because their face is covered."))
			return

		weapon_in_mouth = TRUE
		target.visible_message(SPAN_DANGER("[user] sticks their gun in [target]'s mouth, ready to pull the trigger..."))
		if(!do_after(user, 2 SECONDS, progress=0))
			target.visible_message(SPAN_NOTICE("[user] decided [target]'s life was worth living."))
			weapon_in_mouth = FALSE
			return
		if(istype(src, /obj/item/gun/flamer))
			target.adjust_fire_stacks(15)
			target.IgniteMob()
			target.death()
			log_and_message_admins("[key_name(user)] killed [target] using \a [src]")
			playsound(user, 'sound/weapons/gunshot/flamethrower/flamer_fire.ogg', 50, 1)
			weapon_in_mouth = FALSE
			return
		var/obj/item/projectile/in_chamber = consume_next_projectile()
		if(istype(in_chamber) && process_projectile(in_chamber, user, target, BP_MOUTH))
			var/not_killable = istype(in_chamber, /obj/item/projectile/energy/electrode) || istype(in_chamber, /obj/item/projectile/energy/flash) || !in_chamber.damage
			user.visible_message(SPAN_WARNING("[user] pulls the trigger."))
			var/shot_sound = in_chamber.fire_sound ? in_chamber.fire_sound : fire_sound
			if(silenced)
				playsound(user, shot_sound, 10, 1)
			else
				playsound(user, shot_sound, 50, 1)
			if(istype(in_chamber, /obj/item/projectile/beam/lasertag))
				user.show_message(SPAN_WARNING("You feel rather silly, trying to shoot [target] with a toy."))
				weapon_in_mouth = FALSE
				return

			in_chamber.on_hit(target)
			if(in_chamber.damage_type != PAIN || !not_killable)
				log_and_message_admins("[key_name(user)] killed [target] using \a [src]")
				target.apply_damage(in_chamber.damage * 2.5, in_chamber.damage_type, BP_HEAD, 0, in_chamber.damage_flags(), used_weapon = "Point blank shot in the mouth with \a [in_chamber]")
				target.death()
			else
				to_chat(user, SPAN_NOTICE("Ow..."))
				target.apply_effect(110, PAIN, 0)
			QDEL_NULL(in_chamber)
			weapon_in_mouth = FALSE
			return
		else
			handle_click_empty(user)
			weapon_in_mouth = FALSE
			return

/obj/item/gun/proc/toggle_scope(mob/user, zoom_amount=2.0)
	//looking through a scope limits your periphereal vision
	//still, increase the view size by a tiny amount so that sniping isn't too restricted to NSEW
	var/zoom_offset = round(world.view * zoom_amount)
	var/view_size = round(world.view + zoom_amount)
	var/scoped_accuracy_mod = zoom_offset

	if(zoom)
		unzoom(user)
		return

	zoom(user, zoom_offset, view_size)
	if(zoom)
		accuracy = scoped_accuracy + scoped_accuracy_mod
		if(screen_shake)
			screen_shake = round(screen_shake*zoom_amount+1) //screen shake is worse when looking through a scope

//make sure accuracy and screen_shake are reset regardless of how the item is unzoomed.
/obj/item/gun/unzoom()
	..()
	accuracy = initial(accuracy)
	screen_shake = initial(screen_shake)

/obj/item/gun/_examine_text(mob/user)
	. = ..()
	if(firemodes.len > 1)
		var/datum/firemode/current_mode = firemodes[sel_mode]
		. += "\nThe fire selector is set to [current_mode.name]."
	if(config.misc.toogle_gun_safety && has_safety)
		. += "\nThe safety is [safety() ? "on" : "off"]"

// (re)Setting firemodes from the given list
/obj/item/gun/proc/set_firemodes(list/_firemodes = null)
	QDEL_LIST(firemodes)
	if(!length(_firemodes))
		sel_mode = 1
		return
	for(var/i in 1 to _firemodes.len)
		firemodes |= new /datum/firemode(src, _firemodes[i])
	sel_mode = 1
	var/datum/firemode/F = firemodes[1]
	F.apply_to(src)

/obj/item/gun/proc/switch_firemodes()
	if(firemodes.len <= 1)
		return null

	sel_mode++
	if(sel_mode > firemodes.len)
		sel_mode = 1
	var/datum/firemode/new_mode = firemodes[sel_mode]
	new_mode.apply_to(src)

	return new_mode

/obj/item/gun/attack_self(mob/user)
	var/datum/firemode/new_mode = switch_firemodes(user)
	if(new_mode)
		to_chat(user, "<span class='notice'>\The [src] is now set to [new_mode.name].</span>")

/obj/item/gun/proc/can_autofire()
	return (autofire_enabled && world.time >= next_fire_time)

/obj/item/gun/proc/safety()
	if(!config.misc.toogle_gun_safety)
		return FALSE

	return has_safety && safety_state

/obj/item/gun/proc/toggle_safety(mob/user)
	if(!config.misc.toogle_gun_safety)
		return

	if(!has_safety)
		return

	if (user?.is_physically_disabled())
		return

	safety_state = !safety_state
	update_safety_icon()
	if(user)
		user.visible_message(SPAN_WARNING("[user] switches the safety of \the [src] [safety_state ? "on" : "off"]."), SPAN_NOTICE("You switch the safety of \the [src] [safety_state ? "on" : "off"]."), range = 3)
		last_safety_check = world.time
		playsound(src, 'sound/weapons/flipblade.ogg', 15, 1)

/obj/item/gun/proc/update_safety_icon()
	if(!config.misc.toogle_gun_safety)
		return

	ClearOverlays()
	update_icon()
	AddOverlays((image('icons/obj/guns/gui.dmi',"safety[safety()]")))
	if(safety_icon)
		AddOverlays((image(icon,"[safety_icon][safety()]")))

/obj/item/gun/proc/toggle_safety_verb()
	set src in usr
	set category = "Object"
	set name = "Toggle Gun Safety"
	if(usr == loc)
		toggle_safety(usr)

/obj/item/gun/CtrlClick(mob/user)
	if(loc == user)
		toggle_safety(user)
		return TRUE
	. = ..()
