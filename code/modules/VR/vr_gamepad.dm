#define RESPAWNS_FOR_PAYMENT 3
#define PRICE_PER_USE 100
#define POINTS_FOR_CHEATER 10
/obj/machinery/gamepod
	name = "\improper gamepod"
	desc = "A gaming pod for wasting time."
	icon = 'icons/obj/machines/gamepod.dmi'
	icon_state = "gamepod_open"
	density = TRUE
	anchored = TRUE
	var/is_payed = FALSE
	var/mob/living/carbon/human/occupant = null
	var/datum/mind/occupant_mind

/obj/machinery/gamepod/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/card/id))
		if(is_payed)
			to_chat(user, SPAN("notice", "It is already payed."))
			return
		scan_card(I)
	else if(istype(I, /obj/item/weapon/card/emag))
		if(emagged)
			to_chat(user, SPAN("notice", "It is already broken."))
			return
		else
			to_chat(user, SPAN("notice", "You broke something."))
		emagged = TRUE
	else if(isScrewdriver(I))
		playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
		if(!panel_open)
			panel_open = 1
			if(occupant)
				move_outside()
			to_chat(user, SPAN("notice", "You open the maintenance hatch of [src]."))
			return
		panel_open = 0
		to_chat(user, SPAN("notice", "You close the maintenance hatch of [src]."))
		return
	else if(isCrowbar(I))
		if(!panel_open)
			to_chat(user, SPAN("notice", "You must open the maintenance hatch first."))
			return
		playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
		to_chat(user, SPAN("notice", "You pry off the circutry."))
		var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(loc)
		M.state = 2
		M.icon_state = "box_1"
		for(var/obj/item/T in component_parts)
			T.loc = src.loc
		qdel(src)
		return

/obj/machinery/gamepod/proc/scan_card(obj/item/weapon/card/id/C, mob/user)
	visible_message("<span class='info'>[user] swipes a card through [src].</span>")
	if(!station_account)
		return
	var/datum/money_account/D = get_account(C.associated_account_number)
	var/attempt_pin = 0
	if(D.security_level > 0)
		attempt_pin = input("Enter pin code", "Transaction") as num
	if(attempt_pin)
		D = attempt_account_access(C.associated_account_number, attempt_pin, 2)
	if(!D)
		to_chat(user, SPAN("warning", "No access granted!"))
		return
	var/transaction_amount = PRICE_PER_USE
	if(transaction_amount > D.money)
		to_chat(user, SPAN("warning", "You don't have that much money!"))
		return
	D.money -= transaction_amount
	station_account.money += transaction_amount
	var/datum/transaction/T = new()
	T.target_name = "[station_account.owner_name] (via [src.name])"
	T.purpose = "Purchase of thunderfield gamepod use"
	T.amount = "[transaction_amount]"
	T.source_terminal = src.name
	T.date = stationdate2text()
	T.time = stationtime2text()
	D.transaction_log.Add(T)
	T.target_name = D.owner_name
	station_account.transaction_log.Add(T)
	qdel(T)
	to_chat(user, SPAN("notice", "Transaction successful. Have a nice time."))
	is_payed = TRUE
	if(occupant)
		create_body()

/obj/machinery/gamepod/verb/get_inside()
	set name = "Enter Pod"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != CONSCIOUS || !(ishuman(usr)))
		return

	if(!is_payed)
		to_chat(usr, SPAN("notice", "Pay first."))
		return
	move_inside(usr)
	to_chat(usr, SPAN("warning", "Welcome to battleroyal game"))

/obj/machinery/gamepod/MouseDrop_T(mob/target, mob/user)
	if(user != target || target.stat != CONSCIOUS || !(ishuman(target)))
		return
	if(!is_payed)
		to_chat(user, SPAN("notice", "Pay first."))
		return
	move_inside(target)

/obj/machinery/gamepod/proc/move_inside(mob/living/carbon/human/H, mob/user)
	if(occupant)
		to_chat(user, SPAN("notice", "[src] is in use."))
		return

	if(!powered())
		return

	icon_state = "gamepod"
	H.forceMove(src)
	occupant = H
	create_body()

/obj/machinery/gamepod/proc/create_body(mob/user)
	if(!GLOB.thunderfield_spawns_list.len)
		to_chat(user, SPAN("warning", "No spawn points are available. Something went wrong."))
		return
	if(!occupant.mind)//How that can even happen?
		return
	var/obj/effect/landmark/spawnpoint = pick(GLOB.thunderfield_spawns_list)
	//Here should be some checks for safety of new vrbody
	var/mob/living/carbon/human/vrhuman/vrbody = new /mob/living/carbon/human/vrhuman(spawnpoint.loc)

	if(emagged)
		occupant.mind.thunderfield_cheater = TRUE
		occupant.mind.thunder_points = POINTS_FOR_CHEATER
	occupant.mind.thunder_respawns = RESPAWNS_FOR_PAYMENT
	occupant.mind.thunderfield_owner = occupant
	vrbody.vr_mind = occupant.mind
	vrbody.vr_shop.vr_mind = occupant.mind
	occupant_mind = occupant.mind //We need to store user's mind to return it to his original body in case of some problems
	occupant.mind.transfer_to(vrbody)
	is_payed = FALSE

/obj/machinery/gamepod/verb/get_outside()
	set name = "Exit Pod"
	set category = "Object"
	set src in oview(1)

	if(usr != occupant || usr.stat != CONSCIOUS || !(ishuman(usr) || !(isMonkey(usr))))
		to_chat(usr, SPAN("notice", "You cant do that."))
		return
	move_outside()

/obj/machinery/gamepod/relaymove(mob/user)
	..()
	move_outside()

/obj/machinery/gamepod/proc/move_outside()
	if(occupant_mind) //We need to get player back
		if(occupant in src)
			occupant.dropInto(loc)
		to_chat(occupant, SPAN("warning", "Temporary issues, VR aborted."))
		occupant_mind.thunderfield_cheater = FALSE
		occupant_mind = null
		occupant = null
	icon_state = "gamepod_open"


/obj/machinery/gamepod/emp_act()
	if(occupant)
		move_outside()
	..()

/obj/machinery/gamepod/blob_act()
	if(occupant)
		move_outside()
	..()

/obj/machinery/gamepod/power_change()
	. = ..()
	if(occupant && (stat & NOPOWER))
		move_outside()

/obj/machinery/gamepod/Destroy()
	if(occupant)
		move_outside()
	return ..()

#undef RESPAWNS_FOR_PAYMENT
#undef PRICE_PER_USE
#undef POINTS_FOR_CHEATER
