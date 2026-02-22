

/obj/item/flag
	name = "folded flag"
	desc = SPAN_BOLD("Meaningful") + " fabric carefully folded into a triangle shape."

	icon = 'icons/obj/flags/flags-32.dmi'
	base_icon_state = "bannerflag_folded"

	slot_flags = SLOT_BACK

	w_class = ITEM_SIZE_NORMAL

	drop_sound = SFX_DROP_CLOTH
	pickup_sound = SFX_PICKUP_CLOTH

	/// Typepath for the default flag appearance datum.
	var/flag_appearance_type
	/// Currently mounted flag appearance.
	var/datum/flag_appearance/flag_appearance

	/// Base icon state used when in the backpack slot.
	var/base_icon_state_back = "bannerflag_great_64"

/obj/item/flag/Initialize(mapload)
	. = ..()
	if (mapload && !flag_appearance_type)
		log_debug("Detected attempt to create folded flag with nullish appearance.", loc)
		return INITIALIZE_HINT_QDEL

	if (flag_appearance_type)
		var/datum/flag_appearance/new_flag_appearance = GLOB.flag_appearances[flag_appearance_type]
		if (!istype(new_flag_appearance))
			log_debug("Failed to find '[flag_appearance_type]' in global appearance cache.", loc)
			return INITIALIZE_HINT_QDEL

		set_flag_appearance(new_flag_appearance, color)

/obj/item/flag/proc/set_flag_appearance(datum/flag_appearance/new_appearance, new_color)
	flag_appearance = new_appearance
	color = new_color || flag_appearance.color
	name = "\improper [flag_appearance.name] [initial(name)]"
	update_icon()
	ADD_FLAG_PREVIEW(flag_appearance.icon_state)

/obj/item/flag/examine(mob/user, infix)
	. = ..()
	. += flag_appearance.desc

/obj/item/flag/on_update_icon()
	ClearOverlays()

	icon_state = "[base_icon_state]_[flag_appearance.icon_state]"
	item_state = icon_state
	item_state_slots[slot_back_str] = "[base_icon_state_back]_[flag_appearance.icon_state]"
	icon = initial(icon)

	AddOverlays(overlay_image(icon, "[base_icon_state]_overlay", flags = RESET_COLOR))

#define FLAG_CHOICES list(\
/obj/structure/sign/flag,\
/obj/structure/sign/flag/medium,\
/obj/structure/sign/flag/large,\
/obj/structure/sign/flag/pennant,\
)

/obj/item/flag/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if (!proximity_flag)
		return

	var/turf/loc_turf = get_turf(user)
	if (!iswall(target) || !isfloor(loc_turf))
		return

	var/new_dir = get_dir(user, target)
	if (!(new_dir in GLOB.cardinal))
		return

	if (gotwallitem(loc_turf, new_dir))
		return

	var/list/choices = list()
	for (var/obj/structure/sign/flag/typepath as anything in FLAG_CHOICES)
		var/image/preview = image(typepath::icon, "[typepath::base_icon_state]_[flag_appearance.icon_state]")
		choices[typepath] = preview

	var/choice = show_radial_menu(user, target, choices, require_near = TRUE)
	if (isnull(choice))
		return

	var/obj/structure/sign/flag/wall_flag = new choice(loc_turf)
	wall_flag.set_flag_appearance(flag_appearance, color)
	wall_flag.set_dir(GLOB.reverse_dir[new_dir])

	qdel(src)

#undef FLAG_CHOICES

/obj/structure/sign/flag
	name = "flag"
	desc = "Appropriate for debates with your roommate."

	icon = 'icons/obj/flags/flags-32.dmi'
	base_icon_state = "bannerflag_21"

	/// Typepath for the default flag appearance datum.
	var/flag_appearance_type
	/// Currently mounted flag appearance.
	var/datum/flag_appearance/flag_appearance

/obj/structure/sign/flag/medium
	base_icon_state = "bannerflag_43"

/obj/structure/sign/flag/large
	name = "full-length flag"
	desc = SPAN("italics bold", "Do it For Her.")

	icon = 'icons/obj/flags/flags-64.dmi'
	base_icon_state = "bannerflag_great_64"

/obj/structure/sign/flag/pennant
	name = "pennant"
	desc = "Hang it with honor."

	base_icon_state = "bannerflag_pennant"

/obj/structure/sign/flag/Initialize(mapload, datum/flag_appearance/flag_appearance)
	. = ..()
	if (mapload && !flag_appearance_type)
		log_debug("Detected attempt to create folded flag with nullish appearance.", loc)
		return INITIALIZE_HINT_QDEL

	if (flag_appearance_type)
		var/datum/flag_appearance/new_flag_appearance = GLOB.flag_appearances[flag_appearance_type]
		if (!istype(new_flag_appearance))
			log_debug("Failed to find '[flag_appearance_type]' in global appearance cache.", loc)
			return INITIALIZE_HINT_QDEL

		set_flag_appearance(new_flag_appearance, color)

/obj/structure/sign/flag/proc/set_flag_appearance(datum/flag_appearance/new_appearance, new_color)
	flag_appearance = new_appearance
	color = new_color || flag_appearance.color
	name = "\improper [flag_appearance.name] [initial(name)]"
	update_icon()
	ADD_FLAG_PREVIEW(flag_appearance.icon_state)

/obj/structure/sign/flag/examine(mob/user, infix)
	. = ..()
	. += flag_appearance.desc

/obj/structure/sign/flag/on_update_icon()
	icon_state = "[base_icon_state]_[flag_appearance.icon_state]"

/obj/structure/sign/flag/set_dir(new_dir)
	. = ..()
	adjust_offset()

/obj/structure/sign/flag/proc/adjust_offset()
	var/icon/flag_icon = icon(icon, icon_state)
	var/width = flag_icon.Width()
	var/height = flag_icon.Height()

	pixel_x = 0
	pixel_y = 0

	switch(dir)
		if(NORTH)
			pixel_y = -height
		if(SOUTH)
			pixel_y = WORLD_ICON_SIZE
		if(EAST)
			pixel_x = -width
		if(WEST)
			pixel_x = WORLD_ICON_SIZE

/obj/structure/sign/flag/attack_hand(mob/user)
	. = ..()
	show_splash_text(user, "removing flag...", "You start removing \the [src] from the wall.")
	if (!do_after(user, 2 SECONDS, src))
		return

	show_splash_text(user, "flag removed", "You removed \the [src] from the wall.")
	playsound(src, SFX_DROP_CLOTH, 40)

	var/obj/item/flag/folded_flag = new(get_turf(user))
	folded_flag.set_flag_appearance(flag_appearance, color)
	user.pick_or_drop(folded_flag)

	qdel(src)
