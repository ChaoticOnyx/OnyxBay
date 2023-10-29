
// Small area of effect stun.
/datum/vampire_power/hypnotise
	name = "Hypnotise"
	desc = "Through blood magic, you dominate the victim's mind and force them into a hypnotic transe."
	icon_state = "vamp_hypnotise"
	blood_cost = 0

/datum/vampire_power/hypnotise/is_usable(no_message = FALSE)
	if(!..())
		return FALSE

	if(my_mob.eyecheck() > FLASH_PROTECTION_NONE)
		if(!no_message)
			to_chat(my_mob, SPAN("warning", "You can't do that, because no one will see the light of your eyes!"))
		return FALSE

	return TRUE

/datum/vampire_power/hypnotise/activate()
	if(!..())
		return

	var/list/victims = list()
	for(var/mob/living/carbon/human/H in view(3, my_mob))
		if(H == my_mob)
			continue
		if(H.eyecheck() > FLASH_PROTECTION_NONE)
			continue
		victims += H
	if(!victims.len)
		to_chat(my_mob, SPAN("warning", "No suitable targets."))
		return

	var/mob/living/carbon/human/T = input(my_mob, "Select Victim") as null|mob in victims

	if(!vampire.can_affect(T))
		return

	to_chat(my_mob, SPAN("notice", "You begin peering into [T]'s mind, looking for a way to render them useless."))

	if(do_mob(my_mob, T, 50, incapacitation_flags = INCAPACITATION_DISABLED))
		to_chat(my_mob, SPAN("danger", "You dominate [T]'s mind and render them temporarily powerless to resist"))
		to_chat(T, SPAN("danger", "You are captivated by [my_mob]'s gaze, and find yourself unable to move or even speak."))
		T.Weaken(25)
		T.Stun(25)
		T.silent += 30

		use_blood()
		admin_attack_log(my_mob, T, "used hypnotise to stun [key_name(T)]", "was stunned by [key_name(my_mob)] using hypnotise", "used hypnotise on")

		set_cooldown(60 SECONDS)
	else
		to_chat(my_mob, SPAN("warning", "You broke your gaze."))
