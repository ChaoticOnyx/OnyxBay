

// Combined tools.
// Basically, these allow you to store various tools inside them, switch between these tools and use them directly.
// TODO list: surgery multitool for borgs, swiss knives, detective's advanced sampler (fingerprints, fiber, replaceable swab vials), modular hypospray, modular RCP ~~Toby
/obj/item/weapon/combotool
	name = "generic combined tool"
	desc = "A swiss knife?"
	icon = 'icons/obj/device.dmi'
	item_state = "device"
	icon_state = "combotool"
	mod_weight = 0.5
	mod_reach = 0.5
	mod_handy = 0.5

	var/tool_c = null
	var/tool_u = null

/obj/item/weapon/combotool/proc/switchtools()
	return

/obj/item/weapon/combotool/attack_self(mob/user)
	switchtools()
	to_chat(user, "<span class='notice'>[src] mode: [tool_c].</span>")
	update_icon()
	return

/obj/item/weapon/combotool/resolve_attackby(var/atom/a, var/mob/user, var/click_params)
	if(istype(a, /obj/item/weapon/storage))
		a.attackby(src, user)
		return
	if(istype(a, /obj/structure/table) && user.a_intent == I_DISARM)
		a.attackby(src, user)
		return
	a.attackby(tool_u, user)
	return

/obj/item/weapon/combotool/update_icon()
	underlays.Cut()
	underlays += "adv_[tool_c]"
	..()


/obj/item/weapon/combotool/advtool
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
	throw_speed = 3

	matter = list(DEFAULT_WALL_MATERIAL = 500,"glass" = 200)

	origin_tech = list(TECH_MAGNET = 2, TECH_ENGINEERING = 4)

	var/obj/item/device/multitool/advpart/multitool = null
	var/obj/item/weapon/screwdriver/advpart/screwdriver = null
	var/obj/item/weapon/wirecutters/advpart/wirecutters = null


/obj/item/weapon/combotool/advtool/New()
	..()
	multitool = new /obj/item/device/multitool/advpart(src)
	screwdriver = new /obj/item/weapon/screwdriver/advpart(src)
	wirecutters = new /obj/item/weapon/wirecutters/advpart(src)
	tool_c = "multitool"
	tool_u = multitool

/obj/item/weapon/combotool/advtool/switchtools()
	if(tool_c == "multitool")
		if(screwdriver)
			tool_c = "screwdriver"
			tool_u = screwdriver
		else
			tool_c = "wirecutters"
			tool_u = wirecutters
	else if(tool_c == "screwdriver")
		if(wirecutters)
			tool_c = "wirecutters"
			tool_u = wirecutters
		else
			tool_c = "multitool"
			tool_u = multitool
	else if(tool_c == "wirecutters")
		tool_c = "multitool"
		tool_u = multitool
	update_icon()
	return

/obj/item/weapon/combotool/advtool/attack_self(mob/user)
	if(!screwdriver && !wirecutters)
		to_chat(user, "<span class='notice'>[src] lacks tools.</span>")
		return
	..()

/obj/item/weapon/combotool/advtool/attack_hand(mob/user as mob)
	if(src != user.get_inactive_hand())
		return ..()

	if(!src.contents.len)
		to_chat(user, "<span class=warning>There's nothing in \the [src] to remove!</span>")
		return

	var/choice = input(user, "What would you like to remove from the [src]?") as null|anything in src.contents
	if(!choice || !(choice in src.contents))
		return

	if(choice == multitool)
		to_chat(user, "<span class=warning>You cannot remove the multitool itself.</span>")
		return

	if(user.put_in_active_hand(choice))
		to_chat(user, "<span class=notice>You remove \the [choice] from \the [src].</span>")
		src.contents -= choice
		if(choice == wirecutters)
			wirecutters = null
		else if(choice == screwdriver)
			screwdriver = null
	else
		to_chat(user, "<span class=warning>Something went wrong, please try again.</span>")

	tool_c = "multitool"
	tool_u = multitool
	update_icon()
	return

/obj/item/weapon/combotool/advtool/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/screwdriver/advpart))
		var/obj/item/weapon/screwdriver/advpart/SD = I
		if(!screwdriver)
			src.contents += SD
			user.remove_from_mob(SD)
			SD.loc = src
			screwdriver = SD
			to_chat(user, "<span class=notice>You insert \the [SD] into \the [src].</span>")
			update_icon()
		else
			to_chat(user, "<span class=warning>There's already \the [screwdriver] in \the [src]!</span>")
	else if(istype(I, /obj/item/weapon/wirecutters/advpart))
		var/obj/item/weapon/screwdriver/advpart/WC = I
		if(!wirecutters)
			src.contents += WC
			user.remove_from_mob(WC)
			WC.loc = src
			wirecutters = WC
			to_chat(user, "<span class=notice>You insert \the [WC] into \the [src].</span>")
			update_icon()
		else
			to_chat(user, "<span class=warning>There are already \the [wirecutters] in \the [src]!</span>")
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
	throw_speed = 3
	origin_tech = list(TECH_MAGNET = 2, TECH_ENGINEERING = 4)
	matter = list(DEFAULT_WALL_MATERIAL = 25,"glass" = 20)

/obj/item/weapon/screwdriver/advpart
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
	matter = list(DEFAULT_WALL_MATERIAL = 45)
	lock_picking_level = 6

/obj/item/weapon/screwdriver/advpart/Initialize()
	. = ..()
	icon_state = "adv_screwdriver"
	item_state = "screwdriver"

/obj/item/weapon/wirecutters/advpart
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
	matter = list(DEFAULT_WALL_MATERIAL = 80)

/obj/item/weapon/wirecutters/advpart/Initialize()
	. = ..()
	icon_state = "adv_wirecutters"
	item_state = "cutters"