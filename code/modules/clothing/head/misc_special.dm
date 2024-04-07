/*
 * Contents:
 *		Welding mask
 *		Cakehat
 *		Ushanka
 *		Pumpkin head
 *		Kitty ears
 *		Tinfoil hat
 */

/*
 * Welding mask
 */
/obj/item/clothing/head/welding
	name = "welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye."
	icon_state = "welding"
	item_state_slots = list(
		slot_l_hand_str = "welding",
		slot_r_hand_str = "welding",
		)
	matter = list(MATERIAL_STEEL = 3000, MATERIAL_GLASS = 1000)
	var/up = 0
	armor = list(melee = 70, bullet = 90, laser = 70, energy = 25, bomb = 35, bio = 0)
	coverage = 1.0
	flags_inv = (HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
	body_parts_covered = HEAD|FACE|EYES
	action_button_name = "Flip Welding Mask"
	siemens_coefficient = 0.9
	w_class = ITEM_SIZE_NORMAL
	var/base_state
	flash_protection = FLASH_PROTECTION_MAJOR
	tint = TINT_HEAVY
	var/obj/item/welding_cover/cover = null

	pickup_sound = SFX_PICKUP_HELMET
	drop_sound = SFX_DROP_HELMET

/obj/item/clothing/head/welding/examine(mob/user, infix)
	. = ..()

	if(cover)
		. += " [cover.cover_desc]"

/obj/item/clothing/head/welding/New()
	base_state = icon_state
	if(ispath(cover))
		cover = new cover(src)
		icon_state = "[cover.icon_state]welding"
		item_state = "[cover.icon_state]welding"
	..()

/obj/item/clothing/head/welding/Destroy()
	QDEL_NULL(cover)
	return ..()

/obj/item/clothing/head/welding/attack_self()
	toggle()

/obj/item/clothing/head/welding/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/welding_cover))
		if(!cover && user.drop(W))
			attach_cover(user, W)
		else
			to_chat(user, SPAN("notice", "[src] already has a cover attached."))
	else if(isScrewdriver(W))
		if(cover)
			detach_cover(user)
	else
		..()

/obj/item/clothing/head/welding/verb/toggle()
	set category = "Object"
	set name = "Adjust welding mask"
	set src in usr

	if(CanPhysicallyInteract(usr))
		if(src.up)
			src.up = !src.up
			body_parts_covered |= (EYES|FACE)
			flags_inv |= (HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
			flash_protection = initial(flash_protection)
			tint = initial(tint)
			icon_state = "[cover ? "[cover.icon_state]welding" : base_state]"
			item_state = "[cover ? "[cover.icon_state]welding" : base_state]"
			to_chat(usr, "You flip the [src] down to protect your eyes.")
			coverage = 1.0
		else
			src.up = !src.up
			body_parts_covered &= ~(EYES|FACE)
			flash_protection = FLASH_PROTECTION_NONE
			tint = TINT_NONE
			flags_inv &= ~(HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
			icon_state = "[cover ? "[cover.icon_state]welding" : base_state]up"
			item_state = "[cover ? "[cover.icon_state]welding" : base_state]up"
			to_chat(usr, "You push the [src] up out of your face.")
			coverage = 0.6
		update_clothing_icon()	//so our mob-overlays
		update_vision()
		usr.update_action_buttons()

/obj/item/clothing/head/welding/proc/attach_cover(mob/user, obj/item/welding_cover/W)
	to_chat(user, SPAN("notice", "You clip \the [W] onto \the [src]."))
	W.forceMove(src)
	cover = W
	icon_state = "[cover.icon_state]welding[src.up ? "up" : ""]"
	item_state = "[cover.icon_state]welding[src.up ? "up" : ""]"
	update_clothing_icon()
	user.update_action_buttons()

/obj/item/clothing/head/welding/proc/detach_cover(mob/user)
	to_chat(user, SPAN("notice", "You detach \the [cover] from \the [src]."))
	cover.dropInto(get_turf(src))
	cover = null
	icon_state = "[base_state][src.up ? "up" : ""]"
	item_state = "[base_state][src.up ? "up" : ""]"
	update_clothing_icon()
	user.update_action_buttons()


/obj/item/clothing/head/welding/demon
	cover = /obj/item/welding_cover/demon

/obj/item/clothing/head/welding/knight
	cover = /obj/item/welding_cover/knight

/obj/item/clothing/head/welding/fancy
	cover = /obj/item/welding_cover/fancy

/obj/item/clothing/head/welding/engie
	cover = /obj/item/welding_cover/engie

/obj/item/clothing/head/welding/carp
	cover = /obj/item/welding_cover/carp

/obj/item/clothing/head/welding/hockey
	cover = /obj/item/welding_cover/hockey

/obj/item/clothing/head/welding/blue
	cover = /obj/item/welding_cover/blue

/obj/item/clothing/head/welding/flame
	cover = /obj/item/welding_cover/flame

/obj/item/clothing/head/welding/white
	cover = /obj/item/welding_cover/white

/*
 * Cakehat
 */
/obj/item/clothing/head/cakehat
	name = "cake-hat"
	desc = "It's tasty looking!"
	icon_state = "cake0"
	item_state = "cake0"
	var/onfire = 0
	body_parts_covered = HEAD
	armor = list(melee = 5, bullet = 5, laser = 5, energy = 40, bomb = 0, bio = 0)
	siemens_coefficient = 0.2 // A fancy man's taser absorber

/obj/item/clothing/head/cakehat/think()
	if(!onfire)
		return

	var/turf/location = src.loc
	if(istype(location, /mob/))
		var/mob/living/carbon/human/M = location
		if(M.l_hand == src || M.r_hand == src || M.head == src)
			location = M.loc

	if (istype(location, /turf))
		location.hotspot_expose(700, 1)

	set_next_think(world.time + 1 SECOND)

/obj/item/clothing/head/cakehat/attack_self(mob/user as mob)
	src.onfire = !( src.onfire )
	if (src.onfire)
		src.force = 3
		src.damtype = "fire"
		src.icon_state = "cake1"
		src.item_state = "cake1"
		set_next_think(world.time)
	else
		src.force = null
		src.damtype = "brute"
		src.icon_state = "cake0"
		src.item_state = "cake0"
	return

/obj/item/clothing/head/cakehat/get_temperature_as_from_ignitor()
	if(onfire)
		return 1000
	return 0

/*
 * Ushanka
 */
/obj/item/clothing/head/ushanka
	name = "ushanka"
	desc = "Perfect for winter in Siberia, da?"
	icon_state = "ushankadown"
	var/icon_state_up = "ushankaup"
	flags_inv = HIDEEARS|BLOCKHEADHAIR
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	armor = list(melee = 30, bullet = 5, laser = 5, energy = 0, bomb = 0, bio = 0)

/obj/item/clothing/head/ushanka/attack_self(mob/user as mob)
	if(icon_state == initial(icon_state))
		icon_state = icon_state_up
		to_chat(user, "You raise the ear flaps on the ushanka.")
	else
		icon_state = initial(icon_state)
		to_chat(user, "You lower the ear flaps on the ushanka.")

/obj/item/clothing/head/ushanka/tcc
	name = "TCC ushanka"
	desc = "Perfect for keeping ears warm during your courtmartial."
	icon_state = "tccushankadown"
	icon_state_up = "tccushankaup"

/*
 * Pumpkin head
 */
/obj/item/clothing/head/pumpkinhead
	name = "carved pumpkin"
	desc = "A jack o' lantern! Believed to ward off evil spirits."
	icon_state = "hardhat0_pumpkin"//Could stand to be renamed
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|BLOCKHAIR
	body_parts_covered = HEAD|FACE|EYES
	brightness_on = 2
	light_overlay = "helmet_light"
	w_class = ITEM_SIZE_NORMAL
	armor = list(melee = 35, bullet = 15, laser = 10, energy = 0, bomb = 0, bio = 0)

/*
 * Kitty ears
 */
/obj/item/clothing/head/kitty
	name = "kitty ears"
	desc = "A pair of kitty ears. Meow!"
	icon_state = "kitty"
	slot_flags = SLOT_HEAD | SLOT_EARS
	body_parts_covered = NO_BODYPARTS
	armor = list(melee = -30, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0) // Take an oxygen tank to the head and die. Please.
	siemens_coefficient = 1.5
	item_icons = list()

/obj/item/clothing/head/kitty/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if((slot == slot_head || slot == slot_l_ear || slot == slot_r_ear) && istype(user))
		var/hairgb = rgb(user.r_hair, user.g_hair, user.b_hair)
		var/icon/ears = icon('icons/inv_slots/hats/mob.dmi', "kitty")
		ears.Blend(icon('icons/inv_slots/hats/mob.dmi', "kitty_tail"), ICON_OVERLAY)
		ears.Blend(hairgb, ICON_ADD)
		ears.Blend(icon('icons/inv_slots/hats/mob.dmi', "kittyinner"), ICON_OVERLAY)
		icon_override = ears
	else if(icon_override)
		icon_override = null

/obj/item/clothing/head/richard
	name = "chicken mask"
	desc = "You can hear the distant sounds of rhythmic electronica."
	icon_state = "richard"
	body_parts_covered = HEAD|FACE
	flags_inv = BLOCKHAIR
	armor = list(melee = 5, bullet = 5, laser = 5,energy = 0, bomb = 0, bio = 0)
/*
 * Tinfoil hat
 */
/obj/item/clothing/head/tinfoil
	name = "Tinfoil hat"
	desc = "Big brother is watching you!"
	icon_state = "foilhat"
	body_parts_covered = NO_BODYPARTS
	armor = list(melee = 0, bullet = 0, laser = 5, energy = 5, bomb = 0, bio = 0)
	rad_resist_type = /datum/rad_resist/tinfoil

/datum/rad_resist/tinfoil
	alpha_particle_resist = 30 MEGA ELECTRONVOLT
	beta_particle_resist = 6 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

//ilyadobr's custom item

/obj/item/clothing/head/fox
	name = "fox ears"
	desc = "A pair of fox ears. What does the fox say?"
	icon_state = "fox"
	slot_flags = SLOT_HEAD | SLOT_EARS
	body_parts_covered = NO_BODYPARTS
	siemens_coefficient = 1.5
	item_icons = list()
	var/hairgb = null

/obj/item/clothing/head/fox/Initialize()
	. = ..()
	if(color)
		hairgb = color
		color = null

/obj/item/clothing/head/fox/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(color)
		hairgb = color
		color = null
	var/tail = "fox_tail"
	if((slot == slot_head || slot == slot_l_ear || slot == slot_r_ear) && istype(user))
		if(!hairgb)
			hairgb = rgb(user.r_hair, user.g_hair, user.b_hair)
		var/icon/ears = icon('icons/inv_slots/hats/mob.dmi', "fox")
		switch(user.body_build.name)
			if("Slim")
				tail = "fox_tail_slim"
			if("Slim Alt")
				tail = "fox_tail_slim_alt"
			if("Fat")
				tail = "fox_tail_fat"
			else
				tail = "fox_tail"
		ears.Blend(icon('icons/inv_slots/hats/mob.dmi', tail), ICON_OVERLAY)
		ears.Blend(hairgb, ICON_ADD)
		ears.Blend(icon('icons/inv_slots/hats/mob.dmi', "[tail]_overlay"), ICON_OVERLAY)
		icon_override = ears
	else if(icon_override)
		icon_override = null
