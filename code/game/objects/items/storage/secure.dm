/*
 *	Absorbs /obj/item/secstorage.
 *	Reimplements it only slightly to use existing storage functionality.
 *
 *	Contains:
 *		Secure Briefcase
 *		Wall Safe
 */

// -----------------------------
//         Generic Item
// -----------------------------
/obj/item/storage/secure
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
	var/datum/browser/lock_menu
	w_class = ITEM_SIZE_NORMAL
	max_w_class = ITEM_SIZE_SMALL
	max_storage_space = DEFAULT_BOX_STORAGE

/obj/item/storage/secure/_examine_text(mob/user)
	. = ..()
	. += "The service panel is [open ? "open" : "closed"]."

/obj/item/storage/secure/attackby(obj/item/W, mob/user)
	if(locked)
		if(istype(W, /obj/item/melee/energy/blade))
			emag_act(INFINITY, user, W, "You slice through the lock of \the [src]")
			var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
			spark_system.set_up(5, 0, src.loc)
			spark_system.start()
			playsound(src.loc, 'sound/weapons/blade1.ogg', 50, 1)
			playsound(src.loc, SFX_SPARK, 50, 1)
			return
		if(isScrewdriver(W))
			if(do_after(user, 20, src))
				src.open =! src.open
				user.show_message(text("<span class='notice'>You [] the service panel.</span>", (src.open ? "open" : "close")))
			return
		if(isMultitool(W) && (src.open == 1)&& (!src.l_hacking))
			user.show_message("<span class='notice'>Now attempting to reset internal memory, please hold.</span>", 1)
			src.l_hacking = 1
			if(do_after(usr, 100, src))
				if(prob(40))
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


/obj/item/storage/secure/MouseDrop(over_object, src_location, over_location)
	if(locked)
		add_fingerprint(usr)
		return
	..()

/obj/item/storage/secure/AltClick(mob/usr)
	if(locked)
		add_fingerprint(usr)
		return
	..()

/obj/item/storage/secure/proc/show_lock_menu(mob/user)
	if(user.incapacitated() || !user.Adjacent(src) || !user.client)
		return
	var/dat = text("<TT>\n\nLock Status: []", (locked ? "<font color=red>LOCKED</font>" : "<font color=green>UNLOCKED</font>"))
	var/message = "Code"
	if((l_set == 0) && (!emagged) && (!l_setshort))
		dat += text("<p>\n<b>5-DIGIT PASSCODE NOT SET.<br>ENTER NEW PASSCODE.</b>")
	if(emagged)
		dat += text("<p>\n<font color=red><b>LOCKING SYSTEM ERROR - 1701</b></font>")
	if(l_setshort)
		dat += text("<p>\n<font color=red><b>ALERT: MEMORY SYSTEM ERROR - 6040 201</b></font>")
	message = text("[]", src.code)
	if(!locked)
		message = "*****"
	dat += text("<HR>\n>[]<BR>\n<A href='?src=\ref[];type=1'>1</A>-<A href='?src=\ref[];type=2'>2</A>-<A href='?src=\ref[];type=3'>3</A><BR>\n<A href='?src=\ref[];type=4'>4</A>-<A href='?src=\ref[];type=5'>5</A>-<A href='?src=\ref[];type=6'>6</A><BR>\n<A href='?src=\ref[];type=7'>7</A>-<A href='?src=\ref[];type=8'>8</A>-<A href='?src=\ref[];type=9'>9</A><BR>\n<A href='?src=\ref[];type=R'>R</A>-<A href='?src=\ref[];type=0'>0</A>-<A href='?src=\ref[];type=E'>E</A><BR>\n</TT>", message, src, src, src, src, src, src, src, src, src, src, src, src)

	user.set_machine(src)
	if(!lock_menu || lock_menu.user != user)
		lock_menu = new /datum/browser(user, "mob[name]", "<B>[src]</B>", 300, 280)
		lock_menu.set_content(dat)
	else
		lock_menu.set_content(dat)
		lock_menu.update()
	return

/obj/item/storage/secure/attack_self(mob/user)
	show_lock_menu(user)
	if(lock_menu?.user == user)
		lock_menu.open()

/obj/item/storage/secure/Topic(href, href_list)
	..()
	if((usr.stat || usr.restrained()) || (get_dist(src, usr) > 1))
		return
	if(href_list["type"])
		if(href_list["type"] == "E")
			if((src.l_set == 0) && (length(src.code) == 5) && (!src.l_setshort) && (src.code != "ERROR"))
				src.l_code = src.code
				src.l_set = 1
			else if((src.code == src.l_code) && (src.emagged == 0) && (src.l_set == 1))
				src.locked = 0
				src.overlays = null
				overlays += image('icons/obj/storage.dmi', icon_opened)
				src.code = null
			else
				src.code = "ERROR"
		else
			if((href_list["type"] == "R") && (src.emagged == 0) && (!src.l_setshort))
				src.locked = 1
				src.overlays = null
				src.code = null
				src.close(usr)
			else
				src.code += text("[]", href_list["type"])
				if(length(src.code) > 5)
					src.code = "ERROR"
		for(var/mob/M in viewers(1, src.loc))
			if((M.client && M.machine == src))
				show_lock_menu(M)
			return
	return

/obj/item/storage/secure/emag_act(remaining_charges, mob/user, emag_source, visual_feedback = "", audible_feedback = "")
	var/obj/item/melee/energy/WS = emag_source
	if(WS.active)
		on_hack_behavior(WS, user)
		return TRUE

/obj/item/storage/secure/proc/on_hack_behavior()
	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src.loc)
	spark_system.start()
	playsound(src.loc, 'sound/weapons/blade1.ogg', 50, 1)
	playsound(src.loc, "spark", 50, 1)
	if(!emagged)
		emagged = TRUE
		overlays += image('icons/obj/storage.dmi', icon_sparking)
		sleep(6)
		overlays = null
		overlays += image('icons/obj/storage.dmi', icon_locking)
		locked = FALSE

// -----------------------------
//        Secure Briefcase
// -----------------------------
/obj/item/storage/secure/briefcase
	name = "secure briefcase"
	icon = 'icons/obj/storage.dmi'
	icon_state = "secure"
	item_state = "sec-case"
	desc = "A large briefcase with a digital locking system."
	force = 8.0
	throw_range = 4
	w_class = ITEM_SIZE_HUGE
	mod_weight = 1.5
	mod_reach = 0.75
	mod_handy = 1.0
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = DEFAULT_BACKPACK_STORAGE

/obj/item/storage/secure/briefcase/attack_hand(mob/user)
	if((src.loc == user) && (src.locked == 1))
		to_chat(usr, "<span class='warning'>[src] is locked and cannot be opened!</span>")
	else if((src.loc == user) && (!src.locked))
		src.open(usr)
	else
		..()
		for(var/mob/M in range(1))
			if(M.s_active == src)
				src.close(M)
	src.add_fingerprint(user)
	return

// -----------------------------
//        Secure Safe
// -----------------------------

/obj/item/storage/secure/safe
	name = "secure safe"
	icon = 'icons/obj/storage.dmi'
	icon_state = "safe"
	icon_opened = "safe0"
	icon_locking = "safeb"
	icon_sparking = "safespark"
	force = 0
	w_class = ITEM_SIZE_NO_CONTAINER
	max_w_class = ITEM_SIZE_HUGE
	max_storage_space = 56
	anchored = 1.0
	density = 0
	cant_hold = list(/obj/item/storage/secure/briefcase)

/obj/item/storage/secure/safe/New()
	..()
	new /obj/item/paper(src)
	new /obj/item/pen(src)

/obj/item/storage/secure/safe/attack_hand(mob/user)
	return attack_self(user)

/obj/item/storage/secure/safe/HoS/New()
	..()
	//new /obj/item/storage/lockbox/clusterbang(src) This item is currently broken... and probably shouldnt exist to begin with (even though it's cool)

// -----------------------------
//     Detective's Guncase
// -----------------------------

/obj/item/storage/secure/guncase
	name = "guncase"
	desc = "A heavy-duty container with a digital locking system. Has a thick layer of foam inside."
	icon = 'icons/obj/storage.dmi'
	icon_state = "guncase"
	item_state = "guncase"
	icon_opened = "guncase0"
	force = 8.0
	throw_range = 4
	w_class = ITEM_SIZE_LARGE
	mod_weight = 1.4
	mod_reach = 0.7
	mod_handy = 1.0
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = DEFAULT_BACKPACK_STORAGE

	var/guntype = ""
	var/gunspawned = 0

/obj/item/storage/secure/guncase/attack_hand(mob/user)
	if((loc == user) && (locked == 1))
		to_chat(usr, SPAN("warning", "[src] is locked and cannot be opened!"))
	else if((loc == user) && (!locked))
		open(usr)
	else
		..()
		for(var/mob/M in range(1))
			if(M.s_active == src)
				close(M)
	add_fingerprint(user)
	return

/obj/item/storage/secure/guncase/proc/spawn_set(set_name)
	return

/obj/item/storage/secure/guncase/detective
	name = "detective's gun case"
	icon_state = "guncasedet"
	item_state = "guncasedet"
	desc = "A heavy-duty container with a digital locking system. This one has a wooden coating and its locks are the color of brass."
	guntype = "M1911"

/obj/item/storage/secure/guncase/detective/show_lock_menu(mob/user)
	if(user.incapacitated() || !user.Adjacent(src) || !user.client)
		return
	user.set_machine(src)
	var/dat = text("<TT>\n\nLock Status: []", (locked ? "<font color=red>LOCKED</font>" : "<font color=green>UNLOCKED</font>"))
	var/message = "Code"

	if((l_set == 0) && (!emagged) && (!l_setshort))
		dat += text("<p>\n<b>5-DIGIT PASSCODE NOT SET.<br>ENTER NEW PASSCODE.</b>")
	if(emagged)
		dat += text("<p>\n<font color=red><b>LOCKING SYSTEM ERROR - 1701</b></font>")
	if(l_setshort)
		dat += text("<p>\n<font color=red><b>ALERT: MEMORY SYSTEM ERROR - 6040 201</b></font>")
	message = text("[]", src.code)
	if(!locked)
		message = "*****"
	dat += text("<HR>\n>[]<BR>\n<A href='?src=\ref[];type=1'>1</A>-<A href='?src=\ref[];type=2'>2</A>-<A href='?src=\ref[];type=3'>3</A><BR>\n<A href='?src=\ref[];type=4'>4</A>-<A href='?src=\ref[];type=5'>5</A>-<A href='?src=\ref[];type=6'>6</A><BR>\n<A href='?src=\ref[];type=7'>7</A>-<A href='?src=\ref[];type=8'>8</A>-<A href='?src=\ref[];type=9'>9</A><BR>\n<A href='?src=\ref[];type=R'>R</A>-<A href='?src=\ref[];type=0'>0</A>-<A href='?src=\ref[];type=E'>E</A><BR>\n</TT>", message, src, src, src, src, src, src, src, src, src, src, src, src)

	dat += text("<p><HR>\nChosen Gun: []", guntype)
	if(!gunspawned)
		dat += text("<p>\n Be careful! Once you chose your weapon and unlock the gun case, you won't be able to change it.")
		dat += text("<HR><p>\n<A href='?src=\ref[];type=m1911'>M1911</A>", src)
		dat += text("<p>\n<A href='?src=\ref[];type=legacy'>S&W Legacy</A>", src)
		dat += text("<p>\n<A href='?src=\ref[];type=saw620'>S&W 620</A>", src)
		dat += text("<p>\n<A href='?src=\ref[];type=m2019'>M2019 Detective Special</A>", src)
		dat += text("<p>\n<A href='?src=\ref[];type=det_m9'>T9 Patrol</A>", src)
	dat += text("<HR>")
	if(guntype)
		if(guntype == "M1911")
			dat += text("<p>\n A cheap Martian knock-off of a Colt M1911. Uses .45 rounds. Extremely popular among space detectives nowadays.")
			if(!gunspawned)
				dat += text("<p>\n Comes with two .45 seven round magazines and two .45 rubber seven round magazines.")
		else if(guntype == "S&W Legacy")
			dat += text("<p>\n A cheap Martian knock-off of a Smith & Wesson Model 10. Uses .38-Special rounds. Used to be NanoTrasen's service weapon for detectives.")
			if(!gunspawned)
				dat += text("<p>\n Comes with two .38 six round speedloaders and two .38 rubber six round speedloaders.")
		else if(guntype == "S&W 620")
			dat += text("<p>\n A cheap Martian knock-off of a Smith & Wesson Model 620. Uses .38-Special rounds. Quite popular among professionals.")
			if(!gunspawned)
				dat += text("<p>\n Comes with two .38 six round speedloaders and two .38 rubber six round speedloaders.")
		else if(guntype == "M2019")
			dat += text("<p>\n Quite a controversial weapon. Combining both pros and cons of revolvers and railguns, it's extremely versatile, yet requires a lot of care.")
			if(!gunspawned)
				dat += text("<p>\n Comes with three .44 SPEC five round speedloaders, two .44 CHEM five round speedloaders, and two replaceable power cells.")
				dat += text("<p>\n Brief instructions: <p>\n - M2019 Detective Special can be loaded with any type .44 rounds, yet works best with .44 CHEM and .44 SPEC.")
				dat += text("<p>\n - With a powercell installed, M2019 can be used in two modes: non-lethal and lethal.")
				dat += text("<p>\n - .44 SPEC no cell - works like a rubber bullet. <p>\n - .44 SPEC non-lethal - stuns the target. <p>\n - .44 SPEC lethal - accelerates the bullet, deals great damage and pierces medium armor.")
				dat += text("<p>\n - .44 CHEM no cell - works like a flash bullet. <p>\n - .44 CHEM non-lethal - emmits a weak electromagnetic impulse. <p>\n - .44 CHEM lethal - not supposed to be used like this. The cartride reaches extremely high temperature and melts.")
		else if(guntype == "T9 Patrol")
			dat += text("<p>\n A relatively cheap and reliable knock-off of a Beretta M9. Uses 9mm rounds. Used to be a standart-issue gun in almost every security company.")
			if(!gunspawned)
				dat += text("<p>\n Comes with three ten round 9mm magazines and two 9mm flash ten round magazines.")

	if(!lock_menu || lock_menu.user != user)
		lock_menu = new /datum/browser(user, "mob[name]", "<B>[src]</B>", 300, 280)
		lock_menu.set_content(dat)
	else
		lock_menu.set_content(dat)
		lock_menu.update()
	return

/obj/item/storage/secure/guncase/detective/Topic(href, href_list)
	if((usr.stat || usr.restrained()) || (get_dist(src, usr) > 1))
		return
	if(href_list["type"])
		if (href_list["type"] == "m1911")
			guntype = "M1911"
		else if(href_list["type"] == "legacy")
			guntype = "S&W Legacy"
		else if(href_list["type"] == "saw620")
			guntype = "S&W 620"
		else if(href_list["type"] == "m2019")
			guntype = "M2019"
		else if(href_list["type"] == "det_m9")
			guntype = "T9 Patrol"
		else if(href_list["type"] == "E")
			if((l_set == 0) && (length(code) == 5) && (!l_setshort) && (code != "ERROR"))
				l_code = src.code
				l_set = 1
			else if((code == l_code) && !emagged && (l_set == 1))
				locked = 0
				overlays.Cut()
				overlays += image(icon, icon_opened)
				code = null
				if(!gunspawned)
					spawn_set(guntype)
			else
				code = "ERROR"
		else
			if((href_list["type"] == "R") && !emagged && (!l_setshort))
				locked = 1
				overlays = null
				code = null
				close(usr)
			else
				code += text("[]", href_list["type"])
				if(length(code) > 5)
					code = "ERROR"
		for(var/mob/M in viewers(1, src.loc))
			if((M.client && M.machine == src))
				show_lock_menu(M)
			return
	return

/obj/item/storage/secure/guncase/detective/spawn_set(set_name)
	if(gunspawned)
		return
	switch(set_name)
		if("M1911")
			new /obj/item/gun/projectile/pistol/colt/detective(src)
			new /obj/item/ammo_magazine/c45m/rubber(src)
			new /obj/item/ammo_magazine/c45m/rubber(src)
			new /obj/item/ammo_magazine/c45m/stun(src)
			new /obj/item/ammo_magazine/c45m/stun(src)
			new /obj/item/ammo_magazine/c45m(src)
			new /obj/item/ammo_magazine/c45m(src)
		if("S&W Legacy")
			new /obj/item/gun/projectile/revolver/detective(src)
			new /obj/item/ammo_magazine/c38/rubber(src)
			new /obj/item/ammo_magazine/c38/rubber(src)
			new /obj/item/ammo_magazine/c38(src)
			new /obj/item/ammo_magazine/c38(src)
		if("S&W 620")
			new /obj/item/gun/projectile/revolver/detective/saw620(src)
			new /obj/item/ammo_magazine/c38/rubber(src)
			new /obj/item/ammo_magazine/c38/rubber(src)
			new /obj/item/ammo_magazine/c38(src)
			new /obj/item/ammo_magazine/c38(src)
		if("M2019")
			new /obj/item/gun/projectile/revolver/m2019/detective(src)
			new /obj/item/ammo_magazine/c38/spec(src)
			new /obj/item/ammo_magazine/c38/spec(src)
			new /obj/item/ammo_magazine/c38/spec(src)
			new /obj/item/ammo_magazine/c38/chem(src)
			new /obj/item/ammo_magazine/c38/chem(src)
			new /obj/item/cell/device/high(src)
		if("T9 Patrol")
			new /obj/item/gun/projectile/pistol/det_m9(src)
			new /obj/item/ammo_magazine/mc9mm(src)
			new /obj/item/ammo_magazine/mc9mm(src)
			new /obj/item/ammo_magazine/mc9mm(src)
			new /obj/item/ammo_magazine/mc9mm/flash(src)
			new /obj/item/ammo_magazine/mc9mm/flash(src)
		else
			return
	gunspawned = TRUE


/obj/item/storage/secure/guncase/security
	name = "security hardcase"
	icon_state = "guncasesec"
	item_state = "guncase"
	desc = "A heavy-duty container with an ID-based locking system. This one is painted in NT Security colors."
	override_w_class = list(/obj/item/gun/energy/security)
	max_storage_space = null
	storage_slots = 7

/obj/item/storage/secure/guncase/security/attackby(obj/item/W, mob/user)
	var/obj/item/card/id/I = W.GetIdCard()
	if(I) // For IDs and PDAs and wallets with IDs
		if(!(access_security in I.GetAccess()))
			to_chat(user, SPAN("warning", "Access denied!"))
			return
		if(!guntype)
			to_chat(user, SPAN("warning", "\The [src] blinks red. You need to make a choice first."))
			return
		if(!gunspawned)
			spawn_set(guntype)
			lock_menu.close(user)
			for(var/thing in contents)
				if(istype(thing, /obj/item/gun/energy/security))
					var/obj/item/gun/energy/security/gun = thing
					gun.owner = I.registered_name
		to_chat(user, SPAN("notice", "You [locked ? "un" : ""]lock \the [src]."))
		locked = !locked
		overlays.Cut()
		if(!locked)
			overlays += image(icon, icon_opened)
		return
	return ..()

/obj/item/storage/secure/guncase/security/attack_self(mob/user)
	if(locked && !gunspawned)
		return ..()
	return attack_hand(user)

/obj/item/storage/secure/guncase/security/spawn_set(set_name)
	if(gunspawned)
		return
	var/obj/item/gun/energy/security/gun = null
	switch(set_name)
		if("Pistol")
			gun = new /obj/item/gun/energy/security(src)
			gun.subtype = decls_repository.get_decl(/decl/taser_types/pistol)
			gun.update_subtype()
			new /obj/item/shield/barrier(src)
		if("SMG")
			gun = new /obj/item/gun/energy/security(src)
			gun.subtype = decls_repository.get_decl(/decl/taser_types/smg)
			gun.update_subtype()
			new /obj/item/shield/barrier(src)
		if("Rifle")
			gun = new /obj/item/gun/energy/security(src)
			gun.subtype = decls_repository.get_decl(/decl/taser_types/rifle)
			gun.update_subtype()
			new /obj/item/shield/barrier(src)
		if("Classic")
			new /obj/item/gun/energy/classictaser(src)
			if(prob(70))
				new /obj/item/reagent_containers/vessel/bottle/small/darkbeer(src)
			else
				new /obj/item/reagent_containers/vessel/bottle/whiskey(src)
		else
			return
	new /obj/item/melee/baton/loaded(src)
	new /obj/item/handcuffs(src)
	new /obj/item/handcuffs(src)
	new /obj/item/reagent_containers/food/donut/normal(src)
	new /obj/item/reagent_containers/food/donut/normal(src)
	gunspawned = TRUE

/obj/item/storage/secure/guncase/security/show_lock_menu(mob/user)
	if(user.incapacitated() || !user.Adjacent(src) || !user.client)
		return
	user.set_machine(src)
	var/dat = text("It can be locked and unlocked by swiping your ID card across the lock.<br>")

	dat += text("<p><HR>\nChosen Gun: []", "[guntype ? guntype : "none"]")
	if(!gunspawned)
		dat += text("<p>\n Be careful! Once you chose your weapon and unlock the gun case, you won't be able to change it.")
		dat += text("<HR><p>\n<A href='?src=\ref[];type=Pistol'>Taser Pistol</A>", src)
		dat += text("<p>\n<A href='?src=\ref[];type=SMG'>Taser SMG</A>", src)
		dat += text("<p>\n<A href='?src=\ref[];type=Rifle'>Taser Rifle</A>", src)
		dat += text("<p>\n<A href='?src=\ref[];type=Classic'>Rusty Classic</A>", src)
	dat += text("<HR>")
	if(guntype)
		switch(guntype)
			if("Pistol")
				dat += text("<p>\n A taser pistol. The smallest of all the tasers. It only has a single fire mode, but each shot wields power.")
				dat += text("<p>\n Comes with a baton, a handheld barrier, a couple of handcuffs, and a pair of donuts.")
			if("SMG")
				dat += text("<p>\n A taser SMG. This model is not as powerful as pistols, but is capable of launching electrodes left and right with its remarkable rate of fire.")
				dat += text("<p>\n Comes with a baton, a handheld barrier, a couple of handcuffs, and a pair of donuts.")
			if("Rifle")
				dat += text("<p>\n A taser rifle. Bulky and heavy, it must be wielded with both hands. Although its rate of fire is way below average, it is capable of shooting stun beams.")
				dat += text("<p>\n Comes with a baton, a handheld barrier, a couple of handcuffs, and a pair of donuts.")
			if("Classic")
				dat += text("<p>\n A rusty-and-trusty taser. It's overall worse than the modern baseline tasers, but it still does its job. Useful for those who want to assert their robust dominance. Or, maybe, for old farts.")
				dat += text("<p>\n Comes with a baton, a couple of handcuffs, a pair of donuts, and a drink to stay cool.")

	if(!lock_menu || lock_menu.user != user)
		lock_menu = new /datum/browser(user, "mob[name]", "<B>[src]</B>", 300, 280)
		lock_menu.set_content(dat)
	else
		lock_menu.set_content(dat)
		lock_menu.update()
	return

/obj/item/storage/secure/guncase/security/Topic(href, href_list)
	if((usr.stat || usr.restrained()) || (get_dist(src, usr) > 1))
		return
	if(href_list["type"])
		guntype = href_list["type"]
		for(var/mob/M in viewers(1, loc))
			if((M.client && M.machine == src))
				show_lock_menu(M)
			return
	return
