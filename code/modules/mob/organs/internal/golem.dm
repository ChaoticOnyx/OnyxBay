/obj/item/organ/internal/adamantine_resonator
	name = "adamantine resonator"
	desc = "Fragments of adamantine exist in all golems, stemming from their origins as purely magical constructs. These are used to \"hear\" messages from their leaders."
	organ_tag = BP_ADAMANTINE_RESONATOR
	parent_organ = BP_HEAD
	icon_state = "adamantine_resonator"
	icon = 'icons/mob/human_races/organs/golems.dmi'

/obj/item/organ/internal/adamantine_resonator/New()
	..()
	if(istype(owner))
		GLOB.golems_resonator.Add(src)

/obj/item/organ/internal/adamantine_resonator/replaced()
	..()
	if(istype(owner))
		GLOB.golems_resonator.Add(src)

/obj/item/organ/internal/adamantine_resonator/removed(mob/living/user, drop_organ, detach)
	..()
	if(!istype(owner))
		GLOB.golems_resonator.Remove(src)

/obj/item/organ/internal/vocal_cords/adamantine
	name = "adamantine vocal cords"
	desc = "When adamantine resonates, it causes all nearby pieces of adamantine to resonate as well. Adamantine golems use this to broadcast messages to nearby golems."
	icon_state = "adamantine_cords"
	icon = 'icons/mob/human_races/organs/golems.dmi'
	organ_tag = BP_ADAMANTINE_VOCAL_CORDS
	parent_organ = BP_HEAD
	var/datum/action/organ_action

/obj/item/organ/internal/vocal_cords/adamantine/New()
	..()
	if(istype(owner))
		organ_action = new /datum/action/innate/adamantine_vocal_cords(src)
		organ_action.Grant(owner)
		spawn(1)
			owner.update_action_buttons()

/obj/item/organ/internal/vocal_cords/adamantine/replaced(mob/living/carbon/human/target, obj/item/organ/external/affected)
	..()
	if(istype(owner))
		organ_action.Grant(owner)
		spawn(1)
			owner.update_action_buttons()

/obj/item/organ/internal/vocal_cords/adamantine/removed(mob/living/user, drop_organ, detach)
	organ_action.Remove(owner)
	spawn(1)
		owner.update_action_buttons()
	..()

/datum/action/innate/adamantine_vocal_cords
	check_flags = AB_CHECK_ALIVE|AB_CHECK_INSIDE
	button_icon_state = "adamantine_cords"

/datum/action/innate/adamantine_vocal_cords/Trigger(trigger_flags)
	if(!IsAvailable())
		return
	var/message = tgui_input_text(owner, "Resonate a message to all nearby golems", "Resonate")
	if(!message)
		return
	if(QDELETED(src) || QDELETED(owner))
		return

	owner.say(message)
	for (var/obj/item/organ/internal/adamantine_resonator in GLOB.golems_resonator)
		to_chat(adamantine_resonator.owner,FONT_LARGE(SPAN("resonate",SPAN("name","[owner.real_name]</span> <span class='message'>resonates, \"[message]\""))))
