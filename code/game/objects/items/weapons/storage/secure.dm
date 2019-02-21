/*
 *	Absorbs /obj/item/weapon/secstorage.
 *	Reimplements it only slightly to use existing storage functionality.
 *
 *	Contains:
 *		Secure Briefcase
 *		Wall Safe
 */

// -----------------------------
//         Generic Item
// -----------------------------
/obj/item/weapon/storage/secure
	name = "secstorage"
	var/icon_locking = "secureb"
	var/icon_sparking = "securespark"
	var/icon_opened = "secure0"
	var/locked = 1
	var/code = ""
	var/l_code = null
	var/l_set = 0
	var/l_setshort = 0
	var/l_hacking = 0
	var/emagged = 0
	var/open = 0
	w_class = ITEM_SIZE_NORMAL
	max_w_class = ITEM_SIZE_SMALL
	max_storage_space = DEFAULT_BOX_STORAGE

	examine(mob/user)
		if(..(user, 1))
			to_chat(user, text("The service panel is [src.open ? "open" : "closed"]."))

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(locked)
			if (istype(W, /obj/item/weapon/melee/energy/blade) && emag_act(INFINITY, user, "You slice through the lock of \the [src]"))
				var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
				spark_system.set_up(5, 0, src.loc)
				spark_system.start()
				playsound(src.loc, 'sound/weapons/blade1.ogg', 50, 1)
				playsound(src.loc, "sparks", 50, 1)
				return

			if(isScrewdriver(W))
				if (do_after(user, 20, src))
					src.open =! src.open
					user.show_message(text("<span class='notice'>You [] the service panel.</span>", (src.open ? "open" : "close")))
				return
			if(isMultitool(W) && (src.open == 1)&& (!src.l_hacking))
				user.show_message("<span class='notice'>Now attempting to reset internal memory, please hold.</span>", 1)
				src.l_hacking = 1
				if (do_after(usr, 100, src))
					if (prob(40))
						src.l_setshort = 1
						src.l_set = 0
						user.show_message("<span class='notice'>Internal memory reset. Please give it a few seconds to reinitialize.</span>", 1)
						sleep(80)
						src.l_setshort = 0
						src.l_hacking = 0
					else
						user.show_message("<span class='warning'>Unable to reset internal memory.</span>", 1)
						src.l_hacking = 0
				else	src.l_hacking = 0
				return
			//At this point you have exhausted all the special things to do when locked
			// ... but it's still locked.
			return

		// -> storage/attackby() what with handle insertion, etc
		..()


	MouseDrop(over_object, src_location, over_location)
		if (locked)
			src.add_fingerprint(usr)
			return
		..()


	attack_self(mob/user as mob)
		user.set_machine(src)
		var/dat = text("<TT><B>[]</B><BR>\n\nLock Status: []",src, (src.locked ? "LOCKED" : "UNLOCKED"))
		var/message = "Code"
		if ((src.l_set == 0) && (!src.emagged) && (!src.l_setshort))
			dat += text("<p>\n<b>5-DIGIT PASSCODE NOT SET.<br>ENTER NEW PASSCODE.</b>")
		if (src.emagged)
			dat += text("<p>\n<font color=red><b>LOCKING SYSTEM ERROR - 1701</b></font>")
		if (src.l_setshort)
			dat += text("<p>\n<font color=red><b>ALERT: MEMORY SYSTEM ERROR - 6040 201</b></font>")
		message = text("[]", src.code)
		if (!src.locked)
			message = "*****"
		dat += text("<HR>\n>[]<BR>\n<A href='?src=\ref[];type=1'>1</A>-<A href='?src=\ref[];type=2'>2</A>-<A href='?src=\ref[];type=3'>3</A><BR>\n<A href='?src=\ref[];type=4'>4</A>-<A href='?src=\ref[];type=5'>5</A>-<A href='?src=\ref[];type=6'>6</A><BR>\n<A href='?src=\ref[];type=7'>7</A>-<A href='?src=\ref[];type=8'>8</A>-<A href='?src=\ref[];type=9'>9</A><BR>\n<A href='?src=\ref[];type=R'>R</A>-<A href='?src=\ref[];type=0'>0</A>-<A href='?src=\ref[];type=E'>E</A><BR>\n</TT>", message, src, src, src, src, src, src, src, src, src, src, src, src)
		user << browse(dat, "window=caselock;size=300x280")

	Topic(href, href_list)
		..()
		if ((usr.stat || usr.restrained()) || (get_dist(src, usr) > 1))
			return
		if (href_list["type"])
			if (href_list["type"] == "E")
				if ((src.l_set == 0) && (length(src.code) == 5) && (!src.l_setshort) && (src.code != "ERROR"))
					src.l_code = src.code
					src.l_set = 1
				else if ((src.code == src.l_code) && (src.emagged == 0) && (src.l_set == 1))
					src.locked = 0
					src.overlays = null
					overlays += image('icons/obj/storage.dmi', icon_opened)
					src.code = null
				else
					src.code = "ERROR"
			else
				if ((href_list["type"] == "R") && (src.emagged == 0) && (!src.l_setshort))
					src.locked = 1
					src.overlays = null
					src.code = null
					src.close(usr)
				else
					src.code += text("[]", href_list["type"])
					if (length(src.code) > 5)
						src.code = "ERROR"
			for(var/mob/M in viewers(1, src.loc))
				if ((M.client && M.machine == src))
					src.attack_self(M)
				return
		return

/obj/item/weapon/storage/secure/emag_act(var/remaining_charges, var/mob/user, var/feedback)
	if(!emagged)
		emagged = 1
		src.overlays += image('icons/obj/storage.dmi', icon_sparking)
		sleep(6)
		src.overlays = null
		overlays += image('icons/obj/storage.dmi', icon_locking)
		locked = 0
		to_chat(user, (feedback ? feedback : "You short out the lock of \the [src]."))
		return 1

// -----------------------------
//        Secure Briefcase
// -----------------------------
/obj/item/weapon/storage/secure/briefcase
	name = "secure briefcase"
	icon = 'icons/obj/storage.dmi'
	icon_state = "secure"
	item_state = "sec-case"
	desc = "A large briefcase with a digital locking system."
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = ITEM_SIZE_HUGE
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = DEFAULT_BACKPACK_STORAGE

	attack_hand(mob/user as mob)
		if ((src.loc == user) && (src.locked == 1))
			to_chat(usr, "<span class='warning'>[src] is locked and cannot be opened!</span>")
		else if ((src.loc == user) && (!src.locked))
			src.open(usr)
		else
			..()
			for(var/mob/M in range(1))
				if (M.s_active == src)
					src.close(M)
		src.add_fingerprint(user)
		return

// -----------------------------
//        Secure Safe
// -----------------------------

/obj/item/weapon/storage/secure/safe
	name = "secure safe"
	icon = 'icons/obj/storage.dmi'
	icon_state = "safe"
	icon_opened = "safe0"
	icon_locking = "safeb"
	icon_sparking = "safespark"
	force = 8.0
	w_class = ITEM_SIZE_NO_CONTAINER
	max_w_class = ITEM_SIZE_HUGE
	max_storage_space = 56
	anchored = 1.0
	density = 0
	cant_hold = list(/obj/item/weapon/storage/secure/briefcase)

	New()
		..()
		new /obj/item/weapon/paper(src)
		new /obj/item/weapon/pen(src)

	attack_hand(mob/user as mob)
		return attack_self(user)

/obj/item/weapon/storage/secure/safe/HoS/New()
	..()
	//new /obj/item/weapon/storage/lockbox/clusterbang(src) This item is currently broken... and probably shouldnt exist to begin with (even though it's cool)

// -----------------------------
//     Detective's Guncase
// -----------------------------

/obj/item/weapon/storage/secure/guncase/
	name = "guncase"
	desc = "A heavy-duty container with a digital locking system. Has a thick layer of foam inside. "
	icon_state = "guncase"
	item_state = "guncase"

/obj/item/weapon/storage/secure/guncase/detective
	name = "detective's gun case"
	icon = 'icons/obj/storage.dmi'
	icon_state = "guncasedet"
	item_state = "guncasedet"
	desc = "A heavy-duty container with a digital locking system. This one has a wooden coating and its locks are the color of brass."
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = ITEM_SIZE_NORMAL
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = DEFAULT_BACKPACK_STORAGE
	var/guntype = "M1911"
	var/obj/item/weapon/gun/gun
	var/gunspawned = 0

	attack_hand(mob/user as mob)
		if ((src.loc == user) && (src.locked == 1))
			to_chat(usr, "<span class='warning'>[src] is locked and cannot be opened!</span>")
		else if ((src.loc == user) && (!src.locked))
			src.open(usr)
		else
			..()
			for(var/mob/M in range(1))
				if (M.s_active == src)
					src.close(M)
		src.add_fingerprint(user)
		return

	attack_self(mob/user as mob)
		user.set_machine(src)
		var/dat = text("<TT><B>[]</B><BR>\n\nLock Status: []",src, (src.locked ? "LOCKED" : "UNLOCKED"))
		var/message = "Code"

		if ((src.l_set == 0) && (!src.emagged) && (!src.l_setshort))
			dat += text("<p>\n<b>5-DIGIT PASSCODE NOT SET.<br>ENTER NEW PASSCODE.</b>")
		if (src.emagged)
			dat += text("<p>\n<font color=red><b>LOCKING SYSTEM ERROR - 1701</b></font>")
		if (src.l_setshort)
			dat += text("<p>\n<font color=red><b>ALERT: MEMORY SYSTEM ERROR - 6040 201</b></font>")
		message = text("[]", src.code)
		if (!src.locked)
			message = "*****"
		dat += text("<HR>\n>[]<BR>\n<A href='?src=\ref[];type=1'>1</A>-<A href='?src=\ref[];type=2'>2</A>-<A href='?src=\ref[];type=3'>3</A><BR>\n<A href='?src=\ref[];type=4'>4</A>-<A href='?src=\ref[];type=5'>5</A>-<A href='?src=\ref[];type=6'>6</A><BR>\n<A href='?src=\ref[];type=7'>7</A>-<A href='?src=\ref[];type=8'>8</A>-<A href='?src=\ref[];type=9'>9</A><BR>\n<A href='?src=\ref[];type=R'>R</A>-<A href='?src=\ref[];type=0'>0</A>-<A href='?src=\ref[];type=E'>E</A><BR>\n</TT>", message, src, src, src, src, src, src, src, src, src, src, src, src)

		dat += text("<p><HR>\nChosen Gun: []",src.guntype)
		if (src.gunspawned == 0)
			dat += text("<p>\n Be careful! Once you chose your weapon and unlock the gun case, you won't be able to change it.")
			dat += text("<HR><p>\n<A href='?src=\ref[];type=m1911'>M1911</A>", src)
			dat += text("<p>\n<A href='?src=\ref[];type=legacy'>S&W Legacy</A>", src)
			dat += text("<p>\n<A href='?src=\ref[];type=saw620'>S&W 620</A>", src)
			dat += text("<p>\n<A href='?src=\ref[];type=m2019'>M2019 Detective Special</A>", src)
		dat += text("<HR>")
		if (src.guntype)
			if (src.guntype == "M1911")
				dat += text("<p>\n A cheap Martian knock-off of a Colt M1911. Uses .45 rounds. Extremely popular among space detectives nowadays.")
				if (src.gunspawned == 0)
					dat += text("<p>\n Comes with two .45 seven round magazines and two .45 rubber seven round magazines.")
			else if (src.guntype == "S&W Legacy")
				dat += text("<p>\n A cheap Martian knock-off of a Smith & Wesson Model 10. Uses .38-Special rounds. Used to be NanoTrasen's service weapon for detectives.")
				if (src.gunspawned == 0)
					dat += text("<p>\n Comes with two .38 six round speedloaders and two .38 rubber six round speedloaders.")
			else if (src.guntype == "S&W 620")
				dat += text("<p>\n A cheap Martian knock-off of a Smith & Wesson Model 620. Uses .38-Special rounds. Quite popular among professionals.")
				if (src.gunspawned == 0)
					dat += text("<p>\n Comes with two .38 six round speedloaders and two .38 rubber six round speedloaders.")
			else if (src.guntype == "M2019")
				dat += text("<p>\n Quite a controversial weapon. Combining both pros and cons of revolvers and railguns, it's extremely versatile, yet requires a lot of care.")
				if (src.gunspawned == 0)
					dat += text("<p>\n Comes with three .44 SPEC five round speedloaders, two .44 CHEM five round speedloaders, and two replaceable power cells.")
					dat += text("<p>\n Brief instructions: <p>\n - M2019 Detective Special can be loaded with any type .44 rounds, yet works best with .44 CHEM and .44 SPEC.")
					dat += text("<p>\n - With a powercell installed, M2019 can be used in two modes: non-lethal and lethal.")
					dat += text("<p>\n - .44 SPEC no cell - works like a rubber bullet. <p>\n - .44 SPEC non-lethal - stuns the target. <p>\n - .44 CHEM lethal - accelerates the bullet, deals great damage and pierces medium armor.")
					dat += text("<p>\n - .44 CHEM no cell - works like a flash bullet. <p>\n - .44 CHEM non-lethal - emmits a weak electromagnetic impulse. <p>\n - .44 CHEM lethal - not supposed to be used like this. The cartride reaches extremely high temperature and melts.")

		user << browse(dat, "window=caselock;size=300x280")

	Topic(href, href_list)
		if ((usr.stat || usr.restrained()) || (get_dist(src, usr) > 1))
			return
		if (href_list["type"])
			if (href_list["type"] == "m1911")
				src.guntype = "M1911"
			else if (href_list["type"] == "legacy")
				src.guntype = "S&W Legacy"
			else if (href_list["type"] == "saw620")
				src.guntype = "S&W 620"
			else if (href_list["type"] == "m2019")
				src.guntype = "M2019"
			else if (href_list["type"] == "E")
				if ((src.l_set == 0) && (length(src.code) == 5) && (!src.l_setshort) && (src.code != "ERROR"))
					src.l_code = src.code
					src.l_set = 1
				else if ((src.code == src.l_code) && (src.emagged == 0) && (src.l_set == 1))
					src.locked = 0
					src.overlays = null
					overlays += image('icons/obj/storage.dmi', icon_opened)
					src.code = null
					if (src.gunspawned == 0)
						src.gunspawned = 1
						if (src.guntype == "M1911")
							src.gun = new /obj/item/weapon/gun/projectile/colt/detective(src)
							new /obj/item/ammo_magazine/c45m/rubber(src)
							new /obj/item/ammo_magazine/c45m/rubber(src)
							new /obj/item/ammo_magazine/c45m(src)
							new /obj/item/ammo_magazine/c45m(src)
						else if (src.guntype == "S&W Legacy")
							src.gun = new /obj/item/weapon/gun/projectile/revolver/detective(src)
							new /obj/item/ammo_magazine/c38/rubber(src)
							new /obj/item/ammo_magazine/c38/rubber(src)
							new /obj/item/ammo_magazine/c38(src)
							new /obj/item/ammo_magazine/c38(src)
						else if (src.guntype == "S&W 620")
							src.gun = new /obj/item/weapon/gun/projectile/revolver/detective/saw620(src)
							new /obj/item/ammo_magazine/c38/rubber(src)
							new /obj/item/ammo_magazine/c38/rubber(src)
							new /obj/item/ammo_magazine/c38(src)
							new /obj/item/ammo_magazine/c38(src)
						else if (src.guntype == "M2019")
							src.gun = new /obj/item/weapon/gun/projectile/revolver/m2019/detective(src)
							new /obj/item/ammo_magazine/c44/spec(src)
							new /obj/item/ammo_magazine/c44/spec(src)
							new /obj/item/ammo_magazine/c44/spec(src)
							new /obj/item/ammo_magazine/c44/chem(src)
							new /obj/item/ammo_magazine/c44/chem(src)
							new /obj/item/weapon/cell/device/high(src)
				else
					src.code = "ERROR"
			else
				if ((href_list["type"] == "R") && (src.emagged == 0) && (!src.l_setshort))
					src.locked = 1
					src.overlays = null
					src.code = null
					src.close(usr)
				else
					src.code += text("[]", href_list["type"])
					if (length(src.code) > 5)
						src.code = "ERROR"
			for(var/mob/M in viewers(1, src.loc))
				if ((M.client && M.machine == src))
					src.attack_self(M)
				return
		return