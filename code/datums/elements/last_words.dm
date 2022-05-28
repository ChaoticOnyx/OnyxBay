GLOBAL_LIST_EMPTY(last_words)

/datum/last_words_data
	var/words = null
	var/time_of_death = null
	var/real_name = null
	var/job_title = null

/datum/element/last_words/attach(mob/living/target)
	. = ..()
	
	if(!istype(target))
		return ELEMENT_INCOMPATIBLE

	register_signal(target, SIGNAL_STAT_SET, .proc/on_stat_set)

/datum/element/last_words/detach(datum/target)
	unregister_signal(target, SIGNAL_STAT_SET)
	
	. = ..()

/datum/element/last_words/proc/on_stat_set(mob/living/L, old_stat, new_stat)
	if(new_stat != DEAD)
		return

	if(!length(L.logging[INDIVIDUAL_SAY_LOG]) || (L.loc?.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_CENTCOM)))
		detach(L)
		return

	var/index = 0
	for(var/entry in L.logging[INDIVIDUAL_SAY_LOG])
		index += 1

		if(index == length(L.logging[INDIVIDUAL_SAY_LOG]))
			var/datum/last_words_data/data = new()

			data.words = L.logging[INDIVIDUAL_SAY_LOG][entry]
			data.time_of_death = L.timeofdeath
			data.real_name = L.real_name || L.name
			data.job_title = L.job || "Unemployed"

			GLOB.last_words += data
			break

	detach(L)
