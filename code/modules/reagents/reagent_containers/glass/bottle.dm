
//Not to be confused with /obj/item/reagent_containers/food/drinks/bottle

/obj/item/reagent_containers/glass/bottle
	name = "bottle"
	desc = "A regular glass bottle."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle_medium"
	item_state = "atoxinbottle"
	center_of_mass = "x=16;y=11"
	randpixel = 7
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = "5;10;15;25;30;60"
	w_class = ITEM_SIZE_SMALL
	item_flags = 0
	obj_flags = 0
	volume = 60
	matter = list(MATERIAL_GLASS = 2000)
	atom_flags = null
	var/lid_state = "lid_bottle_medium"
	var/use_filling_states = TRUE
	var/default_name = "bottle"
	var/default_desc = "A regular glass bottle."
	var/starting_label = null

/obj/item/reagent_containers/glass/bottle/small
	name = "small bottle"
	desc = "A small glass bottle."
	icon_state = "bottle_small"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = "5;10;15;30"
	w_class = ITEM_SIZE_TINY
	volume = 30
	matter = list(MATERIAL_GLASS = 1000)
	lid_state = "lid_bottle_small"
	default_name = "small bottle"
	default_desc = "A small glass bottle."

/obj/item/reagent_containers/glass/bottle/big
	name = "big bottle"
	desc = "A big glass bottle."
	icon_state = "bottle_big"
	amount_per_transfer_from_this = 15
	possible_transfer_amounts = "5;10;15;25;30;60"
	volume = 90
	matter = list(MATERIAL_GLASS = 3000)
	lid_state = "lid_bottle_big"
	default_name = "big bottle"
	default_desc = "A big glass bottle."

/obj/item/reagent_containers/glass/bottle/big/get_storage_cost()
	return ..() * 1.5


/obj/item/reagent_containers/glass/bottle/Initialize()
	. = ..()
	if(!default_name)
		default_name = name
	if(!default_desc)
		default_desc = desc
	if(starting_label)
		name = default_name
		AddComponent(/datum/component/label, starting_label) // So the name isn't hardcoded and the label can be removed for reusability
	if(!icon_state)
		icon_state = "bottle-[rand(1,4)]"
		lid_state = "lid_bottle"
	update_icon()

//obj/item/reagent_containers/glass/bottle/proc/setup_bottle(new_label = null

/obj/item/reagent_containers/glass/bottle/on_reagent_change()
	update_icon()

/obj/item/reagent_containers/glass/bottle/pickup(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/glass/bottle/dropped(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/glass/bottle/attack_hand()
	..()
	update_icon()

/obj/item/reagent_containers/glass/bottle/post_attach_label()
	update_icon()

/obj/item/reagent_containers/glass/bottle/post_remove_label()
	..()
	desc = default_desc
	update_icon()

/obj/item/reagent_containers/glass/bottle/update_icon()
	overlays.Cut()

	if(reagents.total_volume && use_filling_states)
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

	overlays += image(icon, src, "over_[icon_state]")

	if(length(get_components(/datum/component/label)))
		overlays += image(icon, src, "label_[icon_state]")

	if(!is_open_container())
		var/image/lid = image(icon, src, lid_state)
		overlays += lid
