
//Not to be confused with /obj/item/weapon/reagent_containers/food/drinks/bottle

/obj/item/weapon/reagent_containers/glass/bottle
	name = "bottle"
	desc = "A small bottle."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	item_state = "atoxinbottle"
	randpixel = 7
	center_of_mass = "x=15;y=10"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = "5;10;15;25;30;60"
	w_class = ITEM_SIZE_SMALL
	item_flags = 0
	obj_flags = 0
	volume = 60
	var/lid_state = "lid_bottle"

/obj/item/weapon/reagent_containers/glass/bottle/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/glass/bottle/pickup(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/bottle/dropped(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/bottle/attack_hand()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/bottle/Initialize()
	. = ..()
	if(!icon_state)
		icon_state = "bottle-[rand(1,4)]"

/obj/item/weapon/reagent_containers/glass/bottle/update_icon()
	overlays.Cut()

	if(reagents.total_volume && (icon_state == "bottle-1" || icon_state == "bottle-2" || icon_state == "bottle-3" || icon_state == "bottle-4"))
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)		filling.icon_state = "[icon_state]--10"
			if(10 to 24) 	filling.icon_state = "[icon_state]-10"
			if(25 to 49)	filling.icon_state = "[icon_state]-25"
			if(50 to 74)	filling.icon_state = "[icon_state]-50"
			if(75 to 79)	filling.icon_state = "[icon_state]-75"
			if(80 to 90)	filling.icon_state = "[icon_state]-80"
			if(91 to INFINITY)	filling.icon_state = "[icon_state]-100"

		filling.color = reagents.get_color()
		overlays += filling

	if (!is_open_container())
		var/image/lid = image(icon, src, "lid_bottle")
		overlays += lid


/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline
	name = "inaprovaline bottle"
	desc = "A small bottle. Contains inaprovaline - used to stabilize patients."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle-4"

/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/inaprovaline, 60)
	update_icon()


/obj/item/weapon/reagent_containers/glass/bottle/toxin
	name = "toxin bottle"
	desc = "A small bottle of toxins. Do not drink, it is poisonous."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle-3"

/obj/item/weapon/reagent_containers/glass/bottle/toxin/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/toxin, 60)
	update_icon()


/obj/item/weapon/reagent_containers/glass/bottle/cyanide
	name = "cyanide bottle"
	desc = "A small bottle of cyanide. Bitter almonds?"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle-3"

/obj/item/weapon/reagent_containers/glass/bottle/cyanide/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/toxin/cyanide, 30) //volume changed to match chloral
	update_icon()


/obj/item/weapon/reagent_containers/glass/bottle/stoxin
	name = "soporific bottle"
	desc = "A small bottle of soporific. Just the fumes make you sleepy."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle-3"

/obj/item/weapon/reagent_containers/glass/bottle/stoxin/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/soporific, 60)
	update_icon()


/obj/item/weapon/reagent_containers/glass/bottle/chloralhydrate
	name = "Chloral Hydrate Bottle"
	desc = "A small bottle of Choral Hydrate. Mickey's Favorite!"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle-3"

/obj/item/weapon/reagent_containers/glass/bottle/chloralhydrate/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/chloralhydrate, 30)		//Intentionally low since it is so strong. Still enough to knock someone out.
	update_icon()


/obj/item/weapon/reagent_containers/glass/bottle/antitoxin
	name = "dylovene bottle"
	desc = "A small bottle of dylovene. Counters poisons, and repairs damage. A wonder drug."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle-4"

/obj/item/weapon/reagent_containers/glass/bottle/antitoxin/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/dylovene, 60)
	update_icon()


/obj/item/weapon/reagent_containers/glass/bottle/mutagen
	name = "unstable mutagen bottle"
	desc = "A small bottle of unstable mutagen. Randomly changes the DNA structure of whoever comes in contact."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle-1"

/obj/item/weapon/reagent_containers/glass/bottle/mutagen/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/mutagen, 60)
	update_icon()

/obj/item/weapon/reagent_containers/glass/bottle/nanites
	name = "nanites bottle"
	desc = "A small bottle of nanites. Causes inpredictable changes in living lifeforms."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle-1"

/obj/item/weapon/reagent_containers/glass/bottle/nanites/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/nanites, 60)
	update_icon()


/obj/item/weapon/reagent_containers/glass/bottle/ammonia
	name = "ammonia bottle"
	desc = "A small bottle."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle-1"

/obj/item/weapon/reagent_containers/glass/bottle/ammonia/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/ammonia, 60)
	update_icon()


/obj/item/weapon/reagent_containers/glass/bottle/eznutrient
	name = "\improper EZ NUtrient bottle"
	desc = "A small bottle of EZ NUtrient. It's extra nutritious!"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "fertilizer1"
	lid_state = "lid_fert"

/obj/item/weapon/reagent_containers/glass/bottle/eznutrient/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/toxin/fertilizer/eznutrient, 60)
	update_icon()


/obj/item/weapon/reagent_containers/glass/bottle/compost
	name = "compost bottle"
	desc = "A small bottle"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle-1"

/obj/item/weapon/reagent_containers/glass/bottle/compost/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/toxin/fertilizer/compost, 60)
	update_icon()

/obj/item/weapon/reagent_containers/glass/bottle/left4zed
	name = "\improper Left-4-Zed bottle"
	desc = "A small bottle of Left-4-Zed. It helps plants to mutate!"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "fertilizer2"
	lid_state = "lid_fert"

/obj/item/weapon/reagent_containers/glass/bottle/left4zed/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/toxin/fertilizer/left4zed, 60)
	update_icon()


/obj/item/weapon/reagent_containers/glass/bottle/robustharvest
	name = "\improper Robust Harvest"
	desc = "A small bottle of Robust Harvest. Causes high yield!"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "fertilizer3"
	lid_state = "lid_fert"

/obj/item/weapon/reagent_containers/glass/bottle/robustharvest/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/toxin/fertilizer/robustharvest, 60)
	update_icon()

/obj/item/weapon/reagent_containers/glass/bottle/mutogrow
	name = "\improper Mut'o'Grow"
	desc = "A small bottle of Mut'o'Grow. Randomly changes the DNA structure of plants. Warning: ingestion may (and will) cause severe poisoning!"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mutagen"
	lid_state = "lid_fert"

/obj/item/weapon/reagent_containers/glass/bottle/mutogrow/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/mutagen/industrial, 60)
	update_icon()


/obj/item/weapon/reagent_containers/glass/bottle/diethylamine
	name = "diethylamine bottle"
	desc = "A small bottle."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle-4"

/obj/item/weapon/reagent_containers/glass/bottle/diethylamine/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/diethylamine, 60)
	update_icon()


/obj/item/weapon/reagent_containers/glass/bottle/pacid
	name = "Polytrinic Acid Bottle"
	desc = "A small bottle. Contains a small amount of Polytrinic Acid."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle-4"

/obj/item/weapon/reagent_containers/glass/bottle/pacid/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/acid/polyacid, 60)
	update_icon()


/obj/item/weapon/reagent_containers/glass/bottle/adminordrazine
	name = "Adminordrazine Bottle"
	desc = "A small bottle. Contains the liquid essence of the gods."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "holyflask"


/obj/item/weapon/reagent_containers/glass/bottle/adminordrazine/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/adminordrazine, 60)
	update_icon()


/obj/item/weapon/reagent_containers/glass/bottle/capsaicin
	name = "Capsaicin Bottle"
	desc = "A small bottle. Contains hot sauce."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle-4"

/obj/item/weapon/reagent_containers/glass/bottle/capsaicin/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/capsaicin, 60)
	update_icon()


/obj/item/weapon/reagent_containers/glass/bottle/frostoil
	name = "Frost Oil Bottle"
	desc = "A small bottle. Contains cold sauce."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle-4"

/obj/item/weapon/reagent_containers/glass/bottle/frostoil/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/frostoil, 60)
	update_icon()

/obj/item/weapon/reagent_containers/glass/bottle/spaceacillin
	name = "spaceacillin bottle"
	desc = "A small bottle of spaceacillin. It has antiviral and antibiotic effects."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle-4"

/obj/item/weapon/reagent_containers/glass/bottle/spaceacillin/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/spaceacillin, 60)
	update_icon()

/obj/item/weapon/reagent_containers/glass/bottle/metroidtoxin
	name = "Mysterious Bottle"
	desc = "An old ketchup bottle filled with some sort of gelatinous substance. Must be szechuan sauce! Or not."
	icon = 'icons/obj/food.dmi'
	icon_state = "ketchupold"

/obj/item/weapon/reagent_containers/glass/bottle/metroidtoxin/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/metroidtoxin, 60)
	update_icon()

/obj/item/weapon/reagent_containers/glass/bottle/opium
	name = "opium bottle"
	desc = "A small bottle of opium. An effective, but addictive painkiller."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle-4"

/obj/item/weapon/reagent_containers/glass/bottle/opium/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/tramadol/opium, 60)
	update_icon()

/obj/item/weapon/reagent_containers/glass/bottle/heroin
	name = "heroin bottle"
	desc = "A small bottle of heroin. An extremely effective painkiller, yet is terribly addictive and notorious for its life-threatening side-effects."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle-4"

/obj/item/weapon/reagent_containers/glass/bottle/heroin/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/tramadol/opium/heroin, 60)
	update_icon()
