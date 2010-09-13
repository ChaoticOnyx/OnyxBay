/mob/living/carbon/monkey/examine()
	set src in oview()

	usr << "\blue *---------*"
	usr << text("\blue This is \icon[] <B>[]</B>!", src, name)
	if (handcuffed)
		usr << text("\blue [] is handcuffed! \icon[]", name, handcuffed)
	if (wear_mask)
		usr << text("\blue [] has a \icon[] [] on \his[] head!", name, wear_mask, wear_mask.name, src)
	if (l_hand)
		usr << text("\blue [] has a \icon[] [] in \his[] left hand!", name, l_hand, l_hand.name, src)
	if (r_hand)
		usr << text("\blue [] has a \icon[] [] in \his[] right hand!", name, r_hand, r_hand.name, src)
	if (back)
		usr << text("\blue [] has a \icon[] [] on \his[] back!", name, back, back.name, src)
	if (stat == 2)
		usr << text("\red [] is limp and unresponsive, a dull lifeless look in their eyes.", name)
	else
		if (bruteloss)
			if (bruteloss < 30)
				usr << text("\red [] looks slightly bruised!", name)
			else
				usr << text("\red <B>[] looks severely bruised!</B>", name)
			if (fireloss)
				if (fireloss < 30)
					usr << text("\red [] looks slightly burnt!", name)
				else
					usr << text("\red <B>[] looks severely burnt!</B>", name)
				if (stat == 1)
					usr << text("\red [] doesn't seem to be responding to anything around them, their eyes closed as though asleep.", name)
	return