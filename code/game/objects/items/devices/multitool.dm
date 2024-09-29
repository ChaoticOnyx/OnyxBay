/**
 * Multitool -- A multitool is used for hacking electronic devices.
 *
 */

/obj/item/device/multitool
	name = "multitool"
	desc = "This small, handheld device is made of durable alloy steel and tipped with electrodes, perfect for interfacing with numerous machines."
	description_info = "Multitools are incredibly versatile and can be used on a wide variety of machines. The most common use for this is to trip a device's wires without having to cut them. Simply click on an object with exposed wiring to use it. There might be other uses, as well..."
	description_fluff = "The common, every day multitool is descended from certain electrical tools from Earth's early space age. Though none too cheap, they are incredibly handy, and can be found in any self-respecting technician's toolbox."
	description_antag = "This handy little tool can get you through doors, turn off power, and anything else you might need."
	icon_state = "multitool"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 6.0
	mod_weight = 0.6
	mod_reach = 0.5
	mod_handy = 0.85
	w_class = ITEM_SIZE_SMALL
	throwforce = 5.0
	throw_range = 15
	tool_behaviour = TOOL_MULTITOOL

	matter = list(MATERIAL_STEEL = 50, MATERIAL_GLASS = 20)

	origin_tech = list(TECH_MAGNET = 1, TECH_ENGINEERING = 1)

	var/buffer_name
	var/atom/buffer_object

	drop_sound = SFX_DROP_MULTITOOL
	pickup_sound = SFX_PICKUP_MULTITOOL

/obj/item/device/multitool/Destroy()
	unregister_buffer(buffer_object)
	return ..()

/obj/item/device/multitool/proc/get_buffer(typepath)
	// Only allow clearing the buffer name when someone fetches the buffer.
	// Means you cannot be sure the source hasn't been destroyed until the very moment it's needed.
	get_buffer_name(TRUE)
	if(buffer_object && (!typepath || istype(buffer_object, typepath)))
		return buffer_object

/obj/item/device/multitool/proc/get_buffer_name(null_name_if_missing = FALSE)
	if(buffer_object)
		buffer_name = buffer_object.name
	else if(null_name_if_missing)
		buffer_name = null
	return buffer_name

/obj/item/device/multitool/proc/set_buffer(atom/buffer)
	if(!buffer || istype(buffer))
		buffer_name = buffer ? buffer.name : null
		if(buffer != buffer_object)
			unregister_buffer(buffer_object)
			buffer_object = buffer
			if(buffer_object)
				register_signal(buffer_object, SIGNAL_QDELETING, nameof(.proc/unregister_buffer))

/obj/item/device/multitool/proc/unregister_buffer(atom/buffer_to_unregister)
	// Only remove the buffered object, don't reset the name
	// This means one cannot know if the buffer has been destroyed until one attempts to use it.
	if(buffer_to_unregister == buffer_object && buffer_object)
		unregister_signal(buffer_object, SIGNAL_QDELETING)
		buffer_object = null

/obj/item/device/multitool/resolve_attackby(atom/A, mob/user)
	if(!isobj(A))
		return ..(A, user)

	var/obj/O = A
	var/datum/extension/interactive/multitool/MT = get_extension(O, /datum/extension/interactive/multitool)
	if(!MT)
		return ..(A, user)

	user.AddTopicPrint(src)
	MT.interact(src, user)
	return FALSE

/obj/item/device/multitool/advtool
	name = "Advanced Multitool"
	desc = "This small, handheld device is made of durable, insulated plastic, has a rubber grip, and can be used as a multitool, screwdriver or wirecutters."
	description_info = "Multitools are incredibly versatile and can be used on a wide variety of machines. The most common use for this is to trip a device's wires without having to cut them. Simply click on an object with exposed wiring to use it. This one can also be used as a screwdriver or wirecutters. There might be other uses, as well..."
	description_fluff = "This device is not just a regular multitool - it is a masterpiece. You can deal with almost any machine using only this little thing."
	description_antag = "This handy little tool can get you through doors, turn off power, and anything else you might need."
	icon = 'icons/obj/device.dmi'
	item_state = "multitool"
	icon_state = "advtool"
	force = 5.0
	w_class = ITEM_SIZE_SMALL
	throwforce = 5.0
	throw_range = 15

	matter = list(MATERIAL_STEEL = 500, MATERIAL_GLASS = 200)

	origin_tech = list(TECH_MAGNET = 2, TECH_ENGINEERING = 4)

	var/tool_c
	var/obj/item/device/multitool/advpart/multitool = null
	var/obj/item/screwdriver/advpart/screwdriver = null
	var/obj/item/wirecutters/advpart/wirecutters = null

/obj/item/device/multitool/advtool/Initialize()
	. = ..()

	multitool = new /obj/item/device/multitool/advpart(src)
	screwdriver = new /obj/item/screwdriver/advpart(src)
	wirecutters = new /obj/item/wirecutters/advpart(src)
	tool_c = "multitool"
	tool_behaviour = TOOL_MULTITOOL

/obj/item/device/multitool/advtool/on_update_icon()
	underlays.Cut()
	underlays += "adv_[tool_c]"
	..()

/obj/item/device/multitool/advtool/proc/switchtools()
	if(tool_c == "multitool")
		if(screwdriver)
			tool_c = "screwdriver"
			tool_behaviour = TOOL_SCREWDRIVER
			sharp = TRUE
		else
			tool_c = "wirecutters"
			tool_behaviour = TOOL_WIRECUTTER
			sharp = FALSE
	else if(tool_c == "screwdriver")
		if(wirecutters)
			tool_c = "wirecutters"
			tool_behaviour = TOOL_WIRECUTTER
			sharp = FALSE
		else
			tool_c = "multitool"
			tool_behaviour = TOOL_MULTITOOL
			sharp = FALSE
	else if(tool_c == "wirecutters")
		tool_c = "multitool"
		tool_behaviour = TOOL_MULTITOOL
		sharp = FALSE
	update_icon()
	return

/obj/item/device/multitool/advtool/attack_self(mob/user)
	if(!screwdriver && !wirecutters)
		to_chat(user, SPAN_NOTICE("[src] lacks tools."))
		return

	switchtools()
	to_chat(user, SPAN_NOTICE("[src] mode: [tool_c]."))
	update_icon()
	return


/obj/item/device/multitool/advtool/attack_hand(mob/user)
	if(src != user.get_inactive_hand())
		return ..()

	if(!contents.len)
		to_chat(user, SPAN_WARNING("There's nothing in \the [src] to remove!"))
		return

	var/choice = input(user, "What would you like to remove from the [src]?") as null|anything in src.contents
	if(!choice || !(choice in src.contents))
		return

	if(choice == multitool)
		to_chat(user, SPAN_WARNING("You cannot remove the multitool itself."))
		return

	if(user.pick_or_drop(choice))
		to_chat(user, SPAN_NOTICE("You remove \the [choice] from \the [src]."))
		src.contents -= choice
		if(choice == wirecutters)
			wirecutters = null
		else if(choice == screwdriver)
			screwdriver = null
	else
		to_chat(user, SPAN_WARNING("Something went wrong, please try again."))

	tool_c = "multitool"
	tool_behaviour = TOOL_MULTITOOL
	update_icon()
	return

/obj/item/device/multitool/advtool/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/screwdriver/advpart))
		var/obj/item/screwdriver/advpart/SD = I
		if(!screwdriver)
			contents += SD
			user.drop(SD, src)
			screwdriver = SD
			to_chat(user, SPAN_NOTICE("You insert \the [SD] into \the [src]."))
			update_icon()
		else
			to_chat(user, SPAN_WARNING("There's already \the [screwdriver] in \the [src]!"))
	else if(istype(I, /obj/item/wirecutters/advpart))
		var/obj/item/screwdriver/advpart/WC = I
		if(!wirecutters)
			contents += WC
			user.drop(WC, src)
			wirecutters = WC
			to_chat(user, SPAN_NOTICE("You insert \the [WC] into \the [src]."))
			update_icon()
		else
			to_chat(user, SPAN_WARNING("There are already \the [wirecutters] in \the [src]!"))
	else
		return ..()


/obj/item/device/multitool/advpart
	name = "compact multitool"
	desc = "You are not supposed to see this, use this or interact with this at all. However, if nobody knows..."
	description_info = "Multitools are incredibly versatile and can be used on a wide variety of machines. The most common use for this is to trip a device's wires without having to cut them. Simply click on an object with exposed wiring to use it. There might be other uses, as well..."
	description_fluff = "The common, every day multitool is descended from certain electrical tools from Earth's early space age. Though none too cheap, they are incredibly handy, and can be found in any self-respecting technician's toolbox."
	description_antag = "This handy little tool can get you through doors, turn off power, and anything else you might need."
	item_state = "multitool"
	icon_state = "adv_multitool"
	force = 3.5
	w_class = ITEM_SIZE_TINY
	throwforce = 3.5
	throw_range = 15
	origin_tech = list(TECH_MAGNET = 2, TECH_ENGINEERING = 4)
	matter = list(MATERIAL_STEEL = 25, MATERIAL_GLASS = 20)

/obj/item/screwdriver/advpart
	name = "compact screwdriver"
	desc = "Just a regular screwdriver. However, this one is especially small."
	description_info = "This tool is used to expose or safely hide away cabling. It can open and shut the maintenance panels on vending machines, airlocks, and much more. You can also use it, in combination with a crowbar, to install or remove windows."
	description_fluff = "Screws have not changed significantly in centuries, and neither have the drivers used to install and remove them."
	description_antag = "In the world of breaking and entering, tools like multitools and wirecutters are the bread; the screwdriver is the butter. In a pinch, try targetting someone's eyes and stabbing them with it - it'll really hurt!"
	icon = 'icons/obj/device.dmi'
	icon_state = "adv_screwdriver"
	item_state = "screwdriver"
	slot_flags = SLOT_BELT | SLOT_EARS
	force = 5.0
	origin_tech = list(TECH_ENGINEERING = 4)
	matter = list(MATERIAL_STEEL = 45)
	lock_picking_level = 6

/obj/item/screwdriver/advpart/Initialize()
	. = ..()
	icon_state = "adv_screwdriver"
	item_state = "screwdriver"

/obj/item/wirecutters/advpart
	name = "compact wirecutters"
	desc = "A special pair of pliers with cutting edges. Various brackets and manipulators built into the handle allow it to repair severed wiring. This pair has some insulation."
	description_info = "This tool will cut wiring anywhere you see it - make sure to wear insulated gloves! When used on more complicated machines or airlocks, it can not only cut cables, but repair them, as well."
	description_fluff = "With modern alloys, today's wirecutters can snap through cables of astonishing thickness."
	description_antag = "These cutters can be used to cripple the power anywhere on the ship. All it takes is some creativity, and being in the right place at the right time."
	icon = 'icons/obj/device.dmi'
	item_state = "cutters"
	icon_state = "adv_wirecutters"
	slot_flags = SLOT_BELT | SLOT_EARS
	w_class = ITEM_SIZE_TINY
	origin_tech = list(TECH_ENGINEERING = 4)
	matter = list(MATERIAL_STEEL = 80)

/obj/item/wirecutters/advpart/Initialize()
	. = ..()
	icon_state = "adv_wirecutters"
	item_state = "cutters"
