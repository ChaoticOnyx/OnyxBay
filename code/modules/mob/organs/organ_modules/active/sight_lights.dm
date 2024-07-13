/obj/item/organ_module/active/sightlights
	name = "ocular installed sightlights "
	desc = "Designed to assist medical personnel in darker areas or places experiencing periodic power issues, " \
		+ "Sightlights will allow one to be able to use their eyes as a flashlight."
	icon_state = "sightlights"
	cooldown = 30
	var/lights_on = FALSE
	allowed_organs = list(BP_EYES)
	cpu_load = 0
	loadout_cost = 5

/obj/item/organ_module/active/sightlights/activate(obj/item/organ/E, mob/living/carbon/human/H)
	lights_on = !lights_on

	if(lights_on)
		H.set_light(1, 1, 3, "#FAE1AF")
	else
		H.set_light(0)

/obj/item/organ_module/active/sightlights/emp_act(severity)
	. = ..()
	set_light(0)
