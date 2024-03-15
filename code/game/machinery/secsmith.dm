
/obj/machinery/secsmith
	name = "Sec-Smith B33-P"
	desc = "A standard NT Security equipment reassembler."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gunsmite"
	layer = BELOW_OBJ_LAYER
	anchored = TRUE
	density = TRUE
	idle_power_usage = 25 WATTS
	active_power_usage = 200 WATTS
	interact_offline = 1
	req_access = list(access_security)

	var/obj/item/gun/energy/security/taser = null
	var/static/list/models = list("pistol" = /decl/taser_types/pistol, "SMG" = /decl/taser_types/smg, "rifle" = /decl/taser_types/rifle)

/obj/machinery/secsmith/on_update_icon()
	if(inoperable())
		icon_state = "gunsmite_off"
		return
	if(taser)
		var/decl/taser_types/tt = taser.subtype
		icon_state = "gunsmite_[tt.type_name]"
	else
		icon_state = "gunsmite"

/obj/machinery/secsmith/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/gun/energy/security))
		if(taser)
			show_splash_text(user, "already contains a taser!")
			return

		if(!user.drop(I, src))
			return

		show_splash_text(user, "taser inserted!")
		taser = I
		update_icon()
		tgui_update()
		return

	else if(istype(I, /obj/item/gun/energy/classictaser))
		show_splash_text(user, "taser not supported!")
		return

	else if(istype(I, /obj/item/gun))
		show_splash_text(user, "gun not supported!")
		return

	..()

/obj/machinery/secsmith/attack_hand(mob/user)
	tgui_interact(user)

/obj/machinery/secsmith/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "SecSmith", "Sec-Smith B33-P")
		ui.open()

/obj/machinery/secsmith/tgui_data(mob/user)
	var/list/data = list(
		"taserInstalled" = istype(taser) ? TRUE : FALSE
	)

	var/decl/taser_types/tt = taser?.subtype
	if(istype(tt))
		data["model"] = tt.type_name
		data["owner"] = taser.owner
		data["charge"] = text2num(round(taser.power_supply?.charge / taser.power_supply?.maxcharge * 100))
		data["rateOfFire"] = text2num(round(600 / tt.fire_delay))
		data["ammo"] = tt.max_shots
		data["info"] = tt.type_desc

	data["taserVariants"] = list()
	for(var/model in models)
		var/list/variant_data = list(
			"name" = model,
			"type" = models[model]
		)
		data["taserVariants"] += list(variant_data)

	return data

/obj/machinery/secsmith/tgui_act(action, params)
	. = ..()

	if(.)
		return

	switch(action)
		if("eject_taser")
			if(!taser)
				return

			taser.forceMove(get_turf(src))
			taser = null
			return TRUE

		if("reset_owner")
			if(!taser)
				return

			taser.owner = null
			return TRUE

		if("set_owner")
			if(!taser)
				return

			var/string = sanitizeSafe(params["ownerName"])
			if(!string || !length(string))
				return

			taser.owner = string
			return TRUE

		if("select_model")
			if(!taser)
				return

			var/new_model = params["newModelType"]
			taser.subtype = decls_repository.get_decl(new_model)
			taser.update_subtype()
			update_icon()
			return TRUE
