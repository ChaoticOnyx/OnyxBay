/obj/item/gun/projectile/automatic
	mod_weight = 0.75
	mod_reach = 0.6
	mod_handy = 1.0
	load_method = MAGAZINE
	slot_flags = SLOT_BELT
	w_class = ITEM_SIZE_NORMAL
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 2)
	mag_insert_sound = 'sound/effects/weapons/gun/smg_magin.ogg'
	mag_eject_sound = 'sound/effects/weapons/gun/smg_magout.ogg'
	multi_aim = 1
	burst_delay = 2

/obj/item/gun/projectile/automatic/machine_pistol
	name = "prototype .45 machine pistol"
	desc = "A protoype lightweight, fast firing gun. Uses .45 rounds."
	icon_state = "mpistolen"
	item_state = "mpistolen"
	caliber = ".45"
	fire_sound = 'sound/effects/weapons/gun/fire1.ogg'
	ammo_type = /obj/item/ammo_casing/c45
	magazine_type = /obj/item/ammo_magazine/c45uzi
	allowed_magazines = /obj/item/ammo_magazine/c45uzi //more damage compared to the wt550, smaller mag size

	//machine pistol, like SMG but easier to one-hand with
	firemodes = list(
		list(mode_name = "semiauto",       burst = 1, fire_delay = 0,    move_delay = null, one_hand_penalty = 0, burst_accuracy = null,                    dispersion = null),
		list(mode_name = "3-round bursts", burst = 3, fire_delay = null, move_delay = 4,    one_hand_penalty = 1, burst_accuracy = list(0, -1,- 1),         dispersion = list(0.0, 0.6, 1.0)),
		list(mode_name = "5-round bursts", burst = 5, fire_delay = null, move_delay = 4,    one_hand_penalty = 2, burst_accuracy = list(0, -1, -1, -1, -2), dispersion = list(0.6, 0.6, 1.0, 1.0, 1.2))
		)
/obj/item/gun/projectile/automatic/machine_pistol/update_icon()
	if(ammo_magazine)
		icon_state = "mpistolen"
	else
		icon_state = "mpistolen-empty"
	..()

/obj/item/gun/projectile/automatic/machine_pistol/mini_uzi
	name = ".45 machine pistol"
	desc = "The Lumoco Arms MP6 Vesper, A fairly common machine pistol. Sometimes refered to as an 'uzi' by the backwater spacers it is often associated with. Uses .45 rounds."
	icon_state = "saber"
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2, TECH_ILLEGAL = 3)

/obj/item/gun/projectile/automatic/machine_pistol/mini_uzi/update_icon()
	if(ammo_magazine)
		icon_state = "saber"
	else
		icon_state = "saber-empty"
	..()

/obj/item/gun/projectile/automatic/prototype //Moved it to own subclass as its' no longer in use. LEGACY CODE. -Tsurupeta
	name = "prototype SMG"
	desc = "A protoype lightweight, fast firing gun. Uses 9mm rounds."
	icon_state = "saber"	//ugly no longer
	fire_sound = 'sound/effects/weapons/gun/fire1.ogg'
	w_class = ITEM_SIZE_NORMAL
	load_method = SPEEDLOADER //yup. until someone sprites a magazine for it.
	max_shells = 22
	caliber = "9mm"
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 2)
	ammo_type = /obj/item/ammo_casing/c9mm

	//machine pistol, easier to one-hand with
	firemodes = list(
		list(mode_name = "semiauto",       burst = 1, fire_delay = 0,    move_delay = null, one_hand_penalty = 0, burst_accuracy = null,                    dispersion = null),
		list(mode_name = "3-round bursts", burst = 3, fire_delay = null, move_delay = 4,    one_hand_penalty = 1, burst_accuracy = list(0, -1, -1),         dispersion = list(0.0, 0.6, 1.0)),
		list(mode_name = "5-round bursts", burst = 5, fire_delay = null, move_delay = 4,    one_hand_penalty = 2, burst_accuracy = list(0, -1, -1, -1, -2), dispersion = list(0.6, 0.6, 1.0, 1.0, 1.2))
		)

/obj/item/gun/projectile/automatic/wt550
	name = "9mm submachine gun"
	desc = "The WT-550 Saber is a cheap self-defense weapon, mass-produced by Ward-Takahashi for paramilitary and private use. Uses 9mm rounds."
	icon_state = "wt550"
	item_state = "wt550"
	wielded_item_state = "wt550-wielded"
	caliber = "9mm"
	fire_sound = 'sound/effects/weapons/gun/fire9.ogg'
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2)
	ammo_type = /obj/item/ammo_casing/c9mm/rubber
	magazine_type = /obj/item/ammo_magazine/mc9mmt/rubber
	allowed_magazines = /obj/item/ammo_magazine/mc9mmt
	one_hand_penalty= 1

	//machine pistol, like SMG but easier to one-hand with
	firemodes = list(
		list(mode_name = "semiauto",       burst = 1, fire_delay = 0,    move_delay = null, one_hand_penalty = 1, burst_accuracy = null,                    dispersion = null),
		list(mode_name = "3-round bursts", burst = 3, fire_delay = null, move_delay = 4,    one_hand_penalty = 2, burst_accuracy = list(0, -1, -1),         dispersion = list(0.0, 0.6, 1.0)),
		list(mode_name = "5-round bursts", burst = 5, fire_delay = null, move_delay = 4,    one_hand_penalty = 3, burst_accuracy = list(0, -1, -1, -1, -2), dispersion = list(0.6, 0.6, 1.0, 1.0, 1.2))
		)

/obj/item/gun/projectile/automatic/wt550/update_icon()
	icon_state = (ammo_magazine)? "wt550-[round(ammo_magazine.stored_ammo.len, 4)]" : "wt550"
	item_state = (ammo_magazine?.stored_ammo?.len) ? "wt550" : "wt550-empty"
	wielded_item_state = (ammo_magazine)? "wt550-wielded" : "wt550-wielded-empty"
	..()

/obj/item/gun/projectile/automatic/c20r
	name = "10mm submachine gun"
	desc = "The C-20r is a lightweight and rapid firing SMG, for when you REALLY need someone dead. Uses 10mm rounds. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp."
	icon_state = "c20r"
	item_state = "c20r"
	w_class = ITEM_SIZE_LARGE
	force = 10
	mod_weight = 0.9
	mod_reach = 0.75
	mod_handy = 1.0
	caliber = "10mm"
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2, TECH_ILLEGAL = 8)
	slot_flags = SLOT_BELT|SLOT_BACK
	magazine_type = /obj/item/ammo_magazine/a10mm
	allowed_magazines = /obj/item/ammo_magazine/a10mm
	auto_eject = 1
	auto_eject_sound = 'sound/effects/weapons/misc/smg_empty_alarm.ogg'
	one_hand_penalty = 2
	fire_sound = 'sound/effects/weapons/gun/fire_smg.ogg'

	//SMG
	firemodes = list(
		list(mode_name = "semiauto",       burst = 1, fire_delay = 0,    move_delay = null, one_hand_penalty = 2, burst_accuracy = null,                    dispersion = null),
		list(mode_name = "3-round bursts", burst = 3, fire_delay = null, move_delay = 4,    one_hand_penalty = 3, burst_accuracy = list(0, -1, -1),         dispersion = list(0.0, 0.6, 1.0)),
		list(mode_name = "5-round bursts", burst = 5, fire_delay = null, move_delay = 4,    one_hand_penalty = 4, burst_accuracy = list(0, -1, -1, -1, -2), dispersion = list(0.6, 0.6, 1.0, 1.0, 1.2))
		)

/obj/item/gun/projectile/automatic/c20r/update_icon()
	if(ammo_magazine)
		icon_state = "c20r-[round(ammo_magazine.stored_ammo.len, 4)]"
	else
		icon_state = "c20r"
	..()

/obj/item/gun/projectile/automatic/as75
	name = "assault rifle"
	desc = "The rugged AS-75 is a durable automatic weapon of a make popular on the frontier worlds. The serial number has been scratched off. Uses 5.56mm rounds."
	icon_state = "arifle"
	item_state = "arifle"
	w_class = ITEM_SIZE_HUGE
	force = 12.5
	mod_weight = 1.0
	mod_reach = 0.8
	caliber = "a556"
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1, TECH_ILLEGAL = 5)
	slot_flags = SLOT_BACK
	magazine_type = /obj/item/ammo_magazine/c556
	allowed_magazines = /obj/item/ammo_magazine/c556
	one_hand_penalty = 3
	wielded_item_state = "arifle-wielded"
	fire_sound = 'sound/effects/weapons/gun/fire_556.ogg'
	mag_insert_sound = 'sound/effects/weapons/gun/assaultrifle_magin.ogg'
	mag_eject_sound = 'sound/effects/weapons/gun/assaultrifle_magout.ogg'

	//Assault rifle, burst fire degrades quicker than SMG, worse one-handing penalty, slightly increased move delay
	firemodes = list(
		list(mode_name = "semiauto",       burst = 1, fire_delay = 0,    move_delay = null, one_hand_penalty = 3, burst_accuracy = null,                    dispersion = null),
		list(mode_name = "3-round bursts", burst = 3, fire_delay = null, move_delay = 6,    one_hand_penalty = 5, burst_accuracy = list(0, -1, -1),         dispersion = list(0.0, 0.6, 1.0)),
		list(mode_name = "5-round bursts", burst = 5, fire_delay = null, move_delay = 6,    one_hand_penalty = 6, burst_accuracy = list(0, -1, -2, -3, -3), dispersion = list(0.6, 1.0, 1.2, 1.2, 1.5))
		)

/obj/item/gun/projectile/automatic/as75/update_icon()
	if(ammo_magazine)
		if(ammo_magazine?.stored_ammo.len)
			icon_state = "arifle-loaded"
		else
			icon_state = "arifle-empty"
	else
		icon_state = "arifle"
	wielded_item_state = (ammo_magazine)? "arifle-wielded" : "arifle-wielded-empty"
	..()


/obj/item/gun/projectile/automatic/z8
	name = "bullpup assault rifle"
	desc = "The Z8 Bulldog is an older model bullpup carbine, made by the now defunct Zendai Foundries. Uses armor piercing 7.62mm rounds. Makes you feel like a space marine when you hold it."
	icon_state = "carbine"
	item_state = "z8carbine"
	w_class = ITEM_SIZE_HUGE
	force = 12.5
	mod_weight = 1.0
	mod_reach = 0.8
	mod_handy = 1.0
	caliber = "a762"
	origin_tech = list(TECH_COMBAT = 8, TECH_MATERIAL = 3)
	ammo_type = /obj/item/ammo_casing/a762
	slot_flags = SLOT_BACK
	magazine_type = /obj/item/ammo_magazine/a762
	allowed_magazines = /obj/item/ammo_magazine/a762
	auto_eject = 1
	auto_eject_sound = 'sound/effects/weapons/misc/smg_empty_alarm.ogg'
	one_hand_penalty = 5
	burst_delay = 3
	wielded_item_state = "z8carbine-wielded"
	fire_sound = 'sound/effects/weapons/gun/fire_762.ogg'
	mag_insert_sound = 'sound/effects/weapons/gun/z8_magin.ogg'
	mag_eject_sound = 'sound/effects/weapons/gun/z8_magout.ogg'

	//would have one_hand_penalty=4,5 but the added weight of a grenade launcher makes one-handing even harder
	firemodes = list(
		list(mode_name = "semiauto",       burst = 1,    fire_delay = 0,    move_delay = null, use_launcher = null, one_hand_penalty = 5, burst_accuracy = null,            dispersion = null),
		list(mode_name = "3-round bursts", burst = 3,    fire_delay = null, move_delay = 6,    use_launcher = null, one_hand_penalty = 6, burst_accuracy = list(0, -1, -1), dispersion = list(0.0, 0.6, 1.0)),
		list(mode_name = "fire grenades",  burst = null, fire_delay = null, move_delay = null, use_launcher = 1,    one_hand_penalty = 5, burst_accuracy = null,            dispersion = null)
		)

	var/use_launcher = 0
	var/obj/item/gun/launcher/grenade/underslung/launcher

/obj/item/gun/projectile/automatic/z8/Initialize()
	. = ..()
	launcher = new(src)

/obj/item/gun/projectile/automatic/z8/attackby(obj/item/I, mob/user)
	if((istype(I, /obj/item/grenade)))
		launcher.load(I, user)
	else
		..()

/obj/item/gun/projectile/automatic/z8/attack_hand(mob/user)
	if(user.get_inactive_hand() == src && use_launcher)
		launcher.unload(user)
	else
		..()

/obj/item/gun/projectile/automatic/z8/Fire(atom/target, mob/living/user, params, pointblank = 0, reflex = 0)
	if(use_launcher)
		launcher.Fire(target, user, params, pointblank, reflex)
		if(!launcher.chambered)
			switch_firemodes() //switch back automatically
	else
		..()

/obj/item/gun/projectile/automatic/z8/update_icon()
	if(ammo_magazine)
		if(ammo_magazine.stored_ammo.len)
			icon_state = "carbine-loaded"
		else
			icon_state = "carbine-empty"
	else
		icon_state = "carbine"
	..()

/obj/item/gun/projectile/automatic/z8/_examine_text(mob/user)
	. = ..()
	if(launcher.chambered)
		. += "\n\The [launcher] has \a [launcher.chambered] loaded."
	else
		. += "\n\The [launcher] is empty."


/obj/item/gun/projectile/automatic/l6_saw
	name = "light machine gun"
	desc = "A heavily modified 5.56x45mm light machine gun, designated 'L6 SAW'. Has 'Aussec Armoury - 2531' engraved on the reciever below the designation."
	icon_state = "l6closed5"
	item_state = "l6closed"
	wielded_item_state = "l6closed-wielded"
	w_class = ITEM_SIZE_HUGE
	force = 14.0
	mod_weight = 1.2
	mod_reach = 0.8
	mod_handy = 1.0
	slot_flags = 0
	max_shells = 50
	caliber = "a556"
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1, TECH_ILLEGAL = 2)
	slot_flags = 0 //need sprites for SLOT_BACK
	ammo_type = /obj/item/ammo_casing/a556
	magazine_type = /obj/item/ammo_magazine/box/a556
	allowed_magazines = list(/obj/item/ammo_magazine/box/a556, /obj/item/ammo_magazine/c556)
	burst_delay = 1.5
	burst = 5
	move_delay = 12
	one_hand_penalty = 8
	fire_sound = 'sound/effects/weapons/gun/lmg_fire.ogg'
	mag_insert_sound = 'sound/effects/weapons/gun/lmg_magin.ogg'
	mag_eject_sound = 'sound/effects/weapons/gun/lmg_magout.ogg'


	//LMG, better sustained fire accuracy than assault rifles (comparable to SMG), higer move delay and one-handing penalty
	//No single-shot or 3-round-burst modes since using this weapon should come at a cost to flexibility.
	firemodes = list(
		list(mode_name = "5-round bursts", burst = 5, move_delay = 12, one_hand_penalty = 8, burst_accuracy = list(0, -1, -1, -1, -2),             dispersion = list(0.0, 0.6, 0.6, 1.0, 1.0)),
		list(mode_name = "8-round bursts", burst = 8, move_delay = 15, one_hand_penalty = 9, burst_accuracy = list(0, -1, -1, -2, -2, -2, -3, -3), dispersion = list(0.6, 0.6, 1.0, 1.0, 1.2))
		)

	var/cover_open = 0

/obj/item/gun/projectile/automatic/l6_saw/mag
	icon_state = "l6closedmag"
	item_state = "l6closedmag"
	wielded_item_state = "l6closedmag-wielded"
	magazine_type = /obj/item/ammo_magazine/c556

/obj/item/gun/projectile/automatic/l6_saw/special_check(mob/user)
	if(cover_open)
		to_chat(user, SPAN("warning", "[src]'s cover is open! Close it before firing!"))
		return 0
	return ..()

/obj/item/gun/projectile/automatic/l6_saw/proc/toggle_cover(mob/user)
	cover_open = !cover_open
	if(cover_open)
		playsound(src.loc, 'sound/effects/weapons/gun/lmg_open.ogg', 50, 1)
	else
		playsound(src.loc, 'sound/effects/weapons/gun/lmg_close.ogg', 50, 1)
	to_chat(user, SPAN("notice", "You [cover_open ? "open" : "close"] [src]'s cover."))
	update_icon()

/obj/item/gun/projectile/automatic/l6_saw/attack_self(mob/user)
	if(cover_open)
		toggle_cover(user) //close the cover
	else
		return ..() //once closed, behave like normal

/obj/item/gun/projectile/automatic/l6_saw/attack_hand(mob/user)
	if(!cover_open && user.get_inactive_hand() == src)
		toggle_cover(user) //open the cover
	else
		return ..() //once open, behave like normal

/obj/item/gun/projectile/automatic/l6_saw/update_icon()
	if(istype(ammo_magazine, /obj/item/ammo_magazine/box))
		icon_state = "l6[cover_open ? "open" : "closed"][Ceiling(ammo_magazine.stored_ammo.len / 12)]"
		item_state = "l6[cover_open ? "open" : "closed"]"
	else if(ammo_magazine)
		icon_state = "l6[cover_open ? "open" : "closed"]mag"
		item_state = "l6[cover_open ? "open" : "closed"]mag"
	else
		icon_state = "l6[cover_open ? "open" : "closed"]-empty"
		item_state = "l6[cover_open ? "open" : "closed"]-empty"
	wielded_item_state = "[item_state]-wielded"
	..()

/obj/item/gun/projectile/automatic/l6_saw/load_ammo(obj/item/A, mob/user)
	if(!cover_open)
		to_chat(user, SPAN("warning", "You need to open the cover to load that into [src]."))
		return
	..()

/obj/item/gun/projectile/automatic/l6_saw/unload_ammo(mob/user, allow_dump = 1)
	if(!cover_open)
		to_chat(user, SPAN("warning", "You need to open the cover to unload [src]."))
		return
	..()
