/obj/item/stack/gassembly
	name = "girder assemblies"
	singular_name = "girder assembly"
	desc = "A wall girder's embryo."
	icon = 'icons/obj/structures.dmi'
	icon_state = "gassembly"
	item_state = "gassembly"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	w_class = ITEM_SIZE_LARGE
	force = 8.5
	throwforce = 10.0
	throw_speed = 5
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
		var/obj/item/weapon/weldingtool/WT = W

		if(WT.remove_fuel(0,user))
			var/obj/item/stack/material/steel/new_item
			if(istype(src.loc,/turf))
				new_item = new(src.loc)
			else
				new_item = new(usr.loc)
			new_item.add_fingerprint(user)
			new_item.add_to_stacks(usr)
			for (var/mob/M in viewers(src))
				M.show_message("<span class='notice'>[src] is shaped into metal by [user.name] with the weldingtool.</span>", 3, "<span class='notice'>You hear welding.</span>", 2)
			var/obj/item/stack/gassembly/R = src
			src = null
			var/replace = (user.get_inactive_hand()==R)
			R.use(1)
			if (!R && replace)
				user.put_in_hands(new_item)
		return

	if(isWrench(W) && !in_use)
		user.visible_message("<span class='notice'>\The [user] begins assembling \a [singular_name].</span>", \
				"<span class='notice'>You begin assembling \the [singular_name].</span>")
		in_use = 1

		if (!do_after(usr, 25))
			in_use = 0
			return

		var/obj/structure/girder/new_girder
		if(istype(src.loc,/turf))
			new_girder = new(src.loc)
		else
			new_girder = new(usr.loc)

		user.visible_message("<span class='notice'>\The [user] assembles \a [singular_name].</span>", \
				"<span class='notice'>You assemble \the [singular_name].</span>")
		in_use = 0
		new_girder.add_fingerprint(user)
		src.use(1)
		return

	..()


/obj/item/stack/gassembly/attack_self(mob/user as mob)
	src.add_fingerprint(user)

	if(!istype(user.loc,/turf)) return 0

	if(!in_use)
		user.visible_message("<span class='notice'>\The [user] begins assembling \a [singular_name].</span>", \
				"<span class='notice'>You begin assembling \the [singular_name].</span>")
		in_use = 1

		if (!do_after(usr, 40))
			in_use = 0
			return

		var/obj/structure/girder/new_girder = new(usr.loc)

		user.visible_message("<span class='notice'>\The [user] assembles \a [new_girder].</span>", \
				"<span class='notice'>You assemble \a [new_girder].</span>")
		in_use = 0
		new_girder.add_fingerprint(user)
		use(1)
	return
