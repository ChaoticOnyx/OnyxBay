/obj/item/clothing/under/syndicate
	name = "tactical turtleneck"
	desc = "It's some non-descript, slightly suspicious looking, civilian clothing."
	icon_state = "syndicate"
	item_state = "bl_suit"
	worn_state = "syndicate"
	has_sensor = 0
	armor = list(melee = 5, bullet = 5, laser = 5, energy = 0, bomb = 0, bio = 0)
	siemens_coefficient = 0.9

/obj/item/clothing/under/syndicate/combat
	name = "combat turtleneck"
	desc = "The height of fashion and tactical utility."
	icon_state = "combat"
	item_state = "bl_suit"
	worn_state = "combat"
	has_sensor = SUIT_HAS_SENSORS
	armor = list(melee = 20, bullet = 20, laser = 10, energy = 0, bomb = 0, bio = 0)

/obj/item/clothing/under/syndicate/tacticool
	name = "\improper Tacticool turtleneck"
	desc = "Just looking at it makes you want to buy an SKS, go into the woods, and -operate-."
	icon_state = "tactifool"
	item_state = "bl_suit"
	worn_state = "tactifool"
	armor = list(melee = 5, bullet = -20, laser = 5, energy = 0, bomb = 0, bio = 0) // Getting shot despite being tacticool hurts on a different level
	siemens_coefficient = 1
	has_sensor = SUIT_HAS_SENSORS
