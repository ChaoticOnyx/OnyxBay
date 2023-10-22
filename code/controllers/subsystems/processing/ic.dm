GLOBAL_LIST_EMPTY(ic_vms)

PROCESSING_SUBSYSTEM_DEF(ic)
	name = "Integrated Circuit"
	priority = SS_PRIORITY_CIRCUIT
	wait = 2 SECONDS

/datum/controller/subsystem/processing/ic/proc/create_vm(datum/ic_limits/limits)
	ASSERT(limits)

	var/handle
	BXL_CREATE_VM_PROC(limits, &handle)

	var/datum/ic_vm/vm = new(handle)

	GLOB.ic_vms["[handle]"] = vm

	return vm

/datum/controller/subsystem/processing/ic/proc/destroy_vm(datum/ic_vm/vm)
	GLOB.ic_vms["[vm.__handle]"] = null

	BXL_DESTROY_VM_PROC(vm.__handle)
	qdel(vm)
