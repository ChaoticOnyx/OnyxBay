
// Light Replacer (LR)
//
// ABOUT THE DEVICE
//
// This is a device supposedly to be used by Janitors and Janitor Cyborgs which will
// allow them to easily replace lights. This was mostly designed for Janitor Cyborgs since
// they don't have hands or a way to replace lightbulbs.
//
// HOW IT WORKS
//
// You attack a light fixture with it, if the light fixture is broken it will replace the
// light fixture with a working light; the broken light is then placed on the floor for the
// user to then pickup with a trash bag. If it's empty then it will just place a light in the fixture.
//
// HOW TO REFILL THE DEVICE
//
// It can be manually refilled or by clicking on a storage item containing lights.
// If it's part of a robot module, it will charge when the Robot is inside a Recharge Station.
//
// EMAGGED FEATURES
//
// NOTICE: The Cyborg cannot use the emagged Light Replacer and the light's explosion was nerfed. It cannot create holes in the station anymore.
//
// I'm not sure everyone will react the emag's features so please say what your opinions are of it.
//
// When emagged it will rig every light it replaces, which will explode when the light is on.
// This is VERY noticable, even the device's name changes when you emag it so if anyone
// examines you when you're holding it in your hand, you will be discovered.
// It will also be very obvious who is setting all these lights off, since only Janitor Borgs and Janitors have easy
// access to them, and only one of them can emag their device.
//
// The explosion cannot insta-kill anyone with 30% or more health.

#define LIGHT_OK 0
#define LIGHT_EMPTY 1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3

#define DEFAULT_BULB_TYPE /obj/item/light/tube

/obj/item/device/lightreplacer

	name = "light replacer"
	desc = "A lightweight automated device, capable of interfacing with and rapidly replacing standard light installations."
	description_info = "Examine or use this item to see how many lights are remaining. You can feed it lightbulbs or sheets of glass to refill it."
	description_fluff = "Can you believe they used to have to screw lightbulbs in by hand?"
	description_antag = "Using a cryptographic sequencer on this device will cause it to overload each light it replaces; when turned on, the new lights will explode!"

	icon = 'icons/obj/janitor.dmi'
	icon_state = "lightreplacer0"
	item_state = "lightreplacer"

	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	origin_tech = list(TECH_MAGNET = 3, TECH_MATERIAL = 2)

	var/max_uses = 20
	/// Assoc list of loaded bulbs [type] -> [amount]
	var/list/bulbs_assoc = list(DEFAULT_BULB_TYPE = 10)
	var/emagged = 0
	var/failmsg = ""
	var/charge = 0
	var/load_interval = 30
	var/store_broken = 0// If set, this lightreplacer will suck up and store broken bulbs
	var/max_stored = 10
	var/load_queue = FALSE

/obj/item/device/lightreplacer/advanced
	store_broken = 1
	load_interval = 10
	max_uses = 30
	bulbs_assoc = list()
	name = "advanced light replacer"
	desc = "A specialised light replacer which stores more lights and refills faster from boxes."
	icon_state = "adv_lightreplacer"
	item_state = "adv_lightreplacer"

/obj/item/device/lightreplacer/New()
	failmsg = "The [name]'s refill light blinks red."
	..()

/obj/item/device/lightreplacer/examine(mob/user, infix)
	. = ..()

	if(get_dist(src, user) > 2)
		return

	. += "It has [bulbs_amt()] light\s remaining."

	if (store_broken)
		. += "It is storing [stored()]/[max_stored] broken light\s."

/obj/item/device/lightreplacer/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/stack/material) && W.get_material_name() == MATERIAL_GLASS)
		var/obj/item/stack/G = W
		if(bulbs_amt() >= max_uses)
			to_chat(user, "<span class='warning'>[src.name] is full.</span>")
			return
		else if(G.use(5))
			bulbs_assoc[DEFAULT_BULB_TYPE] += 2
			if(prob(50))
				bulbs_assoc[DEFAULT_BULB_TYPE] += 1
			to_chat(user, "<span class='notice'>You insert a piece of glass into \the [src.name]. You have [bulbs_amt()] light\s remaining.</span>")
			return
		else
			to_chat(user, "<span class='warning'>You need 5 sheets of glass to replace lights.</span>")

	if(istype(W, /obj/item/light))
		var/obj/item/light/L = W
		if(L.status == 0) // LIGHT OKAY
			if(bulbs_amt() < max_uses)
				to_chat(user, "You insert \the [L.name] into \the [src.name]. You have [bulbs_amt()] light\s remaining.")
				load_bulb_and_qdel(L)
				return
		else
			to_chat(user, "You need a working light.")
			return

/obj/item/device/lightreplacer/afterattack(atom/target, mob/living/user, proximity, params)
	if(istype(target, /obj/item/storage/box))
		if(box_contains_lights(target))
			load_lights_from_box(target, user)
		else
			to_chat(user, "This box has no bulbs in it!")
	if(istype(target, /obj/item/light))
		if(!isturf(target.loc))
			return
		var/obj/item/light/L = target
		if(L.status != 0)
			return
		if(load_queue || bulbs_amt() >= max_uses)
			to_chat(user, "\The [src] is already full!")
			return

		to_chat(user, SPAN("notice", "Light loaded: [bulbs_amt()]/[max_uses]"))
		playsound(loc, 'sound/machines/click.ogg', 20, 1)
		load_bulb_and_qdel(L)

/// Adds amount of L.type available bulbs and qdels L
/obj/item/device/lightreplacer/proc/load_bulb_and_qdel(obj/item/light/L)
	bulbs_assoc[L.type]++
	qdel(L)

/// Total amount of available bulbs
/obj/item/device/lightreplacer/proc/bulbs_amt()
	var/amt = 0
	for(var/type in bulbs_assoc)
		amt += bulbs_assoc[type]

	return amt

/obj/item/device/lightreplacer/proc/box_contains_lights(obj/item/storage/box/box)
	for(var/obj/item/light/L in box.contents)
		if(L.status == 0)
			return TRUE
	return FALSE


/obj/item/device/lightreplacer/proc/load_lights_from_box(obj/item/storage/box/box, mob/user)
	var/boxstartloc = box.loc
	var/ourstartloc = loc
	if(load_queue)
		return
	if(bulbs_amt() >= max_uses)
		to_chat(user, "\The [src] is already full!")
		return
	load_queue = TRUE
	user.visible_message(SPAN("notice", "[user] starts loading lights from \the [box] into their [src]."), SPAN("notice", "You start loading lights from the [box] into the [src]."))
	while(bulbs_amt() < max_uses)
		var/bulb = null
		for(var/obj/item/light/L in box.contents)
			if(L.status == 0)
				bulb = L
				break

		if(!bulb)
			to_chat(user, SPAN("warning", "There are no more working lights left in \the [box]!"))
			load_queue = FALSE
			return

		if(do_after(user, load_interval, needhand = 0) && boxstartloc == box.loc && ourstartloc == loc)
			to_chat(user, SPAN("notice", "Light loaded: [bulbs_amt()]/[max_uses]"))
			playsound(loc, 'sound/machines/click.ogg', 20, 1)
			box.remove_from_storage(bulb, get_turf(box))
			load_bulb_and_qdel(bulb)
		else
			to_chat(usr, SPAN("warning", "You need to keep \the [src] close to \the [box]!"))
			load_queue = FALSE
			return

	load_queue = FALSE
	to_chat(user, SPAN("notice", "\The [src]'s refill light shines a solid green, indicating it's full and ready to go!"))

/obj/item/device/lightreplacer/proc/stored()
	var/count = 0
	for (var/obj/item/light/L in src)
		count++

	return count

/obj/item/device/lightreplacer/attack_self(mob/user)
	/* // This would probably be a bit OP. If you want it though, uncomment the code.
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(R.emagged)
			src.Emag()
			to_chat(usr, "You shortcircuit the [src].")
			return
	*/
	to_chat(user, "It has [bulbs_amt()] lights remaining.")

/obj/item/device/lightreplacer/on_update_icon()
	icon_state = "lightreplacer[emagged]"


/obj/item/device/lightreplacer/proc/Use(mob/user, obj/machinery/light/target)
	playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
	for(var/path in bulbs_assoc)
		if(bulbs_assoc[path] <= 0)
			continue

		if(!ispath(path, target.light_type))
			continue

		bulbs_assoc[path]--
		if(bulbs_assoc[path] <= 0)
			bulbs_assoc -= path

		var/obj/item/light/L = new path(get_turf(src))
		return L

	playsound(src.loc, 'sound/machines/triple_beep.ogg', 50, 1)
	return FALSE

/obj/item/device/lightreplacer/proc/Charge(mob/user, amount = 1)
	charge += amount
	if(charge > 6)
		bulbs_assoc[DEFAULT_BULB_TYPE]++
		charge = 0

/obj/item/device/lightreplacer/proc/ReplaceLight(obj/machinery/light/target, mob/living/U)

	if(target.get_status() == LIGHT_OK)
		to_chat(U, "There is a working [target.get_fitting_name()] already inserted.")
	else if(!CanUse(U))
		to_chat(U, failmsg)

	var/obj/item/light/bulb = Use(U, target)
	if(!istype(bulb))
		return

	to_chat(U, "<span class='notice'>You replace the [target.get_fitting_name()] with the [src].</span>")

	if(target.lightbulb)
		var/obj/item/light/lightbulb = target.remove_bulb()
		if(store_broken && !(stored() >= max_stored))
			lightbulb.forceMove(src)

	bulb.rigged = emagged
	target.insert_bulb(bulb)

/obj/item/device/lightreplacer/emag_act(remaining_charges, mob/user)
	emagged = !emagged
	playsound(src.loc, SFX_SPARK, 100, 1)
	update_icon()
	return 1

//Can you use it?

/obj/item/device/lightreplacer/proc/CanUse(mob/living/user)
	src.add_fingerprint(user)
	//Not sure what else to check for. Maybe if clumsy?
	if(bulbs_amt() > 0)
		return 1
	else
		return 0

#undef LIGHT_OK
#undef LIGHT_EMPTY
#undef LIGHT_BROKEN
#undef LIGHT_BURNED
