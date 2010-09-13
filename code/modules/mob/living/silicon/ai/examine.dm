/mob/living/silicon/ai/examine()
	set src in oview()

	usr << "\blue *---------*"
	usr << text("\blue This is \icon[] <B>[]</B>!", src, name)
	if (stat == 2)
		usr << text("\red [] is powered-down.", name)
	else
		if (bruteloss)
			if (bruteloss < 30)
				usr << text("\red [] looks slightly dented", name)
			else
				usr << text("\red <B>[] looks severely dented!</B>", name)
			if (fireloss)
				if (fireloss < 30)
					usr << text("\red [] looks slightly burnt!", name)
				else
					usr << text("\red <B>[] looks severely burnt!</B>", name)
				if (stat == 1)
					usr << text("\red [] doesn't seem to be responding.", name)
	return