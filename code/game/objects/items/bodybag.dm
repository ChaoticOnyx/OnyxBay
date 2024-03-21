//Also contains /obj/structure/closet/body_bag because I doubt anyone would think to look for bodybags in /object/structures

/obj/item/bodybag
	name = "body bag"
	desc = "A folded bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"
	item_state = "bodybag_folded_c"
	w_class = ITEM_SIZE_SMALL
	pull_sound = SFX_PULL_BODY

/obj/item/bodybag/attack_self(mob/user)
	var/obj/structure/closet/body_bag/R = new /obj/structure/closet/body_bag(user.loc)
	R.add_fingerprint(user)
	qdel(src)


/obj/item/storage/box/bodybags
	name = "body bags"
	desc = "This box contains body bags."
	icon_state = "bodybags"

/obj/item/storage/box/bodybags/Initialize()
	. = ..()
	new /obj/item/bodybag(src)
	new /obj/item/bodybag(src)
	new /obj/item/bodybag(src)
	new /obj/item/bodybag(src)
	new /obj/item/bodybag(src)
	new /obj/item/bodybag(src)
	new /obj/item/bodybag(src)


/obj/structure/closet/body_bag
	name = "body bag"
	desc = "A plastic bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_closed"
	icon_closed = "bodybag_closed"
	icon_opened = "bodybag_open"
	open_sound = 'sound/items/zip.ogg'
	close_sound = 'sound/items/zip.ogg'
	pull_sound = SFX_PULL_BODY
	var/item_path = /obj/item/bodybag
	density = 0
	storage_capacity = (MOB_MEDIUM * 2) - 1
	var/contains_body = 0
	dremovable = 0
	open_delay = 6
	var/obj/structure/bed/roller/roller_buckled //the roller bed this bodybag is attached to.
	var/buckle_offset = 5
	layer = ABOVE_OBJ_LAYER
	intact_closet = FALSE

/obj/structure/closet/body_bag/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/pen))
		var/t = input(user, "What would you like the label to be?", text("[]", name), null)  as text
		if(user.get_active_hand() != W)
			return
		if(!in_range(src, user) && loc != user)
			return
		t = sanitizeSafe(t, MAX_NAME_LEN)
		if(t)
			SetName("body bag - ")
			name += t
			AddOverlays(image(icon, "bodybag_label"))
		else
			SetName("body bag")
	//..() //Doesn't need to run the parent. Since when can fucking bodybags be welded shut? -Agouri
		return
	else if(isWirecutter(W))
		SetName("body bag")
		ClearOverlays()
		to_chat(user, "You cut the tag off \the [src].")
		return
	else if(istype(W, /obj/item/device/healthanalyzer/) && !opened)
		if(contains_body)
			var/obj/item/device/healthanalyzer/HA = W
			for(var/mob/living/L in contents)
				HA.scan_mob(L, user)
		else
			to_chat(user, "\The [W] reports that \the [src] is empty.")
		return

/obj/structure/closet/body_bag/store_mobs(stored_units)
	contains_body = ..()
	return contains_body

/obj/structure/closet/body_bag/close()
	if(..())
		set_density(0)
		return TRUE
	return FALSE

/obj/structure/closet/body_bag/proc/fold(user)
	if(!ishuman(user))
		return
	if(opened)
		return
	if(contents.len)
		return
	visible_message("[user] folds up the [name]")
	. = new item_path(get_turf(src))
	qdel(src)

/obj/structure/closet/body_bag/MouseDrop(over_object, src_location, over_location)
	..()
	if((over_object == usr && (in_range(src, usr) || usr.contents.Find(src))))
		fold(usr)

/obj/structure/closet/body_bag/on_update_icon()
	if(opened)
		icon_state = icon_opened
	else
		if(contains_body > 0)
			icon_state = "bodybag_closed1"
		else
			icon_state = icon_closed
