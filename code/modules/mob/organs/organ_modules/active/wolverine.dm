/obj/item/melee/implant/claws
	name = "claws"
	desc = "A set of claws deployed from the tips of your fingers. Great for cutting people into ribbons."
	icon_state = "wolverine"
	icon = 'icons/obj/implants.dmi'
	item_state = "wolverine"
	sharp = TRUE
	edge = TRUE
	hitsound = 'sound/weapons/bladeslice.ogg'
	force = 25
	mod_weight = 0.8
	mod_reach = 1.2
	mod_handy = 1.5
	armor_penetration = 45
	attack_verb = list("ripped", "torn", "cut")

/obj/item/organ_module/active/simple/wolverine
	name = "embedded claws"
	desc = "A variant on the popular armblade. These claws allow for a more traditional unarmed brawl style while still maintaining your advantage."
	action_button_name = "Deploy embedded claws"
	icon_state = "wolverine"
	allowed_organs = list(BP_L_HAND, BP_R_HAND)
	holding_type = /obj/item/melee/implant/claws
	matter = list(
		MATERIAL_PLASTIC = 2000,
		MATERIAL_PLATINUM = 3000,
		MATERIAL_GOLD = 1500
	)
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
	available_in_charsetup = TRUE
	origin_tech = list(TECH_COMBAT = 4, TECH_ENGINEERING = 3)
	allowed_roles = list(/datum/job/hos, /datum/job/captain)
	loadout_cost = 0
	augment_cost = 4
	cpu_load = 2
	w_class = 2
