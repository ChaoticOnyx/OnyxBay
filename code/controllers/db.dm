GLOBAL_REAL(db, /datum/db) = new

/datum/db/proc/connect()
	var/ret = rustg_sdb_connect(config.db.address, config.db.namespace, config.general.server_id, config.db.login, config.db.password)

	if(ret == "")
		return

	log_error("Can't connect to the database at '[config.db.address]': [ret].")

	ret = rustg_sdb_connect("file://data/database", config.db.namespace, config.general.server_id, "", "")

	if(ret != "")
		CRASH("Can't connect to the fallback database: [ret].")

/datum/db/proc/query(query, binds)
	if(!isnull(binds))
		binds = json_encode(binds)

	var/response = rustg_sdb_query(query, binds)

	try
		return json_decode(response)
	catch
		CRASH(response)

/datum/db/proc/export()
	var/ret = rustg_sdb_export("data/database_dump.sql")

	if(ret != "")
		CRASH(ret)

/datum/db/proc/disconnect()
	rustg_sdb_disconnect()

// Whitelist procs

/datum/db/proc/add_to_whitelist(ckey, whitelist)
	query(
		{"
		IF (<record> $player) NOT IN (<record> $whitelist).players THEN
			UPDATE (<record> $whitelist) SET players += (<record> $player);
		END;
		"},
		list("player" = "player:[ckey]", "whitelist" = "whitelist:[whitelist]")
	)

/datum/db/proc/remove_from_whitelist(ckey, whitelist)
	query(
		{"
			UPDATE (<record> $whitelist) SET players -= (<record> $player);
		"},
		list("player" = "player:[ckey]", "whitelist" = "whitelist:[whitelist]")
	)

/datum/db/proc/is_in_whitelist(ckey, whitelist)
	var/response = query(
		"RETURN (<record> $player) IN (<record> $whitelist).players;",
		list("player" = "player:[ckey]", "whitelist" = "whitelist:[whitelist]")
	)

	return response[1][1]

// Library procs

/datum/db/proc/add_library_book(author, title, content, category, author_ckey)
	query(
		{"
			CREATE book CONTENT {
				author: $author,
				title: $title,
				content: $content,
				category: $category,
				deleted: false,
				author_player: (<record> $author_player)
			};
		"},
		list("author" = author, "title" = title, "content" = content, "category" = category, "author_player" = "player:[author_ckey]")
	)

/datum/db/proc/find_book(book_id)
	var/response = query(
		{"
			SELECT meta::id(id) AS id, title, content, category, author FROM (<record> $book);
		"},
		list("book" = "book:[book_id]")
	)

	return response[1]?[1]

/datum/db/proc/find_books_with_category(category)
	var/response = query(
		{"
			SELECT meta::id(id) AS id, title, content, category, author FROM book WHERE category = $category;
		"},
		list("category" = category)
	)

	return response[1]

/datum/db/proc/mark_deleted_book(book_id)
	var/response = query(
		{"
			IF (<record> $book).id IS NOT NONE
			{
				RETURN UPDATE (<record> $book) MERGE {
					deleted: true
				};
			};
		"},
		list("book" = "book:[book_id]")
	)

	return response[1]?[1]

/datum/db/proc/get_books_ordered(order_by)
	var/response = query(
		{"
			SELECT meta::id(id) AS id, title, category, author FROM book WHERE deleted = false ORDER BY [order_by];
		"}
	)

	return response[1]

// Art library procs

/datum/db/proc/add_art(title, type, data, author_ckey)
	 query(
		{"
			CREATE art CONTENT {
				title: $title,
				type: $type,
				data: $data,
				deleted: false,
				author_player: (<record> $author_player),
			};
		"},
		list("title" = title, "type" = type, "data" = data, "author_player" = "player:[author_ckey]")
	)

/datum/db/proc/find_art(art_id)
	var/response = query(
		{"
			SELECT meta::id(id) AS id, title, data, type FROM (<record> $art);
		"},
		list("art" = "art:[art_id]")
	)

	return response[1]?[1]

/datum/db/proc/mark_deleted_art(art_id)
	var/response = query(
		{"
			IF (<record> $art).id IS NOT NONE
			{
				RETURN UPDATE (<record> $art) MERGE {
					deleted: true
				};
			};
		"},
		list("art" = "art:[art_id]")
	)

	return response[1]?[1]

/datum/db/proc/get_arts_ordered(order_by)
	var/response = query(
		{"
			SELECT meta::id(id) AS id, title, data, type FROM art WHERE deleted = false ORDER BY [order_by];
		"}
	)

	return response[1]
