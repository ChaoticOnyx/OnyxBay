/obj/item/weapon/paper/carbon
	name = "paper"
	icon_state = "paper_stack"
	item_state = "paper"
	var/copied = FALSE
	var/iscopy = FALSE


/obj/item/weapon/paper/carbon/update_icon()
	if(!findtext(icon_state,"scrap"))
		if(iscopy)
			icon_state = "cpaper"
		else if (copied)
			icon_state = "paper"
		else
			icon_state = "paper_stack"
		if(length(info)>length("<!--paper_field_end-->"))
			icon_state += "_words"
	else
		icon_state = "scrap"
	if(taped)
		icon_state += "_taped"


/obj/item/weapon/paper/carbon/verb/removecopy()
	set name = "Remove carbon-copy"
	set category = "Object"
	set src in usr

	if (!copied)
		var/obj/item/weapon/paper/carbon/copy = copy(usr.loc, generate_stamps = FALSE)
		copy.recolorize(saturation = 1, grayscale = TRUE)
		copy.SetName("Copy - " + copy.name)
		to_chat(usr, "<span class='notice'>You tear off the carbon-copy!</span>")
		copied = TRUE
		update_icon()
		copy.iscopy = TRUE
		copy.update_icon()
	else
		to_chat(usr, "There are no more carbon copies attached to this paper!")
