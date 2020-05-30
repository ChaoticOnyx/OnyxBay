
/storyteller_metric_value_record
	var/value
	var/world_time

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

/storyteller_metric/proc/get_value()
	if (__is_need_to_reevaluate())
		__value = _evaluate(world.time - __previous_evaluation_time)
		__previous_evaluation_time = world.time
		__evaluation_storyteller_tick = SSstoryteller.get_tick()
		if (_result_is_number)
			var/storyteller_metric_value_record/record = new
			record.value = __value
			record.world_time = world.time
			__last_values.Add(record)
	return __value

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
	ASSERT("Storyteller metric '[name]' evaluate method is not implemented!")

/storyteller_metric/proc/_log_debug(text)
	if (__debug)
		log_debug("\[Storyteller Metric [name]]: [text]")

/storyteller_metric/proc/print_statistics()
	var/stat = "\n----\n" // start from newline
	for (var/V in __last_values)
		var/storyteller_metric_value_record/record = V
		stat += "[record.world_time]	[record.value]\n"
	stat += "----"
	_log_debug(stat)

#define USE_METRIC(path, varname) \
var/storyteller_metric/metric##varname = _get_metric(##path); \
var/##varname = metric##varname.get_value();
