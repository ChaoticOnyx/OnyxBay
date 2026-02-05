/obj/item/computer_hardware/card_slot
	name = "RFID card slot"
	desc = "Slot that allows this computer to write data on RFID cards. Necessary for some programs to run properly."
	power_usage = 10 //W
	critical = 0
	icon_state = "cardreader"
	hardware_size = 1
	origin_tech = list(TECH_DATA = 2)

	var/obj/item/card/id/stored_card = null

/obj/item/computer_hardware/card_slot/Destroy()
	if(holder2 && (holder2.card_slot == src))
		holder2.card_slot = null
	if(stored_card)
		stored_card.forceMove(get_turf(holder2))
	holder2 = null
	return ..()

/obj/item/computer_hardware/card_slot/forceMove(atom/destination)
	// Eject the stored card when the card slot is removed from the computer
	if(stored_card && holder2 && destination != holder2)
		stored_card.forceMove(get_turf(src))
		stored_card = null
	return ..()
