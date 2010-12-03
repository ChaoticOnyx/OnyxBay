obj/item/weapon/book
	name = "book"
	icon = 'items.dmi'
	icon_state = "book"
	var/by = "name"
	var/list/pages = list()
	var/texts
obj/item/weapon/book/attack_self(mob/user)
/*	if(!pages.len)
		user << "This book has no pages"
		return
	var/datum/bookhand/page/pagex = pages[1]
	var/dat = pagex.texts
	if(!isnull(pages[2]))
		dat += "<A href='?src=\ref[src];page=2'>Next page</A>"*/
	usr << browse(texts,"window=bookwin")
obj/item/weapon/book/Topic(href, href_list)
	if(href_list["page"])
		var/page = href_list["addr"]
		if(page)
			if(pages[page])
				var/datum/bookhand/page/pagex = page[1]
				var/dat = pagex.texts
				var/nextpage = page++
				if(pages[nextpage])
					dat += "<A href='?src=\ref[src];page=[nextpage]'>Next page</A>"
				winset(usr,"bookwin", "title=[src.name]")
				usr << browse(dat,"window=bookwin")

var/datum/bookhand/Bookhandler
datum/bookhand/page
	var/texts = null
datum/bookhand/book
	var/title
	var/bywho
	var/text
datum/bookhand
	var/list/books = list()
datum/bookhand/New()
	var/DBQuery/cquery = dbcon.NewQuery("SELECT * FROM `books`")
	if(!cquery.Execute())
		message_admins(cquery.ErrorMsg())
		log_admin(cquery.ErrorMsg())
	else
		var/list/titles = list()
		var/list/bywho = list()
		var/list/texts = list()
		while(cquery.NextRow())
			var/list/data = cquery.GetRowData()
			titles += data["title"]
			bywho[data["title"]] = data["author"]
			texts[data["title"]]  = data["text"]
		for(var/T in titles)
			var/obj/item/weapon/book/B = new()
			B.name = T
			B.by = bywho[T]
			B.texts = texts[T]
			src.books += B
	/*	if(!books.len)
			return
		var/list/books2 = list()
		for(var/datum/bookhand/book/BC in books)
			var/obj/item/weapon/book/B = new()
			B.name = BC.title
			B.by = BC.bywho
			B.text = BC.text
			books2 += B
		if(books2.len >= 1)
			world << "We got some books"*/
mob/verb/newbookhand()
	Bookhandler = new()
mob/verb/getbooks()
	for(var/obj/item/weapon/book/B in Bookhandler.books)
		usr << B.name
		B.loc = usr.loc

obj/machinery/bookcase
	name = "Bookcase"
	icon = 'computer.dmi'
	icon_state = "messyfiles"
obj/machinery/bookcase/New()
	..()
	for(var/obj/item/weapon/book/BC in Bookhandler.books)
		var/obj/item/weapon/book/B = new(src)
		B.name = BC.name
		B.by = BC.by
		B.texts = BC.texts
obj/machinery/bookcase/attack_hand(mob/user)
	var/obj/item/weapon/book/B = input(user,"Choose a book to take out","Books") as obj in src.contents
	B.loc = user.loc
