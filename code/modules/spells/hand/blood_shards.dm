/datum/spell/hand/blood_shard
	name = "Blood Shards"
	desc = "Invoke a corrupted projectile forward that causes an enemy's blood to fly out in painful shards. Be sure to upgrade it, as it is free."
	spell_flags = 0
	charge_max = 130
	cooldown_reduc = 30
	invocation = "opens their hand, which bursts into vicious red light."
	invocation_type = SPI_EMOTE
	level_max = list(SP_TOTAL = 3, SP_SPEED = 2, SP_POWER = 2)
	range = 7
	spell_delay = 30
	compatible_targets = list(/atom)
	icon_state = "wiz_bshard"
	var/hit_projectile = /obj/item/projectile/bullet/pellet/blood
	var/required_blood = 30

/datum/spell/hand/blood_shard/empower_spell()
	if(!..())
		return FALSE
	switch(spell_levels[SP_POWER])
		if(1)
			hit_projectile = /obj/item/projectile/bullet/pellet/blood/power_one
			required_blood = 45
			return "[src] now cause more damage and cannot be blocked."
		if(2)
			hit_projectile = /obj/item/projectile/bullet/pellet/blood/power_two
			required_blood = 60
			return "Now bloody fragments cause even more damage and restore blood when they hit you."
	return FALSE

/datum/spell/hand/blood_shard/cast_hand(atom/A, mob/user)
	var/obj/item/projectile/blood_shard/B = new(get_turf(user))
	B.firer = user
	B.launch(A, BP_CHEST)
	user.visible_message(SPAN_DANGER("\The [user] shoots out a deep red shard from their hand!"))

/obj/item/projectile/blood_shard/on_hit(atom/movable/target, blocked = 0)
	if(..())
		if(istype(target, /mob/living/carbon/human))
			if(!firer.mind)
				return
			for(var/datum/spell/S in firer.mind.learned_spells)
				if(istype(S, /datum/spell/hand/blood_shard))
					var/datum/spell/hand/blood_shard/B = S
					var/mob/living/carbon/human/H = target
					if(H.vessel.has_reagent(/datum/reagent/blood, B.required_blood))
						H.vessel.remove_reagent(/datum/reagent/blood, B.required_blood)
						H.visible_message(SPAN_DANGER("Tiny red shards burst from \the [H]'s skin!"))
						blood_fragmentate(target, 30, 5, B.hit_projectile)
					break


/obj/proc/blood_fragmentate(mob/living/carbon/target, fragment_number = 30, spreading_range = 5, fragment_type)
	var/turf/T=get_turf(target)
	var/list/target_turfs = getcircle(T, spreading_range)
	var/fragments_per_projectile = round(fragment_number/target_turfs.len)
	var/datum/species/target_species = target.species

	for(var/turf/O in target_turfs)
		sleep(0)
		var/obj/item/projectile/bullet/pellet/blood/P = new fragment_type(T)
		P.color = target_species.blood_color
		P.pellets = fragments_per_projectile
		P.firer = target
		P.launch(O)

/obj/item/projectile/blood_shard
	name = "blood2"
	damage = 4
	color = COLOR_BLOOD_HUMAN
	check_armour = "melee"
	icon_state = "blood"
	damage_type = BRUTE

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
		var/mob/living/carbon/human/H = target_mob
		if(H.mind && GLOB.wizards.is_antagonist(H.mind))
			H.vessel.add_reagent(/datum/reagent/blood, 4)
			return FALSE
	. = ..()
