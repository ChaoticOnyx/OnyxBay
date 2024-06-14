/datum/component/ship_loadout
	can_transfer = FALSE
	var/list/equippable_slots = ALL_HARDPOINT_SLOTS //What slots does this loadout support? Want to allow a fighter to have multiple utility slots?
	var/list/hardpoint_slots = list()
	var/obj/structure/overmap/holder //To get overmap class vars.

/datum/component/ship_loadout/utility
	equippable_slots = HARDPOINT_SLOTS_UTILITY

/datum/component/ship_loadout/Initialize(source)
	. = ..()
	if(!istype(parent, /obj/structure/overmap))
		return COMPONENT_INCOMPATIBLE
	set_next_think(world.time + 1 SECOND)
	holder = parent
	for(var/hardpoint in equippable_slots)
		hardpoint_slots[hardpoint] = null

/datum/component/ship_loadout/proc/get_slot(slot)
	RETURN_TYPE(/obj/item/fighter_component)
	return hardpoint_slots[slot]

/datum/component/ship_loadout/proc/install_hardpoint(obj/item/fighter_component/replacement)
	var/slot = replacement.slot
	if(slot && !(slot in equippable_slots))
		replacement.visible_message("<span class='warning'>[replacement] can't fit onto [parent]")
		return FALSE
	remove_hardpoint(slot, FALSE)
	replacement.on_install(holder)
	if(slot)
		hardpoint_slots[slot] = replacement

/datum/component/ship_loadout/proc/remove_hardpoint(slot, due_to_damage)
	if(!slot)
		return FALSE

	var/obj/item/fighter_component/component = null
	if(istype(slot, /obj/item/fighter_component))
		component = slot
		hardpoint_slots[component.slot] = null
	else
		component = get_slot(slot)
		hardpoint_slots[slot] = null

	if(component && istype(component))
		component.remove_from(holder, due_to_damage)

/datum/component/ship_loadout/proc/dump_contents(slot)
	var/obj/item/fighter_component/component = null
	if(istype(slot, /obj/item/fighter_component))
		component = slot
	else
		component = get_slot(slot)
	component.dump_contents()

/datum/component/ship_loadout/think()
	for(var/slot in equippable_slots)
		var/obj/item/fighter_component/component = hardpoint_slots[slot]
		component?.think()

	set_next_think(world.time + 1 SECOND)
