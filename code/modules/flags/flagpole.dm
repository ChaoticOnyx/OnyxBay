/obj/item/flagpole
	name = "tabletop flag stand"
	desc = "Patriotic display for office use."

	icon = 'icons/obj/flags/flags-32.dmi'
	icon_state = "bannerflag_table_empty"
	base_icon_state = "bannerflag_table"

	w_class = ITEM_SIZE_SMALL

	force = 6.0
	throwforce = 5.0
	throw_range = 7

	mod_handy = 0.7
	mod_reach = 0.8
	mod_weight = 0.6
	mod_speed = 1.0

	attack_verb = list("tapped", "poked", "smacked", "bonked")
	hitsound = SFX_FIGHTING_SWING

	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand_bannerflag.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand_bannerflag.dmi'
	)

	/// Amount of material given when deconstructed.
	var/material_amount = 1

	/// Typepath for the default flag appearance datum.
	var/flag_appearance_type
	/// Currently mounted flag appearance, or null if empty.
	var/datum/flag_appearance/flag_appearance

/obj/item/flagpole/Initialize()
	. = ..()
	if (flag_appearance_type)
		var/datum/flag_appearance/new_flag_appearance = GLOB.flag_appearances[flag_appearance_type]
		if (!istype(new_flag_appearance))
			log_debug("Failed to find '[flag_appearance_type]' in global appearance cache.", loc)
			return INITIALIZE_HINT_QDEL

		change_flag(new_flag_appearance, color)

/obj/item/flagpole/examine(mob/user, infix)
	. = ..()
	if (flag_appearance)
		. += flag_appearance.desc

/obj/item/flagpole/on_update_icon()
	ClearOverlays()

	if (isnull(flag_appearance))
		icon_state = "[base_icon_state]_empty"
		item_state = icon_state
		appearance_flags |= RESET_COLOR
		return

	icon_state = "[base_icon_state]_[flag_appearance.icon_state]"
	item_state = icon_state
	appearance_flags &= ~RESET_COLOR

	AddOverlays(overlay_image(icon, "[base_icon_state]_overlay", flags = RESET_COLOR))

/obj/item/flagpole/attackby(obj/item/W, mob/user)
	if (attempt_flag_insert(W, user))
		return TRUE

	if (isWrench(W) && (obj_flags & OBJ_FLAG_ANCHORABLE) && (loc == get_turf(src)))
		wrench_floor_bolts(user)
		return TRUE

	if (attempt_deconstruct(W, user))
		return TRUE

	return ..()

/obj/item/flagpole/proc/attempt_flag_insert(obj/item/flag/flag, mob/user)
	if (!istype(flag))
		return FALSE

	if (!isnull(flag_appearance))
		show_splash_text(user, "already has a flag", "\The [src] already has a flag mounted.")
		return FALSE

	change_flag(flag.flag_appearance, flag.color)

	show_splash_text(user, "flag attached", "You attach \the [flag_appearance.name] flag into \the [src] and raise it.")
	playsound(src, SFX_PICKUP_CLOTH, 40)

	qdel(flag)
	return TRUE

/obj/item/flagpole/proc/attempt_deconstruct(obj/item/weldingtool/welder, mob/user)
	if (atom_flags & ATOM_FLAG_NO_DECONSTRUCTION)
		return FALSE

	if (!istype(welder))
		return FALSE

	if (!welder.use_tool(src, user, delay = 1 SECONDS, amount = material_amount * 10))
		return FALSE

	if (QDELETED(src) || !user)
		return FALSE

	var/turf/loc_turf = get_turf(src)
	loc_turf?.show_splash_text(user, "deconstructed", "You deconstruct \the [src]",)
	new /obj/item/stack/material/steel(loc, material_amount)
	qdel(src)

	return TRUE

/obj/item/flagpole/AltClick(mob/user)
	if (attempt_flag_remove(user))
		return TRUE

	return ..()

/obj/item/flagpole/proc/attempt_flag_remove(mob/user)
	if(user.stat || user.restrained() || user.paralysis || user.stunned || user.weakened)
		return FALSE

	if (!Adjacent(user))
		return FALSE

	if (isnull(flag_appearance))
		return FALSE

	if (atom_flags & ATOM_FLAG_NO_DECONSTRUCTION)
		return FALSE

	var/obj/item/flag/folded_flag = new
	folded_flag.set_flag_appearance(flag_appearance, color)
	user.pick_or_drop(folded_flag, get_turf(user))

	show_splash_text(user, "flag removed", "You lower and remove [flag_appearance.name] from \the [src].")
	playsound(src, SFX_DROP_CLOTH, 40)

	change_flag(null, null)
	return TRUE

/obj/item/flagpole/proc/change_flag(datum/flag_appearance/new_flag, new_color)
	flag_appearance = new_flag
	color = new_flag ? (new_color || flag_appearance.color) : null
	if (flag_appearance)
		ADD_FLAG_PREVIEW(flag_appearance.icon_state)
	else
		REMOVE_FLAG_PREVIEW
	update_icon()
	update_name()

/obj/item/flagpole/proc/update_name()
	var/name_prefix = isnull(flag_appearance) ? "empty" : flag_appearance.name
	name = "\improper [name_prefix] [initial(name)]"

/obj/item/flagpole/telescopic
	name = "flag staff"
	desc = SPAN_BOLD("To the rally point!")

	icon_state = "bannerflag_stem_empty"

	obj_flags = OBJ_FLAG_ANCHORABLE

	w_class = ITEM_SIZE_HUGE

	force = 9.5
	throwforce = 7.0
	throw_range = 10

	mod_handy = 0.85
	mod_reach = 1.6
	mod_weight = 1.2
	mod_shield = 1.1

	attack_verb = list("hit", "smashed", "whacked", "bashed", "struck")

	material_amount = 3

	/// Whether this flagpole is in its standing position.
	var/deployed = TRUE
	/// Display name when deployed.
	var/deployed_name = "flag stand"
	/// Display description when deployed.
	var/deployed_desc = "You have to vow before it."

	/// Base icon state used when deployed.
	var/base_icon_state_deployed = "bannerflag_stem"
	/// Base icon state used when folded / carried.
	var/base_icon_state_folded = "bannerflag_pole"

/obj/item/flagpole/telescopic/deployed
	deployed = TRUE

/obj/item/flagpole/telescopic/Initialize()
	. = ..()
	set_deployed(deployed)

/obj/item/flagpole/telescopic/update_name()
	var/name_prefix = isnull(flag_appearance) ? "empty" : flag_appearance.name
	var/name_base = deployed ? deployed_name : initial(name)
	name = "\improper [name_prefix] [name_base]"
	desc = deployed ? deployed_desc : initial(desc)

/obj/item/flagpole/telescopic/attack_self(mob/user)
	. = ..()
	set_deployed(TRUE)
	user.drop(src)

/obj/item/flagpole/telescopic/pickup()
	. = ..()
	set_deployed(FALSE)

/obj/item/flagpole/telescopic/proc/set_deployed(new_deployed)
	deployed = new_deployed
	pixel_x = 0
	pixel_y = 0
	randpixel = deployed ? 0 : initial(randpixel)
	base_icon_state = deployed ? base_icon_state_deployed : base_icon_state_folded
	update_icon()
	update_name()
