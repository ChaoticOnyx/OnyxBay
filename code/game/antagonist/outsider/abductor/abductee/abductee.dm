/**
 * ## Abductees
 *
 * Abductees are created by being operated on by abductors. They get some instructions about not
 * remembering the abduction, plus some random weird objectives for them to act crazy with.
 */

/datum/antagonist/abductee
	id = "abductee"
	role_text = "\improper Abductee"
	role_text_plural = "\improper Abductees"
	antaghud_indicator = "hudabductee"
	flags = ANTAG_RANDOM_EXCEPTED

/datum/antagonist/abductee/greet(datum/mind/player)
	to_chat(player.current, SPAN_WARNING("<b>Your mind snaps!</b>"))
	to_chat(player.current, SPAN_WARNING("<big><b>You can't remember how you got here...</b></big>"))
	show_objectives(player)

/datum/antagonist/abductee/create_objectives(datum/mind/player)
	var/objtype = (prob(75) ? /datum/objective/abductee/random : pick(subtypesof(/datum/objective/abductee/) - /datum/objective/abductee/random))
	var/datum/objective/abductee/O = new objtype()
	player.objectives += O
