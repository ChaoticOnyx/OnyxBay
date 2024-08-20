
// Lockets
/obj/item/underwear/neck/locket
	name = "locket necklace"
	desc = "A locket on a chain that seems to have space for a photo within."
	icon_state = "locket"
	item_state = "locket"
	slot_flags = 0
	w_class = ITEM_SIZE_SMALL
	slot_flags = SLOT_MASK | SLOT_TIE
	var/base_icon
	var/open
	var/obj/item/held //Item inside locket.
	var/held_alt = 0
	var/held_alt_desc = ""

/obj/item/underwear/neck/locket/Destroy()
	QDEL_NULL(held)
	return ..()

/obj/item/underwear/neck/locket/attack_self(mob/user as mob)
	if(!base_icon)
		base_icon = icon_state

	if(!("[base_icon]_open" in icon_states(icon)))
		to_chat(user, "\The [src] doesn't seem to open.")
		return

	open = !open
	to_chat(user, "You flip \the [src] [open?"open":"closed"].")
	if(open)
		icon_state = "[base_icon]_open"
		if(held)
			to_chat(user, "\The [held] falls out!")
			held.dropInto(user.loc)
			held = null
	else
		icon_state = "[base_icon]"

/obj/item/underwear/neck/locket/attackby(obj/item/O as obj, mob/user as mob)
	if(!open)
		to_chat(user, "You have to open it first.")
		return

	if(istype(O,/obj/item/paper) || istype(O, /obj/item/photo))
		if(held_alt == 1)
			to_chat(usr, "\The [src] already has something unremovable inside it.")
			return
		if(held)
			to_chat(usr, "\The [src] already has something inside it.")
		else if(user.drop(O, src))
			to_chat(usr, "You slip [O] into [src].")
			src.held = O
			src.held_alt = 1
		return
	..()

/obj/item/underwear/neck/locket/verb/setphoto()
	set name = "Set Locket"
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return 0

	if(src.held_alt == 1)
		to_chat(usr, "It's too late.")
		return 0
	else
		src.held_alt_desc = sanitize(input("The locket contains...") as text|null)
		if(!held_alt_desc)
			return
		else
			desc = "A silver locket. It contains [src.held_alt_desc]."
