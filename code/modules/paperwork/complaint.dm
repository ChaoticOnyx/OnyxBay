/obj/item/weapon/paper/complaint_form
	name = "Complaint form #______"

	var/id
	var/signed = FALSE
	var/signed_ckey

/obj/item/weapon/paper/complaint_form/examine(mob/user)
	. = ..()
	if (signed)
		. += "\n[SPAN_NOTICE("It appears to be signed. Any modifications will be rejected.")]"
	else
		. += "\n[SPAN_NOTICE("It appears to be unsigned and ready for modifications.")]"


/obj/item/weapon/paper/complaint_form/get_signature(obj/item/weapon/pen/P, mob/user as mob, signfield)
	if (signfield == "finish")
		signed = TRUE
		signed_ckey = user?.client?.ckey
		make_readonly() //nanomachines, son
	return ..()

// /obj/item/weapon/paper/complaint_form/parsepencode(t, obj/item/weapon/pen/P, mob/user, iscrayon, isfancy, is_init = FALSE)
// 	if (!is_init)
// 		t = replacetext(t, @"[signfield]", "")
// 		t = replacetext(t, @"[sign]", "")
// 	return ..()


/obj/item/weapon/paper/complaint_form/rename()
	set name = "Rename paper"
	set hidden = 1
	return

/obj/item/weapon/paper/complaint_form/New(loc, id, target_name, target_occupation)
	..(loc)
	appendable = FALSE
	src.id = id
	var/new_title = "Complaint form #[id]: [target_name]"
	var/new_content = "Subject: [target_name]"
	new_content += "\[br\]Subject occupation: [target_occupation]"
	new_content += "\[br\]Complaint reason (brief): \[field=brief_reason\]"
	new_content += "\[br\]Complaint reason: \[field=reason\]"
	new_content += "\[br\]\[hr\]"
	new_content += "\[br\]\[right\]Name: \[field=name\]"
	new_content += "\[br\]Occupation: \[field=occupation\]"
	new_content += "\[br\]Sign: \[signfield=finish\]\[/right\]"
	set_content(new_content, new_title)



/obj/item/weapon/complaint_folder
	name = "Complaint #______"
	desc = "The pen is mightier than the sword."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "folder"
	w_class = ITEM_SIZE_SMALL

	var/id
	var/signed = FALSE
	var/signed_ckey

	var/author_name
	var/const/author_occupation
	var/subject_name
	var/subject_occupation

/obj/item/weapon/complaint_folder/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/paper/complaint_form))
		var/obj/item/weapon/paper/complaint_form/CF = W
		if (id == CF.id)
			to_chat(user, SPAN_NOTICE("You add \the [CF] to \the [src]."))
			CF.forceMove(src)
			return
		to_chat(user, SPAN_WARNING("IDs don't match!"))
		return
	if (istype(W, /obj/item/weapon/pen))
		if (signed)
			to_chat(user, SPAN_WARNING("[src] is already signed! You can't modify it!"))
			return
