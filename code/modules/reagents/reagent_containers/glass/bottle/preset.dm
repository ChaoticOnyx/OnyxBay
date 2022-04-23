
/obj/item/reagent_containers/glass/bottle/inaprovaline
	name = "inaprovaline bottle"
	desc = "A small bottle. Contains inaprovaline - used to stabilize patients."
	starting_label = "Inaprovaline"

/obj/item/reagent_containers/glass/bottle/inaprovaline/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/inaprovaline, 60)
	update_icon()

//////////
/obj/item/reagent_containers/glass/bottle/toxin
	name = "toxin bottle"
	desc = "A small bottle of toxins. Do not drink, it is poisonous."
	icon = 'icons/obj/chemical.dmi'
	starting_label = "toxin"

/obj/item/reagent_containers/glass/bottle/toxin/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/toxin, 60)
	update_icon()

//////////
/obj/item/reagent_containers/glass/bottle/small/cyanide
	name = "cyanide bottle"
	desc = "A small bottle of cyanide. Bitter almonds?"
	starting_label = "Cyanide"

/obj/item/reagent_containers/glass/bottle/small/cyanide/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/toxin/cyanide, 30) //volume changed to match chloral
	update_icon()

//////////
/obj/item/reagent_containers/glass/bottle/stoxin
	name = "soporific bottle"
	desc = "A small bottle of soporific. Just the fumes make you sleepy."
	starting_label = "Soporific"

/obj/item/reagent_containers/glass/bottle/stoxin/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/soporific, 60)
	update_icon()

//////////
/obj/item/reagent_containers/glass/bottle/small/chloralhydrate
	name = "Chloral Hydrate Bottle"
	desc = "A small bottle of Choral Hydrate. Mickey's Favorite!"
	starting_label = "Chloral Hydrate"

/obj/item/reagent_containers/glass/bottle/small/chloralhydrate/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/chloralhydrate, 30)		//Intentionally low since it is so strong. Still enough to knock someone out.
	update_icon()

//////////
/obj/item/reagent_containers/glass/bottle/antitoxin
	name = "dylovene bottle"
	desc = "A small bottle of dylovene. Counters poisons, and repairs damage. A wonder drug."
	starting_label = "Dylovene"

/obj/item/reagent_containers/glass/bottle/antitoxin/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/dylovene, 60)
	update_icon()

//////////
/obj/item/reagent_containers/glass/bottle/mutagen
	name = "unstable mutagen bottle"
	desc = "A small bottle of unstable mutagen. Randomly changes the DNA structure of whoever comes in contact."
	starting_label = "Unstable Mutagen"

/obj/item/reagent_containers/glass/bottle/mutagen/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/mutagen, 60)
	update_icon()

//////////
/obj/item/reagent_containers/glass/bottle/nanites
	name = "nanites bottle"
	desc = "A small bottle of nanites. Causes inpredictable changes in living lifeforms."
	starting_label = "Nanites"

/obj/item/reagent_containers/glass/bottle/nanites/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/nanites, 60)
	update_icon()

//////////
/obj/item/reagent_containers/glass/bottle/ammonia
	name = "ammonia bottle"
	desc = "Smells funny."
	starting_label = "Ammonia"

/obj/item/reagent_containers/glass/bottle/ammonia/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/ammonia, 60)
	update_icon()

//////////
/obj/item/reagent_containers/glass/bottle/diethylamine
	name = "diethylamine bottle"
	starting_label = "Diethylamine"

/obj/item/reagent_containers/glass/bottle/diethylamine/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/diethylamine, 60)
	update_icon()

//////////
/obj/item/reagent_containers/glass/bottle/pacid
	name = "Polytrinic Acid Bottle"
	desc = "A glass bottle. Contains a small amount of Polytrinic Acid."
	starting_label = "Polytrinic Acid"

/obj/item/reagent_containers/glass/bottle/pacid/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/acid/polyacid, 60)
	update_icon()

//////////
/obj/item/reagent_containers/glass/bottle/adminordrazine
	name = "Adminordrazine Bottle"
	desc = "A small bottle. Contains the liquid essence of the gods."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "holyflask"

/obj/item/reagent_containers/glass/bottle/adminordrazine/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/adminordrazine, 60)
	update_icon()

//////////
/obj/item/reagent_containers/glass/bottle/capsaicin
	name = "Capsaicin Bottle"
	desc = "A small bottle. Contains hot sauce."
	starting_label = "Capsaicin"

/obj/item/reagent_containers/glass/bottle/capsaicin/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/capsaicin, 60)
	update_icon()

//////////
/obj/item/reagent_containers/glass/bottle/frostoil
	name = "Frost Oil Bottle"
	desc = "A small bottle. Contains cold sauce."
	starting_label = "Frost Oil"

/obj/item/reagent_containers/glass/bottle/frostoil/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/frostoil, 60)
	update_icon()

//////////
/obj/item/reagent_containers/glass/bottle/spaceacillin
	name = "spaceacillin bottle"
	desc = "A small bottle of spaceacillin. It has antiviral and antibiotic effects."
	starting_label = "Spaceacillin"

/obj/item/reagent_containers/glass/bottle/spaceacillin/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/spaceacillin, 60)
	update_icon()

//////////
/obj/item/reagent_containers/glass/bottle/metroidtoxin
	name = "Mysterious Bottle"
	desc = "An old ketchup bottle filled with some sort of gelatinous substance. Must be szechuan sauce! Or not."
	icon = 'icons/obj/food.dmi'
	icon_state = "ketchupold"

/obj/item/reagent_containers/glass/bottle/metroidtoxin/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/metroidtoxin, 60)
	update_icon()

//////////
/obj/item/reagent_containers/glass/bottle/opium
	name = "opium bottle"
	desc = "A small bottle of opium. An effective, but addictive painkiller."
	starting_label = "Opium"

/obj/item/reagent_containers/glass/bottle/opium/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/painkiller/opium, 60)
	update_icon()

//////////
/obj/item/reagent_containers/glass/bottle/tarine
	name = "tarine bottle"
	desc = "A small bottle of tarine. An extremely effective painkiller, yet is terribly addictive and notorious for its life-threatening side-effects."
	starting_label = "Tarine"

/obj/item/reagent_containers/glass/bottle/tarine/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/painkiller/opium/tarine, 60)
	update_icon()

//////////
/obj/item/reagent_containers/glass/bottle/painkiller
	name = "metazine bottle"
	desc = "A small bottle of metazine. A very potent painkiller. Although it's not an opiate, users may quickly develop a tolerance to the drug."
	starting_label = "Metazine"

/obj/item/reagent_containers/glass/bottle/painkiller/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/painkiller, 60)
	update_icon()
