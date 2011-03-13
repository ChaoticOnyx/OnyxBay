/obj/item/weapon/syndie
	icon = 'syndieweapons.dmi'

/*C-4 explosive charge and etc, replaces the old syndie transfer valve bomb.*/


/*The explosive charge itself.  Flashes for five seconds before exploding.*/

/obj/item/weapon/syndie/c4explosive
	icon_state = "c-4small_0"
	item_state = "c-4small"
	name = "mysterious package"
	desc = "A mysterious package."
	w_class = 3

	var/power = 2.0
	var/size = "small"

/obj/item/weapon/syndie/c4explosive/heavy
	icon_state = "c-4large_0"
	item_state = "c-4large"
	desc = "A mysterious package, it's quite heavy."

	power = 3.5
	size = "large"

/obj/item/weapon/syndie/c4explosive/New()
	var/obj/item/weapon/syndie/c4detonator/detonator = new(src.loc)
	detonator.bomb = src

/obj/item/weapon/syndie/c4explosive/proc/detonate()
	icon_state = "c-4[size]_1"
	spawn(50*tick_multiplier)
	explosion(src.loc, power, power*1.5, power*2, power*3, power*3)


/*Detonator, disguised as a lighter*/
/*Click it when closed to open, when open to bring up a prompt asking you if you want to close it or press the button.*/

/obj/item/weapon/syndie/c4detonator
	icon_state = "c-4detonator_0"
	item_state = "c-4detonator"
	name = "lighter"  /*Sneaky, thanks Dreyfus.*/
	desc = "A disposable lighter, it's quite heavy."
	w_class = 1

	var/obj/item/weapon/syndie/c4explosive/bomb

/obj/item/weapon/syndie/c4detonator/attack_self(mob/user as mob)
	switch(src.icon_state)
		if("c-4detonator_0")
			src.icon_state = "c-4detonator_1"
			user << "You flick open the lighter."

		if("c-4detonator_1")
			switch(alert(user, "What would you like to do?", "Lighter", "Press the button.", "Close the lighter."))
				if("Press the button.")
					user << "\red You press the button."
					flick("c-4detonator_click", src)
					if(src.bomb)
						src.bomb.detonate()

				if("Close the lighter.")
					src.icon_state = "c-4detonator_0"
					user << "You close the lighter."