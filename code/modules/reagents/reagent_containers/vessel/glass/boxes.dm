/obj/item/storage/box/mixedglasses
	name = "glassware box"
	desc = "A box of assorted glassware"
	can_hold = list(/obj/item/reagent_containers/vessel/glass)

	startswith = list(
		/obj/item/reagent_containers/vessel/glass/square,
		/obj/item/reagent_containers/vessel/glass/rocks,
		/obj/item/reagent_containers/vessel/glass/shake,
		/obj/item/reagent_containers/vessel/glass/cocktail,
		/obj/item/reagent_containers/vessel/glass/shot,
		/obj/item/reagent_containers/vessel/glass/pint,
		/obj/item/reagent_containers/vessel/glass/mug,
		/obj/item/reagent_containers/vessel/glass/wine
	)

/obj/item/storage/box/mixedglasses/Initialize()
	. = ..()
	make_exact_fit()

/obj/item/storage/box/glasses
	name = "box of glasses"
	icon_state = "drinking_glasses"
	var/glass_type = /obj/item/reagent_containers/vessel/glass
	can_hold = list(/obj/item/reagent_containers/vessel/glass)

/obj/item/storage/box/glasses/Initialize()
	. = ..()

	for(var/i = 1 to 7)
		new glass_type(src)
	make_exact_fit()

/obj/item/storage/box/glasses/square
	name = "box of half-pint glasses"
	icon_state = "drinking_glasses"
	glass_type = /obj/item/reagent_containers/vessel/glass/square

/obj/item/storage/box/glasses/rocks
	name = "box of rocks glasses"
	icon_state = "drinking_glasses_rocks"
	glass_type = /obj/item/reagent_containers/vessel/glass/rocks

/obj/item/storage/box/glasses/shake
	name = "box of milkshake glasses"
	icon_state = "drinking_glasses_shake"
	glass_type = /obj/item/reagent_containers/vessel/glass/shake

/obj/item/storage/box/glasses/cocktail
	name = "box of cocktail glasses"
	icon_state = "drinking_glasses_cocktail"
	glass_type = /obj/item/reagent_containers/vessel/glass/cocktail

/obj/item/storage/box/glasses/shot
	name = "box of shot glasses"
	icon_state = "drinking_glasses_shot"
	glass_type = /obj/item/reagent_containers/vessel/glass/shot

/obj/item/storage/box/glasses/pint
	name = "box of pint glasses"
	icon_state = "drinking_glasses"
	icon_state = "drinking_glasses_pint"
	glass_type = /obj/item/reagent_containers/vessel/glass/pint

/obj/item/storage/box/glasses/mug
	name = "box of glass mugs"
	icon_state = "drinking_glasses_mug"
	glass_type = /obj/item/reagent_containers/vessel/glass/mug

/obj/item/storage/box/glasses/wine
	name = "box of wine glasses"
	icon_state = "drinking_glasses_wine"
	glass_type = /obj/item/reagent_containers/vessel/glass/wine

/obj/item/storage/box/glass_extras
	name = "box of cocktail garnishings"
	var/extra_type = /obj/item/glass_extra
	can_hold = list(/obj/item/glass_extra)
	storage_slots = 14

/obj/item/storage/box/glass_extras/Initialize()
	for(var/i = 1 to 14)
		new extra_type(src)
	. = ..()

/obj/item/storage/box/glass_extras/straws
	name = "box of straws"
	icon_state = "drinking_glasses_straws"
	extra_type = /obj/item/glass_extra/straw

/obj/item/storage/box/glass_extras/sticks
	name = "box of drink sticks"
	icon_state = "drinking_glasses_sticks"
	extra_type = /obj/item/glass_extra/cocktail_stick
