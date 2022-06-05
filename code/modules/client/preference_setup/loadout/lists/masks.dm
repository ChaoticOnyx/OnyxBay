
/datum/gear/mask
	sort_category = "Masks"
	slot = slot_wear_mask

/datum/gear/mask/surgical
	display_name = "sterile mask"
	path = /obj/item/clothing/mask/surgical
	cost = 2

/datum/gear/mask/scarf
	display_name ="neck scarf"
	path = /obj/item/clothing/mask/bluescarf

/datum/gear/mask/scarf/New()
	..()
	var/scarfs = list()
	scarfs["blue scarf"] = /obj/item/clothing/mask/bluescarf
	scarfs["green scarf"] = /obj/item/clothing/mask/greenscarf
	scarfs["red scarf"] = /obj/item/clothing/mask/redscarf
	scarfs["red white scarf"] = /obj/item/clothing/mask/redwscarf
	scarfs["ninja scarf"] = /obj/item/clothing/mask/ninjascarf
	scarfs["stripped blue scarf"] = /obj/item/clothing/mask/sbluescarf
	scarfs["stripped green scarf"] = /obj/item/clothing/mask/sgreenscarf
	scarfs["stipped red scarf"] = /obj/item/clothing/mask/sredscarf
	gear_tweaks += new /datum/gear_tweak/path(scarfs)

//
// Donator's shop
//

/datum/gear/mask/fakemoustache
	display_name = "fake moustache"
	path = /obj/item/clothing/mask/fakemoustache
	price = 5

/datum/gear/mask/horsehead
	display_name = "horse head"
	path = /obj/item/clothing/mask/horsehead
	price = 12

/datum/gear/mask/pig
	display_name = "pig head"
	path = /obj/item/clothing/mask/pig
	price = 12

/datum/gear/mask/skullmask
	display_name = "skullmask"
	path = /obj/item/clothing/mask/skullmask
	price = 10

/datum/gear/mask/plaguedoctor
	display_name = "plaguedoctor mask"
	path = /obj/item/clothing/mask/gas/plaguedoctor
	price = 20

/datum/gear/mask/monkeymask
	display_name = "monkey mask"
	path = /obj/item/clothing/mask/gas/monkeymask
	price = 15

/datum/gear/mask/owl_mask
	display_name = "owl mask"
	path = /obj/item/clothing/mask/gas/owl_mask
	price = 15

/datum/gear/mask/tecnicos
	display_name = "tecnicos mask"
	path = /obj/item/clothing/mask/luchador/tecnicos
	price = 5

/datum/gear/mask/luchador
	display_name = "luchador mask"
	path = /obj/item/clothing/mask/luchador
	price = 5

/datum/gear/mask/rudos
	display_name = "rudos mask"
	path = /obj/item/clothing/mask/luchador/rudos
	price = 5

/datum/gear/mask/sexymime
	display_name = "sexy mime mask"
	path = /obj/item/clothing/mask/gas/sexymime
	price = 17

/datum/gear/mask/sexyclown
	display_name = "sexy-clown mask"
	path = /obj/item/clothing/mask/gas/sexyclown
	price = 17

/datum/gear/mask/snorkel
	display_name = "snorkel"
	path = /obj/item/clothing/mask/snorkel
	price = 5

/datum/gear/mask/ballgag
	display_name = "ballgag"
	path = /obj/item/clothing/mask/muzzle/ballgag
	price = 20

/datum/gear/mask/trasen
	display_name = "trasen mask"
	path = /obj/item/clothing/mask/rubber/trasen
	price = 10

/datum/gear/mask/barros
	display_name = "barros mask"
	path = /obj/item/clothing/mask/rubber/barros
	price = 10

/datum/gear/mask/admiral
	display_name = "admiral mask"
	path = /obj/item/clothing/mask/rubber/admiral
	price = 10

/datum/gear/mask/turner
	display_name = "turner mask"
	path = /obj/item/clothing/mask/rubber/turner
	price = 10

/datum/gear/mask/skrell
	display_name = "skrell mask"
	path = /obj/item/clothing/mask/rubber/species/skrell
	price = 20

/datum/gear/mask/human
	display_name = "human mask"
	path = /obj/item/clothing/mask/rubber/species
	price = 10

/datum/gear/mask/unathi
	display_name = "unathi mask"
	path = /obj/item/clothing/mask/rubber/species/unathi
	price = 20

/datum/gear/mask/tajaran
	display_name = "tajara mask"
	path = /obj/item/clothing/mask/rubber/species/tajaran
	price = 20

/datum/gear/mask/spirit
	display_name = "spirit mask"
	path = /obj/item/clothing/mask/spirit
	price = 10

/datum/gear/mask/balaclava
	display_name = "balaclava"
	path = /obj/item/clothing/mask/balaclava
	price = 25
