/* Library Machines
 *
 * Contains:
 *		Library Scanner
 *		Space Binder
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
	var/obj/item/book/cache		// Last scanned book
	var/obj/item/canvas/art_cache // Last scanned art
	var/obj/item/current_item

/obj/machinery/libraryscanner/attackby(obj/O, mob/user)
	if(current_item)
		to_chat(user, SPAN_NOTICE("\The [src] already has something inside!"))
		return
	if(istype(O, /obj/item/book) || istype(O, /obj/item/canvas))
		user.drop_item()
		current_item = O
		O.forceMove(src)

/obj/machinery/libraryscanner/attack_hand(mob/user)
	usr.set_machine(src)
	var/dat = "<meta charset=\"utf-8\"><HEAD><TITLE>Scanner Control Interface</TITLE></HEAD><BODY>\n" // <META HTTP-EQUIV='Refresh' CONTENT='10'>
	if(cache || art_cache)
		dat += "<FONT color=#005500>Data stored in memory.</FONT><BR>"
	else
		dat += "No data stored in memory.<BR>"
	dat += "<A href='?src=\ref[src];scan=1'>\[Scan\]</A>"
	if(cache || art_cache)
		dat += "       <A href='?src=\ref[src];clear=1'>\[Clear Memory\]</A><BR><BR>"
		if(current_item)
			dat += "<A href='?src=\ref[src];eject=1'>\[Remove Item\]</A>"
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
		if(istype(current_item, /obj/item/book))
			cache = current_item
		if(istype(current_item, /obj/item/canvas))
			art_cache = current_item
	if(href_list["clear"])
		cache = null
		art_cache = null
	if(href_list["eject"])
		current_item.forceMove(get_turf(src))
		current_item = null
	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


/*
 * Book binder
 */
/obj/machinery/bookbinder
	name = "Space Binder"
	icon = 'icons/obj/library.dmi'
	icon_state = "binder"
	anchored = 1
	density = 1
	obj_flags = OBJ_FLAG_ANCHORABLE
	var/obj/item/print_object

/obj/machinery/bookbinder/attack_hand(mob/user)
	if(print_object)
		src.visible_message("[src] whirs as it spitting out \the [print_object].")
		print_object.forceMove(get_turf(src))
		print_object = FALSE

/obj/machinery/bookbinder/operable()
	. = ..()
	if(!anchored)
		return FALSE

/obj/machinery/bookbinder/attackby(obj/O, mob/user)
	if(operable())
		if(print_object)
			..()
			to_chat(user, "\The [src] already has item inside.")
			return
		if(istype(O, /obj/item/paper) || istype(O, /obj/item/book/wiki/template))
			user.drop_item()
			O.forceMove(src)
			user.visible_message("[user] loads some paper into [src].", "You load some paper into [src].")
			src.visible_message("[src] begins to hum as it warms up its printing drums.")
			addtimer(CALLBACK(src, .proc/handle_paper, O), rand(200,400))
		else if(istype(O, /obj/item/canvas))
			print_object = O
			user.drop_item()
			O.forceMove(src)
			user.visible_message("[user] loads \the [O] into [src].", "You load \the [O] into [src].")
		else
			..()
	else
		..()
		to_chat(user, "[src] doesn't work!")

/obj/machinery/bookbinder/proc/handle_paper(obj/item/print_book)
	if(!operable())
		visible_message("\The [src] ejects \the [print_book].")
		print_book.forceMove(get_turf(src))
		return
	src.visible_message("[src] whirs as it prints and binds a new book.")
	if(istype(print_book, /obj/item/paper))
		var/obj/item/paper/paper = print_book
		print(paper.info, "Print Job #" + "[rand(100, 999)]")
	if(istype(print_book, /obj/item/book/wiki/template))
		var/obj/item/book/wiki/template/template = print_book
		print_wiki(template.topic, template.censored)
	qdel(print_book)

/obj/machinery/bookbinder/proc/print(text, title, author)
	var/obj/item/book/book = new(src.loc)
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
	var/obj/item/book/wiki/book
	if(topic in GLOB.premade_manuals)
		var/manual_type = GLOB.premade_manuals[topic]
		book = new manual_type(src.loc, topic, censorship)
	else
		book = new /obj/item/book/wiki(src.loc, topic, censorship, WIKI_MINI)
		book.icon_state = "book[rand(1,7)]"
	return book
