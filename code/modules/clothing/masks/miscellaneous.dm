/obj/item/clothing/mask/muzzle
	name = "muzzle"
	desc = "To stop that awful noise."
	icon_state = "muzzle"
	item_state = "muzzle"
	body_parts_covered = FACE
	w_class = ITEM_SIZE_SMALL
	gas_transfer_coefficient = 0.90
	voicechange = 1

/obj/item/clothing/mask/muzzle/tape
	name = "length of tape"
	desc = "It's a robust DIY muzzle!"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "tape_cross"
	item_state = null
	w_class = ITEM_SIZE_TINY
	use_alt_layer = TRUE

/obj/item/clothing/mask/muzzle/ballgag
	name = "Ballgag"
	desc = "For when Master wants silence."
	icon_state = "ballgag"
	item_state = "ballgag"
	can_use_alt_layer = TRUE

/obj/item/clothing/mask/muzzle/Initialize()
	. = ..()
	say_messages = list("Mmfph!", "Mmmf mrrfff!", "Mmmf mnnf!")
	say_verbs = list("mumbles", "says")

// Clumsy folks can't take the mask off themselves.
/obj/item/clothing/mask/muzzle/attack_hand(mob/user)
	if(user.wear_mask == src && !user.IsAdvancedToolUser())
		return 0
	..()

/obj/item/clothing/mask/surgical
	name = "sterile mask"
	desc = "A sterile mask designed to help prevent the spread of diseases."
	icon_state = "sterile"
	item_state = "sterile"
	w_class = ITEM_SIZE_SMALL
	body_parts_covered = FACE
	item_flags = 0
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.01
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 60)
	down_gas_transfer_coefficient = 1
	down_body_parts_covered = null
	down_icon_state = "steriledown"
	pull_mask = 1
	use_alt_layer = TRUE

	rad_resist_type = /datum/rad_resist/mask_syrgical

/datum/rad_resist/mask_syrgical
	alpha_particle_resist = 13.5 MEGA ELECTRONVOLT
	beta_particle_resist = 2.2 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/item/clothing/mask/fakemoustache
	name = "fake moustache"
	desc = "Warning: moustache is fake."
	icon_state = "fake-moustache"
	flags_inv = HIDEFACE
	body_parts_covered = NO_BODYPARTS
	visible_name = "Scoundrel"
	can_use_alt_layer = TRUE

/obj/item/clothing/mask/snorkel
	name = "Snorkel"
	desc = "For the Swimming Savant."
	icon_state = "snorkel"
	flags_inv = HIDEFACE
	body_parts_covered = NO_BODYPARTS

/obj/item/clothing/mask/bluescarf
	name = "blue neck scarf"
	desc = "A blue neck scarf."
	icon_state = "blueneckscarf"
	item_state = "blueneckscarf"
	body_parts_covered = NO_BODYPARTS
	item_flags = 0
	w_class = ITEM_SIZE_SMALL
	can_use_alt_layer = TRUE

/obj/item/clothing/mask/uwu
	name = "UwU mask"
	desc = "Weaboo mask."
	icon_state = "uwu"
	item_state = "uwu"
	body_parts_covered = NO_BODYPARTS
	item_flags = 0
	w_class = ITEM_SIZE_SMALL
	use_alt_layer = TRUE

/obj/item/clothing/mask/redwscarf
	name = "red white scarf"
	desc = "A red and white checkered neck scarf."
	icon_state = "redwhite_scarf"
	item_state = "redwhite_scarf"
	body_parts_covered = NO_BODYPARTS
	item_flags = 0
	w_class = ITEM_SIZE_SMALL
	can_use_alt_layer = TRUE

/obj/item/clothing/mask/greenscarf
	name = "green scarf"
	desc = "A green neck scarf."
	icon_state = "green_scarf"
	item_state = "green_scarf"
	body_parts_covered = NO_BODYPARTS
	w_class = ITEM_SIZE_SMALL
	can_use_alt_layer = TRUE

/obj/item/clothing/mask/ninjascarf
	name = "ninja scarf"
	desc = "A stealthy, dark scarf."
	icon_state = "ninja_scarf"
	item_state = "ninja_scarf"
	body_parts_covered = NO_BODYPARTS
	w_class = ITEM_SIZE_SMALL
	can_use_alt_layer = TRUE

/obj/item/clothing/mask/sbluescarf
	name = "stripped blue scarf"
	desc = "A stripped blue neck scarf."
	icon_state = "sblue_scarf"
	item_state = "sblue_scarf"
	body_parts_covered = NO_BODYPARTS
	w_class = ITEM_SIZE_SMALL
	can_use_alt_layer = TRUE

/obj/item/clothing/mask/sgreenscarf
	name = "stripped green scarf"
	desc = "A stripped green neck scarf."
	icon_state = "sgreen_scarf"
	item_state = "sgreen_scarf"
	body_parts_covered = NO_BODYPARTS
	w_class = ITEM_SIZE_SMALL
	can_use_alt_layer = TRUE

/obj/item/clothing/mask/sredscarf
	name = "stripped red scarf"
	desc = "A stripped red neck scarf."
	icon_state = "sred_scarf"
	item_state = "sred_scarf"
	body_parts_covered = NO_BODYPARTS
	w_class = ITEM_SIZE_SMALL
	can_use_alt_layer = TRUE

/obj/item/clothing/mask/redscarf
	name = "red scarf"
	desc = "A red neck scarf."
	icon_state = "red_scarf"
	item_state = "red_scarf"
	body_parts_covered = NO_BODYPARTS
	w_class = ITEM_SIZE_SMALL
	can_use_alt_layer = TRUE

/obj/item/clothing/mask/ai
	name = "camera MIU"
	desc = "Allows for direct mental connection to accessible camera networks."
	icon_state = "s-ninja"
	item_state = "s-ninja"
	flags_inv = HIDEFACE
	body_parts_covered = FACE|EYES
	action_button_name = "Toggle MUI"
	origin_tech = list(TECH_DATA = 5, TECH_ENGINEERING = 5)
	armor = list(melee = 10, bullet = 10, laser = 10, energy = 5, bomb = 0, bio = 0) //Well it's made of some sort of plastic.
	use_alt_layer = TRUE
	can_use_alt_layer = TRUE

	var/active = FALSE
	var/mob/observer/eye/cameranet/eye

/obj/item/clothing/mask/ai/New()
	eye = new(src)
	eye.name_sufix = "camera MIU"
	..()

/obj/item/clothing/mask/ai/Destroy()
	if(eye)
		if(active)
			disengage_mask(eye.owner)
		qdel(eye)
		eye = null

	return ..()

/obj/item/clothing/mask/ai/attack_self(mob/user)
	if(user.incapacitated())
		return
	active = !active
	to_chat(user, "<span class='notice'>You [active ? "" : "dis"]engage \the [src].</span>")
	if(active)
		engage_mask(user)
	else
		disengage_mask(user)

/obj/item/clothing/mask/ai/equipped(mob/user, slot)
	..(user, slot)
	engage_mask(user)

/obj/item/clothing/mask/ai/dropped(mob/user)
	..()
	disengage_mask(user)

/obj/item/clothing/mask/ai/proc/engage_mask(mob/user)
	if(!active)
		return
	if(user.get_equipped_item(slot_wear_mask) != src)
		return

	eye.possess(user)
	to_chat(eye.owner, "<span class='notice'>You feel disorented for a moment as your mind connects to the camera network.</span>")

/obj/item/clothing/mask/ai/proc/disengage_mask(mob/user)
	if(user == eye.owner)
		to_chat(eye.owner, "<span class='notice'>You feel disorented for a moment as your mind disconnects from the camera network.</span>")
		eye.release(eye.owner)
		eye.forceMove(src)

/obj/item/clothing/mask/rubber
	name = "rubber mask"
	desc = "A rubber mask."
	icon_state = "balaclava"
	flags_inv = HIDEFACE|BLOCKHAIR
	siemens_coefficient = 0.7
	body_parts_covered = HEAD|FACE|EYES
	armor = list(melee = 5, bullet = 5, laser = 5, energy = 0, bomb = 0, bio = 0)
	rad_resist_type = /datum/rad_resist/mask_rubber

/datum/rad_resist/mask_rubber
	alpha_particle_resist = 16 MEGA ELECTRONVOLT
	beta_particle_resist = 3.4 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/item/clothing/mask/rubber/trasen
	name = "Jack Trasen mask"
	desc = "CEO of NanoTrasen corporation. Perfect for scaring the unionizing children."
	icon_state = "trasen"
	visible_name = "Jack Trasen"

/obj/item/clothing/mask/rubber/barros
	name = "Amaya Barros mask"
	desc = "Current Secretary-General of Sol Cental Government. Not that the real thing would visit this pigsty."
	icon_state = "barros"
	visible_name = "Amaya Barros"

/obj/item/clothing/mask/rubber/admiral
	name = "Admiral Diwali mask"
	desc = "Admiral that led the offensive against the Terran Colonial Navy in the Gaia conflict. For bridge officers who wish they'd achieve a fraction of that."
	icon_state = "admiral"
	visible_name = "Admiral Diwali"

/obj/item/clothing/mask/rubber/turner
	name = "Charles Turner mask"
	desc = "Premier of the Terran Colonial Confederation. Probably shouldn't wear this in front of your veteran uncle."
	icon_state = "turner"
	visible_name = "Charles Turner"

/obj/item/clothing/mask/rubber/species
	name = "human mask"
	desc = "A rubber human mask."
	icon_state = "manmet"
	var/species = SPECIES_HUMAN

/obj/item/clothing/mask/rubber/species/New()
	..()
	visible_name = species
	var/datum/species/S = all_species[species]
	if(istype(S))
		visible_name = S.get_random_name(pick(MALE,FEMALE))

/obj/item/clothing/mask/rubber/species/tajaran
	name = "tajara mask"
	desc = "A rubber tajara mask."
	icon_state = "catmet"
	species = SPECIES_TAJARA

/obj/item/clothing/mask/rubber/species/unathi
	name = "unathi mask"
	desc = "A rubber unathi mask."
	icon_state = "lizmet"
	species = SPECIES_UNATHI

/obj/item/clothing/mask/rubber/species/skrell
	name = "skrell mask"
	desc = "A rubber skrell mask."
	icon_state = "skrellmet"
	species = SPECIES_SKRELL

/obj/item/clothing/mask/spirit
	name = "spirit mask"
	desc = "An eerie mask of ancient, pitted wood."
	icon_state = "spirit_mask"
	item_state = "spirit_mask"
	flags_inv = HIDEFACE
	body_parts_covered = FACE|EYES

// Bandanas below
/obj/item/clothing/mask/bandana
	name = "black bandana"
	desc = "A fine bandana with nanotech lining. Can be worn on the head or face."
	flags_inv = HIDEFACE
	slot_flags = SLOT_MASK|SLOT_HEAD
	body_parts_covered = FACE
	icon_state = "bandblack"
	item_state = "bandblack"
	item_flags = 0
	w_class = ITEM_SIZE_SMALL
	armor = list(melee = 5, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 15)
	use_alt_layer = TRUE
	can_use_alt_layer = TRUE

	rad_resist_type = /datum/rad_resist/bandana

/datum/rad_resist/bandana
	alpha_particle_resist = 12 MEGA ELECTRONVOLT
	beta_particle_resist = 2.18 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/item/clothing/mask/bandana/equipped(mob/user, slot)
	switch(slot)
		if(slot_wear_mask) //Mask is the default for all the settings
			flags_inv = initial(flags_inv)
			body_parts_covered = initial(body_parts_covered)
			icon_state = initial(icon_state)

		if(slot_head)
			flags_inv = 0
			body_parts_covered = HEAD
			icon_state = "[initial(icon_state)]_up"

	return ..()

/obj/item/clothing/mask/bandana/red
	name = "red bandana"
	icon_state = "bandred"
	item_state = "bandred"

/obj/item/clothing/mask/bandana/blue
	name = "blue bandana"
	icon_state = "bandblue"
	item_state = "bandblue"

/obj/item/clothing/mask/bandana/green
	name = "green bandana"
	icon_state = "bandgreen"
	item_state = "bandgreen"

/obj/item/clothing/mask/bandana/gold
	name = "gold bandana"
	icon_state = "bandgold"
	item_state = "bandgold"

/obj/item/clothing/mask/bandana/orange
	name = "orange bandana"
	icon_state = "bandorange"
	item_state = "bandorange"

/obj/item/clothing/mask/bandana/purple
	name = "purple bandana"
	icon_state = "bandpurple"
	item_state = "bandpurple"

/obj/item/clothing/mask/bandana/botany
	name = "botany bandana"
	icon_state = "bandbotany"
	item_state = "bandbotany"

/obj/item/clothing/mask/bandana/camo
	name = "camo bandana"
	icon_state = "bandcamo"
	item_state = "bandcamo"

/obj/item/clothing/mask/bandana/skull
	name = "skull bandana"
	desc = "A fine black bandana with nanotech lining and a skull emblem. Can be worn on the head or face."
	icon_state = "bandskull"
	item_state = "bandskull"
	rad_resist_type = /datum/rad_resist/bandana

/datum/rad_resist/bandana
	alpha_particle_resist = 12 MEGA ELECTRONVOLT
	beta_particle_resist = 2.18 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/item/clothing/mask/bandana/customwhite //Custom item
	name = "white bandana"
	desc = "A fine white bandana with nanotech lining. Can be worn on the head or face."
	icon_state = "custom_bandwhite"
	item_state = "custom_bandwhite"

/obj/item/clothing/mask/skullmask
	name = "skull"
	desc = "Jeez, is it a real skull?.."
	flags_inv = HIDEFACE
	body_parts_covered = FACE
	icon_state = "skullmask"
	item_state = "skullmask"
	w_class = ITEM_SIZE_NORMAL
	armor = list(melee = 15, bullet = 10, laser = 10, energy = 0, bomb = 0, bio = 0)
	siemens_coefficient = 0.8
	can_use_alt_layer = TRUE

/obj/item/clothing/mask/plasticbag
	name = "plastic bag"
	desc = "Not an eco-friendly way to get your money back."
	icon_state = "plasticbag"
	item_state = "plasticbag"
	flags_inv = HIDEFACE|BLOCKHAIR
	body_parts_covered = HEAD|FACE|EYES
	tint = TINT_BLIND

/obj/item/clothing/mask/plasticbag/attack_self(mob/user)
	user.replace_item(src, new /obj/item/storage/bag/plasticbag, TRUE, TRUE)

/obj/item/clothing/mask/plasticbag/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/tape_roll))
		to_chat(user, "You attach a piece of [W] to [src]!")
		new /obj/item/clothing/mask/gas/plasticbag(get_turf(src))
		qdel(src)
