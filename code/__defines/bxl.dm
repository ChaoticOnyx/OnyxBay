var/static/__bxl_lib

#define BXL_LOG_DEBUG 0
#define BXL_LOG_ERROR 1

/datum/bxl_settings
	var/log_proc

#define BXL_CREATE_VM_PROC(limits, handle_ptr) call_ext(__bxl_lib, "byond:bxl_create_vm")(limits, handle_ptr)
#define BXL_DESTROY_VM_PROC(handle) call_ext(__bxl_lib, "byond:bxl_destroy_vm")(handle)
