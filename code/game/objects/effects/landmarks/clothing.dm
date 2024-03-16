// Costume spawner landmarks.
/obj/effect/landmark/costume
	icon_state = "landmark_outfit"
	delete_after = TRUE

	/// Associative list of typepath | list(typepath) -> value. If value is `null` or `100` atom has 100% chance of spawn.
	var/list/spawn_paths

/obj/effect/landmark/costume/Initialize()
	. = ..()

	for(var/typepath as anything in spawn_paths)
		var/chance = LAZYACCESS(spawn_paths, typepath)

		if(!isnull(chance) && !prob(chance))
			continue

		if(islist(typepath))
			typepath = pick(typepath)

		new typepath(loc)

/obj/effect/landmark/costume/chameleon
	spawn_paths = list(
		/obj/item/clothing/mask/chameleon,
		/obj/item/clothing/under/chameleon,
		/obj/item/clothing/glasses/chameleon,
		/obj/item/clothing/shoes/chameleon,
		/obj/item/clothing/gloves/chameleon,
		/obj/item/clothing/suit/chameleon,
		/obj/item/clothing/head/chameleon,
		/obj/item/storage/backpack/chameleon,
	)

/obj/effect/landmark/costume/gladiator
	spawn_paths = list(
		/obj/item/clothing/under/gladiator,
		/obj/item/clothing/head/helmet/gladiator,
	)

/obj/effect/landmark/costume/madscientist
	spawn_paths = list(
		/obj/item/clothing/under/gimmick/rank/captain/suit,
		/obj/item/clothing/head/flatcap,
		/obj/item/clothing/suit/storage/toggle/labcoat/mad,
		/obj/item/clothing/glasses/gglasses,
	)

/obj/effect/landmark/costume/elpresidente
	spawn_paths = list(
		/obj/item/clothing/under/gimmick/rank/captain/suit,
		/obj/item/clothing/head/flatcap,
		/obj/item/clothing/mask/smokable/cigarette/cigar/havana,
		/obj/item/clothing/shoes/jackboots,
	)

/obj/effect/landmark/costume/nyangirl
	spawn_paths = list(
		/obj/item/clothing/under/schoolgirl,
		/obj/item/clothing/head/kitty,
	)

/obj/effect/landmark/costume/maid
	spawn_paths = list(
		/obj/item/clothing/under/blackskirt,
		/obj/item/clothing/glasses/sunglasses/blindfold,
		list(/obj/item/clothing/head/beret, /obj/item/clothing/head/rabbitears),
	)

/obj/effect/landmark/costume/butler
	spawn_paths = list(
		/obj/item/clothing/accessory/wcoat,
		/obj/item/clothing/under/suit_jacket,
		/obj/item/clothing/head/that,
	)

/obj/effect/landmark/costume/scratch
	spawn_paths = list(
		/obj/item/clothing/gloves/white,
		/obj/item/clothing/shoes/white,
		/obj/item/clothing/under/scratch,
		/obj/item/clothing/head/cueball = 30,
	)

/obj/effect/landmark/costume/prig
	spawn_paths = list(
		/obj/item/clothing/accessory/wcoat,
		/obj/item/clothing/glasses/monocle,
		/obj/item/clothing/shoes/black,
		/obj/item/cane,
		/obj/item/clothing/under/sl_suit,
		/obj/item/clothing/mask/fakemoustache,
		list(/obj/item/clothing/head/bowler, /obj/item/clothing/head/that),
	)

/obj/effect/landmark/costume/plaguedoctor
	spawn_paths = list(
		/obj/item/clothing/suit/bio_suit/plaguedoctorsuit,
		/obj/item/clothing/head/plaguedoctorhat,
	)

/obj/effect/landmark/costume/nightowl
	spawn_paths = list(
		/obj/item/clothing/under/owl,
		/obj/item/clothing/mask/gas/owl_mask,
	)

/obj/effect/landmark/costume/waiter
	spawn_paths = list(
		/obj/item/clothing/under/waiter,
		/obj/item/clothing/suit/apron,
		list(/obj/item/clothing/head/kitty, /obj/item/clothing/head/rabbitears),
	)


/obj/effect/landmark/costume/pirate
	spawn_paths = list(
		/obj/item/clothing/under/pirate,
		/obj/item/clothing/suit/pirate,
		/obj/item/clothing/glasses/eyepatch,
		list(/obj/item/clothing/head/pirate , /obj/item/clothing/mask/bandana/red),
	)


/obj/effect/landmark/costume/commie
	spawn_paths = list(
		/obj/item/clothing/under/soviet,
		/obj/item/clothing/head/ushanka,
	)

/obj/effect/landmark/costume/imperium_monk
	spawn_paths = list(
		/obj/item/clothing/suit/imperium_monk,
		/obj/item/clothing/mask/gas/cyborg = 25,
	)

/obj/effect/landmark/costume/holiday_priest
	spawn_paths = list(
		/obj/item/clothing/suit/holidaypriest,
	)

/obj/effect/landmark/costume/marisawizard/fake
	spawn_paths = list(
		/obj/item/clothing/head/wizard/marisa/fake,
		/obj/item/clothing/suit/wizrobe/marisa/fake,
	)

/obj/effect/landmark/costume/cutewitch
	spawn_paths = list(
		/obj/item/clothing/under/sundress,
		/obj/item/clothing/head/witchwig,
		/obj/item/staff/broom,
	)

/obj/effect/landmark/costume/fakewizard
	spawn_paths = list(
		/obj/item/clothing/suit/wizrobe/fake,
		/obj/item/clothing/head/wizard/fake,
		/obj/item/staff,
	)

/obj/effect/landmark/costume/sexyclown
	spawn_paths = list(
		/obj/item/clothing/mask/gas/sexyclown,
		/obj/item/clothing/under/sexyclown,
	)

/obj/effect/landmark/costume/sexymime
	spawn_paths = list(
		/obj/item/clothing/mask/gas/sexymime,
		/obj/item/clothing/under/sexymime,
	)

/obj/effect/landmark/costume/random
	icon_state = "landmark_outfitrand"

/obj/effect/landmark/costume/random/Initialize()
	. = ..()

	var/list/paths = subtypesof(/obj/effect/landmark/costume) - /obj/effect/landmark/costume/random
	var/chosen_path = pick(paths)
	new chosen_path(loc)
