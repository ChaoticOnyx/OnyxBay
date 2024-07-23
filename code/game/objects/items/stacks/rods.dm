/obj/item/stack/rods
	name = "metal rod"
	desc = "Some rods. Can be used for building, or something."
	singular_name = "metal rod"
	icon_state = "rods"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	w_class = ITEM_SIZE_LARGE
	force = 8.5
	throwforce = 10.0
	throw_range = 20
	mod_weight = 0.8
	mod_reach = 1.0
	mod_handy = 0.8
	matter = list(MATERIAL_STEEL = 1000)
	max_amount = 100
	center_of_mass = null
	attack_verb = list("hit", "bludgeoned", "whacked")
	lock_picking_level = 3

	drop_sound = SFX_DROP_METALWEAPON
	pickup_sound = SFX_PICKUP_METALWEAPON

/obj/item/stack/rods/ten
	amount = 10

/obj/item/stack/rods/fifty
	amount = 50

/obj/item/stack/rods/cyborg
	name = "metal rod synthesizer"
	desc = "A device that makes metal rods."
	gender = NEUTER
	matter = null
	uses_charge = 1
	charge_costs = list(500)
	stacktype = /obj/item/stack/rods

/obj/item/stack/rods/New()
	..()
	update_icon()

/obj/item/stack/rods/attackby(obj/item/W as obj, mob/user as mob)
	if(isWelder(W))
		var/obj/item/weldingtool/WT = W

		if(get_amount() < 2)
			to_chat(user, SPAN_NOTICE("You need at least two rods to do this."))
			return


		if(!WT.use_tool(src, user, amount = 1))
			return

		var/obj/item/stack/material/steel/new_item = new(usr.loc)
		new_item.add_to_stacks(usr)
		for(var/mob/M in viewers(src))
			M.show_message(SPAN_NOTICE("[src] is shaped into metal by [user.name] with the weldingtool."), 3, SPAN_NOTICE("You hear welding."), 2)

		var/obj/item/stack/rods/R = src
		src = null
		var/replace = (user.get_inactive_hand() == R)
		R.use(2)
		if(!R && replace)
			user.pick_or_drop(new_item)
		return

	if (istype(W, /obj/item/tape_roll))
		var/obj/item/stack/medical/splint/ghetto/new_splint = new(user.loc)
		new_splint.dropInto(loc)
		new_splint.add_fingerprint(user)

		user.visible_message("<span class='notice'>\The [user] constructs \a [new_splint] out of a [singular_name].</span>", \
				"<span class='notice'>You use make \a [new_splint] out of a [singular_name].</span>")
		src.use(1)
		return

	..()


/obj/item/stack/rods/attack_self(mob/user)
	add_fingerprint(user)

	if(!isturf(user.loc))
		return

	if(GLOB.using_map.legacy_mode)
		place_grille(user)
	else
		place_window_frame(user)

/obj/item/stack/rods/proc/place_window_frame(mob/user)
	if(locate(/obj/structure/grille, user.loc))
		for(var/obj/structure/grille/G in user.loc)
			if(G.destroyed)
				G.health = 10
				G.set_density(1)
				G.destroyed = 0
				G.icon_state = "grille"
				use(1)
				to_chat(user, SPAN("notice", "You reconstruct an old grille."))
			return
	else if(!in_use)
		if(get_amount() < 2)
			to_chat(user, SPAN("warning", "You need at least two rods to do this."))
			return
		if(locate(/obj/structure/window_frame) in user.loc)
			to_chat(user, SPAN("warning", "There is another frame in this location."))
			return
		to_chat(usr, SPAN("notice", "Assembling a window frame..."))
		in_use = TRUE
		if(!do_after(usr, 1 SECOND, luck_check_type = LUCK_CHECK_ENG))
			in_use = FALSE
			return
		in_use = FALSE
		if(locate(/obj/structure/window_frame) in user.loc)
			to_chat(user, SPAN("warning", "There is another frame in this location."))
			return
		if(!use(2))
			return
		var/obj/structure/window_frame/WF = new /obj/structure/window_frame(get_turf(user))
		WF.add_fingerprint(usr)
		WF.anchored = FALSE
		to_chat(user, SPAN("notice", "You assemble a window frame."))
	return

/obj/item/stack/rods/proc/place_grille(mob/user)
	if(locate(/obj/structure/grille, user.loc))
		for(var/obj/structure/grille/G in user.loc)
			if(G.destroyed)
				G.health = 10
				G.set_density(1)
				G.destroyed = 0
				G.icon_state = "old-grille"
				use(1)
			return

	else if(!in_use)
		if(get_amount() < 2)
			to_chat(user, SPAN("notice", "You need at least two rods to do this."))
			return
		to_chat(usr, SPAN("notice", "Assembling grille..."))
		in_use = 1
		if(!do_after(usr, 1 SECOND, luck_check_type = LUCK_CHECK_ENG))
			in_use = 0
			return
		var/obj/structure/grille/F = new /obj/structure/grille(user.loc)
		to_chat(usr, SPAN("notice", "You assemble a grille"))
		in_use = 0
		F.add_fingerprint(user)
		use(2)
	return

/obj/item/stack/rods/on_update_icon()
	icon_state = "rods[(amount < 5) ? amount : ""]"

/obj/item/stack/rods/use()
	. = ..()
	update_icon()

/obj/item/stack/rods/add()
	. = ..()
	update_icon()
