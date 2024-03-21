/obj/item/projectile/beam
	name = "laser"
	icon_state = "laser"
	fire_sound = 'sound/effects/weapons/energy/fire8.ogg'
	pass_flags = PASS_FLAG_TABLE | PASS_FLAG_GLASS | PASS_FLAG_GRILLE
	damage = 32.5
	damage_type = BURN
	sharp = 1 //concentrated burns
	check_armour = "laser"
	eyeblur = 4
	hitscan = 1
	invisibility = 101	//beam projectiles are invisible as they are rendered by the effect engine
	penetration_modifier = 0.45

	muzzle_type = /obj/effect/projectile/muzzle/laser
	tracer_type = /obj/effect/projectile/tracer/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/item/projectile/beam/practice
	name = "laser"
	icon_state = "laser"
	fire_sound = 'sound/effects/weapons/energy/fire8.ogg'
	pass_flags = PASS_FLAG_TABLE | PASS_FLAG_GLASS | PASS_FLAG_GRILLE
	damage = 2
	damage_type = BURN
	check_armour = "laser"
	eyeblur = 2

/obj/item/projectile/beam/laser
	name = "laser beam"
	icon_state = "laser"
	fire_sound = 'sound/effects/weapons/energy/fire8.ogg'

/obj/item/projectile/beam/laser/small
	name = "small laser beam"
	damage = 20.0
	armor_penetration = 5

	muzzle_type = /obj/effect/projectile/muzzle/laser/small
	tracer_type = /obj/effect/projectile/tracer/laser/small
	impact_type = /obj/effect/projectile/impact/laser/small

/obj/item/projectile/beam/laser/lesser
	damage = 27.5
	armor_penetration = 10

/obj/item/projectile/beam/laser/mid
	icon_state = "laser"
	damage = 35.0
	armor_penetration = 25

/obj/item/projectile/beam/laser/greater
	name = "large laser beam"
	damage = 40.0
	armor_penetration = 45

/obj/item/projectile/beam/laser/heavy
	name = "heavy laser beam"
	icon_state = "heavylaser"
	fire_sound = 'sound/effects/weapons/energy/fire21.ogg'
	damage = 55.0
	armor_penetration = 70

	muzzle_type = /obj/effect/projectile/muzzle/laser/heavy
	tracer_type = /obj/effect/projectile/tracer/laser/heavy
	impact_type = /obj/effect/projectile/impact/laser/heavy


/obj/item/projectile/beam/sniper
	name = "sniper beam"
	icon_state = "xray"
	fire_sound = 'sound/effects/weapons/heavy/fire1.ogg'
	damage = 50
	armor_penetration = 80
	stun = 3
	weaken = 3
	stutter = 3
	penetration_modifier = 1.0

	muzzle_type = /obj/effect/projectile/muzzle/xray
	tracer_type = /obj/effect/projectile/tracer/xray
	impact_type = /obj/effect/projectile/impact/xray

/obj/item/projectile/beam/xray
	name = "x-ray beam"
	icon_state = "xray"
	fire_sound = 'sound/effects/weapons/energy/fire16.ogg'
	damage = 30
	armor_penetration = 40
	penetration_modifier = 0.85

	muzzle_type = /obj/effect/projectile/muzzle/xray
	tracer_type = /obj/effect/projectile/tracer/xray
	impact_type = /obj/effect/projectile/impact/xray

/obj/item/projectile/beam/xray/midlaser
	damage = 30
	armor_penetration = 65

/obj/item/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	fire_sound='sound/effects/weapons/energy/fire26.ogg'
	damage = 15 //lower damage, but fires in bursts
	penetration_modifier = 0.75

	muzzle_type = /obj/effect/projectile/muzzle/pulse
	tracer_type = /obj/effect/projectile/tracer/pulse
	impact_type = /obj/effect/projectile/impact/pulse

/obj/item/projectile/beam/pulse/mid
	damage = 35
	armor_penetration = 50

/obj/item/projectile/beam/pulse/heavy
	damage = 45
	armor_penetration = 80

/obj/item/projectile/beam/pulse/destroy
	name = "destroyer pulse"
	damage = 100 //badmins be badmins I don't give a fuck
	armor_penetration = 100
	penetration_modifier = 100

/obj/item/projectile/beam/pulse/destroy/on_hit(atom/target, blocked = 0)
	if(isturf(target))
		target.ex_act(2)
	..()

/obj/item/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"
	fire_sound = 'sound/effects/weapons/energy/fire10.ogg'
	damage = 0 // The actual damage is computed in /code/modules/power/singularity/emitter.dm

	muzzle_type = /obj/effect/projectile/muzzle/emitter
	tracer_type = /obj/effect/projectile/tracer/emitter
	impact_type = /obj/effect/projectile/impact/emitter

/obj/item/projectile/beam/lasertag
	name = "lasertag beam"
	pass_flags = PASS_FLAG_TABLE | PASS_FLAG_GLASS | PASS_FLAG_GRILLE
	damage = 0
	nodamage = TRUE
	no_attack_log = 1

/obj/item/projectile/beam/lasertag/blue
	icon_state = "bluelaser"

	muzzle_type = /obj/effect/projectile/muzzle/laser/blue
	tracer_type = /obj/effect/projectile/tracer/laser/blue
	impact_type = /obj/effect/projectile/impact/laser/blue

/obj/item/projectile/beam/lasertag/blue/on_hit(atom/target, blocked = 0)
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = target
		if(istype(M.wear_suit, /obj/item/clothing/suit/redtag))
			M.Weaken(5)
			M.Stun(5)
	return 1

/obj/item/projectile/beam/lasertag/red
	icon_state = "laser"

/obj/item/projectile/beam/lasertag/red/on_hit(atom/target, blocked = 0)
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = target
		if(istype(M.wear_suit, /obj/item/clothing/suit/bluetag))
			M.Weaken(5)
			M.Stun(5)
	return 1

/obj/item/projectile/beam/lasertag/omni//A laser tag bolt that stuns EVERYONE
	icon_state = "omnilaser"

	muzzle_type = /obj/effect/projectile/muzzle/laser/omni
	tracer_type = /obj/effect/projectile/tracer/laser/omni
	impact_type = /obj/effect/projectile/impact/laser/omni

/obj/item/projectile/beam/lasertag/omni/on_hit(atom/target, blocked = 0)
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = target
		if((istype(M.wear_suit, /obj/item/clothing/suit/bluetag))||(istype(M.wear_suit, /obj/item/clothing/suit/redtag)))
			M.Weaken(5)
			M.Stun(5)
	return 1

/obj/item/projectile/beam/stun
	name = "stun beam"
	icon_state = "stun"
	fire_sound = 'sound/effects/weapons/energy/fire1.ogg'
	check_armour = "energy"
	damage_type = PAIN
	armor_penetration = 10
	nodamage = TRUE
	sharp = FALSE // not a laser
	damage = 0
	agony = 40
	tasing = 6

	muzzle_type = /obj/effect/projectile/muzzle/stun
	tracer_type = /obj/effect/projectile/tracer/stun
	impact_type = /obj/effect/projectile/impact/stun

/obj/item/projectile/beam/stun/greater
	name = "stun beam"
	agony = 55

/obj/item/projectile/beam/stun/heavy
	name = "heavy stun beam"
	agony = 60

/obj/item/projectile/beam/stun/shock
	name = "shock beam"
	damage_type = ELECTROCUTE
	damage = 10
	agony  = 5
	nodamage = FALSE
	damage_type = STUN
	penetration_modifier = 0.1
	fire_sound='sound/effects/weapons/energy/fire2.ogg'

/obj/item/projectile/beam/stun/shock/heavy
	name = "heavy shock beam"
	damage = 20
	agony  = 10

/obj/item/projectile/beam/plasmacutter
	name = "plasma arc"
	icon_state = "omnilaser"
	fire_sound = 'sound/effects/weapons/energy/fire3.ogg'
	damage = 7
	sharp = 1
	edge = 1
	damage_type = BRUTE
	check_armour = "laser"
	kill_count = 5
	pass_flags = PASS_FLAG_TABLE

	muzzle_type = /obj/effect/projectile/muzzle/trilaser
	tracer_type = /obj/effect/projectile/tracer/trilaser
	impact_type = /obj/effect/projectile/impact/trilaser

/obj/item/projectile/beam/plasmacutter/on_impact(atom/A)
	if(istype(A, /turf/simulated/mineral))
		var/turf/simulated/mineral/M = A
		if(prob(99))
			M.GetDrilled(1)
			return
		else
			M.durability -= 60
	. = ..()

/obj/item/projectile/beam/plasmacutter/danger
	name = "plasma arc"
	icon_state = "omnilaser"
	fire_sound = 'sound/effects/weapons/energy/fire3.ogg'
	damage = 25
	sharp = 1
	edge = 1
	damage_type = BRUTE
	check_armour = "laser"
	kill_count = 5
	pass_flags = PASS_FLAG_TABLE
	armor_penetration = 50
	muzzle_type = /obj/effect/projectile/muzzle/trilaser
	tracer_type = /obj/effect/projectile/tracer/trilaser
	impact_type = /obj/effect/projectile/impact/trilaser
