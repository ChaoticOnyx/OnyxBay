
/obj/item/reagent_containers/glass/beaker
	name = "beaker"
	desc = "A beaker."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker"
	item_state = "beaker"
	center_of_mass = "x=17;y=10"
	matter = list(MATERIAL_GLASS = 2500)

/obj/item/reagent_containers/glass/beaker/Initialize()
	. = ..()
	desc += " Can hold up to [volume] units."
	update_icon()

/obj/item/reagent_containers/glass/beaker/on_reagent_change()
	update_icon()

/obj/item/reagent_containers/glass/beaker/pickup(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/glass/beaker/dropped(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/glass/beaker/attack_hand()
	..()
	update_icon()

/obj/item/reagent_containers/glass/beaker/update_icon()
	overlays.Cut()

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)		filling.icon_state = "[icon_state]-10"
			if(10 to 24) 	filling.icon_state = "[icon_state]10"
			if(25 to 49)	filling.icon_state = "[icon_state]25"
			if(50 to 74)	filling.icon_state = "[icon_state]50"
			if(75 to 79)	filling.icon_state = "[icon_state]75"
			if(80 to 90)	filling.icon_state = "[icon_state]80"
			if(91 to INFINITY)	filling.icon_state = "[icon_state]100"

		filling.color = reagents.get_color()
		overlays += filling

	overlays += image(icon, src, "over_[icon_state]")

	if(!is_open_container())
		var/image/lid = image(icon, src, "lid_[initial(icon_state)]")
		overlays += lid

/obj/item/reagent_containers/glass/beaker/large
	name = "large beaker"
	desc = "A large beaker."
	icon_state = "beakerlarge"
	center_of_mass = "x=17;y=10"
	matter = list(MATERIAL_GLASS = 5000)
	volume = 120
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = "5;10;15;25;30;60;120"
	atom_flags = ATOM_FLAG_OPEN_CONTAINER

/obj/item/reagent_containers/glass/beaker/large/get_storage_cost()
	return ..() * 1.5

/obj/item/reagent_containers/glass/beaker/plass
	name = "plass beaker"
	desc = "A beaker made of plass, it doesn't allow radiation to pass through."
	icon_state = "plass_beaker"
	matter = list(MATERIAL_PLASS = 2500)
	effect_flags = EFFECT_FLAG_RAD_SHIELDED

/obj/item/reagent_containers/glass/beaker/noreact
	name = "cryostasis beaker"
	desc = "A cryostasis beaker that allows for chemical storage without reactions."
	icon_state = "beakernoreact"
	center_of_mass = "x=17;y=10"
	matter = list(MATERIAL_GLASS = 2500)
	volume = 60
	amount_per_transfer_from_this = 10
	atom_flags = ATOM_FLAG_OPEN_CONTAINER | ATOM_FLAG_NO_REACT
	effect_flags = EFFECT_FLAG_RAD_SHIELDED

/obj/item/reagent_containers/glass/beaker/bluespace
	name = "bluespace beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology."
	icon_state = "beakerbluespace"
	center_of_mass = "x=17;y=10"
	matter = list(MATERIAL_STEEL = 1000, MATERIAL_GLASS = 5000)
	volume = 300
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = "5;10;15;25;30;60;120;150;200;250;300"
	atom_flags = ATOM_FLAG_OPEN_CONTAINER

/obj/item/reagent_containers/glass/beaker/vial
	name = "vial"
	desc = "A small glass vial."
	icon_state = "vial"
	center_of_mass = "x=16;y=10"
	matter = list(MATERIAL_GLASS = 1250)
	volume = 30
	w_class = ITEM_SIZE_TINY //half the volume of a bottle, half the size
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = "5;10;15;30"
	atom_flags = ATOM_FLAG_OPEN_CONTAINER

/obj/item/reagent_containers/glass/beaker/cryoxadone
	startswith = list(/datum/reagent/cryoxadone = 30)

/obj/item/reagent_containers/glass/beaker/sulphuric
	startswith = list(/datum/reagent/acid = 60)
