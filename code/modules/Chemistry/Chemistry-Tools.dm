// Bottles transfer 50 units
// Beakers transfer 30 units
// Syringes transfer 15 units
// Droppers transfer 5 units

//BUG!!!: reactions on splashing etc cause errors because stuff gets deleted before it executes.
//		  Bandaid fix using spawn - very ugly, need to fix this.

///////////////////////////////Grenades
//this is slightly like a ripped apart version of the tank transfer valve made to work with beakers instead of tanks

/obj/item/device/chem_grenade
	name = "metal casing"
	icon_state = "chemg1"
	icon = 'chemical.dmi'
	item_state = "flashbang"
	w_class = 2.0
	force = 2.0
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | ONBELT | NOSPLASH
	var/obj/item/weapon/reagent_containers/glass/beaker_one
	var/obj/item/weapon/reagent_containers/glass/beaker_two
	var/obj/item/device/attached_device
	var/active = 0
	var/exploding = 0

/obj/item/device/chem_grenade/attackby(obj/item/item, mob/user)
	switch(active)
		if(0)
			if(istype(item, /obj/item/device/igniter))
				active = 1
				icon_state = "chemg2"
				name = "grenade casing"
				del(item)
		if(1)
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

			else if(istype(item, /obj/item/weapon/screwdriver))
				if(beaker_one && beaker_two && attached_device)
					user << "\blue You lock the assembly."
					playsound(src.loc, 'Screwdriver.ogg', 25, -3)
					name = "grenade"
					icon_state = "chemg3"
					active = 2
				else
					user << "\red You need to add all components before locking the assembly."

/obj/item/device/chem_grenade/attack_self(mob/user as mob)
	if(active == 2)
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

/obj/item/device/chem_grenade/Topic(href, href_list)
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

/obj/item/device/chem_grenade/receive_signal(signal)
	if(!(active == 2))
		return	//cant go off before it gets primed
	explode()

/obj/item/device/chem_grenade/process()

/obj/item/device/chem_grenade/HasProximity(atom/movable/AM as mob|obj)
	if(istype(attached_device, /obj/item/device/prox_sensor))
		var/obj/item/device/prox_sensor/D = attached_device
		if (istype(AM, /obj/beam))
			return
		if (AM.move_speed < 12)
			D.sense()

/obj/item/device/chem_grenade/proc/explode()
	if(exploding) return
	exploding = 1
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

/obj/item/device/chem_grenade/proc/c_state(n)
	icon_state = "chemg[n+3]"
	return

/obj/item/device/chem_grenade/metalfoam
	name = "metal foam grenade"
	desc = "Used for emergency sealing of air breaches."
	icon_state = "chemg3"
	active = 2

	New()
		..()
		beaker_one = new(src)
		beaker_two = new(src)
		attached_device = new /obj/item/device/timer(src)
		attached_device.master = src

		beaker_one.reagents.add_reagent("aluminium", 30)
		beaker_two.reagents.add_reagent("foaming_agent", 10)
		beaker_two.reagents.add_reagent("pacid", 10)

/obj/item/device/chem_grenade/cleaner
	name = "cleaner grenade"
	desc = "BLAM!-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	icon_state = "chemg3"
	active = 2

	New()
		..()
		beaker_one = new(src)
		beaker_two = new(src)
		attached_device = new /obj/item/device/timer(src)
		attached_device.master = src

		beaker_one.reagents.add_reagent("fluorosurfactant", 30)
		beaker_two.reagents.add_reagent("water", 10)
		beaker_two.reagents.add_reagent("cleaner", 10)

/obj/item/device/chem_grenade/flashbang
	name = "flashbang grenade"
	icon_state = "chemg3"
	active = 2

	New()
		..()
		beaker_one = new(src)
		beaker_two = new(src)
		attached_device = new /obj/item/device/timer(src)
		attached_device.master = src

		beaker_one.reagents.add_reagent("potassium", 10)
		beaker_one.reagents.add_reagent("sulfur", 10)
		beaker_two.reagents.add_reagent("aluminium", 10)

///////////////////////////////Grenades

/obj/syringe_gun_dummy
	name = ""
	desc = ""
	icon = 'chemical.dmi'
	icon_state = "null"
	anchored = 1
	density = 0

	New()
		var/datum/reagents/R = new/datum/reagents(15)
		reagents = R
		R.my_atom = src

/obj/item/weapon/gun/syringe
	name = "syringe gun"
	icon = 'gun.dmi'
	icon_state = "syringegun"
	item_state = "syringegun"
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 4.0
	var/list/syringes = new/list()
	var/max_syringes = 1
	m_amt = 2000

	examine()
		set src in view(2)
		..()
		usr << "\icon [src] Syringe gun:"
		usr << "\blue [syringes.len] / [max_syringes] Syringes."

	attackby(obj/item/I as obj, mob/user as mob)
		if(istype(I, /obj/item/weapon/reagent_containers/syringe))
			if(syringes.len < max_syringes)
				user.drop_item()
				I.loc = src
				syringes += I
				user << "\blue You put the syringe in the syringe gun."
				user << "\blue [syringes.len] / [max_syringes] Syringes."
			else
				usr << "\red The syringe gun cannot hold more syringes."

	attack()
		return 1

	afterattack(obj/target, mob/user , flag)
		if(!isturf(target.loc)) return

		if(syringes.len)
			if(target != user)
				spawn(0) fire_syringe(target,user)
			else
				var/obj/item/weapon/reagent_containers/syringe/S = syringes[1]
				S.reagents.trans_to(user, S.reagents.total_volume)
				syringes -= S
				del(S)
				for(var/mob/O in viewers(world.view, user))
					O.show_message(text("\red [] shot \himself with a syringe gun!", user), 1)
		else
			usr << "\red The syringe gun is empty."

	proc
		fire_syringe(atom/target, mob/user)
			var/turf/trg = get_turf(target)
			var/obj/syringe_gun_dummy/D = new/obj/syringe_gun_dummy(get_turf(src))
			var/obj/item/weapon/reagent_containers/syringe/S = syringes[1]
			S.reagents.trans_to(D, S.reagents.total_volume)
			syringes -= S
			del(S)
			D.icon_state = "syringeproj"
			D.name = "syringe"
			playsound(user.loc, 'syringeproj.ogg', 50, 1)
			shoot:
				for(var/i=0, i<6, i++)
					if(D.loc == trg) break
					step_towards_3d(D,trg)

					for(var/mob/living/carbon/M in D.loc)
						if(!istype(M,/mob/living/carbon)) continue
						if(M == user) continue
						D.reagents.trans_to(M, 15)
						M.bruteloss += 5

						for(var/mob/O in viewers(world.view, D))
							O.show_message(text("\red [] was hit by the syringe!", M), 1)

						del(D)
						break shoot

					for(var/atom/A in D.loc)
						if(A == user) continue
						if(A.density)
							del(D)
							break shoot

					sleep(1)

			spawn(10)
				del(D)

			return



/obj/reagent_dispensers
	name = "Dispenser"
	desc = "..."
	icon = 'objects.dmi'
	icon_state = "watertank"
	density = 1
	anchored = 0
	flags = FPRINT
	pressure_resistance = 2*ONE_ATMOSPHERE

	var/amount_per_transfer_from_this = 10

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		return

	New()
		if(istype(src, /obj/reagent_dispensers/hvwatertank/))
			var/datum/reagents/R = new/datum/reagents(3000)
			reagents = R
			R.my_atom = src
		else
			var/datum/reagents/R = new/datum/reagents(1000)
			reagents = R
			R.my_atom = src

	examine()
		set src in view(2)
		..()
		usr << "\blue It contains:"
		if(!reagents) return
		if(reagents.total_volume)
			reagents.update_total()
			usr << "\blue [reagents.total_volume] units of liquid."
		else
			usr << "\blue Nothing."

	ex_act(severity)
		switch(severity)
			if(1.0)
				del(src)
				return
			if(2.0)
				if (prob(50))
					new /obj/effects/water(src.loc)
					del(src)
					return
			if(3.0)
				if (prob(5))
					new /obj/effects/water(src.loc)
					del(src)
					return
			else
		return

	blob_act()
		if(prob(25))
			new /obj/effects/water(src.loc)
			del(src)



/obj/item/weapon/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'chemical.dmi'
	icon_state = null
	w_class = 1
	var/amount_per_transfer_from_this = 5

	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		return
	attack_self(mob/user as mob)
		return
	attack(mob/M as mob, mob/user as mob, def_zone)
		return
	attackby(obj/item/I as obj, mob/user as mob)
		return
	afterattack(obj/target, mob/user , flag)
		return

////////////////////////////////////////////////////////////////////////////////
/// (Mixing)Glass.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/glass/
	name = " "
	desc = " "
	icon = 'chemical.dmi'
	icon_state = "null"
	item_state = "null"
	amount_per_transfer_from_this = 10
	flags = FPRINT | TABLEPASS | OPENCONTAINER

	examine()
		set src in view(2)
		..()
		usr << "\blue It contains:"
		if(!reagents) return
		if(reagents.total_volume)
			reagents.update_total()
			usr << "\blue [reagents.total_volume] units of liquid."
		else
			usr << "\blue Nothing."


	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src

	afterattack(obj/target, mob/user , flag)

		if(ismob(target) && target.reagents && reagents.total_volume)
			user << "\blue You splash the solution onto [target]."
			for(var/mob/O in viewers(world.view, user))
				O.show_message(text("\red [] has been splashed with something by []!", target, user), 1)
			src.reagents.reaction(target, TOUCH)
			message_admins("[target] has been splashed with a container filled with [src.reagents.get_master_reagent_name()] by [user]")
			spawn(5) src.reagents.clear_reagents()
			return
		else if(istype(target, /obj/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

			if(!target.reagents.total_volume && target.reagents)
				user << "\red [target] is empty."
				return

			if(reagents.total_volume >= reagents.maximum_volume)
				user << "\red [src] is full."
				return

			if(istype(src, /obj/item/weapon/reagent_containers/glass/wateringcan))
				var/trans = target.reagents.trans_to(src, 30)
				user << "\blue You fill [src] with [trans] units of the contents of [target]."
			else
				var/trans = target.reagents.trans_to(src, 10)
				user << "\blue You fill [src] with [trans] units of the contents of [target]."

		else if(target.is_open_container() && target.reagents) //Something like a glass. Player probably wants to transfer TO it.
			if(!reagents.total_volume)
				user << "\red [src] is empty."
				return

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				user << "\red [target] is full."
				return

			var/trans = src.reagents.trans_to(target, 10)
			user << "\blue You transfer [trans] units of the solution to [target]."

		else if(target.flags & NOSPLASH)
			return

		else if(reagents.total_volume)
			user << "\blue You splash the solution onto [target]."
			src.reagents.reaction(target, TOUCH)
			spawn(5) src.reagents.clear_reagents()
			return

////////////////////////////////////////////////////////////////////////////////
/// (Mixing)Glass. END
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
/// Droppers.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/dropper
	name = "Dropper"
	desc = "A dropper. Transfers 5 units."
	icon = 'chemical.dmi'
	icon_state = "dropper0"
	amount_per_transfer_from_this = 5
	var/filled = 0

	New()
		var/datum/reagents/R = new/datum/reagents(5)
		reagents = R
		R.my_atom = src

	afterattack(obj/target, mob/user , flag)
		if(!target.reagents) return

		if(filled)

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				user << "\red [target] is full."
				return

			if(!target.is_open_container() && !ismob(target) && !istype(target,/obj/item/weapon/reagent_containers/food)) //You can inject humans and food but you cant remove the shit.
				user << "\red You cannot directly fill this object."
				return

			if(ismob(target))
				for(var/mob/O in viewers(world.view, user))
					O.show_message(text("\red <B>[] drips something onto []!</B>", user, target), 1)
					message_admins("[user] drips something filled with [src.reagents.get_master_reagent_name()] onto [target]")
				src.reagents.reaction(target, TOUCH)

			spawn(5) src.reagents.trans_to(target, 5)
			user << "\blue You transfer 5 units of the solution."
			filled = 0
			icon_state = "dropper[filled]"

		else

			if(!target.is_open_container() && !istype(target,/obj/reagent_dispensers))
				user << "\red You cannot directly remove reagents from [target]."
				return

			if(!target.reagents.total_volume)
				user << "\red [target] is empty."
				return

			target.reagents.trans_to(src, 5)

			user << "\blue You fill the dropper with 5 units of the solution."

			filled = 1
			icon_state = "dropper[filled]"

		return
////////////////////////////////////////////////////////////////////////////////
/// Droppers. END
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
/// Syringes.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/syringe
	name = "Syringe"
	desc = "A syringe."
	icon = 'syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	amount_per_transfer_from_this = 5
	var/mode = "d"
	var/has_blood = 0

	New()
		var/datum/reagents/R = new/datum/reagents(15)
		reagents = R
		R.maximum_volume = 15
		R.my_atom = src

	on_reagent_change()
		update_icon()

	pickup(mob/user)
		..()
		update_icon()

	dropped(mob/user)
		..()
		update_icon()

	attack_self(mob/user as mob)
		switch(mode)
			if("d")
				mode = "i"
			if("i")
				mode = "d"
		update_icon()

	attack_hand()
		..()
		update_icon()

	attack_paw()
		return attack_hand()

	attackby(obj/item/I as obj, mob/user as mob)
		return

	afterattack(obj/target, mob/user , flag)
		if(!target.reagents) return

		switch(mode)
			if("d")
				if(ismob(target))
					if(ismob(target) && target != user)
						if(ishuman(target))
							var/mob/living/carbon/human/H = target
							if(H.vessel.get_reagent_amount("blood") < 5)
								return
							for(var/mob/O in viewers(world.view, user))
								O.show_message(text("\red <B>[] is trying to draw blood from []!</B>", user, target), 1)
							if(!do_mob(user, target)) return
							for(var/mob/O in viewers(world.view, user))
								O.show_message(text("\red [] draws blood from []!", user, target), 1)
							H.vessel.remove_reagent("blood",5)
							reagents.add_reagent("blood",5)
							for(var/datum/reagent/blood/B in reagents.reagent_list)
								if(B.id == "blood")
									B.copy_from(target)
							return
						for(var/mob/O in viewers(world.view, user))
							O.show_message(text("\red <B>[] is trying to draw blood from []!</B>", user, target), 1)
						if(!do_mob(user, target)) return
						for(var/mob/O in viewers(world.view, user))
							O.show_message(text("\red [] draws blood from []!", user, target), 1)
						reagents.add_reagent("blood",5)
						for(var/datum/reagent/blood/B in reagents.reagent_list)
							if(B.id == "blood")
								B.copy_from(target)
					if(ismob(target) && target == user)
						if(ishuman(target))
							var/mob/living/carbon/human/H = target
							if(prob(80))
								user << "\red Oww! The pain makes you miss the vein."
								var/datum/organ/external/org = H.organs["r_arm"]
								org.take_damage(2,0,0,0)
								H.UpdateDamageIcon()
								H.drip(20)
								sleep(10)
								return
							else
								user << "\red You draw some blood from yourself."
							H.vessel.remove_reagent("blood",5)
						reagents.add_reagent("blood",5)
						for(var/datum/reagent/blood/B in reagents.reagent_list)
							if(B.id == "blood")
								B.copy_from(target)
					return //Blood?

				if(!target.reagents.total_volume)
					user << "\red [target] is empty."
					return

				if(reagents.total_volume >= reagents.maximum_volume)
					user << "\red The syringe is full."
					return

				if(!target.is_open_container() && !istype(target,/obj/reagent_dispensers))
					user << "\red You cannot directly remove reagents from this object."
					return

				target.reagents.trans_to(src, 5)

				user << "\blue You fill the syringe with 5 units of the solution."

			if("i")
				if(!reagents.total_volume)
					user << "\red The Syringe is empty."
					return

				if(target.reagents.total_volume >= target.reagents.maximum_volume)
					user << "\red [target] is full."
					return

				if(!target.is_open_container() && !ismob(target) && !istype(target,/obj/item/weapon/reagent_containers/food))
					user << "\red You cannot directly fill this object."
					return

				if(ismob(target) && target != user)
					if(ishuman(target))
						var/mob/living/carbon/human/H = target
						for(var/mob/O in viewers(world.view, user))
							O.show_message(text("\red <B>[] is trying to inject []!</B>", user, target), 1)
						var/datum/reagent/blood/B
						for(var/datum/reagent/blood/d in src.reagents.reagent_list)
							B = d
							break
						if(B)//FIND BACK
							var/datum/reagents/R = new/datum/reagents(5)
							H.vessel.add_reagent("blood",5,B)
							src.reagents.remove_reagent("blood",5)
							if(!do_mob(user, target)) return
							for(var/mob/O in viewers(world.view, user))
								O.show_message(text("\red [] injects [] with the syringe!", user, target), 1)
							R.trans_to(H.vessel,5)
							del(R)
							spawn(5)
								user << "\blue You inject 5 units of the solution. The syringe now contains [src.reagents.total_volume] units."
							return
						else
							if(!do_mob(user, target)) return
							for(var/mob/O in viewers(world.view, user))
								O.show_message(text("\red [] injects [] with the syringe!", user, target), 1)
							src.reagents.trans_to(target, 5)
							spawn(5)
								user << "\blue You inject 5 units of the solution. The syringe now contains [src.reagents.total_volume] units."
							return
					for(var/mob/O in viewers(world.view, user))
						O.show_message(text("\red <B>[] is trying to inject []!</B>", user, target), 1)
					if(!do_mob(user, target)) return
					for(var/mob/O in viewers(world.view, user))
						O.show_message(text("\red [] injects [] with the syringe!", user, target), 1)
					src.reagents.reaction(target, INGEST)
				if(ismob(target) && target == user)
					if(ishuman(target))
						var/datum/reagent/blood/B
						for(var/datum/reagent/blood/d in src.reagents.reagent_list)
							B = d
							break
						if(B)//FIND BACK
							var/mob/living/carbon/human/H = target
							if(prob(80))
								user << "\red Oww! The pain makes you miss the vein."
								var/datum/organ/external/org = H.organs["r_arm"]
								org.take_damage(2,0,0,0)
								H.UpdateDamageIcon()
								H.drip(20)
								sleep(10)
								return
							var/datum/reagents/R = new/datum/reagents(5)
							H.vessel.add_reagent("blood",5,B)
							src.reagents.remove_reagent("blood",5)
							if(!do_mob(user, target)) return
							for(var/mob/O in viewers(world.view, user))
								O.show_message(text("\red [] injects [] with the syringe!", user, target), 1)
							del(R)
							spawn(5)
								user << "\blue You inject 5 units of the solution. The syringe now contains [src.reagents.total_volume] units."
							return
				spawn(5)
					src.reagents.trans_to(target, 5)
					user << "\blue You inject 5 units of the solution. The syringe now contains [src.reagents.total_volume] units."
		return

	proc
		update_icon()
			var/rounded_vol = round(reagents.total_volume,5)
			has_blood = 0
			for(var/datum/reagent/blood/B in reagents.reagent_list)
				has_blood = 1
				break
			if(ismob(loc))
				icon_state = "[mode][(has_blood?"b":"")][rounded_vol]"
			else
				icon_state = "[(has_blood?"b":"")][rounded_vol]"
			item_state = "syringe_[rounded_vol]"

////////////////////////////////////////////////////////////////////////////////
/// Syringes. END
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
/// Pills.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/pill
	name = "pill"
	desc = "a pill."
	icon = 'chemical.dmi'
	icon_state = null
	item_state = "pill"

	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		icon_state = "pill[rand(1,20)]"

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		return
	attack_self(mob/user as mob)
		return
	attack(mob/M as mob, mob/user as mob, def_zone)
		if(M == user)
			M << "\blue You swallow [src]."
			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(5)
					reagents.trans_to(M, reagents.total_volume)
					del(src)
			else
				del(src)
			return 1

		else if(istype(M, /mob/living/carbon/human) )

			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] attempts to force [M] to swallow [src].", 1)

			if(!do_mob(user, M)) return

			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] forces [M] to swallow [src].", 1)

			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(5)
					reagents.trans_to(M, reagents.total_volume)
					del(src)
			else
				del(src)

			return 1

		return 0

	attackby(obj/item/I as obj, mob/user as mob)
		return

	afterattack(obj/target, mob/user , flag)

		if(target.is_open_container() == 1 && target.reagents)
			if(!target.reagents.total_volume)
				user << "\red [target] is empty. Can't dissolve pill."
				return
			user << "\blue You dissolve the pill in [target]"
			reagents.trans_to(target, reagents.total_volume)
			for(var/mob/O in viewers(2, user))
				O.show_message("\red [user] puts something in [target].", 1)
			spawn(5)
				del(src)

		return

////////////////////////////////////////////////////////////////////////////////
/// Pills. END
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
/// Subtypes.
////////////////////////////////////////////////////////////////////////////////

//Glasses
/obj/item/weapon/reagent_containers/glass/bucket
	desc = "It's a bucket."
	name = "bucket"
	icon = 'janitor.dmi'
	icon_state = "bucket"
	item_state = "bucket"
	amount_per_transfer_from_this = 10
	flags = FPRINT | OPENCONTAINER
	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src

	attackby(var/obj/D, mob/user as mob)
		if(istype(D, /obj/item/device/prox_sensor))
			var/obj/item/weapon/bucket_sensor/B = new /obj/item/weapon/bucket_sensor
			B.loc = user
			if (user.r_hand == D)
				user.u_equip(D)
				user.r_hand = B
			else
				user.u_equip(D)
				user.l_hand = B
			B.layer = 20
			user << "You add the sensor to the bucket"
			del(D)
			del(src)

/obj/item/weapon/reagent_containers/glass/dispenser
	name = "reagent glass"
	desc = "A reagent glass."
	icon = 'chemical.dmi'
	icon_state = "beaker"
	amount_per_transfer_from_this = 10
	flags = FPRINT | TABLEPASS | OPENCONTAINER


/obj/item/weapon/reagent_containers/glass/dispenser/surfactant
	name = "reagent glass (surfactant)"
	icon_state = "liquid"

	New()
		..()
		reagents.add_reagent("fluorosurfactant", 20)


/obj/item/weapon/reagent_containers/glass/large
	name = "large reagent glass"
	desc = "A large reagent glass."
	icon = 'chemical.dmi'
	icon_state = "beakerlarge"
	item_state = "beaker"
	amount_per_transfer_from_this = 10
	flags = FPRINT | TABLEPASS | OPENCONTAINER

	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src

	cleaner

		New()
			..()
			reagents.add_reagent("cleaner", 50)

/obj/item/weapon/reagent_containers/glass/bottle/
	name = "bottle"
	desc = "A small bottle."
	icon = 'chemical.dmi'
	icon_state = "bottle16"
	item_state = "atoxinbottle"
	amount_per_transfer_from_this = 10
	flags = FPRINT | TABLEPASS | OPENCONTAINER

	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src
		icon_state = "bottle[rand(1,20)]"
/obj/item/weapon/reagent_containers/glass/bloodpack/
	name = "Blood Pack"
	desc = "A plastic bag of blood."
	icon = 'chemical.dmi'
	icon_state = "bottle16"
	item_state = "atoxinbottle"
	amount_per_transfer_from_this = 10
	flags = FPRINT | TABLEPASS | OPENCONTAINER

	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		icon_state = "bottle[rand(1,20)]"
/obj/item/weapon/reagent_containers/glass/bloodpack/A
	name = "Blood Pack A"
	desc = "A plastic bag of blood with a sticker that says A."
	icon = 'chemical.dmi'
	icon_state = "bottle16"
	item_state = "atoxinbottle"
	amount_per_transfer_from_this = 10

	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		icon_state = "bottle[rand(1,20)]"
		var/datum/reagent/blood/B = new()
		reagents.reagent_list += B
		B.holder = src
		B.volume = 50
		B.blood_type = "A"
		B.description = "Type: [B.blood_type]<br>DNA: DATA EXPUNGED"
		reagents.update_total()
/obj/item/weapon/reagent_containers/glass/bloodpack/B
	name = "Blood Pack B"
	desc = "A plastic bag of blood with a sticker that says B."
	icon = 'chemical.dmi'
	icon_state = "bottle16"
	item_state = "atoxinbottle"
	amount_per_transfer_from_this = 10

	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		icon_state = "bottle[rand(1,20)]"
		var/datum/reagent/blood/B = new()
		reagents.reagent_list += B
		B.holder = src
		B.volume = 50
		B.blood_type = "B"
		B.description = "Type: [B.blood_type]<br>DNA: DATA EXPUNGED"
		R.update_total()
/obj/item/weapon/reagent_containers/glass/bloodpack/O
	name = "Blood Pack O"
	desc = "A plastic bag of blood with a sticker that says O."
	icon = 'chemical.dmi'
	icon_state = "bottle16"
	item_state = "atoxinbottle"
	amount_per_transfer_from_this = 10
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		icon_state = "bottle[rand(1,20)]"
		var/datum/reagent/blood/B = new()
		reagents.reagent_list += B
		B.holder = src
		B.volume = 50
		B.blood_type = "O"
		B.description = "Type: [B.blood_type]<br>DNA: DATA EXPUNGED"
		R.update_total()
/obj/item/weapon/reagent_containers/glass/bloodpack/AB
	name = "Blood Pack AB"
	desc = "A plastic bag of blood with a sticker that says AB."
	icon = 'chemical.dmi'
	icon_state = "bottle16"
	item_state = "atoxinbottle"
	amount_per_transfer_from_this = 10

	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		icon_state = "bottle[rand(1,20)]"
		var/datum/reagent/blood/B = new()
		reagents.reagent_list += B
		B.holder = src
		B.volume = 50
		B.blood_type = "AB"
		B.description = "Type: [B.blood_type]<br>DNA: DATA EXPUNGED"
		R.update_total()
/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline
	name = "inaprovaline bottle"
	desc = "A small bottle. Contains inaprovaline - used to stabilize patients."
	icon = 'chemical.dmi'
	icon_state = "bottle16"
	amount_per_transfer_from_this = 10

	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src
		R.add_reagent("inaprovaline", 30)

/obj/item/weapon/reagent_containers/glass/bottle/toxin
	name = "toxin bottle"
	desc = "A small bottle."
	icon = 'chemical.dmi'
	icon_state = "bottle12"
	amount_per_transfer_from_this = 5

	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src
		R.add_reagent("toxin", 30)

/obj/item/weapon/reagent_containers/glass/bottle/stoxin
	name = "sleep-toxin bottle"
	desc = "A small bottle."
	icon = 'chemical.dmi'
	icon_state = "bottle20"
	amount_per_transfer_from_this = 5

	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src
		R.add_reagent("stoxin", 30)

/obj/item/weapon/reagent_containers/glass/bottle/antitoxin
	name = "dylovene bottle"
	desc = "A small bottle."
	icon = 'chemical.dmi'
	icon_state = "bottle17"
	amount_per_transfer_from_this = 5

	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src
		R.add_reagent("anti_toxin", 30)



/obj/item/weapon/reagent_containers/glass/beaker
	name = "beaker"
	desc = "A beaker. Can hold up to 50 units."
	icon = 'chemical.dmi'
	icon_state = "beaker0"
	item_state = "beaker"

	on_reagent_change()
		if(reagents.total_volume)
			icon_state = "beaker1"
		else
			icon_state = "beaker0"

/obj/item/weapon/reagent_containers/glass/beaker/cryoxadone
	name = "beaker"
	desc = "A beaker. Can hold up to 30 units."
	icon = 'chemical.dmi'
	icon_state = "beaker0"
	item_state = "beaker"

	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src
		R.add_reagent("cryoxadone", 30)


//Syringes
/obj/item/weapon/reagent_containers/syringe/robot
	name = "Syringe (mixed)"
	label = list("mixed")
	desc = "Contains inaprovaline & anti-toxins."
	New()
		var/datum/reagents/R = new/datum/reagents(15)
		reagents = R
		R.maximum_volume = 15
		R.my_atom = src
		R.add_reagent("inaprovaline", 7)
		R.add_reagent("anti_toxin", 8)
		mode = "i"
		update_icon()

/obj/item/weapon/reagent_containers/syringe/inaprovaline
	name = "Syringe (inaprovaline)"
	label = list("inaprovaline")
	desc = "Contains inaprovaline - used to stabilize patients."
	New()
		var/datum/reagents/R = new/datum/reagents(15)
		reagents = R
		R.maximum_volume = 15
		R.my_atom = src
		R.add_reagent("inaprovaline", 15)
		update_icon()

/obj/item/weapon/reagent_containers/syringe/antitoxin
	name = "Syringe (dylovene)"
	label = list("dylovene")
	desc = "Contains anti-toxins."
	New()
		var/datum/reagents/R = new/datum/reagents(15)
		reagents = R
		R.maximum_volume = 15
		R.my_atom = src
		R.add_reagent("anti_toxin", 15)
		update_icon()

/obj/item/weapon/reagent_containers/syringe/antiviral
	name = "Syringe (spaceacillin)"
	label = list("spaceacillin")
	desc = "Contains antiviral agents."
	New()
		var/datum/reagents/R = new/datum/reagents(15)
		reagents = R
		R.maximum_volume = 15
		R.my_atom = src
		R.add_reagent("spaceacillin", 15)
		update_icon()


//Pills
/obj/item/weapon/reagent_containers/pill/antitox
	name = "dylovene pill"
	desc = "Neutralizes many common toxins."
	icon_state = "pill17"

	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("anti_toxin", 50)

/obj/item/weapon/reagent_containers/pill/tox
	name = "Toxins pill"
	desc = "Highly toxic."
	icon_state = "pill5"

	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("toxin", 50)

/obj/item/weapon/reagent_containers/pill/stox
	name = "Sleeping pill"
	desc = "Commonly used to treat insomnia."
	icon_state = "pill8"

	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("stoxin", 30)

/obj/item/weapon/reagent_containers/pill/kelotane
	name = "Kelotane pill"
	desc = "Used to treat burns."
	icon_state = "pill11"

	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("kelotane", 30)

/obj/item/weapon/reagent_containers/pill/inaprovaline
	name = "Inaprovaline pill"
	desc = "Used to stabilize patients."
	icon_state = "pill20"

	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("inaprovaline", 30)

//Dispensers
/obj/reagent_dispensers/watertank
	name = "watertank"
	desc = "A watertank"
	icon = 'objects.dmi'
	icon_state = "watertank"
	amount_per_transfer_from_this = 10

	New()
		..()
		reagents.add_reagent("water",1000)

/obj/reagent_dispensers/hvwatertank
	name = "high-volume watertank"
	desc = "A large watertank"
	icon = 'objects.dmi'
	icon_state = "hvwatertank"
	amount_per_transfer_from_this = 10

	New()
		..()
		reagents.add_reagent("water",3000)

/obj/reagent_dispensers/fueltank
	name = "fueltank"
	desc = "A fueltank"
	icon = 'objects.dmi'
	icon_state = "weldtank"
	amount_per_transfer_from_this = 10

	New()
		..()
		reagents.add_reagent("fuel",1000)

/obj/reagent_dispensers/beerkeg
	name = "beer keg"
	desc = "A beer keg"
	icon = 'objects.dmi'
	icon_state = "beertankTEMP"
	amount_per_transfer_from_this = 10

	New()
		..()
		reagents.add_reagent("beer",1000)

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////