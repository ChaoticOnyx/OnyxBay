//this is slightly like a ripped apart version of the tank transfer valve made to work with beakers instead of tanks

/obj/item/device/chemgrenade
	name = "grenade casing"
	icon_state = "chemg2"
	icon = 'chemical.dmi'
	item_state = "flashbang"
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | ONBELT | NOSPLASH
	var/obj/item/weapon/reagent_containers/glass/beaker_one
	var/obj/item/weapon/reagent_containers/glass/beaker_two
	var/obj/item/device/attached_device
	var/active = 0
	var/toggle = 1

	attackby(obj/item/item, mob/user)
		if(active)
			return ..()
		if(istype(item, /obj/item/weapon/reagent_containers/glass))
			if(beaker_one && beaker_two)
				user << "\red There are already two beakers inside, remove one first!"
				return

			if(!beaker_one)
				beaker_one = item
				user.drop_item()
				item.loc = src
				user << "\blue You insert the beaker into the casing."
			else if(!beaker_two)
				beaker_two = item
				user.drop_item()
				item.loc = src
				user << "\blue You insert the beaker into the casing."

		else if(istype(item, /obj/item/device/radio/signaler) || istype(item, /obj/item/device/timer) || istype(item, /obj/item/device/infra) || istype(item, /obj/item/device/prox_sensor))
			if(attached_device)
				user << "\red There is already an device attached to the controls, remove it first!"
				return

			attached_device = item
			user.drop_item()
			item.loc = src
			user << "\blue You attach the [item] to the grenade controls!"
			item.master = src

		else if(istype(item, /obj/item/weapon/screwdriver) && !active)
			if(beaker_one && beaker_two && attached_device)
				user << "\blue You lock the assembly."
				playsound(src.loc, 'Screwdriver.ogg', 25, -3)
				name = "grenade"
				icon_state = "chemg3"
				active = 1
			else
				user << "\red You need to add all components before locking the assembly."
		return


	attack_self(mob/user as mob)
		if(active)
			attached_device.attack_self(usr)
			return
		user.machine = src
		var/dat = {"<B> Grenade properties: </B>
		<BR> <B> Beaker one:</B> [beaker_one] [beaker_one ? "<A href='?src=\ref[src];beaker_one=1'>Remove</A>" : ""]
		<BR> <B> Beaker two:</B> [beaker_two] [beaker_two ? "<A href='?src=\ref[src];beakertwo=1'>Remove</A>" : ""]
		<BR> <B> Control attachment:</B> [attached_device ? "<A href='?src=\ref[src];device=1'>[attached_device]</A>" : "None"] [attached_device ? "<A href='?src=\ref[src];rem_device=1'>Remove</A>" : ""]"}

		user << browse(dat, "window=trans_valve;size=600x300")
		onclose(user, "trans_valve")
		return


	Topic(href, href_list)
		..()
		if (usr.stat || usr.restrained())
			return
		if (src.loc == usr)
			if(href_list["beakerone"])
				beaker_one.loc = get_turf(src)
				beaker_one = null
			if(href_list["beakertwo"])
				beaker_two.loc = get_turf(src)
				beaker_two = null
			if(href_list["rem_device"])
				attached_device.loc = get_turf(src)
				attached_device = null
			if(href_list["device"])
				attached_device.attack_self(usr)
			src.attack_self(usr)
			src.add_fingerprint(usr)
			return

	receive_signal(signal)
		if(!active)
			return	//cant go off before it gets primed
		explode()

	process()

	proc
		explode()
			playsound(src.loc, 'bamf.ogg', 50, 1)
			beaker_one.reagents.update_total()
			beaker_one.reagents.trans_to(beaker_two, beaker_one.reagents.total_volume)
			if(beaker_one.reagents.total_volume) //The possible reactions didnt use up all reagents.
				var/datum/effects/system/steam_spread/steam = new /datum/effects/system/steam_spread()
				steam.set_up(10, 0, get_turf(src))
				steam.attach(src)
				steam.start()
				for(var/atom/A in view(3, src.loc))
					if( A == src ) continue
					beaker_one.reagents.reaction(A, 1, 10)
			invisibility = 100 //Why am i doing this?
			spawn(50)		   //To make sure all reagents can work
				del(src)	   //correctly before deleting the grenade.
		c_state()
			return
