/obj/item/melee/cultblade
	name = "cult blade"
	desc = "An arcane weapon wielded by the followers of Nar-Sie."
	icon_state = "cultblade"
	item_state = "cultblade"
	edge = 1
	sharp = 1
	w_class = ITEM_SIZE_LARGE
	force = 30
	mod_weight = 1.4
	mod_reach = 1.4
	mod_handy = 1.15
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/melee/cultblade/attack(mob/living/M, mob/living/user, target_zone)
	if(iscultist(user) || (user.mind in GLOB.godcult.current_antagonists))
		return ..()

	var/zone = (user.hand ? BP_L_ARM : BP_R_ARM)

	var/obj/item/organ/external/affecting = null
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		affecting = H.get_organ(zone)

	if(affecting)
		to_chat(user, "<span class='danger'>An unexplicable force rips through your [affecting.name], tearing the sword from your grasp!</span>")
	else
		to_chat(user, "<span class='danger'>An unexplicable force rips through you, tearing the sword from your grasp!</span>")

	//random amount of damage between half of the blade's force and the full force of the blade.
	user.apply_damage(rand(force/2, force), BRUTE, zone, 0, (DAM_SHARP|DAM_EDGE))
	user.Weaken(5)
	user.Stun(3)

	user.drop(src, force = TRUE)
	throw_at(get_edge_target_turf(src, pick(GLOB.alldirs)), rand(1, 3))

	var/spooky = pick('sound/hallucinations/growl1.ogg', 'sound/hallucinations/growl2.ogg', 'sound/hallucinations/growl3.ogg', 'sound/hallucinations/wail.ogg')
	playsound(loc, spooky, 50, 1)

	return 1

/obj/item/melee/cultblade/pickup(mob/living/user as mob)
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>An overwhelming feeling of dread comes over you as you pick up the cultist's sword. It would be wise to be rid of this blade quickly.</span>")
		user.make_dizzy(120)


/obj/item/clothing/head/culthood
	name = "cult hood"
	icon_state = "culthood"
	desc = "A hood worn by the followers of Nar-Sie."
	flags_inv = HIDEFACE
	body_parts_covered = HEAD
	armor_type = /datum/armor/culthood
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.8 //That's a pretty cool opening in the hood. Also: Cloth making physical contact to the skull.

/datum/armor/culthood
	bullet = 10
	energy = 5
	laser = 5
	melee = 30

/obj/item/clothing/head/culthood/magus
	name = "magus helm"
	icon_state = "magus"
	desc = "A helm worn by the followers of Nar-Sie."
	flags_inv = HIDEFACE | BLOCKHAIR
	body_parts_covered = HEAD|FACE|EYES
	armor_type = /datum/armor/magushelm

/datum/armor/magushelm
	bomb = 15
	bullet = 40
	energy = 20
	laser = 30
	melee = 50

/obj/item/clothing/head/culthood/alt
	icon_state = "cult_hoodalt"

/obj/item/clothing/suit/cultrobes
	name = "cult robes"
	desc = "A set of durable robes worn by the followers of Nar-Sie."
	icon_state = "cultrobes"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/book/tome,/obj/item/melee/cultblade)
	armor_type = /datum/armor/cultrobes
	flags_inv = HIDEJUMPSUIT
	siemens_coefficient = 0.6

/datum/armor/cultrobes
	bio = 10
	bomb = 25
	bullet = 30
	energy = 20
	laser = 25
	melee = 35

/obj/item/clothing/suit/cultrobes/alt
	icon_state = "cultrobesalt"

/obj/item/clothing/suit/cultrobes/magusred
	name = "magus robes"
	desc = "A set of plated robes worn by the followers of Nar-Sie."
	icon_state = "magusred"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	armor_type = /datum/armor/magusrobes

/datum/armor/magusrobes
	bio = 10
	bomb = 50
	bullet = 50
	energy = 40
	laser = 55
	melee = 75

/obj/item/clothing/suit/cultrobes/magusred/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 1

/obj/item/clothing/head/helmet/space/cult
	name = "cult helmet"
	desc = "A space worthy helmet used by the followers of Nar-Sie."
	icon_state = "cult_helmet"
	armor_type = /datum/armor/culthelm
	siemens_coefficient = 0.3 //Bone is not very conducive to electricity.
	rad_resist = list(
		RADIATION_ALPHA_PARTICLE = 1.0,
		RADIATION_BETA_PARTICLE = 1.0,
		RADIATION_HAWKING = 1 ELECTRONVOLT
	)

/datum/armor/culthelm
	bio = 100
	bomb = 30
	bullet = 60
	energy = 15
	laser = 60
	melee = 60

/obj/item/clothing/suit/space/cult
	name = "cult armour"
	icon_state = "cult_armour"
	desc = "A bulky suit of armour, bristling with spikes. It looks space proof."
	allowed = list(/obj/item/book/tome,/obj/item/melee/cultblade,/obj/item/tank,/obj/item/device/suit_cooling_unit)
	armor_type = /datum/armor/cultarmor
	siemens_coefficient = 0.2
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|HANDS
	rad_resist = list(
		RADIATION_ALPHA_PARTICLE = 1.0,
		RADIATION_BETA_PARTICLE = 1.0,
		RADIATION_HAWKING = 1 ELECTRONVOLT
	)

/datum/armor/cultarmor
	bio = 100
	bomb = 30
	bullet = 50
	energy = 15
	laser = 60
	melee = 60

/obj/item/clothing/suit/space/cult/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 1
