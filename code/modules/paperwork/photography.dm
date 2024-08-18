/*	Photography!
 *	Contains:
 *		Camera
 *		Camera Film
 *		Photos
 *		Photo Albums
 */

/*******
* film *
*******/
/obj/item/device/camera_film
	name = "film cartridge"
	icon = 'icons/obj/items.dmi'
	desc = "A camera film cartridge. Insert it into a camera to reload it."
	icon_state = "film"
	item_state = "electropack"
	w_class = ITEM_SIZE_TINY


/********
* photo *
********/
var/global/photo_count = 0

/obj/item/photo
	name = "photo"
	icon = 'icons/obj/items.dmi'
	icon_state = "photo"
	item_state = "paper"
	randpixel = 10
	w_class = ITEM_SIZE_TINY
	var/id
	var/icon/img	//Big photo image
	var/scribble	//Scribble on the back.
	var/image/tiny
	var/photo_size = 3
	var/list/disfigured_mobs = list()

/obj/item/photo/New()
	id = photo_count++

/obj/item/photo/attack_self(mob/user as mob)
	user.examinate(src)

/obj/item/photo/on_update_icon()
	ClearOverlays()
	var/scale = 8/(photo_size*32)
	var/image/small_img = image(img)
	small_img.SetTransform(scale = scale)
	small_img.pixel_x = -32*(photo_size-1)/2 - 3
	small_img.pixel_y = -32*(photo_size-1)/2
	AddOverlays(small_img)

	tiny = image(img)
	tiny.SetTransform(scale = 0.5 * scale)
	tiny.underlays += image('icons/obj/bureaucracy.dmi',"photo")
	tiny.pixel_x = -32*(photo_size-1)/2 - 3
	tiny.pixel_y = -32*(photo_size-1)/2 + 3

/obj/item/photo/attackby(obj/item/P as obj, mob/user as mob)
	if(istype(P, /obj/item/pen))
		var/txt = sanitize(input(user, "What would you like to write on the back?", "Photo Writing", null), 128)
		if(loc == user && user.stat == 0)
			scribble = txt
	..()

/obj/item/photo/examine(mob/user, infix)
	. = ..()

	if(in_range(user, src))
		show(user)
	else
		. += SPAN_NOTICE("It is too far away.")

/obj/item/photo/proc/show(mob/user as mob)
	send_rsc(user, img, "tmp_photo_[id].png")
	var/dat = "<html><meta charset=\"utf-8\"><head><title>[name]</title></head>" \
		+ "<body style='overflow:hidden;margin:0;text-align:center'>" \
		+ "<img src='tmp_photo_[id].png' width='[64*photo_size]' style='-ms-interpolation-mode:nearest-neighbor' />" \
		+ "[scribble ? "<br>Written on the back:<br><i>[scribble]</i>" : ""]"\
		+ "</body></html>"
	show_browser(user, dat, "window=book;size=[64*photo_size]x[scribble ? 400 : 64*photo_size]")
	onclose(user, "[name]")
	return

/obj/item/photo/verb/rename()
	set name = "Rename photo"
	set category = "Object"
	set src in usr

	var/new_name = sanitizeSafe(input(usr, "What would you like to label the photo?", "Photo Labelling", null) as text, MAX_NAME_LEN)
	//loc.loc check is for making possible renaming photos in clipboards
	if((loc == usr || (loc.loc && loc.loc == usr)) && usr.stat == 0)
		SetName("[(new_name ? text("[new_name]") : "photo")]")
	add_fingerprint(usr)
	return


/**************
* photo album *
**************/
/obj/item/storage/photo_album
	name = "Photo album"
	icon = 'icons/obj/items.dmi'
	icon_state = "album"
	item_state = "briefcase"
	w_class = ITEM_SIZE_NORMAL //same as book
	storage_slots = DEFAULT_BOX_STORAGE //yes, that's storage_slots. Photos are w_class 1 so this has as many slots equal to the number of photos you could put in a box
	can_hold = list(/obj/item/photo)

/obj/item/storage/photo_album/MouseDrop(obj/over_object as obj)
	if((ishuman(usr)))
		var/mob/M = usr
		if(!istype(over_object, /atom/movable/screen))
			return ..()
		playsound(loc, SFX_SEARCH_CLOTHES, 50, 1, -5)
		if((!M.restrained() && !M.stat && M.back == src))
			switch(over_object.name)
				if("r_hand")
					if(M.drop(src))
						M.put_in_r_hand(src)
				if("l_hand")
					if(M.drop(src))
						M.put_in_l_hand(src)
			add_fingerprint(usr)
			return
		if(over_object == usr && in_range(src, usr) || usr.contents.Find(src))
			if(usr.s_active)
				usr.s_active.close(usr)
			show_to(usr)
			return
	return


/*********
* camera *
*********/
/obj/item/device/camera
	name = "camera"
	icon = 'icons/obj/items.dmi'
	desc = "A polaroid camera."
	icon_state = "camera"
	item_state = "camera"
	w_class = ITEM_SIZE_SMALL
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	matter = list(MATERIAL_STEEL = 2000)
	var/pictures_max = 10
	var/pictures_left = 10
	var/is_on = TRUE
	var/next_shot_time
	var/icon_on = "camera"
	var/icon_off = "camera_off"
	var/size = 3
	var/see_ghosts = FALSE

/obj/item/device/camera/on_update_icon()
	if(is_on)
		icon_state = "[initial(icon_state)]"
	else
		icon_state = "[initial(icon_state)]_off"

/obj/item/device/camera/Initialize()
	update_icon()
	. = ..()

/obj/item/device/camera/verb/change_size()
	set name = "Set Photo Focus"
	set category = "Object"
	var/new_size = input("Photo Size", "Pick a size of resulting photo.") as null|anything in list(1,3)
	if(new_size)
		size = new_size
		to_chat(usr, "<span class='notice'>Camera will now take [size]x[size] photos.</span>")

/obj/item/device/camera/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/device/camera/attack_self(mob/user as mob)
	is_on = !is_on
	update_icon()
	to_chat(user, "You switch the camera [is_on ? "on" : "off"].")
	return

/obj/item/device/camera/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/device/camera_film))
		if(pictures_left)
			to_chat(user, "<span class='notice'>[src] still has some film in it!</span>")
			return
		if(!user.drop(I, src))
			return
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		// TODO [V] That's kinda strange: pictures_left should be stored in film rather than in camera
		pictures_left = pictures_max
		return
	..()


/obj/item/device/camera/proc/get_mobs(turf/the_turf as turf)
	var/mob_detail
	if(see_ghosts)
		for(var/mob/observer/ghost/A in the_turf)
			if(!mob_detail)
				mob_detail = "You can see [A] on the photo. "
			else
				mob_detail += "You can also see [A] on the photo."

	for(var/mob/living/carbon/A in the_turf)
		if(A.invisibility) continue
		var/holding = null
		if(A.l_hand || A.r_hand)
			if(A.l_hand) holding = "They are holding \a [A.l_hand]"
			if(A.r_hand)
				if(holding)
					holding += " and \a [A.r_hand]"
				else
					holding = "They are holding \a [A.r_hand]"

		if(!mob_detail)
			mob_detail = "You can see [A] on the photo[(A.health / A.maxHealth) < 0.75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]. "
		else
			mob_detail += "You can also see [A] on the photo[(A.health / A.maxHealth)< 0.75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]."
		if(ishuman(A))
			var/mob/living/carbon/human/H = A
			var/obj/item/organ/external/head/E = H.get_organ(BP_HEAD)
			if(E && (E?.status & ORGAN_DISFIGURED)) // Check to see if we even have a head and if the head's disfigured.
				mob_detail += "You can see [A] on the photo is disfigured."
	return mob_detail

/obj/item/device/camera/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if(!is_on || !pictures_left || ismob(target.loc))
		return
	if(world.time < next_shot_time)
		to_chat(user, "<span class='notice'>Camera is still charging.</span>")
		return

	next_shot_time = world.time + 6 SECONDS
	pictures_left--

	captureimage(target, user, flag)
	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)
	to_chat(user, "<span class='notice'>[pictures_left] photos left.</span>")

	update_icon()

/obj/item/device/camera/examine(mob/user, infix)
	. = ..()
	. += "It has [pictures_left] photo\s left."

/mob/living/proc/can_capture_turf(turf/T)
	return (T in view(src))

/obj/item/device/camera/proc/captureimage(atom/target, mob/living/user, flag)
	var/x_c = target.x - (size-1)/2
	var/y_c = target.y + (size-1)/2
	var/z_c	= target.z
	var/mobs = ""
	var/list/disfigured = list()
	for(var/i = 1 to size)
		for(var/j = 1 to size)
			var/turf/T = locate(x_c, y_c, z_c)
			if(user.can_capture_turf(T))
				mobs += get_mobs(T)
				for(var/mob/living/carbon/A in T)
					if(ishuman(A))
						var/mob/living/carbon/human/H = A
						var/obj/item/organ/external/head/E = H.get_organ(BP_HEAD)
						if(E && (E?.status & ORGAN_DISFIGURED))
							disfigured |= A
			x_c++
		y_c--
		x_c = x_c - size

	var/obj/item/photo/p = createpicture(target, user, mobs, flag, disfigured)
	printpicture(user, p)

/obj/item/device/camera/proc/createpicture(atom/target, mob/user, mobs, flag, list/disfigured)
	var/x_c = target.x - (size-1)/2
	var/y_c = target.y - (size-1)/2
	var/z_c	= target.z
	var/icon/photoimage = generate_image(x_c, y_c, z_c, size, CAPTURE_MODE_REGULAR, user, 0, see_ghosts=src.see_ghosts)

	var/obj/item/photo/p = new()
	p.img = photoimage
	p.desc = mobs
	p.photo_size = size
	p.disfigured_mobs = disfigured
	p.update_icon()

	return p

/obj/item/device/camera/proc/printpicture(mob/user, obj/item/photo/p)
	user.pick_or_drop(p)

/obj/item/photo/proc/copy(copy_id = 0)
	var/obj/item/photo/p = new /obj/item/photo()

	p.SetName(name)
	p.appearance = appearance
	p.tiny = new
	p.tiny.appearance = tiny.appearance
	p.img = icon(img)
	p.photo_size = photo_size
	p.scribble = scribble

	if(copy_id)
		p.id = id

	return p

/obj/item/device/camera/spooky
	name = "camera obscura"
	desc = "A polaroid camera, some say it can see ghosts!"
	see_ghosts = TRUE

/obj/item/device/camera/random
	name = "camera "
	desc = "A polaroid camera. It seems to have an extra magnifier on the end."

/obj/item/device/camera/random/createpicture(atom/target, mob/user, mobs, flag, list/disfigured)
	var/atom/new_target = pick(GLOB.player_list)

	var/x_c = new_target.x - (size-1)/2
	var/y_c = new_target.y - (size-1)/2
	var/z_c	= new_target.z
	var/icon/photoimage = generate_image(x_c, y_c, z_c, size, CAPTURE_MODE_REGULAR, user, 0, see_ghosts=src.see_ghosts)

	var/obj/item/photo/p = new()
	p.img = photoimage
	p.desc = mobs
	p.photo_size = size
	p.update_icon()

	return p

/obj/item/device/camera/fiery
	name = "camera "
	desc = "A polaroid camera. It seems to be kinda hot."

/obj/item/device/camera/fiery/get_temperature_as_from_ignitor()
	return 300
