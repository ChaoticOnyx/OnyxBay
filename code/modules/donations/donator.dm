/datum/donator_prize
	var/obj/object
	var/cost
	var/category


/datum/donator
	var/ckey
	var/money
	var/total

	var/list/datum/donator_prize/available = list() // Items bought by this player
	var/list/datum/donator_prize/unacquired = list() // Items available for acquisition


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


/datum/donator/proc/buy_prize(datum/donator_prize/prize)
	set background = 1

	. = src.refund(-prize.cost)
	if (.)
		var/database/query/q = new("INSERT INTO donators (ckey, bought_for, type) VALUES ( ? , ? , ? )", src.ckey, prize.cost, "[prize.object.type]")
		. &= q.Execute(GLOB.donations.db)

		if (.)
			src.available.Add(prize)
			src.unacquired.Add(prize)


/datum/donator/Topic(href, href_list)
	var/mob/living/carbon/human/user = usr

	var/datum/donator_prize/prize = locate(href_list["target"])
	world << prize
	if (!prize || !(prize in GLOB.donations.prizes))
		to_chat(usr, "This is not a real prize")
		return 0

	switch (href_list["action"])
		if ("buy")
			if (prize in src.available)
				to_chat(user, "<span class='danger'>You've already bought this item!</span>")
				return 0

			if (prize.cost > src.money)
				to_chat(user, "<span class='danger'>You don't have enough money to buy this!</span>")
				return 0

			var/response = input(user, "Are you sure you want to buy [prize.object.name]?", "Order confirmation", "No") in list("No", "Yes")
			if (response == "Yes")
				if (src.buy_prize(prize))
					to_chat(user, "<span class='info'>You have bought [prize.object.name] for [prize.cost]</span>.")
				else
					to_chat(user, "Something went wrong: report this: [dbcon.ErrorMsg()]; [GLOB.donations.db.ErrorMsg()]")

		if ("acquire")
			if(!user)
				to_chat(usr, "<span class='warning'>You must be a human to use this.</span>")
				return 0

			if(user.stat)
				to_chat(usr, "<span class='danger'>You must be conscious to use this.</span>")
				return 0

			if (world.time > GLOB.donations.spawn_period)
				to_chat(usr, "<span class='danger'>You can only acquire during acquisition period which lasts [GLOB.donations.spawn_period / 10] seconds</span>")
				return 0

			if (!(prize in src.available))
				to_chat(usr, "<span class='danger'>You haven't bought this item.</span>")
				return 0

			if (!(prize in src.unacquired))
				to_chat(usr, "<span class='danger'>You cannot acquire this item more than once per round.</span>")
				return 0

			var/list/slots = list(
				"backpack" = slot_in_backpack,
				"left pocket" = slot_l_store,
				"right pocket" = slot_r_store,
				"left hand" = slot_l_hand,
				"right hand" = slot_r_hand,
			)

			var/obj/spawned = new prize.object.type(get_turf(user))
			var/where = user.equip_in_one_of_slots(spawned, slots, del_on_fail=0)

			if (!where)
				to_chat(user, "<span class='info'>Your [prize.object.name] has been spawned!</span>")
			else
				to_chat(user, "<span class='info'>Your [prize.object.name] has been spawned in your [where]!</span>")

			src.unacquired.Remove(prize)

	src.ui_interact(user)
	return 1


/datum/donator/ui_interact(mob/user, ui_key = "donation", var/datum/nanoui/ui = null, var/force_open = 0)
	var/list/list/categories = list()

	for (var/datum/donator_prize/prize in GLOB.donations.prizes)
		if (!categories[prize.category])
			categories[prize.category] = list()

		var/hashed = md5("[prize.object.type]")
		user << browse_rsc(icon(prize.object.icon, prize.object.icon_state), "prize_[hashed].dmi")
		categories[prize.category][++categories[prize.category].len] = list(
			"name" = prize.object.name,
			"desc" = prize.object.desc,
			"prize" = "\ref[prize]",
			"icon" = "<img class='icon prize_icon' src='prize_[hashed].dmi'></img>",
			"is_available" = (prize in src.available),
			"is_acquired" = !(prize in src.unacquired),
			"cost" = prize.cost
		)

	var/list/data = list(
		"money" = src.money,
		"total" = src.total,
		"categories" = categories
	)

	ui = GLOB.nanomanager.try_update_ui(user, user, ui_key, ui, data, force_open)
	if (!ui)
		ui = new (user, src, ui_key, "donations.tmpl", "Donator Panel", 400, 800, state=GLOB.interactive_state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(0)