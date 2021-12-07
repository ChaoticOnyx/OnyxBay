/* Library Machines
 *
 * Contains:
 *		Library Scanner
 *		Book Binder
 */

/*
 * Library Scanner
 */
/obj/machinery/libraryscanner
	name = "scanner"
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"
	anchored = 1
	density = 1
	var/obj/item/weapon/book/cache		// Last scanned book

/obj/machinery/libraryscanner/attackby(obj/O as obj, mob/user as mob)
	if(istype(O, /obj/item/weapon/book))
		user.drop_item()
		O.loc = src

/obj/machinery/libraryscanner/attack_hand(mob/user as mob)
	usr.set_machine(src)
	var/dat = "<meta charset=\"utf-8\"><HEAD><TITLE>Scanner Control Interface</TITLE></HEAD><BODY>\n" // <META HTTP-EQUIV='Refresh' CONTENT='10'>
	if(cache)
		dat += "<FONT color=#005500>Data stored in memory.</FONT><BR>"
	else
		dat += "No data stored in memory.<BR>"
	dat += "<A href='?src=\ref[src];scan=1'>\[Scan\]</A>"
	if(cache)
		dat += "       <A href='?src=\ref[src];clear=1'>\[Clear Memory\]</A><BR><BR><A href='?src=\ref[src];eject=1'>\[Remove Book\]</A>"
	else
		dat += "<BR>"
	show_browser(user, dat, "window=scanner")
	onclose(user, "scanner")

/obj/machinery/libraryscanner/Topic(href, href_list)
	if(..())
		close_browser(usr, "window=scanner")
		onclose(usr, "scanner")
		return

	if(href_list["scan"])
		for(var/obj/item/weapon/book/B in contents)
			cache = B
			break
	if(href_list["clear"])
		cache = null
	if(href_list["eject"])
		for(var/obj/item/weapon/book/B in contents)
			B.loc = src.loc
	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


/*
 * Book binder
 */
/obj/machinery/bookbinder
	name = "Book Binder"
	icon = 'icons/obj/library.dmi'
	icon_state = "binder"
	anchored = 1
	density = 1

/obj/machinery/bookbinder/attackby(obj/O as obj, mob/user as mob)
	if(operable())
		if(istype(O, /obj/item/weapon/paper) || istype(O, /obj/item/weapon/book/wiki/template))
			user.drop_item()
			O.loc = src
			user.visible_message("[user] loads some paper into [src].", "You load some paper into [src].")
			src.visible_message("[src] begins to hum as it warms up its printing drums.")
			sleep(rand(200,400))
			src.visible_message("[src] whirs as it prints and binds a new book.")
			if(istype(O, /obj/item/weapon/paper))
				var/obj/item/weapon/paper/paper = O
				print(paper.info, "Print Job #" + "[rand(100, 999)]")
			if(istype(O, /obj/item/weapon/book/wiki/template))
				var/obj/item/weapon/book/wiki/template/template = O
				print_wiki(template.topic, template.censored)
			qdel(O)
		else
			..()
	else
		..()
		to_chat(user, "[src] doesn't work!")

/obj/machinery/bookbinder/proc/print(text, title, author)
	var/obj/item/weapon/book/book = new(src.loc)
	if(text)
		book.dat += text
	if(title)
		book.title = title
		book.SetName(title)
	if(author)
		book.author = author
	book.icon_state = "book[rand(1,7)]"
	return book

/obj/machinery/bookbinder/proc/print_wiki(topic, censorship)
	var/obj/item/weapon/book/wiki/book
	if(topic in GLOB.premade_manuals)
		var/manual_type = GLOB.premade_manuals[topic]
		book = new manual_type(src.loc, topic, censorship)
	else
		book = new /obj/item/weapon/book/wiki(src.loc, topic, censorship, WIKI_MINI)
		book.icon_state = "book[rand(1,7)]"
	return book
