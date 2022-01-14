
// Emits an EMP around our host body
/datum/changeling_power/bioelectrogenesis
	name = "Bioelectrogenesis"
	desc = "We create an electromagnetic pulse against synthetics."
	icon_state = "ling_emp"
	required_chems = 50
	text_activate = "We emit an electromagnetic pulse!"
	var/heavy_range = 1
	var/light_range = 2

/datum/changeling_power/bioelectrogenesis/activate()
	if(!..())
		return

	use_chems()
	to_chat(my_mob, SPAN("changeling", text_activate))

	spawn()
		empulse(my_mob, heavy_range, light_range, TRUE)

/datum/changeling_power/bioelectrogenesis/update_recursive_enhancement()
	if(..())
		heavy_range = 2
		text_activate = "We emit a powerful electromagnetic pulse!"
	else
		heavy_range = 1
		text_activate = "We emit an electromagnetic pulse!"
