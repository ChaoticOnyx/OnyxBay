#define SIN_GLUTTONY_BEGINNER 0
#define SIN_GLUTTONY_BLASPHEMER 3
#define SIN_GLUTTONY_SACRILEGE 6
#define SIN_GLUTTONY_ULTIMATE 10
#define GLUTTONY_HEAL_REDUCTION 10

/datum/modifier/sin/gluttony
	name = "Gluttony"
	desc = "GLUTTONY."

	metabolism_percent = 3
	incoming_healing_percent = 2

/datum/spell/targeted/gluttony_heal
	name = "HEAL"
	desc = "GLUTTONY HEAL."
	feedback = "GH"
	school = "transmutation"
	charge_max = 1 MINUTE
	spell_flags = INCLUDEUSER | SELECTABLE
	invocation_type = SPI_NONE
	range = 2
	max_targets = 1

	icon_state = "undead_heal"

	message = "You feel a pleasant rush of heat move through your body."

/datum/spell/targeted/gluttony_heal/apply_spell_damage(mob/living/target)
	var/mob/living/carbon/user = holder
	if(!istype(user))
		return

	amt_dam_brute = user.nutrition / GLUTTONY_HEAL_REDUCTION
	amt_dam_fire = user.nutrition / GLUTTONY_HEAL_REDUCTION
	amt_dam_tox = user.nutrition / GLUTTONY_HEAL_REDUCTION
	amt_dam_oxy = user.nutrition / GLUTTONY_HEAL_REDUCTION
	return ..()

/datum/spell/targeted/gluttony_heal/after_spell(list/targets, mob/user, channel_duration)
	var/datum/godcultist/sinmind = user.mind?.godcultist
	if(!istype(sinmind))
		return

	sinmind.add_points(1)
