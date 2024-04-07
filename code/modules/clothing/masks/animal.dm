/obj/item/clothing/mask/animal_mask
	flags_inv = HIDEFACE
	w_class = ITEM_SIZE_SMALL
	siemens_coefficient = 0.7
	body_parts_covered = FACE|EYES
	armor = list(melee = 5, bullet = 5, laser = 5, energy = 0, bomb = 0, bio = 0)
	rad_resist_type = /datum/rad_resist/animal_mask

/datum/rad_resist/animal_mask
	alpha_particle_resist = 14.6 MEGA ELECTRONVOLT
	beta_particle_resist = 2.1 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/item/clothing/mask/animal_mask/pig
	name = "pig mask"
	desc = "A rubber pig mask."
	icon_state = "pig"
	item_state = "pig"
	flags_inv = HIDEFACE|BLOCKHAIR
	body_parts_covered = HEAD|FACE|EYES

/obj/item/clothing/mask/animal_mask/rat
	name = "rat mask"
	desc = "Look at my face. We've met before..."
	icon_state = "rat"
	item_state = "rat"

/obj/item/clothing/mask/animal_mask/fox
	name = "fox mask"
	desc = "A fox is hunting."
	icon_state = "fox"
	item_state = "fox"

/obj/item/clothing/mask/animal_mask/bear
	name = "bear mask"
	desc = "Question number one: Do you like hurting other people?"
	icon_state = "bear"
	item_state = "bear"

/obj/item/clothing/mask/animal_mask/bat
	name = "bat mask"
	desc = "This is not baseball bat."
	icon_state = "bat"
	item_state = "bat"

/obj/item/clothing/mask/animal_mask/raven
	name = "raven mask"
	desc = "CAAAAW!."
	icon_state = "raven"
	item_state = "raven"

/obj/item/clothing/mask/animal_mask/jackal
	name = "jackal mask"
	desc = "A simple jackal mask."
	icon_state = "jackal"
	item_state = "jackal"

/obj/item/clothing/mask/animal_mask/bumba
	name = "bumba mask"
	desc = "Something from ancient times."
	icon_state = "bumba"
	item_state = "bumba"

/obj/item/clothing/mask/animal_mask/cow
	name = "cow mask"
	desc = "A moooo mask."
	icon_state = "cow"
	item_state = "cow"

/obj/item/clothing/mask/animal_mask/frog
	name = "frog mask"
	desc = "Ribbit, ribbit, ribbit."
	icon_state = "frog"
	item_state = "frog"

/obj/item/clothing/mask/animal_mask/ian
	name = "Corgi mask"
	desc = "Yap, Yap, Awwoo."
	icon_state = "ian"
	item_state = "ian"

/obj/item/clothing/mask/animal_mask/bee
	name = "bee mask"
	desc = "Buzzzz."
	icon_state = "bee"
	item_state = "bee"

/obj/item/clothing/mask/animal_mask/horsehead
	name = "horse head mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a horse."
	icon_state = "horsehead"
	item_state = "horsehead"
	flags_inv = HIDEFACE|BLOCKHAIR
	body_parts_covered = HEAD|FACE|EYES
	rad_resist_type = /datum/rad_resist/mask_horsehead

/datum/rad_resist/mask_horsehead
	alpha_particle_resist = 15 MEGA ELECTRONVOLT
	beta_particle_resist = 2.14 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/item/clothing/mask/animal_mask/horsehead/New()
	..()
	// The horse mask doesn't cause voice changes by default, the wizard spell changes the flag as necessary
	say_messages = list("NEEIIGGGHHHH!", "NEEEIIIIGHH!", "NEIIIGGHH!", "HAAWWWWW!", "HAAAWWW!")
	say_verbs = list("whinnies", "neighs", "says")
