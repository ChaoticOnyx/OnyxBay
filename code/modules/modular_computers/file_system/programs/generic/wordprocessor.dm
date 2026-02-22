/datum/computer_file/program/wordprocessor
	filename = "wordprocessor"
	filedesc = "NanoWord"
	extended_desc = "This program allows the editing and preview of text documents."
	program_icon_state = "word"
	program_key_state = "atmos_key"
	program_light_color = "#4273E7"
	size = 4
	category = PROG_OFFICE
	requires_ntnet = 0
	available_on_ntnet = 1
	nanomodule_path = /datum/nano_module/program/computer_wordprocessor/
	var/browsing
	var/open_file
	var/loaded_data
	var/error
	var/is_edited
	var/current_page = 1
	use_tgui = TRUE

	var/static/const/PAGE_DELIM = "\n<---PAGE BREAK--->\n"

/datum/computer_file/program/wordprocessor/proc/open_file(filename)
	var/datum/computer_file/data/F = get_file(filename)
	if(F)
		open_file = F.filename
		loaded_data = F.stored_data
		return 1

/datum/computer_file/program/wordprocessor/proc/save_file(filename)
	var/datum/computer_file/data/F = get_file(filename)
	if(!F) //try to make one if it doesn't exist
		F = create_file(filename, loaded_data, /datum/computer_file/data/text)
		return !QDELETED(F)
	var/datum/computer_file/data/backup = F.clone()
	var/obj/item/computer_hardware/hard_drive/HDD = computer.hard_drive
	if(!HDD)
		return
	HDD.remove_file(F)
	F.stored_data = loaded_data
	F.calculate_size()
	if(!HDD.store_file(F))
		HDD.store_file(backup)
		return 0
	is_edited = 0
	return 1

/datum/computer_file/program/wordprocessor/proc/_ensure_loaded()
	if(isnull(loaded_data))
		loaded_data = ""

/datum/computer_file/program/wordprocessor/proc/get_pages()
	_ensure_loaded()
	var/text = "[loaded_data]"
	if(!length(text))
		return list("")

	var/list/pages = splittext(text, PAGE_DELIM)
	if(!pages || !pages.len)
		return list("")

	return pages

/datum/computer_file/program/wordprocessor/proc/set_pages(list/pages)
	if(!pages || !pages.len)
		loaded_data = ""
		return

	loaded_data = jointext(pages, PAGE_DELIM)

/datum/computer_file/program/wordprocessor/proc/clamp_current_page()
	var/list/pages = get_pages()
	if(current_page < 1) current_page = 1
	if(current_page > pages.len) current_page = pages.len
	if(current_page < 1) current_page = 1

/datum/computer_file/program/wordprocessor/proc/get_page_raw(page_index)
	var/list/pages = get_pages()
	if(page_index < 1 || page_index > pages.len)
		return ""
	return "[pages[page_index]]"

/datum/computer_file/program/wordprocessor/proc/set_page_raw(page_index, text)
	var/list/pages = get_pages()
	if(page_index < 1) page_index = 1
	if(page_index > pages.len) page_index = pages.len
	pages[page_index] = text
	set_pages(pages)

/datum/computer_file/program/wordprocessor/proc/add_page(after_index)
	var/list/pages = get_pages()
	if(after_index < 0) after_index = 0
	if(after_index > pages.len) after_index = pages.len
	pages.Insert(after_index + 1, "")
	set_pages(pages)

/datum/computer_file/program/wordprocessor/proc/delete_page(page_index)
	var/list/pages = get_pages()
	if(pages.len <= 1)
		pages[1] = ""
	else
		if(page_index < 1) page_index = 1
		if(page_index > pages.len) page_index = pages.len
		pages.Cut(page_index, page_index + 1)
	set_pages(pages)

/datum/computer_file/program/wordprocessor/proc/move_page(from_index, to_index)
	var/list/pages = get_pages()
	if(from_index < 1 || from_index > pages.len) return
	if(to_index < 1) to_index = 1
	if(to_index > pages.len) to_index = pages.len
	if(from_index == to_index) return

	var/tmp = pages[from_index]
	pages.Cut(from_index, from_index + 1)
	pages.Insert(to_index, tmp)
	set_pages(pages)

/datum/computer_file/program/wordprocessor/proc/_doc_display_name()
	if(open_file && length(open_file))
		return "[open_file]"
	return "UNNAMED"

/datum/computer_file/program/wordprocessor/proc/print_page_to_paper(page_index)
	if(!computer || !computer.nano_printer)
		error = "Missing Hardware: Your computer does not have the required hardware to complete this operation."
		return null

	var/list/pages = get_pages()
	if(page_index < 1 || page_index > pages.len)
		return null

	var/docname = _doc_display_name()

	var/obj/item/paper/P = computer.nano_printer.print_text_paper(pages[page_index], paper_title="[docname] - page [page_index]")
	if(!P)
		error = "Hardware error: Printer was unable to print the file. It may be out of paper."
		return null

	return P

/datum/computer_file/program/wordprocessor/proc/print_pages_bundle(from_page = 1, to_page = 0)
	var/list/pages = get_pages()
	if(!pages || !pages.len)
		return FALSE
	
	if(from_page==to_page)
		return isnull(print_page_to_paper(from_page))

	if(to_page <= 0)
		to_page = pages.len

	from_page = clamp(from_page, 1, pages.len)
	to_page = clamp(to_page, 1, pages.len)
	if(to_page < from_page)
		var/tmp = from_page
		from_page = to_page
		to_page = tmp

	var/docname = _doc_display_name()
	var/obj/item/paper_bundle/B = new(get_turf(computer))
	B.SetName("[docname]")

	B.pages = list()
	B.page = 1

	for(var/i = from_page; i <= to_page; i++)
		var/obj/item/paper/P = print_page_to_paper(i)
		if(!P)
			qdel(B)
			return FALSE
		B.insert_sheet_at(null, B.pages.len + 1, P)
	B.page = 1
	B.update_icon()
	return TRUE

/datum/nano_module/program/computer_wordprocessor
	name = "Word Processor"

/datum/nano_module/program/computer_wordprocessor/tgui_state(mob/user)
	var test = program.computer.tgui_state(user)
	return test

/datum/nano_module/program/computer_wordprocessor/ui_status(mob/user, datum/ui_state/state)
	var test = program.computer.ui_status(user, state)
	return test

/datum/nano_module/program/computer_wordprocessor/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "WordProcessor")
		ui.open()

/datum/nano_module/program/computer_wordprocessor/tgui_data(mob/user)
	var/list/data = list()
	var/datum/computer_file/program/wordprocessor/PRG = program

	if(PRG?.computer)
		var/list/pc = PRG.computer.get_header_data(user)
		for(var/k in pc)
			data[k] = pc[k]
				
				
	if(PRG.error)
		data["error"] = PRG.error

	data["browsing"] = !!PRG.browsing
	data["filename"] = PRG.open_file ? (PRG.is_edited ? "[PRG.open_file]*" : PRG.open_file) : "UNNAMED"

	if(PRG.browsing)
		if(!PRG.computer || !PRG.computer.hard_drive)
			data["error"] = "I/O ERROR: Unable to access hard drive."
			return data

		var/obj/item/computer_hardware/hard_drive/HDD = PRG.computer.hard_drive
		var/list/files = list()
		for(var/datum/computer_file/F in HDD.stored_files)
			if(F.filetype == "TXT")
				files += list(list("name" = F.filename, "size" = F.size))
		data["files"] = files

		var/obj/item/computer_hardware/hard_drive/portable/RHDD = PRG.computer.portable_drive
		if(RHDD)
			data["usbconnected"] = TRUE
			var/list/usbfiles = list()
			for(var/datum/computer_file/F in RHDD.stored_files)
				if(F.filetype == "TXT")
					usbfiles += list(list("name" = F.filename, "size" = F.size))
			data["usbfiles"] = usbfiles

		return data

	PRG.clamp_current_page()
	var/list/pages = PRG.get_pages()
	data["page_index"] = PRG.current_page
	data["page_count"] = pages.len

	var/page_raw = PRG.get_page_raw(PRG.current_page)
	var/page_html = pencode2html(page_raw)
	page_html = replacetext(page_html, "<table", "<table class='nword'")
	data["page_html"] = page_html

	var/list/page_titles = list()
	for(var/i = 1; i <= pages.len; i++)
		var/t = "[pages[i]]"
		t = copytext(t, 1, min(length(t) + 1, 64))
		if(!length(t)) t = "—"
		page_titles += list(list("i" = i, "title" = t))
	data["pages"] = page_titles

	return data

/datum/nano_module/program/computer_wordprocessor/tgui_act(action, params)
	. = ..()
	if(.)
		return TRUE

	var/datum/computer_file/program/wordprocessor/PRG = program

	if(action == "PC_shutdown" || action == "PC_exit" || action == "PC_minimize")
		if(PRG?.computer)
			SStgui.close_uis(src)
			return PRG.computer.tgui_act(action, params)

	switch(action)
		if("back_to_menu")
			PRG.error = null
			return TRUE

		if("load_menu")
			PRG.browsing = TRUE
			return TRUE

		if("close_browser")
			PRG.browsing = FALSE
			return TRUE

		if("open_file")
			if(PRG.is_edited)
				if(alert("Would you like to save your changes first?",,"Yes","No") == "Yes")
					PRG.save_file(PRG.open_file)

			PRG.browsing = FALSE
			if(!PRG.open_file(params["name"]))
				PRG.error = "I/O error: Unable to open file '[params["name"]]'."
			PRG.current_page = 1
			return TRUE

		if("new_file")
			if(PRG.is_edited)
				if(alert("Would you like to save your changes first?",,"Yes","No") == "Yes")
					PRG.save_file(PRG.open_file)

			var/newname = sanitize(input(usr, "Enter file name:", "New File") as text|null)
			if(!newname)
				return TRUE

			var/datum/computer_file/data/F = PRG.create_file(newname, "", /datum/computer_file/data/text)
			if(F)
				PRG.open_file = F.filename
				PRG.loaded_data = ""
				PRG.is_edited = FALSE
				PRG.current_page = 1
			else
				PRG.error = "I/O error: Unable to create file '[newname]'."
			return TRUE

		if("save_file")
			if(!PRG.open_file)
				PRG.open_file = sanitize(input(usr, "Enter file name:", "Save As") as text|null)
				if(!PRG.open_file)
					return TRUE
			if(!PRG.save_file(PRG.open_file))
				PRG.error = "I/O error: Unable to save file '[PRG.open_file]'."
			return TRUE

		if("save_as")
			var/newname2 = sanitize(input(usr, "Enter file name:", "Save As") as text|null)
			if(!newname2)
				return TRUE
			var/datum/computer_file/data/F2 = PRG.create_file(newname2, PRG.loaded_data, /datum/computer_file/data/text)
			if(F2)
				PRG.open_file = F2.filename
			else
				PRG.error = "I/O error: Unable to create file '[newname2]'."
			return TRUE

		if("set_page")
			PRG.current_page = text2num(params["i"])
			PRG.clamp_current_page()
			return TRUE

		if("add_page_after")
			var/i_add = text2num(params["i"])
			PRG.add_page(i_add)
			PRG.current_page = i_add + 1
			PRG.is_edited = TRUE
			return TRUE

		if("delete_page")
			var/i_del = text2num(params["i"])
			PRG.delete_page(i_del)
			PRG.current_page = i_del
			PRG.clamp_current_page()
			PRG.is_edited = TRUE
			return TRUE

		if("move_page")
			var/from_i = text2num(params["from"])
			var/to_i = text2num(params["to"])
			PRG.move_page(from_i, to_i)
			PRG.current_page = to_i
			PRG.clamp_current_page()
			PRG.is_edited = TRUE
			return TRUE

		if("duplicate_page")
			var/i_dup = text2num(params["i"])
			var/list/pages = PRG.get_pages()
			if(i_dup >= 1 && i_dup <= pages.len)
				pages.Insert(i_dup + 1, "[pages[i_dup]]")
				PRG.set_pages(pages)
				PRG.current_page = i_dup + 1
				PRG.is_edited = TRUE
			return TRUE

		if("edit_page")
			var/i_edit = text2num(params["i"])
			PRG.clamp_current_page()

			var/oldtext = html_decode(PRG.get_page_raw(i_edit))
			oldtext = replacetext(oldtext, "\[br\]", "\n")
			
			var/newtext = tgui_input_pencode_editor(
				usr,
				"Editing page [i_edit]. Document: '[PRG.open_file ? PRG.open_file : "UNNAMED"]'",
				"NanoWord",
				oldtext,
				MAX_PAPER_MESSAGE_LEN,
				FALSE,
				0
			)

			if(isnull(newtext))
				return TRUE

				
			newtext = sanitize(replacetext(newtext, "\n", "\[br\]"), MAX_TEXTFILE_LENGTH)
			PRG.set_page_raw(i_edit, newtext)


			var/list/check_pages = PRG.get_pages()
			var/total_text = jointext(check_pages, PRG.PAGE_DELIM)
			if(length(total_text) > MAX_TEXTFILE_LENGTH)
				to_chat(usr, SPAN_WARNING("File is too large. Reduce text or pages."))
				return TRUE
				
			var/list/all_pages = PRG.get_pages()
			var/all_text = jointext(all_pages, "\n")
			var/laststart = 1
			var/fields = 0
			while(TRUE)
				var/p = findtext_char(all_text, "\[field\]", laststart)
				if(p == 0) break
				laststart = p + 1
				fields++
			if(fields > 50)
				to_chat(usr, SPAN_WARNING("Too many fields. Sorry, you can't do this."))
				PRG.set_page_raw(i_edit, sanitize(replacetext(oldtext, "\n", "\[br\]"), MAX_TEXTFILE_LENGTH))
				return TRUE

			PRG.is_edited = TRUE
			return TRUE

		if("preview_page")
			var/ip = text2num(params["i"])
			var/page_raw = PRG.get_page_raw(ip)
			show_browser(usr, "<HTML><meta charset=\"utf-8\"><HEAD><TITLE>[PRG.open_file]</TITLE></HEAD>[pencode2html(page_raw)]</BODY></HTML>", "window=file_[PRG.open_file]_p[ip]")
			return TRUE

		if("print_page")
			var/ip2 = text2num(params["i"])
			PRG.print_page_to_paper(ip2)
			return TRUE

		if("print_all")
			var/list/pages = PRG.get_pages()
			var/maxp = pages.len

			var/fromp = input(usr, "Print from page (1..[maxp])", "Print Range", 1) as num|null
			if(isnull(fromp)) return TRUE
			var/top = input(usr, "Print to page (1..[maxp])", "Print Range", maxp) as num|null
			if(isnull(top)) return TRUE

			PRG.print_pages_bundle(fromp, top)
			return TRUE

		if("taghelp")
			var/phrase = pick(list(\
				"NanoWord autosave triggered. Your procrastination is now permanently documented.",\
				"Spellcheck complete. Confidence level: suspiciously high.",\
				"NanoWord suggests adding more buzzwords to increase perceived competence.",\
				"Document recovered from unexpected shutdown. Cause: “totally not sabotage.”",\
				"Formatting normalized. Chaos reduced to a manageable level.",\
				"NanoWord reminder: shouting in all caps does not improve report credibility.",\
				"Insert table successful. Nobody will read it, but it looks impressive.",\
				"NanoWord encountered creative writing. Flagging as “incident report.”",\
				"Grammar check complete. Responsibility for remaining errors transferred to the author.",\
				"Document size exceeded expectations. Engineering has been notified.",\
				"NanoWord tip: adding a signature increases authority by up to 12%.",\
				"Autosave paused briefly to question your life choices.",\
				"NanoWord successfully ignored several questionable formatting decisions.",\
				"Revision history updated. Evidence carefully preserved for future investigations.",\
				"Document printed. Ink levels remain legally ambiguous",\
			))
			to_chat(usr, SPAN_NOTICE("The hologram of a googly-eyed paper clip helpfully tells you:[phrase]"))
			
			return TRUE

	return FALSE
