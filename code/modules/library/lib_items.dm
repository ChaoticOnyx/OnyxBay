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
		if(istype(I, /obj/item/weapon/book))
			I.forceMove(src)
	update_icon()
	. = ..()

/obj/structure/bookcase/attackby(obj/O as obj, mob/user as mob)
	if(istype(O, /obj/item/weapon/book))
		user.drop_item()
		O.loc = src
		update_icon()
	else if(istype(O, /obj/item/weapon/pen))
		var/newname = sanitizeSafe(input("What would you like to title this bookshelf?"), MAX_NAME_LEN)
		if(!newname)
			return
		else
			SetName("bookcase ([newname])")
	else if(isScrewdriver(O))
		playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
		to_chat(user, "<span class='notice'>You begin dismantling \the [src].</span>")
		if(do_after(user,25,src))
			to_chat(user, "<span class='notice'>You dismantle \the [src].</span>")
			new /obj/item/stack/material/wood(get_turf(src), 5)
			for(var/obj/item/weapon/book/b in contents)
				b.loc = (get_turf(src))
			qdel(src)

	else
		..()
	return

/obj/structure/bookcase/attack_hand(mob/user as mob)
	if(contents.len)
		var/list/titles = list()
		for(var/obj/item in contents)
			var/item_name = item.name
			if(istype(item, /obj/item/weapon/book))
				var/obj/item/weapon/book/B = item
				item_name = B.title
			titles[item_name] = item
		var/title = input("Which book would you like to remove from the shelf?") as null|anything in titles
		if(title)
			if(!CanPhysicallyInteract(user))
				return
			var/obj/choice = titles[title]
			ASSERT(choice)
			if(ishuman(user))
				if(!user.get_active_hand())
					user.put_in_hands(choice)
			else
				choice.loc = get_turf(src)
			update_icon()

/obj/structure/bookcase/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/obj/item/weapon/book/b in contents)
				qdel(b)
			qdel(src)
			return
		if(2.0)
			for(var/obj/item/weapon/book/b in contents)
				if (prob(50)) b.loc = (get_turf(src))
				else qdel(b)
			qdel(src)
			return
		if(3.0)
			if (prob(50))
				for(var/obj/item/weapon/book/b in contents)
					b.loc = (get_turf(src))
				qdel(src)
			return
		else
	return

/obj/structure/bookcase/update_icon()
	if(contents.len < 5)
		icon_state = "book-[contents.len]"
	else
		icon_state = "book-5"



/obj/structure/bookcase/manuals/medical
	name = "Medical Manuals bookcase"

	New()
		..()
		new /obj/item/weapon/book/wiki/medical_chemistry(src)
		new /obj/item/weapon/book/wiki/medical_diagnostics_manual(src)
		new /obj/item/weapon/book/wiki/medical_diagnostics_manual(src)
		new /obj/item/weapon/book/wiki/medical_diagnostics_manual(src)
		update_icon()


/obj/structure/bookcase/manuals/engineering
	name = "Engineering Manuals bookcase"

	New()
		..()
		new /obj/item/weapon/book/wiki/engineering_construction(src)
		new /obj/item/weapon/book/wiki/engineering_hacking(src)
		new /obj/item/weapon/book/wiki/engineering_guide(src)
		new /obj/item/weapon/book/wiki/atmospipes(src)
		new /obj/item/weapon/book/wiki/engineering_singularity_safety(src)
		new /obj/item/weapon/book/wiki/hardsuits(src)
		update_icon()

/obj/structure/bookcase/manuals/research_and_development
	name = "R&D Manuals bookcase"

	New()
		..()
		new /obj/item/weapon/book/wiki/research_and_development(src)
		update_icon()


/*
 * Book
 */
/obj/item/weapon/book
	name = "book"
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL		 //upped to three because books are, y'know, pretty big. (and you could hide them inside eachother recursively forever)
	attack_verb = list("bashed", "whacked", "educated")
	var/dat = "<meta charset=\"utf-8\">" // Actual page content
	var/author		       // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	var/unique = 0         // 0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified
	var/title = "Untitled" // The real name of the book.
	var/carved = 0         // Has the book been hollowed out for use as a secret storage item?
	var/obj/item/store	   // What's in the book?
	var/window_width = 650
	var/window_height = 650

/obj/item/weapon/book/attack_self(mob/user as mob)
	if(carved)
		if(store)
			to_chat(user, "<span class='notice'>[store] falls out of [title]!</span>")
			store.loc = get_turf(src.loc)
			store = null
			return
		else
			to_chat(user, "<span class='notice'>The pages of [title] have been cut out!</span>")
			return
	if(src.dat)
		user << browse(dat, "window=book_[title];size=[window_width]x[window_height]")
		user.visible_message("[user] opens a book titled \"[src.title]\" and begins reading intently.")
		onclose(user, "book")
	else
		to_chat(user, "This book is completely blank!")

/obj/item/weapon/book/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(carved == 1)
		if(!store)
			if(W.w_class < ITEM_SIZE_NORMAL)
				user.drop_item()
				W.loc = src
				store = W
				to_chat(user, "<span class='notice'>You put [W] in [title].</span>")
				return
			else
				to_chat(user, "<span class='notice'>[W] won't fit in [title].</span>")
				return
		else
			to_chat(user, "<span class='notice'>There's already something in [title]!</span>")
			return
	if(istype(W, /obj/item/weapon/pen))
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
	else if(istype(W, /obj/item/weapon/material/knife) || isWirecutter(W))
		if(carved)	return
		to_chat(user, "<span class='notice'>You begin to carve out [title].</span>")
		if(do_after(user, 30, src))
			to_chat(user, "<span class='notice'>You carve out the pages from [title]! You didn't want to read it anyway.</span>")
			carved = 1
			return
	else
		..()

/obj/item/weapon/book/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(user.zone_sel.selecting == BP_EYES)
		user.visible_message("<span class='notice'>You open up the book and show it to [M]. </span>", \
			"<span class='notice'> [user] opens up a book and shows it to [M]. </span>")
		M << browse(dat, "window=book_[title];size=[window_width]x[window_height]")
		user.setClickCooldown(DEFAULT_QUICK_COOLDOWN) //to prevent spam

/obj/item/weapon/book/wiki
	title = ""
	unique = 1
	var/topic
	var/style = WIKI_MINI
	var/censored = 1

/obj/item/weapon/book/wiki/Initialize(mapload, ntopic, ncensored, nstyle)
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
	. = ..(mapload)

/obj/item/weapon/book/wiki/Topic(href, href_list[])
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
			script = "window.location='[config.wikiurl]/index.php?title=[topic]&printable=yes'"
		if(WIKI_MINI)
			script = file2text('code/js/wiki_html.js')
			add_params = "&useskin=monobook&disabletoc=true" // TODO: Whenever BYOND bug about anchor links in local files will be fixed, remove '&disabletoc=true' to allow index
		if(WIKI_MOBILE)
			script = file2text('code/js/wiki_html.js')
			add_params = "&useskin=minerva"
		if(WIKI_TEXT)
			script = file2text('code/js/wiki_text.js');
			if(source)
				usr << browse(icon(source.icon, source.icon_state), "file=wiki_paper.png&display=0")
			else
				usr << browse(icon('icons/obj/bureaucracy.dmi', "paper"), "file=wiki_paper.png&display=0")
			usr << browse(icon('icons/misc/mark.dmi', "rt"), "file=right_arrow.png&display=0")
			usr << browse(icon('icons/obj/library.dmi', "binder"), "file=bookbinder.png&display=0")
			usr << browse(icon('icons/obj/library.dmi', "book1"), "file=book1.png&display=0")
			preamble = {"<div style='text-align:center;border-style: dashed;'><b>This is a book template. Process it through a bookbinder to get a proper book.</b><br>
						<img src='wiki_paper.png' style='width: 32px; height: 32px;'/><img src='right_arrow.png' style='width: 32px; height: 32px;'/><img src='bookbinder.png' style='width: 32px; height: 32px;'/><img src='right_arrow.png' style='width: 32px; height: 32px;'/><img src='book1.png' style='width: 32px; height: 32px;'/>
						</div><br>"}

	return {"<!DOCTYPE html><html>
		<head><meta http-equiv=\"x-ua-compatible\" content=\"IE=edge\" charset=\"UTF-8\"></head>
		<body>[preamble]<div id='status'>Turning on...</div></body>
		<script>
		var mainPage = '[config.wikiurl]';
		var topic = '[topic][add_params]';
		var censorship = [censorship];
		[ref]
		[script]
		</script>
		</html>"}

/obj/item/weapon/book/wiki/template
	icon_state = "paper_stack"
	desc = "Bunch of unbound paper pieces."
	style = WIKI_TEXT
