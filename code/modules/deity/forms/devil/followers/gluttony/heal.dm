#define HEAL_REDUCTION 10
#define NUTRITION_REMOVAL_COEFFICIENT 5

/datum/action/cooldown/spell/gluttony_heal
	name = "Heal"
	desc = "GLLUTTONY HEAL!!!"
	button_icon_state = "devil_nutritious_heal"
	cooldown_time = 1 MINUTE
	cast_range = 1
	click_to_activate = TRUE

/datum/action/cooldown/spell/gluttony_heal/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/gluttony_heal/cast(mob/living/carbon/human/cast_on)
	var/mob/living/carbon/carbon_owner = owner
	if(!istype(carbon_owner))
		return

	cast_on.adjustBruteLoss(-carbon_owner.nutrition / HEAL_REDUCTION)
	cast_on.adjustFireLoss(-carbon_owner.nutrition / HEAL_REDUCTION)
	cast_on.adjustToxLoss(-carbon_owner.nutrition / HEAL_REDUCTION)
	cast_on.adjustOxyLoss(-carbon_owner.nutrition / HEAL_REDUCTION)
	carbon_owner.remove_nutrition(-carbon_owner.nutrition / NUTRITION_REMOVAL_COEFFICIENT)

#undef HEAL_REDUCTION
#undef NUTRITION_REMOVAL_COEFFICIENT
