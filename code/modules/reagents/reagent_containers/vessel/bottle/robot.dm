
/obj/item/reagent_containers/vessel/bottle/chemical/robot
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = "5;10;15;25;30;50;100"
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	lid_state = LID_NONE
	volume = 60
	brittle = FALSE // No, for the love of god
	var/reagent = ""


/obj/item/reagent_containers/vessel/bottle/chemical/robot/inaprovaline
	name = "internal inaprovaline bottle"
	desc = "A small bottle. Contains inaprovaline - used to stabilize patients."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle-4"
	reagent = /datum/reagent/inaprovaline
	startswith = list(/datum/reagent/inaprovaline)

/obj/item/reagent_containers/vessel/bottle/chemical/robot/antitoxin
	name = "internal anti-toxin bottle"
	desc = "A small bottle of Anti-toxins. Counters poisons, and repairs damage, a wonder drug."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle-4"
	reagent = /datum/reagent/dylovene
	startswith = list(/datum/reagent/dylovene)
