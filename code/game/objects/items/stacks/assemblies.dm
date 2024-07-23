/obj/item/stack/gassembly
	name = "girder assemblies"
	singular_name = "girder assembly"
	plural_name = "assemblies"
	desc = "A wall girder's embryo."
	icon = 'icons/obj/structures.dmi'
	icon_state = "gassembly"
	item_state = "gassembly"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	w_class = ITEM_SIZE_LARGE
	force = 8.5
	throwforce = 10.0
	throw_speed = 2
	throw_range = 7
	mod_weight = 1.2
	mod_reach = 0.85
	mod_handy = 0.7
	matter = list(DEFAULT_WALL_MATERIAL = 3000)
	max_amount = 10
	center_of_mass = null
	attack_verb = list("hit", "bludgeoned", "whacked")

/obj/item/stack/gassembly/ten
	amount = 10

/obj/item/stack/gassembly/attackby(obj/item/W as obj, mob/user as mob)
	if(isWelder(W))
		var/obj/item/weldingtool/WT = W

		if(!WT.use_tool(src, user, amount = 1))
			return

		var/obj/item/stack/material/steel/new_item
		if(istype(src.loc,/turf))
			new_item = new(src.loc)
		else
			new_item = new(usr.loc)
		new_item.add_fingerprint(user)
		new_item.add_to_stacks(usr)
		for (var/mob/M in viewers(src))
			M.show_message(SPAN_NOTICE("[src] is shaped into metal by [user.name] with the weldingtool."), 3, SPAN_NOTICE("You hear welding."), 2)
		var/obj/item/stack/gassembly/R = src
		src = null
		var/replace = (user.get_inactive_hand()==R)
		R.use(1)
		if (!R && replace)
			user.pick_or_drop(new_item)


	if(isWrench(W) && !in_use)

		if(istype(loc, /turf) && !isfloor(loc))
			to_chat(user, SPAN_WARNING("\The [name] must be constructed on the floor!"))
			return

		user.visible_message(SPAN_NOTICE("\The [user] begins assembling \a [singular_name]."), \
				SPAN_NOTICE("You begin assembling \the [singular_name]."))
		in_use = 1

		if (!do_after(usr, 25, src, luck_check_type = LUCK_CHECK_ENG))
			in_use = 0
			return

		var/obj/structure/girder/new_girder
		if(istype(src.loc,/turf))
			new_girder = new(src.loc)
		else
			new_girder = new(usr.loc)

		user.visible_message(SPAN_NOTICE("\The [user] assembles \a [singular_name]."), \
				SPAN_NOTICE("You assemble \the [singular_name]."))
		in_use = 0
		new_girder.add_fingerprint(user)
		src.use(1)
		return

	..()


/obj/item/stack/gassembly/attack_self(mob/user as mob)
	src.add_fingerprint(user)

	if (istype(user.loc,/turf) && !isfloor(user.loc))
		to_chat(user, SPAN_WARNING("\The [name] must be constructed on the floor!"))
		return

	if(!in_use)
		user.visible_message(SPAN_NOTICE("\The [user] begins assembling \a [singular_name]."), \
				SPAN_NOTICE("You begin assembling \the [singular_name]."))
		in_use = 1

		if (!do_after(usr, 40, src, luck_check_type = LUCK_CHECK_ENG))
			in_use = 0
			return

		var/obj/structure/girder/new_girder = new(usr.loc)

		user.visible_message(SPAN_NOTICE("\The [user] assembles \a [new_girder]."), \
				SPAN_NOTICE("You assemble \a [new_girder]."))
		in_use = 0
		new_girder.add_fingerprint(user)
		use(1)
	return
