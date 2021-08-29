/obj/item/weapon
	name = "weapon"
	icon = 'icons/obj/weapons.dmi'
	hitsound = "swing_hit"
	var/clumsy_unaffected = FALSE

/obj/item/weapon/Bump(mob/M as mob)
	spawn(0)
		..()
	return
