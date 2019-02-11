/*
CONTAINS:
RSF

*/

/obj/item/weapon/rsf
	name = "\improper Rapid-Service-Fabricator"
	desc = "A device used to rapidly deploy service items."
	icon = 'icons/obj/items.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0.0
	var/stored_matter = 30
	var/mode = 1
	w_class = ITEM_SIZE_NORMAL

/obj/item/weapon/rsf/examine(mob/user)
	if(..(user, 0))
		to_chat(user, "It currently holds [stored_matter]/30 fabrication-units.")

/obj/item/weapon/rsf/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/rcd_ammo))

		if ((stored_matter + 10) > 30)
			to_chat(user, "The RSF can't hold any more matter.")
			return

		qdel(W)

		stored_matter += 10
		playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
		to_chat(user, "The RSF now holds [stored_matter]/30 fabrication-units.")
		return

/obj/item/weapon/rsf/attack_self(mob/user as mob)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)

	switch(mode)
		if(1)
			mode = 2
			to_chat(user, "Changed dispensing mode to 'Drinking Glass'")

		if(2)
			mode = 3
			to_chat(user, "Changed dispensing mode to 'Paper'")

		if(3)

			mode = 4
			to_chat(user, "Changed dispensing mode to 'Pen'")

		if(4)
			mode = 5
			to_chat(user, "Changed dispensing mode to 'Dice Pack'")

		if(5)

			mode = 6
			to_chat(user, "Changed dispensing mode to 'Shot glass'")

		if(6)
			mode = 7
			to_chat(user, "Changed dispensing mode to 'Rocks glass'")

		if(7)
			mode = 8
			to_chat(user, "Changed dispensing mode to 'Beer Mug'")

		if(8)
			mode = 1
			to_chat(user, "Changed dispensing mode to 'Cigarette'")


/obj/item/weapon/rsf/afterattack(atom/A, mob/user as mob, proximity)

	if(!proximity) return

	if(istype(user,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = user
		if(R.stat || !R.cell || R.cell.charge <= 0)
			return
	else
		if(stored_matter <= 0)
			return

	if(!istype(A, /obj/structure/table) && !istype(A, /turf/simulated/floor))
		return

	playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
	var/used_energy = 0
	var/obj/product

	switch(mode)
		if(1)
			product = new /obj/item/clothing/mask/smokable/cigarette()
			used_energy = 10
		if(2)
			product = new /obj/item/weapon/reagent_containers/food/drinks/glass2()
			used_energy = 50
		if(3)
			product = new /obj/item/weapon/paper()
			used_energy = 10
		if(4)
			product = new /obj/item/weapon/pen()
			used_energy = 50
		if(5)
			product = new /obj/item/weapon/storage/pill_bottle/dice()
			used_energy = 200
		if(6)
			product = new /obj/item/weapon/reagent_containers/food/drinks/glass2/shot()
			used_energy = 20
		if(7)
			product = new /obj/item/weapon/reagent_containers/food/drinks/glass2/rocks()
			used_energy = 50
		if(8)
			product = new /obj/item/weapon/reagent_containers/food/drinks/glass2/mug()
			used_energy = 50

	to_chat(user, "Dispensing [product ? product : "product"]...")
	product.loc = get_turf(A)

	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(R.cell)
			R.cell.use(used_energy)
	else
		stored_matter--
		to_chat(user, "The RSF now holds [stored_matter]/30 fabrication-units.")
