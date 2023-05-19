
//Recover from stuns.]
/datum/changeling_power/unstun
	name = "Epinephrine Sacs"
	desc = "Removes all stuns."
	icon_state = "ling_unstun"
	required_chems = 80
	max_stat = UNCONSCIOUS

/datum/changeling_power/unstun/activate()
	if(!..())
		return
	use_chems()
	var/mob/living/carbon/human/H = my_mob

	H.reagents?.clear_reagents()

	H.set_stat(CONSCIOUS)

	H.SetParalysis(0)
	H.SetStunned(0)
	H.SetWeakened(0)

	H.lying = FALSE
	H.poise = H.poise_pool
	H.update_canmove()

	feedback_add_details("changeling_powers","UNS")
