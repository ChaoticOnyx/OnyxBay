/*
// Bluespace Technician is a godmode avatar designed for debugging and admin actions
// Their primary benefit is the ability to spawn in wherever you are, making it quick to get a human for your needs
// They also have incorporeal flying movement if they choose, which is often the fastest way to get somewhere specific
// They are mostly invincible, although godmode is a bit imperfect.
// Most of their superhuman qualities can be toggled off if you need a normal human for testing biological functions
*/

/client/proc/bluespace_tech()
	set category = "Debug"
	set name = "Spawn Bluespace Tech"
	set desc = "Spawns a Bluespace Tech to debug stuff"

	if(!check_rights(R_ADMIN|R_DEBUG))
		return

	if(!isghost(mob))
		to_chat(src, SPAN_WARNING("You must to be a ghost to use this!"), confidential = TRUE)
		return

	//I couldn't get the normal way to work so this works.
	//This whole section looks like a hack, I don't like it.
	var/T = get_turf(mob)
	var/mob/living/carbon/human/bluespace_tech/bst = new(T)

	bst.dir = mob.dir
	bst.ckey = ckey
	bst.name = "Bluespace Technician"
	bst.real_name = "Bluespace Technician"
	bst.voice_name = "Bluespace Technician"
	bst.h_style = "Crewcut"

	//Items
	var/obj/item/clothing/under/U = new /obj/item/clothing/under/assistantformal/bluespace_tech(bst)
	bst.equip_to_slot_or_del(U, slot_w_uniform)
	bst.equip_to_slot_or_del(new /obj/item/device/radio/headset/ert/bluespace_tech(bst), slot_l_ear)
	bst.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/holding/bluespace_tech(bst), slot_back)
	bst.equip_to_slot_or_del(new /obj/item/clothing/shoes/black/bluespace_tech(bst), slot_shoes)
	bst.equip_to_slot_or_del(new /obj/item/clothing/head/beret(bst), slot_head)
	bst.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/bluespace_tech(bst), slot_glasses)
	bst.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full/bluespace_tech(bst), slot_belt)
	bst.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/white/bluespace_tech(bst), slot_gloves)
	bst.equip_to_slot_or_del(new /obj/item/weapon/storage/box/ids(bst.back), slot_in_backpack)
	bst.equip_to_slot_or_del(new /obj/item/device/t_scanner(bst.back), slot_in_backpack)

	var/obj/item/weapon/storage/box/pills = new /obj/item/weapon/storage/box(null, TRUE)
	pills.name = "adminordrazine"
	for(var/i = 1, i < 12, i++)
		new /obj/item/weapon/reagent_containers/pill/adminordrazine(pills)
	bst.equip_to_slot_or_del(pills, slot_in_backpack)

	//Sort out ID
	var/obj/item/weapon/card/id/bluespace_tech/id = new (bst)
	id.registered_name = bst.real_name
	id.assignment = "Bluespace Technician"
	id.name = "[id.assignment]"
	bst.equip_to_slot_or_del(id, slot_wear_id)
	bst.update_inv_wear_id()
	bst.regenerate_icons()
	bst.reload_fullscreen()

	//Add the rest of the languages
	//Because universal speak doesn't work right.
	bst.add_language(LANGUAGE_GALCOM)
	bst.add_language(LANGUAGE_EAL)
	bst.add_language(LANGUAGE_SOL_COMMON)
	bst.add_language(LANGUAGE_UNATHI)
	bst.add_language(LANGUAGE_SIIK_MAAS)
	bst.add_language(LANGUAGE_SKRELLIAN)
	bst.add_language(LANGUAGE_LUNAR)
	bst.add_language(LANGUAGE_GUTTER)
	bst.add_language(LANGUAGE_SIGN)
	bst.add_language(LANGUAGE_INDEPENDENT)
	bst.add_language(LANGUAGE_SPACER)
	bst.add_language(LANGUAGE_ROBOT)

	addtimer(CALLBACK(src, .proc/bluespace_tech_post_spawn, bst), 10)
	log_debug("Bluespace Tech Spawned: X:[bst.x] Y:[bst.y] Z:[bst.z] User:[src]")

/client/proc/bluespace_tech_post_spawn(mob/living/carbon/human/bluespace_tech/bst)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()

/mob/living/carbon/human/bluespace_tech
	status_flags = NO_ANTAG
	universal_understand = 1
	var/fall_override = TRUE
	movement_handlers = list(
		/datum/movement_handler/mob/relayed_movement,
		/datum/movement_handler/mob/death,
		/datum/movement_handler/mob/conscious,
		/datum/movement_handler/mob/eye,
		/datum/movement_handler/move_relay,
		/datum/movement_handler/mob/buckle_relay,
		/datum/movement_handler/mob/delay,
		/datum/movement_handler/mob/stop_effect,
		/datum/movement_handler/mob/physically_capable,
		/datum/movement_handler/mob/physically_restrained,
		/datum/movement_handler/mob/space,
		/datum/movement_handler/mob/multiz,
		/datum/movement_handler/mob/multiz_connected,
		/datum/movement_handler/mob/movement
	)

/mob/living/carbon/human/bluespace_tech/can_inject(mob/user, target_zone)
	to_chat(user, SPAN_DANGER("The [src] disarms you before you can inject them."), confidential = TRUE)
	user.drop_item()
	return 0

/mob/living/carbon/human/bluespace_tech/binarycheck()
	return 1

/mob/living/carbon/human/bluespace_tech/proc/suicide()
	if(QDELETED(src))
		return
	custom_emote(VISIBLE_MESSAGE, "presses a button on their suit, followed by a polite bow.")
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()

	QDEL_IN(src, 10)

	if(key)
		var/mob/observer/ghost/ghost = new(src)	//Transfer safety to observer spawning proc.
		ghost.key = key
		ghost.dir = dir
		ghost.mind.name = "[ghost.key] BSTech"
		ghost.name = "[ghost.key] BSTech"
		ghost.real_name = "[ghost.key] BSTech"
		ghost.voice_name = "[ghost.key] BSTech"
		ghost.admin_ghosted = 1
		ghost.can_reenter_corpse = 1
		ghost.reload_fullscreen()

/mob/living/carbon/human/bluespace_tech/verb/antigrav()
	set name = "Toggle Gravity"
	set desc = "Toggles on/off falling for you."
	set category = "BST"

	if (fall_override)
		fall_override = FALSE
		to_chat(usr, SPAN_NOTICE("You will now fall normally."), confidential = TRUE)
	else
		fall_override = TRUE
		to_chat(usr, SPAN_NOTICE("You will no longer fall."), confidential = TRUE)

/mob/living/carbon/human/bluespace_tech/verb/bstwalk()
	set name = "Ruin Everything"
	set desc = "Uses bluespace technology to phase through solid matter and move quickly."
	set category = "BST"
	set popup_menu = 0

	if(usr.HasMovementHandler(/datum/movement_handler/mob/incorporeal))
		usr.RemoveMovementHandler(/datum/movement_handler/mob/incorporeal)
		to_chat(usr, SPAN_NOTICE("You will no-longer phase through solid matter."), confidential = TRUE)
	else
		usr.ReplaceMovementHandler(/datum/movement_handler/mob/incorporeal)
		to_chat(usr, SPAN_NOTICE("You will now phase through solid matter."), confidential = TRUE)

/mob/living/carbon/human/bluespace_tech/verb/bstrecover()
	set name = "Rejuv"
	set desc = "Use the bluespace within you to restore your health"
	set category = "BST"
	set popup_menu = 0

	revive()

/mob/living/carbon/human/bluespace_tech/verb/bstawake()
	set name = "Wake up"
	set desc = "This is a quick fix to the relogging sleep bug"
	set category = "BST"
	set popup_menu = 0

	sleeping = 0

/mob/living/carbon/human/bluespace_tech/verb/bstquit()
	set name = "Teleport out"
	set desc = "Activate bluespace to leave and return to your original mob (if you have one)."
	set category = "BST"

	suicide(usr)

/mob/living/carbon/human/bluespace_tech/verb/tgm()
	set name = "Toggle Godmode"
	set desc = "Enable or disable god mode. For testing things that require you to be vulnerable."
	set category = "BST"

	status_flags ^= GODMODE
	to_chat(usr, SPAN_NOTICE("God mode is now [status_flags & GODMODE ? "enabled" : "disabled"]."), confidential = TRUE)

//Equipment. All should have canremove set to 0
//All items with a /bluespace_tech need the attack_hand() proc overrided to stop people getting overpowered items.

//Bag o Holding
/obj/item/weapon/storage/backpack/holding/bluespace_tech
	canremove = 0
	storage_slots = 56
	max_w_class = 400

/obj/item/weapon/storage/backpack/holding/bluespace_tech/attack_hand(mob/user)
	if(!user)
		return
	if(!istype(user, /mob/living/carbon/human/bluespace_tech))
		to_chat(user, SPAN_WARNING("Your hand seems to go right through the [src]. It's like it doesn't exist."), confidential = TRUE)
		return
	return ..()

//Headset
/obj/item/device/radio/headset/ert/bluespace_tech
	name = "bluespace technician's headset"
	desc = "A Bluespace Technician's headset. The letters 'BST' are stamped on the side."
	translate_binary = 1
	translate_hive = 1
	canremove = 0
	keyslot1 = new /obj/item/device/encryptionkey/binary

/obj/item/device/radio/headset/ert/bluespace_tech/attack_hand(mob/user)
	if(!user)
		return
	if(!istype(user, /mob/living/carbon/human/bluespace_tech))
		to_chat(user, SPAN_WARNING("Your hand seems to go right through the [src]. It's like it doesn't exist."), confidential = TRUE)
		return
	return ..()

// overload this so we can force translate flags without the required keys
/obj/item/device/radio/headset/ert/bluespace_tech/recalculateChannels(setDescription = 0)
	. = ..(setDescription)
	translate_binary = 1
	translate_hive = 1

//Clothes
//Nobody ever wears the formal assistant uniform so this is fine
/obj/item/clothing/under/assistantformal/bluespace_tech
	name = "bluespace technician's uniform"
	desc = "A Bluespace Technician's Uniform. There is a logo on the sleeve that reads 'BST'."
	has_sensor = 0
	sensor_mode = 0
	canremove = 0
	siemens_coefficient = 0
	cold_protection = FULL_BODY
	heat_protection = FULL_BODY

/obj/item/clothing/under/assistantformal/bluespace_tech/attack_hand(mob/user)
	if(!user)
		return
	if(!istype(user, /mob/living/carbon/human/bluespace_tech))
		to_chat(user, SPAN_WARNING("Your hand seems to go right through the [src]. It's like it doesn't exist."), confidential = TRUE)
		return
	return ..()

//Gloves
/obj/item/clothing/gloves/color/white/bluespace_tech
	name = "bluespace technician's gloves"
	desc = "A pair of modified gloves. The letters 'BST' are stamped on the side."
	siemens_coefficient = 0
	permeability_coefficient = 0
	canremove = 0

/obj/item/clothing/gloves/color/white/bluespace_tech/attack_hand(mob/user)
	if(!user)
		return
	if(!istype(user, /mob/living/carbon/human/bluespace_tech))
		to_chat(user, SPAN_WARNING("Your hand seems to go right through the [src]. It's like it doesn't exist."), confidential = TRUE)
		return
	return ..()

//Sunglasses
/obj/item/clothing/glasses/sunglasses/bluespace_tech
	name = "bluespace technician's glasses"
	desc = "A pair of modified sunglasses. The word 'BST' is stamped on the side."
	vision_flags = (SEE_TURFS|SEE_OBJS|SEE_MOBS)
	see_invisible = SEE_INVISIBLE_NOLIGHTING
	flash_protection = FLASH_PROTECTION_MAJOR
	canremove = 0

/obj/item/clothing/glasses/sunglasses/bluespace_tech/verb/toggle_xray(mode in list("X-Ray without Lighting", "X-Ray with Lighting", "Normal"))
	set name = "Change Vision Mode"
	set desc = "Changes your glasses' vision mode."
	set category = "BST"
	set src in usr

	switch (mode)
		if ("X-Ray without Lighting")
			vision_flags = (SEE_TURFS|SEE_OBJS|SEE_MOBS)
			see_invisible = SEE_INVISIBLE_NOLIGHTING
		if ("X-Ray with Lighting")
			vision_flags = (SEE_TURFS|SEE_OBJS|SEE_MOBS)
			see_invisible = -1
		if ("Normal")
			vision_flags = 0
			see_invisible = -1

	to_chat(usr, SPAN_NOTICE("\The [src]'s vision mode is now <b>[mode]</b>."), confidential = TRUE)

/obj/item/clothing/glasses/sunglasses/bluespace_tech/attack_hand(mob/user)
	if(!user)
		return
	if(!istype(user, /mob/living/carbon/human/bluespace_tech))
		to_chat(user, SPAN_WARNING("Your hand seems to go right through the [src]. It's like it doesn't exist."), confidential = TRUE)
		return
	return ..()

//Shoes
/obj/item/clothing/shoes/black/bluespace_tech
	name = "bluespace technician's shoes"
	desc = "A pair of black shoes with extra grip. The letters 'BST' are stamped on the side."
	icon_state = "black"
	item_flags = ITEM_FLAG_NOSLIP
	canremove = 0

/obj/item/clothing/shoes/black/bluespace_tech/attack_hand(mob/user)
	if(!user)
		return
	if(!istype(user, /mob/living/carbon/human/bluespace_tech))
		to_chat(user, SPAN_WARNING("Your hand seems to go right through the [src]. It's like it doesn't exist."), confidential = TRUE)
		return
	return ..()

//ID
/obj/item/weapon/card/id/bluespace_tech
	icon_state = "centcom"
	desc = "An ID straight from Central Command. This one looks highly classified."

/obj/item/weapon/card/id/bluespace_tech/Initialize()
	. = ..()
	access = get_all_accesses() + get_all_centcom_access() + get_all_syndicate_access()

/obj/item/weapon/card/id/bluespace_tech/attack_hand(mob/user)
	if(!user)
		return
	if(!istype(user, /mob/living/carbon/human/bluespace_tech))
		to_chat(user, SPAN_WARNING("Your hand seems to go right through the [src]. It's like it doesn't exist."), confidential = TRUE)
		return
	return ..()

/obj/item/weapon/storage/belt/utility/full/bluespace_tech
	canremove = 0

/obj/item/weapon/storage/belt/utility/full/bluespace_tech/New()
	..() //Full set of tools
	new /obj/item/device/multitool(src)

/mob/living/carbon/human/bluespace_tech/restrained()
	return 0

/mob/living/carbon/human/bluespace_tech/can_fall()
	return fall_override ? FALSE : ..()
