// this goes in gameticker.dm's setup() proc and works in conjuction with landmarks manually placed on the map
		var/list/lootspawn = list()
		for(var/obj/landmark/S in world)
			if (S.name == "Loot spawn")
				lootspawn.Add(S.loc)
		if(lootspawn.len)
			var/lootamt = rand(5,15)
			while(lootamt > 0)
				var/lootloc = pick(lootspawn)
				if (prob(75)) new/obj/crate/loot(lootloc)
				--lootamt

// this can go anywhere, probably best in the crates file i guess

/obj/crate/loot
	desc = "What could be inside?"
	name = "Abandoned Crate"
	icon_state = "securecrate"
	openicon = "securecrateopen"
	closedicon = "securecrate"
	var/redlight = "securecrater"
	var/greenlight = "securecrateg"
	var/sparks = "securecratesparks"
	var/emag = "securecrateemag"
	var/code = null
	var/lastattempt = null
	var/attempts = 3
	locked = 1

	New()
		..()
		src.code = rand(1,10)
		overlays = null
		overlays += redlight
		var/loot = rand(1,3)
		switch(loot)
			if(1)
				new/obj/item/weapon/reagent_containers/food/drinks/rum_spaced(src)
				new/obj/item/weapon/reagent_containers/food/drinks/rum_spaced(src)
				new/obj/item/weapon/reagent_containers/food/drinks/rum_spaced(src)
				new/obj/item/weapon/reagent_containers/food/drinks/thegoodstuff(src)
				new/obj/item/weapon/plant/cannabis(src)
				new/obj/item/weapon/plant/cannabis(src)
				new/obj/item/weapon/plant/cannabis(src)
			if(2)
				new/obj/item/weapon/spacecash/thousand(src)
				new/obj/item/weapon/spacecash/thousand(src)
				new/obj/item/weapon/spacecash/thousand(src)
				new/obj/item/weapon/spacecash/thousand(src)
				new/obj/item/weapon/spacecash/thousand(src)
			if(3)
				new/obj/machinery/artifact(src)


	attack_hand(mob/user as mob)
		if(locked)
			user << "\blue The crate is locked with a deca-code lock."
			var/input = input(usr, "Enter digit from 1 to 10.", "Deca-Code Lock", "") as num
			if (input == src.code)
				user << "\blue The crate unlocks!"
				overlays = null
				overlays += greenlight
				src.locked = 0
			else if (input == null || input > 10 || input < 1) user << "You leave the crate alone."
			else
				user << "\red A red light flashes."
				src.lastattempt = input
				src.attempts--
				if (src.attempts == 0)
					user << "\red The crate's anti-tamper system activates!"
					var/turf/T = get_turf(src.loc)
					explosion(T, -1, -1, 1, 1)
					del src
					return
		else return ..()

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(locked)
			if (istype(W, /obj/item/weapon/card/emag))
				user << "\blue The crate unlocks!"
				overlays = null
				overlays += greenlight
				src.locked = 0
			if (istype(W, /obj/item/device/multitool))
				user << "DECA-CODE LOCK REPORT:"
				if (src.attempts == 1) user << "\red * Anti-Tamper Bomb will activate on next failed access attempt."
				else user << "* Anti-Tamper Bomb will activate after [src.attempts] failed access attempts."
				if (lastattempt == null)
					user << "* No attempt has been made to open the crate thus far."
					return
				// hot and cold
				if (src.code > src.lastattempt) user << "* Last access attempt lower than expected code."
				else user << "* Last access attempt higher than expected code."
			else ..()
		else ..()