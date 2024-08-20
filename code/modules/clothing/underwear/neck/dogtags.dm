
/obj/item/underwear/neck/dogtag
	name = "dog tag"
	desc = "A simple badge that demonstrates its owner's military background."
	icon_state = "dogtag"
	slot_flags = SLOT_MASK | SLOT_TIE
	var/stored_name
	var/stored_blood_type
	var/religion

/obj/item/underwear/neck/dogtag/proc/set_name(new_name)
	stored_name = new_name
	name = "[initial(name)] ([stored_name])"

/obj/item/underwear/neck/dogtag/attack_self(mob/user)
	if(isliving(user))
		var/to_display = "It reads: [stored_name], blood type: [stored_blood_type], religious affiliation: [religion]"
		user.visible_message(SPAN_NOTICE("[user] displays their [name].\n[to_display]"), SPAN_NOTICE("You display your [name].\n[to_display]"))
