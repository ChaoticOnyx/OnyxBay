#define USE_METRIC(path, varname) \
var/storyteller_metric/metric##varname = _get_metric(##path); \
var/##varname = metric##varname.get_value();
