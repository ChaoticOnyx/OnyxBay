/* Used for whether the AI can use a hologram. Mostly self-documenting.
* requires_malf: will display the malf hologram overlay and requires malf mode to be active.
* icon_colorize: if false, the hologram will be decolorized.
* ckey: ckey of player that allows to use this hologram. None makes it allowed to all players.
*/

GLOBAL_LIST_INIT(AI_holos, init_subtypes(/datum/ai_holo))
/datum/ai_holo
	var/requires_malf = FALSE
	var/icon = 'icons/mob/hologram.dmi'
	var/icon_state = "icon_state"
	var/icon_colorize = FALSE
	var/name
	var/ckey


/datum/ai_holo/proc/may_be_used_by_ai(mob/living/silicon/ai/AI)
	var/allowed = !requires_malf || AI.is_malf_or_traitor()
	if(ckey)
		if(AI.ckey && AI.ckey != ckey)
			allowed = FALSE
	return allowed

/datum/ai_holo/New(name, icon, icon_state, icon_colorize = FALSE, requires_malf = FALSE)
	src.icon = icon || src.icon
	src.icon_state = icon_state || src.icon_state
	src.name = name || src.icon_state
	src.icon_colorize = icon_colorize
	src.requires_malf = src.requires_malf || requires_malf

/datum/ai_holo/default
	icon_state = "Default"

/datum/ai_holo/default_slim
	icon_state = "Default-Slim"

/datum/ai_holo/face
	icon_state = "Face"

/datum/ai_holo/carp
	icon_state = "Carp"

/datum/ai_holo/solgov
	icon_state = "SolGov"

/datum/ai_holo/cursor
	icon_state = "Cursor"

/datum/ai_holo/caution
	icon_state = "Caution"

/datum/ai_holo/chevrons
	icon_state = "Chevrons"

/datum/ai_holo/dronum
	icon_state = "Dronum"

/datum/ai_holo/dronus
	icon_state = "Dronus"

/datum/ai_holo/question
	icon_state = "Question"

/datum/ai_holo/singularity
	icon_state = "Singularity"

/datum/ai_holo/clippy
	requires_malf = TRUE
	icon_state = "malf-clippy"

/datum/ai_holo/malfcursor
	requires_malf = TRUE
	icon_state = "malf-cursor"

/datum/ai_holo/malfdronus
	requires_malf = TRUE
	icon_colorize = TRUE
	icon_state = "malf-Dronus"

/datum/ai_holo/missingno
	requires_malf = TRUE
	icon_colorize = TRUE
	icon_state = "malf-missingno"

/datum/ai_holo/malfsingularity
	icon_state = "malf-singularity"
	requires_malf = TRUE
	icon_colorize = TRUE

/datum/ai_holo/malftcc
	icon_state = "malf-TCC"
	requires_malf = TRUE
	icon_colorize = TRUE

/datum/ai_holo/catalyst
	icon_state = "malf-catalyst"
	requires_malf = TRUE
