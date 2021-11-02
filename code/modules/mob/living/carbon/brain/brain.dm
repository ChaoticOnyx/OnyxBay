//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/mob/living/carbon/brain
	var/obj/item/container = null
	var/timeofhostdeath = 0
	var/emp_damage = 0//Handles a type of MMI damage
	var/alert = null
	use_me = 0 //Can't use the me verb, it's a freaking immobile brain
	icon = 'icons/mob/human_races/organs/human.dmi'
	icon_state = "brain1"
	species_language = LANGUAGE_GALCOM // galcom is default for sapient life in game.

/mob/living/carbon/brain/New()
	create_reagents(1000)
	..()

/mob/living/carbon/brain/Destroy()
	if(key)				//If there is a mob connected to this thing. Have to check key twice to avoid false death reporting.
		if(stat!=DEAD)	//If not dead.
			death(1)	//Brains can die again. AND THEY SHOULD AHA HA HA HA HA HA
		ghostize()		//Ghostize checks for key so nothing else is necessary.
	. = ..()

/mob/living/carbon/brain/incapacitated(incapacitation_flags = INCAPACITATION_DEFAULT)
	// brain can't be knocked out.
	if((incapacitation_flags & INCAPACITATION_KNOCKOUT) && (container && istype(container, /obj/item/device/mmi)))
		return FALSE
	return TRUE

/mob/living/carbon/brain/say_understands(mob/other, datum/language/speaking)
	// If brain is not in MMI, it can't hear mob/other.
	if(!(container && istype(container, /obj/item/device/mmi)))
		return FALSE
	return ..()

/mob/living/carbon/brain/update_canmove()
	if(in_contents_of(/obj/mecha) || istype(loc, /obj/item/device/mmi))
		use_me = 1

/mob/living/carbon/brain/isSynthetic()
	return istype(loc, /obj/item/device/mmi/digital)

/mob/living/carbon/brain/binarycheck()
	return isSynthetic()

/mob/living/carbon/brain/check_has_mouth()
	return 0

