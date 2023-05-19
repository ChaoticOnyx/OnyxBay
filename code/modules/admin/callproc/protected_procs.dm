
/proc/is_proc_protected(procname)
    var/static/list/protected_procs = list(
		"sql_query",
		"shutdown"
    )
    return procname in protected_procs
