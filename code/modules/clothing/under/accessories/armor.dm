//Pouches
/obj/item/clothing/accessory/storage/pouches
	name = "storage pouches"
	desc = "A collection of black pouches that can be attached to a plate carrier. Carries up to two items."
	icon = 'icons/obj/clothing/modular_armor.dmi'
	icon_state = "pouches"
	gender = PLURAL
	slot = ACCESSORY_SLOT_ARMOR_S
	slots = 2

/obj/item/clothing/accessory/storage/pouches/blue
	desc = "A collection of blue pouches that can be attached to a plate carrier. Carries up to two items."
	icon_state = "pouches_blue"

/obj/item/clothing/accessory/storage/pouches/navy
	desc = "A collection of navy blue pouches that can be attached to a plate carrier. Carries up to two items."
	icon_state = "pouches_navy"

/obj/item/clothing/accessory/storage/pouches/green
	desc = "A collection of green pouches that can be attached to a plate carrier. Carries up to two items."
	icon_state = "pouches_green"

/obj/item/clothing/accessory/storage/pouches/tan
	desc = "A collection of tan pouches that can be attached to a plate carrier. Carries up to two items."
	icon_state = "pouches_tan"

/obj/item/clothing/accessory/storage/pouches/large
	name = "large storage pouches"
	desc = "A collection of black pouches that can be attached to a plate carrier. Carries up to four items."
	icon_state = "lpouches"
	slots = 4
	slowdown = 1

/obj/item/clothing/accessory/storage/pouches/large/blue
	desc = "A collection of blue pouches that can be attached to a plate carrier. Carries up to four items."
	icon_state = "lpouches_blue"

/obj/item/clothing/accessory/storage/pouches/large/navy
	desc = "A collection of navy blue pouches that can be attached to a plate carrier. Carries up to four items."
	icon_state = "lpouches_navy"

/obj/item/clothing/accessory/storage/pouches/large/green
	desc = "A collection of green pouches that can be attached to a plate carrier. Carries up to four items."
	icon_state = "lpouches_green"

/obj/item/clothing/accessory/storage/pouches/large/tan
	desc = "A collection of tan pouches that can be attached to a plate carrier. Carries up to four items."
	icon_state = "lpouches_tan"

//Armor plates
/obj/item/clothing/accessory/armorplate
	name = "light armor plate"
	desc = "A basic armor plate made of steel-reinforced synthetic fibers. Attaches to a plate carrier."
	icon = 'icons/obj/clothing/modular_armor.dmi'
	icon_state = "armor_light"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	armor_type = /datum/armor/plate_light
	slot = ACCESSORY_SLOT_ARMOR_C

/datum/armor/plate_light
	bomb = 25
	bullet = 25
	energy = 10
	laser = 25
	melee = 25

/obj/item/clothing/accessory/armorplate/get_fibers()
	return null	//plates do not shed

/obj/item/clothing/accessory/armorplate/medium
	name = "medium armor plate"
	desc = "A plasteel-reinforced synthetic armor plate, providing good protection. Attaches to a plate carrier."
	icon_state = "armor_medium"
	armor_type = /datum/armor/plate_medium

/datum/armor/plate_medium
	bomb = 30
	bullet = 35
	energy = 15
	laser = 35
	melee = 35

/obj/item/clothing/accessory/armorplate/syndi
	name = "heavy armor plate"
	desc = "A ceramics-reinforced synthetic armor plate, providing state of of the art protection. Attaches to a plate carrier."
	icon_state = "armor_merc"
	armor_type = /datum/armor/plate_syndi
	slowdown = 1

/datum/armor/plate_syndi
	bomb = 40
	bullet = 60
	energy = 35
	laser = 60
	melee = 60

//Arm guards
/obj/item/clothing/accessory/armguards
	name = "arm guards"
	desc = "A pair of black arm pads reinforced with armor plating. Attaches to a plate carrier."
	icon = 'icons/obj/clothing/modular_armor.dmi'
	icon_state = "armguards"
	gender = PLURAL
	body_parts_covered = ARMS
	armor_type = /datum/armor/armguards
	slot = ACCESSORY_SLOT_ARMOR_A

/datum/armor/armguards
	bomb = 25
	bullet = 40
	energy = 15
	laser = 40
	melee = 40

/obj/item/clothing/accessory/armguards/blue
	desc = "A pair of blue arm pads reinforced with armor plating. Attaches to a plate carrier."
	icon_state = "armguards_blue"

/obj/item/clothing/accessory/armguards/navy
	desc = "A pair of navy blue arm pads reinforced with armor plating. Attaches to a plate carrier."
	icon_state = "armguards_navy"

/obj/item/clothing/accessory/armguards/green
	desc = "A pair of green arm pads reinforced with armor plating. Attaches to a plate carrier."
	icon_state = "armguards_green"

/obj/item/clothing/accessory/armguards/tan
	desc = "A pair of tan arm pads reinforced with armor plating. Attaches to a plate carrier."
	icon_state = "armguards_tan"

/obj/item/clothing/accessory/armguards/syndi
	name = "heavy arm guards"
	desc = "A pair of red-trimmed black arm pads reinforced with heavy armor plating. Attaches to a plate carrier."
	icon_state = "armguards_merc"
	armor_type = /datum/armor/armguards_syndi

/datum/armor/armguards_syndi
	bomb = 40
	bullet = 60
	energy = 40
	laser = 60
	melee = 60

/obj/item/clothing/accessory/armguards/riot
	name = "riot arm guards"
	desc = "A pair of armored arm pads with heavy padding to protect against melee attacks."
	icon_state = "armguards_riot"
	armor_type = /datum/armor/armguards_riot
	siemens_coefficient = 0.5

/datum/armor/armguards_riot
	bomb = 25
	bullet = 35
	energy = 15
	laser = 35
	melee = 80

/obj/item/clothing/accessory/armguards/ballistic
	name = "ballistic arm guards"
	desc = "A pair of armored arm pads with heavy plates to protect against ballistic projectiles."
	icon_state = "armguards_ballistic"
	armor_type = /datum/armor/armguards_ballistic
	siemens_coefficient = 0.7

/datum/armor/armguards_ballistic
	bomb = 25
	bullet = 85
	energy = 15
	laser = 35
	melee = 35

/obj/item/clothing/accessory/armguards/ablative
	name = "ablative arm guards"
	desc = "A pair of armored arm pads with advanced shielding to protect against energy weapons."
	icon_state = "armguards_ablative"
	armor_type = /datum/armor/armguards_ablative
	siemens_coefficient = 0

/datum/armor/armguards_ablative
	bullet = 35
	energy = 60
	laser = 85
	melee = 35

//Leg guards
/obj/item/clothing/accessory/legguards
	name = "leg guards"
	desc = "A pair of armored leg pads in black. Attaches to a plate carrier."
	icon = 'icons/obj/clothing/modular_armor.dmi'
	icon_state = "legguards"
	gender = PLURAL
	body_parts_covered = LEGS
	armor_type = /datum/armor/legguards
	slot = ACCESSORY_SLOT_ARMOR_L

/datum/armor/legguards
	bomb = 25
	bullet = 35
	energy = 15
	laser = 35
	melee = 35

/obj/item/clothing/accessory/legguards/blue
	desc = "A pair of armored leg pads in blue. Attaches to a plate carrier."
	icon_state = "legguards_blue"

/obj/item/clothing/accessory/legguards/navy
	desc = "A pair of armored leg pads in navy blue. Attaches to a plate carrier."
	icon_state = "legguards_navy"

/obj/item/clothing/accessory/legguards/green
	desc = "A pair of armored leg pads in green. Attaches to a plate carrier."
	icon_state = "legguards_green"

/obj/item/clothing/accessory/legguards/tan
	desc = "A pair of armored leg pads in tan. Attaches to a plate carrier."
	icon_state = "legguards_tan"

/obj/item/clothing/accessory/legguards/syndi
	name = "heavy leg guards"
	desc = "A pair of heavily armored leg pads in red-trimmed black. Attaches to a plate carrier."
	icon_state = "legguards_merc"
	armor_type = /datum/armor/legguards_syndi

/datum/armor/legguards_syndi
	bomb = 40
	bullet = 60
	energy = 35
	laser = 60
	melee = 60

/obj/item/clothing/accessory/legguards/riot
	name = "riot leg guards"
	desc = "A pair of armored leg pads with heavy padding to protect against melee attacks. Looks like they might impair movement."
	icon_state = "legguards_riot"
	armor_type = /datum/armor/legguards_riot
	siemens_coefficient = 0.5
	slowdown = 1

/datum/armor/legguards_riot
	bomb = 25
	bullet = 35
	energy = 15
	laser = 35
	melee = 35

/obj/item/clothing/accessory/legguards/ballistic
	name = "ballistic leg guards"
	desc = "A pair of armored leg pads with heavy plates to protect against ballistic projectiles. Looks like they might impair movement."
	icon_state = "legguards_ballistic"
	armor_type = /datum/armor/legguards_ballistic
	siemens_coefficient = 0.7
	slowdown = 1

/datum/armor/legguards_ballistic
	bomb = 25
	bullet = 85
	energy = 15
	laser = 35
	melee = 35

/obj/item/clothing/accessory/legguards/ablative
	name = "ablative leg guards"
	desc = "A pair of armored leg pads with advanced shielding to protect against energy weapons. Looks like they might impair movement."
	icon_state = "legguards_ablative"
	armor_type = /datum/armor/legguards_ablative
	siemens_coefficient = 0
	slowdown = 1

/datum/armor/legguards_ablative
	bomb = 25
	bullet = 35
	energy = 60
	laser = 85
	melee = 35

//Decorative attachments
/obj/item/clothing/accessory/armor/tag
	name = "master armor tag"
	desc = "A collection of various tags for placing on the front of a plate carrier."
	icon = 'icons/obj/clothing/modular_armor.dmi'
	icon_state = "null"
	slot = ACCESSORY_SLOT_ARMOR_M

/obj/item/clothing/accessory/armor/tag/nt
	name = "\improper NT SECURITY tag"
	desc = "An armor tag with the words NT SECURITY printed in red lettering on it."
	icon_state = "nanotag"

/obj/item/clothing/accessory/armor/tag/press
	name = "\improper PRESS tag"
	desc = "A tag with the word PRESS printed in white lettering on it."
	icon_state = "presstag"
	slot_flags = SLOT_BELT

/obj/item/clothing/accessory/armor/tag/opos
	name = "\improper O+ blood patch"
	desc = "An embroidered patch indicating the wearer's blood type as O POSITIVE."
	icon_state = "opostag"

/obj/item/clothing/accessory/armor/tag/oneg
	name = "\improper O- blood patch"
	desc = "An embroidered patch indicating the wearer's blood type as O NEGATIVE."
	icon_state = "onegtag"

/obj/item/clothing/accessory/armor/tag/apos
	name = "\improper A+ blood patch"
	desc = "An embroidered patch indicating the wearer's blood type as A POSITIVE."
	icon_state = "apostag"

/obj/item/clothing/accessory/armor/tag/aneg
	name = "\improper A- blood patch"
	desc = "An embroidered patch indicating the wearer's blood type as A NEGATIVE."
	icon_state = "anegtag"

/obj/item/clothing/accessory/armor/tag/bpos
	name = "\improper B+ blood patch"
	desc = "An embroidered patch indicating the wearer's blood type as B POSITIVE."
	icon_state = "bpostag"

/obj/item/clothing/accessory/armor/tag/bneg
	name = "\improper B- blood patch"
	desc = "An embroidered patch indicating the wearer's blood type as B NEGATIVE."
	icon_state = "bnegtag"

/obj/item/clothing/accessory/armor/tag/abpos
	name = "\improper AB+ blood patch"
	desc = "An embroidered patch indicating the wearer's blood type as AB POSITIVE."
	icon_state = "abpostag"

/obj/item/clothing/accessory/armor/tag/abneg
	name = "\improper AB- blood patch"
	desc = "An embroidered patch indicating the wearer's blood type as AB NEGATIVE."
	icon_state = "abnegtag"

/obj/item/clothing/accessory/armor/helmcover
	name = "helmet cover"
	desc = "A fabric cover for armored helmets."
	icon = 'icons/obj/clothing/modular_armor.dmi'
	icon_state = "null"
	slot = ACCESSORY_SLOT_HELM_C

/obj/item/clothing/accessory/armor/helmcover/blue
	name = "blue helmet cover"
	desc = "A fabric cover for armored helmets in a bright blue color."
	icon_state = "helmcover_blue"

/obj/item/clothing/accessory/armor/helmcover/navy
	name = "navy blue helmet cover"
	desc = "A fabric cover for armored helmets. This one is colored navy blue."
	icon_state = "helmcover_navy"

/obj/item/clothing/accessory/armor/helmcover/green
	name = "green helmet cover"
	desc = "A fabric cover for armored helmets. This one has a woodland camouflage pattern."
	icon_state = "helmcover_green"

/obj/item/clothing/accessory/armor/helmcover/tan
	name = "tan helmet cover"
	desc = "A fabric cover for armored helmets. This one has a desert camouflage pattern."
	icon_state = "helmcover_tan"

/obj/item/clothing/accessory/armor/helmcover/nt
	name = "\improper NanoTrasen helmet cover"
	desc = "A fabric cover for armored helmets. This one has NanoTrasen's colors."
	icon_state = "helmcover_nt"
