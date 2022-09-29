//NASA Voidsuit
/obj/item/clothing/head/helmet/space/void
	name = "void helmet"
	desc = "A high-tech dark red space suit helmet. Used for AI satellite maintenance."
	icon_state = "void"

	heat_protection = HEAD
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100)
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.4

	//Species-specific stuff.
	species_restricted = list(SPECIES_HUMAN, SPECIES_IPC)

	sprite_sheets_obj = list(
		SPECIES_UNATHI = 'icons/obj/clothing/species/unathi/hats.dmi',
		SPECIES_TAJARA = 'icons/obj/clothing/species/tajaran/hats.dmi',
		SPECIES_SKRELL = 'icons/obj/clothing/species/skrell/hats.dmi'
	)

	light_overlay = "helmet_light"
	rad_resist = list(
		RADIATION_ALPHA_PARTICLE = 59.4 MEGA ELECTRONVOLT,
		RADIATION_BETA_PARTICLE = 13.2 MEGA ELECTRONVOLT,
		RADIATION_HAWKING = 1 ELECTRONVOLT
	)

/obj/item/clothing/suit/space/void
	name = "voidsuit"
	icon_state = "void"
	//item_state = "syndie_hardsuit"
	w_class = ITEM_SIZE_HUGE//bulky item
	desc = "A high-tech dark red space suit. Used for AI satellite maintenance."
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.4

	species_restricted = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_IPC)

	sprite_sheets_obj = list(
		SPECIES_UNATHI = 'icons/obj/clothing/species/unathi/suits.dmi',
		SPECIES_TAJARA = 'icons/obj/clothing/species/tajaran/suits.dmi',
		SPECIES_SKRELL = 'icons/obj/clothing/species/skrell/suits.dmi'
	)

	rad_resist = list(
		RADIATION_ALPHA_PARTICLE = 59.4 MEGA ELECTRONVOLT,
		RADIATION_BETA_PARTICLE = 13.2 MEGA ELECTRONVOLT,
		RADIATION_HAWKING = 1 ELECTRONVOLT
	)

	//Breach thresholds, should ideally be inherited by most (if not all) voidsuits.
	//With 0.2 resiliance, will reach 10 breach damage after 3 laser carbine blasts or 8 smg hits.
	breach_threshold = 18
	can_breach = 1

	//Inbuilt devices.
	var/obj/item/clothing/shoes/magboots/boots = null // Deployable boots, if any.
	var/obj/item/clothing/head/helmet/helmet = null   // Deployable helmet, if any.
	var/obj/item/tank/tank = null              // Deployable tank, if any.

	action_button_name = "Toggle Helmet"

#define VOIDSUIT_INIT_EQUIPMENT(equipment_var, expected_path) \
if(ispath(##equipment_var, ##expected_path )){\
	##equipment_var = new equipment_var (src);\
}\
else if(##equipment_var) {\
	CRASH("[log_info_line(src)] has an invalid [#equipment_var] type: [log_info_line(##equipment_var)]");\
}

/obj/item/clothing/suit/space/void/Initialize()
	. = ..()
	VOIDSUIT_INIT_EQUIPMENT(boots,  /obj/item/clothing/shoes/magboots)
	VOIDSUIT_INIT_EQUIPMENT(helmet, /obj/item/clothing/head/helmet)
	VOIDSUIT_INIT_EQUIPMENT(tank,   /obj/item/tank)

#undef VOIDSUIT_INIT_EQUIPMENT

/obj/item/clothing/suit/space/void/Destroy()
	. = ..()
	QDEL_NULL(boots)
	QDEL_NULL(helmet)
	QDEL_NULL(tank)

/obj/item/clothing/suit/space/void/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 1

/obj/item/clothing/suit/space/void/_examine_text(user)
	. = ..()
	var/list/part_list = new
	for(var/obj/item/I in list(helmet,boots,tank))
		part_list += "\a [I]"
	. += "\n\The [src] has [english_list(part_list)] installed."
	if(tank && in_range(src,user))
		. += "\n<span class='notice'>The wrist-mounted pressure gauge reads [max(round(tank.air_contents.return_pressure()),0)] kPa remaining in \the [tank].</span>"

/obj/item/clothing/suit/space/void/refit_for_species(target_species)
	..()
	if(istype(helmet))
		helmet.refit_for_species(target_species)
	if(istype(boots))
		boots.refit_for_species(target_species)

/obj/item/clothing/suit/space/void/equipped(mob/M)
	..()

	var/mob/living/carbon/human/H = M

	if(!istype(H)) return

	if(H.wear_suit != src)
		return

	if(boots)
		if (H.equip_to_slot_if_possible(boots, slot_shoes))
			boots.canremove = 0

	if(helmet)
		if(H.head)
			to_chat(M, "You are unable to deploy your suit's helmet as \the [H.head] is in the way.")
		else if (H.equip_to_slot_if_possible(helmet, slot_head))
			to_chat(M, "Your suit's helmet deploys with a hiss.")
			helmet.canremove = 0

	if(tank)
		if(H.s_store) //In case someone finds a way.
			to_chat(M, "Alarmingly, the valve on your suit's installed tank fails to engage.")
		else if (H.equip_to_slot_if_possible(tank, slot_s_store))
			to_chat(M, "The valve on your suit's installed tank safely engages.")
			tank.canremove = 0


/obj/item/clothing/suit/space/void/dropped()
	..()

	var/mob/living/carbon/human/H

	if(helmet)
		helmet.canremove = 1
		H = helmet.loc
		if(istype(H))
			if(helmet && H.head == helmet)
				H.drop(helmet, src, TRUE)

	if(boots)
		boots.canremove = 1
		H = boots.loc
		if(istype(H))
			if(boots && H.shoes == boots)
				H.drop(boots, src, TRUE)

	if(tank)
		tank.canremove = 1
		if(istype(H))
			H.drop(boots, src, TRUE)
		tank.forceMove(src)

/obj/item/clothing/suit/space/void/verb/toggle_helmet()

	set name = "Toggle Helmet"
	set category = "Object"
	set src in usr

	if(!istype(src.loc,/mob/living)) return

	if(!helmet)
		to_chat(usr, "There is no helmet installed.")
		return

	var/mob/living/carbon/human/H = usr

	if(!istype(H)) return
	if(H.incapacitated()) return
	if(H.wear_suit != src) return

	if(H.head == helmet)
		to_chat(H, "<span class='notice'>You retract your suit helmet.</span>")
		helmet.canremove = 1
		H.drop_from_inventory(helmet)
		helmet.forceMove(src)
	else
		if(H.head)
			to_chat(H, "<span class='danger'>You cannot deploy your helmet while wearing \the [H.head].</span>")
			return
		if(H.equip_to_slot_if_possible(helmet, slot_head))
			helmet.pickup(H)
			helmet.canremove = 0
			to_chat(H, "<span class='info'>You deploy your suit helmet, sealing you off from the world.</span>")
	helmet.update_light(H)

/obj/item/clothing/suit/space/void/verb/eject_tank()

	set name = "Eject Voidsuit Tank"
	set category = "Object"
	set src in usr

	if(!istype(src.loc,/mob/living)) return

	if(!tank)
		to_chat(usr, "There is no tank inserted.")
		return

	var/mob/living/carbon/human/H = usr

	if(!istype(H)) return
	if(H.incapacitated()) return
	if(H.wear_suit != src) return

	to_chat(H, "<span class='info'>You press the emergency release, ejecting \the [tank] from your suit.</span>")
	tank.canremove = 1
	H.drop_from_inventory(tank)
	src.tank = null

/obj/item/clothing/suit/space/void/attackby(obj/item/W as obj, mob/user as mob)

	if(!istype(user,/mob/living)) return

	if(istype(W,/obj/item/clothing/accessory) || istype(W, /obj/item/hand_labeler))
		return ..()

	if(user.get_inventory_slot(src) == slot_wear_suit)
		to_chat(user, "<span class='warning'>You cannot modify \the [src] while it is being worn.</span>")
		return

	if(istype(W,/obj/item/screwdriver))
		if(helmet || boots || tank)
			var/choice = input("What component would you like to remove?") as null|anything in list(helmet,boots,tank)
			if(!choice) return

			if(choice == tank)	//No, a switch doesn't work here. Sorry. ~Techhead
				to_chat(user, "You pop \the [tank] out of \the [src]'s storage compartment.")
				tank.forceMove(get_turf(src))
				src.tank = null
			else if(choice == helmet)
				to_chat(user, "You detatch \the [helmet] from \the [src]'s helmet mount.")
				helmet.forceMove(get_turf(src))
				src.helmet = null
			else if(choice == boots)
				to_chat(user, "You detatch \the [boots] from \the [src]'s boot mounts.")
				boots.forceMove(get_turf(src))
				src.boots = null
		else
			to_chat(user, "\The [src] does not have anything installed.")
		return

	else if(istype(W, /obj/item/clothing/head/helmet/space))
		if(helmet)
			to_chat(user, "\The [src] already has a helmet installed.")
		else if(user.drop(W, src))
			to_chat(user, "You attach \the [W] to \the [src]'s helmet mount.")
			helmet = W
		return

	else if(istype(W, /obj/item/clothing/shoes/magboots))
		if(boots)
			to_chat(user, "\The [src] already has magboots installed.")
		else if(user.drop(W, src))
			to_chat(user, "You attach \the [W] to \the [src]'s boot mounts.")
			boots = W
		return

	else if(istype(W, /obj/item/tank))
		if(tank)
			to_chat(user, "\The [src] already has an airtank installed.")
		else if(istype(W, /obj/item/tank/plasma))
			to_chat(user, "\The [W] cannot be inserted into \the [src]'s storage compartment.")
		else if(user.drop(W, src))
			to_chat(user, "You insert \the [W] into \the [src]'s storage compartment.")
			tank = W
		return

	..()

/obj/item/clothing/suit/space/void/attack_self() //sole purpose of existence is to toggle the helmet
	toggle_helmet()
