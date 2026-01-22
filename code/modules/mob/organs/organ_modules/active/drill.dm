/obj/item/organ_module/active/simple/drill
	name = "integrated drill"
	icon_state = "augment-tool"
	action_button_name = "Deploy drill"
	allowed_organs = list(BP_L_ARM, BP_R_ARM)
	holding_type = /obj/item/pickaxe/drill

/obj/item/organ_module/active/simple/drill/emp_act(severity)
	. = ..()

	var/obj/item/organ/external/E = loc
	var/mob/living/carbon/human/H = E?.owner
	if(!istype(E) || !istype(H))
		return

	var/chance = 10 * (4 - severity)
	if(!prob(chance))
		return

	H.visible_message(
		SPAN_WARNING("[H]'s integrated drill spins out of control inside \his hand!"),
		SPAN_DANGER("Your integrated drill spins out of control inside your hand!")
	)
	H.apply_damage(rand(8, 16), BRUTE, E.organ_tag)
