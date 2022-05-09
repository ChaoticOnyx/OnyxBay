/obj/item/reagent_containers/vessel/paint
	desc = "It's a paint bucket."
	name = "paint bucket"
	icon = 'icons/obj/items.dmi'
	icon_state = "paint_neutral"
	item_state = "paintcan"
	matter = list(MATERIAL_STEEL = 200)
	w_class = ITEM_SIZE_NORMAL
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = "10;20;30;60"
	volume = 60
	unacidable = FALSE
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	lid_type = null
	var/paint_hex = "#fe191a"

/obj/item/reagent_containers/vessel/paint/afterattack(turf/simulated/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target) && reagents.total_volume > 5)
		user.visible_message(SPAN("waarning", "\The [target] has been splashed with something by [user]!"))
		reagents.trans_to_turf(target, 5)
	else
		return ..()

/obj/item/reagent_containers/vessel/paint/Initialize()
	. = ..()
	if(paint_hex && length(paint_hex) > 0)
		reagents.add_reagent(/datum/reagent/paint, volume, paint_hex)

/obj/item/reagent_containers/vessel/paint/red
	name = "red paint bucket"
	icon_state = "paint_red"
	paint_hex = "#fe191a"

/obj/item/reagent_containers/vessel/paint/yellow
	name = "yellow paint bucket"
	icon_state = "paint_yellow"
	paint_hex = "#fdfe7d"

/obj/item/reagent_containers/vessel/paint/green
	name = "green paint bucket"
	icon_state = "paint_green"
	paint_hex = "#18a31a"

/obj/item/reagent_containers/vessel/paint/blue
	name = "blue paint bucket"
	icon_state = "paint_blue"
	paint_hex = "#247cff"

/obj/item/reagent_containers/vessel/paint/purple
	name = "purple paint bucket"
	icon_state = "paint_violet"
	paint_hex = "#cc0099"

/obj/item/reagent_containers/vessel/paint/black
	name = "black paint bucket"
	icon_state = "paint_black"
	paint_hex = "#333333"

/obj/item/reagent_containers/vessel/paint/white
	name = "white paint bucket"
	icon_state = "paint_white"
	paint_hex = "#f0f8ff"

/obj/item/reagent_containers/vessel/paint/random
	name = "odd paint bucket"
	icon_state = "paint_neutral"

/obj/item/reagent_containers/vessel/paint/random/Initialize()
	paint_hex = rgb(rand(1, 255), rand(1, 255), rand(1, 255))
	. = ..()
