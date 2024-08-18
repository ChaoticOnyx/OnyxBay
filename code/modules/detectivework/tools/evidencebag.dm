//CONTAINS: Evidence bags and fingerprint cards

/obj/item/evidencebag
	name = "evidence bag"
	desc = "An empty evidence bag."

	icon = 'icons/obj/storage/misc.dmi'
	icon_state = "evidenceobj"
	base_icon_state = "evidence"

	w_class = ITEM_SIZE_SMALL

	var/obj/item/stored_item = null

/obj/item/evidencebag/attackby(obj/item/I, mob/user)
	if(!istype(I) || !istype(user))
		return FALSE

	put_item(I, user)

/obj/item/evidencebag/MouseDrop_T(obj/item/I, mob/living/carbon/human/user)
	if(!istype(user))
		return FALSE

	if(!istype(I) || I.anchored)
		return FALSE

	if (isturf(I.loc))
		if (!user.Adjacent(I))
			return FALSE
	else
		//If it isn't on the floor. Do some checks to see if it's in our hands or a box. Otherwise give up.
		if(istype(I.loc,/obj/item/storage))	//in a container.
			var/sdepth = I.storage_depth(user)
			if (sdepth == -1 || sdepth > 1)
				return	//too deeply nested to access

			var/obj/item/storage/U = I.loc
			user.client.screen -= I
			U.contents.Remove(I)
			I.forceMove(get_turf(U))
		else if(user.l_hand == I || user.r_hand == I)					//in a hand
			attackby(I, user)
			return FALSE
		else
			return FALSE

	put_item(I, user)

/obj/item/evidencebag/proc/put_item(obj/item/I, mob/user)
	if(istype(I, /obj/item/evidencebag))
		to_chat(user, SPAN_NOTICE("You find putting an evidence bag in another evidence bag to be slightly absurd."))
		return FALSE

	if(I.w_class > ITEM_SIZE_NORMAL)
		to_chat(user, SPAN_NOTICE("[I] won't fit in [src]."))
		return FALSE

	if(stored_item)
		to_chat(user, SPAN_NOTICE("[src] already has something inside it."))
		return FALSE

	if(!user.drop(I, src))
		return FALSE

	user.visible_message("[user] puts [I] into [src]", "You put [I] inside [src].",\
	"You hear a rustle as someone puts something into a plastic bag.")
	store_item(I)
	return TRUE

/obj/item/evidencebag/proc/store_item(obj/item/I)
	I.forceMove(src)

	icon_state = base_icon_state

	var/item_x = I.pixel_x	//save the offset of the item
	var/item_y = I.pixel_y
	I.pixel_x = 0		//then remove it so it'll stay within the evidence bag
	I.pixel_y = 0
	var/image/img = image(I.icon, I.icon_state, layer = FLOAT_LAYER)	//take a snapshot. (necessary to stop the underlays appearing under our inventory-HUD slots ~Carn
	img.SetTransform(scale = 0.7)
	I.pixel_x = item_x		//and then return it
	I.pixel_y = item_y
	AddOverlays(img) // should look nicer for transparent stuff. not really that important, but hey.
	AddOverlays(base_icon_state)

	desc = "\A [initial(name)] containing [I]."
	stored_item = I
	w_class = I.w_class

	return TRUE

/obj/item/evidencebag/attack_self(mob/user)
	if(stored_item)
		var/obj/item/I = contents[1]
		user.visible_message("[user] takes [I] out of [src]", "You take [I] out of [src].",\
		"You hear someone rustle around in a plastic bag, and remove something.")
		ClearOverlays()	//remove the overlays

		user.pick_or_drop(I)
		stored_item = null

		w_class = initial(w_class)
		icon_state = "[base_icon_state]obj"
		desc = initial(desc)
	else
		to_chat(user, "[src] is empty.")
		icon_state = "[base_icon_state]obj"
	return

/obj/item/evidencebag/examine(mob/user, infix)
	. = ..()

	if(!stored_item)
		return

	. += stored_item.examine(user)

/obj/item/evidencebag/cyborg
	name = "integrated evidence bag dispenser"
	desc = "used for detective cyborg to collect evidences."

/obj/item/evidencebag/cyborg/afterattack(atom/target, mob/living/user, proximity)
	if(!target)
		return
	if(!proximity)
		return
	if(!isturf(target.loc))
		return
	if(istype(target, /obj/item))
		var/obj/item/evidencebag/EB
		if(istype(target, /obj/item/evidencebag))
			EB = target
			if(EB.stored_item)
				EB.attack_self(user)
			else
				qdel(EB)

		var/obj/item/I = target
		EB = new(get_turf(src))

		if(!EB.attackby(I, user))
			qdel(EB)

/obj/item/evidencebag/cyborg/attack_self(mob/user)
	return

/obj/item/evidencebag/cyborg/MouseDrop_T(obj/item/I as obj)
	return

/obj/item/evidencebag/research
	name = "sample bag"
	desc = "A bag for holding research samples."
	base_icon_state = "samplebag"
