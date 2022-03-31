/datum/extension/appearance
	expected_type = /atom
	flags = EXTENSION_FLAG_IMMEDIATE // | EXTENSION_FLAG_MULTIPLE_INSTANCES
	var/appearance_handler_type
	var/item_equipment_proc
	var/item_removal_proc

/datum/extension/appearance/New(holder)
	var/decl/appearance_handler/appearance_handler = appearance_manager.get_appearance_handler(appearance_handler_type)
	if(!appearance_handler)
		CRASH("Unable to acquire the [appearance_handler_type] appearance handler.")

	appearance_handler.register_signal(holder, SIGNAL_ITEM_EQUIPPED, item_equipment_proc)
	appearance_handler.register_signal(holder, SIGNAL_ITEM_UNEQUIPPED, item_removal_proc)

	..()

/datum/extension/appearance/Destroy()
	var/decl/appearance_handler/appearance_handler = appearance_manager.get_appearance_handler(appearance_handler_type)

	appearance_handler.unregister_signal(holder, SIGNAL_ITEM_EQUIPPED)
	appearance_handler.unregister_signal(holder, SIGNAL_ITEM_UNEQUIPPED)

	. = ..()
