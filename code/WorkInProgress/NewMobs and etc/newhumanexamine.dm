/mob/living/carbon/human/examine()
	set src in view()

	usr << "\blue *---------*"

	usr << "\blue This is \icon[icon] <B>[name]</B>!"

	// crappy hack because you can't do \his[src] etc
	var/t_his = "its"
	var/t_him = "it"
	if (gender == MALE)
		t_his = "his"
		t_him = "him"
	else if (gender == FEMALE)
		t_his = "her"
		t_him = "her"

	if (w_uniform)
		if (w_uniform.blood_DNA)
			usr << "\red [name] is wearing a[w_uniform.blood_DNA ? " bloody " : " "] \icon[w_uniform] [w_uniform.name]!"
		else
			usr << "\blue [name] is wearing a \icon[w_uniform] [w_uniform.name]."

	if (handcuffed)
		usr << "\blue [name] is \icon[handcuffed] handcuffed!"

	if (wear_suit)
		if (wear_suit.blood_DNA)
			usr << "\red [name] has a[wear_suit.blood_DNA ? " bloody " : " "] \icon[wear_suit] [wear_suit.name] on!"
		else
			usr << "\blue [name] has a \icon[wear_suit] [wear_suit.name] on."

	if (ears)
		usr << "\blue [name] has a \icon[ears] [ears.name] by [t_his] mouth."

	if (wear_mask)
		if (wear_mask.blood_DNA)
			usr << "\red [name] has a[wear_mask.blood_DNA ? " bloody " : " "] \icon[wear_mask] [wear_mask.name] on [t_his] face!"
		else
			usr << "\blue [name] has a \icon[wear_mask] [wear_mask.name] on [t_his] face."

	if (l_hand)
		if (l_hand.blood_DNA)
			usr << "\red [name] has a[l_hand.blood_DNA ? " bloody " : " "] \icon[l_hand] [l_hand.name] in [t_his] left hand!"
		else
			usr << "\blue [name] has a \icon[l_hand] [l_hand.name] in [t_his] left hand."

	if (r_hand)
		if (r_hand.blood_DNA)
			usr << "\red [name] has a[r_hand.blood_DNA ? " bloody " : " "] \icon[r_hand] [r_hand.name] in [t_his] right hand!"
		else
			usr << "\blue [name] has a \icon[r_hand] [r_hand.name] in [t_his] right hand."

	if (belt)
		if (belt.blood_DNA)
			usr << "\red [name] has a[belt.blood_DNA ? " bloody " : " "] \icon[belt] [belt.name] on [t_his] belt!"
		else
			usr << "\blue [name] has a \icon[belt] [belt.name] on [t_his] belt."

	if (gloves)
		if (gloves.blood_DNA)
			usr << "\red [name] has bloody \icon[gloves] [gloves.name] on [t_his] hands!"
		else
			usr << "\blue [name] has \icon[gloves] [gloves.name] on [t_his] hands."
	else if (blood_DNA)
		usr << "\red [name] has[blood_DNA ? " bloody " : " "] hands!"

	if (back)
		usr << "\blue [name] has a \icon[back] [back.name] on [t_his] back."

	if (wear_id)
		if (wear_id.registered != real_name && in_range(src, usr) && prob(10))
			usr << "\red [name] is wearing \icon[wear_id] [wear_id.name] yet doesn't seem to be that person!!!"
		else
			usr << "\blue [name] is wearing \icon[wear_id] [wear_id.name]."

	if (is_jittery)
		switch(jitteriness)
			if(300 to INFINITY)
				usr << "\red [src] is violently convulsing."
			if(200 to 300)
				usr << "\red [src] looks extremely jittery."
			if(100 to 200)
				usr << "\red [src] is twitching ever so slightly."

	if (stat == 2 || changeling_fakedeath == 1)
		var/datum/organ/external/T = organs["head"]
		usr << "\red [src] is limp and unresponsive[T.destroyed ? "." : ", a dull lifeless look in [t_his] eyes"]"
	else
		if (bruteloss)
			if (bruteloss < 30)
				usr << "\red [name] looks slightly injured!"
			else
				usr << "\red <B>[name] looks severely injured!</B>"

		if (fireloss)
			if (fireloss < 30)
				usr << "\red [name] looks slightly burned!"
			else
				usr << "\red <B>[name] looks severely burned!</B>"

		if (stat == 1)
			usr << "\red [name] doesn't seem to be responding to anything around [t_him], [t_his] eyes closed as though asleep."
		else if (brainloss >= 60)
			usr << "\red [name] has a stupid expression on [t_his] face."
	for(var/datum/organ/external/temp in organs2)
		if(temp.destroyed)
			usr << "\red [name] is missing [t_his] [temp.display_name]."
		if(temp.wounds)
			for(var/datum/organ/external/wound/w in temp.wounds)
				var/size = w.wound_size
				var/sizetext
				switch(size)
					if(1)
						sizetext = "cut"
					if(2)
						sizetext = "deep cut"
					if(3)
						sizetext = "flesh wound"
					if(4)
						sizetext = "gaping wound"
					if(5)
						sizetext = "big gaping wound"
					if(6)
						sizetext = "fleshwound"
				if(w.bleeding)
					usr << "\red [name] is bleeding from a [sizetext] on [t_his] [temp.display_name]."
					continue
	usr << "\blue *---------*"
