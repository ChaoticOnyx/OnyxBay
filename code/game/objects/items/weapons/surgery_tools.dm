/* Surgery Tools
 * Contains:
 *		Retractor
 *		Hemostat
 *		Cautery
 *		Surgical Drill
 *		Scalpel
 *		Circular Saw
 */

/*
 * Retractor
 */
/obj/item/weapon/retractor
	name = "retractor"
	desc = "Retracts stuff."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	matter = list(MATERIAL_STEEL = 10000, MATERIAL_GLASS = 5000)
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 1)

/*
 * Hemostat
 */
/obj/item/weapon/hemostat
	name = "hemostat"
	desc = "You think you have seen this before."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	matter = list(MATERIAL_STEEL = 5000, MATERIAL_GLASS = 2500)
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 1)
	attack_verb = list("attacked", "pinched")

/obj/item/weapon/hemostat/pico
	name = "precision grasper"
	desc = "A thin rod with pico manipulators embedded in it allowing for fast and precise extraction."
	icon_state = "pico_grasper"
	surgery_speed = 0.5

/*
 * Cautery
 */
/obj/item/weapon/cautery
	name = "cautery"
	desc = "This stops bleeding."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	matter = list(MATERIAL_STEEL = 5000, MATERIAL_GLASS = 2500)
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 1)
	attack_verb = list("burnt")

/*
 * Surgical Drill
 */
/obj/item/weapon/surgicaldrill
	name = "surgical drill"
	desc = "You can drill using this item. You dig?"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "drill"
	hitsound = 'sound/effects/fighting/circsawhit.ogg'
	matter = list(MATERIAL_STEEL = 15000, MATERIAL_GLASS = 10000)
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 15.0
	sharp = 1
	w_class = ITEM_SIZE_NORMAL
	mod_weight = 1.0
	mod_reach = 0.6
	mod_handy = 0.9
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 1)
	attack_verb = list("drilled")

/*
 * Scalpel
 */
/obj/item/weapon/scalpel
	name = "scalpel"
	desc = "Cut, cut, and once more cut."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 7.5
	sharp = 1
	edge = 1
	w_class = ITEM_SIZE_TINY
	mod_weight = 0.5
	mod_reach = 0.5
	mod_handy = 1.0
	slot_flags = SLOT_EARS
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 1)
	matter = list(MATERIAL_STEEL = 10000, MATERIAL_GLASS = 5000)
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'

/*
 * Researchable Scalpels
 */
/obj/item/weapon/scalpel/laser1
	name = "laser scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field.  This one looks basic and could be improved."
	icon_state = "scalpel_laser1_on"
	damtype = "fire"
	surgery_speed = 0.8

/obj/item/weapon/scalpel/laser2
	name = "laser scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field.  This one looks somewhat advanced."
	icon_state = "scalpel_laser2_on"
	damtype = "fire"
	force = 12.0
	surgery_speed = 0.6

/obj/item/weapon/scalpel/laser3
	name = "laser scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field.  This one looks to be the pinnacle of precision energy cutlery!"
	icon_state = "scalpel_laser3_on"
	damtype = "fire"
	force = 15.0
	surgery_speed = 0.4

/obj/item/weapon/scalpel/manager
	name = "incision management system"
	desc = "A true extension of the surgeon's body, this marvel instantly and completely prepares an incision allowing for the immediate commencement of therapeutic steps."
	icon_state = "scalpel_manager_on"
	force = 7.5
	surgery_speed = 0.2

/*
 * Circular Saw
 */
/obj/item/weapon/circular_saw
	name = "circular saw"
	desc = "For heavy duty cutting."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw3"
	hitsound = 'sound/effects/fighting/circsawhit.ogg'
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 15.0
	w_class = ITEM_SIZE_NORMAL
	mod_weight = 1.2
	mod_reach = 0.65
	mod_handy = 0.9
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 1)
	matter = list(MATERIAL_STEEL = 20000, MATERIAL_GLASS = 10000)
	attack_verb = list("attacked", "slashed", "sawed", "cut")
	sharp = 1
	edge = 1
	var/improved = 0

/obj/item/weapon/circular_saw/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/material/wirerod) && improved == 0)
		user.drop_from_inventory(W)
		qdel(W)
		name = "circular spear"
		desc = "For heavy duty cutting in glory of The Emperor and The Imperium."
		icon_state = "chainspear"
		item_state = "chainspear"
		mod_weight = 1.3
		mod_reach = 1.55
		w_class = ITEM_SIZE_LARGE
		improved = 1
		surgery_speed = 1.2 // Well, it's bigger and heavier now
	if(istype(W,/obj/item/weapon/wirecutters) && improved == 1)
		new /obj/item/weapon/material/wirerod(get_turf(src)) //give back the wired rod
		name = "circular saw"
		desc = "For heavy duty cutting. It remembers its past glory..."
		icon_state = "saw3"
		item_state = "saw3"
		mod_weight = 1.2
		mod_reach = 0.65
		w_class = ITEM_SIZE_NORMAL
		improved = 0
		surgery_speed = 1.0
	..()


/obj/item/weapon/circular_saw/plasmasaw //Orange transparent chainsaw!
	name = "plasma saw"
	desc = "Perfect for cutting through ice."
	icon_state = "plasmasaw"
	force = 22.5
	surgery_speed = 0.5
	//improved = 2 // Jeez I'm waaay to lazy to draw sprites for plasma chainspear

/obj/item/weapon/circular_saw/plasmasaw/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/material/wirerod) && improved == 0)
		user.drop_from_inventory(W)
		qdel(W)
		name = "plasma spear"
		desc = "For The Heaviest-Dutiest cutting in glory of The Emperor and The Imperium."
		icon_state = "chainspearp"
		item_state = "chainspearp"
		mod_weight = 1.3
		mod_reach = 1.55
		w_class = ITEM_SIZE_LARGE
		improved = 1
		surgery_speed = 1.2 // Well, it's bigger and heavier now
	if(istype(W,/obj/item/weapon/wirecutters) && improved == 1)
		new /obj/item/weapon/material/wirerod(get_turf(src)) //give back the wired rod
		name = "circular saw"
		desc = "Perfect for cutting through ice. And bodies."
		icon_state = "plasmasaw"
		item_state = "plasmasaw"
		mod_weight = 1.2
		mod_reach = 0.65
		w_class = ITEM_SIZE_NORMAL
		improved = 0
		surgery_speed = 1.0
	..()

//misc, formerly from code/defines/weapons.dm
/obj/item/weapon/bonegel
	name = "bone gel"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone-gel"
	force = 0
	w_class = ITEM_SIZE_SMALL
	throwforce = 1.0

/obj/item/weapon/FixOVein
	name = "FixOVein"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "fixovein"
	force = 0
	throwforce = 1.0
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 3)
	w_class = ITEM_SIZE_SMALL
	var/usage_amount = 10

/obj/item/weapon/FixOVein/clot
	name = "capillary laying operation tool" //C.L.O.T.
	desc = "A canister like tool that stores synthetic vein."
	icon_state = "clot"
	surgery_speed = 0.5

/obj/item/weapon/bonesetter
	name = "bone setter"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone setter"
	force = 8.0
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	mod_weight = 0.75
	mod_reach = 0.5
	mod_handy = 0.75
	attack_verb = list("attacked", "hit", "bludgeoned")

/obj/item/weapon/bonesetter/bone_mender
	name = "bone mender"
	desc = "A favorite among skeletons. It even sounds like a skeleton too."
	icon_state = "bone-mender"
	surgery_speed = 0.5

/obj/item/weapon/organfixer
	name = "organ fixer"
	desc = "A device used to fix internal organs."
	icon = 'icons/obj/surgery.dmi'
	item_state = "scientology" // TODO: Draw a proper handheld sprite; For now it looks fine ~Toby
	force = 8.0
	throwforce = 8.0
	w_class = ITEM_SIZE_NORMAL
	mod_weight = 0.9
	mod_reach = 0.6
	mod_handy = 1.0
	origin_tech = list(TECH_MATERIAL = 2, TECH_BIO = 3)
	matter = list(MATERIAL_STEEL = 10000, MATERIAL_GLASS = 5000)
	var/gel_amt_max = 10
	var/gel_amt = 10
	var/emagged = 0 // Emagged organ fixer destroys organs for good

/obj/item/weapon/organfixer/New()
	..()
	update_icon()

/obj/item/weapon/organfixer/update_icon()
	if(gel_amt == 0)
		icon_state = "[initial(icon_state)]-empty"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/weapon/organfixer/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/medical/advanced/bruise_pack))
		if(gel_amt_max == -1)
			to_chat(user, SPAN("notice", "\The [src] doesn't seem to be reloadable."))
			return
		var/obj/item/stack/medical/advanced/bruise_pack/O = I
		if(!O.get_amount())
			to_chat(user, SPAN("warning", "You are trying to refill \the [src] using an empty container."))
			return
		if(refill())
			to_chat(user, SPAN("notice", "You load some [O] into the [src]."))
			O.use(1)
		else
			to_chat(user, SPAN("notice", "\The [src] is full."))
		return
	else
		..()

/obj/item/weapon/organfixer/examine(mob/user)
	. = ..()
	if(. && user.Adjacent(src))
		if(gel_amt_max > 0)
			if(gel_amt == 0)
				to_chat(user, "It's empty.")
			else
				to_chat(user, "It has [gel_amt] doses of gel left.")

/obj/item/weapon/organfixer/emag_act(remaining_charges, mob/user)
	if(emagged)
		return
	emagged = 1
	to_chat(user, "<span class='danger'>You overload \the [src]'s circuits.</span>")
	return 1

/obj/item/weapon/organfixer/proc/refill(amt = 1)
	if(gel_amt >= gel_amt_max)
		return 0
	gel_amt += amt
	update_icon()
	return 1

/obj/item/weapon/organfixer/standard
	desc = "QROF-26 produced by Vey-Med. This easy-to-use device utilizes somatic gel in order to repair even severely damaged internal organs."
	icon_state = "organ-fixer"

/obj/item/weapon/organfixer/standard/empty
	gel_amt = 0

/obj/item/weapon/organfixer/advanced
	name = "advanced organ fixer"
	desc = "A modified version of QROF-26. This model uses a cluster of advanced manipulators, which allows it to fix multiple organs at once, as well as an enlarged gel storage tank."
	icon_state = "organ-fixer-up"
	gel_amt_max = 20
	gel_amt = 20
	origin_tech = list(TECH_MATERIAL = 4, TECH_ENGINEERING = 3, TECH_BIO = 4)

/obj/item/weapon/organfixer/advanced/empty
	gel_amt = 0

/obj/item/weapon/organfixer/advanced/bluespace
	name = "bluespace organ fixer"
	desc = "A heavyly modified device, resembling QROF-26 produced by Vey-Med. This prototype has some sort of bluespace-related device attached, and doesn't seem to have any gel injection ports."
	icon_state = "organ-fixer-bs"
	gel_amt_max = -1
	gel_amt = -1
	surgery_speed = 0.6
	origin_tech = list(TECH_MATERIAL = 5, TECH_ENGINEERING = 3, TECH_BIO = 5, TECH_BLUESPACE = 2)

/obj/item/weapon/organfixer/advanced/bluespace/refill()
	return 0
