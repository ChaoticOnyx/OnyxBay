/datum/wizard/undead/proc/add_undead_power(datum/power/P)
	if(P in purchased_powers)
		for(var/datum/power/undead/power in available_powers)
			if(power.type == P.power_path)
				return

/datum/wizard/undead/proc/remove_undead_power(target_power, remove_purchased = TRUE)
	return

/datum/power/undead
	var/icon = null
	var/owned = FALSE
	var/price = 10

	var/power_item_type = null

/datum/power/undead/proc/apply()


/datum/power/undead/modifier/apply()
	/datum/modifier/movespeed/lightpink


/datum/power/undead/armblade
	name = "Arm Blade"
	desc = "We reform our hand into a deadly arm blade."
	icon = "bool"
	price = 10
	owned = TRUE

	power_item_type = /obj/item/melee/changeling/arm_blade

/datum/power/undead/armblade/proc/activate()
	usr.visible_message("<b>[usr]</b>'s arm twitches.", \
		SPAN_WARNING("."))

	var/mob/living/carbon/human/H = usr

	if(H.l_hand && H.r_hand)
		to_chat(H, SPAN_WARNING("Your hands are full."))
		return FALSE

	var/obj/item/I = new power_item_type(H)
	H.pick_or_drop(I)
	return TRUE

/datum/power/undead/heal
	name = "Heal"
	desc = "Placeholder"
	price = 228

	power_item_type = /datum/spell/targeted/heal_target/area/undead_heal

/datum/power/undead/damage
	name = "Damage"
	desc = "Placeholder"
	icon = "bool"
	price = 10
	owned = TRUE

	power_path = null

/datum/power/undead/hunter
	name = "Hunter"
	desc = "Placeholder"
	icon = "bool"
	price = 10
	owned = TRUE

	power_path = null

/datum/power/undead/protector
	name = "Protector"
	desc = "Placeholder"
	icon = "bool"
	price = 10
	owned = TRUE

	power_path = null
