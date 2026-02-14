/obj/item/organ_module/active/sightlights
	name = "ocular installed sightlights"
	desc = "Designed to assist medical personnel in darker areas or places experiencing periodic power issues, " \
		+ "Sightlights will allow one to be able to use their eyes as a flashlight."
	action_button_name = "Toggle sightlights"
	icon_state = "sightlights"
	cooldown = 30
	var/lights_on = FALSE
	light_color = "#FAE1AF"
	allowed_organs = list(BP_EYES)
	cpu_load = 0
	available_in_charsetup = TRUE
	loadout_cost = 0
	augment_cost = 3
	w_class = 1

/obj/item/organ_module/active/sightlights/activate(obj/item/organ/E, mob/living/carbon/human/H)
	lights_on = !lights_on

	if(lights_on)
		H.set_light(1, 1, 3, l_color = light_color)
	else
		H.set_light(0)
	H.update_hud_eye_glow()

/obj/item/organ_module/active/sightlights/deactivate(obj/item/organ/E, mob/living/carbon/human/H)
	if(lights_on)
		lights_on = FALSE
		H.set_light(0)
		H.update_hud_eye_glow()

/obj/item/organ_module/active/sightlights/is_cpu_active(mob/living/carbon/human/H)
	return lights_on

/obj/item/organ_module/active/sightlights/emp_act(severity)
	. = ..()
	lights_on = FALSE
	var/obj/item/organ/internal/eyes/eyes = loc
	var/mob/living/carbon/human/H = eyes?.owner
	H?.set_light(0)
