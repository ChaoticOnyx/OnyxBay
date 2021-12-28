
//Boosts the range of our stings by 1, but also increases required chems by 10.
/datum/changeling_power/toggled/bioelectrogenesis
	name = "Bioelectrogenesis"
	desc = "We create an electromagnetic pulse against synthetics."
	icon_state = "ling_emp"
	required_chems = 40
	power_processing = FALSE

	text_activate = "We prepare to launch an electromagnetic pulse."
	text_deactivate = "We retract from using bioelectrogenesis."

/datum/changeling_power/toggled/bioelectrogenesis/activate()
	changeling.deactivate_stings()
	my_mob.PushClickHandler(/datum/click_handler/changeling/changeling_bioelectrogenesis)
	active = TRUE
	update_screen_button()

/datum/changeling_power/toggled/bioelectrogenesis/deactivate(no_message = TRUE)
	active = FALSE
	if(istype(my_mob.GetClickHandler(), /datum/click_handler/changeling/changeling_bioelectrogenesis))
		my_mob.PopClickHandler()
	if(!no_message)
		to_chat(my_mob, SPAN("changeling", text_deactivate))
	update_screen_button()

/datum/changeling_power/toggled/bioelectrogenesis/proc/affect(atom/target)
	if(!target)
		return
	if(!is_usable())
		return
	if(target in orange(1, src))
		empulse(target.loc, 1, 1)
		deactivate()
		use_chems()
	else
		to_chat(src, SPAN("changeling", "The target is too far away."))
