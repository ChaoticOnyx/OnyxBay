GLOBAL_LIST_INIT(flag_appearances, populate_flag_appearance_list())

/proc/populate_flag_appearance_list()
	var/list/result = list()
	for (var/typepath as anything in subtypesof(/datum/flag_appearance))
		result[typepath] = new typepath
	return result

/datum/flag_appearance
	var/name
	var/desc
	var/color
	var/icon_state

FLAG_APPEARANCE_DEF(white, white)
	name = "white"
	desc = "Perhaps, someone's surrendering?"

FLAG_APPEARANCE_DEF(arcturusmain, arcturusmain)
	name = "Arcturia"
	desc = "Arcturia yes!"

FLAG_APPEARANCE_DEF(cargonia, cargonia)
	name = "Cargonia"
	desc = "LIBERTY! EQUALITY! FRATERNITY!"

FLAG_APPEARANCE_DEF(gaianovaasr, gaianovaasr)
	name = "Gaia Nova ASR"
	desc = "Lada Star, now colored! It is written, “Gaia Nova ASR”."

FLAG_APPEARANCE_DEF(gaiamagnamain, gaiamagnamain)
	name = "Gaia Magna"
	desc = "God forgive these T*rran stripes."

FLAG_APPEARANCE_DEF(magnitkamain, magnitkamain)
	name = "Nova Magnitka"
	desc = "Attracting space bears and financial troubles."

FLAG_APPEARANCE_DEF(nt, nanotrasenmain)
	name = "NanoTrasen"
	desc = "Yep, that's the company you'll most likely live and die for."

// TODO: Wait for new and improved Syndicate flag sprites.
FLAG_APPEARANCE_DEF(syndie, white)
	name = "Syndicate"
	desc = "Who's that Syndie Kate, again?"
	color = "#8b0000"

FLAG_APPEARANCE_DEF(byonder, prob80)
	name = "Developer"
	desc = "It wields some sort of a deep meaning."

FLAG_APPEARANCE_DEF(zenghumain, zenghumain)
	name = "Zeng-Hu Clique"
	desc = "Is that a funny dragon in the middle?"
