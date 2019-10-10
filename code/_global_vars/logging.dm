var/runtime_diary = null


var/list/combatlog = list()
var/list/IClog     = list()
var/list/OOClog    = list()
var/list/adminlog  = list()

GLOBAL_REAL(config,    /datum/configuration)
GLOBAL_REAL(watchlist, /datum/watchlist)

var/list/jobMax        = list()
var/diary = null

GLOBAL_VAR(log_directory)
GLOBAL_PROTECT(log_directory)
GLOBAL_VAR(world_runtime_log)
GLOBAL_PROTECT(world_runtime_log)
GLOBAL_VAR(world_qdel_log)
GLOBAL_PROTECT(world_qdel_log)
GLOBAL_VAR(tgui_error_log)
GLOBAL_PROTECT(tgui_error_log)
GLOBAL_VAR(tgui_debug_log)
GLOBAL_PROTECT(tgui_debug_log)
