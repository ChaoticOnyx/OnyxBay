
// Grapple a victim by leaping onto them.
/datum/vampire_power/grapple
	name = "Grapple"
	desc = "Lunge towards a target like an animal, and grapple them."
	icon_state = "vamp_leap"
	blood_cost = 0

/datum/vampire_power/grapple/activate()
	if(!..())
		return

	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(4, my_mob))
		targets += H
	targets -= my_mob

	if(!targets.len)
		to_chat(my_mob, SPAN("warning", "No valid targets visible or in range."))
		return

	var/mob/living/carbon/human/T = pick(targets)
	my_mob.process_leap(T)
	set_cooldown(3 SECONDS)
