/obj/item/melee/energy
	var/active = FALSE
	var/active_force
	var/active_throwforce
	sharp = 0
	edge = 0
	armor_penetration = 50
	atom_flags = ATOM_FLAG_NO_BLOOD
	var/active_max_bright = 0.3
	var/active_outer_range = 1.6
	var/brightness_color
	var/needs_blocking = TRUE
	var/activate_sound = 'sound/weapons/saberon.ogg'
	var/deactivate_sound = 'sound/weapons/saberon.ogg'

/obj/item/melee/energy/proc/activate(mob/living/user)
	if(active)
		return
	active = TRUE
	force = active_force
	throwforce = active_throwforce
	sharp = 0
	edge = 1
	slot_flags |= SLOT_DENYPOCKET
	check_armour = "laser"
	playsound(user, activate_sound, 50, 1)

/obj/item/melee/energy/proc/deactivate(mob/living/user)
	if(!active)
		return
	playsound(user, deactivate_sound, 50, 1)
	active = FALSE
	force = initial(force)
	throwforce = initial(throwforce)
	sharp = initial(sharp)
	edge = initial(edge)
	slot_flags = initial(slot_flags)
	check_armour = "melee"

/obj/item/melee/energy/attack_self(mob/living/user)
	if(active)
		if(!clumsy_unaffected && (MUTATION_CLUMSY in user.mutations) && prob(50))
			user.visible_message(SPAN("danger", "\The [user] accidentally cuts \himself with \the [src]."), \
								 SPAN("danger", "You accidentally cut yourself with \the [src]."))
			user.take_organ_damage(5, 5)
		deactivate(user)
	else
		activate(user)

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()

	add_fingerprint(user)
	return

/obj/item/melee/energy/dropped()
	spawn(9)
		if(isturf(loc))
			deactivate()

/obj/item/melee/energy/get_storage_cost()
	if(active)
		return ITEM_SIZE_NO_CONTAINER
	return ..()

/obj/item/melee/energy/get_temperature_as_from_ignitor()
	if(active)
		return 3500
	return 0

/obj/item/melee/energy/sword/handle_shield(mob/user, damage, atom/damage_source = null, mob/attacker = null, def_zone = null, attack_text = "the attack")
	if(active && default_parry_check(user, attacker, damage_source) && prob(50))
		user.visible_message("<span class='danger'>\The [user] parries [attack_text] with \the [src]!</span>")
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, user.loc)
		spark_system.start()
		playsound(user.loc, 'sound/weapons/blade1.ogg', 50, 1)
		return 1
	return 0

/*
 * Energy Axe
 */
/obj/item/melee/energy/axe
	name = "energy axe"
	desc = "An energised battle axe."
	icon_state = "axe0"
	//active_force = 150 //holy...
	active_force = 60
	active_throwforce = 35
	//force = 40
	//throwforce = 25
	force = 20
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	atom_flags = ATOM_FLAG_NO_BLOOD
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	origin_tech = list(TECH_MAGNET = 3, TECH_COMBAT = 4)
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	sharp = 1
	edge = 1

/obj/item/melee/energy/axe/activate(mob/living/user)
	..()
	icon_state = "axe1"
	to_chat(user, "<span class='notice'>\The [src] is now energised.</span>")

/obj/item/melee/energy/axe/deactivate(mob/living/user)
	..()
	icon_state = initial(icon_state)
	to_chat(user, "<span class='notice'>\The [src] is de-energised. It's just a regular axe now.</span>")

/*
 * Energy Sword
 */
/obj/item/melee/energy/sword
	color
	active_force = 45
	active_throwforce = 45
	force = 3
	throwforce = 5
	throw_speed = 1
	throw_range = 10
	w_class = ITEM_SIZE_SMALL
	atom_flags = ATOM_FLAG_NO_BLOOD
	origin_tech = list(TECH_MAGNET = 3, TECH_ILLEGAL = 4)
	sharp = 0
	edge = 1
	hitsound = 'sound/effects/fighting/energy1.ogg'
	var/blade_color

/obj/item/melee/energy/sword/activate(mob/living/user)
	if(!active)
		to_chat(user, SPAN("notice", "\The [src] is now energised."))
	..()
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	icon_state = "sword[blade_color]"
	set_light(l_max_bright = active_max_bright, l_outer_range = active_outer_range, l_color = brightness_color)

/obj/item/melee/energy/sword/deactivate(mob/living/user)
	if(active)
		to_chat(user, SPAN("notice", "\The [src] deactivates!"))
	..()
	attack_verb = list()
	icon_state = initial(icon_state)
	set_light(0)

/obj/item/melee/energy/sword/one_hand
	name = "energy sword"
	desc = "May the force be within you."
	icon_state = "sword0"

/obj/item/melee/energy/sword/one_hand/New()
	var/list/colorparam = list("green" = "#68ff4d", "red" = "#ff5959", "blue" = "#4de4ff", "purple" = "#de4dff")
	blade_color = pick(colorparam)
	brightness_color = colorparam[blade_color]

/obj/item/melee/energy/sword/one_hand/green/New()
	blade_color = "green"
	brightness_color = "#68ff4d"

/obj/item/melee/energy/sword/one_hand/red/New()
	blade_color = "red"
	brightness_color = "#ff5959"

/obj/item/melee/energy/sword/one_hand/blue/New()
	blade_color = "blue"
	brightness_color = "#4de4ff"

/obj/item/melee/energy/sword/one_hand/purple/New()
	blade_color = "purple"
	brightness_color = "#de4dff"

/obj/item/melee/energy/sword/one_hand/attackby(obj/item/sword, mob/user)
	if(istype(sword, /obj/item/melee/energy/sword/one_hand))
		to_chat(user, SPAN("notice", "You attach the ends of the two energy swords, making a single double-bladed weapon!"))
		var/obj/item/melee/energy/sword/dualsaber/D = new /obj/item/melee/energy/sword/dualsaber(user.loc)
		user.drop_from_inventory(src)
		user.drop_from_inventory(sword)
		qdel(src)
		qdel(sword)
		user.put_in_hands(D)

/obj/item/melee/energy/sword/pirate
	name = "energy cutlass"
	desc = "Arrrr matey."
	icon_state = "cutlass0"
	brightness_color = "#ff5959"

/obj/item/melee/energy/sword/pirate/activate(mob/living/user)
	..()
	icon_state = "cutlass1"

/*
 *DualSaber
 */
/obj/item/melee/energy/sword/dualsaber
	name = "dualsaber"
	desc = "May the Dark side be within you."
	icon_state = "dualsaber0"
	active_force = 60
	active_throwforce = 70
	force = 5
	throwforce = 10
	throw_speed = 1
	throw_range = 10
	origin_tech = list(TECH_MAGNET = 4, TECH_ILLEGAL = 5)
	var/base_block_chance = 50
	active_max_bright = 0.5
	active_outer_range = 1.8

/obj/item/melee/energy/sword/dualsaber/New()
	var/list/colorparam = list("green" = "#68ff4d", "red" = "#ff5959", "blue" = "#4de4ff", "purple" = "#de4dff")
	blade_color = pick(colorparam)
	brightness_color = colorparam[blade_color]

/obj/item/melee/energy/sword/dualsaber/green/New()
	blade_color = "green"
	brightness_color = "#68ff4d"

/obj/item/melee/energy/sword/dualsaber/red/New()
	blade_color = "red"
	brightness_color = "#ff5959"

/obj/item/melee/energy/sword/dualsaber/blue/New()
	blade_color = "blue"
	brightness_color = "#4de4ff"

/obj/item/melee/energy/sword/dualsaber/purple/New()
	blade_color = "purple"
	brightness_color = "#de4dff"

/obj/item/melee/energy/sword/dualsaber/activate(mob/living/user)
	..()
	icon_state = "dualsaber[blade_color]"

/*
 *Energy Blade
 */
//Can't be activated or deactivated, so no reason to be a subtype of energy
/obj/item/melee/energy/blade
	name = "energy blade"
	desc = "A concentrated beam of energy in the shape of a blade. Very stylish... and lethal."
	icon_state = "blade"
	active = TRUE
	force = 40 //Normal attacks deal very high damage - about the same as wielded fire axe
	armor_penetration = 100
	sharp = 1
	edge = 1
	check_armour = "laser"
	anchored = TRUE    // Never spawned outside of inventory, should be fine.
	throwforce = 1  //Throwing or dropping the item deletes it.
	throw_speed = 1
	throw_range = 1
	w_class = ITEM_SIZE_TINY //technically it's just energy or something, I dunno
	atom_flags = ATOM_FLAG_NO_BLOOD
	canremove = FALSE
	force_drop = TRUE
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	hitsound = 'sound/effects/fighting/energy1.ogg'
	var/mob/living/creator
	var/datum/effect/effect/system/spark_spread/spark_system

/obj/item/melee/energy/blade/New()
	..()
	spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/melee/energy/blade/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/melee/energy/blade/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/melee/energy/blade/get_storage_cost()
	return ITEM_SIZE_NO_CONTAINER

/obj/item/melee/energy/blade/attack_self(mob/user as mob)
	user.drop_from_inventory(src)
	QDEL_IN(src, 0)

/obj/item/melee/energy/blade/dropped()
	QDEL_IN(src, 0)

/obj/item/melee/energy/blade/Process()
	if(!creator || loc != creator || (creator.l_hand != src && creator.r_hand != src))
		// Tidy up a bit.
		if(isliving(loc))
			var/mob/living/carbon/human/host = loc
			if(istype(host))
				for(var/obj/item/organ/external/organ in host.organs)
					for(var/obj/item/O in organ.implants)
						if(O == src)
							organ.implants -= src
			host.pinned -= src
			host.embedded -= src
			host.drop_from_inventory(src)
		QDEL_IN(src, 0)

/obj/item/melee/energy/sword/robot
	icon_state = "sword0"
	blade_color = "red"
	brightness_color = "#ff5959"
	needs_blocking = FALSE
