////////////////Basic shooter (reworked basilisk)////////////////

/mob/living/simple_animal/hostile/asteroid/shooter
	name = "shockzard"
	desc = "A territorial reptile-like beast, covered in a thick shell that absorbs energy. A huge crystal on its long tail emits some sparks when the beast is nervous."
	icon = 'icons/mob/asteroid/basilisk.dmi'
	icon_state = "Basilisk"
	icon_living = "Basilisk"
	icon_aggro = "Basilisk_alert"
	icon_dead = "Basilisk_dead"
	icon_gib = "syndicate_gib"
	move_to_delay = 20
	projectiletype = /obj/item/projectile/temp/basilisk
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = 1
	ranged_message = "emits energy"
	ranged_cooldown_cap = 20
	throw_message = "does nothing against the hard shell of"
	vision_range = 2
	speed = 3
	maxHealth = 75
	health = 75
	harm_intent_damage = 5
	melee_damage_lower = 12
	melee_damage_upper = 12
	attacktext = "bites into"
	a_intent = "harm"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	ranged_cooldown_cap = 4
	aggro_vision_range = 7
	idle_vision_range = 2

/obj/item/projectile/energy/neurotoxin/shockzard
	name = "energy blast"
	icon_state = "ice_2"
	fire_sound = 'sound/weapons/pulse3.ogg'
	damage = 5
	damage_type = BURN
	nodamage = 0
	check_armour = "energy"
	weaken=5
	
/mob/living/simple_animal/hostile/asteroid/shooter/GiveTarget(new_target)
	target_mob = new_target
	if(target_mob != null)
		Aggro()
		stance = HOSTILE_STANCE_ATTACK
	return

/mob/living/simple_animal/hostile/asteroid/shooter/ex_act(severity, target_mob)
	switch(severity)
		if(1.0)
			gib()
		if(2.0)
			adjustBruteLoss(140)
		if(3.0)
			adjustBruteLoss(110)

/mob/living/simple_animal/hostile/asteroid/shooter/death(gibbed)
	var/counter
	for(counter=0, counter<2, counter++)
		var/obj/item/weapon/ore/diamond/D = new /obj/item/weapon/ore/diamond(src.loc)
		D.layer = 4.1
	..(gibbed)



////////////////Beholder (formerly known as spectator)////////////////

/mob/living/simple_animal/hostile/asteroid/shooter/beholder
	name = "beholder"
	desc = "Floating orb of flesh with a large creepy mouth, hateful single central eye, and many smaller flexible eyestalks on top. It looks kinda ancient."
	icon = 'icons/mob/asteroid/spectator.dmi'
	icon_state = "Spectator"
	icon_living = "Spectator"
	icon_aggro = "Spectator_alert"
	icon_dead = "Spectator_dead"
	vision_range = 5
	speed = 4
	maxHealth = 250
	health = 250
	ranged_message = "stares cruelly"
	ranged_cooldown_cap = 3
	harm_intent_damage = 15
	melee_damage_lower = 22
	melee_damage_upper = 22
	attacktext = "gnaws and mauls"
	aggro_vision_range = 9
	idle_vision_range = 5
	var/list/projectiletypes = list(/obj/item/projectile/beam/mindflayer,
									/obj/item/projectile/energy/neurotoxin/shockzard,
									/obj/item/projectile/ion/small,
									/obj/item/projectile/energy/plasmastun,
									/obj/item/projectile/energy/declone,
									/obj/item/projectile/energy/dart,
									/obj/item/projectile/energy/neurotoxin,
									/obj/item/projectile/energy/phoron,
									/obj/item/projectile/energy/electrode,
									/obj/item/projectile/energy/flash,
									/obj/item/projectile/energy/flash/flare,
									/obj/item/projectile/beam/plasmacutter,
									/obj/item/projectile/forcebolt,
									/obj/item/projectile/animate)

/mob/living/simple_animal/hostile/asteroid/shooter/beholder/OpenFire()
	. = ..()
	projectiletype = pick(projectiletypes)

/mob/living/simple_animal/hostile/asteroid/shooter/beholder/GiveTarget(new_target)
	target_mob = new_target
	if(target_mob != null)
		Aggro()
		stance = HOSTILE_STANCE_ATTACK
		if(isliving(target_mob))
			var/mob/living/L = target_mob
			if(L.bodytemperature > 258)
				L.bodytemperature = 258
				visible_message("<span class='danger'>The [src.name]'s evil stare chills [L.name] to the bone!</span>")
	return
