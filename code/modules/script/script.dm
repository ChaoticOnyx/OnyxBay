/datum/script
	var/id = null
	var/max_memory = 0

/datum/script/New(max_memory)
	. = ..()

	src.max_memory = max_memory
	id = Z_SCRIPT_CREATE(src, max_memory)
	ASSERT(id != null)

/datum/script/Destroy(force)
	. = ..()
	
	if(id == null)
		return

	ASSERT(Z_SCRIPT_DESTROY(id) == TRUE)
	id = null

/datum/script/proc/has_var(name)
	var/ret = Z_SCRIPT_HAS_VAR(id, name)
	ASSERT(ret != null)

	return ret

/datum/script/proc/set_var(name, value, cast)
	ASSERT(Z_SCRIPT_SET_VAR(id, name, value, cast) == TRUE)

/datum/script/proc/get_var(name)
	return Z_SCRIPT_GET_VAR(id, name)

/datum/script/proc/get_var_type(name)
	var/type = Z_SCRIPT_GET_VAR_TYPE(id, name)
	ASSERT(type != null)

	return type

/datum/script/proc/unset_var(name)
	ASSERT(Z_SCRIPT_UNSET_VAR(id, name) == TRUE)

/datum/script/proc/register_function(name, callback, dst, typings)
	ASSERT(Z_SCRIPT_REGISTER_FUNCTION(id, name, callback, dst, typings) == TRUE)

/datum/script/proc/unregister_function(name)
	ASSERT(Z_SCRIPT_UNREGISTER_FUNCTION(id, name) == TRUE)

/datum/script/proc/compile(source)
	var/ret = Z_SCRIPT_COMPILE(id, source, 0, 0)
	ASSERT(ret != null)

	return ret

/datum/script/proc/get_compile_error_kind()
	var/ret = Z_SCRIPT_GET_COMPILE_ERROR_KIND(id)
	ASSERT(ret != null)

	if(ret == 0)
		return null
	
	return ret

/datum/script/proc/get_compile_error_pos()
	var/ret = Z_SCRIPT_GET_COMPILE_ERROR_POS(id)
	ASSERT(ret != null)

	if(ret < 0)
		return null
	
	return ret

/datum/script/proc/run_script(max_ops, max_time_ds, time_check_interval, time_util)
	var/ret = Z_SCRIPT_RUN(id, max_ops, max_time_ds, time_check_interval, time_util)
	ASSERT(ret != null)
	
	return ret

/datum/script/proc/get_runtime_error_kind()
	var/ret = Z_SCRIPT_GET_RUNTIME_ERROR_KIND(id)
	ASSERT(ret != null)

	return ret

/datum/script/proc/get_runtime_error_ip()
	var/ret = Z_SCRIPT_GET_RUNTIME_ERROR_IP(id)
	ASSERT(ret != null)

	return ret

/datum/script/proc/reset(clear_vars, clear_functions, clear_stack)
	ASSERT(Z_SCRIPT_RESET(id, clear_vars, clear_functions, clear_stack) == TRUE)

/datum/script/proc/gc_collect()
	ASSERT(Z_SCRIPT_GC_COLLECT(id) == TRUE)

/datum/script/proc/get_ip()
	var/ip = Z_SCRIPT_GET_IP(id)
	ASSERT(ip != null)

	return ip

/datum/script/proc/set_ip(ip)
	ASSERT(Z_SCRIPT_SET_IP(id, ip) == TRUE)

/datum/script/proc/get_op_pos(ip)
	var/ret = Z_SCRIPT_GET_OP_POS(id, ip)
	ASSERT(ret != null)

	return ret

/datum/script/proc/get_used_memory()
	var/ret = Z_SCRIPT_GET_USED_MEMORY(id)
	ASSERT(ret != null)

	return ret
