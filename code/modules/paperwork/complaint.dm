/obj/item/weapon/paper/complaint_form
	name = "Complaint form #______"

	var/id
	var/signed = FALSE
	var/signed_ckey
	var/signed_name

/obj/item/weapon/paper/complaint_form/examine(mob/user)
	. = ..()
	if (signed)
		. += "\n[SPAN_NOTICE("It appears to be signed. Any modifications will be rejected.")]"
	else
		. += "\n[SPAN_NOTICE("It appears to be unsigned and ready for modifications.")]"


/obj/item/weapon/paper/complaint_form/get_signature(obj/item/weapon/pen/P, mob/user as mob, signfield)
	. = ..()
	if (signfield == "finish")
		signed = TRUE
		signed_ckey = user?.client?.ckey
		signed_name = strip_html_properly(.)
		name += ", signed by [signed_name]"
		make_readonly() //nanomachines, son

// /obj/item/weapon/paper/complaint_form/parsepencode(t, obj/item/weapon/pen/P, mob/user, iscrayon, isfancy, is_init = FALSE)
// 	if (!is_init)
// 		t = replacetext(t, @"[signfield]", "")
// 		t = replacetext(t, @"[sign]", "")
// 	return ..()


/obj/item/weapon/paper/complaint_form/rename()
	set name = "Rename paper"
	set hidden = 1
	return

/obj/item/weapon/paper/complaint_form/New(loc, id, target_name, target_occupation, noinit = FALSE)
	. = ..(loc)
	if (noinit)
		return
	appendable = FALSE
	src.id = id
	var/new_title = "Complaint form #[id]"
	if (target_name)
		new_title += ": [target_name]"
	var/new_content = "ID: [id]"
	new_content += "\[br\]Subject: [target_name ? target_name : @"[field=target_name]"]"
	new_content += "\[br\]Subject occupation: [target_occupation ? target_occupation : @"[field=target_occupation]"]"
	new_content += "\[br\]Complaint reason (brief): \[field=brief_reason\]"
	new_content += "\[br\]Complaint reason: \[field=reason\]"
	new_content += "\[br\]\[hr\]"
	new_content += "\[br\]\[right\]Name: \[field=name\]"
	new_content += "\[br\]Occupation: \[field=occupation\]"
	new_content += "\[br\]Sign: \[signfield=finish\]\[/right\]"
	set_content(new_content, new_title)

/obj/item/weapon/paper/complaint_form/copy(loc = src.loc)
	var/obj/item/weapon/paper/complaint_form/CF = ..()
	CF.id = id
	CF.signed = signed
	CF.signed_ckey = signed_ckey
	CF.signed_name = signed_name
	return CF


/obj/item/weapon/complaint_folder
	name = "Complaint #______"
	desc = "The pen is mightier than the sword."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "folder"
	w_class = ITEM_SIZE_SMALL

	var/id
	var/target_name
	var/target_occupation
	var/signed = FALSE
	var/obj/item/weapon/paper/complaint_form/main_form

/obj/item/weapon/complaint_folder/proc/copy(loc = src.loc)
	var/obj/item/weapon/complaint_folder/CFo = new src.type(loc, noinit = TRUE)
	CFo.name = name
	CFo.id = id
	CFo.target_name = target_name
	CFo.target_occupation = target_occupation
	for (var/obj/item/weapon/paper/complaint_form/CF in contents)
		if (CF != main_form)
			CF.copy(CFo)
	CFo.main_form = main_form.copy(CFo)

/obj/item/weapon/complaint_folder/New(loc, id, noinit = FALSE)
	. = ..()
	if (noinit)
		return
	src.id = id
	name = "Complaint #[id]"
	main_form = new(src, id)

/obj/item/weapon/complaint_folder/examine(mob/user)
	. = ..()
	if (main_form.signed)
		. += "\n[SPAN_NOTICE("It is signed by [main_form.signed_name]")]"
		if (length(contents) > 1)
			var/counter = 0
			for (var/obj/item/weapon/paper/complaint_form/F in contents)
				counter++
			. += "\n[SPAN_NOTICE("It has [counter - 1] complaint forms attached")]"

/obj/item/weapon/complaint_folder/proc/check_signed()
	if (signed)
		return TRUE
	if (main_form.signed)
		var/fields = main_form.parse_named_fields()
		target_name = strip_html_properly(fields["target_name"])
		target_occupation = strip_html_properly(fields["target_occupation"])
		signed = TRUE
		return TRUE

/obj/item/weapon/complaint_folder/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/paper/complaint_form))
		var/obj/item/weapon/paper/complaint_form/CF = W
		if (!check_signed())
			to_chat(user, SPAN_WARNING("Sign [src] first!")) //how did they get complaint form tho?
			return
		if (id == CF.id)
			to_chat(user, SPAN_NOTICE("You add \the [CF] to \the [src]."))
			user.drop_item()
			CF.forceMove(src)
			return
		to_chat(user, SPAN_WARNING("IDs don't match!"))
		return

	if (istype(W, /obj/item/weapon/pen))
		main_form.attackby(W, user)
		return

	return ..()

/obj/item/weapon/complaint_folder/attack_self(mob/living/user as mob)
	user.examinate(main_form)
	return ..()

/obj/item/weapon/complaint_folder/attack_hand(mob/user)
	if (user.get_inactive_hand() != src)
		return ..()
	if (!check_signed())
		to_chat(user, SPAN_WARNING("Sign [src] first!"))
		return
	var/list/choices_list = list()
	for (var/obj/item/weapon/paper/complaint_form/F in contents)
		if (F != main_form)
			choices_list += F
	var/const/new_form_choice = "New complaint form"
	choices_list += new_form_choice
	var/action = input(user, "Choose form to take out", name, new_form_choice) as null|anything in choices_list
	if (!action)
		return
	if (istype(action,/obj/item/weapon/paper/complaint_form))
		user.put_in_hands(action)
		to_chat(user, SPAN_NOTICE("You take [action] out of [src]."))
		return
	if (action == new_form_choice)
		var/new_form = new /obj/item/weapon/paper/complaint_form(src.loc, id, target_name, target_occupation)
		user.put_in_hands(new_form)
		to_chat(user, SPAN_NOTICE("You take [new_form] out of [src]."))
		return
