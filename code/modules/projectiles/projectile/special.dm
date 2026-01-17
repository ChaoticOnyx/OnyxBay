/obj/item/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	fire_sound = 'sound/effects/weapons/energy/Laser.ogg'
	damage = 0
	damage_type = BURN
	nodamage = 1
	check_armour = "energy"
	blockable = FALSE
	projectile_light = TRUE
	projectile_brightness_color = COLOR_LIGHT_CYAN
	var/heavy_effect_range = 1
	var/light_effect_range = 2

/obj/item/projectile/ion/on_impact(atom/A)
		empulse(A, heavy_effect_range, light_effect_range)
		return 1

/obj/item/projectile/ion/small
	name = "ion pulse"
	heavy_effect_range = 0
	light_effect_range = 1
	projectile_inner_range = 0.2

/obj/item/projectile/ion/c38
	name = "ion bullet"
	icon_state = "ionbullet"
	nodamage = 0
	damage = 10
	heavy_effect_range = 0
	light_effect_range = 0
	projectile_inner_range = 0.2
	projectile_outer_range = 1.25

/obj/item/projectile/bullet/gyro
	name ="explosive bolt"
	icon_state= "bolter"
	damage = 50
	check_armour = "bullet"
	sharp = 1
	edge = 1

/obj/item/projectile/bullet/gyro/on_hit(atom/target, blocked = 0)
	explosion(target, -1, 0, 2)
	return 1

/obj/item/projectile/temp
	name = "hot beam"
	icon_state = "ice_2"
	fire_sound = 'sound/effects/weapons/energy/pulse3.ogg'
	damage = 0
	damage_type = BURN
	nodamage = 1
	check_armour = "energy"
	projectile_light = TRUE
	projectile_brightness_color = COLOR_DEEP_SKY_BLUE
	var/temperature = 300


/obj/item/projectile/temp/on_hit(atom/target, blocked = 0)//These two could likely check temp protection on the mob
	if(istype(target, /mob/living))
		var/mob/M = target
		M.bodytemperature = temperature
	return 1

/obj/item/projectile/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small"
	damage = 0
	damage_type = BRUTE
	nodamage = 1
	check_armour = "bullet"
	blockable = FALSE
	poisedamage = 255 // slammy jammy

/obj/item/projectile/meteor/Bump(atom/A, forced = FALSE)
	if(A == firer)
		loc = A.loc
		return

	if(src)//Do not add to this if() statement, otherwise the meteor won't delete them
		if(A)

			A.ex_act(2)
			playsound(src.loc, 'sound/effects/meteorimpact.ogg', 40, 1)

			for(var/mob/M in range(10, src))
				if(!M.stat && !istype(M, /mob/living/silicon/ai))
					shake_camera(M, 3, 1)
			qdel(src)
			return 1
	else
		return 0

/obj/item/projectile/energy/floramut
	name = "alpha somatoray"
	icon_state = "energy"
	fire_sound = 'sound/effects/stealthoff.ogg'
	damage = 0
	damage_type = TOX
	nodamage = 1
	check_armour = "energy"
	projectile_light = TRUE
	projectile_brightness_color = COLOR_LIME
	projectile_inner_range = 0.2

/obj/item/projectile/energy/floramut/on_hit(atom/target, blocked = 0)
	var/mob/living/M = target
	if(ishuman(target))
		var/mob/living/carbon/human/H = M
		if((H.species.species_flags & SPECIES_FLAG_IS_PLANT) && (H.nutrition < 500))
			if(prob(15))
				M.rad_act(new /datum/radiation_source(new /datum/radiation(rand(3.5 TERA BECQUEREL, 4 TERA BECQUEREL), RADIATION_ALPHA_PARTICLE), src))
				H.Weaken(5)
				H.Stun(5)
				for (var/mob/V in viewers(src))
					V.show_message(SPAN_WARNING("[M] writhes in pain as \his vacuoles boil."), 3, SPAN_WARNING("You hear the crunching of leaves."), 2)
			M.adjustFireLoss(rand(5,15))
			M.show_message(SPAN_DANGER("The radiation beam singes you!"))
	else if(istype(target, /mob/living/carbon))
		M.show_message(SPAN_NOTICE("The radiation beam dissipates harmlessly through your body."))
	else
		return 1

/obj/item/projectile/energy/floramut/gene
	name = "gamma somatoray"
	icon_state = "energy2"
	fire_sound = 'sound/effects/stealthoff.ogg'
	damage = 0
	damage_type = TOX
	nodamage = 1
	check_armour = "energy"
	projectile_brightness_color = "#e6d1b5"
	var/decl/plantgene/gene = null

/obj/item/projectile/energy/florayield
	name = "beta somatoray"
	icon_state = "energy2"
	fire_sound = 'sound/effects/stealthoff.ogg'
	damage = 0
	damage_type = TOX
	nodamage = 1
	check_armour = "energy"
	projectile_light = TRUE
	projectile_brightness_color = "#e6d1b5"
	projectile_inner_range = 0.2

/obj/item/projectile/energy/florayield/on_hit(atom/target, blocked = 0)
	var/mob/M = target
	if(ishuman(target)) //These rays make plantmen fat.
		var/mob/living/carbon/human/H = M
		if((H.species.species_flags & SPECIES_FLAG_IS_PLANT) && (H.nutrition < 500))
			H.add_nutrition(30)
	else if (istype(target, /mob/living/carbon))
		M.show_message(SPAN_NOTICE("The radiation beam dissipates harmlessly through your body."))
	else
		return 1


/obj/item/projectile/beam/mindflayer
	name = "flayer ray"

/obj/item/projectile/beam/mindflayer/on_hit(atom/target, blocked = 0)
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		M.confused += rand(5,8)

/obj/item/projectile/chameleon
	name = "bullet"
	icon_state = "bullet"
	damage = 1 // stop trying to murderbone with a fake gun dumbass!!!
	embed = 0 // nope
	nodamage = 1
	damage_type = PAIN
	muzzle_type = /obj/effect/projectile/muzzle/bullet

/obj/item/projectile/energy/laser
	name = "energy blast"
	icon_state = "ibeam"
	damage = 30
	agony = 10
	eyeblur = 4
	damage_type = BURN
	check_armour = "laser"
	armor_penetration = 10
	sharp = 1 //concentrated burns
	tasing = FALSE // Nah, that's too much
	penetration_modifier = 0.35
	pass_flags = PASS_FLAG_TABLE | PASS_FLAG_GLASS | PASS_FLAG_GRILLE
	fire_sound = 'sound/effects/weapons/energy/fire8.ogg'
	projectile_light = TRUE
	projectile_brightness_color = COLOR_RED_LIGHT

/obj/item/projectile/energy/laser/small // Pistol level
	name = "small energy blast"
	icon_state = "laser_small"
	damage = 27.5
	armor_penetration = 0
	projectile_inner_range = 0.15

/obj/item/projectile/energy/laser/lesser // Carbine level
	icon_state = "laser_lesser"
	damage = 35
	agony = 5
	armor_penetration = 5
	projectile_inner_range = 0.2

/obj/item/projectile/energy/laser/mid // Rifle level
	icon_state = "laser"
	damage = 45
	agony = 10
	armor_penetration = 10

/obj/item/projectile/energy/laser/greater // Advanced laser rifle or something
	name = "large energy blast"
	icon_state = "laser_greater"
	damage = 55
	agony = 15
	armor_penetration = 20
	projectile_inner_range = 0.35
	projectile_outer_range = 1.75

/obj/item/projectile/energy/laser/heavy // Cannon level
	name = "heavy energy blast"
	icon_state = "laser_heavy"
	damage = 70
	agony = 20
	armor_penetration = 40
	fire_sound = 'sound/effects/weapons/energy/fire21.ogg'
	projectile_inner_range = 0.4
	projectile_outer_range = 2.0

/obj/item/projectile/facehugger_proj // Yes, it's dirty, and hacky, and so on. But it works and works fucking perfectly.
	name = "alien"
	icon = 'icons/mob/alien.dmi'
	icon_state = "facehugger_thrown"
	embed = 0 // nope nope nope nope nope
	damage = 5
	damage_type = PAIN
	pass_flags = PASS_FLAG_TABLE
	kill_count = 12

	var/mob/living/simple_animal/hostile/facehugger/holder = null

/obj/item/projectile/facehugger_proj/Bump(atom/A, forced = FALSE)
	if(A == src)
		return FALSE // no idea how this could ever happen but let's ensure

	if(A == firer)
		loc = A.loc
		return FALSE

	if(!holder)
		return FALSE

	if(bumped)
		return FALSE
	bumped = TRUE

	if(istype(A, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = A
		if(H.faction != holder.faction && holder.facefuck(H))
			holder = null
			qdel(src)
			return TRUE

	var/turf/bump_loc = get_turf(A)
	var/turf/previous_loc = get_turf(previous)
	holder.forceMove(bump_loc)

	if(istype(bump_loc, /turf/simulated/wall) || istype(bump_loc, /turf/simulated/shuttle/wall))
		holder.forceMove(previous_loc) // Get us out of the wall
	else
		for(var/obj/O in bump_loc)
			if(!O.density || !O.anchored)
				continue
			if(istype(O, /obj/structure/window)) // Yeah those fuckers require different processing, did I mention FUCK glass panes
				var/obj/structure/window/W = O
				if(get_turf(W) == starting)
					if(!W.CheckDiagonalExit(src, get_turf(original)))
						W.take_damage(10)
					else
						continue
				else if(!W.CanDiagonalPass(src, previous_loc))
					W.take_damage(10)
				else
					continue
			if(istype(O, /obj/structure/inflatable/door/panel)) // Those fuckers require different processing as well
				var/obj/structure/inflatable/door/panel/P = O
				if(get_turf(P) == starting)
					if(!P.CheckDiagonalExit(src, get_turf(original)))
						P.take_damage(5)
					else
						continue
				else if(!P.CanDiagonalPass(src, previous_loc))
					P.take_damage(5)
				else
					continue
			else if(O.CanZASPass(previous_loc)) // If it doesn't block gases, it also doesn't prevent us from getting through
				continue
			holder.forceMove(previous_loc) // Otherwise we failed to pass
			holder.visible_message(SPAN("danger", "\The [holder] smacks against \the [O]!"))
			break

	holder.set_target_mob(holder.find_target())
	holder.MoveToTarget() // Calling these two to make sure the facehugger will try to keep distance upon missing
	holder = null

	set_density(0)
	set_invisibility(101)
	qdel(src)
	return TRUE

/obj/item/projectile/facehugger_proj/on_impact(atom/A, use_impact = TRUE)
	Bump(A)

/obj/item/projectile/facehugger_proj/Destroy()
	if(!holder)
		return ..()

	if(kill_count)
		QDEL_NULL(holder)
	else
		var/turf/T = get_turf(loc)
		if(T)
			holder.forceMove(T)
			holder = null
		else
			QDEL_NULL(holder)
	return ..()

/obj/item/projectile/portal
	name = "portal sphere"
	icon_state = "portal"
	fire_sound = 'sound/effects/weapons/energy/Laser.ogg'
	damage = 0
	damage_type = CLONE
	nodamage = TRUE
	kill_count = 500 // enough to cross a ZLevel...twice!
	check_armour = "energy"
	blockable = FALSE
	impact_on_original = TRUE
	pass_flags = PASS_FLAG_TABLE | PASS_FLAG_GLASS | PASS_FLAG_GRILLE
	var/obj/item/gun/portalgun/parent
	var/setting = 0

/obj/item/projectile/portal/New(loc)
	parent = loc
	return ..()

/obj/item/projectile/portal/on_impact(atom/A)
	if(!istype(parent, /obj/item/gun/portalgun))
		return

	var/obj/item/gun/portalgun/P = parent

	if(!(locate(/obj/effect/portal) in loc))
		if(!ismob(firer))
			firer = shot_from
		P.open_portal(setting,loc,A,firer)
