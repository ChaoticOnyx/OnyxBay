/* Library Items
 *
 * Contains:
 *		Bookcase
 *		Book
 */


/*
 * Bookcase
 */

/obj/structure/bookcase
	name = "bookcase"
	icon = 'icons/obj/library.dmi'
	icon_state = "book-0"
	anchored = 1
	density = 1
	opacity = 1
	obj_flags = OBJ_FLAG_ANCHORABLE

/obj/structure/bookcase/Initialize()
	for(var/obj/item/I in loc)
		if(istype(I, /obj/item/book))
			I.forceMove(src)
	update_icon()
	. = ..()

/obj/structure/bookcase/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/book))
		if(user.drop(O, src))
			update_icon()
	else if(istype(O, /obj/item/pen))
		var/newname = sanitizeSafe(input("What would you like to title this bookshelf?"), MAX_NAME_LEN)
		if(!newname)
			return
		else
			SetName("bookcase ([newname])")
	else if(isScrewdriver(O))
		playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
		to_chat(user, SPAN("notice", "You begin dismantling \the [src]."))
		if(do_after(user,25,src))
			to_chat(user, SPAN("notice", "You dismantle \the [src]."))
			new /obj/item/stack/material/wood(get_turf(src), 5)
			for(var/obj/item/book/b in contents)
				b.dropInto(get_turf(src))
			qdel(src)

	else
		..()
	return

/obj/structure/bookcase/attack_hand(mob/user as mob)
	if(contents.len)
		var/list/titles = list()
		for(var/obj/item in contents)
			var/item_name = item.name
			if(istype(item, /obj/item/book))
				var/obj/item/book/B = item
				item_name = B.title
			titles[item_name] = item
		var/title = input("Which book would you like to remove from the shelf?") as null|anything in titles
		if(title)
			if(!CanPhysicallyInteract(user))
				return
			var/obj/choice = titles[title]
			ASSERT(choice)
			if(ishuman(user))
				user.pick_or_drop(choice)
			else
				choice.forceMove(loc)
			update_icon()

/obj/structure/bookcase/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/obj/item/book/b in contents)
				qdel(b)
			qdel(src)
			return
		if(2.0)
			for(var/obj/item/book/b in contents)
				if(prob(50))
					b.dropInto(get_turf(src))
				else
					qdel(b)
			qdel(src)
			return
		if(3.0)
			if(prob(50))
				for(var/obj/item/book/b in contents)
					b.dropInto(get_turf(src))
				qdel(src)
			return
	return

/obj/structure/bookcase/on_update_icon()
	if(contents.len < 5)
		icon_state = "book-[contents.len]"
	else
		icon_state = "book-5"



/obj/structure/bookcase/manuals/medical
	name = "Medical Manuals bookcase"

	New()
		..()
		new /obj/item/book/wiki/medical_chemistry(src)
		new /obj/item/book/wiki/medical_diagnostics_manual(src)
		new /obj/item/book/wiki/medical_diagnostics_manual(src)
		new /obj/item/book/wiki/medical_diagnostics_manual(src)
		update_icon()


/obj/structure/bookcase/manuals/engineering
	name = "Engineering Manuals bookcase"

	New()
		..()
		new /obj/item/book/wiki/engineering_construction(src)
		new /obj/item/book/wiki/engineering_hacking(src)
		new /obj/item/book/wiki/engineering_guide(src)
		new /obj/item/book/wiki/atmospipes(src)
		new /obj/item/book/wiki/engineering_singularity_safety(src)
		new /obj/item/book/wiki/powersuits(src)
		update_icon()

/obj/structure/bookcase/manuals/research_and_development
	name = "R&D Manuals bookcase"

	New()
		..()
		new /obj/item/book/wiki/research_and_development(src)
		update_icon()

/obj/structure/bookcase/prefitted
	var/prefit_category

/obj/structure/bookcase/prefitted/Initialize()
	. = ..()
	if(!prefit_category)
		return
	if(!establish_old_db_connection())
		return
	var/list/potential_books = list()
	var/DBQuery/query = sql_query("SELECT * FROM library WHERE category = $category", dbcon_old, list(category = prefit_category))
	while(query.NextRow())
		potential_books.Add(list(list(
			"id" = query.item[1],
			"author" = query.item[2],
			"title" = query.item[3],
			"content" = query.item[4]
		)))
	var/list/picked_books = list()
	for(var/i in 1 to rand(3,5))
		if(potential_books.len)
			var/r = rand(1, potential_books.len)
			var/pick = potential_books[r]
			picked_books += list(pick)
			potential_books -= list(pick)
	for(var/i in picked_books)
		var/obj/item/book/book = new(src)
		book.dat += "<font face=\"Verdana\"><i>Author: [i["author"]]<br>USBN: [i["id"]]</i><br><h3>[i["title"]]</h3></font><br>[i["content"]]"
		book.title = i["title"]
		book.author = i["author"]
		book.icon_state = "book[rand(1,7)]"
	update_icon()

/obj/structure/bookcase/prefitted/fiction
	name = "bookcase (Fiction)"
	prefit_category = "Fiction"

/obj/structure/bookcase/prefitted/nonfiction
	name = "bookcase (Non-Fiction)"
	prefit_category = "Non-Fiction"

/obj/structure/bookcase/prefitted/religious
	name = "bookcase (Religious)"
	prefit_category = "Religion"

/obj/structure/bookcase/prefitted/reference
	name = "bookcase (Reference)"
	prefit_category = "Reference"

/*
 * Book
 */
/obj/item/book
	name = "book"
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL		 //upped to three because books are, y'know, pretty big. (and you could hide them inside eachother recursively forever)
	force = 2.5
	mod_handy = 0.4
	mod_reach = 0.5
	mod_weight = 0.5
	attack_verb = list("bashed", "whacked", "educated")
	var/dat = "<meta charset=\"utf-8\">" // Actual page content
	var/author		       // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	var/unique = 0         // 0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified
	var/title = "Untitled" // The real name of the book.
	var/carved = 0         // Has the book been hollowed out for use as a secret storage item?
	var/obj/item/store	   // What's in the book?
	var/window_width = 650
	var/window_height = 650

	drop_sound = SFX_DROP_BOOK
	pickup_sound = SFX_PICKUP_BOOK

/obj/item/book/attack_self(mob/user)
	if(carved)
		if(store)
			to_chat(user, SPAN("notice", "[store] falls out of [title]!"))
			store.dropInto(user.loc)
			store = null
			return
		else
			to_chat(user, SPAN("notice", "The pages of [title] have been cut out!"))
			return
	if(src.dat)
		show_browser(user, dat, "window=book_[title];size=[window_width]x[window_height]")
		user.visible_message("[user] opens a book titled \"[src.title]\" and begins reading intently.")
		onclose(user, "book")
	else
		to_chat(user, "This book is completely blank!")

/obj/item/book/attackby(obj/item/W as obj, mob/user as mob)
	if(carved == 1)
		if(!store)
			if(W.w_class < ITEM_SIZE_NORMAL && user.drop(W, src))
				store = W
				to_chat(user, SPAN("notice", "You put [W] in [title]."))
				return
			else
				to_chat(user, SPAN("notice", "[W] won't fit in [title]."))
				return
		else
			to_chat(user, SPAN("notice", "There's already something in [title]!"))
			return
	if(istype(W, /obj/item/pen))
		if(unique)
			to_chat(user, "These pages don't seem to take the ink well. Looks like you can't modify it.")
			return
		var/choice = input("What would you like to change?") in list("Title", "Contents", "Author", "Cancel")
		switch(choice)
			if("Title")
				var/newtitle = reject_bad_text(sanitizeSafe(input("Write a new title:")))
				if(!newtitle)
					to_chat(usr, "The title is invalid.")
					return
				else
					src.SetName(newtitle)
					src.title = newtitle
			if("Contents")
				var/content = sanitize(input("Write your book's contents (HTML NOT allowed):") as message|null, MAX_BOOK_MESSAGE_LEN)
				if(!content)
					to_chat(usr, "The content is invalid.")
					return
				else
					src.dat += content
			if("Author")
				var/newauthor = sanitize(input(usr, "Write the author's name:"))
				if(!newauthor)
					to_chat(usr, "The name is invalid.")
					return
				else
					src.author = newauthor
			else
				return
	else if(istype(W, /obj/item/material/knife) || isWirecutter(W))
		if(carved)	return
		to_chat(user, SPAN("notice", "You begin to carve out [title]."))
		if(do_after(user, 30, src))
			to_chat(user, SPAN("notice", "You carve out the pages from [title]! You didn't want to read it anyway."))
			carved = 1
			return
	else
		..()

/obj/item/book/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(user.zone_sel.selecting == BP_EYES && user.a_intent == I_HELP)
		user.visible_message(
			SPAN("notice", "[user] opens up a book and shows it to [M]."),
			SPAN("notice", "You open up the book and show it to [M].")
		)
		show_browser(M, dat, "window=book_[title];size=[window_width]x[window_height]")
		user.setClickCooldown(DEFAULT_QUICK_COOLDOWN) //to prevent spam
	else
		..()

/obj/item/book/wiki
	title = ""
	unique = 1
	var/topic
	var/style = WIKI_MINI
	var/censored = 1

/obj/item/book/wiki/Initialize(mapload, ntopic, ncensored, nstyle, temporary = FALSE)
	if(ntopic)
		topic = ntopic
	if(!isnull(ncensored))
		censored = ncensored
	if(nstyle)
		style = nstyle
	if(!title)
		title = topic
	if(title)
		SetName(title)
	dat = wiki_request(topic, style, censored, src)
	if(temporary) // I hate myself for doing this
		atom_flags |= ATOM_FLAG_INITIALIZED
		return INITIALIZE_HINT_QDEL
	. = ..(mapload)

/obj/item/book/wiki/Topic(href, href_list[])
	// No parent call here
	if(href_list["title"] && initial(title) == "")
		title = href_list["title"]
		SetName(href_list["title"]) // Cirillic names are possible!
	return 1

// Put this into browse() to show a wiki topic
/proc/wiki_request(topic, style = WIKI_MINI, censorship = 0, obj/source)
	var/preamble = ""
	var/add_params = ""
	var/script = ""
	var/ref = source ? "var ref = \ref[source];" : "";
	switch(style)
		if(WIKI_FULL)
			script = "window.location='[config.link.wiki]/index.php?title=[topic]&printable=yes'"
		if(WIKI_MINI)
			script = file2text('code/js/wiki_html.js')
			add_params = "&useskin=monobook&disabletoc=true" // TODO: Whenever BYOND bug about anchor links in local files will be fixed, remove '&disabletoc=true' to allow index
		if(WIKI_MOBILE)
			script = file2text('code/js/wiki_html.js')
			add_params = "&useskin=minerva"
		if(WIKI_TEXT)
			script = file2text('code/js/wiki_text.js');
			if(source)
				show_browser(usr, icon(source.icon, source.icon_state), "file=wiki_paper.png&display=0")
			else
				show_browser(usr, icon('icons/obj/bureaucracy.dmi', "paper"), "file=wiki_paper.png&display=0")
			show_browser(usr, icon('icons/misc/mark.dmi', "rt"), "file=right_arrow.png&display=0")
			show_browser(usr, icon('icons/obj/library.dmi', "binder"), "file=bookbinder.png&display=0")
			show_browser(usr, icon('icons/obj/library.dmi', "book1"), "file=book1.png&display=0")
			preamble = {"<div style='text-align:center;border-style: dashed;'><b>This is a book template. Process it through a bookbinder to get a proper book.</b><br>
						<img src='wiki_paper.png' style='width: 32px; height: 32px;'/><img src='right_arrow.png' style='width: 32px; height: 32px;'/><img src='bookbinder.png' style='width: 32px; height: 32px;'/><img src='right_arrow.png' style='width: 32px; height: 32px;'/><img src='book1.png' style='width: 32px; height: 32px;'/>
						</div><br>"}

	return {"<!DOCTYPE html><html>
		<head><meta http-equiv=\"x-ua-compatible\" content=\"IE=edge\" charset=\"UTF-8\"></head>
		<body>[preamble]<div id='status'>Turning on...</div></body>
		<script>
		var mainPage = '[config.link.wiki]';
		var topic = '[topic][add_params]';
		var censorship = [censorship];
		[ref]
		[script]
		</script>
		</html>"}

/obj/item/book/wiki/template
	icon_state = "paper_stack"
	desc = "Bunch of unbound paper pieces."
	style = WIKI_TEXT
