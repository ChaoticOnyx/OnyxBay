//** Shield Helpers
//These are shared by various items that have shield-like behaviour

//bad_arc is the ABSOLUTE arc of directions from which we cannot block. If you want to fix it to e.g. the user's facing you will need to rotate the dirs yourself.
/proc/check_shield_arc(mob/user, bad_arc, atom/damage_source = null, mob/attacker = null)
	//check attack direction
	var/attack_dir = 0 //direction from the user to the source of the attack
	if(istype(damage_source, /obj/item/projectile))
		var/obj/item/projectile/P = damage_source
		attack_dir = get_dir(get_turf(user), P.starting)
	else if(attacker)
		attack_dir = get_dir(get_turf(user), get_turf(attacker))
	else if(damage_source)
		attack_dir = get_dir(get_turf(user), get_turf(damage_source))

	if(!(attack_dir && (attack_dir & bad_arc)))
		return 1
	return 0

/proc/default_parry_check(mob/user, mob/attacker, atom/damage_source)
	//parry only melee attacks
	if(istype(damage_source, /obj/item/projectile) || (attacker && get_dist(user, attacker) > 1) || user.incapacitated())
		return 0

	//block as long as they are not directly behind us
	var/bad_arc = reverse_direction(user.dir) //arc of directions from which we cannot block
	if(!check_shield_arc(user, bad_arc, damage_source, attacker))
		return 0

	return 1

/obj/item/shield
	name = "shield"

/* This shit ain't working, guys. Fix it, please. ~Toby
/obj/item/shield/handle_shield(mob/user, damage, atom/damage_source = null, mob/attacker = null, def_zone = null, attack_text = "the attack")
	if(user.incapacitated())
		return 0

	//block as long as they are not directly behind us
	var/bad_arc = reverse_direction(user.dir) //arc of directions from which we cannot block
	if(check_shield_arc(user, bad_arc, damage_source, attacker))
		..()
	return 0*/

/obj/item/shield/riot
	name = "riot shield"
	desc = "A shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "riot"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BACK
	force = 15.0
	throwforce = 5.0
	throw_speed = 2
	throw_range = 4
	w_class = ITEM_SIZE_HUGE
	mod_weight = 2.0
	mod_reach = 1.5
	mod_handy = 1.5
	mod_shield = 2.0
	block_tier = BLOCK_TIER_PROJECTILE
	origin_tech = list(TECH_MATERIAL = 2)
	matter = list(MATERIAL_GLASS = 7500, MATERIAL_STEEL = 1000)
	attack_verb = list("shoved", "bashed")

/obj/item/shield/riot/handle_shield(mob/user, damage, atom/damage_source = null, mob/attacker = null, def_zone = null, attack_text = "the attack")
	. = ..()
	if(.)
		playsound(user.loc, 'sound/effects/fighting/Genhit.ogg', 50, 1)


/obj/item/shield/riot/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/melee/baton))
		THROTTLE(cooldown, 25)
		if(cooldown)
			user.visible_message("<span class='warning'>[user] bashes [src] with [W]!</span>")
			playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
			cooldown = world.time
	else
		..()

/obj/item/shield/buckler
	name = "buckler"
	desc = "A wooden buckler used to block sharp things from entering your body back in the day.."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "buckler"
	slot_flags = SLOT_BACK
	force = 8
	throwforce = 8
	throw_speed = 1
	throw_range = 20
	w_class = ITEM_SIZE_HUGE
	origin_tech = list(TECH_MATERIAL = 1)
	matter = list(MATERIAL_STEEL = 1000, MATERIAL_WOOD = 1000)
	attack_verb = list("shoved", "bashed")

/obj/item/shield/buckler/handle_shield(mob/user, damage, atom/damage_source = null, mob/attacker = null, def_zone = null, attack_text = "the attack")
	. = ..()
	if(.)
		playsound(user.loc, 'sound/effects/fighting/Genhit.ogg', 50, 1)

/*
 * Energy Shield
 */

/obj/item/shield/energy
	name = "energy combat shield"
	desc = "A shield capable of stopping most projectile and melee attacks. It can be retracted, expanded, and stored anywhere."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "eshield0" // eshield1 for expanded
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 5.0
	throwforce = 5.0
	throw_speed = 2
	throw_range = 4
	w_class = ITEM_SIZE_SMALL
	mod_weight = 0.35
	mod_reach = 0.3
	mod_handy = 1.0
	mod_shield = 3.0
	origin_tech = list(TECH_MATERIAL = 4, TECH_MAGNET = 3, TECH_ILLEGAL = 4)
	attack_verb = list("shoved", "bashed")
	var/active = 0

/obj/item/shield/energy/handle_shield(mob/user, damage, atom/damage_source = null, mob/attacker = null, def_zone = null, attack_text = "the attack")
	. = ..()
	if(. == PROJECTILE_FORCE_BLOCK)
		playsound(user.loc, 'sound/weapons/blade1.ogg', 50, 1)
	return

/obj/item/shield/energy/attack_self(mob/living/user)
	if((MUTATION_CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='warning'>You beat yourself in the head with [src].</span>")
		user.take_organ_damage(5)
	active = !active
	if(active)
		force = 15
		update_icon()
		w_class = ITEM_SIZE_HUGE
		mod_weight = 1.5
		mod_reach = 1.0
		mod_handy = 1.5
		mod_shield = 3.0
		block_tier = BLOCK_TIER_ADVANCED
		playsound(user, 'sound/weapons/saberon.ogg', 50, 1)
		to_chat(user, "<span class='notice'>\The [src] is now active.</span>")
	else
		force = 5
		update_icon()
		w_class = ITEM_SIZE_TINY
		mod_weight = initial(mod_weight)
		mod_reach = initial(mod_reach)
		mod_handy = initial(mod_handy)
		mod_shield = initial(mod_shield)
		block_tier = BLOCK_TIER_MELEE
		playsound(user, 'sound/weapons/saberoff.ogg', 50, 1)
		to_chat(user, "<span class='notice'>\The [src] can now be concealed.</span>")

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()

	add_fingerprint(user)
	return

/obj/item/shield/energy/update_icon()
	icon_state = "eshield[active]"
	if(active)
		set_light(0.4, 0.1, 1, 2, "#006aff")
	else
		set_light(0)


/*
 * Security Barrier
 */

/obj/item/shield/barrier
	name = "handheld barrier"
	desc = "An energy shield capable of stopping most projectile and melee attacks. It can be retracted and expanded. It relies on the charge, and can't take too much damage without its battery getting completely depleted."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "secshield0"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 5.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 4
	w_class = ITEM_SIZE_SMALL
	mod_weight = 0.35
	mod_reach = 0.3
	mod_handy = 1.0
	mod_shield = 3.0
	origin_tech = list(TECH_MATERIAL = 4, TECH_MAGNET = 3, TECH_ILLEGAL = 4)
	attack_verb = list("shoved", "bashed")
	var/active = 0
	var/obj/item/cell/device/cell = null

/obj/item/shield/barrier/Initialize()
	. = ..()
	cell = new /obj/item/cell/device/high(src)

/obj/item/shield/barrier/update_icon()
	if(!cell)
		icon_state = "secshield_nocell"
	else
		icon_state = "secshield[active]"
		item_state = icon_state
	if(active)
		set_light(0.4, 0.1, 1, 2, "#ffb200")
	else
		set_light(0)

/obj/item/shield/barrier/_examine_text(mob/user)
	. = ..()
	if(cell)
		. += SPAN("notice", "\nHas <b>[cell.percent()]%</b> charge left.")
	else
		. += "\n<b>Has no battery installed.</b>"

/obj/item/shield/barrier/attackby(obj/item/I, mob/user)
	if(isScrewdriver(I))
		if(!cell)
			to_chat(user, SPAN("notice", "\The [src] does not have a battery installed."))
			return
		if(active)
			to_chat(user, SPAN("notice", "You need to toggle \the [src] off first."))
			return
		cell.update_icon()
		cell.dropInto(loc)
		cell = null
		to_chat(user, SPAN("notice", "You remove the cell from the [src]."))
		update_icon()
		return
	if(istype(I, /obj/item/cell/device))
		if(!cell && user.unEquip(I))
			I.forceMove(src)
			cell = I
			to_chat(user, SPAN("notice", "You install a cell into \the the [src]."))
			update_icon()
		else
			to_chat(user, SPAN("notice", "\The [src] already has a cell."))
		return
	if(istype(I, /obj/item/melee/baton))
		THROTTLE(cooldown, 25)
		if(cooldown)
			user.visible_message(SPAN("warning", "[user] bashes [src] with [I]!"))
			playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
			cooldown = world.time
		return
	..()

/obj/item/shield/barrier/handle_shield(mob/user, damage, atom/damage_source = null, mob/attacker = null, def_zone = null, attack_text = "the attack")
	. = ..()
	if(. == PROJECTILE_FORCE_BLOCK)
		playsound(user.loc, 'sound/weapons/blade1.ogg', 50, 1)
		var/obj/item/projectile/P = damage_source
		var/discharge = P.get_structure_damage()
		cell.use(discharge)
		if(cell.charge <= 0)
			to_chat(user, SPAN("warning", "\The [src] goes offline!"))
			toggle(user, FALSE, TRUE)
			playsound(user, 'sound/effects/weapons/energy/no_power2.ogg', 50, 1)
	return

/obj/item/shield/barrier/proc/toggle(mob/user, new_state = null, no_message = FALSE)
	active = isnull(new_state) ? !active : new_state
	if(active)
		force = 12.5
		update_icon()
		w_class = ITEM_SIZE_HUGE
		mod_weight = 1.35
		mod_reach = 0.9
		mod_handy = 1.35
		mod_shield = 2.5
		block_tier = BLOCK_TIER_PROJECTILE
		playsound(loc, 'sound/effects/weapons/energy/unfold2.ogg', 50, 1)
		if(user && !no_message)
			to_chat(user, SPAN("notice", "\The [src] is now active."))
	else
		force = 5
		update_icon()
		w_class = ITEM_SIZE_TINY
		mod_weight = initial(mod_weight)
		mod_reach = initial(mod_reach)
		mod_handy = initial(mod_handy)
		mod_shield = initial(mod_shield)
		block_tier = BLOCK_TIER_MELEE
		playsound(loc, 'sound/effects/weapons/energy/unfold4.ogg', 50, 1)
		if(user && !no_message)
			to_chat(user, SPAN("notice", "\The [src] is now retracted."))

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()

/obj/item/shield/barrier/attack_self(mob/living/user)
	if(!cell)
		to_chat(user, SPAN("notice", "\The [src] does not have a battery installed."))
		return
	if(cell.charge <= 0)
		to_chat(user, SPAN("warning", "\The [src] is out of charge."))
		return
	if((MUTATION_CLUMSY in user.mutations) && prob(50))
		to_chat(user, SPAN("warning", "You beat yourself in the head with [src]."))
		user.take_organ_damage(5)
	toggle(user)
	add_fingerprint(user)
	return

