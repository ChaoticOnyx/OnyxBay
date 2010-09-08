/mob/living/silicon/robot/examine()
	set src in oview()

	usr << "\blue *---------*"
	usr << text("\blue This is \icon[src] <B>[name]</B>!")
	if (stat == 2)
		usr << text("\red [name] is powered-down.")
	if (bruteloss)
		if (bruteloss < 75)
			usr << text("\red [name] looks slightly dented")
		else
			usr << text("\red <B>[name] looks severely dented!</B>")
	if (fireloss)
		if (fireloss < 75)
			usr << text("\red [name] looks slightly burnt!")
		else
			usr << text("\red <B>[name] looks severely burnt!</B>")
	if (stat == 1)
		usr << text("\red [name] doesn't seem to be responding.")
	if(opened)
		usr << "The cover is open and the power cell is [ cell ? "installed" : "missing"]."
	else
		usr << "The cover is closed."
	return