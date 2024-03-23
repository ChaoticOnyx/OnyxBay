/obj/item/coffee_condi_display
	name = "coffee condiments display"
	desc = "A neat small box, holding all your favorite coffee condiments."
	icon_state = "condi_display"
	icon = 'icons/obj/storage/boxes.dmi'
	obj_flags = OBJ_FLAG_ANCHORABLE

	var/static/image/sugar_overlay = image(icon = 'icons/obj/storage/boxes.dmi', icon_state = "condi_display_sugar")
	var/static/image/creamer_overlay = image(icon = 'icons/obj/storage/boxes.dmi', icon_state = "condi_display_creamer")
	var/static/image/astrotame_overlay = image(icon = 'icons/obj/storage/boxes.dmi', icon_state = "condi_display_astrotame")
	var/static/image/chocolate_overlay = image(icon = 'icons/obj/storage/boxes.dmi', icon_state = "condi_display_chocolate")

	var/static/radial_take_sugar = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_take_sugar")
	var/static/radial_take_sweetener = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_take_sweetener")
	var/static/radial_take_creamer = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_take_creamer")
	var/static/radial_take_chocolate = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_take_choco")

	/// Amount of sugar packs stored
	var/sugar_packs = 8
	/// Amount of creamer packs stored
	var/creamer_packs = 8
	/// Amount of astrtotame packs stored
	var/astrotame_packs = 8
	/// Amount of chocolate bars stored
	var/chocolatebars = 8

/obj/item/coffee_condi_display/Initialize()
	. = ..()
	update_icon()
	for(var/i in 1 to 4)
		new /obj/item/reagent_containers/vessel/condiment/pack/sugar(src)
		new /obj/item/reagent_containers/vessel/condiment/pack/creamer(src)
		new /obj/item/reagent_containers/vessel/condiment/pack/astrotame(src)
		new /obj/item/reagent_containers/food/chocolatebar(src)

/obj/item/coffee_condi_display/attack_hand(mob/user)
	. = ..()

	if(!anchored)
		show_splash_text(user, "anchor it first!")

	var/list/radial_options = list()

	if(sugar_packs > 0)
		radial_options["Take Sugar"] = radial_take_sugar

	if(creamer_packs > 0)
		radial_options["Take Creamer"] = radial_take_creamer

	if(astrotame_packs > 0)
		radial_options["Take Sweetener"] = radial_take_sweetener

	if(chocolatebars > 0)
		radial_options["Take Chocolate"] = radial_take_chocolate

	var/choice

	if(length(radial_options) < 1)
		return

	if(length(radial_options) == 1)
		choice = radial_options[1]
	else
		choice = show_radial_menu(user, src, radial_options, require_near = TRUE)

	switch(choice)
		if("Take Sugar")
			take_sugar(user)
		if("Take Sweetener")
			take_sweetener(user)
		if("Take Creamer")
			take_creamer(user)
		if("Take Chocolate")
			take_chocolate(user)

/obj/item/coffee_condi_display/proc/take_sugar(mob/user)
	if(creamer_packs <= 0)
		show_splash_text(user, "no creamer left!")
		return

	var/obj/item/reagent_containers/vessel/condiment/pack/creamer/new_pack = new(drop_location())
	if(Adjacent(user))
		user.put_in_hands(new_pack)
	else
		new_pack.dropInto(get_turf(src))
	creamer_packs--
	update_icon()

/obj/item/coffee_condi_display/proc/take_sweetener(mob/user)
	if(astrotame_packs <= 0)
		show_splash_text(user, "no sweetener left!")
		return

	var/obj/item/reagent_containers/vessel/condiment/pack/astrotame/new_pack = new(get_turf(src))
	if(Adjacent(user))
		user.put_in_hands(new_pack)
	else
		new_pack.dropInto(get_turf(src))
	astrotame_packs--
	update_icon()

/obj/item/coffee_condi_display/proc/take_creamer(mob/user)
	if(creamer_packs <= 0)
		show_splash_text(user, "no creamer left!")
		return

	var/obj/item/reagent_containers/vessel/condiment/pack/creamer/new_pack = new(drop_location())
	if(Adjacent(user))
		user.put_in_hands(new_pack)
	else
		new_pack.dropInto(get_turf(src))
	creamer_packs--
	update_icon()

/obj/item/coffee_condi_display/proc/take_chocolate(mob/user)
	if(chocolatebars <= 0)
		show_splash_text(user, "no chocolate left!")
		return

	var/obj/item/reagent_containers/food/chocolatebar/new_bar = new(drop_location())
	if(Adjacent(user))
		user.put_in_hands(new_bar)
	else
		new_bar.dropInto(get_turf(src))
	chocolatebars--
	update_icon()

/obj/item/coffee_condi_display/attackby(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/reagent_containers/vessel/condiment/pack/sugar))
		if(!user.drop(I, src))
			return

		sugar_packs++
		update_icon()
		return

	else if(istype(I, /obj/item/reagent_containers/vessel/condiment/pack/astrotame))
		if(!user.drop(I, src))
			return

		astrotame_packs++
		update_icon()
		return

	else if(istype(I, /obj/item/reagent_containers/vessel/condiment/pack/creamer))
		if(!user.drop(I, src))
			return

		creamer_packs++
		update_icon()
		return

	else if(istype(I, /obj/item/reagent_containers/food/chocolatebar))
		if(!user.drop(I, src))
			return

		chocolatebars++
		update_icon()
		return

	else
		return ..()

/obj/item/coffee_condi_display/on_update_icon()
	if(sugar_packs > 0)
		AddOverlays(sugar_overlay)
	else
		CutOverlays(sugar_overlay)

	if(creamer_packs > 0)
		AddOverlays(creamer_overlay)
	else
		CutOverlays(creamer_overlay)

	if(astrotame_packs > 0)
		AddOverlays(astrotame_overlay)
	else
		CutOverlays(astrotame_overlay)

	if(chocolatebars > 0)
		AddOverlays(chocolate_overlay)
	else
		CutOverlays(chocolate_overlay)
