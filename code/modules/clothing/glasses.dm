///////////////////////////////////////////////////////////////////////
//Glasses
/*
SEE_SELF  // can see self, no matter what
SEE_MOBS  // can see all mobs, no matter what
SEE_OBJS  // can see all objs, no matter what
SEE_TURFS // can see all turfs (and areas), no matter what
SEE_PIXELS// if an object is located on an unlit area, but some of its pixels are
	      // in a lit area (via pixel_x, y or smooth movement), can see those pixels
BLIND     // can't see anything
*/
/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	w_class = ITEM_SIZE_SMALL
	body_parts_covered = EYES
	slot_flags = SLOT_EYES
	coverage = 1.0

	blood_overlay_type = null // These are too small to bother, no need to waste CPU time

	drop_sound = SFX_DROP_ACCESSORY
	pickup_sound = SFX_PICKUP_ACCESSORY
	can_be_wrung_out = FALSE

	var/vision_flags = 0
	var/darkness_view = 0//Base human is 2
	var/see_invisible = -1
	var/light_protection = 0

/obj/item/clothing/glasses/update_clothing_icon()
	if(ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_glasses()
