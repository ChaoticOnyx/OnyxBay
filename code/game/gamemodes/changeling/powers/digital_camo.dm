
//Prevents AIs tracking you but makes you easily detectable to the human-eye.
/datum/changeling_power/toggled/digital_camouflage
	name = "Digital Camouflage"
	desc = "The AI can no longer track us, but we will look different if examined. Has a constant cost while active."
	icon_state = "ling_digital_camo"
	required_chems = 0
	chems_drain = 0.5
	power_processing = TRUE

	text_activate = "We distort our form to prevent AI-tracking."
	text_deactivate = "We return to normal, allowing AI to track us."
	text_nochems = "Our digital camouflage diappears as we run out of chemicals. AI can track us again."

/datum/changeling_power/toggled/digital_camouflage/activate()
	if(!..())
		return
	var/mob/living/carbon/human/H = my_mob
	to_chat(H, SPAN("changeling", text_activate))
	H.digitalcamo = TRUE
	use_chems()

	feedback_add_details("changeling_powers", "CAM")

/datum/changeling_power/toggled/digital_camouflage/deactivate(no_message = TRUE)
	if(!..())
		return
	var/mob/living/carbon/human/H = my_mob
	to_chat(H, SPAN("changeling", text_deactivate))
	H.digitalcamo = FALSE
