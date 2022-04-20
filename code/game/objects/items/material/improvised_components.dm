/obj/item/material/butterflyconstruction
	name = "unfinished concealed knife"
	desc = "An unfinished concealed knife, it looks like the screws need to be tightened."
	icon = 'icons/obj/buildingobject.dmi'
	icon_state = "butterflystep1"
	force_divisor = 0.1
	thrown_force_divisor = 0.1
	hitsound = SFX_FIGHTING_SWING
	material_amount = 2

/obj/item/material/butterflyconstruction/attackby(obj/item/W, mob/user)
	if(isScrewdriver(W))
		to_chat(user, "You finish the concealed blade weapon.")
		user.put_in_hands(new /obj/item/material/butterfly(user.loc, material.name))
		qdel(src)
		return

/obj/item/material/butterflyblade
	name = "knife blade"
	desc = "A knife blade. Unusable as a weapon without a grip."
	icon = 'icons/obj/buildingobject.dmi'
	icon_state = "butterfly2"
	force_divisor = 0.1
	thrown_force_divisor = 0.1
	material_amount = 1

/obj/item/material/butterflyhandle
	name = "concealed knife grip"
	desc = "A plasteel grip with screw fittings for a blade."
	icon = 'icons/obj/buildingobject.dmi'
	icon_state = "butterfly1"
	force_divisor = 0.1
	thrown_force_divisor = 0.1
	hitsound = SFX_FIGHTING_SWING
	material_amount = 1

/obj/item/material/butterflyhandle/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/material/butterflyblade))
		var/obj/item/material/butterflyblade/B = W
		to_chat(user, "You attach the two concealed blade parts.")
		var/finished = new /obj/item/material/butterflyconstruction(user.loc, B.material.name)
		qdel(W)
		qdel(src)
		user.put_in_hands(finished)
		return

/obj/item/material/wirerod
	name = "wired rod"
	desc = "A rod with some wire wrapped around the top. It'd be easy to attach something to the top bit."
	icon_state = "wiredrod"
	item_state = "rods"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 8.5
	throwforce = 10
	force_const = 8.5
	thrown_force_const = 10.0
	w_class = ITEM_SIZE_NORMAL
	mod_weight = 1.0
	mod_reach = 1.25
	mod_handy = 1.0
	attack_verb = list("hit", "bludgeoned", "whacked", "bonked")
	hitsound = SFX_FIGHTING_SWING
	force_divisor = 0
	thrown_force_divisor = 0
	applies_material_colour = 0
	material_amount = 2

/obj/item/material/wirerod/attackby(obj/item/I, mob/user)
	..()
	var/obj/item/finished
	if(istype(I, /obj/item/material/shard) || istype(I, /obj/item/material/knife/shiv))
		var/obj/item/material/tmp_shard = I
		finished = new /obj/item/material/twohanded/spear(get_turf(user), tmp_shard.material.name)
		to_chat(user, "<span class='notice'>You fasten \the [I] to the top of the rod with the cable.</span>")
	else if(isWirecutter(I))
		finished = new /obj/item/melee/baton/cattleprod(get_turf(user))
		to_chat(user, "<span class='notice'>You fasten the wirecutters to the top of the rod with the cable, prongs outward.</span>")
	if(finished)
		user.drop_from_inventory(src)
		user.drop_from_inventory(I)
		qdel(I)
		qdel(src)
		user.put_in_hands(finished)
		return
	update_icon(user)
