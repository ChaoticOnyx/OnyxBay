/obj/item/clothing/mask/balaclava
	name = "balaclava"
	desc = "Designed to both hide identities and keep your face comfy and warm."
	icon_state = "balaclava"
	item_state = "balaclava"
	flags_inv = HIDEFACE|BLOCKHAIR
	body_parts_covered = FACE|HEAD
	down_body_parts_covered = HEAD
	down_flags_inv = BLOCKHEADHAIR
	down_icon_state = "balaclava_r"
	pull_mask = 1
	w_class = ITEM_SIZE_SMALL
	rad_resist_type = /datum/rad_resist/mask_balaclava

/datum/rad_resist/mask_balaclava
	alpha_particle_resist = 21.6 MEGA ELECTRONVOLT
	beta_particle_resist = 2.4 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/item/clothing/mask/balaclava/tactical
	name = "green balaclava"
	icon_state = "swatclava"
	item_state = "swatclava"
	down_icon_state = "swatclava_r"

/obj/item/clothing/mask/luchador
	name = "Luchador Mask"
	desc = "Worn by robust fighters, flying high to defeat their foes!"
	icon_state = "luchag"
	item_state = "luchag"
	flags_inv = HIDEFACE|BLOCKHAIR
	body_parts_covered = HEAD|FACE
	w_class = ITEM_SIZE_SMALL
	siemens_coefficient = 3.0
	rad_resist_type = /datum/rad_resist/mask_luchador

/datum/rad_resist/mask_luchador
	alpha_particle_resist = 20 MEGA ELECTRONVOLT
	beta_particle_resist = 2.25 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/item/clothing/mask/luchador/tecnicos
	name = "Tecnicos Mask"
	desc = "Worn by robust fighters who uphold justice and fight honorably."
	icon_state = "luchador"
	item_state = "luchador"

/obj/item/clothing/mask/luchador/rudos
	name = "Rudos Mask"
	desc = "Worn by robust fighters who are willing to do anything to win."
	icon_state = "luchar"
	item_state = "luchar"
