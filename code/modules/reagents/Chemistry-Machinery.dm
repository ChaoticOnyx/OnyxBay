#define BOTTLE_SPRITES list("bottle-1", "bottle-2", "bottle-3", "bottle-4") //list of available bottle sprites

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/chem_master
	name = "ChemMaster 3000"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer"
	layer = BELOW_OBJ_LAYER
	idle_power_usage = 20 WATTS
	clicksound = SFX_USE_BUTTON
	clickvol = 20
	var/obj/item/reagent_containers/vessel/beaker
	var/obj/item/storage/pill_bottle/loaded_pill_bottle
	var/mode = 0
	var/condi = 0
	var/useramount = 30 // Last used amount
	var/pillamount = 10
	var/bottlesprite = "bottle-1" //yes, strings
	var/pillsprite = "1"
	var/client/has_sprites = list()
	var/max_pill_count = 20
	var/capacity = 120
	component_types = list(
		/obj/item/circuitboard/chemmaster,
		/obj/item/device/healthanalyzer,
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/manipulator = 4,
		/obj/item/stock_parts/console_screen,
	)
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	var/matter_amount_per_sheet = SHEET_MATERIAL_AMOUNT
	var/matter_type = MATERIAL_GLASS
	var/matter_storage = SHEET_MATERIAL_AMOUNT * 25
	var/matter_storage_max = SHEET_MATERIAL_AMOUNT * 50

/obj/machinery/chem_master/New()
	create_reagents(capacity)
	..()

/obj/machinery/chem_master/Initialize()
	. = ..()
	update_icon()

/obj/machinery/chem_master/Destroy()
	if(loaded_pill_bottle)
		loaded_pill_bottle.forceMove(get_turf(src))
		loaded_pill_bottle = null
	if(beaker)
		beaker.forceMove(get_turf(src))
		beaker = null
	if(matter_storage >= matter_amount_per_sheet)
		new /obj/item/stack/material/glass(get_turf(src), Floor(matter_storage / matter_amount_per_sheet))
	return ..()

/obj/machinery/chem_master/on_update_icon()
	ClearOverlays()
	if(stat & (NOPOWER | BROKEN))
		set_light(0)
		if(stat & BROKEN)
			AddOverlays(OVERLAY(icon, "[icon_state]_b"))
	else
		var/overlay_icon_state = "[icon_state]_over[!!beaker]"
		AddOverlays(OVERLAY(icon, overlay_icon_state))
		AddOverlays(emissive_appearance(icon, overlay_icon_state))
		set_light(0.8, 0.5, 2, 3, "#0099FF")

	if(beaker)
		AddOverlays(OVERLAY(icon, "[icon_state]_vessel"))

/obj/machinery/chem_master/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return

/obj/machinery/chem_master/attackby(obj/item/W, mob/user)
	if(default_deconstruction_screwdriver(user, W))
		return
	if(default_deconstruction_crowbar(user, W))
		return
	if(default_part_replacement(user, W))
		return

	if(istype(W, /obj/item/reagent_containers/vessel/beaker) || istype(W, /obj/item/reagent_containers/vessel/bottle/chemical))
		if(beaker)
			to_chat(user, "A beaker is already loaded into the machine.")
			return
		if(!user.drop(W, src))
			return
		beaker = W
		to_chat(user, "You add \the [W] to the machine!")
		updateUsrDialog()
		update_icon()

	else if(istype(W, /obj/item/storage/pill_bottle))
		if(loaded_pill_bottle)
			to_chat(user, "A pill bottle is already loaded into the machine.")
			return
		if(!user.drop(W, src))
			return
		loaded_pill_bottle = W
		to_chat(user, "You add \the [W] into the dispenser slot!")
		updateUsrDialog()

	else if(istype(W, /obj/item/stack/material) && W.get_material_name() == matter_type)
		if((matter_storage_max - matter_storage) < matter_amount_per_sheet)
			to_chat(user, SPAN("warning", "\The [src] is too full."))
			return
		var/obj/item/stack/S = W
		var/space_left = matter_storage_max - matter_storage
		var/sheets_to_take = min(S.amount, Floor(space_left / matter_amount_per_sheet))
		if(sheets_to_take <= 0)
			to_chat(user, SPAN("warning", "\The [src] is too full."))
			return
		matter_storage = min(matter_storage_max, matter_storage + (sheets_to_take * matter_amount_per_sheet))
		to_chat(user, SPAN("info", "\The [src] processes \the [W]. Levels of stored matter now: [matter_storage]/[matter_storage_max]"))
		S.use(sheets_to_take)
		return
	return

/obj/machinery/chem_master/Topic(href, href_list, state)
	if(..())
		return 1

	if (href_list["ejectp"])
		if(loaded_pill_bottle)
			loaded_pill_bottle.dropInto(loc)
			loaded_pill_bottle = null
	else if(href_list["close"])
		close_browser(usr, "window=chemmaster")
		usr.unset_machine()
		return

	if(beaker)
		var/datum/reagents/R = beaker:reagents
		if (href_list["analyze"])
			var/dat = "<meta charset=\"utf-8\">"
			if(!condi)
				if(href_list["name"] == "Blood")
					var/datum/reagent/blood/G
					for(var/datum/reagent/F in R.reagent_list)
						if(F.name == href_list["name"])
							G = F
							break
					var/A = G.name
					var/B = G.data["blood_type"]
					var/C = G.data["blood_DNA"]
					dat += "<TITLE>Chemmaster 3000</TITLE>Chemical infos:<BR><BR>Name:<BR>[A]<BR><BR>Description:<BR>Blood Type: [B]<br>DNA: [C]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
				else
					dat += "<TITLE>Chemmaster 3000</TITLE>Chemical infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			else
				dat += "<TITLE>Condimaster 3000</TITLE>Condiment infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			show_browser(usr, dat, "window=chem_master;size=575x400")
			return

		else if (href_list["add"])
			if(href_list["amount"])
				var/datum/reagent/their_reagent = locate(href_list["add"]) in R.reagent_list
				if(their_reagent)
					var/amount = Clamp((text2num(href_list["amount"])), 0, capacity)
					R.trans_type_to(src, their_reagent.type, amount)

		else if (href_list["addcustom"])
			var/datum/reagent/their_reagent = locate(href_list["addcustom"]) in R.reagent_list
			if(their_reagent)
				useramount = input("Select the amount to transfer.", 30, useramount) as null|num
				if(useramount)
					useramount = Clamp(useramount, 0, capacity)
					src.Topic(href, list("amount" = "[useramount]", "add" = href_list["addcustom"]), state)

		else if (href_list["remove"])
			if(href_list["amount"])
				var/datum/reagent/my_reagents = locate(href_list["remove"]) in reagents.reagent_list
				if(my_reagents)
					var/amount = Clamp((text2num(href_list["amount"])), 0, capacity)
					if(mode)
						reagents.trans_type_to(beaker, my_reagents.type, amount)
					else
						reagents.remove_reagent(my_reagents.type, amount)


		else if (href_list["removecustom"])
			var/datum/reagent/my_reagents = locate(href_list["removecustom"]) in reagents.reagent_list
			if(my_reagents)
				useramount = input("Select the amount to transfer.", 30, useramount) as null|num
				if(useramount)
					useramount = Clamp(useramount, 0, 200)
					src.Topic(href, list("amount" = "[useramount]", "remove" = href_list["removecustom"]), state)

		else if (href_list["toggle"])
			mode = !mode

		else if (href_list["main"])
			attack_hand(usr)
			return
		else if (href_list["eject"])
			if(beaker)
				beaker:dropInto(loc)
				beaker = null
				reagents.clear_reagents()
				update_icon()
		else if (href_list["createpill"] || href_list["createpill_multiple"])
			var/count = 1

			if(reagents.total_volume/count < 1) //Sanity checking.
				return

			if (href_list["createpill_multiple"])
				count = input("Select the number of pills to make.", "Max [max_pill_count]", pillamount) as num
				count = Clamp(count, 1, max_pill_count)

			if(reagents.total_volume/count < 1) //Sanity checking.
				return

			var/amount_per_pill = reagents.total_volume/count
			if (amount_per_pill > 30) amount_per_pill = 30

			var/name = sanitizeSafe(input(usr,"Name:","Name your pill!","[reagents.get_master_reagent_name()] ([amount_per_pill]u)"), MAX_NAME_LEN)

			if(reagents.total_volume/count < 1) //Sanity checking.
				return
			while (count-- && count >= 0)
				var/obj/item/reagent_containers/pill/P = new /obj/item/reagent_containers/pill(src.loc)
				if(!name) name = reagents.get_master_reagent_name()
				P.SetName("[name] pill")
				P.icon_state = "pill"+pillsprite
				if(P.icon_state in list("pill1", "pill2", "pill3", "pill4", "pill5")) // if using greyscale, take colour from reagent
					P.color = reagents.get_color()
				reagents.trans_to_obj(P,amount_per_pill)
				if(src.loaded_pill_bottle)
					if(loaded_pill_bottle.contents.len < loaded_pill_bottle.max_storage_space)
						P.forceMove(loaded_pill_bottle)
						src.updateUsrDialog()

		else if(href_list["createbottle"])
			if(!spend_material(2000, usr))
				return
			if(!condi)
				create_bottle(usr)
			else
				var/obj/item/reagent_containers/vessel/condiment/P = new /obj/item/reagent_containers/vessel/condiment(src.loc)
				reagents.trans_to_obj(P, 50)

		else if(href_list["createbottle_small"])
			if(!spend_material(1000, usr))
				return
			create_bottle(usr, 30, "small")

		else if(href_list["createbottle_big"])
			if(!spend_material(3000, usr))
				return
			create_bottle(usr, 90, "big")

		else if(href_list["change_pill"])
			#define MAX_PILL_SPRITE 25 //max icon state of the pill sprites
			var/dat = "<meta charset=\"utf-8\"><table>"
			for(var/i = 1 to MAX_PILL_SPRITE)
				dat += "<tr><td><a href=\"?src=\ref[src]&pill_sprite=[i]\"><img src=\"pill[i].png\" /></a></td></tr>"
			dat += "</table>"
			show_browser(usr, dat, "window=chem_master")
			return
		else if(href_list["change_bottle"])
			var/dat = "<meta charset=\"utf-8\"><table>"
			for(var/sprite in BOTTLE_SPRITES)
				dat += "<tr><td><a href=\"?src=\ref[src]&bottle_sprite=[sprite]\"><img src=\"[sprite].png\" /></a></td></tr>"
			dat += "</table>"
			show_browser(usr, dat, "window=chem_master")
			return
		else if(href_list["pill_sprite"])
			pillsprite = href_list["pill_sprite"]
		else if(href_list["bottle_sprite"])
			bottlesprite = href_list["bottle_sprite"]

	src.updateUsrDialog()
	return

/obj/machinery/chem_master/proc/create_bottle(mob/user = null, reagent_amount = 60, bottle_type = null)
	var/bottle_name
	if(user)
		bottle_name = sanitizeSafe(input(user, "Name:", "Name your bottle!", reagents.get_master_reagent_name()), MAX_NAME_LEN)
	if(!bottle_name)
		bottle_name = reagents.get_master_reagent_name()
	var/obj/item/reagent_containers/vessel/bottle/chemical/B
	switch(bottle_type)
		if("small")
			B = new /obj/item/reagent_containers/vessel/bottle/chemical/small(loc)
		if("big")
			B = new /obj/item/reagent_containers/vessel/bottle/chemical/big(loc)
		else
			B = new /obj/item/reagent_containers/vessel/bottle/chemical(loc)
	B.AddComponent(/datum/component/label, bottle_name)
	if(B.atom_flags | ATOM_FLAG_OPEN_CONTAINER)
		B.lid.toggle()
	reagents.trans_to_obj(B, reagent_amount)
	B.update_icon()

/obj/machinery/chem_master/proc/spend_material(amount = 0, mob/user)
	if(matter_storage < amount)
		if(user)
			to_chat(user, "\icon[src]<b>\The [src]</b> pings sadly as it lacks material to complete the task.")
		return FALSE
	matter_storage -= amount
	return TRUE

/obj/machinery/chem_master/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/chem_master/attack_hand(mob/user as mob)
	if(inoperable())
		return
	user.set_machine(src)
	if(!(user.client in has_sprites))
		spawn()
			has_sprites += user.client
			for(var/i = 1 to MAX_PILL_SPRITE)
				send_rsc(usr, icon('icons/obj/chemical.dmi', "pill" + num2text(i)), "pill[i].png")
			for(var/sprite in BOTTLE_SPRITES)
				send_rsc(usr, icon('icons/obj/chemical.dmi', sprite), "[sprite].png")
	var/dat = ""
	if(!beaker)
		dat = "Please insert beaker.<BR>"
		if(src.loaded_pill_bottle)
			dat += "<A href='?src=\ref[src];ejectp=1'>Eject Pill Bottle \[[loaded_pill_bottle.contents.len]/[loaded_pill_bottle.max_storage_space]\]</A><BR><BR>"
		else
			dat += "No pill bottle inserted.<BR><BR>"
		dat += "<A href='?src=\ref[src];close=1'>Close</A>"
	else
		var/datum/reagents/R = beaker:reagents
		dat += "<A href='?src=\ref[src];eject=1'>Eject beaker and Clear Buffer</A><BR>"
		if(src.loaded_pill_bottle)
			dat += "<A href='?src=\ref[src];ejectp=1'>Eject Pill Bottle \[[loaded_pill_bottle.contents.len]/[loaded_pill_bottle.max_storage_space]\]</A><BR><BR>"
		else
			dat += "No pill bottle inserted.<BR><BR>"
		if(!R.total_volume)
			dat += "Beaker is empty."
		else
			dat += "Add to buffer:<BR>"
			for(var/datum/reagent/G in R.reagent_list)
				dat += "[G.name] , [G.volume] Units - "
				dat += "<A href='?src=\ref[src];analyze=1;desc=[G.description];name=[G.name]'>(Analyze)</A> "
				dat += "<A href='?src=\ref[src];add=\ref[G];amount=1'>(1)</A> "
				dat += "<A href='?src=\ref[src];add=\ref[G];amount=5'>(5)</A> "
				dat += "<A href='?src=\ref[src];add=\ref[G];amount=10'>(10)</A> "
				dat += "<A href='?src=\ref[src];add=\ref[G];amount=[G.volume]'>(All)</A> "
				dat += "<A href='?src=\ref[src];addcustom=\ref[G]'>(Custom)</A><BR>"

		dat += "<HR>Transfer to <A href='?src=\ref[src];toggle=1'>[(!mode ? "disposal" : "beaker")]:</A><BR>"
		if(reagents.total_volume)
			for(var/datum/reagent/N in reagents.reagent_list)
				dat += "[N.name] , [N.volume] Units - "
				dat += "<A href='?src=\ref[src];analyze=1;desc=[N.description];name=[N.name]'>(Analyze)</A> "
				dat += "<A href='?src=\ref[src];remove=\ref[N];amount=1'>(1)</A> "
				dat += "<A href='?src=\ref[src];remove=\ref[N];amount=5'>(5)</A> "
				dat += "<A href='?src=\ref[src];remove=\ref[N];amount=10'>(10)</A> "
				dat += "<A href='?src=\ref[src];remove=\ref[N];amount=[N.volume]'>(All)</A> "
				dat += "<A href='?src=\ref[src];removecustom=\ref[N]'>(Custom)</A><BR>"
		else
			dat += "Empty<BR>"
		dat += "<HR>Stored glass amount: [matter_storage]/[matter_storage_max]<BR>"
		if(!condi)
			dat += "<HR><BR><A href='?src=\ref[src];createpill=1'>Create pill (30 units max)</A><a href=\"?src=\ref[src]&change_pill=1\"><img src=\"pill[pillsprite].png\" /></a><BR>"
			dat += "<A href='?src=\ref[src];createpill_multiple=1'>Create multiple pills</A><BR>"
			dat +=  "<A href='?src=\ref[src];createbottle_small=1'>Create small bottle  | 30 units max | Glass: 1000</A><BR>"
			dat +=        "<A href='?src=\ref[src];createbottle=1'>Create normal bottle | 60 units max | Glass: 2000</A><BR>"
			dat +=    "<A href='?src=\ref[src];createbottle_big=1'>Create big bottle    | 90 units max | Glass: 3000</A>"
		else
			dat += "<A href='?src=\ref[src];createbottle=1'>Create bottle | 50 units max | Glass: 2000</A>"
	if(!condi)
		show_browser(user, "<meta charset=\"utf-8\"><TITLE>Chemmaster 3000</TITLE>Chemmaster menu:<BR><BR>[dat]", "window=chem_master;size=575x400")
	else
		show_browser(user, "<meta charset=\"utf-8\"><TITLE>Condimaster 3000</TITLE>Condimaster menu:<BR><BR>[dat]", "window=chem_master;size=575x400")
	onclose(user, "chem_master")
	return

/obj/machinery/chem_master/condimaster
	name = "CondiMaster 3000"
	condi = 1

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
/obj/machinery/reagentgrinder
	name = "All-In-One Grinder"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	layer = BELOW_OBJ_LAYER
	density = 0
	anchored = 0
	idle_power_usage = 5 WATTS
	active_power_usage = 100 WATTS

	component_types = list(
		/obj/item/circuitboard/grinder,
		/obj/item/stock_parts/scanning_module,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/console_screen,
	)

	var/inuse = FALSE
	var/obj/item/reagent_containers/vessel/beaker/beaker
	var/limit = 10
	var/list/holdingitems = list()

	/// Associative list of text -> image, where text is a name of an action.
	var/static/list/choices

/obj/machinery/reagentgrinder/Initialize(mapload)
	. = ..()
	if(mapload)
		beaker = new /obj/item/reagent_containers/vessel/beaker/large(src)
	update_icon()

/obj/machinery/reagentgrinder/on_update_icon()
	icon_state = "juicer"+num2text(!isnull(beaker))
	return

/obj/machinery/reagentgrinder/Destroy()
	if(beaker)
		beaker.forceMove(get_turf(src))
		beaker = null
	return ..()

/obj/machinery/reagentgrinder/attackby(obj/item/O as obj, mob/user as mob)
	if(default_deconstruction_screwdriver(user, O))
		return
	if(default_deconstruction_crowbar(user, O))
		return
	if(default_part_replacement(user, O))
		return

	if(istype(O, /obj/item/reagent_containers/vessel/beaker))
		if(beaker)
			return TRUE
		else if(user.drop(O, src))
			beaker =  O
			update_icon()
			updateUsrDialog()
			return FALSE

	if(holdingitems && holdingitems.len >= limit)
		to_chat(usr, "The machine cannot hold anymore items.")
		return TRUE

	if(!istype(O))
		return

	if(istype(O,/obj/item/storage/plants))
		var/obj/item/storage/plants/bag = O
		var/failed = 1
		for(var/obj/item/G in O.contents)
			if(!G.reagents || !G.reagents.total_volume)
				continue
			failed = 0
			bag.remove_from_storage(G, src)
			holdingitems += G
			if(holdingitems && holdingitems.len >= limit)
				break

		if(failed)
			to_chat(user, "Nothing in the plant bag is usable.")
			return 1

		if(!O.contents.len)
			to_chat(user, "You empty \the [O] into \the [src].")
		else
			to_chat(user, "You fill \the [src] from \the [O].")

		src.updateUsrDialog()
		return 0
	if(istype(O, /obj/item/organ))
		var/obj/item/organ/I = O
		if(BP_IS_ROBOTIC(I))
			to_chat(user, "\The [O] is not suitable for blending.")
			return 1
	if(istype(O, /obj/item/stack/material))
		var/obj/item/stack/material/stack = O
		if(!stack.material.reagent_path)
			to_chat(user, "\The [O] is not suitable for blending.")
			return 1
	else if(!O.reagents?.total_volume || istype(O, /obj/item/reagent_containers/dropper))
		to_chat(user, "\The [O] is not suitable for blending.")
		return 1

	if(!user.drop(O, src))
		return
	holdingitems += O
	updateUsrDialog()
	return 0

/obj/machinery/reagentgrinder/attack_ai(mob/user as mob)
	return 0

/obj/machinery/reagentgrinder/attack_hand(mob/user)
	if(!inuse)
		show_choices(user)

/obj/machinery/reagentgrinder/attack_robot(mob/user)
	//Calling for adjacency as I don't think grinders are wireless.
	if(Adjacent(user))
		//Calling attack_hand(user) to make ensure no functionality is missed.
		//If attack_hand is updated, this segment won't have to be updated as well.
		return attack_hand(user)

/obj/machinery/reagentgrinder/proc/show_choices(mob/user)
	if(!length(choices))
		_generate_buttons()

	var/choice = show_radial_menu(user, src, choices, require_near = TRUE)
	switch(choice)
		if("grind")
			grind()
		if("dump")
			show_splash_text(user, "contents dumped.")
			eject()
		if("detach")
			show_splash_text(user, beaker ? "beaker detached." : "no beaker present!")
			detach()

/obj/machinery/reagentgrinder/proc/_generate_buttons()
	LAZYINITLIST(choices)
	for(var/action as anything in list("grind", "dump", "detach"))
		choices[action] = image('icons/hud/radial.dmi', "radial_[action]")

/obj/machinery/reagentgrinder/proc/eject()
	if(!length(holdingitems))
		return

	for(var/obj/item/O in holdingitems)
		holdingitems -= O
		O.dropInto(loc)

/obj/machinery/reagentgrinder/proc/detach()
	if(!beaker)
		return

	beaker.dropInto(loc)
	beaker = null
	update_icon()

/obj/machinery/reagentgrinder/proc/grind()

	power_change()
	if(stat & (NOPOWER|BROKEN))
		return

	// Sanity check.
	if(!beaker || beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
		return

	if(!(beaker.atom_flags & ATOM_FLAG_OPEN_CONTAINER))
		audible_message(SPAN("warning", "<b>The [src]</b> states, \"The beaker is closed, reagent processing is impossible.\""))
		playsound(src.loc, 'sound/signals/error28.ogg', 50, 1)
		return

	playsound(src.loc, 'sound/machines/blender.ogg', 50, 1)
	inuse = 1

	// Reset the machine.
	spawn(60)
		inuse = 0
		interact(usr)

	// Process.
	for(var/obj/item/O in holdingitems)

		var/remaining_volume = beaker.reagents.maximum_volume - beaker.reagents.total_volume
		if(remaining_volume <= 0)
			break

		if(istype(O, /obj/item/stack/material))
			var/obj/item/stack/material/stack = O
			if(stack.material.reagent_path)
				var/amount_to_take = max(0, min(stack.amount, round(remaining_volume / REAGENTS_PER_MATERIAL_SHEET)))
				if(amount_to_take)
					stack.use(amount_to_take)
					if(QDELETED(stack))
						holdingitems -= stack
					beaker.reagents.add_reagent(stack.material.reagent_path, (amount_to_take * REAGENTS_PER_MATERIAL_SHEET))
			continue

		var/obj/item/reagent_containers/food/internal_snack = null
		if(istype(O, /obj/item/organ/internal))
			var/obj/item/reagent_containers/food/organ/organ_snack = locate() in O.contents
			if(istype(organ_snack))
				internal_snack = organ_snack
		else if(istype(O, /obj/item/organ/external))
			var/obj/item/reagent_containers/food/meat/meat_snack = locate() in O.contents
			if(istype(meat_snack))
				internal_snack = meat_snack

		var/remaining_o_volume = 0
		if(O.reagents)
			O.reagents.trans_to(beaker, min(O.reagents.total_volume, remaining_volume))
			remaining_o_volume += O.reagents.total_volume

		if(internal_snack?.reagents)
			internal_snack.reagents.trans_to(beaker, min(internal_snack.reagents.total_volume, remaining_volume))
			remaining_o_volume += internal_snack.reagents.total_volume

		if(remaining_o_volume <= 0)
			holdingitems -= O
			qdel(O)

		if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
