//Contains the target item datums for Steal objectives.

/datum/objective_item
	var/name = "A silly bike horn! Honk!"
	var/targetitem = /obj/item/weapon/bikehorn		//typepath of the objective item
	var/difficulty = 9001							//vaguely how hard it is to do this objective
	var/list/excludefromjob = list()				//If you don't want a job to get a certain objective (no captain stealing his own medal, etcetc)
	var/list/altitems = list()				//Items which can serve as an alternative to the objective (darn you blueprints)
	var/list/special_equipment = list()

/datum/objective_item/proc/check_special_completion() //for objectives with special checks (is that slime extract unused? does that intellicard have an ai in it? etcetc)
	return 1

/datum/objective_item/proc/TargetExists()
	return TRUE

/datum/objective_item/steal/New()
	..()
	if(TargetExists())
		GLOB.possible_items += src
	else
		qdel(src)

/datum/objective_item/steal/Destroy()
	GLOB.possible_items -= src
	return ..()

/datum/objective_item/steal/caplaser
	name = "the captain's antique laser gun."
	targetitem = /obj/item/weapon/gun/energy/captain
	difficulty = 5
	excludefromjob = list("Captain")

/datum/objective_item/steal/handtele
	name = "a hand teleporter."
	targetitem = /obj/prefab/hand_teleporter
	difficulty = 5
	excludefromjob = list("Captain", "Research Director")

/datum/objective_item/steal/hypo
	name = "the hypospray."
	targetitem = /obj/item/weapon/reagent_containers/hypospray/vial
	difficulty = 5
	excludefromjob = list("Chief Medical Officer")

/datum/objective_item/steal/nukedisc
	name = "the nuclear authentication disk."
	targetitem = /obj/item/weapon/disk/nuclear
	difficulty = 5
	excludefromjob = list("Captain")

/datum/objective_item/steal/reflector
	name = "a reflector trenchcoat."
	targetitem = /obj/item/clothing/suit/armor/laserproof
	difficulty = 3
	excludefromjob = list("Head of Security", "Warden")

/datum/objective_item/steal/reactive
	name = "the reactive teleport armor."
	targetitem = /obj/item/clothing/suit/armor/reactive
	difficulty = 5
	excludefromjob = list("Research Director")

//Items with special checks!
/datum/objective_item/steal/plasma
	name = "28 moles of plasma (full tank)."
	targetitem = /obj/item/weapon/tank
	difficulty = 3
	excludefromjob = list("Chief Engineer","Research Director","Station Engineer","Scientist","Atmospheric Technician")

/datum/objective_item/steal/plasma/check_special_completion(obj/item/weapon/tank/T)
	var/target_amount = text2num(name)
	var/found_amount = 0
	found_amount += T.air_contents.gas["phoron"] ? T.air_contents.gas["phoron"] : 0
	return found_amount >= target_amount

/datum/objective_item/steal/functionalai
	name = "a functional AI."
	targetitem = /obj/item/weapon/aicard
	difficulty = 20 //beyond the impossible

/datum/objective_item/steal/functionalai/check_special_completion(obj/item/weapon/aicard/C)
	for(var/mob/living/silicon/ai/A in C)
		if(isAI(A) && A.stat != DEAD) //See if any AI's are alive inside that card.
			return 1
	return 0

/datum/objective_item/steal/blueprints
	name = "the station blueprints."
	targetitem = /obj/item/blueprints
	difficulty = 10
	excludefromjob = list("Chief Engineer")

/datum/objective_item/steal/slime
	name = "an unused sample of slime extract."
	targetitem = /obj/item/slime_extract
	difficulty = 3
	excludefromjob = list("Research Director", "Xenobiologist", "Scientist")

/datum/objective_item/steal/slime/check_special_completion(obj/item/slime_extract/E)
	if(E.Uses > 0)
		return 1
	return 0

//Unique Objectives
/datum/objective_item/special/New()
	..()
	if(TargetExists())
		GLOB.possible_items_special += src
	else
		qdel(src)

/datum/objective_item/special/Destroy()
	GLOB.possible_items_special -= src
	return ..()

//Old ninja objectives.
/datum/objective_item/special/aegun
	name = "an advanced energy gun."
	targetitem = /obj/item/weapon/gun/energy/gun/nuclear
	difficulty = 10

/datum/objective_item/special/ddrill
	name = "a diamond drill."
	targetitem = /obj/item/weapon/pickaxe/diamonddrill
	difficulty = 10

/datum/objective_item/special/boh
	name = "a bag of holding."
	targetitem = /obj/item/weapon/storage/backpack/holding
	difficulty = 10

/datum/objective_item/special/hypercell
	name = "a hyper-capacity power cell."
	targetitem = /obj/item/weapon/cell/hyper
	difficulty = 5

/datum/objective_item/special/corgimeat
	name = "a piece of corgi meat."
	targetitem = /obj/item/weapon/reagent_containers/food/snacks/meat/corgi
	difficulty = 5

/datum/objective_item/stack/New()
	..()
	if(TargetExists())
		GLOB.possible_items_special += src
	else
		qdel(src)

/datum/objective_item/stack/Destroy()
	GLOB.possible_items_special -= src
	return ..()

//Stack objectives get their own subtype
/datum/objective_item/stack
	name = "5 cardboard."
	targetitem = /obj/item/stack/material/cardboard
	difficulty = 9001

/datum/objective_item/stack/check_special_completion(obj/item/stack/S)
	var/target_amount = text2num(name)
	var/found_amount = 0

	if(istype(S, targetitem))
		found_amount = S.amount
	return found_amount>=target_amount

/datum/objective_item/stack/diamond
	name = "10 diamonds."
	targetitem = /obj/item/stack/material/diamond
	difficulty = 10

/datum/objective_item/stack/gold
	name = "50 gold bars."
	targetitem = /obj/item/stack/material/gold
	difficulty = 15

/datum/objective_item/stack/uranium
	name = "25 refined uranium bars."
	targetitem = /obj/item/stack/material/uranium
	difficulty = 10
