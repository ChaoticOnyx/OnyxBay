/obj/item/organ_module/active/lenses
	name = "corrective lenses"
	icon_state = "eye"
	allowed_organs = list(BP_EYES)
	cpu_load = 0
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
	loadout_cost = 1

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
	pass()

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
	toggleable = TRUE
	toggled = FALSE
	action_button_name = "Toggle HUD lenses"
	/// Will process security hud if TRUE
	var/sec_hud = FALSE
	/// Will process medhud if TRUE
	var/med_hud = FALSE

/obj/item/organ_module/active/lenses/hud/process_hud(mob/living/carbon/human/owner)
	if(sec_hud)
		process_sec_hud(owner, TRUE)
	if(med_hud)
		process_med_hud(owner, TRUE)

/obj/item/organ_module/active/lenses/hud/activate(obj/item/organ/E, mob/living/carbon/human/user)
	toggled = !toggled

	user.visible_message(
		toggled ? "<b>[user]</b>'s pupils narrow..." : "<b>[user]</b>'s pupils return to normal.",
		range = 3
	)

/obj/item/organ_module/active/lenses/hud/sec
	name = "Security HUD implant"
	icon_state = "hunterseye"
	sec_hud = TRUE
	loadout_cost = 2
	allowed_jobs = list(/datum/job/hos, /datum/job/warden, /datum/job/detective, /datum/job/officer)

/obj/item/organ_module/active/lenses/hud/med
	name = "Medical HUD implant"
	icon_state = "eye_medical"
	med_hud = TRUE
	loadout_cost = 2
	allowed_jobs = list(/datum/job/cmo, /datum/job/doctor, /datum/job/psychiatrist, /datum/job/chemist, /datum/job/paramedic)
