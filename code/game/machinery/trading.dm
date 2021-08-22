/obj/machinery/vending/trading
	name = "Trading"
	var/password
	var/trader_access
	var/datum/money_account/vendor_account

/obj/machinery/vending/trading/Initialize()
	. = ..()
	component_parts = list(
		new /obj/item/weapon/circuitboard/trading(src),
		new /obj/item/weapon/stock_parts/matter_bin(src),
		new /obj/item/weapon/stock_parts/manipulator(src),
		new /obj/item/weapon/stock_parts/console_screen(src))
	RefreshParts()

/obj/machinery/vending/trading/proc/make_password(mob/user)
	password = input(user, "Enter password", "New password. 0 - 9999", -1) as null|num
	if(password == null || password < 0 || password > 9999)
		to_chat(user, "\icon[src][SPAN_WARNING("Wrong password! Try again!")]")
		password = null
	return password

/obj/machinery/vending/trading/proc/authorize_manual(mob/user)
	var/attempt_account_num = input(user, "Enter account number", "New account number") as num
	var/attempt_pin = input(user, "Enter pin code", "Account pin") as num
	vendor_account = attempt_account_access(attempt_account_num, attempt_pin, 1)

	if(!vendor_account)
		to_chat(user, "\icon[src][SPAN_WARNING("Account not found.")]")
		return

	if(vendor_account.suspended)
		vendor_account = null
		to_chat(user, "\icon[src][SPAN_WARNING("Account have been suspended.")]")
		return

	if(make_password(user))
		to_chat(user, "\icon[src][SPAN_NOTICE("Account #[attempt_account_num] have been successfully authorized.")]")
	else
		vendor_account = null


/obj/machinery/vending/trading/proc/authorize_card(obj/item/weapon/card/id/I, mob/user)
	var/account_num = I.associated_account_number
	vendor_account = get_account(account_num)
	if(vendor_account)
		to_chat(user, "\icon[src][SPAN_NOTICE("Account #[account_num] have been successfully authorized.")]")
	else
		to_chat(user, "\icon[src][SPAN_WARNING("Authorization failed.")]")

/obj/machinery/vending/trading/proc/authorize(obj/item/weapon/card/id/I, mob/user)
	if(!I)
		return
	if(trader_access && !(trader_access in I.GetAccess()))
		to_chat(user, "\icon[src][SPAN_DANGER("Access denied.")]")
		return

	var/account_type = input(user,
		"Choose a account authorization method", "Method", "Card") in list("Card", "Manual")
	if(account_type == "Manual")
		authorize_manual(user)
	if(account_type == "Card")
		authorize_card(I, user)

/obj/machinery/vending/trading/proc/check_authorization(mob/user)
	if(password)
		var/input_password = input(user, "Enter password", "Password", -1) as num
		if(password != input_password)
			to_chat(user, "\icon[src][SPAN_WARNING("Wrong password.")]")
			return FALSE
		return TRUE

	if(!vendor_account)
		to_chat(user, "\icon[src][SPAN_WARNING("Authorization failed.")]")
		return FALSE

	for(var/obj/item/weapon/card/id/I in user.contents)
		if(vendor_account == get_account(I.associated_account_number))
			return TRUE

	to_chat(user, "\icon[src][SPAN_WARNING("Authorization failed.")]")
	return FALSE

/obj/machinery/vending/trading/proc/cleanup()
	for(var/datum/stored_items/vending_products/P in product_records)
		if(!P.get_amount())
			product_records -= P
			qdel(P)

/obj/machinery/vending/trading/proc/insert_item(obj/item/W, mob/user)
	if(!check_authorization(user))
		return

	if(istype(W, /obj/item/weapon/disk/nuclear))
		to_chat(user, "\icon[src][SPAN_DANGER("This item cannot be traided!")]")

	if(!attempt_to_stock(W, user))
		var/price = max(0, round(input(user, "Enter price", "Price", 0) as num))
		make_product_record(W.type, price, amount = 0)
		attempt_to_stock(W, user)

/obj/machinery/vending/trading/credit_purchase(target)
	var/datum/transaction/T = new(target, "Purchase of [currently_vending.item_name]", currently_vending.price, name)
	vendor_account.do_transaction(T)

/obj/machinery/vending/trading/proc/modify_slogans(mob/user)
	var/actions = list("Cancel", "Add")
	if(slogan_list.len)
		actions += list("Edit", "Remove")
	var/action = input(user, "Select action", "Action", "Cancel") in actions
	switch(action)
		if("Edit")
			var/target = input(user, "Select", "Slogan") in slogan_list
			slogan_list -= target
			slogan_list += sanitize(input(user, "Edit slogan", "Edit", target) as text, MAX_LNAME_LEN)
		if("Remove")
			var/target = input(user, "Select", "Slogan") in slogan_list
			slogan_list -= target
		if("Add")
			slogan_list += sanitize(input(user, "Write slogan", "Slogan") as text, MAX_LNAME_LEN)

/obj/machinery/vending/trading/proc/modify_ads(mob/user)
	var/actions = list("Cancel", "Add")
	if(ads_list.len)
		actions += list("Edit", "Remove")
	var/action = input(user, "Select action", "Action", "Cancel") in actions

	switch(action)
		if("Edit")
			var/target = input(user, "Select", "Ad") in ads_list
			ads_list -= target
			ads_list += sanitize(input(user, "Edit ad", "Edit", target) as text, MAX_LNAME_LEN)
		if("Remove")
			ads_list -= input(user, "Select", "Ad") in ads_list
		if("Add")
			ads_list += sanitize(input(user, "Write ad", "Ad") as text, MAX_LNAME_LEN)

/obj/machinery/vending/trading/attackby(obj/item/W, mob/user)
	cleanup()
	if(!panel_open || isScrewdriver(W))
		return ..()

	if(!vendor_account && istype(W, /obj/item/weapon/card/id))
		authorize(W, user)
		return

	if(istype(W, /obj/item/weapon/pen))
		if(!check_authorization(user))
			return
		switch(input(user, "Select action", "Action", "Cancel") in
			list("Rename", "Change description", "Change appearence", "Modify slogans", "Modify ads", "Cancel"))
			if("Rename")
				name = "[sanitize(input(user, "Rename", "New name", name) as null|text, MAX_LNAME_LEN)]"
			if("Change description")
				desc = "[sanitize(input(user, "Change description", "Description", desc) as null|text, MAX_LNAME_LEN)]"
			if("Change appearence")
				var/list/vends = icon_states(icon)
				var/list/ovends = vends
				for(var/V in vends)
					if(findtext(V, "-")) // ancillary states
						vends -= V
					if(findtext(V, "wall"))
						vends -= V
					if(!("[V]-panel" in ovends))
						vends -= V

				base_icon = icon_state = input("Select appearence", "Appearence", icon_state) in vends
				overlays.Cut()
				overlays += image(icon, "[base_icon]-panel")
			if("Modify slogans")
				modify_slogans(user)
			if("Modify ads")
				modify_ads(user)
		return

	if(vendor_account)
		insert_item(W, user)

/obj/machinery/vending/trading/attack_hand(mob/user)
	. = ..()
	cleanup()
