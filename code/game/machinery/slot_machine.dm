
/obj/machinery/slot_machine
	name = "Slot Machine"
	desc = "Gambling for the antisocial."
	icon = 'icons/obj/slotmachine.dmi'
	icon_state = "slot3"
	layer = BELOW_OBJ_LAYER
	anchored = TRUE
	density = TRUE
	idle_power_usage = 10 WATTS
	emagged = FALSE
	obj_flags = OBJ_FLAG_ANCHORABLE
	clicksound = SFX_USE_BUTTON
	pull_slowdown = PULL_SLOWDOWN_HEAVY

	var/plays = FALSE
	var/skin_variation = 0
	///break-even point for slots when this is set to 2500. make lower to make slots pay out better, or higher to give the house an edge
	var/max_roll = 2000
	var/wager = 0
	var/current_player = ""

/obj/machinery/slot_machine/Initialize(mapload)
	. = ..()
	power_change()
	skin_variation = rand(1, 3)
	update_icon()

/obj/machinery/slot_machine/on_update_icon()
	ClearOverlays()
	if(stat & BROKEN)
		icon_state = "slot[skin_variation]_off"
	else if(!(stat & (NOPOWER | POWEROFF)))
		icon_state = "slot[skin_variation][plays ? "_spin" : ""]"
		if(wager)
			AddOverlays(OVERLAY(icon, "wager_overlay"))
			set_light(0.8, 0.5, 2, 3, "#E4DD7F")
		else
			set_light(0.8, 0.5, 2, 3, "#FFB27F")
		AddOverlays(emissive_appearance(icon, "slot-ea"))
	else
		icon_state = "slot[skin_variation]_off"
		set_light(0)

/obj/machinery/slot_machine/proc/update_standing_icon()
	if(!anchored)
		SetTransform(rotation = -90)
		pixel_y = -1
	else
		ClearTransform()
		pixel_y = initial(pixel_y)
	update_icon()

/obj/machinery/slot_machine/attack_hand(mob/user)
	if(stat & (BROKEN | NOPOWER | POWEROFF))
		return

	if(user.a_intent == I_HURT && Adjacent(user))
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		playsound(src, 'sound/effects/vent/vent12.ogg', 40, TRUE)
		shake_animation(stime = 4)
		user.do_attack_animation(src)
		user.visible_message(SPAN("danger", "\The [user] knock \the [src]!"),
			SPAN("danger", "You knock \the [src]!"),
			SPAN("danger", "You hear a knock sound."))
		return

	if(!wager)
		return

	visible_message(SPAN("notice", "[user] launches \the [src]!"))
	money_roll()

/obj/machinery/slot_machine/proc/money_roll()
	plays = TRUE
	update_icon()
	set_next_think(world.time + 3 SECONDS)

/obj/machinery/slot_machine/think()
	var/roll = rand(1, max_roll)
	var/exclamation = ""
	var/amount = 0

	//300x and 100x jackpots fall through to 50x winner if wager <= 100
	if(wager < 100)
		roll = max(6, roll)
	if(emagged)
		roll = min(roll * 2, max_roll)

	if(roll == 1) //1 - 300
		exclamation = "JACKPOT! "
		amount = 300 * wager
		SSannounce.play_station_announce(/datum/announce/slot_machine, "Congratulations to [current_player] on winning a Jackpot of [amount] credits!")
	else if(roll <= 5) //4 - 400
		exclamation = "Big Winner! "
		amount = 100 * wager
		SSannounce.play_station_announce(/datum/announce/slot_machine, "Congratulations to [current_player] on winning [amount] credits!")
	else if(roll <= 15) //10 - 500    (Plus additional 5 - 250 if wager <= 250)
		exclamation = "Big Winner! "
		amount = 50 * wager
	else if(roll <= 65) //50 - 500
		exclamation = "Winner! "
		amount = 10 * wager
	else if(roll <= 165) //100 - 500
		exclamation = "Winner! "
		amount = 5 * wager
	else if(roll <= 265) //100 - 300
		exclamation = "Winner! "
		amount = 3 * wager
	else if(roll <= 715 && wager < 150) //450 - 450, if wager <= 150, to make up for not having jackpots
		exclamation = "Small Winner! "
		amount = 1 * wager
	else
		visible_message("<b>[src]</b> says, \"No luck!\"")

	if(amount > 0)
		visible_message("<b>[src]</b> says, \"[exclamation][current_player] has won [amount] credits!\"")
		var/obj/item/spacecash/bundle/B = new(loc)
		B.worth = amount
		B.update_icon()

	plays = FALSE
	wager = 0
	current_player = ""
	update_icon()

/obj/machinery/slot_machine/attackby(obj/item/W, mob/user)
	if((obj_flags & OBJ_FLAG_ANCHORABLE) && isWrench(W))
		if(wrench_floor_bolts(user))
			update_standing_icon()
			power_change()
		return
	if(pay(W, user))
		return
	else if(W.force >= 10)
		user.visible_message(SPAN("danger", "\The [src] has been [pick(W.attack_verb)] with [W] by [user]!"))
		W.set_cooldown()
		user.do_attack_animation(src)
		obj_attack_sound(W)
		shake_animation(stime = 4)
		return
	..()
	if(W.mod_weight >= 0.75)
		shake_animation(stime = 2)
	return

/obj/machinery/slot_machine/proc/pay(obj/item/W, mob/user)
	if(!W)
		return FALSE

	if((stat & (NOPOWER | POWEROFF | BROKEN)) || !anchored || plays)
		return FALSE

	var/obj/item/card/id/I = W.get_id_card()

	if(plays || wager) // One thingy at a time!
		to_chat(user, SPAN("warning", "\The [src] is busy at the moment!"))
		return TRUE

	if(I) // For IDs and PDAs and wallets with IDs
		pay_with_card(I, W, user)

	update_icon()
	return TRUE

/obj/machinery/slot_machine/proc/pay_with_card(obj/item/card/id/I, obj/item/ID_container, mob/user)
	if(I == ID_container || ID_container == null)
		visible_message(SPAN("info", "\The [usr] swipes \the [I] through \the [src]."))
	else
		visible_message(SPAN("info", "\The [usr] swipes \the [ID_container] through \the [src]."))

	var/datum/money_account/customer_account = get_account(I.associated_account_number)
	if(!customer_account)
		to_chat(user, "Error: Unable to access account. Please contact technical support if problem persists.")
		return FALSE

	if(customer_account.suspended)
		to_chat(user, "Unable to access account: account suspended.")
		return FALSE

	// Have the customer punch in the PIN before checking if there's enough money. Prevents people from figuring out acct is
	// empty at high security levels
	if(customer_account.security_level != 0) //If card requires pin authentication (ie seclevel 1 or 2)
		var/attempt_pin = input("Enter pin code", "Slots transaction") as num
		customer_account = attempt_account_access(I.associated_account_number, attempt_pin, 2)

		if(!customer_account)
			to_chat(user, "Unable to access account: incorrect credentials.")
			return FALSE

	if(plays)
		to_chat(user, "Machine busy, operation canceled.")
		return FALSE

	var/target_wager = input("What is your bet?", "Slots transaction") as num
	if(target_wager < 1)
		return FALSE

	target_wager = floor(target_wager)

	if(target_wager > customer_account.money)
		to_chat(user, "Insufficient funds in account.")
		return FALSE
	else
		if(plays)
			to_chat(user, "Machine busy, operation canceled.")
			return FALSE
		// Okay to move the money at this point
		var/datum/transaction/T = new("NTBets Co. (via [name])", "Bet at [src]", -target_wager, name)

		customer_account.do_transaction(T)
		wager = target_wager
		current_player = customer_account.owner_name
		to_chat(user, "You spend [wager] credits.")
		return TRUE
