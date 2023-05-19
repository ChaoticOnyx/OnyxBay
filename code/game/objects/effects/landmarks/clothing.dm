// Costume spawner landmarks.
/obj/effect/landmark/costume
	icon_state = "landmark_outfit"
	delete_after = TRUE

// Costume spawner, selects a random subclass and disappears
/obj/effect/landmark/costume/New()
	var/list/options = typesof(/obj/effect/landmark/costume)
	var/PICK = options[rand(1, length(options))]
	new PICK(loc)

// SUBCLASSES. Spawn a bunch of items and disappear likewise.
/obj/effect/landmark/costume/chameleon/New()
	new /obj/item/clothing/mask/chameleon(loc)
	new /obj/item/clothing/under/chameleon(loc)
	new /obj/item/clothing/glasses/chameleon(loc)
	new /obj/item/clothing/shoes/chameleon(loc)
	new /obj/item/clothing/gloves/chameleon(loc)
	new /obj/item/clothing/suit/chameleon(loc)
	new /obj/item/clothing/head/chameleon(loc)
	new /obj/item/storage/backpack/chameleon(loc)

/obj/effect/landmark/costume/gladiator/New()
	new /obj/item/clothing/under/gladiator(loc)
	new /obj/item/clothing/head/helmet/gladiator(loc)

/obj/effect/landmark/costume/madscientist/New()
	new /obj/item/clothing/under/gimmick/rank/captain/suit(loc)
	new /obj/item/clothing/head/flatcap(loc)
	new /obj/item/clothing/suit/storage/toggle/labcoat/mad(loc)
	new /obj/item/clothing/glasses/gglasses(loc)

/obj/effect/landmark/costume/elpresidente/New()
	new /obj/item/clothing/under/gimmick/rank/captain/suit(loc)
	new /obj/item/clothing/head/flatcap(loc)
	new /obj/item/clothing/mask/smokable/cigarette/cigar/havana(loc)
	new /obj/item/clothing/shoes/jackboots(loc)

/obj/effect/landmark/costume/nyangirl/New()
	new /obj/item/clothing/under/schoolgirl(loc)
	new /obj/item/clothing/head/kitty(loc)

/obj/effect/landmark/costume/maid/New()
	new /obj/item/clothing/under/blackskirt(loc)
	new /obj/item/clothing/glasses/sunglasses/blindfold(loc)

	var/CHOICE = pick(/obj/item/clothing/head/beret, /obj/item/clothing/head/rabbitears)
	new CHOICE(loc)

/obj/effect/landmark/costume/butler/New()
	new /obj/item/clothing/accessory/wcoat(loc)
	new /obj/item/clothing/under/suit_jacket(loc)
	new /obj/item/clothing/head/that(loc)

/obj/effect/landmark/costume/scratch/New()
	new /obj/item/clothing/gloves/white(loc)
	new /obj/item/clothing/shoes/white(loc)
	new /obj/item/clothing/under/scratch(loc)

	if(prob(30))
		new /obj/item/clothing/head/cueball(loc)

/obj/effect/landmark/costume/prig/New()
	new /obj/item/clothing/accessory/wcoat(loc)
	new /obj/item/clothing/glasses/monocle(loc)
	new /obj/item/clothing/shoes/black(loc)
	new /obj/item/cane(loc)
	new /obj/item/clothing/under/sl_suit(loc)
	new /obj/item/clothing/mask/fakemoustache(loc)

	var/CHOICE = pick(/obj/item/clothing/head/bowler, /obj/item/clothing/head/that)
	new CHOICE(loc)

/obj/effect/landmark/costume/plaguedoctor/New()
	new /obj/item/clothing/suit/bio_suit/plaguedoctorsuit(loc)
	new /obj/item/clothing/head/plaguedoctorhat(loc)

/obj/effect/landmark/costume/nightowl/New()
	new /obj/item/clothing/under/owl(loc)
	new /obj/item/clothing/mask/gas/owl_mask(loc)

/obj/effect/landmark/costume/waiter/New()
	new /obj/item/clothing/under/waiter(loc)
	new /obj/item/clothing/suit/apron(loc)

	var/CHOICE = pick(/obj/item/clothing/head/kitty, /obj/item/clothing/head/rabbitears)
	new CHOICE(loc)

/obj/effect/landmark/costume/pirate/New()
	new /obj/item/clothing/under/pirate(loc)
	new /obj/item/clothing/suit/pirate(loc)
	new /obj/item/clothing/glasses/eyepatch(loc)

	var/CHOICE = pick(/obj/item/clothing/head/pirate , /obj/item/clothing/mask/bandana/red)
	new CHOICE(loc)

/obj/effect/landmark/costume/commie/New()
	new /obj/item/clothing/under/soviet(loc)
	new /obj/item/clothing/head/ushanka(loc)

/obj/effect/landmark/costume/imperium_monk/New()
	new /obj/item/clothing/suit/imperium_monk(loc)

	if(prob(25))
		new /obj/item/clothing/mask/gas/cyborg(loc)

/obj/effect/landmark/costume/holiday_priest/New()
	new /obj/item/clothing/suit/holidaypriest(loc)

/obj/effect/landmark/costume/marisawizard/fake/New()
	new /obj/item/clothing/head/wizard/marisa/fake(loc)
	new /obj/item/clothing/suit/wizrobe/marisa/fake(loc)

/obj/effect/landmark/costume/cutewitch/New()
	new /obj/item/clothing/under/sundress(loc)
	new /obj/item/clothing/head/witchwig(loc)
	new /obj/item/staff/broom(loc)

/obj/effect/landmark/costume/fakewizard/New()
	new /obj/item/clothing/suit/wizrobe/fake(loc)
	new /obj/item/clothing/head/wizard/fake(loc)
	new /obj/item/staff/(loc)

/obj/effect/landmark/costume/sexyclown/New()
	new /obj/item/clothing/mask/gas/sexyclown(loc)
	new /obj/item/clothing/under/sexyclown(loc)

/obj/effect/landmark/costume/sexymime/New()
	new /obj/item/clothing/mask/gas/sexymime(loc)
	new /obj/item/clothing/under/sexymime(loc)

