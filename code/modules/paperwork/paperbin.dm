/obj/item/paper_bin
	name = "paper bin"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin1"
	item_state = "sheet-metal"
	randpixel = 0
	throwforce = 1
	w_class = ITEM_SIZE_NORMAL
	throw_range = 7
	layer = BELOW_OBJ_LAYER
	var/amount = 30					//How much paper is in the bin.
	var/list/papers = new /list()	//List of papers put in the bin for reference.


/obj/item/paper_bin/MouseDrop(mob/user)
	if((user == usr && (!( usr.restrained() ) && (!( usr.stat ) && (usr.contents.Find(src) || in_range(src, usr))))))
		if(!istype(usr, /mob/living/carbon/metroid) && !istype(usr, /mob/living/simple_animal))
			if( !usr.get_active_hand() )		//if active hand is empty
				var/mob/living/carbon/human/H = user
				var/obj/item/organ/external/temp = H.organs_by_name[BP_R_HAND]

				if (H.hand)
					temp = H.organs_by_name[BP_L_HAND]
				if(temp && !temp.is_usable())
					to_chat(user, SPAN("notice", "You try to move your [temp.name], but cannot!"))
					return

				to_chat(user, SPAN("notice", "You pick up the [src]."))
				user.put_in_hands(src)

	return

/obj/item/paper_bin/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.organs_by_name[BP_R_HAND]
		if (H.hand)
			temp = H.organs_by_name[BP_L_HAND]
		if(temp && !temp.is_usable())
			to_chat(user, SPAN("notice", "You try to move your [temp.name], but cannot!"))
			return
	var/response = ""
	if(!papers.len > 0)
		response = alert(user, "Do you take regular paper, or Carbon copy paper?", "Paper type request", "Regular", "Carbon-Copy", "Cancel")
		if (response != "Regular" && response != "Carbon-Copy")
			add_fingerprint(user)
			return
	if(amount >= 1)
		amount--
		if(amount==0)
			update_icon()

		var/obj/item/paper/P
		if(papers.len > 0)	//If there's any custom paper on the stack, use that instead of creating a new paper.
			P = papers[papers.len]
			papers.Remove(P)
		else
			if(response == "Regular")
				P = new /obj/item/paper
				if(Holiday == "April Fool's Day")
					if(prob(30))
						P.info = "<font face=\"[P.crayonfont]\" color=\"red\"><b>HONK HONK HONK HONK HONK HONK HONK<br>HOOOOOOOOOOOOOOOOOOOOOONK<br>APRIL FOOLS</b></font>"
						P.rigged = 1
						P.generateinfolinks()
			else if (response == "Carbon-Copy")
				P = new /obj/item/paper/carbon

		P.loc = user.loc
		user.put_in_hands(P)
		to_chat(user, SPAN("notice", "You take [P] out of the [src]."))
	else
		to_chat(user, SPAN("notice", "[src] is empty!"))

	add_fingerprint(user)
	return


/obj/item/paper_bin/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/paper))
		if(istype(I, /obj/item/paper/talisman))
			return
		user.drop_item()
		I.forceMove(src)
		to_chat(user, SPAN("notice", "You put [I] in [src]."))
		papers.Add(I)
		update_icon()
		amount++
	else if(istype(I, /obj/item/paper_bundle))
		var/obj/item/paper_bundle/bundle = I
		to_chat(user, SPAN("notice", "You loosen \the [bundle] and add its papers into \the [src]."))
		var/was_there_a_photo = 0
		for(var/obj/item/bundleitem in bundle.pages) //loop through items in bundle
			if(istype(bundleitem, /obj/item/paper)) //if item is paper, add into the bin
				papers.Add(bundleitem)
				bundleitem.forceMove(src)
				amount++
			else if(istype(bundleitem, /obj/item/photo)) //if item is photo, drop it on the ground
				was_there_a_photo = 1
				bundleitem.dropInto(user.loc)
				bundleitem.reset_plane_and_layer()
		update_icon()
		bundle.pages.Cut()
		user.drop_from_inventory(bundle)
		qdel(bundle)
		if(was_there_a_photo)
			to_chat(user, SPAN("notice", "The photo cannot go into \the [src]."))
	return


/obj/item/paper_bin/_examine_text(mob/user)
	. = ..()
	if(get_dist(src, user) <= 1)
		if(amount)
			. += "\n<span class='notice'>There " + (amount > 1 ? "are [amount] papers" : "is one paper") + " in the bin.</span>"
		else
			. += "\n<span class='notice'>There are no papers in the bin.</span>"
	return


/obj/item/paper_bin/update_icon()
	if(amount < 1)
		icon_state = "paper_bin0"
	else
		icon_state = "paper_bin1"
