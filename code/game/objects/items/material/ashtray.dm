/obj/item/material/ashtray
	name = "ashtray"
	desc = "A thing to keep your butts in."
	icon = 'icons/obj/objects.dmi'
	icon_state = "ashtray"
	force_divisor = 0.1
	thrown_force_divisor = 0.1
	randpixel = 5
	mod_weight = 0.3
	mod_reach = 0.3
	mod_handy = 0.5
	w_class = ITEM_SIZE_SMALL
	hitsound = SFX_FIGHTING_SWING
	material_amount = 2
	var/max_butts = 10

/obj/item/material/ashtray/Destroy()
	for(var/obj/O in contents)
		qdel(O)
	return ..()

/obj/item/material/ashtray/_examine_text(mob/user)
	. = ..()
	if(material)
		. += "\nIt's made of [material.display_name]."
	if(contents.len >= max_butts)
		. += "\nIt's full."
	else if(contents.len)
		. += "\nIt has [contents.len] cig butts in it."

/obj/item/material/ashtray/update_icon()
	overlays.Cut()
	if (contents.len == max_butts)
		overlays |= image('icons/obj/objects.dmi', "ashtray_full")
	else if (contents.len >= max_butts/2)
		overlays |= image('icons/obj/objects.dmi', "ashtray_half")

/obj/item/material/ashtray/attackby(obj/item/W, mob/user)
	if(health <= 0)
		return
	if(istype(W,/obj/item/cigbutt) || istype(W,/obj/item/clothing/mask/smokable/cigarette) || istype(W, /obj/item/flame/match))
		if(contents.len >= max_butts)
			to_chat(user, "\The [src] is full.")
			return
		user.remove_from_mob(W)
		W.forceMove(src)

		if(istype(W,/obj/item/clothing/mask/smokable/cigarette))
			var/obj/item/clothing/mask/smokable/cigarette/cig = W
			if (cig.lit == 1)
				visible_message("[user] crushes [cig] in [src], putting it out.")
				W = cig.die(nomessage = TRUE, nodestroy = TRUE) // No need to completely destroy the cigarette and its contents
			else if (cig.lit == 0)
				to_chat(user, "You place [cig] in [src] without even smoking it. Why would you do that?")
		else
			visible_message("[user] places [W] in [src].")

		user.remove_from_mob(W, src)

		user.update_inv_l_hand()
		user.update_inv_r_hand()
		add_fingerprint(user)
		update_icon()
	else
		..()
		health = max(0,health - W.force)
		if (health < 1)
			shatter()

/obj/item/material/ashtray/throw_impact(atom/hit_atom)
	if (health > 0)
		health = max(0,health - 3)
		if (contents.len)
			visible_message("<span class='danger'>\The [src] slams into [hit_atom], spilling its contents!</span>")
			for (var/obj/O in contents)
				O.dropInto(loc)
		if (health < 1)
			shatter()
			return
		update_icon()
	return ..()

/obj/item/material/ashtray/verb/empty_butts()
	set name = "Empty Contents"
	set category = "Object"

	if(!ishuman(usr) || isobj(loc) || usr.stat || usr.restrained())
		return

	if(!contents.len)
		to_chat(usr, SPAN("notice", "\The [src] is empty!"))
		return

	visible_message(SPAN("notice", "[usr] flips \the [src], spilling its contents!"))
	for(var/obj/O in contents)
		O.dropInto(loc)

/obj/item/material/ashtray/plastic/New(newloc)
	..(newloc, MATERIAL_PLASTIC)

/obj/item/material/ashtray/bronze/New(newloc)
	..(newloc, MATERIAL_BRONZE)

/obj/item/material/ashtray/glass/New(newloc)
	..(newloc, MATERIAL_GLASS)
