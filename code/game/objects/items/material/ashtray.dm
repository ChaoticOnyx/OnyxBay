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
	var/holey = FALSE

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

/obj/item/material/ashtray/on_update_icon()
	ClearOverlays()
	if (contents.len == max_butts)
		AddOverlays(image('icons/obj/objects.dmi', "ashtray_full"))
	else if (contents.len >= max_butts/2)
		AddOverlays(image('icons/obj/objects.dmi', "ashtray_half"))

/obj/item/material/ashtray/proc/store(obj/item/W, mob/user)
	if(QDELETED(W))
		return FALSE
	if(!(istype(W, /obj/item/cigbutt) || istype(W, /obj/item/clothing/mask/smokable/cigarette) || istype(W, /obj/item/flame/match)))
		return FALSE
	if(length(contents) >= max_butts)
		to_chat(user, "\The [src] is full.")
		return FALSE
	if(istype(W, /obj/item/clothing/mask/smokable/cigarette))
		var/obj/item/clothing/mask/smokable/cigarette/C = W
		if(C.lit)
			visible_message("[user] crushes [C] in [src], putting it out.")
			W = C.die(nomessage = TRUE, nodestroy = TRUE)
			if(QDELETED(W))
				return // things without after-die remnants
		else
			to_chat(user, SPAN_NOTICE("You place [C] in [src] without even smoking it. Why would you do that?"))

	visible_message("[user] places [W] in [src].")
	if(iscarbon(W.loc))
		var/mob/living/carbon/M = W.loc
		M.drop(W, src)
	else
		W.forceMove(src)
	add_fingerprint(user)
	update_icon()

	return TRUE

/obj/item/material/ashtray/attackby(obj/item/W, mob/user)
	if(health <= 0)
		return
	if(store(W, user))
		return
	if(isScrewdriver(W))
		to_chat(user, "You punch some holes in \the [src]!")
		holey = TRUE
		return
	else if(holey && istype(W, /obj/item/stack/rods))
		var/obj/item/stack/rods/V = W
		V.use(1)
		var/obj/item/hookah_coal/makeshift/HC = new (get_turf(src))
		HC.color = color
		if(user.get_inactive_hand() == src)
			user.drop(src)
			user.pick_or_drop(HC)
		qdel_self()
	else
		..()
		health = max(0, health - W.force)
		if(health < 1)
			shatter()

/obj/item/material/ashtray/throw_impact(atom/hit_atom)
	if (health > 0)
		health = max(0,health - 3)
		if (contents.len)
			visible_message(SPAN_DANGER("\The [src] slams into [hit_atom], spilling its contents!"))
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
		to_chat(usr, SPAN_NOTICE("\The [src] is empty!"))
		return

	visible_message(SPAN_NOTICE("[usr] flips \the [src], spilling its contents!"))
	for(var/obj/O in contents)
		O.dropInto(loc)
	update_icon()

/obj/item/material/ashtray/plastic/New(newloc)
	..(newloc, MATERIAL_PLASTIC)

/obj/item/material/ashtray/bronze/New(newloc)
	..(newloc, MATERIAL_BRONZE)

/obj/item/material/ashtray/glass/New(newloc)
	..(newloc, MATERIAL_GLASS)
