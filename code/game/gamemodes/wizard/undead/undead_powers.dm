/datum/power/undead
	var/owned = FALSE
	var/price

	var/power_item_type = null

/datum/power/undead/proc/activate()
	return

/datum/power/undead/armblade
	name = "Arm Blade"
	desc = "Mutate your hand into a deadly armblade."
	price = 10

	power_item_type = /obj/item/melee/prosthetic/bio/fake_arm_blade/undead_armblade

/obj/item/melee/prosthetic/bio/fake_arm_blade/undead_armblade
	force = 15
	sharp = 1
	edge = 1
	icon_state = "bone_blade"

/datum/power/undead/armblade/activate(mob/living/carbon/human/H)
	var/hand = pick(list(BP_R_HAND, BP_L_HAND))
	var/failed = FALSE
	switch(hand)
		if(BP_R_HAND)
			if(!isProsthetic(H.r_hand))
				H.drop_r_hand()
			else if(!isProsthetic(H.l_hand))
				H.drop_l_hand()
				hand = BP_L_HAND
			else
				failed = TRUE
		if(BP_L_HAND)
			if(!isProsthetic(H.l_hand))
				H.drop_l_hand()
			else if(!isProsthetic(H.r_hand))
				H.drop_r_hand()
				hand = BP_R_HAND
			else
				failed = TRUE

	if(!failed)
		H.visible_message(SPAN_DANGER("The flesh is torn around the [H.name]\'s arm!"))
		new power_item_type(H, H.organs_by_name[hand])

/datum/power/undead/armblade/armshield
	name = "Bone Shield"
	desc = "Mutate your hand into a bone shield."
	price = 10

	power_item_type = /obj/item/melee/prosthetic/bio/fake_arm_blade/undead_shield

/obj/item/melee/prosthetic/bio/fake_arm_blade/undead_shield
	name = "bone shield"
	desc = "A gigantic shield made of interlocked bones."
	icon_state = "bone_shield"
	w_class = ITEM_SIZE_HUGE
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 0, BOMB = 30, BIO = 0, FIRE = 80, ACID = 70)
	mod_weight = 2.0
	mod_reach = 1.5
	mod_handy = 1.5
	mod_shield = 2.0
	block_tier = BLOCK_TIER_PROJECTILE
	force = 15.0
	attack_verb = list("bashes", "pounds", "slams")

/datum/power/undead/heal
	name = "Heal"
	desc = "Heal your undead comrades."
	price = 5

	power_item_type = /datum/spell/targeted/heal_target/area/undead_heal

/datum/power/undead/heal/activate(mob/living/carbon/human/H)
	var/datum/spell/targeted/heal_target/area/undead_heal/heal = new power_item_type(src)
	H.add_spell(heal)
