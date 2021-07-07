/*
In reply to this set of comments on lib_machines.dm:
// TODO: Make this an actual /obj/machinery/computer that can be crafted from circuit boards and such
// It is August 22nd, 2012... This TODO has already been here for months.. I wonder how long it'll last before someone does something about it.

The answer was five and a half years -ZeroBits
*/

/datum/computer_file/program/library
	filename = "library"
	filedesc = "Library"
	extended_desc = "This program can be used to view e-books from an external archive."
	program_icon_state = "word"
	program_key_state = "atmos_key"
	program_menu_icon = "note"
	size = 6
	category = PROG_OFFICE
	requires_ntnet = 1
	available_on_ntnet = 1

	nanomodule_path = /datum/nano_module/library

/datum/nano_module/library
	name = "Library"
	var/error_message = ""
	var/current_book
	var/obj/machinery/libraryscanner/scanner
	var/sort_by = "id"

/datum/nano_module/library/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.default_state)
	var/list/data = host.initial_data()

	data["admin"] = check_rights(R_INVESTIGATE, FALSE, user)
	if(error_message)
		data["error"] = error_message
	else if(current_book)
		data["current_book"] = current_book
	else
		var/list/all_entries[0]
		if(!establish_old_db_connection())
			error_message = "Unable to contact External Archive. Please contact your system administrator for assistance."
		else
			var/DBQuery/query = sql_query({"
				SELECT
					id,
					author,
					title,
					category
				FROM
					library
				ORDER BY
					$sort_by
				"}, dbcon_old, list(sort_by = sort_by))

			while(query.NextRow())
				all_entries.Add(list(list(
				"id" = query.item[1],
				"author" = query.item[2],
				"title" = query.item[3],
				"category" = query.item[4]
			)))
		data["book_list"] = all_entries
		data["scanner"] = istype(scanner)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "library.tmpl", "Library Program", 575, 700, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()

/datum/nano_module/library/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["viewbook"])
		view_book(href_list["viewbook"])
		return 1
	if(href_list["viewid"])
		view_book(input("Enter USBN:") as num|null)
		return 1
	if(href_list["closebook"])
		current_book = null
		return 1
	if(href_list["connectscanner"])
		if(!nano_host())
			return 1
		for(var/d in GLOB.cardinal)
			var/obj/machinery/libraryscanner/scn = locate(/obj/machinery/libraryscanner, get_step(nano_host(), d))
			if(scn && scn.anchored)
				scanner = scn
				return 1
	if(href_list["uploadbook"])
		if(!scanner || !scanner.anchored)
			scanner = null
			error_message = "Hardware Error: No scanner detected. Unable to access cache."
			return 1
		if(!scanner.cache)
			error_message = "Interface Error: Scanner cache does not contain any data. Please scan a book."
			return 1

		var/obj/item/weapon/book/B = scanner.cache

		if(B.unique)
			error_message = "Interface Error: Cached book is copy-protected."
			return 1

		B.SetName(input(usr, "Enter Book Title", "Title", B.name) as text|null)
		B.author = input(usr, "Enter Author Name", "Author", B.author) as text|null

		if(!B.author)
			B.author = "Anonymous"
		else if(lowertext(B.author) == "edgar allen poe" || lowertext(B.author) == "edgar allan poe")
			error_message = "User Error: Upload something original."
			return 1

		if(!B.title)
			B.title = "Untitled"

		var/choice = input(usr, "Upload [B.name] by [B.author] to the External Archive?") in list("Yes", "No")
		if(choice == "Yes")
			if(!establish_old_db_connection())
				error_message = "Network Error: Connection to the Archive has been severed."
				return 1

			var/upload_category = input(usr, "Upload to which category?") in list("Fiction", "Non-Fiction", "Reference", "Religion")

			var/DBQuery/query = sql_query({"
				INSERT INTO
					library
						(author,
						title,
						content,
						category)
				VALUES
					($author,
					$title,
					$content,
					$upload_category)
				"}, dbcon_old, list(author = B.author, title = B.name, content = B.dat, upload_category = upload_category))
			if(!query)
				error_message = "Network Error: Unable to upload to the Archive. Contact your system Administrator for assistance."
				return 1
			else
				log_and_message_admins("has uploaded the book titled [B.name], [length(B.dat)] signs")
				log_game("[usr.name]/[usr.key] has uploaded the book titled [B.name], [length(B.dat)] signs")
				alert("Upload Complete.")
			return 1

		return 0

	if(href_list["printbook"])
		if(!current_book)
			error_message = "Software Error: Unable to print; book not found."
			return 1

		//PRINT TO BINDER
		if(!nano_host())
			return 1
		for(var/d in GLOB.cardinal)
			var/obj/machinery/bookbinder/bndr = locate(/obj/machinery/bookbinder, get_step(nano_host(), d))
			if(bndr && bndr.anchored && bndr.operable())
				var/obj/item/weapon/book/new_book = bndr.print(current_book["content"], current_book["title"], current_book["author"])
				if(new_book)
					new_book.desc = current_book["author"] + ", " + current_book["title"] + ", " + "USBN " + current_book["id"]
					bndr.visible_message("\The [bndr] whirs as it prints and binds a new book.")
				return 1

		//Regular printing
		print_text("<i>Author: [current_book["author"]]<br>USBN: [current_book["id"]]</i><br><h3>[current_book["title"]]</h3><br>[current_book["content"]]", usr, rawhtml=TRUE)
		return 1
	if(href_list["sortby"])
		sort_by = href_list["sortby"]
		return 1
	if(href_list["reseterror"])
		if(error_message)
			current_book = null
			scanner = null
			sort_by = "id"
			error_message = ""
		return 1

	if(href_list["delbook"])
		if(!check_rights(R_INVESTIGATE, FALSE, usr))
			href_exploit(usr.ckey, href)
			return 1
		if(alert(usr, "Are you sure that you want to delete that book?", "Delete Book", "Yes", "No") == "Yes")
			current_book = null
			del_book_from_db(href_list["delbook"], usr)
		return 1

/datum/nano_module/library/proc/view_book(id)
	if(current_book || !id)
		return 0

	if(!establish_old_db_connection())
		error_message = "Network Error: Connection to the Archive has been severed."
		return 1

	var/DBQuery/query = sql_query("SELECT * FROM library WHERE id = $id", dbcon_old, list(id = id))

	while(query.NextRow())
		current_book = list(
			"id" = query.item[1],
			"author" = query.item[2],
			"title" = query.item[3],
			"content" = query.item[4]
			)
		break
	return 1

/proc/del_book_from_db(id, user)
	if(!id || !user)
		return
	if(!check_rights(R_INVESTIGATE, TRUE, user))
		return

	if(!establish_db_connection())
		to_chat(user, SPAN("warning", "Failed to establish database connection!"))
		return

	var/author
	var/title
	var/DBQuery/query = sql_query("SELECT author, title FROM library WHERE id = $id", dbcon, list(id = id))

	if(query.NextRow())
		author = query.item[1]
		title = query.item[2]
	else
		to_chat(user, SPAN("warning", "Book with ISBN number \[[id]\] was not found!"))
		return

	query = sql_query("DELETE FROM library WHERE id = $id", dbcon, list(id = id))
	if(query)
		log_and_message_admins("has deleted the book: \[[id]\] \"[title]\" by [author]", user)

#define WIKI_COMMON_CATEGORY "Available_in_library"
#define WIKI_HACKED_CATEGORY "Available_in_hacked_library"

/datum/computer_file/program/wiki
	filename = "wiki"
	filedesc = "Knowledge Base"
	extended_desc = "This program grants access to a vast corporate knowledge base."
	program_icon_state = "upload"
	program_key_state = "atmos_key"
	program_menu_icon = "lightbulb"
	size = 10
	category = PROG_OFFICE
	requires_ntnet = 1
	available_on_ntnet = 1

	nanomodule_path = /datum/nano_module/wiki

/datum/nano_module/wiki
	name = "Wiki"

/datum/nano_module/wiki/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 0, datum/topic_state/state = GLOB.default_state)
	var/list/data = host.initial_data()

	var/emagged = 0
	if(istype(nano_host(), /obj/item/modular_computer))
		var/obj/item/modular_computer/computer = nano_host()
		emagged = computer.computer_emagged
	if(istype(nano_host(), /datum/computer_file/program))
		var/datum/computer_file/program/program = nano_host()
		emagged = program.computer_emagged

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "wiki_topics.tmpl", "Knowledge Base", 575, 700, state = state)
		ui.add_script("wiki_topics.js")
		ui.add_script("[config.wikiurl]/api.php?action=query&list=categorymembers&cmtitle=Category:[WIKI_COMMON_CATEGORY]&cmprop=title&cmtype=page&cmlimit=100&format=json&formatversion=2&callback=parseCat")
		if(emagged)
			ui.add_script("[config.wikiurl]/api.php?action=query&list=categorymembers&cmtitle=Category:[WIKI_HACKED_CATEGORY]&cmprop=title&cmtype=page&cmlimit=100&format=json&formatversion=2&callback=parseCat")
		ui.set_initial_data(data)
		ui.open()

/datum/nano_module/wiki/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["topic"])
		var/emagged = 0
		if(istype(nano_host(), /obj/item/modular_computer))
			var/obj/item/modular_computer/computer = nano_host()
			emagged = computer.computer_emagged
		if(istype(nano_host(), /datum/computer_file/program))
			var/datum/computer_file/program/program = nano_host()
			emagged = program.computer_emagged

		// Print to connected bookbinders (if any)
		for(var/d in GLOB.cardinal)
			var/obj/machinery/bookbinder/bndr = locate(/obj/machinery/bookbinder, get_step(nano_host(), d))
			if(bndr && bndr.anchored && bndr.operable())
				bndr.print_wiki(href_list["topic"], emagged ? 0 : 1)
				return 1

		// Regular print (creates book template)
		if(istype(nano_host(), /obj/item/modular_computer))
			var/obj/item/modular_computer/computer = nano_host()
			if(!computer.nano_printer)
				to_chat(usr, SPAN("danger", "Error: No printer detected. Unable to print document."))
				return 1
		new /obj/item/weapon/book/wiki/template(get_turf(nano_host()), href_list["topic"], emagged ? 0 : 1)
		return 1

#undef WIKI_COMMON_CATEGORY
#undef WIKI_HACKED_CATEGORY
