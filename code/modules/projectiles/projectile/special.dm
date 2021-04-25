/obj/item/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	fire_sound = 'sound/weapons/Laser.ogg'
	damage = 0
	damage_type = BURN
	nodamage = 1
	check_armour = "energy"
	blockable = FALSE
	var/heavy_effect_range = 1
	var/light_effect_range = 2

	on_impact(var/atom/A)
		empulse(A, heavy_effect_range, light_effect_range)
		return 1

/obj/item/projectile/ion/small
	name = "ion pulse"
	heavy_effect_range = 0
	light_effect_range = 1

/obj/item/projectile/ion/c44
	name = "ion bullet"
	icon_state = "ionbullet"
	nodamage = 0
	damage = 10
	heavy_effect_range = 0
	light_effect_range = 0

/obj/item/projectile/bullet/gyro
	name ="explosive bolt"
	icon_state= "bolter"
	damage = 50
	check_armour = "bullet"
	sharp = 1
	edge = 1

	on_hit(var/atom/target, var/blocked = 0)
		explosion(target, -1, 0, 2)
		return 1

/obj/item/projectile/temp
	name = "freeze beam"
	icon_state = "ice_2"
	fire_sound = 'sound/weapons/pulse3.ogg'
	damage = 0
	damage_type = BURN
	nodamage = 1
	check_armour = "energy"
	var/temperature = 300


	on_hit(var/atom/target, var/blocked = 0)//These two could likely check temp protection on the mob
		if(istype(target, /mob/living))
			var/mob/M = target
			M.bodytemperature = temperature
		return 1

/obj/item/projectile/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "smallf"
	damage = 0
	damage_type = BRUTE
	nodamage = 1
	check_armour = "bullet"
	blockable = FALSE

	Bump(atom/A as mob|obj|turf|area)
		if(A == firer)
			loc = A.loc
			return

		sleep(-1) //Might not be important enough for a sleep(-1) but the sleep/spawn itself is necessary thanks to explosions and metoerhits

		if(src)//Do not add to this if() statement, otherwise the meteor won't delete them
			if(A)

				A.ex_act(2)
				playsound(src.loc, 'sound/effects/meteorimpact.ogg', 40, 1)

				for(var/mob/M in range(10, src))
					if(!M.stat && !istype(M, /mob/living/silicon/ai))\
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

	on_hit(var/atom/target, var/blocked = 0)
		var/mob/living/M = target
		if(ishuman(target))
			var/mob/living/carbon/human/H = M
			if((H.species.species_flags & SPECIES_FLAG_IS_PLANT) && (H.nutrition < 500))
				if(prob(15))
					H.apply_effect((rand(30,80)),IRRADIATE,blocked = H.getarmor(null, "rad"))
					H.Weaken(5)
					H.Stun(5)
					for (var/mob/V in viewers(src))
						V.show_message("<span class='warning'>[M] writhes in pain as \his vacuoles boil.</span>", 3, "<span class='warning'>You hear the crunching of leaves.</span>", 2)
				if(prob(35))
					if(prob(80))
						randmutb(M)
						domutcheck(M,null)
					else
						randmutg(M)
						domutcheck(M,null)
				else
					M.adjustFireLoss(rand(5,15))
					M.show_message("<span class='danger'>The radiation beam singes you!</span>")
		else if(istype(target, /mob/living/carbon/))
			M.show_message("<span class='notice'>The radiation beam dissipates harmlessly through your body.</span>")
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
	var/decl/plantgene/gene = null

/obj/item/projectile/energy/florayield
	name = "beta somatoray"
	icon_state = "energy2"
	fire_sound = 'sound/effects/stealthoff.ogg'
	damage = 0
	damage_type = TOX
	nodamage = 1
	check_armour = "energy"

	on_hit(var/atom/target, var/blocked = 0)
		var/mob/M = target
		if(ishuman(target)) //These rays make plantmen fat.
			var/mob/living/carbon/human/H = M
			if((H.species.species_flags & SPECIES_FLAG_IS_PLANT) && (H.nutrition < 500))
				H.nutrition += 30
		else if (istype(target, /mob/living/carbon/))
			M.show_message("<span class='notice'>The radiation beam dissipates harmlessly through your body.</span>")
		else
			return 1


/obj/item/projectile/beam/mindflayer
	name = "flayer ray"

	on_hit(var/atom/target, var/blocked = 0)
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
	muzzle_type = /obj/effect/projectile/bullet/muzzle

/obj/item/projectile/energy/laser
	name = "laser slug"
	icon_state = "ibeam"
	damage = 30
	agony = 10
	eyeblur = 4
	damage_type = BURN
	check_armour = "laser"
	armor_penetration = 10
	sharp = 1 //concentrated burns
	pass_flags = PASS_FLAG_TABLE | PASS_FLAG_GRILLE
	fire_sound = 'sound/effects/weapons/energy/fire8.ogg'

/obj/item/projectile/energy/laser/mid
	icon_state = "laser"
	damage = 60
	agony = 20
	armor_penetration = 20

/obj/item/projectile/energy/laser/heavy
	name = "heavy laser slug"
	icon_state = "heavylaser"
	damage = 80
	agony = 30
	armor_penetration = 40
	fire_sound = 'sound/effects/weapons/energy/fire21.ogg'

/obj/item/projectile/facehugger_proj // Yes, it's dirty, and hacky, and so on. But it works and works fucking perfectly.
	name = "alien"
	icon = 'icons/mob/alien.dmi'
	icon_state = "facehugger_thrown"
	embed = 0 // nope nope nope nope nope
	damage_type = PAIN
	pass_flags = PASS_FLAG_TABLE
	var/mob/living/simple_animal/hostile/facehugger/holder = null

/obj/item/projectile/facehugger_proj/Bump(atom/A as mob|obj|turf|area)
	if(A == firer)
		loc = A.loc
		return

	if(!holder)
		return

	if(bumped)
		return
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
			else if(O.CanZASPass(previous_loc)) // If it doesn't block gases, it also doesn't prevent us from getting through
				continue
			holder.forceMove(previous_loc) // Otherwise we failed to pass
			holder.visible_message(SPAN("danger", "\The [holder] smacks against \the [O]!"))
			break

	holder.FindTarget()
	holder.MoveToTarget() // Calling these two to make sure the facehugger will try to keep distance upon missing
	holder = null


	set_density(0)
	set_invisibility(101)
	qdel(src)
	return TRUE
