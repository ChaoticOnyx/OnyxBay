/mob/living/simple_animal/hostile/slug
	name = "slug"
	desc = "A slug. This looks disgusting."
	icon = 'icons/mob/animal.dmi'
	icon_state = "worm"
	icon_living = "worm"
	icon_dead = "worm_dead"
	var/icon_rest = "worm_rest"
	speak_emote = list("brays")
	mob_size = MOB_MEDIUM
	faction = "event"
	attack_sound = 'sound/weapons/bite.ogg'

	universal_speak = 1
	universal_understand = 1

	stammering = TRUE
	burrieng = TRUE
	lisping = TRUE

	health = 120
	maxHealth = 120
	melee_damage_lower = 8
	melee_damage_upper = 16
	attacktext = "nibbles"
	bodyparts = /decl/simple_animal_bodyparts/worm

	var/list/wizardy_spells = list(/datum/spell/toggled/transform, /datum/spell/toggled/thermal, /datum/spell/toggled/sting_paralize)


/mob/living/simple_animal/hostile/slug/wearing_wiz_garb()
	return 1

/mob/living/simple_animal/hostile/slug/New()
	..()
	verbs += /mob/living/proc/ventcrawl
	for(var/spell in wizardy_spells)
		src.add_spell(new spell, "const_spell_ready")

/mob/living/simple_animal/hostile/slug/adjustBruteLoss(obj/item/O, mob/user)
	..()
	var/datum/spell/toggled/transform/T = src.ability_master.get_ability_by_spell_name("False form")
	if(T)
		T.off()

/mob/living/simple_animal/hostile/slug/UnarmedAttack(atom/A, proximity)
	..()
	var/datum/spell/toggled/transform/T = src.ability_master.get_ability_by_spell_name("False form")
	if(T && ismob(A))
		T.off()

/mob/living/simple_animal/hostile/slug/restrained()
	return 0

/mob/living/simple_animal/hostile/slug/worm
	name = "worm"
	desc = "A worm. This looks very disgusting."
	icon = 'icons/mob/phoron_worm.dmi'
	icon_state = "worm"
	icon_living = "worm"
	icon_dead = "worm_dead"

	health = 240
	maxHealth = 240
	melee_damage_lower = 16
	melee_damage_upper = 22
	wizardy_spells = list(/datum/spell/targeted/pumping_out_blood, /datum/spell/toggled/thermal, /datum/spell/targeted/heal_slug, /datum/spell/aoe_turf/conjure/slug)

/mob/living/simple_animal/hostile/asteroid/dweller
	name = "dweller"
	desc = "A flying serpent resembling an eel, covered in thick but elastic skin that absorbs energy. A huge crystal instead of an eye emits sparks when the animal is nervous."
	icon_state = "dweller"
	icon_living = "dweller"
	icon_aggro = "dweller_alert"
	icon_dead = "dweller_dead"
	icon = 'icons/mob/animal.dmi'
	faction = "event"
	vision_range = 6
	turns_per_move = 3
	move_to_delay = 4
	projectiletype = /obj/item/projectile/energy/neurotoxin/shockzard
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = 1
	retreat_distance = 3
	minimum_distance = 4
	ranged_message = "emits energy"
	ranged_cooldown_cap = 20
	throw_message = "does nothing against the hard shell of"
	speed = 3
	maxHealth = 75
	health = 75
	harm_intent_damage = 5
	melee_damage_lower = 12
	melee_damage_upper = 12
	attacktext = "bites into"
	a_intent = "harm"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	bodyparts = /decl/simple_animal_bodyparts/quadruped
	ranged_cooldown_cap = 4
	aggro_vision_range = 7
	idle_vision_range = 7
	var/loot = /obj/item/stack/telecrystal/time_bluespace_crystal

/mob/living/simple_animal/hostile/asteroid/dweller/abomination
	name = "abomination"
	desc = "A flying serpent resembling an eel, covered in thick but elastic skin that absorbs energy. A huge crystal instead of an eye emits sparks when the animal is nervous."
	icon_state = "abomination"
	icon_living = "abomination"
	icon_aggro = "abomination"
	icon_dead = "abomination_dead"
	icon = 'icons/mob/animal.dmi'
	faction = "event"
	vision_range = 6
	turns_per_move = 5
	move_to_delay = 4
	projectiletype = /obj/item/projectile/bullet/needle
	ranged_message = "spits out the needle"
	attack_sound = 'sound/weapons/bite.ogg'
	loot = null

/mob/living/simple_animal/hostile/asteroid/dweller/death(gibbed, deathmessage, show_dead_message)
	. = ..()
	if(.)
		new loot(src.loc)

/mob/living/simple_animal/hostile/carp/alt
	icon_state = "carp_alt"
	icon_living = "carp_alt"
	icon_dead = "carp_alt_dead"
	icon_gib = "carp_alt_gib"
	faction = "event"
	maxHealth = 45
	health = 45

/mob/living/simple_animal/hostile/carp/shark
	name = "space shark"
	desc = "Too healthy for an ordinary space carp. Be careful with your teeth."
	icon_state = "shark"
	icon_living = "shark"
	icon_dead = "shark_dead"
	icon_gib = "shark_gib"
	maxHealth = 75
	health = 75
	faction = "event"
	move_to_delay = 2
	harm_intent_damage = 8
	melee_damage_lower = 12
	melee_damage_upper = 18

/mob/living/simple_animal/hostile/asteroid/sand_lurker/lesser_ling
	name = "croaking creature"
	desc = "A small creature with long hairy stings on its back and the same paws under its belly. Somewhat reminiscent of a spider and a yard dog."
	icon_state = "lesser_ling"
	icon_living = "lesser_ling"
	icon_aggro = "lesser_ling"
	icon_dead = "lesser_ling_dead"
	icon_gib = "syndicate_gib"
	attack_sound = 'sound/weapons/bite.ogg'
	maxHealth = 45
	health = 45
	move_to_delay = 2
	turns_per_move = 3
	faction = "event"
	bodyparts = /decl/simple_animal_bodyparts/spider
	harm_intent_damage = 15
	melee_damage_lower = 6
	melee_damage_upper = 8
	speed = 4
	vision_range = 7
	aggro_vision_range = 7
	idle_vision_range = 7
