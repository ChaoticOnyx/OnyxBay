/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	item_state_slots = list(
		slot_l_hand_str = "glasses",
		slot_r_hand_str = "glasses"
		)
	var/prescription = FALSE
	var/toggleable = FALSE
	var/off_state = "degoggles"
	var/active = FALSE
	var/activation_sound = 'sound/items/goggles_charge.ogg'
	var/deactivation_sound = 'sound/items/goggles_switch.ogg'
	var/atom/movable/screen/overlay = null
	var/electric = FALSE //if the glasses should be disrupted by EMP
	var/hud_type
	var/one_eyed = FALSE

/obj/item/clothing/glasses/needs_vision_update()
	return ..() || overlay || vision_flags || see_invisible || darkness_view

/obj/item/clothing/glasses/emp_act(severity)
	if(electric)
		if(istype(src.loc, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = src.loc
			if(M.glasses == src)
				if(!one_eyed)
					to_chat(M, SPAN("danger", "Your [name] malfunction[gender != PLURAL ? "s":""], blinding you!"))
					M.eye_blind = one_eyed ? 1 : 2
				else
					to_chat(M, SPAN("danger", "Your [name] malfunction[gender != PLURAL ? "s":""], briefly blinding you!"))
				M.eye_blurry = one_eyed ? 2 : 4
				// Don't cure being nearsighted
				if(!(M.disabilities & NEARSIGHTED))
					M.disabilities |= NEARSIGHTED
					spawn(100)
						M.disabilities &= ~NEARSIGHTED
		if(toggleable)
			active = FALSE

/obj/item/clothing/glasses/attack_self(mob/user)
	if(toggleable && !user.incapacitated())
		if(active)
			active = FALSE
			icon_state = off_state
			user.update_inv_glasses()
			flash_protection = FLASH_PROTECTION_NONE
			tint = TINT_NONE
			to_chat(usr, "You deactivate the optical matrix on the [src].")
		else
			active = TRUE
			icon_state = initial(icon_state)
			user.update_inv_glasses()
			if(activation_sound)
				sound_to(usr, sound(activation_sound, volume = 50))

			flash_protection = initial(flash_protection)
			tint = initial(tint)
			to_chat(usr, "You activate the optical matrix on the [src].")
		user.update_action_buttons()

/obj/item/clothing/glasses/proc/process_hud(mob/M)
	return

/obj/item/clothing/glasses/eyepatch
	name = "eyepatch"
	desc = "Yarr."
	icon_state = "eyepatch"
	item_state_slots = list(
		slot_l_hand_str = "blindfold", // Looks kinda close ngl
		slot_r_hand_str = "blindfold"
		)
	body_parts_covered = NO_BODYPARTS
	one_eyed = TRUE
	var/flipped = FALSE // Indicates left or right eye; 0 = on the right

/obj/item/clothing/glasses/eyepatch/verb/flip_patch()
	set name = "Flip Patch"
	set category = "Object"
	set src in usr

	if (usr.stat || usr.restrained())
		return

	src.flipped = !src.flipped
	if(src.flipped)
		icon_state = "[icon_state]_r"
	else
		src.icon_state = initial(icon_state)
	to_chat (usr, "You change \the [src] to cover the [src.flipped ? "left" : "right"] eye.")
	update_clothing_icon()

/obj/item/clothing/glasses/monocle
	name = "monocle"
	desc = "Such a dapper eyepiece!"
	icon_state = "monocle"
	item_state_slots = list(
		slot_l_hand_str = "headset",
		slot_r_hand_str = "headset"
		)
	body_parts_covered = NO_BODYPARTS
	one_eyed = TRUE

/obj/item/clothing/glasses/regular
	name = "prescription glasses"
	desc = "Made by Nerd. Co."
	icon_state = "glasses"
	prescription = 7
	body_parts_covered = NO_BODYPARTS

/obj/item/clothing/glasses/regular/scanners
	name = "scanning goggles"
	desc = "A very oddly shaped pair of goggles with bits of wire poking out the sides. A soft humming sound emanates from it."
	icon_state = "uzenwa_sissra_1"
	light_protection = 7
	electric = TRUE

/obj/item/clothing/glasses/regular/hipster
	name = "prescription glasses"
	desc = "Made by Uncool. Co."
	icon_state = "hipster_glasses"

/obj/item/clothing/glasses/threedglasses
	name = "3D glasses"
	desc = "A long time ago, people used these glasses to makes images from screens threedimensional."
	icon_state = "3d"
	body_parts_covered = NO_BODYPARTS

/obj/item/clothing/glasses/gglasses
	name = "green glasses"
	desc = "Forest green glasses, like the kind you'd wear when hatching a nasty scheme."
	icon_state = "gglasses"
	body_parts_covered = NO_BODYPARTS

/obj/item/clothing/glasses/rglasses
	name = "red glasses"
	desc = "They make you look like a wannabe elite agent."
	icon_state = "bigredglasses"
	body_parts_covered = NO_BODYPARTS

/obj/item/clothing/glasses/sunglasses
	name = "sunglasses"
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
	icon_state = "sun"
	item_state_slots = list(
		slot_l_hand_str = "sunglasses",
		slot_r_hand_str = "sunglasses"
		)
	darkness_view = -1
	flash_protection = FLASH_PROTECTION_MODERATE
	var/darktinted = 1

/obj/item/clothing/glasses/sunglasses/Initialize()
	. = ..()
	if(darktinted)
		overlay = GLOB.global_hud.darktint

/obj/item/clothing/glasses/sunglasses/redglasses
	name = "Crimson glasses"
	desc = "They make you look like an elite agent."
	icon_state = "bigredglasses"

/obj/item/clothing/glasses/sunglasses/blindfold
	name = "blindfold"
	desc = "Covers the eyes, preventing sight."
	icon_state = "blindfold"
	item_state_slots = list(
		slot_l_hand_str = "blindfold",
		slot_r_hand_str = "blindfold"
		)
	tint = TINT_BLIND
	flash_protection = FLASH_PROTECTION_MAJOR

	drop_sound = SFX_DROP_GLOVES
	pickup_sound = SFX_PICKUP_GLOVES

/obj/item/clothing/glasses/sunglasses/blindfold/tape
	name = "length of tape"
	desc = "It's a robust DIY blindfold!"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "tape_cross"
	item_state_slots = list()
	w_class = ITEM_SIZE_TINY

/obj/item/clothing/glasses/sunglasses/prescription
	name = "prescription sunglasses"
	prescription = 5

/obj/item/clothing/glasses/sunglasses/big
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Larger than average enhanced shielding blocks many flashes."
	icon_state = "bigsunglasses"

/obj/item/clothing/glasses/welding
	name = "welding goggles"
	desc = "Protects the eyes from welders, approved by the mad scientist association."
	icon_state = "welding-g"
	item_state_slots = list(
		slot_l_hand_str = "welding-g",
		slot_r_hand_str = "welding-g"
		)
	action_button_name = "Flip Welding Goggles"
	matter = list(MATERIAL_STEEL = 1500, MATERIAL_GLASS = 1000)
	use_alt_layer = TRUE
	var/up = FALSE
	flash_protection = FLASH_PROTECTION_MAJOR
	tint = TINT_HEAVY

/obj/item/clothing/glasses/welding/attack_self()
	toggle()

/obj/item/clothing/glasses/welding/verb/toggle()
	set category = "Object"
	set name = "Adjust welding goggles"
	set src in usr

	if(!usr.incapacitated())
		if(src.up)
			src.up = !src.up
			flags_inv |= HIDEEYES
			body_parts_covered |= EYES
			icon_state = initial(icon_state)
			item_state = initial(item_state)
			flash_protection = initial(flash_protection)
			tint = initial(tint)
			to_chat(usr, "You flip \the [src] down to protect your eyes.")
		else
			src.up = !src.up
			flags_inv &= ~HIDEEYES
			body_parts_covered &= ~EYES
			icon_state = "[initial(icon_state)]up"
			item_state = "[initial(icon_state)]up"
			flash_protection = FLASH_PROTECTION_NONE
			tint = TINT_NONE
			to_chat(usr, "You push \the [src] up out of your face.")
		update_clothing_icon()
		update_vision()
		usr.update_action_buttons()

/obj/item/clothing/glasses/welding/superior
	name = "superior welding goggles"
	desc = "Welding goggles made from more expensive materials, strangely smells like potatoes."
	icon_state = "rwelding-g"
	tint = TINT_MODERATE

/obj/item/clothing/glasses/tacgoggles
	name = "tactical goggles"
	desc = "Self-polarizing goggles with light amplification for dark environments. Made from durable synthetic."
	icon_state = "swatgoggles"
	origin_tech = list(TECH_MAGNET = 2, TECH_COMBAT = 4)
	darkness_view = 5
	action_button_name = "Toggle Goggles"
	toggleable = TRUE
	see_invisible = SEE_INVISIBLE_NOLIGHTING
	armor = list(melee = 20, bullet = 20, laser = 20, energy = 15, bomb = 20, bio = 0)
	siemens_coefficient = 0.6
	electric = TRUE

/obj/item/clothing/glasses/magma_dark_glasses
	name = "dark gar glasses"
	desc = "The coolest dark-colored glasses in the universe! At least according to ads."
	icon_state = "magma_dark_glasses"

/obj/item/clothing/glasses/magma_red_glasses
	name = "red gar glasses"
	desc = "The coolest red-colored glasses in the universe! At least according to ads."
	icon_state = "magma_red_glasses"

/obj/item/clothing/glasses/magma_dual_glasses
	name = "dual gar glasses"
	desc = "The coolest dual-colored glasses in the universe! At least according to ads."
	icon_state = "magma_dual_glasses"
