#define BLUE_PORTAL 0
#define ORANGE_PORTAL 1

/obj/item/gun/portalgun	// - base code by Deity Link, modification and momentum stuff by Doster-d
	name = "\improper Portal Gun"
	desc = "There's a hole in the sky... through which I can fly."
	icon = 'icons/obj/portals.dmi'
	icon_state = "portal_gun"
	item_state = "portalgun0" // TODO [V]: make portal gun sprite in hand
	slot_flags = SLOT_BELT
	origin_tech = list(TECH_MATERIAL = 7, TECH_BLUESPACE = 6, TECH_MAGNET = 5)
	w_class = ITEM_SIZE_NORMAL
	fire_delay = 2
	fire_sound = 'sound/weapons/portalgun_blue.ogg'
	fire_sound_text = "laser beam"
	var/setting = BLUE_PORTAL // BLUE_PORTAL = Blue, ORANGE_PORTAL = Red.
	var/obj/effect/portal/linked/blue_portal
	var/obj/effect/portal/linked/red_portal

/obj/item/gun/portalgun/_examine_text(mob/user)
	. = ..()
	. += "\nIt's current setting is <span style='color: [setting ? COLOR_ORANGE : COLOR_BLUE];'>[setting ? "red" : "blue"]</span>."

/obj/item/gun/portalgun/Initialize()
	. = ..()
	update_icon()

/obj/item/gun/portalgun/Destroy()
	QDEL_NULL(blue_portal)
	QDEL_NULL(red_portal)
	..()

/obj/item/gun/portalgun/consume_next_projectile()
	var/obj/item/projectile/portal/P = new /obj/item/projectile/portal(src)
	P.color = setting ? COLOR_ORANGE : COLOR_BLUE
	P.setting = setting
	return P

/obj/item/gun/portalgun/attack_self(mob/user)
	setting = !setting
	fire_sound = setting ? 'sound/weapons/portalgun_red.ogg' : 'sound/weapons/portalgun_blue.ogg'
	to_chat(user, "Now set to fire <span style='color: [setting ? COLOR_ORANGE : COLOR_BLUE];'>[setting ? "red" : "blue"] portals</span>.")
	update_icon()

/obj/item/gun/portalgun/update_icon()
	overlays.Cut()
	var/icon/portal_icon = icon(icon, "pg[setting]")
	overlays.Add(portal_icon)
	if(blood_overlay)
		overlays += blood_overlay
	return ..()

/obj/item/gun/portalgun/proc/open_portal(proj_setting, turf/T, atom/A, mob/firer)
	if(!T)
		return

	var/obj/effect/portal/linked/new_portal = new(T, null, 5 MINUTES) // Portal Gun-made portals stay open for 5 minutes by default.

	if(ismob(firer))
		new_portal.owner = "[firer.real_name]+[firer.ckey]"
	else
		new_portal.owner = firer
	new_portal.portal_creator_weakref = weakref(src)
	switch(setting)
		if(BLUE_PORTAL)
			QDEL_NULL(blue_portal)
			blue_portal = new_portal
		if(ORANGE_PORTAL)
			QDEL_NULL(red_portal)
			red_portal = new_portal
			red_portal.icon_state = "portal1"

	sync_portals()

	if(A && isliving(A))
		new_portal.Crossed(A)

/obj/item/gun/portalgun/proc/sync_portals()
	if(!blue_portal || !red_portal)
		var/obj/effect/portal/linked/single_portal = blue_portal || red_portal
		if(single_portal)
			single_portal.overlays.Cut()
			single_portal.target = null
			single_portal.disconnect_atmospheres()
		return
	red_portal.disconnect_atmospheres()
	blue_portal.disconnect_atmospheres()

	//connecting the portals
	blue_portal.target = red_portal
	red_portal.target = blue_portal

	//updating their sprites
	blue_portal.blend_icon(red_portal)
	red_portal.blend_icon(blue_portal)

	// portals are open, teleport items that on portal
	blue_portal.move_all_objects()
	red_portal.move_all_objects()

	//updating their atmos connection
	blue_portal.connect_atmospheres()

#undef BLUE_PORTAL
#undef ORANGE_PORTAL
