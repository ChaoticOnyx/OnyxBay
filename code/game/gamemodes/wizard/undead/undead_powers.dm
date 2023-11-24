/datum/power/undead
	var/owned = FALSE
	var/price

	var/power_item_type = null

/datum/power/undead/proc/activate()
	return

/datum/power/undead/armblade
	name = "Arm Blade"
	desc = "Mutate your hand into a deadly armblade."
	price = 120

	power_item_type = /obj/item/melee/changeling/arm_blade/undead_armblade

/obj/item/melee/changeling/arm_blade/undead_armblade/dropped(mob/user)
	user.pick_or_drop(src)
	return

/datum/power/undead/armblade/activate(mob/living/carbon/human/H)
	H.visible_message("<b>[H]</b>'s arm twitches.", \
		SPAN_WARNING("."))

	if(H.l_hand && H.r_hand)
		to_chat(H, SPAN_WARNING("Your hands are full."))
		return FALSE

	var/obj/item/I = new power_item_type(H)
	H.pick_or_drop(I)
	return TRUE

/datum/power/undead/heal
	name = "Heal"
	desc = "Heal your undead comrades."
	price = 120

	power_item_type = /datum/spell/targeted/heal_target/area/undead_heal

/datum/power/undead/heal/activate(mob/living/carbon/human/H)
	var/datum/spell/targeted/heal_target/area/undead_heal/heal = new power_item_type(src)
	H.add_spell(heal)
