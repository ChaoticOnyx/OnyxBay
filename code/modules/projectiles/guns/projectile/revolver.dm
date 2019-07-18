/obj/item/weapon/gun/projectile/revolver
	name = "revolver"
	desc = "The Lumoco Arms HE Colt is a choice revolver for when you absolutely, positively need to put a hole in the other guy. Uses .357 ammo."
	icon_state = "revolver"
	item_state = "revolver"
	caliber = "357"
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	handle_casings = CYCLE_CASINGS
	max_shells = 6
	mod_weight = 0.7
	mod_reach = 0.5
	mod_handy = 1.0
	fire_delay = 6.75 //Revolvers are naturally slower-firing
	ammo_type = /obj/item/ammo_casing/a357
	var/chamber_offset = 0 //how many empty chambers in the cylinder until you hit a round

/obj/item/weapon/gun/projectile/revolver/hos
	name = "Colt Python"
	desc = "The Lumoco Arms Colt Python is a choice revolver for when you absolutely, positively need to put a hole in a criminal. Uses .357 ammo."
	icon_state = "mateba-hos"
	item_state = "revolver"
	caliber = "357"
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 3)
	handle_casings = CYCLE_CASINGS
	max_shells = 6
	mod_weight = 0.7
	mod_reach = 0.5
	mod_handy = 1.0
	fire_delay = 6.75 //Revolvers are naturally slower-firing
	ammo_type = /obj/item/ammo_casing/a357

/obj/item/weapon/gun/projectile/revolver/AltClick()
	if(CanPhysicallyInteract(usr))
		spin_cylinder()

/obj/item/weapon/gun/projectile/revolver/verb/spin_cylinder()
	set name = "Spin cylinder"
	set desc = "Fun when you're bored out of your skull."
	set category = "Object"

	chamber_offset = 0
	visible_message("<span class='warning'>\The [usr] spins the cylinder of \the [src]!</span>", \
	"<span class='notice'>You hear something metallic spin and click.</span>")
	playsound(src.loc, 'sound/weapons/revolver_spin.ogg', 100, 1)
	loaded = shuffle(loaded)
	if(rand(1,max_shells) > loaded.len)
		chamber_offset = rand(0,max_shells - loaded.len)

/obj/item/weapon/gun/projectile/revolver/consume_next_projectile()
	if(chamber_offset)
		chamber_offset--
		return
	return ..()

/obj/item/weapon/gun/projectile/revolver/load_ammo(var/obj/item/A, mob/user)
	chamber_offset = 0
	return ..()

/obj/item/weapon/gun/projectile/revolver/mateba
	name = "mateba"
	icon_state = "mateba"
	caliber = ".50"
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	ammo_type = /obj/item/ammo_casing/a50

/obj/item/weapon/gun/projectile/revolver/detective
	name = "Legacy .38"
	desc = "A cheap Martian knock-off of a Smith & Wesson Model 10. Uses .38-Special rounds."
	icon_state = "detective"
	max_shells = 6
	caliber = "38"
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	ammo_type = /obj/item/ammo_casing/c38

/obj/item/weapon/gun/projectile/revolver/detective/saw620
	name = "S&W 620"
	desc = "A cheap Martian knock-off of a Smith & Wesson Model 620. Uses .38-Special rounds."
	icon_state = "saw620"


/obj/item/weapon/gun/projectile/revolver/detective/verb/rename_gun()
	set name = "Name Gun"
	set category = "Object"
	set desc = "Click to rename your gun. If you're the detective."

	var/mob/M = usr
	if(!M.mind)	return 0
	if(!M.mind.assigned_role == "Detective")
		to_chat(M, "<span class='notice'>You don't feel cool enough to name this gun, chump.</span>")
		return 0

	var/input = sanitizeSafe(input("What do you want to name the gun?", ,""), MAX_NAME_LEN)

	if(src && input && !M.stat && in_range(M,src))
		SetName(input)
		to_chat(M, "You name the gun [input]. Say hello to your new friend.")
		return 1


// Blade Runner pistol.
/obj/item/weapon/gun/projectile/revolver/deckard
	name = "Deckard .44"
	desc = "A custom-built revolver, based off the semi-popular Detective Special model."
	icon_state = "deckard-empty"
	ammo_type = /obj/item/ammo_magazine/c38/rubber

/obj/item/weapon/gun/projectile/revolver/deckard/emp
	ammo_type = /obj/item/ammo_casing/c38/emp

/obj/item/weapon/gun/projectile/revolver/deckard/update_icon()
	..()
	if(loaded.len)
		icon_state = "deckard-loaded"
	else
		icon_state = "deckard-empty"

/obj/item/weapon/gun/projectile/revolver/deckard/load_ammo(var/obj/item/A, mob/user)
	if(istype(A, /obj/item/ammo_magazine))
		flick("deckard-reload",src)
	..()

/obj/item/weapon/gun/projectile/revolver/capgun
	name = "cap gun"
	desc = "Looks almost like the real thing! Ages 8 and up."
	icon_state = "revolver-toy"
	item_state = "revolver"
	caliber = "caps"
	origin_tech = list(TECH_COMBAT = 1, TECH_MATERIAL = 1)
	handle_casings = CYCLE_CASINGS
	max_shells = 7
	ammo_type = /obj/item/ammo_casing/cap

/obj/item/weapon/gun/projectile/revolver/capgun/attackby(obj/item/weapon/wirecutters/W, mob/user)
	if(!istype(W) || icon_state == "revolver")
		return ..()
	to_chat(user, "<span class='notice'>You snip off the toy markings off the [src].</span>")
	name = "revolver"
	icon_state = "revolver"
	desc += " Someone snipped off the barrel's toy mark. How dastardly."
	return 1

/obj/item/weapon/gun/projectile/revolver/webley
	name = "service revolver"
	desc = "A rugged top break revolver based on the Webley Mk. VI model, with modern improvements. Uses .44 magnum rounds."
	icon_state = "webley"
	item_state = "webley"
	max_shells = 6
	caliber = ".44"
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	ammo_type = /obj/item/ammo_casing/c44

/obj/item/weapon/gun/projectile/revolver/m2019/detective
	name = "M2019 Detective Special"
	desc = "Though this one resembles a regular NT's M2019, it is definitely a masterpiece. It can use any .44 round, but works best with .44 SPEC and .44 CHEM."
	var/base_icon = "lapd2019"
	icon_state = "lapd201900"
	item_state = "lapd2019"
	max_shells = 5
	caliber = ".44"
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 3)
	ammo_type = /obj/item/ammo_casing/c44
	starts_loaded = 0
	var/chargemode = 1
	var/shotcost = 20
	var/obj/item/weapon/cell/bcell

/obj/item/weapon/gun/projectile/revolver/m2019/detective/New()
	bcell = new /obj/item/weapon/cell/device/high(src)
	update_icon()
	..()

/*obj/item/weapon/gun/projectile/revolver/m2019/detective/proc/deductcharge(var/chrgdeductamt)
	if(bcell)
		if(bcell.checked_use(chrgdeductamt))
			return 1
		else
			status = 0
			update_icon()
			return 0
	return null*/


/obj/item/weapon/gun/projectile/revolver/m2019/detective/examine(mob/user)
	. = ..()
	if(!bcell)
		to_chat(user, "\The [src] has no power cell installed.")
	else
		to_chat(user, "\The [src] is [round(bcell.percent())]% charged.")

/obj/item/weapon/gun/projectile/revolver/m2019/detective/consume_next_projectile()
	if(chamber_offset)
		chamber_offset--
	//get the next casing
	if(loaded.len)
		chambered = loaded[1] //load next casing.
		if(handle_casings != HOLD_CASINGS)
			loaded -= chambered
			if(usecharge(shotcost))
				if(chargemode == 1)
					if(istype(chambered, /obj/item/ammo_casing/c44/spec))
						chambered = new /obj/item/ammo_casing/c44/spec/nonlethal(src)
					else if(istype(chambered, /obj/item/ammo_casing/c44/chem))
						chambered = new /obj/item/ammo_casing/c44/chem/nonlethal(src)
				else if (chargemode == 2)
					if(istype(chambered, /obj/item/ammo_casing/c44/spec))
						chambered = new /obj/item/ammo_casing/c44/spec/lethal(src)
					else if(istype(chambered, /obj/item/ammo_casing/c44/chem))
						chambered = new /obj/item/ammo_casing/c44/chem/lethal(src)

	if (chambered)
		return chambered.BB
	return null

/obj/item/weapon/gun/projectile/revolver/m2019/detective/attack_self(mob/living/user as mob)
	if(chargemode == 0)
		to_chat(user, "<span class='warning'>[src] has no battery installed!</span>")
		return
	else if(chargemode == 2)
		to_chat(user, "<span class='notice'>[src] fire mode: non-lethal.</span>")
		chargemode = 1
	else if(chargemode == 1)
		to_chat(user, "<span class='warning'>[src] fire mode: lethal.</span>")
		chargemode = 2
	update_icon()

/obj/item/weapon/gun/projectile/revolver/m2019/detective/attackby(obj/item/weapon/cell/device/C, mob/user)
	if(!istype(C))
		return ..()
	insert_cell(C, user)
	return 1
/obj/item/weapon/gun/projectile/revolver/m2019/detective/proc/usecharge(var/UC)
	if(bcell)
		if(bcell.checked_use(UC))
			return 1
		else
			update_icon()
			return 0
	return null

/obj/item/weapon/gun/projectile/revolver/m2019/detective/proc/insert_cell(obj/item/weapon/cell/B, mob/user)
	if(bcell)
		to_chat(user, "<span class='notice'>[src] already has the [bcell] installed.</span>")
		return
	if(user.unEquip(B))
		to_chat(user, "<span class='notice'>You install the [B] into your [src].</span>")
		bcell = B
		bcell.forceMove(src)
		chargemode = 1
		update_icon()

/obj/item/weapon/gun/projectile/revolver/m2019/detective/verb/remove_cell()
	set name = "Remove Powercell"
	set desc = "Remove the powercell from your gun."
	set category = "Object"

	if(!bcell) return
	to_chat(usr, "<span class='notice'>You remove the [bcell.name] from your [src].</span>")
	usr.put_in_hands(bcell)
	bcell = null
	chargemode = 0
	update_icon()
	return

/obj/item/weapon/gun/projectile/revolver/m2019/detective/AltClick()
	if(CanPhysicallyInteract(usr))
		unload_ammo(usr)

/obj/item/weapon/gun/projectile/revolver/m2019/detective/update_icon()
	..()
	if(loaded.len)
		icon_state = "[src.base_icon]-loaded"
	else
		icon_state = "[src.base_icon]-empty"
	if(!bcell || (bcell.charge < shotcost))
		icon_state = "[icon_state]0"
	else
		icon_state = "[icon_state][chargemode]"