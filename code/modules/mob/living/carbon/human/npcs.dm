/mob/living/carbon/human/monkey/punpun/New()
	..()
	name = "Pun Pun"
	real_name = name
	var/obj/item/clothing/C
	if(prob(50))
		C = new /obj/item/clothing/under/monkey/punpun(src)
		equip_to_appropriate_slot(C)
	else
		C = new /obj/item/clothing/under/monkey/pants(src)
		C.attach_accessory(null, new /obj/item/clothing/accessory/toggleable/hawaii/random(src))
		equip_to_appropriate_slot(C)
		mutations.Add(MUTATION_BARTENDER)
		if(prob(10))
			C = new /obj/item/clothing/head/collectable/petehat(src)
			equip_to_appropriate_slot(C)

/decl/hierarchy/outfit/blank_subject
	name = "Test Subject"
	uniform = /obj/item/clothing/under/color/white
	shoes = /obj/item/clothing/shoes/white
	head = /obj/item/clothing/head/helmet/facecover
	mask = /obj/item/clothing/mask/muzzle
	suit = /obj/item/clothing/suit/straight_jacket
	flags = OUTFIT_NO_SURVIVAL

/decl/hierarchy/outfit/blank_subject/post_equip(mob/living/carbon/human/H)
	..()
	var/obj/item/clothing/under/color/white/C = locate() in H
	if(C)
		C.has_sensor  = SUIT_LOCKED_SENSORS
		C.sensor_mode = SUIT_SENSOR_OFF

/mob/living/carbon/human/blank/New(new_loc)
	..(new_loc, SPECIES_VATGROWN)

/mob/living/carbon/human/blank/Initialize()
	. = ..()
	var/number = "[pick(possible_changeling_IDs)]-[rand(1,30)]"
	fully_replace_character_name("Subject [number]")
	var/decl/hierarchy/outfit/outfit = outfit_by_type(/decl/hierarchy/outfit/blank_subject)
	outfit.equip(src)
	var/obj/item/clothing/head/helmet/facecover/F = locate() in src
	if(F)
		F.SetName("[F.name] ([number])")

/mob/living/carbon/human/blank/ssd_check()
	return FALSE
