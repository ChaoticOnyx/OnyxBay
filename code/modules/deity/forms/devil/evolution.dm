/datum/evolution_category/devil/followers
	name = "Follower Improvements"
	items = list(
		/datum/evolution_package/devil/second_life,
		/datum/evolution_package/devil/second_life_enchancement,
		/datum/evolution_package/devil/request_imps
	)

/datum/evolution_package/devil/second_life
	name = "Second Life"
	desc = "Grant your followers a second chance at life (sort of). Even in death they will serve you as monkey-like creatures - imps."

/datum/evolution_package/devil/second_life_enchancement
	name = "Imps - Upgrade"
	desc = "Your imps will become less frail."
	unlocked_by = list(/datum/evolution_package/devil/second_life)

/datum/evolution_package/devil/second_life_enchancement/evolve(mob/living/M)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/deity/deity = get_associated_deity(M)
	var/datum/deity_form/devil/devil = deity?.form
	devil.upgrade_all_quasits()

/datum/evolution_package/devil/request_imps
	name = "Request imps from Avernus"
	desc = "Submit a request for mass delivery of imps straight from your hellish domain. WARNING: efficiency of this upgrade depends on the current amount of available souls."

/datum/evolution_package/devil/request_imps/evolve(mob/living/M)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/deity/deity = get_associated_deity(M)
	var/datum/deity_form/devil/devil = deity?.form
	for(var/i = 0 to 10)
		var/new_quasit = new /mob/living/carbon/human/quasit(devil.devil_spawn)
		var/datum/ghosttrap/quasit/S = get_ghost_trap("quasit")
		S.request_player(new_quasit, "The devil requests imps from Averno.")
