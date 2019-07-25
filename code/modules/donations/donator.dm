/datum/donator_product
	var/obj/object
	var/cost
	var/category


/datum/donator
	var/ckey
	var/money
	var/total

	var/list/datum/donator_product/owned = list() // Items bought by this player
	var/list/datum/donator_product/received = list() // Received items


/datum/donator/proc/refund(amount)
	set background = 1

	var/DBQuery/q = dbcon.NewQuery("UPDATE donators SET current = [src.money] WHERE ckey='[src.ckey]'")
	. = q.Execute()
	if (.)
		src.money += amount


/datum/donator/proc/full_refund(type_as_text, refund_amount)
	set background = 1

	. = src.refund(refund_amount)
	if (.)
		var/database/query/q = new("DELETE FROM donators WHERE ckey=? AND type=?", src.ckey, type_as_text)
		. &= q.Execute(GLOB.donations.db)


/datum/donator/proc/partial_refund(type_as_text, old_cost, new_cost)
	set background = 1

	. = src.refund(old_cost - new_cost)
	if (.)
		var/database/query/q = new("UPDATE donators SET bought_for=? WHERE ckey=? AND type=?", new_cost, src.ckey, type_as_text)
		. &= q.Execute(GLOB.donations.db)


/datum/donator/proc/buy_product(datum/donator_product/product)
	set background = 1

	. = src.refund(-product.cost)
	if (. > 0)
		var/database/query/q = new("INSERT INTO donators (ckey, bought_for, type) VALUES ( ? , ? , ? )", src.ckey, product.cost, "[product.object.type]")
		. &= q.Execute(GLOB.donations.db)

		if (.)
			src.owned.Add(product)


/datum/donator/Topic(href, href_list)
	var/mob/living/carbon/human/user = usr

	var/datum/donator_product/product = locate(href_list["target"])
	if (!product || !(product in GLOB.donations.products))
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

			var/response = input(user, "Are you sure you want to buy [product.object.name]? THIS CANNOT BE UNDONE UNLESS THE PRICE GOES UP OR THIS ITEM GOES OFF THE MARKET!", "Order confirmation", "No") in list("No", "Yes")
			if (response == "Yes")
				if (src.buy_product(product))
					to_chat(user, "<span class='info'>You now own \icon[product.object] [product.object.name].</span>")
				else
					to_chat(user, "Something went wrong: report this: [dbcon.ErrorMsg()]; [GLOB.donations.db.ErrorMsg()]")

		if ("receive")
			if(!user)
				to_chat(usr, "<span class='warning'>You must be a human to acquire items.</span>")
				return 0

			if(user.stat)
				to_chat(usr, "<span class='danger'>You must be conscious to acquire items.</span>")
				return 0

			if (product in src.received)
				to_chat(usr, "<span class='danger'>You've already received this item.</span>")
				return 0

			if (world.time > GLOB.donations.spawn_period)
				to_chat(usr, "<span class='danger'>It's too late into the round to acquire items now.</span>")
				return 0

			if (!(product in src.owned))
				to_chat(usr, "<span class='danger'>You don't own this item.</span>")
				return 0

			var/list/slots = list(
				"backpack" = slot_in_backpack,
				"left pocket" = slot_l_store,
				"right pocket" = slot_r_store
			)

			var/obj/spawned = new product.object.type(get_turf(user))
			var/where = user.equip_in_one_of_slots(spawned, slots, del_on_fail=0)

			if (!where)
				to_chat(user, "<span class='info'>\icon[product.object] [product.object.name] has been delivered.</span>")
			else
				to_chat(user, "<span class='info'>\icon[product.object] [product.object.name] has been delivered to your [where].</span>")

			src.received.Add(product)

	src.ui_interact(user)
	return 1


/datum/donator/ui_interact(mob/user, ui_key = "donation", var/datum/nanoui/ui = null, var/force_open = 0)
	var/list/list/categories = list()

	for (var/datum/donator_product/product in GLOB.donations.products)
		if (!categories[product.category])
			categories[product.category] = list()

		var/hashed = md5("[product.object.type]")
		user << browse_rsc(icon(product.object.icon, product.object.icon_state), "product_[hashed].dmi")
		categories[product.category][++categories[product.category].len] = list(
			"name" = product.object.name,
			"desc" = product.object.desc,
			"product" = "\ref[product]",
			"icon" = "<img class='icon product_icon' src='product_[hashed].dmi'></img>",
			"is_owned" = (product in src.owned),
			"is_received" = (product in src.received),
			"cost" = product.cost
		)

	var/list/data = list(
		"money" = src.money,
		"total" = src.total,
		"categories" = categories
	)

	ui = GLOB.nanomanager.try_update_ui(user, user, ui_key, ui, data, force_open)
	if (!ui)
		ui = new (user, src, ui_key, "donations.tmpl", "Donator Store", 400, 800, state=GLOB.interactive_state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(0)