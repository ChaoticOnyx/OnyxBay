/obj/item/hand_labeler
	name = "hand labeler"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler0"
	item_state = "flight"
	var/label = null
	var/labels_left = 30
	var/mode = 0	//off or on.
	matter = list(MATERIAL_STEEL = 100)

/obj/item/hand_labeler/attack()
	return

/obj/item/hand_labeler/afterattack(atom/A, mob/user as mob, proximity)
	if(!proximity)
		return
	if(!mode)	//if it's off, give up.
		return
	if(A == loc)	// if placing the labeller into something (e.g. backpack)
		return		// don't set a label

	if(istype(A, /obj/structure/bigDelivery) || istype(A, /obj/item/smallDelivery))	// Restricts adding a label not through the hand labeller dialog
		return

	if(!labels_left)
		to_chat(user, SPAN("notice", "No labels left."))
		return
	if(!label || !length(label))
		to_chat(user, SPAN("notice", "No label text set."))
		return

	user.visible_message(SPAN("notice", "\The [user] attaches a label to \the [A]."),
		SPAN("notice", "You attach a label, '[label]', to \the [A]."))

	A.AddComponent(/datum/component/label, label)

/obj/item/hand_labeler/attack_self(mob/user as mob)
	mode = !mode
	icon_state = "labeler[mode]"
	if(mode)
		to_chat(user, SPAN("notice", "You turn on \the [src]."))
		//Now let them chose the text.
		var/str = sanitizeSafe(input(user,"Label text?","Set label",""), MAX_LNAME_LEN)
		if(!str || !length(str))
			to_chat(user, SPAN("notice", "Invalid text."))
			return
		label = str
		to_chat(user, SPAN("notice", "You set the text to '[str]'."))
	else
		to_chat(user, SPAN("notice", "You turn off \the [src]."))
