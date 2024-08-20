
/mob/living/carbon/human/verb/neckwear_layer()
	set name = "Change Neckwear Layer"
	set category = "IC"

	change_neckwear_layer()

/mob/living/carbon/human/proc/change_neckwear_layer()
	var/list/underwear_list = list()
	for(var/obj/item/underwear/neck/N in worn_underwear)
		underwear_list |= N

	if(length(underwear_list) < 1)
		to_chat(user, SPAN("notice", "You wear nothing on your neck."))
		return

	var/obj/item/underwear/neck/choice = null
	if(length(underwear_list) == 1)
		choice = underwear_list[1]
	else
		choice = tgui_input_list(usr, "Position Neckwear", "Select Neckwear", underwear_list)

	var/list/options = list("Under Uniform" = HO_UNDERWEAR_PLUS_LAYER, "Over Uniform" = HO_UNDERWEAR_UNIFORM_LAYER, "Over Suit" = HO_UNDERWEAR_SUIT_LAYER)
	var/new_layer = tgui_input_list(usr, "Position Neckwear", "Neckwear Style", options)
	if(new_layer)
		choice.mob_wear_layer = options[new_layer]
		to_chat(usr, SPAN_NOTICE("\The [src] will now layer [new_layer]."))
		var/mob/living/carbon/human/H = usr
		H?.update_underwear()

/obj/item/underwear/neck
	required_free_body_parts = HEAD
	underwear_slot = UNDERWEAR_SLOT_NECK
	icon = 'icons/obj/clothing/neck.dmi'
	/// Can use different wear layers to be drawn over/under uniform.
