/obj/item/underwear/top/silicone_top
	name = "Silicone Breasts"
	desc = "200% Organic, 100% Real Woman, and Only 50% Straight."
	icon = 'icons/inv_slots/hidden/mob.dmi'
	icon_state = "siliconetop"
	color = "#ffffff"
	var/buffered_gender
	var/datum/body_build/buffered_build

/obj/item/underwear/top/silicone_top/ForceEquipUnderwear(mob/living/carbon/human/H, update_icons = TRUE)
	buffered_gender = H.gender
	buffered_build = H.body_build

	if(H.gender == FEMALE)
		return ..()

	H.gender = FEMALE
	if(istype(H.body_build, /datum/body_build/slim/male))
		var/datum/species/S = all_species[H.get_species()]
		H.change_body_build(S.body_builds[2])

	H.regenerate_icons()

	return ..()

/obj/item/underwear/top/silicone_top/RemoveUnderwear(mob/user, mob/living/carbon/human/H)
	if(!..())
		return FALSE

	if(buffered_gender == FEMALE)
		return TRUE

	H.gender = buffered_gender
	H.body_build = buffered_build
	buffered_build = null

	H.regenerate_icons()

	return TRUE

/obj/item/underwear/top/silicone_top/verb/change_color()
	set name = "Change Color"
	set category = "Object"
	set desc = "Change the color of the top."
	set src in usr

	if(usr.incapacitated())
		return

	var/new_color = input(usr, "Pick a new color", "Top Color", color) as color|null
	if(!new_color || new_color == color || usr.incapacitated())
		return

	color = new_color
	var/mob/living/carbon/human/H = usr
	H.update_underwear()
