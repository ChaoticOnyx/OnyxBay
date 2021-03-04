/obj/item/clothing/mask/gas
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply. Filters harmful gases from the air."
	icon_state = "gas_alt"
	item_state = "gas_alt"
	item_flags = ITEM_FLAG_BLOCK_GAS_SMOKE_EFFECT | ITEM_FLAG_AIRTIGHT
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE
	body_parts_covered = FACE|EYES
	w_class = ITEM_SIZE_NORMAL
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	siemens_coefficient = 0.8
	var/gas_filter_strength = 1			//For gas mask filters
	var/list/filtered_gases = list("plasma", "sleeping_agent")
	var/istinted = 0
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 0, bomb = 0, bio = 75, rad = 25)

/obj/item/clothing/mask/gas/Initialize()
	. = ..()
	if(istinted)
		overlay = GLOB.global_hud.gasmask

/obj/item/clothing/mask/gas/filter_air(datum/gas_mixture/air)
	var/datum/gas_mixture/filtered = new

	for(var/g in filtered_gases)
		if(air.gas[g])
			filtered.gas[g] = air.gas[g] * gas_filter_strength
			air.gas[g] -= filtered.gas[g]

	air.update_values()
	filtered.update_values()

	return filtered

/obj/item/clothing/mask/gas/old
	name = "old gas mask"
	desc = "An old face-covering mask that can be connected to an air supply. Not less reliable than the new one, but it doesn't look very good. Filters harmful gases from the air."
	icon_state = "gas_mask"
	item_state = "gas_mask"

	armor = list(melee = 10, bullet = 5, laser = 10, energy = 0, bomb = 0, bio = 55, rad = 25)

//Plague Dr suit can be found in clothing/suits/bio.dm
/obj/item/clothing/mask/gas/plaguedoctor
	name = "plague doctor mask"
	desc = "A modernised version of the classic design, this mask will not only filter out plasma but it can also be connected to an air supply."
	icon_state = "plaguedoctor"
	item_state = "plaguedoctor"
	armor = list(melee = 5, bullet = 5, laser = 5,energy = 2, bomb = 0, bio = 90, rad = 10)
	body_parts_covered = HEAD|FACE|EYES
	siemens_coefficient = 0.9

/obj/item/clothing/mask/gas/swat
	name = "\improper SWAT mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "swat"
	item_state = "swat"
	istinted = 0
	siemens_coefficient = 0.5
	body_parts_covered = FACE|EYES
	armor = list(melee = 15, bullet = 15, laser = 15, energy = 0, bomb = 0, bio = 75, rad = 50)

/obj/item/clothing/mask/gas/tactical
	name = "\improper tactical mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "fullgas"
	item_state = "fullgas"

/obj/item/clothing/mask/gas/clear
	name = "gas mask"
	desc = "A close-fitting, panoramic gas mask that can be connected to an air supply."
	icon_state = "gasmask-clear"
	item_state = "gasmask-clear"
	istinted = 0
	siemens_coefficient = 0.9

/obj/item/clothing/mask/gas/police
	name = "police gas mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "policegas"
	item_state = "policegas"
	istinted = 0

/obj/item/clothing/mask/gas/german
	name = "tactical gas mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "wehrgas"
	item_state = "wehrgas"
	istinted = 0

/obj/item/clothing/mask/gas/german/Initialize()
	. = ..()
	overlay = GLOB.global_hud.thermal

/obj/item/clothing/mask/gas/swat/vox
	name = "alien mask"
	desc = "Clearly not designed for a human face."
	body_parts_covered = 0 //Hack to allow vox to eat while wearing this mask.
	species_restricted = list(SPECIES_VOX)

/obj/item/clothing/mask/gas/syndicate
	name = "tactical mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "swat"
	item_state = "swat"
	istinted = 0
	siemens_coefficient = 0.5
	armor = list(melee = 15, bullet = 15, laser = 15, energy = 0, bomb = 0, bio = 75, rad = 50)

/obj/item/clothing/mask/gas/clown_hat
	name = "clown wig and mask"
	desc = "A true prankster's facial attire. A clown is incomplete without their wig and mask."
	icon_state = "clown"
	item_state = "clown"
	istinted = 0

/obj/item/clothing/mask/gas/sexyclown
	name = "sexy-clown wig and mask"
	desc = "A feminine clown mask for the dabbling crossdressers or female entertainers."
	icon_state = "sexyclown"
	item_state = "sexyclown"
	istinted = 0

/obj/item/clothing/mask/gas/mime
	name = "mime mask"
	desc = "The traditional mime's mask. It has an eerie facial posture."
	icon_state = "mime"
	item_state = "mime"
	istinted = 0

/obj/item/clothing/mask/gas/monkeymask
	name = "monkey mask"
	desc = "A mask used when acting as a monkey."
	icon_state = "monkeymask"
	item_state = "monkeymask"
	body_parts_covered = HEAD|FACE|EYES
	istinted = 0

/obj/item/clothing/mask/gas/sexymime
	name = "sexy mime mask"
	desc = "A traditional female mime's mask."
	icon_state = "sexymime"
	item_state = "sexymime"
	istinted = 0

/obj/item/clothing/mask/gas/death_commando
	name = "Death Commando Mask"
	icon_state = "death_commando_mask"
	item_state = "death_commando_mask"
	siemens_coefficient = 0.2

/obj/item/clothing/mask/gas/cyborg
	name = "cyborg visor"
	desc = "Beep boop!"
	icon_state = "death"
	item_state = "death"
	siemens_coefficient = 1.0

/obj/item/clothing/mask/gas/owl_mask
	name = "owl mask"
	desc = "Twoooo!"
	icon_state = "owl"
	item_state = "owl"
	body_parts_covered = HEAD|FACE|EYES
	istinted = 0
	siemens_coefficient = 1.0

/obj/item/clothing/mask/gas/vox
	name = "vox breathing mask"
	desc = "A small oxygen filter for use by Vox"
	icon_state = "respirator"
	istinted = 0
	flags_inv = 0
	body_parts_covered = 0
	species_restricted = list(SPECIES_VOX)
	filtered_gases = list("plasma", "sleeping_agent", "oxygen")
