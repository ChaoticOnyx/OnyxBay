/obj/item/weapon/paper/carbon
	name = "paper"
	icon_state = "paper_stack"
	item_state = "paper"
	var/copied = 0
	var/iscopy = 0


/obj/item/weapon/paper/carbon/update_icon()
	if(iscopy)
		if(info)
			icon_state = "cpaper_words"
			return
		icon_state = "cpaper"
	else if (copied)
		if(info)
			icon_state = "paper_words"
			return
		icon_state = "paper"
	else
		if(info)
			icon_state = "paper_stack_words"
			return
		icon_state = "paper_stack"



/obj/item/weapon/paper/carbon/verb/removecopy()
	set name = "Remove carbon-copy"
	set category = "Object"
	set src in usr

	if (copied == 0)
		var/obj/item/weapon/paper/carbon/copy = copy(usr.loc, generate_stamps = FALSE)
		copy.recolorize(saturation = 1, grayscale = TRUE)
		copy.SetName("Copy - " + copy.name)
		to_chat(usr, "<span class='notice'>You tear off the carbon-copy!</span>")
		copied = 1
		update_icon()
		copy.iscopy = 1
		copy.update_icon()
	else
		to_chat(usr, "There are no more carbon copies attached to this paper!")
