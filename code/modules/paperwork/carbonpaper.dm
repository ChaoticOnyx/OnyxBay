/obj/item/weapon/paper/carbon
	name = "paper"
	icon_state = "paper_stack"
	item_state = "paper"
	var/copied = FALSE


/obj/item/weapon/paper/carbon/update_icon()
	if(!crumpled)
		icon_state = copied ? "cpaper" : "paper_stack"
		if(!is_clean())
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
		var/obj/item/weapon/paper/copy = copy(usr.loc, generate_stamps = FALSE)
		copy.recolorize(saturation = 1, grayscale = TRUE)
		copy.SetName("Copy - " + copy.name)
		to_chat(usr, SPAN_NOTICE("You tear off the carbon-copy!"))
		copied = TRUE
		update_icon()
		copy.update_icon()
	else
		to_chat(usr, SPAN_NOTICE("There are no more carbon copies attached to this paper!"))
