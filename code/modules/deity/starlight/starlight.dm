/datum/god_form/starlight
	name = "Starlight Herald"
	desc = "The bringer of life, and all that entails."
	form_state = "sungod"

	buildables = list(
		/datum/deity_power/structure/starlight/pylon,
		/datum/deity_power/structure/starlight/altar,
		/datum/deity_power/structure/starlight/statue
	)

	phenomena = list(
		/datum/deity_power/phenomena/burning_glare
	)

	boons = list(
		/datum/deity_power/boon/starburst,
		/datum/deity_power/boon/burning_grip,
		/datum/deity_power/boon/emp,
		/datum/deity_power/boon/cure_light,
		/datum/deity_power/boon/blazing_blade,
		/datum/deity_power/boon/holy_beacon,
		/datum/deity_power/boon/black_death
	)

	resources = list(
		/datum/deity_resource/starlight/piety,
		/datum/deity_resource/starlight/favor
	)


/datum/god_form/starlight/take_charge(mob/living/user, charge)
	charge = max(5, charge/100)
	if(prob(charge))
		to_chat(user, SPAN_DANGER("Your body burns!"))
	user.adjustFireLoss(charge)
	return TRUE
