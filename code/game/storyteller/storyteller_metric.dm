
/storyteller_metric_value_record
	var/value
	var/round_time

/storyteller_metric
	var/name = "Unknown Metric"

	var/_result_is_number = TRUE      // should be FALSE if _evaluate returns an object instead of number, disables statistics
	var/_can_be_used_on_setup = FALSE // if metric can be used on round start
	var/_const = FALSE                // if doesn't change with story processing

	var/__value = null
	var/__evaluation_storyteller_tick = 0
	var/list/__last_values = new      // list of storyteller_metric_value_record, used for statistics
	var/__previous_evaluation_time = null

	var/__debug = TRUE                // print debug logs

/storyteller_metric/proc/update()
	__value = _evaluate(world.time - __previous_evaluation_time)
	__previous_evaluation_time = world.time
	__evaluation_storyteller_tick = SSstoryteller.get_tick()
	if (_result_is_number)
		var/storyteller_metric_value_record/record = new
		record.value = __value
		record.round_time = world.time - global.round_start_time
		__last_values.Add(record)

/storyteller_metric/proc/get_value()
	if (__is_need_to_reevaluate())
		update()
	return __value

/storyteller_metric/proc/get_params_for_ui()
	var/time_passed = world.time - __previous_evaluation_time
	var/list/data = list(
		"name" = name,
		"is_const" = _const,
		"last_evaluation_time_minutes" = round(time_passed / (1 MINUTE)),
		"last_evaluation_time_seconds" = round(time_passed / (1 SECOND))
	)
	if (_result_is_number)  // TODO: need to provide "else" case when not-number metrics will be available
		data["value"] = __value
	return data

// reevaluate once per storyteller tick
/storyteller_metric/proc/__is_need_to_reevaluate()
	if (SSstoryteller.get_tick() != __evaluation_storyteller_tick)
		ASSERT(SSstoryteller.get_tick() != -1 || _can_be_used_on_setup)
		if (_const && !isnull(__value))
			return FALSE
		return TRUE
	return FALSE

// Should evaluate metric and return result.
// Prefer numbers as result of evaluation. If you need to return something more heavy (object?), disable statistics with '_result_is_number'
/storyteller_metric/proc/_evaluate(time_elapsed)
	CRASH("Storyteller metric '[name]' evaluate method is not implemented!")

/storyteller_metric/proc/_log_debug(text, verbose = FALSE)
	if (!__debug)
		return
	var/string_to_log = "\[Storyteller Metric [name]]: [text]"
	if (verbose)
		log_debug(string_to_log) //print in the debug chat and save in a log file
	else
		log_debug_verbose(string_to_log) //only save in a log file

/storyteller_metric/proc/print_statistics(user)
	if (!user)
		_log_debug(__build_statistics())
		return

	var/string_to_log = "\[Storyteller Metric [name]]: "
	to_chat(user, string_to_log + __build_statistics())

/storyteller_metric/proc/__build_statistics()
	var/stat = "\n----\n" // start from newline
	for (var/V in __last_values)
		var/storyteller_metric_value_record/record = V
		stat += "[record.round_time]	[record.value]\n"
	stat += "----"
	return stat

#define USE_METRIC(path, varname) \
var/storyteller_metric/metric##varname = _get_metric(##path); \
var/##varname = metric##varname.get_value();
