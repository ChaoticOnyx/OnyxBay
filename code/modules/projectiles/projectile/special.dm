/obj/item/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	fire_sound = 'sound/effects/weapons/energy/Laser.ogg'
	damage = 0
	damage_type = BURN
	nodamage = 1
	check_armour = "energy"
	blockable = FALSE
	var/heavy_effect_range = 1
	var/light_effect_range = 2

/obj/item/projectile/ion/on_impact(atom/A)
		empulse(A, heavy_effect_range, light_effect_range)
		return 1

/obj/item/projectile/ion/small
	name = "ion pulse"
	heavy_effect_range = 0
	light_effect_range = 1

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
	var/temperature = 300


/obj/item/projectile/temp/on_hit(atom/target, blocked = 0)//These two could likely check temp protection on the mob
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

/obj/item/projectile/energy/floramut/on_hit(atom/target, blocked = 0)
	var/mob/living/M = target
	if(ishuman(target))
		var/mob/living/carbon/human/H = M
		if((H.species.species_flags & SPECIES_FLAG_IS_PLANT) && (H.nutrition < 500))
			if(prob(15))
				H.apply_effect((rand(30,80)),IRRADIATE,blocked = H.getarmor(null, "rad"))
				H.Weaken(5)
				H.Stun(5)
				for (var/mob/V in viewers(src))
					V.show_message(SPAN_WARNING("[M] writhes in pain as \his vacuoles boil."), 3, SPAN_WARNING("You hear the crunching of leaves."), 2)
			if(prob(35))
				if(prob(80))
					randmutb(M)
					domutcheck(M,null)
				else
					randmutg(M)
					domutcheck(M,null)
			else
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
	var/decl/plantgene/gene = null

/obj/item/projectile/energy/florayield
	name = "beta somatoray"
	icon_state = "energy2"
	fire_sound = 'sound/effects/stealthoff.ogg'
	damage = 0
	damage_type = TOX
	nodamage = 1
	check_armour = "energy"

/obj/item/projectile/energy/florayield/on_hit(atom/target, blocked = 0)
	var/mob/M = target
	if(ishuman(target)) //These rays make plantmen fat.
		var/mob/living/carbon/human/H = M
		if((H.species.species_flags & SPECIES_FLAG_IS_PLANT) && (H.nutrition < 500))
			H.nutrition += 30
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
	muzzle_type = /obj/effect/projectile/bullet/muzzle
