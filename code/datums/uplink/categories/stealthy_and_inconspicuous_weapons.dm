/*************************************
* Stealthy and Inconspicuous Weapons *
*************************************/
/datum/uplink_item/item/stealthy_weapons
	category = /datum/uplink_category/stealthy_weapons

/datum/uplink_item/item/stealthy_weapons/soap
	name = "Subversive Soap"
	desc = "Useful for hiding murder and slipping vigilantes."
	item_cost = 1
	path = /obj/item/soap/syndie

/datum/uplink_item/item/stealthy_weapons/cigarette_kit
	name = "Syndicate Smokes"
	desc = "Contains the following packs of cigarettes: 2x Flash, 2x Smoke, 1x MindBreaker, 1x Tricordrazine."
	item_cost = 1
	path = /obj/item/storage/box/syndie_kit/cigarette

/datum/uplink_item/item/stealthy_weapons/concealed_cane
	name = "Concealed Cane Sword"
	desc = "A cane. With a hidden stiletto."
	item_cost = 2
	path = /obj/item/cane/concealed

/datum/uplink_item/item/stealthy_weapons/random_toxin
	name = "Random Toxin Kit"
	desc = "Contains a syringe and a vial with a random potent (but not necessarily deadly) poison."
	item_cost = 2
	path = /obj/item/storage/box/syndie_kit/toxin

/datum/uplink_item/item/stealthy_weapons/detomatix
	name = "Detomatix PDA Cartridge"
	desc = "Allows you to remotely detonate up to 4 PDAs."
	item_cost = 2
	path = /obj/item/cartridge/syndicate

/datum/uplink_item/item/stealthy_weapons/syringegun
	name = "Disguised Syringe Gun"
	desc = "A tiny syringe gun, disguised as a pen."
	item_cost = 3
	path = /obj/item/storage/box/syndie_kit/syringegun

/datum/uplink_item/item/stealthy_weapons/robust_gloves
	name = "Robust Chameleon Gloves"
	desc = "This pair of chameleon gloves drastically increases their wearer's unarmed combat abilities."
	item_cost = 4
	antag_costs = list(MODE_NUKE = 2)
	path = /obj/item/clothing/gloves/chameleon/robust

/datum/uplink_item/item/stealthy_weapons/sleepy
	name = "Sleepy Pen"
	desc = "Puts your target to sleep."
	item_cost = 5
	path = /obj/item/pen/reagent/sleepy

/datum/uplink_item/item/stealthy_weapons/paralytic
	name = "Paralytic Pen"
	desc = "Completely disables your target, but keeps them awake."
	item_cost = 5
	path = /obj/item/pen/reagent/paralytic

/datum/uplink_item/item/stealthy_weapons/energy_dagger
	name = "Energy Dagger"
	desc = "Energy sword's little brother. Acts just like a regular pen when you don't feel like slicing and dicing people."
	item_cost = 5
	antag_costs = list(MODE_NUKE = 3)
	path = /obj/item/pen/energy_dagger