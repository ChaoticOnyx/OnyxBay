/obj/item/melee/baton/whip_of_torment
	name = "Whip of torment"
	desc = ""//THINK THINK
	icon = 'icons/obj/weapons.dmi'
	icon_state = "baton"
	item_state = "classic_baton"
	slot_flags = SLOT_BELT
	force = 20
	mod_weight = 1.25
	mod_reach = 1.25
	mod_handy = 1.5
	hitcost = 0 //YEP
	stunforce = 8
	agonyforce = 80
	status = 1 //It is always ON

/obj/item/melee/baton/whip_of_torment/New()
	bcell = new /obj/item/cell/device/high(src)

/obj/item/melee/baton/whip_of_torment/examine_cell()
	return

/obj/item/melee/baton/whip_of_torment/change_status()
	return

/obj/item/melee/baton/whip_of_torment/set_status()
	return

/obj/item/melee/baton/whip_of_torment/attack(mob/M, mob/user)
	if(user != master && ((MUTATION_CLUMSY in user.mutations) && prob(50)))
		to_chat(user, "<span class='danger'>You accidentally hit yourself with the [src]!</span>")
		user.Weaken(30)
		return

	return ..()


/obj/item/melee/baton/whip_of_torment/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/cell/device))
		return

	else if(isScrewdriver(W))
		return

	else
		..()
