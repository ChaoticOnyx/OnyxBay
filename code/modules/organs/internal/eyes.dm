
/obj/item/organ/internal/eyes
	name = "eyeballs"
	icon_state = "eyes"
	gender = PLURAL
	organ_tag = BP_EYES
	parent_organ = BP_HEAD
	surface_accessible = TRUE
	relative_size = 10
	var/plasma_guard = 0
	var/list/eye_colour = list(0,0,0)
	var/innate_flash_protection = 0
	max_damage = 45
	var/isRobotize = 0

/obj/item/organ/internal/eyes/optics
	status = ORGAN_ROBOTIC
	organ_tag = BP_OPTICS

/obj/item/organ/internal/eyes/optics/New()
	..()
	robotize()

/obj/item/organ/internal/eyes/robotize()
	..()
	name = "optical sensor"
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "camera"
	dead_icon = "camera_broken"
	update_colour()
	isRobotize = 1

/obj/item/organ/internal/eyes/robot
	name = "optical sensor"

/obj/item/organ/internal/eyes/robot/New()
	..()
	robotize()

/obj/item/organ/internal/eyes/replaced(mob/living/carbon/human/target)

	// Apply our eye colour to the target.
	if(istype(target) && eye_colour)
		target.r_eyes = eye_colour[1]
		target.g_eyes = eye_colour[2]
		target.b_eyes = eye_colour[3]
		target.update_eyes()
	..()

/obj/item/organ/internal/eyes/proc/update_colour()
	if(!owner)
		return
	eye_colour = list(
		owner.r_eyes ? owner.r_eyes : 0,
		owner.g_eyes ? owner.g_eyes : 0,
		owner.b_eyes ? owner.b_eyes : 0
		)

/obj/item/organ/internal/eyes/take_internal_damage(amount, silent=0)
	var/oldbroken = is_broken()
	. = ..()
	if(is_broken() && !oldbroken && owner && !owner.stat)
		to_chat(owner, "<span class='danger'>You go blind!</span>")

/obj/item/organ/internal/eyes/Process() //Eye damage replaces the old eye_stat var.
	..()
	if(!owner)
		return

	if(germ_level > INFECTION_LEVEL_ONE && prob(1))
		owner.eye_blurry = 5
	if(germ_level > INFECTION_LEVEL_TWO && prob(1))
		owner.eye_blurry = 20
	if(germ_level > INFECTION_LEVEL_THREE && prob(1))
		owner.eye_blind = 2

	if(is_bruised())
		owner.eye_blurry = 20
	if(is_broken())
		owner.eye_blind = 20

/obj/item/organ/internal/eyes/proc/get_total_protection(flash_protection = FLASH_PROTECTION_NONE)
	return (flash_protection + innate_flash_protection)

/obj/item/organ/internal/eyes/proc/additional_flash_effects(intensity)
	return -1
