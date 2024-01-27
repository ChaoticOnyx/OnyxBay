
/obj/item/reagent_containers/vessel/bottle
	name = "bottle"
	desc = "A regular glass bottle."
	icon = 'icons/obj/reagent_containers/bottles.dmi'
	icon_state = "bottle_medium"
	center_of_mass = "x=16;y=11"
	randpixel = 7
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = "5;10;15;25;30;60"
	w_class = ITEM_SIZE_SMALL
	item_flags = 0
	obj_flags = 0
	volume = 100
	force = 8.5
	mod_weight = 0.75
	mod_reach = 0.5
	mod_handy = 0.75
	smash_weaken = 5
	matter = list(MATERIAL_GLASS = 2000)
	brittle = TRUE
	lid_type = /datum/vessel_lid/cap
	can_flip = TRUE

	var/obj/item/reagent_containers/rag/rag = null
	var/rag_underlay = "rag"

	var/obj/item/bottle_extra/pourer/pourer = null
	var/pourer_overlay = "pourer_overlay"

	drop_sound = SFX_DROP_GLASSBOTTLE
	pickup_sound = SFX_PICKUP_GLASSBOTTLE

/obj/item/reagent_containers/vessel/bottle/Destroy()
	if(rag)
		rag.forceMove(get_turf(src))
	rag = null
	if(pourer)
		pourer.forceMove(get_turf(src))
	pourer = null
	return ..()

/obj/item/reagent_containers/vessel/bottle/on_update_icon()
	..()
	underlays.Cut()
	if(rag)
		var/underlay_image = image(src.icon, icon_state = rag.on_fire? "[rag_underlay]_lit" : rag_underlay)
		underlays += underlay_image
		set_light(rag.light_max_bright, 0.1, rag.light_outer_range, 2, rag.light_color)
	else if(pourer)
		AddOverlays(pourer_overlay)
		set_light(0)
	else
		set_light(0)

/obj/item/reagent_containers/vessel/bottle/attackby(obj/item/W, mob/user)
	if(!rag && !pourer && istype(W, /obj/item/bottle_extra/pourer))
		insert_pourer(W, user)
		return
	if(!rag && !pourer && istype(W, /obj/item/reagent_containers/rag))
		insert_rag(W, user)
		return
	if(rag && istype(W, /obj/item/flame))
		rag.attackby(W, user)
		return
	..()

/obj/item/reagent_containers/vessel/bottle/attack_self(mob/user)
	if(rag)
		remove_rag(user)
	else if(pourer)
		remove_pourer(user)
	else
		..()

/obj/item/reagent_containers/vessel/bottle/proc/insert_rag(obj/item/reagent_containers/rag/R, mob/user)
	if(rag || pourer)
		return
	if(!is_open_container())
		to_chat(user, SPAN("notice", "You need to open \the [src] first."))
		return
	if(user.drop(R, src))
		to_chat(user, SPAN("notice", "You stuff \the [R] into \the [src]."))
		rag = R
		atom_flags &= ~ATOM_FLAG_OPEN_CONTAINER
		update_icon()

/obj/item/reagent_containers/vessel/bottle/proc/remove_rag(mob/user)
	if(!rag)
		return
	user.pick_or_drop(rag)
	rag = null
	atom_flags |= ATOM_FLAG_OPEN_CONTAINER
	update_icon()

/obj/item/reagent_containers/vessel/bottle/proc/insert_pourer(obj/item/bottle_extra/pourer/P, mob/user)
	if(rag || pourer)
		return
	if(!is_open_container())
		to_chat(user, SPAN("notice", "You need to open \the [src] first."))
		return
	if(user.drop(P, src))
		to_chat(user, SPAN("notice", "You stuff [P] into [src]."))
		pourer = P
		possible_transfer_amounts = "0.5;1;2;3;4;5;10"
		update_icon()

/obj/item/reagent_containers/vessel/bottle/proc/remove_pourer(mob/user)
	if(!pourer)
		return
	user.pick_or_drop(pourer)
	pourer = null
	possible_transfer_amounts = initial(possible_transfer_amounts)
	amount_per_transfer_from_this = 5
	update_icon()


/obj/item/reagent_containers/vessel/bottle/small
	volume = 50
	lid_type = /datum/vessel_lid/beercap
	force = 7.0
	mod_weight = 0.65
	mod_reach = 0.5
	mod_handy = 0.85
	smash_weaken = 3

/obj/item/reagent_containers/vessel/bottle/chemical
	name = "bottle"
	desc = "A regular glass bottle."
	icon = 'icons/obj/reagent_containers/chemical.dmi'
	icon_state = "bottle_medium"
	item_state = "atoxinbottle"
	center_of_mass = "x=16;y=11"
	randpixel = 7
	force = 7.0
	mod_weight = 0.65
	mod_reach = 0.45
	mod_handy = 0.65
	smash_weaken = 0
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = "5;10;15;25;30;60"
	w_class = ITEM_SIZE_SMALL
	volume = 60
	precise_measurement = TRUE
	filling_states = "5;10;25;50;75;80;100"
	base_name = "bottle"
	base_desc = "A regular glass bottle."
	label_icon = TRUE
	overlay_icon = TRUE
	lid_type = /datum/vessel_lid/cork
	rag_underlay = "rag_medium"

	drop_sound = SFX_DROP_BOTTLE
	pickup_sound = SFX_PICKUP_BOTTLE

/obj/item/reagent_containers/vessel/bottle/chemical/small
	name = "small bottle"
	desc = "A small glass bottle."
	icon_state = "bottle_small"
	force = 5.0
	mod_weight = 0.5
	mod_reach = 0.25
	mod_handy = 0.65
	smash_weaken = 0
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = "5;10;15;30"
	w_class = ITEM_SIZE_TINY
	volume = 30
	matter = list(MATERIAL_GLASS = 1000)
	base_name = "small bottle"
	base_desc = "A small glass bottle."
	rag_underlay = "rag_small"

/obj/item/reagent_containers/vessel/bottle/chemical/big
	name = "big bottle"
	desc = "A big glass bottle."
	icon_state = "bottle_big"
	force = 8.5
	mod_weight = 0.75
	mod_reach = 0.5
	mod_handy = 0.75
	smash_weaken = 4
	amount_per_transfer_from_this = 15
	possible_transfer_amounts = "5;10;15;25;30;60"
	volume = 90
	matter = list(MATERIAL_GLASS = 3000)
	base_name = "big bottle"
	base_desc = "A big glass bottle."
	rag_underlay = "rag_big"

/obj/item/reagent_containers/vessel/bottle/chemical/big/get_storage_cost()
	return ..() * 1.5

/obj/item/reagent_containers/vessel/bottle/chemical/Initialize()
	. = ..()
	if(!icon_state)
		icon_state = "bottle-[rand(1,4)]"
		lid.icon_state = "lid[icon_state]"
		update_icon()


/obj/item/reagent_containers/vessel/bottle/chemical/robot
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = "5;10;15;25;30;50;100"
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	lid_type = null
	volume = 60
	force = 0
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


//Pourers and stuff

/obj/item/bottle_extra
	name = "generic bottle addition"
	desc = "This goes on a bottle."
	icon = 'icons/obj/reagent_containers/bottles.dmi'
	var/bottle_addition
	var/bottle_desc
	var/bottle_color
	w_class = ITEM_SIZE_TINY

/obj/item/bottle_extra/pourer
	name = "bottle pourer"
	desc = "This goes in a bottle and lets you pour drinks more precisely."
	bottle_addition = "pourer"
	bottle_desc = "There is a pourer in the bottle."
	icon_state = "pourer"
