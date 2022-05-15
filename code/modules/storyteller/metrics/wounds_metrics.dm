/datum/controller/subsystem/storyteller/proc/report_wound(mob/victim, type, severity)
	if(!config.game.storyteller)
		return

	ASSERT(istype(victim)) 	     // not used yet, keep for the future
	ASSERT(istext(type) && type) // not used yet, keep for the future
	ASSERT(isnum(severity) && severity)

	var/static/storyteller_metric/injuries_score/metric
	if (!metric)
		metric = get_metric(/storyteller_metric/injuries_score)

	if (!victim.mind)
		return

	//metric._log_debug("Injury reported: victim is '[victim]', type is '[type]', severity is [severity]", verbose=TRUE)
	metric.injuries_sum += severity


// Score of Injuries. roughly ~200 is equivalent to one beaten to death human. 200 score are dropped to zero after 10 minutes
/storyteller_metric/injuries_score
	name = "Score of Injuries"
	var/injuries_sum = 0

/storyteller_metric/injuries_score/_evaluate(time_elapsed)
	injuries_sum = max(0, injuries_sum - time_elapsed * 200 / (10 MINUTES))
	return injuries_sum
