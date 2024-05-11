//RAPID HANDHELD DEVICE. the base for all rapid devices

#define MATTER_REDUCTION_COEFFICIENT 5

/obj/item/construction
	name = "not for ingame use"
	desc = "A device used to rapidly build and deconstruct. Reload with iron, plasteel, glass or compressed local_matter cartridges."
	opacity = FALSE
	density = FALSE
	anchored = FALSE
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	force = 10
	throwforce = 10
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	mod_weight = 1.0
	mod_reach = 0.75
	mod_handy = 1.0

	/// the spark system which sparks whever the ui options are dited
	var/datum/effect/effect/system/spark_spread/spark_system
	/// current local local_matter inside the device
	var/local_matter = 0
	/// maximum local local_matter this device can hold
	var/max_matter = 100
	/// controls whether or not does update_icon apply ammo indicator overlays
	var/has_ammobar = FALSE
	/// amount of divisions in the ammo indicator overlay/number of ammo indicator states
	var/ammo_sections = 10
	/// bitflags for upgrades
	var/upgrade = 0
	/// bitflags for banned upgrades
	var/banned_upgrades = 0
	/// switch to use internal or remote storage
	var/silo_link = FALSE

/obj/item/construction/Initialize(mapload)
	. = ..()
	spark_system = new /datum/effect/effect/system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

///returns local local_matter units available. overriden by rcd borg to return power units available
/obj/item/construction/proc/get_matter(mob/user)
	return local_matter

/obj/item/construction/examine(mob/user, infix)
	. = ..()
	. += "It currently holds [get_matter(user)]/[max_matter] matter-units."

/obj/item/construction/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/item/construction/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/rcd_upgrade))
		install_upgrade(item, user)
		return TRUE
	if(insert_matter(item, user))
		return TRUE
	return ..()

/// Installs an upgrade into the RCD checking if it is already installed, or if it is a banned upgrade
/obj/item/construction/proc/install_upgrade(obj/item/rcd_upgrade/design_disk, mob/user)
	if(design_disk.upgrade & upgrade)
		show_splash_text(user, "already installed!", SPAN("warning", "\The [src] already has this upgrade!"))
		return FALSE
	if(design_disk.upgrade & banned_upgrades)
		show_splash_text(user, "cannot install upgrade!", SPAN("warning", "\The [src] cannot have this upgrade!"))
		return FALSE
	upgrade |= design_disk.upgrade
	playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
	qdel(design_disk)
	return TRUE

/// Inserts local_matter into the RCD allowing it to build
/obj/item/construction/proc/insert_matter(obj/item, mob/user)
	if(issilicon(user))
		return FALSE

	var/loaded = FALSE
	if(istype(item, /obj/item/rcd_ammo))
		var/obj/item/rcd_ammo/ammo = item
		var/load = min(ammo.ammoamt, max_matter - local_matter)
		if(load <= 0)
			show_splash_text(user, "storage full!", SPAN("warning", "\The [src] is full!"))
			return FALSE
		ammo.ammoamt -= load
		if(ammo.ammoamt <= 0)
			qdel(ammo)
		local_matter += load
		playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
		loaded = TRUE
	else if(isstack(item))
		loaded = loadwithsheets(item, user)
	if(loaded)
		update_icon() //ensures that ammo counters (if present) get updated
	return loaded

/obj/item/construction/proc/loadwithsheets(obj/item/stack/the_stack, mob/user)
	if(the_stack.amount <= 0)
		show_splash_text(user, "invalid sheets!", SPAN("warning", "\The [src] refuses to accept this."))
		return FALSE

	var/sheet_amt_to_matter = round(the_stack.amount / MATTER_REDUCTION_COEFFICIENT)
	var/maxsheets = round(((max_matter - local_matter) - sheet_amt_to_matter) * MATTER_REDUCTION_COEFFICIENT) //calculate the max number of sheets that will fit in RCD
	if(maxsheets > 0)
		var/amount_to_use = min(the_stack.amount, maxsheets)
		the_stack.use(amount_to_use)
		local_matter += round(amount_to_use / MATTER_REDUCTION_COEFFICIENT)
		playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
		return TRUE

	show_splash_text(user, "storage full!", SPAN("warning", "\The [src] is full!"))
	return FALSE

/obj/item/construction/proc/activate()
	playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)

/obj/item/construction/attack_self(mob/user)
	playsound(loc, 'sound/effects/pop.ogg', 50, FALSE)
	if(prob(20))
		spark_system.start()

/obj/item/construction/on_update_icon()
	. = ..()
	if(has_ammobar)
		var/ratio = CEILING((local_matter / max_matter) * ammo_sections, 1)
		if(ratio > 0)
			. += "[icon_state]_charge[ratio]"

/obj/item/construction/proc/useResource(amount, mob/user)
	if(local_matter < amount)
		if(user)
			show_splash_text(user, "not enough local_matter!", SPAN("warning", "Not enough local_matter!"))
		return FALSE

	local_matter -= amount
	update_icon()
	return TRUE

///shared data for rcd,rld & plumbing
/obj/item/construction/tgui_data(mob/user)
	var/list/data = list()

	//local_matter in the rcd
	var/total_matter = get_matter(user)
	if(!total_matter)
		total_matter = 0
	data["matterLeft"] = total_matter

	return data

///shared action for toggling silo link rcd,rld & plumbing
/obj/item/construction/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/update = handle_ui_act(action, params, ui, state)
	if(isnull(update))
		update = FALSE
	return update

/// overwrite to insert custom ui handling for subtypes
/obj/item/construction/proc/handle_ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	return null

/obj/item/construction/proc/checkResource(amount, mob/user)
	. = local_matter >= amount

	if(!. && user)
		show_splash_text(user, "low ammo!", SPAN("warning", "Not enough matter!"))
		if(has_ammobar)
			flick("[icon_state]_empty", src) //somewhat hacky thing to make RCDs with ammo counters actually have a blinking yellow light

	return .

/obj/item/construction/proc/range_check(atom/target, mob/user)
	if(target.z != user.z)
		return
	if(!(target in dview(7, get_turf(user))))
		show_splash_text(user, "out of range!", SPAN("warning", "Out of range!"))
		flick("[icon_state]_empty", src)
		return FALSE
	else
		return TRUE

/**
 * Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The living mob interacting with the menu
 * * remote_anchor The remote anchor for the menu
 */
/obj/item/construction/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE

	if(user.incapacitated())
		return FALSE

	return TRUE

/obj/item/rcd_upgrade
	name = "RCD advanced design disk"
	desc = "It seems to be empty."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk2"
	item_state = "card-id"
	var/upgrade

/obj/item/rcd_upgrade/frames
	desc = "It contains the design for machine frames and computer frames."
	upgrade = RCD_UPGRADE_FRAMES

/obj/item/rcd_upgrade/simple_circuits
	desc = "It contains the design for firelock, air alarm, fire alarm, apc circuits and crap power cells."
	upgrade = RCD_UPGRADE_SIMPLE_CIRCUITS

/obj/item/rcd_upgrade/anti_interrupt
	desc = "It contains the upgrades necessary to prevent interruption of RCD construction and deconstruction."
	upgrade = RCD_UPGRADE_ANTI_INTERRUPT

/obj/item/rcd_upgrade/cooling
	desc = "It contains the upgrades necessary to allow more frequent use of the RCD."
	upgrade = RCD_UPGRADE_NO_FREQUENT_USE_COOLDOWN

/obj/item/rcd_upgrade/furnishing
	desc = "It contains the design for chairs, stools, tables, and glass tables."
	upgrade = RCD_UPGRADE_FURNISHING

/**
 * Produces a new RCD result from the given one if it can be calculated that
 * the RCD should speed up with the remembered form.
 *
 */
/proc/rcd_result_with_memory(list/defaults, turf/place, expected_memory)
	if(place?.rcd_memory == expected_memory)
		return defaults + list(
			"cost" = defaults["cost"] / RCD_MEMORY_COST_BUFF,
			"delay" = defaults["delay"] / RCD_MEMORY_SPEED_BUFF,
			RCD_RESULT_BYPASS_FREQUENT_USE_COOLDOWN = TRUE,
		)
	else
		return defaults

#undef MATTER_REDUCTION_COEFFICIENT
