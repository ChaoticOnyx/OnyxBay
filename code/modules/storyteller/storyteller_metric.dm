/storyteller_metric
	var/name = "Unknown Metric"

	var/_result_is_number = TRUE      // should be FALSE if _evaluate returns an object instead of number, disables statistics
	var/_can_be_used_on_setup = FALSE // if metric can be used on round start
	var/_const = FALSE                // if doesn't change with story processing

	var/__value
	var/__evaluation_storyteller_tick = 0
	var/list/__last_values = new      // [[worldtime, value], [worldtime, value], ...], used for statistics

	var/__debug = TRUE                // print debug logs

/storyteller_metric/proc/get_value()
	if (__is_need_to_reevaluate())
		__value = _evaluate()
		if (_result_is_number && !_const)
			__last_values.Add(new /list(world.time, __value))
	return __value

// reevaluate once per storyteller tick
/storyteller_metric/proc/__is_need_to_reevaluate()
	if (SSstoryteller.get_tick() != __evaluation_storyteller_tick)
		ASSERT(SSstoryteller.get_tick() != -1 || _can_be_used_on_setup)
		if (_const && __value)
			return FALSE
		return TRUE
	return FALSE

// Should evaluate metric and return result.
// Prefer numbers as result of evaluation. If you need to return something more heavy (object?), disable statistics with '_result_is_number'
/storyteller_metric/proc/_evaluate()
	ASSERT("Storyteller metric '[name]' evaluate method is not implemented!")

/storyteller_metric/proc/_log_debug(text)
	if (__debug)
		log_debug("\[Storyteller Metric [name]]: [text]")

#define USE_METRIC(path, varname) \
var/storyteller_metric/metric##varname = _get_metric(##path); \
var/##varname = metric##varname.get_value();
