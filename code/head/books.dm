/*
Catagories
-----------
Fiction
Engineering
Medical
History
Business
Self-Help
Science
Religion
Cooking
*/
#define Fiction 1
#define Engineering 2
#define Medical 3
#define History 4
#define Business 5
#define SelfHelp 6
#define Science 7
#define Religion 8
#define Cooking 9
obj/item/weapon/book
	name = "book"
	icon = 'items.dmi'
	icon_state = "book"
	var/by = "name"
	var/list/pages = list()
	var/texts
	var/cat = Fiction
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
		var/list/cats = list()
		while(cquery.NextRow())
			var/list/data = cquery.GetRowData()
			titles += data["title"]
			bywho[data["title"]] = data["author"]
			texts[data["title"]]  = data["text"]
			cats[data["title"]] = text2num(data["cat"])
		for(var/T in titles)
			var/obj/item/weapon/book/B = new()
			B.name = T
			B.by = bywho[T]
			B.texts = texts[T]
			B.cat = cats[T]
			src.books += B
		for(var/obj/machinery/bookcase/BS)
			BS.update()
mob/verb/newbookhand()
	Bookhandler = new()
mob/verb/getbooks()
	for(var/obj/item/weapon/book/B in Bookhandler.books)
		usr << B.name
		B.loc = usr.loc

obj/machinery/bookcase
	name = "Fiction Bookcase"
	icon = 'computer.dmi'
	icon_state = "messyfiles"
	var/cat = Fiction

obj/machinery/bookcase/engi
	name = "Engineering Bookcase"
	cat = Engineering
obj/machinery/bookcase/med
	name = "Medical Bookcase"
	cat = Medical
obj/machinery/bookcase/his
	name = "History Bookcase"
	cat = History
obj/machinery/bookcase/bus
	name = "Business Bookcase"
	cat = Business
obj/machinery/bookcase/sh
	name = "Self-Help Bookcase"
	cat = SelfHelp
obj/machinery/bookcase/sci
	name = "Science Bookcase"
	cat = Science
obj/machinery/bookcase/reli
	name = "Religion Bookcase"
	cat = Religion
obj/machinery/bookcase/cook
	name = "Cooking Bookcase"
	cat = Cooking
obj/machinery/bookcase/proc/update()
	for(var/obj/item/weapon/book/BC in Bookhandler.books)
		if(BC.cat == src.cat)
			var/obj/item/weapon/book/B = new(src)
			B.name = BC.name
			B.by = BC.by
			B.texts = BC.texts
			B.cat = BC.cat
obj/machinery/bookcase/attack_hand(mob/user)
	var/obj/item/weapon/book/B = input(user,"Choose a book to take out","Books") as obj in src.contents
	B.loc = user.loc

obj/machinery/writersdesk
	name = "Writer Desk"
	desc = "A desk with various tools to write a book"
	icon = 'structures.dmi'
	icon_state = "writers"
obj/machinery/writersdesk/attack_hand(mob/user)
	switch(alert("Would you like to write a book?",,"Yes","No"))
		if("No")
			return
	var/cat = 1
	var/text = input(user,"Write a book!","Booker","type something here") as message
	var/title = input(user,"Give a title to your book!","Bookia","Title here") as text
	var/author = input(user,"Whats your name?","Namey",user.name) as text
	var/catname = input(user,"What catagory is this book in?","Fiction") in list("Fiction","Engineering","Medical","History","Business","SelfHelp","Science","Religion","Cooking")
	switch(catname)
		if("Fiction")
			cat = Fiction
		if("Engineering")
			cat = Engineering
		if("Medical")
			cat = Medical
		if("History")
			cat = History
		if("Business")
			cat = Business
		if("SelfHelp")
			cat = SelfHelp
		if("Science")
			cat = Science
		if("Religion")
			cat = Religion
		if("Cooking")
			cat = Cooking
	var/DBQuery/x_query = dbcon.NewQuery("INSERT INTO `books` (`title`, `author`, `text`,`cat`) VALUES ('[dbcon.Quote(title)]', '[dbcon.Quote(author)]','[dbcon.Quote(text)]','[cat]')")
	//"INSERT INTO `books` (`title`, `author`, `text`,`cat`) VALUES ('[dbcon.Quote(title)]', '[dbcon.Quote(author)]', '[dbcon.Quote(text)]','[cat]')")
	if(!x_query.Execute())
		world << "Failed-[x_query.ErrorMsg()]"

