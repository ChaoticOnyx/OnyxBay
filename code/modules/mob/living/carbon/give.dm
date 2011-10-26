mob/living/carbon/verb/give(var/mob/living/carbon/A)
	set name = "Give"
	set src in view(1)
	if(A.stat == STAT_DEAD || A.client == null)
		return
	var/obj/item/I
	if(!hand && r_hand == null)
		usr << "You don't have anything in your right hand to give to [A.name]"
		return
	if(hand && l_hand == null)
		usr << "You don't have anything in your left hand to give to [A.name]"
		return
	if(hand)
		I = l_hand
	else if(!hand)
		I = r_hand
	if(!I)
		return
	var/obj/item/weapon/T = new(src.loc)
	if(!A.loc.Enter(T))
		usr << "Can't reach him"
		del(T)
		return
	del(T)
	if(A.r_hand == null)
		switch(alert(A,"[src.name] wants to give you \a [I.name]?",,"Yes","No"))
			if("Yes")
				drop_item(I)
				A.r_hand = I
				I.loc = A
				I.layer = 20
				I.add_fingerprint(A)
				A.update_clothing()
				src.update_clothing()
				action_message(src,"[src.name] handed \the [I.name] to [A.name].")
			if("No")
				action_message(src,"[src.name] tried to hand [I.name] to [A.name] but [A.name] didn't want it.")
	else if(A.l_hand == null)
		switch(alert(A,"[src.name] wants to give you \a [I.name]?",,"Yes","No"))
			if("Yes")
				drop_item(I)
				A.l_hand = I
				I.loc = A
				I.layer = 20
				I.add_fingerprint(A)
				A.update_clothing()
				src.update_clothing()
				action_message(src,"[src.name] handed \the [I.name] to [A.name].")
			if("No")
				action_message(src,"[src.name] tried to hand [I.name] to [A.name] but [A.name] didn't want it.")
	else
		usr << "[A.name]\s hands are full."
proc/action_message(var/mob/living/carbon/A,var/message)
	if (message != "")
		if (1 & 1)
			for (var/mob/O in viewers(A.loc, null))
				O.show_message(message, 1)
		else if (1 & 2)
			for (var/mob/O in hearers(A.loc, null))
				O.show_message(message, 1)
	else if (message != "")
		if (1 & 1)
			for (var/mob/O in viewers(A, null))
				O.show_message(message, 1)
		else if (1 & 2)
			for (var/mob/O in hearers(A, null))
				O.show_message(message, 1)