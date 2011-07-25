/obj/machinery/power/furnace
	name = "Furnace"
	desc = "An inefficient method of powering the station. Most often used in emergencies."
	icon_state = "furnace"
	anchored = 1
	density = 1
	var/active = 0
	var/fuel = 0
	var/maxfuel = 600
	var/genrate = 5000

	process()
		if(stat & BROKEN) return
		if(src.active)
			if(src.fuel)
				add_avail(src.genrate)
				fuel--
			if(!src.fuel)
				for(var/mob/O in viewers(src, null)) O.show_message(text("\red [] runs out of fuel and shuts down!", src), 1)
				src.overlays = null
				src.active = 0
		var/fuelperc = (src.fuel / src.maxfuel) * 100
		src.overlays = null
		if (src.active) src.overlays += image('power.dmi', "furn-burn")
		if (fuelperc >= 20) src.overlays += image('power.dmi', "furn-c1")
		if (fuelperc >= 40) src.overlays += image('power.dmi', "furn-c2")
		if (fuelperc >= 60) src.overlays += image('power.dmi', "furn-c3")
		if (fuelperc >= 80) src.overlays += image('power.dmi', "furn-c4")

	attack_hand(var/mob/user as mob)
		if (!src.fuel) user << "\red There is no fuel in the furnace!"
		else
			src.active = !src.active
			user << "You switch [src.active ? "on" : "off"] the furnace."

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/grab))
			if (!src.active)
				user << "\red It'd probably be easier to dispose of them while the furnace is active..."
				return
			else
				user.visible_message("\red [user] starts to shove [W:affecting] into the furnace!")
				src.add_fingerprint(user)
				sleep(30)
				if(W:affecting && src.active)
					user.visible_message("\red [user] stuffs [W:affecting] into the furnace!")
					var/mob/M = W:affecting
					M.death(1)
					if(M.client)
						var/mob/dead/observer/newmob
						newmob = new/mob/dead/observer(M)
						M:client:mob = newmob
						newmob:client:eye = newmob
						del(M)
					else del(M)
					del(W)
					src.fuel += 200
					if(src.fuel > src.maxfuel)
						src.fuel = src.maxfuel
						user << "\blue The furnace is now full!"
					return
		else if (istype(W, /obj/item/weapon/ore/char)) src.fuel += 30
		else if (istype(W, /obj/item/weapon/ore/plasmastone)) src.fuel += 400
		else if (istype(W, /obj/item/weapon/paper/)) src.fuel += 3
		else if (istype(W, /obj/item/weapon/spacecash/)) src.fuel += 3
		else if (istype(W, /obj/item/clothing/gloves/)) src.fuel += 5
		else if (istype(W, /obj/item/clothing/head/)) src.fuel += 10
		else if (istype(W, /obj/item/clothing/mask/)) src.fuel += 5
		else if (istype(W, /obj/item/clothing/shoes/)) src.fuel += 5
		else if (istype(W, /obj/item/clothing/head/)) src.fuel += 10
		else if (istype(W, /obj/item/clothing/suit/)) src.fuel += 20
		else if (istype(W, /obj/item/clothing/under/)) src.fuel += 15
		else
			..()
			return
		user << "\blue You load [W] into [src]!"
		user.u_equip(W)
		W.dropped()
		if ((user.client && user.s_active != src))
			user.client.screen -= W
		del W
		if(src.fuel > src.maxfuel)
			src.fuel = src.maxfuel
			user << "\blue The furnace is now full!"

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (istype(O, /obj/crate/))
			if (src.fuel >= src.maxfuel)
				user << "\red The furnace is already full!"
				return
			for(var/mob/V in viewers(user, null)) V.show_message(text("\blue [] uses the []'s automatic ore loader on []!", user, src, O), 1)
			var/amtload = 0
			for (var/obj/item/weapon/ore/M in O.contents)
				if (istype(M,/obj/item/weapon/ore/char))
					src.fuel += 30
					del M
				else if (istype(M,/obj/item/weapon/ore/plasmastone))
					src.fuel += 400
					del M
				if (src.fuel == src.maxfuel)
					user << "\blue The furnace is now full!"
					break
				amtload++
			if (amtload) user << "\blue [amtload] pieces of ore loaded from [O]!"
			else user << "\red No ore loaded!"
		else if (istype(O, /obj/item/weapon/ore/))
			if (src.fuel >= src.maxfuel)
				user << "\red The furnace is already full!"
				return
			for(var/mob/V in viewers(user, null)) V.show_message(text("\blue [] begins quickly stuffing ore into []!", user, src), 1)
			var/staystill = user.loc
			for(var/obj/item/weapon/ore/M in view(1,user))
				if (istype(M,/obj/item/weapon/ore/char))
					src.fuel += 30
					del M
				else if (istype(M,/obj/item/weapon/ore/plasmastone))
					src.fuel += 400
					del M
				sleep(3)
				if (user.loc != staystill) break
				if (src.fuel == src.maxfuel)
					user << "\blue The furnace is now full!"
					break
			user << "\blue You finish stuffing ore into [src]!"
		else ..()
		src.updateUsrDialog()