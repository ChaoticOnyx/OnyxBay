#define IM_PIN "pin"
#define IM_ACC "acc"
#define IM_SUM "sum"

#define TA_INFO    0
#define TA_ERROR   1
#define TA_SUCCESS 2

/obj/item/device/eftpos
	name = "\improper EFTPOS scanner"
	desc = "Swipe your ID card to make purchases electronically."

	icon = 'icons/obj/device.dmi'
	icon_state = "eftpos"

	matter = list(MATERIAL_STEEL = 30, MATERIAL_GLASS = 20)

	origin_tech = list(TECH_MAGNET = 1)

	/// Whether the payment amount persists after a successful transaction.
	var/payment_repeating = FALSE
	/// How much to charge for the current transaction, use `set_payment_amount()` to modify.
	var/payment_amount = 0
	/// The account terminal deposits payments into.
	var/payment_account_number = 0
	/// The current input mode, possible values: `IM_PIN`, `IM_ACC`, `IM_SUM`
	var/input_mode = IM_SUM
	/// The previous input mode, used in push/pop "stack" operations.
	var/input_mode_prev = null
	/// Associative list of input mode identifiers to `/datum/eftpos_input_mode` instances.
	var/list/input_modes
	/// Unique identifier for this terminal, used in transaction logs.
	var/eftpos_id
	/// Deprecated! Name of this terminal, was used by our 'precious' mappers, so I left it.
	var/eftpos_name = "Default EFTPOS scanner"
	/// Overlay used to display the holographic price indicator.
	var/image/price_overlay

/obj/item/device/eftpos/Initialize()
	. = ..()
	input_modes = list(
		IM_SUM = new /datum/eftpos_input_mode(),
		IM_PIN = new /datum/eftpos_input_mode/pin(),
		IM_ACC = new /datum/eftpos_input_mode/account(),
	)
	eftpos_id = "[station_name()] EFTPOS #[num_financial_terminals++]"
	price_overlay = image('icons/effects/effects.dmi', "blank")

/obj/item/device/eftpos/Destroy()
	QDEL_LIST_ASSOC_VAL(input_modes)
	QDEL_NULL(price_overlay)
	return ..()

/obj/item/device/eftpos/examine(mob/user, infix)
	. = ..()

	if (!payment_account_number)
		return

	var/datum/money_account/payment_account = get_account(payment_account_number)
	if (isnull(payment_account))
		return

	. += "\The [src] is owned by [payment_account.owner_name] #[payment_account.account_number]."

/obj/item/device/eftpos/on_update_icon()
	ClearOverlays()
	if (payment_amount > 0 && !istype(loc, /atom/movable))
		price_overlay.maptext = MAPTEXT("<span valign='top' style='color: #CFF6FF; text-align: center; -dm-text-outline: 1px #0FFFEA'>[text2num(payment_amount)]C</span>")
		price_overlay.icon = 'icons/obj/device.dmi'
		price_overlay.icon_state = "holo_overlay_[length(num2text(payment_amount))]"

		set_light(1.0, 0.5, 1, 2, "#7de1e1")
	else
		price_overlay.maptext = ""
		price_overlay.icon = 'icons/effects/effects.dmi'
		price_overlay.icon_state = "blank"

		set_light(0)

	AddOverlays(price_overlay)

/obj/item/device/eftpos/pickup()
	. = ..()
	queue_icon_update()

/obj/item/device/eftpos/dropped()
	. = ..()
	queue_icon_update()

/obj/item/device/eftpos/attackby(obj/item/O, user)
	var/obj/item/card/id/id_card = O?.get_id_card()
	if(istype(id_card))
		if (input_mode == IM_SUM && payment_amount > 0)
			attempt_id_payment(id_card)
			return

		if (input_mode == IM_ACC)
			attempt_id_account_input(id_card)
			return

	else if (istype(O, /obj/item/spacecash/ewallet))
		pay_with_ewallet(O)
		return

	else if (isWrench(O) && loc == get_turf(src))
		wrench_floor_bolts(user)
		return

	return ..()

/obj/item/device/eftpos/proc/attempt_id_payment(obj/item/card/id/id_card)
	var/datum/eftpos_input_mode/current_mode = get_current_mode()
	current_mode.set_meta(list("acc" = id_card.associated_account_number))

	if (!check_account(id_card.associated_account_number, FALSE))
		return

	pay_with_account(id_card.associated_account_number)
	current_mode.reset()

/obj/item/device/eftpos/proc/attempt_id_account_input(obj/item/card/id/id_card)
	var/datum/eftpos_input_mode/current_mode = get_current_mode()
	current_mode.value = id_card.associated_account_number

	if (!current_mode.check())
		return

	if (!check_account(current_mode.value))
		return

	commit_input()

/obj/item/device/eftpos/proc/pay_with_ewallet(obj/item/spacecash/ewallet/wallet)
	if (!payment_account_number)
		return

	if (payment_amount > wallet.worth)
		return

	if (!charge_to_account(payment_account_number, wallet.owner_name, "Charge (Charge Card)", eftpos_id, payment_amount))
		return

	wallet.deduct(payment_amount)

/obj/item/device/eftpos/proc/pay_with_account(account_number)
	var/datum/money_account/buyer_account = get_account(account_number)
	if (!buyer_account || buyer_account.suspended)
		announce_message("buyer account not found or suspended", TA_ERROR)
		return

	var/datum/money_account/terminal_account = get_account(payment_account_number)
	if (!terminal_account || terminal_account.suspended)
		announce_message("EFTPOS account not found or suspended", TA_ERROR)
		return

	if (payment_amount > buyer_account.money)
		announce_message("insufficient funds", TA_ERROR)
		return

	charge_to_account(account_number, name, "Payment", eftpos_id, -payment_amount)
	charge_to_account(payment_account_number, buyer_account.owner_name, "Charge", eftpos_id, payment_amount)

	announce_message("payment complete", TA_SUCCESS)

	if (!payment_repeating)
		set_payment_amount(0)

	return TRUE

/obj/item/device/eftpos/proc/set_payment_amount(new_amount)
	payment_amount = new_amount
	queue_icon_update()

/obj/item/device/eftpos/attack_hand(mob/user)
	if (anchored)
		tgui_interact(user)
		return

	return ..()

/obj/item/device/eftpos/attack_self(mob/user)
	. = ..()
	tgui_interact(user)

/obj/item/device/eftpos/attack_ai(mob/user)
	. = ..()
	tgui_interact(user)

/obj/item/device/eftpos/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "PaymentTerminal", "EFTPOS scanner")
		ui.open()

/obj/item/device/eftpos/tgui_data(mob/user)
	var/datum/eftpos_input_mode/current_mode = get_current_mode()
	return list(
		"mode" = input_mode,
		"digits" = current_mode.value,
		"digitsFixedLength" = current_mode.require_all_digits ? current_mode.max_digits : 0,
		"isRepeating" = payment_repeating,
	)

/obj/item/device/eftpos/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	playsound(src, 'sound/machines/buttonbeep.ogg', 40, TRUE)

	switch(action)
		if("input_number")
			return act_input_number(params)
		if("input_clear")
			return act_input_clear()
		if("input_enter")
			return act_input_enter()
		if("payment_repeat")
			return act_payment_repeat()
		if("account_reset")
			return act_account_reset()

/obj/item/device/eftpos/proc/act_input_number(list/params)
	var/number = params["value"]
	if(!isnum(number))
		return FALSE
	var/datum/eftpos_input_mode/current_mode = get_current_mode()
	current_mode.put_digit(number)
	return TRUE

/obj/item/device/eftpos/proc/act_input_clear()
	var/datum/eftpos_input_mode/current_mode = get_current_mode()
	if(current_mode.value > 0)
		current_mode.value = 0
		return TRUE

	if(input_mode != IM_SUM)
		set_mode(IM_SUM)
		return TRUE

	if(payment_amount > 0)
		set_payment_amount(0)
	return FALSE

/obj/item/device/eftpos/proc/act_input_enter()
	var/datum/eftpos_input_mode/current_mode = get_current_mode()
	if(!current_mode.check())
		announce_message(current_mode.error_message, TA_ERROR)
		return FALSE

	switch(input_mode)
		if(IM_SUM)
			if(!check_account(payment_account_number))
				return TRUE
			commit_input()
		if(IM_ACC)
			if(!check_account(current_mode.value))
				return TRUE
			commit_input()
		if(IM_PIN)
			pop_mode()
			commit_input()

	return TRUE

/obj/item/device/eftpos/proc/act_payment_repeat()
	if(input_mode != IM_SUM)
		return FALSE
	payment_repeating = !payment_repeating
	return TRUE

/obj/item/device/eftpos/proc/act_account_reset()
	if(input_mode != IM_SUM)
		return FALSE
	set_mode(IM_ACC)
	return TRUE

/obj/item/device/eftpos/proc/get_current_mode()
	return input_modes[input_mode]

/obj/item/device/eftpos/proc/set_mode(mode)
	input_mode = mode
	input_mode_prev = null
	var/datum/eftpos_input_mode/M = get_current_mode()
	M.reset()

/obj/item/device/eftpos/proc/push_mode(mode)
	input_mode_prev = input_mode
	input_mode = mode

/obj/item/device/eftpos/proc/pop_mode()
	var/datum/eftpos_input_mode/M = get_current_mode()
	M.reset()
	input_mode = input_mode_prev
	input_mode_prev = null

/obj/item/device/eftpos/proc/commit_input()
	var/datum/eftpos_input_mode/current_mode = get_current_mode()

	switch (input_mode)
		if (IM_ACC)
			payment_account_number = current_mode.value
			set_mode(IM_SUM)
			announce_message("account set", TA_SUCCESS)
		if (IM_SUM)
			var/linked_account = LAZYACCESS(current_mode.meta, "acc")
			if (linked_account)
				pay_with_account(linked_account)
			else
				set_payment_amount(current_mode.value)
				announce_message("amount set", TA_SUCCESS)
			current_mode.reset()

/obj/item/device/eftpos/proc/check_account(account_number, pin_required = TRUE)
	var/datum/money_account/account = get_account(account_number)
	if (isnull(account) || account.suspended)
		announce_message("account not found or suspended", TA_ERROR)
		return FALSE

	// This way we're skipping PIN input screen if the account isn't secured.
	if (!account.security_level && !pin_required)
		return TRUE

	if (input_mode != IM_PIN)
		push_mode(IM_PIN)

	var/datum/eftpos_input_mode/pin_mode = get_current_mode()
	pin_mode.set_meta(list("acc" = account_number))
	announce_message("account action required", TA_INFO)
	tgui_update()
	return FALSE

/obj/item/device/eftpos/proc/announce_message(message, status)
	var/sound_file
	var/heard_verb
	var/heard_override
	switch(status)
		if(TA_SUCCESS)
			sound_file = 'sound/machines/ping.ogg'
			heard_verb = "chimes"
			heard_override = "*ding*"
		if(TA_ERROR)
			sound_file = 'sound/machines/buzz-sigh.ogg'
			heard_verb = "buzzes"
			heard_override = "*bzzt*"
		if(TA_INFO)
			sound_file = 'sound/machines/twobeep.ogg'
			heard_verb = "beeps"
			heard_override = "*beep-beep*"
	playsound(src, sound_file, 40, TRUE)
	audible_message(
		SPAN_NOTICE("\The [src] [heard_verb]."),
		splash_override=heard_override
		)
	visible_message(SPAN_NOTICE("\The [src] displays: \"[message]\""))

#undef TA_INFO
#undef TA_ERROR
#undef TA_SUCCESS

#undef IM_PIN
#undef IM_ACC
#undef IM_SUM

/datum/eftpos_input_mode
	/// The current numeric input value.
	var/value = 0
	/// Maximum amount of digits this mode accepts.
	var/max_digits = 3
	/// Whether all digit positions must be filled for valiadation to pass.
	var/require_all_digits = FALSE
	/// Optional metadata list for passing contextual data between modes.
	var/list/meta = null
	// Pretty, yet simplified error message for a user.
	var/error_message = "invalid value"

/datum/eftpos_input_mode/proc/reset()
	value = 0
	meta = null

/datum/eftpos_input_mode/proc/check()
	if (require_all_digits)
		var/min_value = text2num(repeat_string(max_digits, "1"))
		var/max_value = text2num(repeat_string(max_digits, "9"))
		return value >= min_value && value <= max_value

	return value > 0

/datum/eftpos_input_mode/proc/set_meta(list/new_meta)
	meta = new_meta

/datum/eftpos_input_mode/proc/put_digit(digit)
	digit = clamp(digit, 0, 9)
	value = (value * 10 + digit) % (10 ** max_digits)

/datum/eftpos_input_mode/pin
	max_digits = 4
	require_all_digits = TRUE
	error_message = "incorrect PIN"

/datum/eftpos_input_mode/pin/check()
	. = ..()
	if (!.)
		return FALSE

	var/account_number = LAZYACCESS(meta, "acc")
	if (!account_number)
		return FALSE

	var/datum/money_account/account = attempt_account_access(account_number, value, 2)
	if (isnull(account) || account.suspended)
		return FALSE

/datum/eftpos_input_mode/account
	max_digits = 6
	require_all_digits = TRUE
	error_message = "account not found or suspended"

/datum/eftpos_input_mode/account/check()
	. = ..()
	if (!.)
		return FALSE

	var/datum/money_account/MA = get_account(value)
	if (isnull(MA) || MA.suspended)
		return FALSE
