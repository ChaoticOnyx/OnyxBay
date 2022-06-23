/datum/computer_file/program/art_library
	filename = "art library"
	filedesc = "Art library"
	extended_desc = "This program can be used to view pictures from an external archive."
	program_icon_state = "word"
	program_key_state = "atmos_key"
	program_menu_icon = "note"
	size = 6
	category = PROG_OFFICE
	requires_ntnet = 1
	available_on_ntnet = 1

	nanomodule_path = /datum/nano_module/art_library

//getFlatIcon

/datum/nano_module/art_library
	name = "Art library"
	var/error_message = ""
	var/sort_by = "id"
	var/current_art
	var/obj/machinery/libraryscanner/scanner
	var/static/list/icon_cache = list()
	var/static/list/canvas_state_to_type = list()

/datum/nano_module/art_library/New(datum/host, topic_manager)
	. = ..()
	if(!length(canvas_state_to_type))
		for(var/canvas_type in typesof(/obj/item/canvas))
			var/obj/item/canvas/C = new canvas_type()
			canvas_state_to_type[C.icon_state] = canvas_type

/datum/nano_module/art_library/Destroy()
	. = ..()

/datum/nano_module/art_library/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.default_state)
	var/list/data = host.initial_data()

	data["admin"] = check_rights(R_INVESTIGATE, FALSE, user)
	if(error_message)
		data["error"] = error_message
	else if(current_art)
		data["current_art"] = current_art
	else
		var/list/all_entries[0]
		if(!establish_old_db_connection())
			error_message = "Unable to contact External Archive. Please contact your system administrator for assistance."
		else
			try
				var/DBQuery/query = sql_query({"
					SELECT
						id,
						ckey,
						title,
						data,
						type
					FROM
						art_library
					ORDER BY
						$sort_by
					"}, dbcon_old, list(sort_by = sort_by))

				while(query.NextRow())
					all_entries.Add(list(list(
					"id" = query.item[1],
					"ckey" = query.item[2],
					"title" = query.item[3],
					"data" = query.item[4],
					"type" = query.item[5]
				)))
			catch
				error_message = "Unable to receive arts form External Archive. Please contact your system administrator for assistance."
		data["art_list"] = all_entries
		data["scanner"] = istype(scanner)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "art_library.tmpl", "Art library Program", 575, 700, state = state)
		ui.auto_update_layout = TRUE
		ui.set_initial_data(data)
		ui.open()

/datum/nano_module/art_library/Topic(href, href_list)
	if(..())
		return TRUE
	if(href_list["viewart"])
		view_art(href_list["viewart"])
		return TRUE
	if(href_list["viewid"])
		var/id = input("Enter USBN:") as num|null
		if(isnum_safe(id))
			view_art(id)
		return TRUE
	if(href_list["closeart"])
		current_art = null
		return TRUE
	if(href_list["connectscanner"])
		if(!nano_host())
			return TRUE
		for(var/d in GLOB.alldirs)
			var/obj/machinery/libraryscanner/scn = locate(/obj/machinery/libraryscanner, get_step(nano_host(), d))
			if(scn && scn.anchored)
				scanner = scn
				return TRUE
	if(href_list["uploadart"])
		if(!scanner || !scanner.anchored)
			scanner = null
			error_message = "Hardware Error: No scanner detected. Unable to access cache."
			return TRUE
		if(!scanner.art_cache)
			error_message = "Interface Error: Scanner cache does not contain any data. Please scan a art."
			return TRUE

		var/obj/item/canvas/art_cache = scanner.art_cache
		var/encoded_data = art_cache.to_json()
		if(!encoded_data)
			return
		var/choice = input(usr, "Upload [art_cache.painting_name] to the External Archive?") in list("Yes", "No")
		if(choice == "Yes")
			if(!establish_old_db_connection())
				error_message = "Network Error: Connection to the Archive has been severed."
				return TRUE
			var/DBQuery/query = sql_query({"
				INSERT INTO
					art_library
						(ckey,
						title,
						data,
						type)
				VALUES
					($ckey,
					$title,
					$data,
					$type)
				"}, dbcon_old, list(ckey = art_cache.author_ckey, title = art_cache.painting_name, data = encoded_data, type = art_cache.icon_state))
			if(!query)
				error_message = "Network Error: Unable to upload to the Archive. Contact your system Administrator for assistance."
				return TRUE
			else
				log_and_message_admins("has uploaded the art titled [art_cache.painting_name], [length(encoded_data)] signs of data")
				log_game("[usr.name]/[usr.key] has uploaded the art titled [art_cache.painting_name], [length(encoded_data)] signs of data")
				alert("Upload Complete.")
			return TRUE

		return FALSE

	if(href_list["printart"])
		if(!current_art)
			error_message = "Software Error: Unable to print; art not found."
			return TRUE

		//PRINT TO BINDER
		var/atom/lib_host = nano_host()
		if(!lib_host)
			return TRUE
		for(var/d in GLOB.alldirs)
			var/obj/machinery/bookbinder/bndr = locate(/obj/machinery/bookbinder, get_step(lib_host, d))
			if(bndr && bndr.operable())
				if(!istype(bndr.print_object, /obj/item/canvas) || bndr.print_object?.icon_state != current_art["type"])
					error_message = "Software Error: Unable to print; the wrong canvas type of canvas in book binder, or the canvas is missing."
					return TRUE
				var/obj/item/canvas/new_art = bndr.print_object
				if(!new_art.finalized)
					new_art.apply_canvas_data(current_art["data"])
					new_art.finalize()
					new_art.forceMove(get_turf(bndr))
					bndr.visible_message("\The [bndr] whirs as it prints a new art.")
				return TRUE
		error_message = "Software Error: Unable to print; book binder not found."
		return TRUE
	if(href_list["sortby"])
		sort_by = href_list["sortby"]
		return TRUE
	if(href_list["reseterror"])
		if(error_message)
			current_art = null
			scanner = null
			sort_by = "id"
			error_message = ""
		return TRUE

	if(href_list["delart"])
		if(!check_rights(R_INVESTIGATE, FALSE, usr))
			href_exploit(usr.ckey, href)
			return TRUE
		if(alert(usr, "Are you sure that you want to delete that art?", "Delete Art", "Yes", "No") == "Yes")
			current_art = null
			del_art_from_db(href_list["delart"], usr)
		return TRUE

/datum/nano_module/art_library/proc/view_art(id)
	if(current_art || !id)
		return FALSE

	if(!establish_old_db_connection())
		error_message = "Network Error: Connection to the Archive has been severed."
		return TRUE

	try
		var/DBQuery/query = sql_query("SELECT * FROM art_library WHERE id = $id", dbcon_old, list(id = id))

		while(query.NextRow())
			var/art_type = query.item[6]
			var/canvas_type = canvas_state_to_type[art_type]
			var/obj/item/canvas/preview_canvas = new canvas_type()
			var/art_icon
			preview_canvas.icon_generated = FALSE
			preview_canvas.apply_canvas_data(query.item[4])
			preview_canvas.paint_image()
			var/icon/pre_icon = getFlatIcon(preview_canvas)
			switch(art_type)
				if("11x11")
					pre_icon.Crop(11, 21, 21, 11)
				if("19x19")
					pre_icon.Crop(8, 27, 26, 9)
				if("23x19")
					pre_icon.Crop(6, 26, 28, 8)
				if("23x23")
					pre_icon.Crop(6, 27, 28, 5)
				if("24x24")
					pre_icon.Crop(5, 27, 28, 4)
			art_icon = icon2base64(pre_icon)
			icon_cache[query.item[3]] = art_icon
			current_art = list(
				"id" = query.item[1],
				"ckey" = query.item[2],
				"title" = query.item[3],
				"data" = query.item[4],
				"icon" = art_icon,
				"type" = art_type
				)
			QDEL_NULL(preview_canvas)
			break
	catch
		error_message = "Network Error: Connection to the Archive has been severed."
	return TRUE

/proc/del_art_from_db(id, user)
	if(!id || !user)
		return
	if(!check_rights(R_INVESTIGATE, TRUE, user))
		return

	if(!establish_db_connection())
		to_chat(user, SPAN_WARNING("Failed to establish database connection!"))
		return

	var/author
	var/title
	var/DBQuery/query = sql_query("SELECT ckey, title FROM art_library WHERE id = $id", dbcon, list(id = id))

	if(query.NextRow())
		author = query.item[1]
		title = query.item[2]
	else
		to_chat(user, SPAN_WARNING("Art with ISAN number \[[id]\] was not found!"))
		return

	query = sql_query("DELETE FROM art_library WHERE id = $id", dbcon, list(id = id))
	if(query)
		log_and_message_admins("has deleted the art: \[[id]\] \"[title]\" by [author]", user)
