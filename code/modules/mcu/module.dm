/obj/item/mcu_module
	w_class = ITEM_SIZE_TINY

	var/device_type = 0
	
	/// Set by MCU, starts from 0 NOT 1!!!
	var/__pci_slot = null
	/// Set by MCU
	var/weakref/__host = null

/obj/item/mcu_module/proc/__reset(attached)
	return

/obj/item/mcu_module/proc/__syscall(cmd, ...)
	return FALSE

/obj/item/mcu_module/tgui_host(mob/user)
	if(__host != null)
		return __host.resolve()
	
	return src

/obj/item/mcu_module/Destroy()
	. = ..()
	
	if(__pci_slot == null)
		return

	var/obj/item/device/mcu/M = __host.resolve()

	if(QDELETED(M))
		return
	
	ASSERT(M.try_detach_pci_module(src) == TRUE)
