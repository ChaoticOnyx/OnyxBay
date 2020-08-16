/obj/item/weapon/paper/complaint_form
	name = "Complaint form #______"

	var/signed = FALSE
	var/signed_ckey

/obj/item/weapon/paper/complaint_form/examine(mob/user)
	. = ..()
	if (signed)
		. += "\n[SPAN_NOTICE("It appears to be signed. Any modifications will be rejected.")]"
	else
		. += "\n[SPAN_NOTICE("It appears to be unsigned and ready for modifications.")]"


/obj/item/weapon/paper/complaint_form/get_signature(obj/item/weapon/pen/P, mob/user as mob)
	signed = TRUE
	signed_ckey = user?.client?.ckey
	readonly = TRUE //nanomachines, son
	return ..()

/obj/item/weapon/paper/complaint_form/rename()
	set name = "Rename paper"
	set hidden = 1
	return

/obj/item/weapon/paper/complaint_form/New(loc, id, target_name, target_occupation)
	..(loc)
	appendable = FALSE
	var/new_title = "Complaint form #[id]: [target_name]"
	var/new_content = "Subject: [target_name]"
	new_content += "\[br\]Subject occupation: [target_occupation]"
	new_content += "\[br\]Complaint reason (brief): \[field\]"
	new_content += "\[br\]Complaint reason: \[field\]"
	new_content += "\[br\]\[right\]Name: \[field\]"
	new_content += "\[br\]Occupation: \[field\]"
	new_content += "\[br\]Sign: \[signfield\]\[/right\]"
	set_content(new_content, new_title)