/obj/item/clothing/proc/can_attach_accessory(obj/item/clothing/accessory/A)
	if(valid_accessory_slots && istype(A) && (A.slot in valid_accessory_slots))
		.=1
	else
		return 0
	if(accessories.len && restricted_accessory_slots && (A.slot in restricted_accessory_slots))
		for(var/obj/item/clothing/accessory/AC in accessories)
			if (AC.slot == A.slot)
				return 0

/obj/item/clothing/attackby(obj/item/I, mob/user)
	if(is_sharp(I) && istype(src, /obj/item/clothing/under))
		var/mob/living/carbon/human/H = user
		if(H.wear_suit)
			to_chat(user, "<span class='warning'>You are unable to cut your underwear as \the [H.wear_suit] is in the way.</span>")
			return

		if(accessories.len)
			to_chat(user, "<span class='warning'>You are unable to make rag as \the [src] have attachment.</span>")
			return

		user.visible_message("<span class='notice'>\The [user] begins cutting up \the [src] with \a [I].</span>", "<span class='notice'>You begin cutting up \the [src] with \the [I].</span>")

		if(do_after(user, 20, src))
			to_chat(user, "<span class='notice'>You cut \the [src] into pieces!</span>")
			for(var/i in 1 to rand(2,3))
				new /obj/item/weapon/reagent_containers/glass/rag(get_turf(src))
			qdel(src)
		return

	if(istype(I, /obj/item/clothing/accessory))
		if(!valid_accessory_slots || !valid_accessory_slots.len)
			to_chat(usr, "<span class='warning'>You cannot attach accessories of any kind to \the [src].</span>")
			return

		var/obj/item/clothing/accessory/A = I
		if(can_attach_accessory(A))
			user.drop_item()
			attach_accessory(user, A)
			return
		else
			to_chat(user, "<span class='warning'>You cannot attach more accessories of this type to [src].</span>")
		return

	for(var/obj/item/clothing/accessory/A in accessories)
		A.attackby(I, user)
	return

	..()

/obj/item/clothing/attack_hand(mob/user)
	//only forward to the attached accessory if the clothing is equipped (not in a storage)
	if(accessories.len && src.loc == user)
		var/obj/item/clothing/accessory/A = accessories[accessories.len] // only upper accessory can be fast accessed
		A.attack_hand(user)
		return
	return ..()

/obj/item/clothing/MouseDrop(obj/over_object)
	if (!over_object || !(ishuman(usr) || issmall(usr)))
		return

	//makes sure that the clothing is equipped so that we can't drag it into our hand from miles away.
	if (!(src.loc == usr))
		return

	if (usr.incapacitated())
		return

	if (!usr.unEquip(src))
		return

	switch(over_object.name)
		if("r_hand")
			usr.put_in_r_hand(src)
		if("l_hand")
			usr.put_in_l_hand(src)
	src.add_fingerprint(usr)

/obj/item/clothing/examine(mob/user)
	. = ..(user)
	for(var/obj/item/clothing/accessory/A in accessories)
		to_chat(user, "\icon[A] \A [A] is attached to it.")

/obj/item/clothing/proc/update_accessory_slowdown()
	slowdown_accessory = 0
	for(var/obj/item/clothing/accessory/A in accessories)
		slowdown_accessory += A.slowdown

/obj/item/clothing/verb/makerag_verb()
	set name = "Make Rag"
	set category = "Object"
	set src in usr

	if(!istype(src, /obj/item/clothing/under))
		to_chat(usr, "<span class='warning'>You abble to make rag only from underwear.</span>")
		return

	if(accessories.len)
		to_chat(usr, "<span class='warning'>You are unable to make rag as \the [src] have attachment.</span>")
		return

	var/mob/living/carbon/human/H = usr
	if(H.wear_suit == src)
		to_chat(usr, "<span class='warning'>You are unable to make rag as \the [H.wear_suit] is in the way.</span>")
		return

	usr.visible_message("<span class='notice'>\The [usr] begins make rag \the [src]</span>", "<span class='notice'>You begin cutting up \the [src]</span>")

	if(do_after(usr, 50, src))
		to_chat(usr, "<span class='notice'>You cut \the [src] into rag!</span>")
		new /obj/item/weapon/reagent_containers/glass/rag(get_turf(src))
		qdel(src)

/**
 *  Attach accessory A to src
 *
 *  user is the user doing the attaching. Can be null, such as when attaching
 *  items on spawn
 */
/obj/item/clothing/proc/attach_accessory(mob/user, obj/item/clothing/accessory/A)
	accessories += A
	A.on_attached(src, user)
	src.verbs |= /obj/item/clothing/proc/removetie_verb
	update_accessory_slowdown()
	update_clothing_icon()

/obj/item/clothing/proc/remove_accessory(mob/user, obj/item/clothing/accessory/A)
	if(!(A in accessories))
		return

	A.on_removed(user)
	accessories -= A
	update_accessory_slowdown()
	update_clothing_icon()

/obj/item/clothing/proc/removetie_verb()
	set name = "Remove Accessory"
	set category = "Object"
	set src in usr
	if(!istype(usr, /mob/living)) return
	if(usr.stat) return
	if(!accessories.len) return
	var/obj/item/clothing/accessory/A
	if(accessories.len > 1)
		A = input("Select an accessory to remove from [src]") as null|anything in accessories
	else
		A = accessories[1]
	src.remove_accessory(usr,A)
	if(!accessories.len)
		src.verbs -= /obj/item/clothing/proc/removetie_verb

/obj/item/clothing/emp_act(severity)
	if(accessories.len)
		for(var/obj/item/clothing/accessory/A in accessories)
			A.emp_act(severity)
	..()
