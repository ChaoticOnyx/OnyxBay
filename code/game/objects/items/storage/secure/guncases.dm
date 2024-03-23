/obj/item/storage/secure/guncase
	name = "guncase"
	desc = "A heavy-duty container with a digital locking system. Has a thick layer of foam inside."
	icon_state = "guncase"
	item_state = "guncase"
	icon_opened = "guncase0"
	inspect_state = FALSE
	force = 8.0
	throw_range = 4
	w_class = ITEM_SIZE_LARGE
	mod_weight = 1.4
	mod_reach = 0.7
	mod_handy = 1.0
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = DEFAULT_BACKPACK_STORAGE

	var/guntype = null
	var/gunspawned = FALSE

	/// An associative list of possible guns. 'gun name' = 'gun description'
	var/list/possible_guns = list()

	/// An associative list of gun - contents.
	var/list/gun_spawn = list()

/obj/item/storage/secure/guncase/attack_hand(mob/user)
	if(loc == user && locked == 1)
		show_splash_text(user, "locked!", SPAN("warning", "\The [src] is locked!"))

	else if(loc == user && !locked)
		open(usr)

	else
		..()
		for(var/mob/M in range(1))
			if(M.s_active == src)
				close(M)

	add_fingerprint(user)

/obj/item/storage/secure/guncase/open(mob/user)
	tgui_update()
	return ..()

/obj/item/storage/secure/guncase/close(mob/user)
	tgui_update()
	return ..()

/obj/item/storage/secure/guncase/attack_self(mob/user)
	return tgui_interact(user)

/obj/item/storage/secure/guncase/proc/spawn_set(set_name)
	if(gunspawned)
		return

	if(!length(gun_spawn[set_name]))
		return

	for(var/path in gun_spawn[set_name])
		new path (src)

	gunspawned = TRUE

/obj/item/storage/secure/guncase/tgui_data(mob/user)
	var/list/data = list(
		"chosenGun" = guntype,
		"gunSpawned" = gunspawned,
		"possibleGuns",
	)

	for(var/gun_name in possible_guns)
		var/list/gun_data = list(
			"gunName" = gun_name,
			"gunDesc" = possible_guns[gun_name]
		)
		data["possibleGuns"] += list(gun_data)

	if(!isnull(guntype))
		data["chosenGunDesc"] = possible_guns[guntype]

	data += ..()

	return data

/obj/item/storage/secure/guncase/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(.)
		return TRUE

	if(action != "chooseGun")
		return

	switch(action)
		if("chooseGun")
			guntype = params["gunName"]
			return TRUE

/obj/item/storage/secure/guncase/detective
	name = "detective's gun case"
	icon_state = "guncasedet"
	item_state = "guncasedet"
	desc = "A heavy-duty container with a digital locking system. This one has a wooden coating and its locks are the color of brass."
	guntype = "M1911"

	possible_guns = list(
		"M1911" = "A cheap Martian knock-off of a Colt M1911. Uses .45 rounds. Extremely popular among space detectives nowadays. Comes with two .45 seven round magazines and two .45 rubber seven round magazines.",
		"S&W Legacy" = "A cheap Martian knock-off of a Smith & Wesson Model 10. Uses .38-Special rounds. Used to be NanoTrasen's service weapon for detectives. Comes with two .38 six round speedloaders and two .38 rubber six round speedloaders.",
		"S&W 620" = "A cheap Martian knock-off of a Smith & Wesson Model 620. Uses .38-Special rounds. Quite popular among professionals.Comes with two .38 six round speedloaders and two .38 rubber six round speedloaders.",
		"M2019" = "Quite a controversial weapon. Combining both pros and cons of revolvers and railguns, it's extremely versatile, yet requires a lot of care. Comes with three .38 SPEC five round speedloaders, two .38 CHEM five round speedloaders, and two replaceable power cells.",
		"T9 Patrol" = "A relatively cheap and reliable knock-off of a Beretta M9. Uses 9mm rounds. Used to be a standart-issue gun in almost every security company. Comes with three ten round 9mm magazines and two 9mm flash ten round magazines."
	)

	gun_spawn = list(
		"M1911" = list(
			/obj/item/gun/projectile/pistol/colt/detective,
			/obj/item/ammo_magazine/c45m/rubber,
			/obj/item/ammo_magazine/c45m/rubber,
			/obj/item/ammo_magazine/c45m/stun,
			/obj/item/ammo_magazine/c45m/stun,
			/obj/item/ammo_magazine/c45m,
			/obj/item/ammo_magazine/c45m
		),
		"S&W Legacy" = list(
			/obj/item/gun/projectile/revolver/detective,
			/obj/item/ammo_magazine/c38/rubber,
			/obj/item/ammo_magazine/c38/rubber,
			/obj/item/ammo_magazine/c38,
			/obj/item/ammo_magazine/c38
		),
		"S&W 620" = list(
			/obj/item/gun/projectile/revolver/detective/saw620,
			/obj/item/ammo_magazine/c38/rubber,
			/obj/item/ammo_magazine/c38/rubber,
			/obj/item/ammo_magazine/c38,
			/obj/item/ammo_magazine/c38
		),
		"M2019" = list(
			/obj/item/gun/projectile/revolver/m2019/detective,
			/obj/item/ammo_magazine/c38/spec,
			/obj/item/ammo_magazine/c38/spec,
			/obj/item/ammo_magazine/c38/spec,
			/obj/item/ammo_magazine/c38/chem,
			/obj/item/ammo_magazine/c38/chem,
			/obj/item/cell/device/high
		),
		"T9 Patrol" = list(
			/obj/item/gun/projectile/pistol/det_m9,
			/obj/item/ammo_magazine/mc9mm,
			/obj/item/ammo_magazine/mc9mm,
			/obj/item/ammo_magazine/mc9mm,
			/obj/item/ammo_magazine/mc9mm/flash,
			/obj/item/ammo_magazine/mc9mm/flash
		)
	)

/obj/item/storage/secure/guncase/detective/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DetectiveGuncase", name)
		ui.open()

/obj/item/storage/secure/guncase/detective/open(mob/user)
	if(!guntype)
		show_splash_text(user, "no gun selected!", SPAN("warning", "You must select a gun first!"))
		return

	if(!gunspawned)
		tgui_update()
		spawn_set(guntype)

	return ..()

/obj/item/storage/secure/guncase/security
	name = "security hardcase"
	icon_state = "guncasesec"
	item_state = "guncase"
	desc = "A heavy-duty container with an ID-based locking system. This one is painted in NT Security colors."
	override_w_class = list(/obj/item/gun/energy/security)
	max_storage_space = null
	storage_slots = 7

	possible_guns = list(
		"Pistol" = "A taser pistol. The smallest of all the tasers. It only has a single fire mode, but each shot wields power. Comes with a baton, a handheld barrier, a couple of handcuffs, and a pair of donuts.",
		"SMG" = "A taser SMG. This model is not as powerful as pistols, but is capable of launching electrodes left and right with its remarkable rate of fire. Comes with a baton, a handheld barrier, a couple of handcuffs, and a pair of donuts.",
		"Rifle" = "A taser rifle. Bulky and heavy, it must be wielded with both hands. Although its rate of fire is way below average, it is capable of shooting stun beams. Comes with a baton, a handheld barrier, a couple of handcuffs, and a pair of donuts.",
		"Classic" = "A rusty-and-trusty taser. It's overall worse than the modern baseline tasers, but it still does its job. Useful for those who want to assert their robust dominance. Or, maybe, for old farts. Comes with a baton, a couple of handcuffs, a pair of donuts, and a drink to stay cool."
	)

	gun_spawn = list(
		"Pistol" = list(
			/obj/item/gun/energy/security/pistol,
			/obj/item/shield/barrier
		),
		"SMG" = list(
			/obj/item/gun/energy/security/smg,
			/obj/item/shield/barrier
		),
		"Rifle" = list(
			/obj/item/gun/energy/security/rifle,
			/obj/item/shield/barrier
		),
		"Classic" = list(
			/obj/item/gun/energy/classictaser
		)
	)

	req_access = list(access_security )

/obj/item/storage/secure/guncase/security/attackby(obj/item/W, mob/user)
	var/obj/item/card/id/I = W.get_id_card()
	if(istype(I))
		if(!allowed(user))
			show_splash_text(user, "access denied!", SPAN("warning", "\icon[src] Access Denied!"))
			return

		if(!guntype)
			show_splash_text(user, "no gun selected!", SPAN("warning", "You must select a gun first!"))
			return

		if(!gunspawned)
			tgui_update()
			spawn_set(guntype)
			for(var/obj/item/gun/energy/security/gun in contents)
				gun.owner = I.registered_name

		show_splash_text(user, "[locked ? "un" : ""]locked", SPAN("notice", "You [locked ? "un" : ""]lock \the [src]."))
		locked = !locked
		update_icon()
		return

	else return ..()

/obj/item/storage/secure/guncase/security/spawn_set(set_name)
	new /obj/item/melee/baton/loaded(src)
	new /obj/item/handcuffs(src)
	new /obj/item/handcuffs(src)
	new /obj/item/reagent_containers/food/donut/normal(src)
	new /obj/item/reagent_containers/food/donut/normal(src)

	if(set_name == "Classic")
		if(prob(70))
			new /obj/item/reagent_containers/vessel/bottle/small/darkbeer(src)
		else
			new /obj/item/reagent_containers/vessel/bottle/whiskey(src)

	..()

/obj/item/storage/secure/guncase/security/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Guncase", name)
		ui.open()

/obj/item/storage/secure/guncase/security/hos
	name = "high command security hardcase"
	desc = "A heavy-duty container with an ID-based locking system. This one is painted in NT High Command Security colors."
	icon_state = "guncasehos"
	override_w_class = list(/obj/item/gun/projectile/lawgiver)

	possible_guns = list(
		"Razor" = "Hephaestus Industries G50SE \"Razor\", a cheaper version of G50XS \"Raijin\". It has lethal and stun settings.",
		"Lawgiver" = "The Lawgiver II. A twenty-five round sidearm with mission-variable voice-programmed ammunition. You must use the words STUN, LASER, RAPID, FLASH and AP to change modes."
	)

	gun_spawn = list(
		"Lawgiver" = list(
			/obj/item/gun/projectile/lawgiver,
			/obj/item/ammo_magazine/lawgiver
		),
		"Razor" = list(
			/obj/item/gun/energy/rifle/cheap
		)
	)

	req_access = list(access_hos)

/obj/item/storage/secure/guncase/security/hos/spawn_set(set_name)
	if(set_name != "Lawgiver") // Delete lawgiver steal contract, we can't get lawgiver legally.
		GLOB.contracts_steal_items.Remove("the head of security's lawgiver gun")
		for(var/datum/antag_contract/item/steal/C in GLOB.all_contracts)
			if(C.target_type == /obj/item/gun/projectile/lawgiver)
				C.remove()

	..()
