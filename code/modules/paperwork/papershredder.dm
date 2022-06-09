/obj/machinery/papershredder
	name = "paper shredder"
	desc = "For those documents you don't want seen."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "papershredder0"
	density = 1
	anchored = 1
	atom_flags = ATOM_FLAG_CLIMBABLE
	obj_flags = OBJ_FLAG_ANCHORABLE
	var/max_paper = 10
	var/paperamount = 0
	var/list/shred_amounts = list(
		/obj/item/photo = 1,
		/obj/item/shreddedp = 1,
		/obj/item/paper = 1,
		/obj/item/newspaper = 3,
		/obj/item/card/id = 3,
		/obj/item/paper_bundle = 3,
		)

/obj/machinery/papershredder/attackby(obj/item/W, mob/user)

	if(istype(W, /obj/item/storage))
		empty_bin(user, W)
		return
	else
		var/paper_result
		for(var/shred_type in shred_amounts)
			if(istype(W, shred_type))
				paper_result = shred_amounts[shred_type]
		if(paper_result)
			if(paperamount == max_paper)
				to_chat(user, "<span class='warning'>\The [src] is full; please empty it before you continue.</span>")
				return
			paperamount += paper_result
			user.drop_from_inventory(W)
			qdel(W)
			playsound(src.loc, 'sound/items/pshred.ogg', 75, 1)
			if(paperamount > max_paper)
				to_chat(user, "<span class='danger'>\The [src] was too full, and shredded paper goes everywhere!</span>")
				for(var/i=(paperamount-max_paper);i>0;i--)
					var/obj/item/shreddedp/SP = get_shredded_paper()
					SP.loc = get_turf(src)
					SP.throw_at(get_edge_target_turf(src, pick(GLOB.alldirs)), 1, 1)
				paperamount = max_paper
			update_icon()
			return
	..()
	if(W.mod_weight >= 0.75)
		shake_animation(stime = 4)
	return

/obj/machinery/papershredder/verb/empty_contents()
	set name = "Empty bin"
	set category = "Object"
	set src in range(1)

	if(usr.stat || usr.restrained() || usr.weakened || usr.paralysis || usr.lying || usr.stunned)
		return

	if(!paperamount)
		to_chat(usr, "<span class='notice'>\The [src] is empty.</span>")
		return

	empty_bin(usr)

/obj/machinery/papershredder/proc/empty_bin(mob/living/user, obj/item/storage/empty_into)

	// Sanity.
	if(empty_into && !istype(empty_into))
		empty_into = null

	if(empty_into && empty_into.contents.len >= empty_into.storage_slots)
		to_chat(user, "<span class='notice'>\The [empty_into] is full.</span>")
		return

	while(paperamount)
		var/obj/item/shreddedp/SP = get_shredded_paper()
		if(!SP) break
		if(empty_into)
			empty_into.handle_item_insertion(SP)
			if(empty_into.contents.len >= empty_into.storage_slots)
				break
	if(empty_into)
		if(paperamount)
			to_chat(user, "<span class='notice'>You fill \the [empty_into] with as much shredded paper as it will carry.</span>")
		else
			to_chat(user, "<span class='notice'>You empty \the [src] into \the [empty_into].</span>")

	else
		to_chat(user, "<span class='notice'>You empty \the [src].</span>")
	update_icon()

/obj/machinery/papershredder/proc/get_shredded_paper()
	if(!paperamount)
		return
	paperamount--
	return new /obj/item/shreddedp(get_turf(src))

/obj/machinery/papershredder/update_icon()
	icon_state = "papershredder[max(0,min(5,Floor(paperamount/2)))]"

/obj/item/shreddedp/attackby(obj/item/W as obj, mob/user)
	if(istype(W, /obj/item/flame/lighter))
		burnpaper(W, user)
	else
		..()

/obj/item/shreddedp/proc/burnpaper(obj/item/flame/lighter/P, mob/user)
	if(user.restrained())
		return
	if(!P.lit)
		to_chat(user, "<span class='warning'>\The [P] is not lit.</span>")
		return
	user.visible_message("<span class='warning'>\The [user] holds \the [P] up to \the [src]. It looks like \he's trying to burn it!</span>", \
		"<span class='warning'>You hold \the [P] up to \the [src], burning it slowly.</span>")
	if(!do_after(user,20, src))
		to_chat(user, "<span class='warning'>You must hold \the [P] steady to burn \the [src].</span>")
		return
	user.visible_message("<span class='danger'>\The [user] burns right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>", \
		"<span class='danger'>You burn right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>")
	FireBurn()

/obj/item/shreddedp/proc/FireBurn()
	var/mob/living/M = loc
	if(istype(M))
		M.drop_from_inventory(src)
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)

/obj/item/shreddedp
	name = "shredded paper"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "shredp"
	randpixel = 5
	throwforce = 0
	w_class = ITEM_SIZE_TINY
	throw_range = 3
	throw_speed = 2

/obj/item/shreddedp/New()
	..()
	if(prob(65)) color = pick("#bababa","#7f7f7f")
