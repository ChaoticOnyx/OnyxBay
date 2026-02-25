/obj/item/organ_module/active/lenses
	name = "corrective lenses"
	icon_state = "eye"
	allowed_organs = list(BP_EYES, BP_OPTICS)
	cpu_load = 0
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL | OM_FLAG_MECHANICAL
	available_in_charsetup = FALSE
	loadout_cost = 0

	/// Influences darksight range
	var/darkness_view
	/// Unused, vision_flags are currently not modified in-game. Left here just in case.
	var/vision_flags
	/// For those who require prescription glasses.
	var/prescription
	/// Works similar to sunglasses.
	var/light_protection
	/// Don't touch if you're not sure
	var/see_invisible
	/// Darkens the wearer's screen.
	var/tint
	/// Level of flash protection.
	var/flash_protection
	/// Will be applied to the wearer's screen.
	var/atom/movable/screen/overlay
	/// If this module can be toggled or works passively. Note - when toggled is FALSE, lenses will not be processed and their variables will not be applied to the wearer.
	var/toggleable = FALSE
	toggled = TRUE

/// Called from 'update_equipment_vision()', which is in turn called from 'Life()'. Override for special behavior.
/obj/item/organ_module/active/lenses/proc/process_hud(mob/living/carbon/human/owner)
	SHOULD_CALL_PARENT(FALSE)
	return

/obj/item/organ_module/active/lenses/emp_act(severity)
	. = ..()

	var/obj/item/organ/internal/eyes/eyes = loc
	if(!istype(eyes))
		return

	var/mob/living/carbon/human/wearer = eyes.loc
	if(!istype(wearer))
		return

	to_chat(wearer, SPAN("danger", "Your [src] malfunctions, blinding you!"))
	wearer.eye_blind = 2
	wearer.eye_blurry = 4
	if(!(wearer.disabilities & NEARSIGHTED))
		wearer.disabilities |= NEARSIGHTED
		spawn(100)
			wearer.disabilities &= ~NEARSIGHTED

	if(toggleable)
		toggled = FALSE

/obj/item/organ_module/active/lenses/prescription
	name = "prescription lenses"
	prescription = 7


/obj/item/organ_module/active/lenses/hud
	name = "hud lenses"
	desc = "With this Zeng-Hu technology - you can forget about fragile glasses on your face. Works with every hud matrix."
	toggleable = TRUE
	toggled = FALSE
	action_button_name = "HUD lenses"
	available_in_charsetup = TRUE
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL | OM_FLAG_MECHANICAL
	loadout_cost = 0
	augment_cost = 5
	w_class = 1
	cpu_load = 0
	origin_tech = list(TECH_BIO = 5, TECH_MATERIAL = 3, TECH_ENGINEERING = 2, TECH_DATA = 4)
	/// Will process security hud if TRUE
	var/sec_hud = FALSE
	/// Will process medhud if TRUE
	var/med_hud = FALSE
	var/obj/item/device/hudmatrix/matrix = null
	/// Built-in HUD, doesn't require or allow matrix installation
	var/builtin = FALSE

/obj/item/organ_module/active/lenses/hud/process_hud(mob/living/carbon/human/owner)
	if(sec_hud)
		process_sec_hud(owner, TRUE)
	if(med_hud)
		process_med_hud(owner, TRUE)

/obj/item/organ_module/active/lenses/hud/activate(obj/item/organ/E, mob/living/carbon/human/user)
	if(builtin)
		toggled = !toggled
		var/eyes_covered = FALSE
		if(istype(user, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			var/list/protection = list(H.head, H.glasses, H.wear_mask)
			for(var/obj/item/I in protection)
				if(I && (I.body_parts_covered & EYES))
					eyes_covered = TRUE
					break
		if(!eyes_covered)
			user.visible_message(
				toggled ? "<b>[user]</b>'s pupils narrow..." : "<b>[user]</b>'s pupils return to normal.",
				range = 3
			)
		user.update_hud_eye_glow()
		return

	if(!matrix)
		to_chat(user, SPAN("notice", "No HUD matrix installed."))
		return

	var/list/choices = list(
		"Toggle HUD" = "toggle",
		"Remove matrix" = "remove"
	)
	var/choice = input(user, "HUD lenses", "HUD lenses") as null|anything in choices
	if(!choice)
		return

	if(choices[choice] == "toggle")
		toggled = !toggled
		var/eyes_covered = FALSE
		if(istype(user, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			var/list/protection = list(H.head, H.glasses, H.wear_mask)
			for(var/obj/item/I in protection)
				if(I && (I.body_parts_covered & EYES))
					eyes_covered = TRUE
					break
		if(!eyes_covered)
			user.visible_message(
				toggled ? "<b>[user]</b>'s pupils narrow..." : "<b>[user]</b>'s pupils return to normal.",
				range = 3
			)
		user.update_hud_eye_glow()
		return

	if(choices[choice] == "remove")
		if(user.get_active_hand())
			to_chat(user, SPAN("notice", "You need a free hand."))
			return

		var/obj/item/device/hudmatrix/M = matrix
		if(!M)
			return

		matrix = null
		overlay = null
		vision_flags = initial(vision_flags)
		see_invisible = initial(see_invisible)
		darkness_view = initial(darkness_view)
		flash_protection = initial(flash_protection)
		sec_hud = FALSE
		med_hud = FALSE
		toggled = FALSE

		if(!user.put_in_active_hand(M))
			M.dropInto(get_turf(user))

		to_chat(user, SPAN("notice", "You remove \the [M] from \the [src]."))
		user.update_equipment_vision()
		user.update_hud_eye_glow()
		return

/obj/item/organ_module/active/lenses/hud/attackby(obj/item/I, mob/user)
	if(builtin)
		return
	. = ..()

/obj/item/organ_module/active/lenses/hud/sec
	name = "Security HUD implant"
	desc = "Zeng-Hu augmentation for eyes of military personell. Flash protection included."
	icon_state = "hunterseye"
	sec_hud = TRUE
	builtin = TRUE
	loadout_cost = 0
	augment_cost = 5
	available_in_charsetup = TRUE
	allowed_roles = list(/datum/job/hos, /datum/job/warden, /datum/job/detective, /datum/job/officer)
	flash_protection = FLASH_PROTECTION_MODERATE

/obj/item/organ_module/active/lenses/hud/med
	name = "Medical HUD implant"
	desc = "Provides you with real-time vitals of every person you see."
	icon_state = "eye_medical"
	med_hud = TRUE
	builtin = TRUE
	loadout_cost = 0
	augment_cost = 3
	available_in_charsetup = TRUE
	allowed_roles = list(/datum/job/cmo, /datum/job/doctor, /datum/job/psychiatrist, /datum/job/chemist, /datum/job/paramedic)

/obj/item/organ_module/active/lenses/hud/deactivate(obj/item/organ/E, mob/living/carbon/human/user)
	if(toggled)
		toggled = FALSE
		var/eyes_covered = FALSE
		if(istype(user, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			var/list/protection = list(H.head, H.glasses, H.wear_mask)
			for(var/obj/item/I in protection)
				if(I && (I.body_parts_covered & EYES))
					eyes_covered = TRUE
					break
		if(!eyes_covered)
			user.visible_message(
				"<b>[user]</b>'s pupils return to normal.",
				range = 3
			)
		if(istype(user, /mob/living/carbon/human))
			user.update_hud_eye_glow()

/obj/item/organ_module/active/lenses/hud/is_cpu_active(mob/living/carbon/human/H)
	return toggled
