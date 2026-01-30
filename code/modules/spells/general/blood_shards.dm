/datum/spell/blood_shard
	name = "Blood Shards"
	desc = "Causes the caster's blood to seep through the skin and scatter in all directions in deadly shards."
	spell_flags = NEEDSHUMAN
	charge_max = 130
	cooldown_reduc = 30
	school = "conjuration"
	invocation = "bursts into vicious blood light."
	invocation_type = SPI_EMOTE
	range = 0
	level_max = list(SP_TOTAL = 3, SP_SPEED = 2, SP_POWER = 2)
	icon_state = "wiz_bshard"

	var/hit_projectile = /obj/item/projectile/bullet/pellet/blood
	var/required_blood = 30

/datum/spell/blood_shard/empower_spell()
	if(!..())
		return FALSE
	switch(spell_levels[SP_POWER])
		if(1)
			hit_projectile = /obj/item/projectile/bullet/pellet/blood/power_one
			required_blood = 45
			return "[src] now requires more of your blood, but deals more damage and can't be blocked."
		if(2)
			hit_projectile = /obj/item/projectile/bullet/pellet/blood/power_two
			required_blood = 60
			return "[src] now requires even more of your blood, and also starts to deal more damage, returning some of the blood when the fragments hit someone."
	return FALSE

/obj/item/projectile/blood_shard
	name = "blood shard"
	damage = 4
	color = COLOR_BLOOD_HUMAN
	check_armour = "melee"
	icon_state = "blood2"
	damage_type = BRUTE
	var/hit_projectile
	var/required_blood

/datum/spell/blood_shard/choose_targets()
	return list(holder)

/datum/spell/blood_shard/cast(list/targets, mob/user, channel_duration)
	var/mob/living/carbon/human/H = targets[1]
	if(!H.vessel.has_reagent(/datum/reagent/blood, required_blood))
		return
	H.vessel.remove_reagent(/datum/reagent/blood, required_blood)
	H.visible_message(SPAN_DANGER("Tiny blood shards burst from \the [H]'s skin!"))
	var/turf/T=get_turf(H)
	var/list/target_turfs = getcircle(T, 5)
	var/fragments_per_projectile = round(30 / target_turfs.len)
	H.Stun(1)
	H.emote("scream")
	playsound(H, 'sound/effects/squelch1.ogg', 100, 1)
	var/atom/movable/fake_overlay/animation = new(T)
	animation.plane = H.plane
	animation.layer = H.layer + 0.01
	animation.icon = 'icons/mob/mob.dmi'
	animation.icon_state = "blank"
	animation.master = H
	animation.color = H.species.blood_color
	animation.set_dir(H.dir)
	flick("bloodshards", animation)
	QDEL_IN(animation, 10)
	sleep(5)
	for(var/turf/O in target_turfs)
		spawn(0)
			var/obj/item/projectile/bullet/pellet/blood/P = new hit_projectile(T)
			P.color = H.species.blood_color
			P.pellets = fragments_per_projectile
			P.firer = H
			P.launch(O)

/obj/item/projectile/bullet/pellet/blood
	name = "blood fragment"
	icon_state = "blood2"
	color = COLOR_BLOOD_HUMAN
	damage = 4
	armor_penetration = 6
	base_spread = 0
	embed = FALSE
	muzzle_type = null
	no_attack_log = TRUE
	can_ricochet = FALSE

/obj/item/projectile/bullet/pellet/blood/power_one
	damage = 8
	armor_penetration = 12
	blockable = FALSE

/obj/item/projectile/bullet/pellet/blood/power_two
	damage = 12
	armor_penetration = 24
	blockable = FALSE

/obj/item/projectile/bullet/pellet/blood/power_two/attack_mob(mob/living/target_mob, distance, miss_modifier)
	if(ishuman(target_mob))
		var/mob/living/carbon/human/H = firer
		H.vessel.add_reagent(/datum/reagent/blood, 2)
	return ..()
