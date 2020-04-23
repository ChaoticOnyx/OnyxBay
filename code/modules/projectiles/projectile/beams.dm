/obj/item/projectile/beam
	name = "laser"
	icon_state = "laser"
	fire_sound = 'sound/effects/weapons/energy/fire8.ogg'
	pass_flags = PASS_FLAG_TABLE | PASS_FLAG_GLASS | PASS_FLAG_GRILLE
	damage = 40
	damage_type = BURN
	sharp = 1 //concentrated burns
	check_armour = "laser"
	eyeblur = 4
	hitscan = 1
	invisibility = 101	//beam projectiles are invisible as they are rendered by the effect engine

	muzzle_type = /obj/effect/projectile/laser/muzzle
	tracer_type = /obj/effect/projectile/laser/tracer
	impact_type = /obj/effect/projectile/laser/impact

/obj/item/projectile/beam/practice
	name = "laser"
	icon_state = "laser"
	fire_sound = 'sound/effects/weapons/energy/fire8.ogg'
	pass_flags = PASS_FLAG_TABLE | PASS_FLAG_GLASS | PASS_FLAG_GRILLE
	damage = 2
	damage_type = BURN
	check_armour = "laser"
	eyeblur = 2

/obj/item/projectile/beam/smalllaser
	damage = 25

/obj/item/projectile/beam/midlaser
	damage = 50
	armor_penetration = 10

/obj/item/projectile/beam/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	fire_sound = 'sound/effects/weapons/energy/fire21.ogg'
	damage = 60
	armor_penetration = 30

	muzzle_type = /obj/effect/projectile/laser/heavy/muzzle
	tracer_type = /obj/effect/projectile/laser/heavy/tracer
	impact_type = /obj/effect/projectile/laser/heavy/impact

/obj/item/projectile/beam/xray
	name = "x-ray beam"
	icon_state = "xray"
	fire_sound = 'sound/effects/weapons/energy/fire16.ogg'
	damage = 30
	armor_penetration = 30
	penetration_modifier = 0.8

	muzzle_type = /obj/effect/projectile/laser/xray/muzzle
	tracer_type = /obj/effect/projectile/laser/xray/tracer
	impact_type = /obj/effect/projectile/laser/xray/impact

/obj/item/projectile/beam/xray/midlaser
	damage = 30
	armor_penetration = 65

/obj/item/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	fire_sound='sound/effects/weapons/energy/fire26.ogg'
	damage = 15 //lower damage, but fires in bursts

	muzzle_type = /obj/effect/projectile/laser/pulse/muzzle
	tracer_type = /obj/effect/projectile/laser/pulse/tracer
	impact_type = /obj/effect/projectile/laser/pulse/impact

/obj/item/projectile/beam/pulse/mid
	damage = 35
	armor_penetration = 25

/obj/item/projectile/beam/pulse/heavy
	damage = 45
	armor_penetration = 40

/obj/item/projectile/beam/pulse/destroy
	name = "destroyer pulse"
	damage = 100 //badmins be badmins I don't give a fuck
	armor_penetration = 100

/obj/item/projectile/beam/pulse/destroy/on_hit(atom/target, blocked = 0)
	if(isturf(target))
		target.ex_act(2)
	..()

/obj/item/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"
	fire_sound = 'sound/effects/weapons/energy/fire10.ogg'
	damage = 0 // The actual damage is computed in /code/modules/power/singularity/emitter.dm

	muzzle_type = /obj/effect/projectile/laser/emitter/muzzle
	tracer_type = /obj/effect/projectile/laser/emitter/tracer
	impact_type = /obj/effect/projectile/laser/emitter/impact

/obj/item/projectile/beam/lastertag/blue
	name = "lasertag beam"
	icon_state = "bluelaser"
	pass_flags = PASS_FLAG_TABLE | PASS_FLAG_GLASS | PASS_FLAG_GRILLE
	damage = 0
	no_attack_log = 1
	damage_type = BURN
	check_armour = "laser"

	muzzle_type = /obj/effect/projectile/laser/blue/muzzle
	tracer_type = /obj/effect/projectile/laser/blue/tracer
	impact_type = /obj/effect/projectile/laser/blue/impact

/obj/item/projectile/beam/lastertag/blue/on_hit(atom/target, blocked = 0)
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = target
		if(istype(M.wear_suit, /obj/item/clothing/suit/redtag))
			M.Weaken(5)
	return 1

/obj/item/projectile/beam/lastertag/red
	name = "lasertag beam"
	icon_state = "laser"
	pass_flags = PASS_FLAG_TABLE | PASS_FLAG_GLASS | PASS_FLAG_GRILLE
	damage = 0
	no_attack_log = 1
	damage_type = BURN
	check_armour = "laser"

/obj/item/projectile/beam/lastertag/red/on_hit(atom/target, blocked = 0)
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = target
		if(istype(M.wear_suit, /obj/item/clothing/suit/bluetag))
			M.Weaken(5)
	return 1

/obj/item/projectile/beam/lastertag/omni//A laser tag bolt that stuns EVERYONE
	name = "lasertag beam"
	icon_state = "omnilaser"
	pass_flags = PASS_FLAG_TABLE | PASS_FLAG_GLASS | PASS_FLAG_GRILLE
	damage = 0
	damage_type = BURN
	check_armour = "laser"

	muzzle_type = /obj/effect/projectile/laser/omni/muzzle
	tracer_type = /obj/effect/projectile/laser/omni/tracer
	impact_type = /obj/effect/projectile/laser/omni/impact

/obj/item/projectile/beam/lastertag/omni/on_hit(atom/target, blocked = 0)
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = target
		if((istype(M.wear_suit, /obj/item/clothing/suit/bluetag))||(istype(M.wear_suit, /obj/item/clothing/suit/redtag)))
			M.Weaken(5)
	return 1

/obj/item/projectile/beam/sniper
	name = "sniper beam"
	icon_state = "xray"
	fire_sound = 'sound/effects/weapons/heavy/fire1.ogg'
	damage = 50
	armor_penetration = 10
	stun = 3
	weaken = 3
	stutter = 3

	muzzle_type = /obj/effect/projectile/laser/xray/muzzle
	tracer_type = /obj/effect/projectile/laser/xray/tracer
	impact_type = /obj/effect/projectile/laser/xray/impact

/obj/item/projectile/beam/stun
	name = "stun beam"
	icon_state = "stun"
	fire_sound = 'sound/effects/weapons/energy/fire1.ogg'
	check_armour = "energy"
	sharp = 0 //not a laser
	agony = 40
	tasing = 1
	damage_type = STUN

	muzzle_type = /obj/effect/projectile/stun/muzzle
	tracer_type = /obj/effect/projectile/stun/tracer
	impact_type = /obj/effect/projectile/stun/impact

/obj/item/projectile/beam/stun/heavy
	name = "heavy stun beam"
	agony = 60

/obj/item/projectile/beam/stun/shock
	name = "shock beam"
	damage_type = ELECTROCUTE
	damage = 10
	agony  = 5
	fire_sound='sound/effects/weapons/energy/fire2.ogg'

/obj/item/projectile/beam/stun/shock/heavy
	name = "heavy shock beam"
	damage = 20
	agony  = 10

/obj/item/projectile/beam/plasmacutter
	name = "plasma arc"
	icon_state = "omnilaser"
	fire_sound = 'sound/effects/weapons/energy/fire3.ogg'
	armor_penetration = 10
	damage = 30
	sharp = 1
	edge = 1
	damage_type = BURN
	check_armour = "laser"
	kill_count = 5
	pass_flags = PASS_FLAG_TABLE

	muzzle_type = /obj/effect/projectile/trilaser/muzzle
	tracer_type = /obj/effect/projectile/trilaser/tracer
	impact_type = /obj/effect/projectile/trilaser/impact

/obj/item/projectile/beam/plasmacutter/on_impact(atom/A)
	if(istype(A, /turf/simulated/mineral))
		var/turf/simulated/mineral/M = A
		if(prob(99))
			M.GetDrilled(1)
			return
		else
			M.emitter_blasts_taken += 2
	if(istype(A, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = A
		if(!H.wearing_rig)
			var/obj/item/organ/external/LIMP = H.get_organ(src.def_zone)
			var/block = H.run_armor_check(src.def_zone, src.check_armour, src.armor_penetration)
			var/chance = 33
			if(block > 0)
				chance = round((100 - block) / 3)
			if(prob(chance))
				if (istype(LIMP, /obj/item/organ/external/chest) ||	istype(LIMP, /obj/item/organ/external/groin))
					LIMP.take_external_damage(30, used_weapon = "Plasma arc")
				else
					LIMP.droplimb(0, DROPLIMB_EDGE)
	. = ..()
