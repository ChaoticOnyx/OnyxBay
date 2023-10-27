
// Small area of effect stun.
/datum/vampire_power/glare
	name = "Glare"
	desc = "Your eyes flash a bright light, stunning any who are watching."
	icon_state = "vamp_glare"
	blood_cost = 0

/datum/vampire_power/glare/is_usable(no_message = FALSE)
	if(!..())
		return FALSE

	if(my_mob.eyecheck() > FLASH_PROTECTION_NONE)
		to_chat(my_mob, SPAN("warning", "You can't do that, because no one will see the light of your eyes!"))
		return FALSE

	return TRUE

/datum/vampire_power/glare/activate()
	if(!..())
		return

	use_blood()
	my_mob.visible_message(SPAN("danger", "[my_mob]'s eyes emit a blinding flash"))

	var/list/victims = list()
	for(var/mob/living/carbon/human/H in view(2, my_mob))
		if(H == my_mob)
			continue
		if(!vampire.can_affect(H, FALSE))
			continue
		if(H.eyecheck() > FLASH_PROTECTION_NONE)
			continue
		H.Weaken(8)
		H.Stun(6)
		H.stuttering = 20
		H.confused = 10
		to_chat(H, SPAN("danger", "You are blinded by [my_mob]'s glare!"))
		H.flash_eyes()
		victims += H

	admin_attacker_log_many_victims(my_mob, victims, "used glare to stun", "was stunned by [key_name(my_mob)] using glare", "used glare to stun")

	set_cooldown(40 SECONDS)
