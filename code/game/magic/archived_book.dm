//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:04

#define BOOK_VERSION_MIN	1
#define BOOK_VERSION_MAX	2
#define BOOK_PATH			"data/books/"
#define BOOKS_USE_SQL		0				// no guarentee for this branch to work right with sql  // TODO: make books work normally with SQL

var/global/datum/book_manager/book_mgr = new()

datum/book_manager/proc/path(id)
	if(isnum(id)) // kill any path exploits
		return "[BOOK_PATH][id].sav"

datum/book_manager/proc/getall()
	var/list/paths = flist(BOOK_PATH)
	var/list/books = new()

	for(var/path in paths)
		var/datum/archived_book/B = new(BOOK_PATH + path)
		books += B

	return books

datum/book_manager/proc/freeid()
	var/list/paths = flist(BOOK_PATH)
	var/id = paths.len + 101

	// start at 101+number of books, which will be correct id if none have been deleted, etc
	// otherwise, keep moving forward until we find an open id
	while(fexists(path(id)))
		id++

	return id

/client/proc/delbook() // TODO: normal db establish instead of recreating db
	set name = "Delete Book"
	set desc = "Permamently deletes a book from the database."
	set category = "Admin"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/isbn = input("ISBN number?", "Delete Book") as num | null
	if(!isbn)
		return

	if(BOOKS_USE_SQL && config.external.sql_enabled) // always false. see todo on line 6 of this file
		if(!establish_db_connection())
			alert("Connection to Archive has been severed. Aborting.")
		else
			var/DBQuery/query = sql_query("DELETE FROM library WHERE id=$$", dbcon, isbn)
	else
		book_mgr.remove(isbn)
	log_admin("[usr.key] has deleted the book [isbn]")

// delete a book
datum/book_manager/proc/remove(id)
	fdel(path(id))

datum/archived_book
	var/author		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	var/title		 // The real name of the book.
	var/category	 // The category/genre of the book
	var/id			 // the id of the book (like an isbn number)
	var/dat			 // Actual page content

	var/author_real	 // author's real_name
	var/author_key	 // author's byond key
	var/list/icon/photos	 // in-game photos used

// loads the book corresponding by the specified id
datum/archived_book/New(path)
	if(isnull(path))
		return

	var/savefile/F = new(path)

	var/version
	from_file(F["version"], version)

	if (isnull(version) || version < BOOK_VERSION_MIN || version > BOOK_VERSION_MAX)
		fdel(path)
		to_chat(usr, "What book?")
		return 0

	from_file(F["author"],      author)
	from_file(F["title"],       title)
	from_file(F["category"],    category)
	from_file(F["id"],          id)
	from_file(F["dat"],         dat)

	from_file(F["author_real"], author_real)
	from_file(F["author_key"],  author_key)
	from_file(F["photos"],      photos)
	if(!photos)
		photos = new()

	// let's sanitize it here too!
	for(var/tag in paper_blacklist)
		if(findtext(dat,"<"+tag))
			dat = ""
			return


datum/archived_book/proc/save()
	var/savefile/F = new(book_mgr.path(id))

	to_file(F["version"],     BOOK_VERSION_MAX)
	to_file(F["author"],      author)
	to_file(F["title"],       title)
	to_file(F["category"],    category)
	to_file(F["id"],          id)
	to_file(F["dat"],         dat)

	to_file(F["author_real"], author_real)
	to_file(F["author_key"],  author_key)
	to_file(F["photos"],      photos)

#undef BOOK_VERSION_MIN
#undef BOOK_VERSION_MAX
#undef BOOK_PATH
