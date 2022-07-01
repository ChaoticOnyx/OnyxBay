
/obj/machinery/secsmith
	name = "Sec-Smith B33-P"
	desc = "A standard NT Security equipment reassembler."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gunsmite"
	layer = BELOW_OBJ_LAYER
	anchored = TRUE
	density = TRUE
	idle_power_usage = 25
	active_power_usage = 200
	interact_offline = 1
	req_access = list(access_security)

	var/obj/item/gun/energy/security/taser = null
	var/list/models = list("pistol", "SMG", "rifle")

/obj/machinery/secsmith/update_icon()
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
			to_chat(user, "[src] already contains a taser!")
			return
		to_chat(user, "You insert \the [I] into [src].")
		user.drop_item()
		I.forceMove(src)
		taser = I
		update_icon()
		updateUsrDialog()
		return
	else if(istype(I, /obj/item/gun/energy/classictaser))
		to_chat(user, "\The [I]'s model is outdated, and not supported by [src].")
		return
	else if(istype(I, /obj/item/gun))
		to_chat(user, "[src] is not suited for this type of weapon.")
		return
	..()

/obj/machinery/secsmith/attack_hand(mob/user)
	if(..() || stat & (BROKEN|NOPOWER))
		return

	if(!user.IsAdvancedToolUser())
		return 0

	user.set_machine(src)

	var/dat = "<meta charset=\"utf-8\"><HEAD><TITLE>Sec-Smith B33-P</TITLE></HEAD>"
	dat += "Welcome to <b>Sec-Smith B33-P</b><BR> Security equipment assembling system"
	dat += "<BR><FONT SIZE=1>Property of NanoTransen</FONT>"

	if(!taser)
		dat += "<br><font color='red'>No equipment found.</font>"
	else
		var/decl/taser_types/tt = taser.subtype
		dat += "<br><h2><b>Equipment found:</b></h2>"
		dat += "<b>Model:</b> [tt.type_name]"
		dat += "<br><b>Assigned User:</b> [taser.owner ? taser.owner : "none"]"
		dat += "<br><b>Charge:</b> [round(taser.power_supply.charge / taser.power_supply.maxcharge * 100)]%"
		dat += "<br><b>Rate of fire:</b> [round(600 / tt.fire_delay)] RPM"
		dat += "<br><b>Ammunition:</b> [tt.max_shots] shots"
		dat += "<hr><b>Info:</b> [tt.type_desc]"
		dat += "<hr>"
		dat += "<h3><b>Customisation:</b></h3>"
		dat += "<A href='?src=\ref[src];select_model=1'>\[reassemble\]</a>"
		dat += "<A href='?src=\ref[src];reset_owner=1'><br>\[reset owner\]</a>"
		dat += "<A href='?src=\ref[src];set_owner=1'><br>\[set owner\]</a>"
		dat += "<A href='?src=\ref[src];eject_taser=1'><br>\[eject\]</a>"

	show_browser(user, dat, "window=secsmith")
	onclose(user, "secsmith")
	return

/obj/machinery/secsmith/Topic(href, href_list)
	if(href_list["eject_taser"])
		if(!taser)
			return
		taser.forceMove(get_turf(src))
		taser = null
		update_icon()
	else if(href_list["set_owner"])
		if(!taser)
			return
		var/str = sanitizeSafe(input("Label text?","Set label",""), MAX_NAME_LEN)
		if(!str || !length(str) || !taser)
			return
		taser.owner = str
	else if(href_list["reset_owner"])
		if(!taser)
			return
		taser.owner = null
	else if(href_list["select_model"])
		if(!taser)
			return
		var/choice = input("Wanted Model.","Sec-Smith B33-P",null) as null|anything in models
		if(!choice || !taser)
			return
		var/new_model = null
		switch(choice)
			if("pistol")
				new_model = /decl/taser_types/pistol
			if("SMG")
				new_model = /decl/taser_types/smg
			if("rifle")
				new_model = /decl/taser_types/rifle
			else
				return
		taser.subtype = decls_repository.get_decl(new_model)
		taser.update_subtype()
		update_icon()

	updateUsrDialog()
	return

/obj/machinery/secsmith/verb/eject()
	set src in oview(1)
	set category = "Object"
	set name = "Eject Taser"

	if(usr.stat)
		return

	if(!taser)
		to_chat(usr, "[src] is empty.")
		return

	taser.forceMove(get_turf(src))
	taser = null
	update_icon()
	add_fingerprint(usr)
	return
