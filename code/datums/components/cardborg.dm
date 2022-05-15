/datum/component/cardborg/Initialize(...)
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	
	var/decl/appearance_handler/A = appearance_manager.get_appearance_handler(/decl/appearance_handler/cardborg)

	A.register_signal(parent, SIGNAL_ITEM_EQUIPPED, /decl/appearance_handler/cardborg/proc/item_equipped)
	A.register_signal(parent, SIGNAL_ITEM_UNEQUIPPED, /decl/appearance_handler/cardborg/proc/item_removed)

/datum/component/cardborg/Destroy(force, silent)
	var/decl/appearance_handler/A = appearance_manager.get_appearance_handler(/decl/appearance_handler/cardborg)

	A.unregister_signal(parent, SIGNAL_ITEM_EQUIPPED)
	A.unregister_signal(parent, SIGNAL_ITEM_UNEQUIPPED)
	
	. = ..()
