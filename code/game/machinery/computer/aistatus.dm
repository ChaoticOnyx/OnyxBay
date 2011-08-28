/*I'll do a bit more on this later, for now I'm a lazy.*/

/obj/machinery/computer/aistatus/attack_hand(mob/user as mob)
	if(stat & NOPOWER)
		user << "\red The status panel has no power!"
		return
	if(stat & BROKEN)
		user << "\red The status panel is broken!"
		return
	user << "\red I don't understand any of this!"
	return