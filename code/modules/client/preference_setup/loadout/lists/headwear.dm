/datum/gear/head
	sort_category = "Hats"
	slot = slot_head

/datum/gear/head/beret
	display_name = "beret, colour select"
	path = /obj/item/clothing/head/beret/plaincolor
	flags = GEAR_HAS_COLOR_SELECTION
	description = "A simple, solid color beret. This one has no emblems or insignia on it."

/datum/gear/head/whitentberet
	display_name = "beret, NanoTrasen security"
	path = /obj/item/clothing/head/beret/guard

/datum/gear/head/bandana
	display_name = "bandana selection"
	path = /obj/item/clothing

/datum/gear/head/bandana/New()
	..()
	gear_tweaks += new /datum/gear_tweak/path/specified_types_list(typesof(/obj/item/clothing/mask/bandana) + typesof(/obj/item/clothing/head/bandana))

/datum/gear/head/bow
	display_name = "hair bow, colour select"
	path = /obj/item/clothing/head/hairflower/bow
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/head/cap
	display_name = "cap selection"
	path = /obj/item/clothing/head
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/head/cap/New()
	..()
	var/caps = list()
	caps["cap"] = /obj/item/clothing/head/soft/black
	caps["flat cap"] = /obj/item/clothing/head/flatcap
	caps["mailman cap"] = /obj/item/clothing/head/mailman
	caps["rainbow cap"] = /obj/item/clothing/head/soft/rainbow
	caps["white cap"] = /obj/item/clothing/head/soft/mime
	caps["major bill's shipping cap"] = /obj/item/clothing/head/soft/mbill
	gear_tweaks += new /datum/gear_tweak/path(caps)

/datum/gear/head/hairflower
	display_name = "hair flower pin"
	path = /obj/item/clothing/head/hairflower

/datum/gear/head/hairflower/New()
	..()
	var/pins = list()
	pins["blue pin"] = /obj/item/clothing/head/hairflower/blue
	pins["pink pin"] = /obj/item/clothing/head/hairflower/pink
	pins["red pin"] = /obj/item/clothing/head/hairflower
	pins["yellow pin"] = /obj/item/clothing/head/hairflower/yellow
	pins["white pin"] = /obj/item/clothing/head/hairflower/white
	pins["purple pin"] = /obj/item/clothing/head/hairflower/purple
	gear_tweaks += new /datum/gear_tweak/path(pins)

/datum/gear/head/hardhat
	display_name = "hardhat selection"
	path = /obj/item/clothing/head/hardhat
	cost = 2
	allowed_roles = TECHNICAL_ROLES

/datum/gear/head/hardhat/New()
	..()
	var/hardhats = list()
	hardhats["blue hardhat"] = /obj/item/clothing/head/hardhat/dblue
	hardhats["orange hardhat"] = /obj/item/clothing/head/hardhat/orange
	hardhats["red hardhat"] = /obj/item/clothing/head/hardhat/red
	hardhats["yellow hardhat"] = /obj/item/clothing/head/hardhat
	gear_tweaks += new /datum/gear_tweak/path(hardhats)

/datum/gear/head/formalhat
	display_name = "formal hat selection"
	path = /obj/item/clothing/head

/datum/gear/head/formalhat/New()
	..()
	var/formalhats = list()
	formalhats["boatsman hat"] = /obj/item/clothing/head/boaterhat
	formalhats["bowler hat"] = /obj/item/clothing/head/bowler
	formalhats["fedora"] = /obj/item/clothing/head/fedora //m'lady
	formalhats["feather trilby"] = /obj/item/clothing/head/feathertrilby
	formalhats["fez"] = /obj/item/clothing/head/fez
	formalhats["top hat"] = /obj/item/clothing/head/that
	formalhats["fedora, brown"] = /obj/item/clothing/head/det
	formalhats["fedora, grey"] = /obj/item/clothing/head/det/grey
	gear_tweaks += new /datum/gear_tweak/path(formalhats)

/datum/gear/head/informalhat
	display_name = "informal hat selection"
	path = /obj/item/clothing/head

/datum/gear/head/informalhat/New()
	..()
	var/informalhats = list()
	informalhats["cowboy hat"] = /obj/item/clothing/head/cowboy_hat
	informalhats["ushanka"] = /obj/item/clothing/head/ushanka
	informalhats["TCC ushanka"] = /obj/item/clothing/head/ushanka/tcc
	gear_tweaks += new /datum/gear_tweak/path(informalhats)

/datum/gear/head/hijab
	display_name = "hijab, colour select"
	path = /obj/item/clothing/head/hijab
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/head/kippa
	display_name = "kippa, colour select"
	path = /obj/item/clothing/head/kippa
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/head/turban
	display_name = "turban, colour select"
	path = /obj/item/clothing/head/turban
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/head/taqiyah
	display_name = "taqiyah, colour select"
	path = /obj/item/clothing/head/taqiyah
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/head/surgical
	display_name = "standard surgical caps"
	path = /obj/item/clothing/head/surgery
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/head/surgical/custom
	display_name = "surgical cap, colour select"
	flags = GEAR_HAS_COLOR_SELECTION

//
// Donator's shop
//

/datum/gear/head/kitty
	display_name = "kitty ears"
	path = /obj/item/clothing/head/kitty
	price = 20

/datum/gear/head/wizard_fake
	display_name = "wizard hat"
	path = /obj/item/clothing/head/wizard/fake
	price = 30

/datum/gear/head/marisa_wizard_fake
	display_name = "marisa wizard hat"
	path = /obj/item/clothing/head/wizard/marisa/fake
	price = 30

/datum/gear/head/witchwig
	display_name = "witchwig"
	path = /obj/item/clothing/head/witchwig
	price = 30

/datum/gear/head/bearpelt
	display_name = "bearpelt"
	path = /obj/item/clothing/head/bearpelt
	price = 30

/datum/gear/head/rabbitears
	display_name = "rabbit ears"
	path = /obj/item/clothing/head/rabbitears
	price = 16

/datum/gear/head/festive
	display_name = "festive hat"
	path = /obj/item/clothing/head/festive
	price = 2

/datum/gear/head/petehat
	display_name = "pete hat"
	path = /obj/item/clothing/head/collectable/petehat
	price = 5

/datum/gear/head/cardborg
	display_name = "cardborg hat"
	path = /obj/item/clothing/head/cardborg
	price = 5

/datum/gear/head/pirate
	display_name = "pirate cap"
	path = /obj/item/clothing/head/pirate
	price = 10

/datum/gear/head/plaguedoctorhat
	display_name = "plague doctor hat"
	path = /obj/item/clothing/head/plaguedoctorhat
	price = 10

/datum/gear/head/sombrero
	display_name = "sombrero"
	path = /obj/item/clothing/head/sombrero
	price = 5

/datum/gear/head/chicken
	display_name = "chicken head"
	path = /obj/item/clothing/head/chicken
	price = 18

/datum/gear/head/rasta
	display_name = "rasta hat"
	path = /obj/item/clothing/head/rasta
	price = 10

/datum/gear/head/richard
	display_name = "cock head"
	path = /obj/item/clothing/head/richard
	price = 20

/datum/gear/head/pumpkinhead
	display_name = "pumpkin head"
	path = /obj/item/clothing/head/pumpkinhead
	price = 12

/datum/gear/head/capcap_alt
	display_name = "captain's cap"
	path = /obj/item/clothing/head/caphat/cap/capcap_alt
	price = 10
	allowed_roles = list(/datum/job/captain)
