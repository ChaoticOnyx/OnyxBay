/obj/item/projectile/energy
	name = "energy"
	icon_state = "spark"
	damage = 0
	damage_type = BURN
	check_armour = "energy"


//releases a burst of light on impact or after travelling a distance
/obj/item/projectile/energy/flash
	name = "chemical shell"
	icon_state = "bullet"
	fire_sound = 'sound/effects/weapons/gun/fire_generic_pistol.ogg'
	damage = 5
	agony = 20
	kill_count = 15 //if the shell hasn't hit anything after travelling this far it just explodes.
	muzzle_type = /obj/effect/projectile/bullet/muzzle
	var/flash_range = 1
	var/brightness = 7
	var/light_colour = "#ffffff"

/obj/item/projectile/energy/flash/on_impact(atom/A)
	var/turf/T = flash_range? src.loc : get_turf(A)
	if(!istype(T)) return

	//blind and confuse adjacent people
	for (var/mob/living/carbon/M in viewers(T, flash_range))
		if(M.eyecheck() < FLASH_PROTECTION_MODERATE)
			M.flash_eyes()
			M.eye_blurry += (brightness / 2)
			M.confused += (brightness / 2)

	//snap pop
	playsound(src, 'sound/effects/snap.ogg', 50, 1)
	src.visible_message("<span class='warning'>\The [src] explodes in a bright flash!</span>")

	var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
	sparks.set_up(2, 1, T)
	sparks.start()

	new /obj/effect/decal/cleanable/ash(src.loc) //always use src.loc so that ash doesn't end up inside windows
	new /obj/effect/effect/smoke/illumination(T, 5, brightness, brightness, light_colour)

//blinds people like the flash round, but in a larger area and can also be used for temporary illumination
/obj/item/projectile/energy/flash/flare
	damage = 10
	agony = 25
	fire_sound = 'sound/effects/weapons/gun/fire_shotgun.ogg'
	flash_range = 2
	brightness = 15

/obj/item/projectile/energy/flash/flare/on_impact(atom/A)
	light_colour = pick("#e58775", "#ffffff", "#90ff90", "#a09030")

	..() //initial flash

	//residual illumination
	new /obj/effect/effect/smoke/illumination(src.loc, rand(190,240) SECONDS, range=8, power=3, color=light_colour) //same lighting power as flare

/obj/item/projectile/energy/flash/c38
	damage_type = BURN
	damage = 5
	agony = 25
	icon_state = "bullet"
	fire_sound = 'sound/effects/weapons/gun/fire_shotgun.ogg'
	flash_range = 1
	brightness = 10

//////////////////////////////////////////////////////

/obj/item/projectile/energy/electrode
	name = "electrode"
	icon_state = "electrode"
	fire_sound = 'sound/effects/weapons/energy/Taser.ogg'
	nodamage = TRUE
	agony = 65
	tasing = 6
	damage_type = PAIN
	armor_penetration = 10
	//Damage will be handled on the MOB side, to prevent window shattering.
	projectile_light = TRUE
	projectile_brightness_color = COLOR_YELLOW

/obj/item/projectile/energy/electrode/small
	icon_state = "electrode-small"
	agony = 37.5

/obj/item/projectile/energy/electrode/greater
	agony = 85

/obj/item/projectile/energy/electrode/heavy
	icon_state = "electrode-heavy"
	agony = 100
	tasing = 8
	armor_penetration = 15
	hitscan = TRUE

/obj/item/projectile/energy/electrode/stunshot
	nodamage = FALSE
	damage = 15
	agony = 70
	damage_type = BURN
	armor_penetration = 10
	penetration_modifier = 0.2

/obj/item/projectile/energy/electrode/stunsphere
	damage_type = PAIN
	icon_state = "spark"
	agony = 70
	stutter = 10
	armor_penetration = 10

/obj/item/projectile/energy/electrode/c45
	name = "stun bullet"
	icon_state = "stunbullet"
	nodamage = FALSE
	agony = 40 // Weaker than the stunsphere la'classique
	damage_type = BURN
	damage = 3 //A little ouchie.
	armor_penetration = 10
	fire_sound = 'sound/effects/weapons/gun/gunshot.ogg'
	projectile_inner_range = 0.2

/obj/item/projectile/energy/electrode/c38
	name = "shock bullet"
	icon_state = "shockbullet"
	nodamage = FALSE
	agony = 60
	damage_type = BRUTE
	damage = 5 //It's still a bullet
	armor_penetration = 10
	fire_sound = 'sound/effects/weapons/gun/fire_revolver44.ogg'
	projectile_inner_range = 0.2

/obj/item/projectile/energy/c38
	name = "overheated bullet"
	icon_state = "heatbullet"
	damage = 40
	agony = 20
	eyeblur = 4
	damage_type = BURN
	armor_penetration = 15
	fire_sound = 'sound/effects/weapons/gun/fire_revolver44.ogg'
	projectile_light = TRUE
	projectile_brightness_color = "#ff8c3f"
	projectile_inner_range = 0.2
	projectile_outer_range = 1.25

/obj/item/projectile/energy/declone
	name = "decloner beam"
	icon_state = "declone"
	fire_sound = 'sound/effects/weapons/energy/pulse3.ogg'
	damage = 30
	damage_type = CLONE
	irradiate = 40
	projectile_light = TRUE
	projectile_brightness_color = COLOR_LIME


/obj/item/projectile/energy/dart
	name = "dart"
	icon_state = "toxin"
	damage = 5
	damage_type = TOX
	weaken = 5


/obj/item/projectile/energy/bolt
	name = "bolt"
	icon_state = "cbbolt"
	damage = 10
	damage_type = TOX
	nodamage = 0
	agony = 40
	stutter = 10


/obj/item/projectile/energy/bolt/large
	name = "largebolt"
	damage = 20
	agony = 60


/obj/item/projectile/energy/neurotoxin
	name = "neuro"
	icon_state = "neurotoxin"
	damage = 5
	damage_type = TOX
	weaken = 5

/obj/item/projectile/energy/acid //Slightly up-gunned (Read: The thing does agony and checks bio resist) variant of the simple alien mob's projectile, for queens and sentinels.
	name = "acidic spit"
	icon_state = "neurotoxin"
	damage = 45
	damage_type = BURN
	agony = 15
	check_armour = "bio"
	armor_penetration = 25	// It's acid

/obj/item/projectile/energy/plasma
	name = "plasma bolt"
	icon_state = "energy"
	fire_sound = 'sound/effects/stealthoff.ogg'
	damage = 20
	damage_type = TOX
	irradiate = 20

/obj/item/projectile/energy/plasmastun
	name = "plasma pulse"
	icon_state = "plasma_stun"
	fire_sound = 'sound/effects/weapons/energy/blaster.ogg'
	armor_penetration = 10
	kill_count = 4
	damage = 5
	agony = 70
	damage_type = BURN
	vacuum_traversal = 0

/obj/item/projectile/energy/plasmastun/proc/bang(mob/living/carbon/M)

	to_chat(M, "<span class='danger'>You hear a loud roar.</span>")
	var/ear_safety = 0
	if(iscarbon(M))
		if(ishuman(M))
			ear_safety = M.get_ear_protection()
	if(ear_safety == 1)
		M.make_dizzy(120)
	else if (ear_safety > 1)
		M.make_dizzy(60)
	else if (!ear_safety)
		M.make_dizzy(300)
		M.ear_damage += rand(1, 10)
		M.ear_deaf = max(M.ear_deaf,15)
	if (M.ear_damage >= 15)
		to_chat(M, "<span class='danger'>Your ears start to ring badly!</span>")
		if (prob(M.ear_damage - 5))
			to_chat(M, "<span class='danger'>You can't hear anything!</span>")
			M.sdisabilities |= DEAF
	else
		if (M.ear_damage >= 5)
			to_chat(M, "<span class='danger'>Your ears start to ring!</span>")
	M.update_icons()

/obj/item/projectile/energy/plasmastun/on_hit(atom/target)
	bang(target)
	. = ..()
