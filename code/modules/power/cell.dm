// the power cell
// charge from 0 to 100%
// fits in APC to provide backup power or into cyborgs

/obj/item/weapon/cell
	name = "power cell"
	desc = "A rechargeable electrochemical power cell."
	icon = 'power.dmi'
	icon_state = "cell"
	item_state = "cell"
	flags = FPRINT|TABLEPASS
	force = 5.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	w_class = 3.0
	pressure_resistance = 80
	var/charge = 0	// note %age conveted to actual charge in New
	var/maxcharge = 1000
	m_amt = 700
	var/rigged = 0		// true if rigged to explode

/obj/item/weapon/cell/supercharged
	maxcharge = 7500

/obj/item/weapon/cell/New()
	..()

	charge = charge * maxcharge/100.0		// map obj has charge as percentage, convert to real value here

	spawn(5)
		updateicon()


/obj/item/weapon/cell/proc/updateicon()

	if(maxcharge <= 2500)
		icon_state = "cell"
	else
		icon_state = "hpcell"

	overlays = null

	if(charge < 0.01)
		return
	else if(charge/maxcharge >=0.995)
		overlays += image('power.dmi', "cell-o2")
	else
		overlays += image('power.dmi', "cell-o1")

/obj/item/weapon/cell/proc/percent()		// return % charge of cell
	return 100.0*charge/maxcharge

// use power from a cell
/obj/item/weapon/cell/proc/use(var/amount)
	charge = max(0, charge-amount)
	if(rigged && amount > 0)
		explode()

// recharge the cell
/obj/item/weapon/cell/proc/give(var/amount)
	charge = min(maxcharge, charge+amount)
	if(rigged && amount > 0)
		explode()


/obj/item/weapon/cell/examine()
	set src in view(1)
	if(usr && !usr.stat)
		if(maxcharge <= 2500)
			usr << "[desc]\nThe manufacturer's label states this cell has a power rating of [maxcharge], and that you should not swallow it.\nThe charge meter reads [round(src.percent() )]%."
		else
			usr << "This power cell has an exciting chrome finish, as it is an uber-capacity cell type! It has a power rating of [maxcharge].\nThe charge meter reads [round(src.percent() )]%."





/obj/item/weapon/cell/attackby(obj/item/W, mob/user)
/*Removed stungloves as they are dodgy weapons :3. -CN
	var/obj/item/clothing/gloves/G = W

	if(istype(G))
		if(charge < 1000)
			return

		G.elecgen = 1
		G.uses = min(5, round(charge / 1000))
		use(G.uses*1000)
		updateicon()
		user << "\red These gloves are now electrically charged!"
*/
	if(istype(W, /obj/item/weapon/reagent_containers/syringe))
		var/obj/item/weapon/reagent_containers/syringe/S = W

		user << "You inject the solution into the power cell."

		if(S.reagents.has_reagent("plasma", 5))

			rigged = 1

		S.reagents.clear_reagents()


/obj/item/weapon/cell/proc/explode()
	var/turf/T = get_turf(src.loc)

	explosion(T, 0, 1, 2, 2, 1)

	spawn(1)
		del(src)