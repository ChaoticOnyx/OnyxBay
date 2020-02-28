/datum/donator_product
	var/atom/object // type
	var/cost
	var/category

/datum/donator
	var/ckey
	var/money
	var/total

	var/list/datum/donator_product/owned = list() // Items bought by this player
	var/list/datum/donator_product/received = list() // Received items

/datum/donator/proc/buy_product(datum/donator_product/product)
	set background = TRUE

	src.money -= product.cost

	var/DBQuery/q = dbcon.NewQuery("INSERT INTO `Z_buys` (`byond`, `type`) VALUES ('[src.ckey]', '[product.object]');")
	. = q.Execute()

	if (.)
		src.owned.Add(product)


/datum/donator/Topic(href, href_list)
	var/mob/living/carbon/human/user = usr

	var/datum/donator_product/product = locate(href_list["target"])
	if (!product || src.ckey != user.ckey || !(product in GLOB.donations.products))
		message_admins("[key_name_admin(user, include_name = 1)] has attempted to use an href exploit in Donator Store.")
		to_chat(usr, "Href exploits do not work here.")
		return 0

	switch (href_list["action"])
		if ("buy")
			if (product in src.owned)
				to_chat(user, "<span class='warning'>You already own this item.</span>")
				return 0

			if (product.cost > src.money)
				to_chat(user, "<span class='danger'>You don't have enough money to buy this.</span>")
				return 0

			var/response = input(user, "Are you sure you want to buy [initial(product.object.name)]? THIS CANNOT BE UNDONE UNLESS THE PRICE GOES UP OR THIS ITEM GETS REMOVED FROM THE STORE!", "Order confirmation", "No") in list("No", "Yes")
			if (response == "Yes")
				if (src.buy_product(product))
					to_chat(user, "<span class='info'>You now own [icon2html(icon(initial(product.object.icon), initial(product.object.icon_state)), user, realsize=FALSE)] [initial(product.object.name)].</span>")
				else
					to_chat(user, "Something went wrong: report this: [dbcon.ErrorMsg()];")
					log_and_message_admins("Donator Store DB error: [dbcon.ErrorMsg()];")

		if ("receive")
			if(!istype(user))
				to_chat(usr, "<span class='warning'>You must be a human to acquire items.</span>")
				return 0

			if(user.stat)
				to_chat(usr, "<span class='danger'>You must be conscious to acquire items.</span>")
				return 0

			if (product in src.received)
				to_chat(usr, "<span class='danger'>You've already received this item.</span>")
				return 0

			if (round_duration_in_ticks > GLOB.donations.spawn_period)
				to_chat(usr, "<span class='danger'>It's too late into the round to receive items now.</span>")
				return 0

			if (!(product in src.owned))
				to_chat(usr, "<span class='danger'>You don't own this item.</span>")
				return 0

			var/list/slots = list(
				"backpack" = slot_in_backpack,
				"left pocket" = slot_l_store,
				"right pocket" = slot_r_store
			)

			var/obj/spawned = new product.object(get_turf(user))

			spawned.donator_owner = user.real_name

			var/where = user.equip_in_one_of_slots(spawned, slots, del_on_fail=0)

			if (!where)
				to_chat(user, "<span class='info'>[icon2html(spawned, user, realsize=FALSE)] [initial(product.object.name)] has been delivered.</span>")
			else
				to_chat(user, "<span class='info'>[icon2html(spawned, user, realsize=FALSE)] [initial(product.object.name)] has been delivered to your [where].</span>")

			src.received.Add(product)

	src.ui_interact(user)
	return 1


/datum/donator/ui_interact(mob/user, ui_key = "donation", datum/nanoui/ui = null, force_open = 0)
	var/list/list/categories = list()

	for (var/datum/donator_product/product in GLOB.donations.products)
		if (!categories[product.category])
			categories[product.category] = list()

		categories[product.category][++categories[product.category].len] = list(
			"name" = initial(product.object.name),
			"desc" = initial(product.object.desc),
			"product" = "\ref[product]",
			"icon" = "[icon2html(icon(initial(product.object.icon), initial(product.object.icon_state)), user, realsize=FALSE)]",
			"is_owned" = (product in src.owned),
			"is_received" = (product in src.received),
			"cost" = product.cost
		)

	var/list/data = list(
		"money" = src.money,
		"total" = src.total,
		"categories" = categories
	)

	ui = SSnano.try_update_ui(user, user, ui_key, ui, data, force_open)
	if (!ui)
		ui = new (user, src, ui_key, "donations.tmpl", "Donator Store", 400, 800, state=GLOB.interactive_state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(0)
