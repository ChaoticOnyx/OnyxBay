/obj/item/projectile/bullet
	name = "bullet"
	icon_state = "bullet"
	damage = 50
	damage_type = BRUTE
	nodamage = 0
	check_armour = "bullet"
	embed = 1
	sharp = 1
	penetration_modifier = 1.0
	poisedamage = 5.0
	var/mob_passthrough_check = 0

	muzzle_type = /obj/effect/projectile/muzzle/bullet

/obj/item/projectile/bullet/on_hit(atom/target, blocked = 0)
	if (..(target, blocked))
		var/mob/living/L = target
		shake_camera(L, 3, 2)

/obj/item/projectile/bullet/attack_mob(mob/living/target_mob, distance, miss_modifier)
	if(penetrating > 0 && damage > 20 && prob(damage))
		mob_passthrough_check = 1
	else
		mob_passthrough_check = 0
	. = ..()

	if(. == 1 && iscarbon(target_mob))
		damage *= 0.7 //squishy mobs absorb KE

/obj/item/projectile/bullet/can_embed()
	//prevent embedding if the projectile is passing through the mob
	if(mob_passthrough_check)
		return 0
	return ..()

/obj/item/projectile/bullet/check_penetrate(atom/A)
	if(!A || !A.density) return 1 //if whatever it was got destroyed when we hit it, then I guess we can just keep going

	if(istype(A, /obj/mecha))
		return 1 //mecha have their own penetration handling

	if(ismob(A))
		if(!mob_passthrough_check)
			return 0
		return 1

	var/chance = damage
	if(istype(A, /turf/simulated/wall))
		var/turf/simulated/wall/W = A
		chance = round(damage/W.material.integrity*180)
	else if(istype(A, /obj/machinery/door))
		var/obj/machinery/door/D = A
		chance = round(damage/D.maxhealth*180)
		if(D.glass) chance *= 2
	else if(istype(A, /obj/structure/girder))
		chance = 100

	if(prob(chance))
		if(A.opacity)
			//display a message so that people on the other side aren't so confused
			A.visible_message("<span class='warning'>\The [src] pierces through \the [A]!</span>")
		return 1

	return 0

//For projectiles that actually represent clouds of projectiles
/obj/item/projectile/bullet/pellet
	name = "shrapnel" //'shrapnel' sounds more dangerous (i.e. cooler) than 'pellet'
	damage = 22.5
	poisedamage = 10.0
	//icon_state = "bullet" //TODO: would be nice to have it's own icon state
	var/pellets = 4			//number of pellets
	var/range_step = 2		//projectile will lose a fragment each time it travels this distance. Can be a non-integer.
	var/base_spread = 90	//lower means the pellets spread more across body parts. If zero then this is considered a shrapnel explosion instead of a shrapnel cone
	var/spread_step = 10	//higher means the pellets spread more across body parts with distance

/obj/item/projectile/bullet/pellet/Bumped()
	. = ..()
	bumped = 0 //can hit all mobs in a tile. pellets is decremented inside attack_mob so this should be fine.

/obj/item/projectile/bullet/pellet/proc/get_pellets(distance)
	var/pellet_loss = round((distance - 1)/range_step) //pellets lost due to distance
	return max(pellets - pellet_loss, 1)

/obj/item/projectile/bullet/pellet/attack_mob(mob/living/target_mob, distance, miss_modifier)
	if(pellets < 0)
		return TRUE

	var/total_pellets = get_pellets(distance)
	var/spread = max(base_spread - (spread_step * distance), 0)

	//shrapnel explosions miss prone mobs with a chance that increases with distance
	var/prone_chance = 0
	if(!base_spread)
		prone_chance = max(spread_step * (distance - 2), 0)

	var/hits = 0
	for(var/i in 1 to total_pellets)
		if(target_mob.lying && target_mob != original && prob(prone_chance))
			continue

		//pellet hits spread out across different zones, but 'aim at' the targeted zone with higher probability
		//whether the pellet actually hits the def_zone or a different zone should still be determined by the parent using get_zone_with_miss_chance().
		var/old_zone = def_zone
		def_zone = ran_zone(def_zone, spread)
		if(..())
			hits++
		def_zone = old_zone //restore the original zone the projectile was aimed at

	pellets -= hits //each hit reduces the number of pellets left
	if(hits >= total_pellets || pellets <= 0)
		return TRUE
	return FALSE

/obj/item/projectile/bullet/pellet/get_structure_damage()
	var/distance = get_dist(loc, starting)
	return ..() * get_pellets(distance)

/obj/item/projectile/bullet/pellet/Move()
	. = ..()

	//If this is a shrapnel explosion, allow mobs that are prone to get hit, too
	if(. && !base_spread && isturf(loc))
		for(var/mob/living/M in loc)
			if(M.lying || !M.CanPass(src, loc, 0.5, 0)) //Bump if lying or if we would normally Bump.
				if(Bump(M)) //Bump will make sure we don't hit a mob multiple times
					return

/* short-casing projectiles, like the kind used in pistols or SMGs */

/obj/item/projectile/bullet/pistol
	damage = 27.5 //9mm, .38, etc
	poisedamage = 5.0

/obj/item/projectile/bullet/pistol/medium
	damage = 30 //.45
	poisedamage = 7.5

/obj/item/projectile/bullet/pistol/medium/smg
	damage = 32.5 //10mm
	poisedamage = 6.0

/obj/item/projectile/bullet/pistol/medium/revolver
	fire_sound = 'sound/effects/weapons/gun/fire_revolver44.ogg'
	damage = 37.5 //.44 magnum or something
	armor_penetration = 20
	poisedamage = 12.5

/obj/item/projectile/bullet/pistol/strong //matebas
	fire_sound = 'sound/effects/weapons/gun/fire_mateba.ogg'
	damage = 60 //.50AE
	armor_penetration = 50
	poisedamage = 20.0

/obj/item/projectile/bullet/pistol/strong/revolver //revolvers
	damage = 50 //Revolvers get snowflake bullets, to keep them relevant
	armor_penetration = 30
	poisedamage = 20.0

// for rapid-fire mode (lawgiver)
/obj/item/projectile/bullet/pistol/lawgiver
	damage = 18.5
	armor_penetration = 10
	fire_sound = 'sound/effects/weapons/gun/fire1.ogg'
	poisedamage = 3.0

/obj/item/projectile/bullet/pistol/rubber //"rubber" bullets
	name = "rubber bullet"
	check_armour = "melee"
	damage = 5
	agony = 30
	embed = 0
	sharp = 0
	penetration_modifier = 0.2
	poisedamage = 10.0

/obj/item/projectile/bullet/pistol/rubber/c44
	name = "rubber bullet"
	check_armour = "melee"
	damage = 5
	agony = 35
	embed = 0
	sharp = 0
	fire_sound = 'sound/effects/weapons/gun/fire_revolver44.ogg'
	poisedamage = 13.5

/obj/item/projectile/bullet/pistol/accelerated/c38
	name = "accelerated bullet"
	damage = 35.0 // .38 + gauss
	armor_penetration = 50
	fire_sound = 'sound/effects/weapons/gun/fire_revolver44.ogg' // Gauss .38 should sound like a badass
	poisedamage = 12.5


/* shotgun projectiles */

/obj/item/projectile/bullet/shotgun
	name = "slug"
	damage = 60
	armor_penetration = 30
	poisedamage = 20.0

/obj/item/projectile/bullet/shotgun/beanbag		//because beanbags are not bullets
	name = "beanbag"
	check_armour = "melee"
	damage = 25
	agony = 60
	embed = 0
	sharp = 0
	penetration_modifier = 0.2
	can_ricochet = FALSE // Too soft
	poisedamage = 20.0

//Should do about 80 damage at 1 tile distance (adjacent), and 50 damage at 3 tiles distance.
//Overall less damage than slugs in exchange for more damage at very close range and more embedding
/obj/item/projectile/bullet/pellet/shotgun
	name = "shrapnel"
	damage = 20
	pellets = 6
	range_step = 1
	spread_step = 10
	penetration_modifier = 1.2 // A bit more internal damage since we don't have armor penetration anyway
	poisedamage = 12.5

/obj/item/projectile/bullet/pellet/scattershot // Used by *heavy* shotguns, i.e. LBX AC 10 "Scattershot"
	name = "shrapnel"
	damage = 35
	armor_penetration = 30
	pellets = 5
	range_step = 2
	spread_step = 15
	penetration_modifier = 1.2
	poisedamage = 17.5

/obj/item/projectile/bullet/pellet/accelerated
	name = "accelerated particles"
	icon_state = "accel"
	embed = FALSE // Unstable particles just disappear
	can_ricochet = FALSE // Too unstable to survive ricocheting
	damage = 22.5
	armor_penetration = 15
	pellets = 5
	range_step = 3
	spread_step = 5
	penetration_modifier = 1.1
	muzzle_type = /obj/effect/projectile/muzzle/accel
	poisedamage = 15.0

/obj/item/projectile/bullet/pellet/accelerated/lesser
	damage = 20
	poisedamage = 12.5

/* "Rifle" rounds */

/obj/item/projectile/bullet/rifle
	armor_penetration = 40
	penetrating = 1
	poisedamage = 7.0

/obj/item/projectile/bullet/rifle/a556
	damage = 27.5

/obj/item/projectile/bullet/rifle/a762
	damage = 35
	armor_penetration = 50

/obj/item/projectile/bullet/rifle/a792
	damage = 50
	armor_penetration = 50

/obj/item/projectile/bullet/rifle/a145
	damage = 80
	stun = 3
	weaken = 3
	penetrating = 5
	armor_penetration = 125
	hitscan = 1 //so the PTR isn't useless as a sniper weapon
	penetration_modifier = 1.25
	poisedamage = 125.0 //you can't withstand a knuckle-sized chunk of metal with borderline escape velocity

/obj/item/projectile/bullet/rifle/a145/apds
	damage = 75
	penetrating = 6
	armor_penetration = 175
	penetration_modifier = 1.5

/* Miscellaneous */

/obj/item/projectile/bullet/suffocationbullet//How does this even work?
	name = "co bullet"
	damage = 25
	damage_type = OXY

/obj/item/projectile/bullet/cyanideround
	name = "poison bullet"
	damage = 45
	damage_type = TOX

/obj/item/projectile/bullet/burstbullet
	name = "exploding bullet"
	damage = 25
	embed = 0
	edge = 1

/obj/item/projectile/bullet/gyro/Initialize()
	. = ..()

	fire_sound = GET_SFX(SFX_EXPLOSION)

/obj/item/projectile/bullet/gyro/on_hit(atom/target, blocked = 0)
	if(isturf(target))
		explosion(target, -1, 0, 2)
	..()

/obj/item/projectile/bullet/blank
	invisibility = 101
	damage = 1
	embed = 0

/* Practice */

/obj/item/projectile/bullet/pistol/practice
	damage = 5
	poisedamage = 3.0

/obj/item/projectile/bullet/rifle/a762/practice
	damage = 5
	poisedamage = 3.0

/obj/item/projectile/bullet/shotgun/practice
	name = "practice"
	damage = 5
	poisedamage = 3.0

/obj/item/projectile/bullet/pistol/cap
	name = "cap"
	invisibility = 101
	fire_sound = null
	damage_type = PAIN
	damage = 0
	nodamage = 1
	embed = 0
	sharp = 0
	poisedamage = 0.0

/obj/item/projectile/bullet/pistol/cap/Process()
	loc = null
	qdel(src)

/obj/item/projectile/bullet/rock //spess dust
	name = "micrometeor"
	icon_state = "rock"
	damage = 40
	armor_penetration = 50
	kill_count = 255
	poisedamage = 255 // SLAM JAM

/obj/item/projectile/bullet/rock/New()
	icon_state = "rock[rand(1,3)]"
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	..()
