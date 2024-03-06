
/**
 *  A vending machine
 */
/obj/machinery/vending
	name = "Vendomat"
	desc = "A generic vending machine."
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "generic"
	layer = BELOW_OBJ_LAYER
	anchored = 1
	density = 1
	obj_flags = OBJ_FLAG_ANCHORABLE
	clicksound = SFX_USE_BUTTON
	clickvol = 40
	pull_slowdown = PULL_SLOWDOWN_HEAVY

	var/max_health = 100
	var/health = 100
	var/base_icon = "generic"
	var/use_vend_state = FALSE // whether to use "[base_icon]-vend" icon when vending
	var/diona_spawn_chance = 0.1
	var/use_alt_icons = FALSE
	var/alt_icons = list()

	// Power
	idle_power_usage = 10 WATTS
	var/vend_power_usage = 150 WATTS //actuators and stuff

	// Vending-related
	var/vend_ready = TRUE // Are we ready to vend?? Is it time??
	var/vend_delay = null // How long does it take to vend? Uses random value if set to null.
	var/categories = CAT_NORMAL // Bitmask of cats we're currently showing
	var/datum/stored_items/vending_products/currently_vending = null // What we're requesting payment for right now
	var/status_message = "" // Status screen messages like "insufficient funds", displayed in NanoUI
	var/status_error = FALSE // Set to TRUE if status_message is an error

	var/obj/item/vending_cartridge/cartridge = null
	component_types = list(/obj/item/vending_cartridge)

	// Variables used to initialize advertising
	var/product_slogans = "" //String of slogans spoken out loud, separated by semicolons
	var/product_ads = "" //String of small ad messages in the vending screen

	var/list/ads_list = list()

	// Stuff relating vocalizations
	var/list/slogan_list = list()
	var/shut_up = 1 //Stop spouting those godawful pitches!
	var/vend_reply //Thank you for shopping!
	var/last_reply = 0
	var/last_slogan = 0 //When did we last pitch?
	var/slogan_delay = 6000 //How long until we can pitch again?

	// Things that can go wrong
	emagged = 0 //Ignores if somebody doesn't have card access to that machine.
	var/seconds_electrified = 0 //Shock customers like an airlock.
	var/shoot_inventory = 0 //Fire items at customers! We're broken!
	var/shooting_chance = 2 //The chance that items are being shot per tick

	var/scan_id = 1
	var/obj/item/material/coin/coin
	var/datum/wires/vending/wires = null

	/// If true - `currently_vending` is the thing stuck in the vending.
	var/is_stuck = FALSE

	// Content-related stuff
	var/list/products = list() // In case we want to add something extra to our vending machine
	var/list/legal = list()
	var/list/illegal = list()
	var/list/premium = list()
	var/list/prices = list()
	var/gen_rand_amount = FALSE // If we want to generate random amount of items in our cartridge.

	var/vending_sound = SFX_VENDING_DROP

/obj/machinery/vending/on_update_icon()
	ClearOverlays()
	if(stat & BROKEN)
		icon_state = "[base_icon]-broken"
	else if(!(stat & (NOPOWER | POWEROFF)))
		icon_state = base_icon
	else
		icon_state = "[base_icon]-off"
	if(panel_open)
		AddOverlays(image(icon, "[base_icon]-panel"))

/obj/machinery/vending/Initialize(mapload)
	. = ..()
	wires = new(src)
	if(vend_delay == null)
		vend_delay = rand(2 SECONDS, 4 SECONDS)
	if(product_slogans)
		slogan_list += splittext(product_slogans, ";")
		// So not all machines speak at the exact same time.
		// The first time this machine says something will be at slogantime + this random value,
		// so if slogantime is 10 minutes, it will say it at somewhere between 10 and 20 minutes after the machine is crated.
		last_slogan = world.time + rand(0, slogan_delay)
	if(product_ads)
		ads_list += splittext(product_ads, ";")
	refresh_cartridge()
	setup_cartridge()
	power_change()
	setup_icon_states()

/obj/machinery/vending/proc/refresh_cartridge()
	cartridge = locate() in component_parts

/obj/machinery/vending/proc/setup_cartridge()
	if(cartridge)
		cartridge.legal = legal
		cartridge.illegal = illegal
		cartridge.premium = premium
		cartridge.prices = prices
		cartridge.extra = products
		cartridge.build_inventory(gen_rand_amount)

/obj/machinery/vending/_examine_text(mob/user)
	. = ..()
	if(.)
		if(stat & BROKEN)
			to_chat(user, SPAN("warning", "It's broken."))
		else
			if(health <= 0.4 * max_health)
				to_chat(user, SPAN("warning", "It's heavily damaged!"))
			else if(health < max_health)
				to_chat(user, SPAN("warning", "It's showing signs of damage."))

/obj/machinery/vending/proc/take_damage(force)
	if(health > 0)
		health = max(health-force, 0)
		if(health == 0)
			set_broken(1)

/obj/machinery/vending/Destroy()
	QDEL_NULL(wires)
	QDEL_NULL(coin)
	QDEL_NULL(cartridge)
	. = ..()

/obj/machinery/vending/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				qdel(src)
				return
		if(3.0)
			if(prob(25))
				spawn(0)
					malfunction()
					return
				return
	return

/obj/machinery/vending/emag_act(remaining_charges, mob/user)
	if(!emagged)
		playsound(loc, 'sound/effects/computer_emag.ogg', 25)
		emagged = 1
		to_chat(user, "You short out the product lock on \the [src]")
		return 1

/obj/machinery/vending/bullet_act(obj/item/projectile/Proj)
	var/damage = Proj.get_structure_damage()
	if(!damage)
		return

	..()
	take_damage(damage)
	return

/obj/machinery/vending/proc/pay(obj/item/W, mob/user)
	if(!W)
		return FALSE

	var/obj/item/card/id/I = W.get_id_card()

	if(currently_vending && vendor_account && !vendor_account.suspended)
		var/paid = 0

		if(!vend_ready) // One thingy at a time!
			to_chat(user, SPAN("warning", "\The [src] is busy at the moment!"))
			return

		if(I) // For IDs and PDAs and wallets with IDs
			paid = pay_with_card(I, W)
		else if(istype(W, /obj/item/spacecash/ewallet))
			var/obj/item/spacecash/ewallet/C = W
			paid = pay_with_ewallet(C)
		else if(istype(W, /obj/item/spacecash/bundle))
			var/obj/item/spacecash/bundle/C = W
			paid = pay_with_cash(C)

		if(paid)
			vend(currently_vending, usr)
			return TRUE

	return FALSE

/obj/machinery/vending/attackby(obj/item/W, mob/user)
	if(default_deconstruction_screwdriver(user, W))
		return
	if(default_deconstruction_crowbar(user, W))
		return
	if(pay(W, user))
		return
	if(isMultitool(W) || isWirecutter(W))
		if(panel_open)
			attack_hand(user)
		return
	if((obj_flags & OBJ_FLAG_ANCHORABLE) && isWrench(W))
		if(wrench_floor_bolts(user))
			update_standing_icon()
			power_change()
		return
	else if(istype(W, /obj/item/material/coin) && !coin && cartridge.premium.len > 0)
		if(!user.drop(W, src))
			return
		coin = W
		categories |= CAT_COIN
		to_chat(user, SPAN("notice", "You insert \the [W] into \the [src]."))
		return
	else if(attempt_to_repair(user, W))
		return
	else if(attempt_to_stock(W, user))
		return
	else if(W.force >= 10)
		take_damage(W.force)
		user.visible_message(SPAN("danger", "\The [src] has been [pick(W.attack_verb)] with [W] by [user]!"))
		user.setClickCooldown(W.update_attack_cooldown())
		user.do_attack_animation(src)
		obj_attack_sound(W)
		shake_animation(stime = 4)
		return
	..()
	if(W.mod_weight >= 0.75)
		shake_animation(stime = 2)
	return

/obj/machinery/vending/default_deconstruction_crowbar(mob/user, obj/item/crowbar/C)
	if(!istype(C) || !(stat & (POWEROFF | NOPOWER)) || !panel_open)
		return FALSE
	if(!do_after(user, 40, src) || !(stat & (POWEROFF | NOPOWER)) || !panel_open)
		return FALSE
	. = dismantle()

/obj/machinery/vending/dismantle()
	playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
	var/obj/machinery/vending_frame/V = new /obj/machinery/vending_frame(get_turf(src))
	V.anchored = TRUE
	V.set_dir(dir)
	V.state = 3
	for(var/obj/I in component_parts)
		component_parts -= I
		I.forceMove(V)
	V.refresh_cartridge()
	cartridge = null
	V.update_icon()
	V.update_desc()
	qdel(src)
	return FALSE

/obj/machinery/vending/proc/attempt_to_repair(mob/user, obj/item/weldingtool/W)
	if(!istype(W) || !W.isOn())
		return FALSE
	if(health == max_health)
		to_chat(user, SPAN("notice", "\The [src] is undamaged."))
		return FALSE
	if(!W.remove_fuel(0, user))
		to_chat(user, SPAN("notice", "You need more welding fuel to complete this task."))
		return FALSE
	playsound(src, 'sound/items/Welder.ogg', 100, 1)
	user.visible_message(SPAN("notice", "[user] is repairing \the [src]..."), SPAN("notice", "You start repairing the damage to [src]..."))
	if(do_after(user, 30, src) && W.isOn())
		health = max_health
		user.visible_message(SPAN("notice", "[user] repairs \the [src]."), SPAN("notice", "You repair \the [src]."))
		set_broken(0)
	return TRUE

/obj/machinery/vending/MouseDrop_T(obj/item/I, mob/user)
	if(!CanMouseDrop(I, user) || (I.loc != user))
		return
	return attempt_to_stock(I, user)

/obj/machinery/vending/proc/attempt_to_stock(obj/item/I, mob/user)
	if(!cartridge)
		return FALSE
	for(var/datum/stored_items/vending_products/R in cartridge.product_records)
		if(I.type == R.item_path)
			stock(I, R, user)
			return TRUE
/**
 *  Receive payment with cashmoney.
 */
/obj/machinery/vending/proc/pay_with_cash(obj/item/spacecash/bundle/cashmoney)
	if(currently_vending.price > cashmoney.worth)
		// This is not a status display message, since it's something the character
		// themselves is meant to see BEFORE putting the money in
		to_chat(usr, "\icon[cashmoney] <span class='warning'>That is not enough money.</span>")
		return 0

	visible_message(SPAN("info", "\The [usr] inserts some cash into \the [src]."))
	cashmoney.worth -= currently_vending.price

	if(cashmoney.worth <= 0)
		qdel(cashmoney)
	else
		cashmoney.update_icon()

	// Vending machines have no idea who paid with cash
	credit_purchase("(cash)")
	return 1

/**
 * Scan a chargecard and deduct payment from it.
 *
 * Takes payment for whatever is the currently_vending item. Returns 1 if
 * successful, 0 if failed.
 */
/obj/machinery/vending/proc/pay_with_ewallet(obj/item/spacecash/ewallet/wallet)
	visible_message(SPAN("info", "\The [usr] swipes \the [wallet] through \the [src]."))
	if(currently_vending.price > wallet.worth)
		status_message = "Insufficient funds on chargecard."
		status_error = TRUE
		return 0
	else
		wallet.worth -= currently_vending.price
		credit_purchase("[wallet.owner_name] (chargecard)")
		return 1

/**
 * Scan a card and attempt to transfer payment from associated account.
 *
 * Takes payment for whatever is the currently_vending item. Returns 1 if
 * successful, 0 if failed
 */
/obj/machinery/vending/proc/pay_with_card(obj/item/card/id/I, obj/item/ID_container)
	if(I==ID_container || ID_container == null)
		visible_message(SPAN("info", "\The [usr] swipes \the [I] through \the [src]."))
	else
		visible_message(SPAN("info", "\The [usr] swipes \the [ID_container] through \the [src]."))
	var/datum/money_account/customer_account = get_account(I.associated_account_number)
	if(!customer_account)
		status_message = "Error: Unable to access account. Please contact technical support if problem persists."
		status_error = TRUE
		return 0

	if(customer_account.suspended)
		status_message = "Unable to access account: account suspended."
		status_error = TRUE
		return 0

	// Have the customer punch in the PIN before checking if there's enough money. Prevents people from figuring out acct is
	// empty at high security levels
	if(customer_account.security_level != 0) //If card requires pin authentication (ie seclevel 1 or 2)
		var/attempt_pin = input("Enter pin code", "Vendor transaction") as num
		customer_account = attempt_account_access(I.associated_account_number, attempt_pin, 2)

		if(!customer_account)
			status_message = "Unable to access account: incorrect credentials."
			status_error = TRUE
			return 0

	if(!currently_vending)
		status_message = "Item not selected, operation canceled."
		status_error = TRUE
		return

	if(currently_vending.price > customer_account.money)
		status_message = "Insufficient funds in account."
		status_error = TRUE
		return 0
	else
		// Okay to move the money at this point
		var/datum/transaction/T = new("[vendor_account.owner_name] (via [name])", "Purchase of [currently_vending.item_name]", -currently_vending.price, name)

		customer_account.do_transaction(T)

		// Give the vendor the money. We use the account owner name, which means
		// that purchases made with stolen/borrowed card will look like the card
		// owner made them
		credit_purchase(customer_account.owner_name)
		return 1

/**
 *  Add money for current purchase to the vendor account.
 *
 *  Called after the money has already been taken from the customer.
 */
/obj/machinery/vending/proc/credit_purchase(target)
	vendor_account.money += currently_vending.price

	var/datum/transaction/T = new(target, "Purchase of [currently_vending.item_name]", currently_vending.price, name)
	vendor_account.do_transaction(T)

/obj/machinery/vending/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/vending/attack_hand(mob/user)
	if(stat & (BROKEN | NOPOWER))
		return

	wires.Interact(user)

	if(stat & POWEROFF)
		return

	if(seconds_electrified != 0)
		if(shock(user, 100))
			return

	if(user.a_intent == I_HURT && Adjacent(user))
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		take_damage(2)
		playsound(src, 'sound/effects/vent/vent12.ogg', 40, TRUE)
		shake_animation(stime = 4)
		user.do_attack_animation(src)
		user.visible_message(SPAN("danger", "\The [user] knocks \the [src]!"),
			SPAN("danger", "You knock \the [src]!"),
			SPAN("danger", "You hear a knock sound."))

		if(is_stuck && prob(50))
			unstuck()

		return

	tgui_interact(user)

/obj/machinery/vending/tgui_state(mob/user)
	return GLOB.tgui_machinery_noaccess_state

/obj/machinery/vending/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "Vending")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/vending/tgui_data(mob/user)
	var/list/data = list(
		"name" = name,
		"mode" = 0,
		"ready" = vend_ready
	)

	if(currently_vending)
		data["mode"] = 1
		data["payment"] = list(
			"product" = currently_vending.item_name,
			"price" = currently_vending.price,
			"message_err" = 0,
			"message" = status_message,
			"message_err" = status_error,
			"icon" = icon2base64html(currently_vending.item_path)
		)

	var/list/listed_products = list()

	if(cartridge)
		for(var/key = 1 to cartridge.product_records.len)
			var/datum/stored_items/vending_products/I = cartridge.product_records[key]

			if(!(I.category & categories))
				continue

			listed_products.Add(list(list(
				"key" = key,
				"name" = I.item_name,
				"price" = I.price,
				"color" = I.display_color,
				"amount" = I.get_amount(),
				"icon" = icon2base64html(I.item_path))))

	data["products"] = listed_products

	if(coin)
		data["coin"] = coin.name

	if(panel_open)
		data["panel"] = 1
		data["speaker"] = shut_up ? 0 : 1
	else
		data["panel"] = 0

	return data

/obj/machinery/vending/tgui_act(action, params)
	. = ..()

	if(.)
		return

	if(stat & POWEROFF)
		return

	switch(action)
		if("remove_coin")
			if(istype(usr, /mob/living/silicon))
				return TRUE

			if(!coin)
				to_chat(usr, "There is no coin in this machine.")
				return TRUE

			usr.pick_or_drop(coin, loc)
			to_chat(usr, SPAN("notice", "You remove \the [coin] from \the [src]"))
			coin = null
			categories &= ~CAT_COIN

			return TRUE
		if("vend")
			if(!vend_ready || currently_vending)
				return TRUE

			if((!allowed(usr)) && !emagged)	// For SECURE VENDING MACHINES YEAH
				to_chat(usr, SPAN("warning", "Access denied.")) // Unless emagged of course
				flick("[base_icon]-deny", src)
				return TRUE

			var/key = text2num(params["vend"])
			var/datum/stored_items/vending_products/R = cartridge.product_records[key]

			// This should not happen unless the request from NanoUI was bad
			if(!(R.category & categories))
				return TRUE

			if(R.price <= 0)
				currently_vending = R
				vend(R, usr)
			else if(istype(usr, /mob/living/silicon)) // If the item is not free, provide feedback if a synth is trying to buy something.
				to_chat(usr, SPAN("danger", "Artificial unit recognized.  Artificial units cannot complete this transaction.  Purchase canceled."))
				return TRUE
			else
				currently_vending = R
				if(!vendor_account || vendor_account.suspended)
					status_message = "This machine is currently unable to process payments due to problems with the associated account."
					status_error = TRUE
				else
					status_message = "Please swipe a card or insert cash to pay for the item."
					status_error = FALSE

		if("cancelpurchase")
			currently_vending = null
			return TRUE

		if("togglevoice")
			if(!panel_open)
				return TRUE

			shut_up = !shut_up
			return TRUE
		if("pay")
			pay(usr.get_active_hand(), usr) || pay(usr.get_inactive_hand(), usr)
			return TRUE

/obj/machinery/vending/proc/vend(datum/stored_items/vending_products/R, mob/user)
	if((!allowed(usr)) && !emagged)	// For SECURE VENDING MACHINES YEAH
		to_chat(usr, SPAN("warning", "Access denied.")) // Unless emagged of course
		flick("[base_icon]-deny", src)
		return
	vend_ready = FALSE // One thing at a time!!
	status_message = "Vending..."
	status_error = FALSE

	if(R.category & CAT_COIN)
		if(!coin)
			to_chat(user, SPAN("notice", "You need to insert a coin to get this item."))
			return
		if(coin.string_attached)
			if(prob(50))
				to_chat(user, SPAN("notice", "You successfully pull the coin out before \the [src] could swallow it."))
			else
				to_chat(user, SPAN("notice", "You weren't able to pull the coin out fast enough, the machine ate it, string and all."))
				qdel(coin)
				coin = null
				categories &= ~CAT_COIN
		else
			qdel(coin)
			coin = null
			categories &= ~CAT_COIN

	if(((last_reply + (vend_delay + 200)) <= world.time) && vend_reply)
		spawn(0)
			speak(vend_reply)
			last_reply = world.time

	use_power_oneoff(vend_power_usage)	//actuators and stuff
	if(use_vend_state) //Show the vending animation if needed
		flick("[base_icon]-vend", src)

	spawn(vend_delay) //Time to vend
		// A chance to stuck in.
		if(prob(1))
			stuck()
			return

		playsound(src, vending_sound, 70, TRUE)

		if(prob(diona_spawn_chance)) //Hehehe
			var/turf/T = get_turf(src)
			var/mob/living/carbon/alien/diona/S = new(T)
			visible_message(SPAN("notice", "\The [src] makes an odd grinding noise before coming to a halt as \a [S.name] slurmps out from the receptacle."))
		else //Just a normal vend, then
			R.get_product(get_turf(src), user)
			visible_message("\The [src] whirs as it vends \the [R.item_name].")
			if(prob(1)) //The vending gods look favorably upon you
				sleep(3)
				if(R.get_product(get_turf(src)))
					visible_message(SPAN("notice", "\The [src] clunks as it vends an additional [R.item_name]."))

		status_message = ""
		status_error = FALSE
		vend_ready = TRUE
		currently_vending = null

/obj/machinery/vending/proc/stuck()
	ASSERT(!is_stuck)
	ASSERT(currently_vending)

	playsound(src, 'sound/signals/error28.ogg', 40, FALSE)
	status_message = "Unexpected error occurred. Please contact technical support."
	speak(status_message)
	status_error = TRUE
	is_stuck = TRUE

/obj/machinery/vending/proc/unstuck()
	ASSERT(is_stuck)

	playsound(src, 'sound/signals/error25.ogg', 40, FALSE)
	is_stuck = FALSE

	spawn(1 SECOND)
		playsound(src, 'sound/effects/using/disposal/drop2.ogg', 40, TRUE)
		currently_vending.get_product(get_turf(src))
		visible_message("\The [src] whirs as it vends \the [currently_vending.item_name].")
		status_message = ""
		status_error = FALSE
		vend_ready = TRUE
		currently_vending = null

/**
 * Add item to the machine
 *
 * Checks if item is vendable in this machine should be performed before
 * calling. W is the item being inserted, R is the associated vending_product entry.
 */
/obj/machinery/vending/proc/stock(obj/item/W, datum/stored_items/vending_products/R, mob/user)
	if(!user.drop(W))
		return

	if(R.add_product(W))
		to_chat(user, SPAN("notice", "You insert \the [W] in the product receptor."))
		return 1

/obj/machinery/vending/Process()
	if(stat & (BROKEN|NOPOWER|POWEROFF))
		return

	if(seconds_electrified > 0)
		seconds_electrified--

	//Pitch to the people!  Really sell it!
	if(((last_slogan + slogan_delay) <= world.time) && (slogan_list.len > 0) && (!shut_up) && prob(5))
		var/slogan = pick(slogan_list)
		speak(slogan)
		last_slogan = world.time

	if(shoot_inventory && prob(shooting_chance))
		throw_item()

	return

/obj/machinery/vending/proc/speak(message)
	if(stat & NOPOWER)
		return

	if(!message)
		return

	for(var/mob/O in hearers(src, null))
		O.show_message("<span class='game say'><span class='name'>\The [src]</span> beeps, \"[message]\"</span>", 2)
	return

/obj/machinery/vending/powered()
	return anchored && ..()

/obj/machinery/vending/proc/setup_icon_states()
	if(use_alt_icons)
		base_icon = pick(alt_icons)
		update_icon()
	else
		base_icon = icon_state

/obj/machinery/vending/proc/update_standing_icon()
	if(!anchored)
		SetTransform(rotation = -90)
		pixel_y = -3
	else
		ClearTransform()
		pixel_y = initial(pixel_y)
	update_icon()

//Oh no we're malfunctioning!  Dump out some product and break.
/obj/machinery/vending/proc/malfunction()
	for(var/datum/stored_items/vending_products/R in cartridge.product_records)
		while(R.get_amount()>0)
			R.get_product(loc)
		break
	set_broken(TRUE)

//Somebody cut an important wire and now we're following a new definition of "pitch."
/obj/machinery/vending/proc/throw_item()
	var/obj/throw_item = null
	var/mob/living/target = locate() in view(7, src)
	if(!target)
		return 0

	for(var/datum/stored_items/vending_products/R in shuffle(cartridge.product_records))
		throw_item = R.get_product(loc)
		if(throw_item)
			break
	if(!throw_item)
		return 0
	throw_item.throw_at(target, rand(1, 3), null, src)
	visible_message(SPAN("warning", "\The [src] launches \a [throw_item] at \the [target]!"))
	return 1

/obj/machinery/vending/set_broken(new_state)
	..()
	if(new_state)
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, loc)
		spark_system.start()
		playsound(loc, SFX_SPARK, 50, 1)

/obj/machinery/vending/check_access(obj/item/I)
	return ..() || !scan_id
