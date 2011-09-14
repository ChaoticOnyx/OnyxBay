#define SOLID 1
#define LIQUID 2
#define GAS 3

/obj/machinery/chem_dispenser/
	name = "chem dispenser"
	density = 1
	anchored = 1
	icon = 'chemical.dmi'
	icon_state = "dispenser"
	var/energy = 10
	//var/max_energy = 25
	var/list/dispensable_reagents = list("water","oxygen","nitrogen","hydrogen","potassium","mercury","sulfur","carbon","chlorine","fluorine","phosphorus","lithium","acid","radium","iron","aluminium","silicon","plasma","sugar","ethanol", "milk")

	//proc
		//recharge()
		//	if(stat & BROKEN) return
		//	if(energy != max_energy)
		//		energy++
		//		use_power(50)
		//	spawn(600) recharge()

	New()
		//recharge()

	ex_act(severity)
		switch(severity)
			if(1.0)
				del(src)
				return
			if(2.0)
				if (prob(50))
					del(src)
					return

	blob_act()
		if (prob(25))
			del(src)

	meteorhit()
		del(src)
		return

	Topic(href, href_list)
		if(stat & BROKEN) return
		if(usr.stat || usr.restrained()) return
		if(!in_range(src, usr)) return

		usr.machine = src

		if (href_list["dispense"])
			if(!energy)
				var/dat = "Not enough energy.<BR><A href='?src=\ref[src];ok=1'>OK</A>"
				usr << browse("<TITLE>Chemical Dispenser</TITLE>Chemical dispenser:<BR>Energy = [energy]<BR><BR>[dat]", "window=chem_dispenser")
				return
			var/id = href_list["dispense"]
			var/obj/item/weapon/reagent_containers/glass/dispenser/G = new/obj/item/weapon/reagent_containers/glass/dispenser(src.loc)
			switch(text2num(href_list["state"]))
				if(LIQUID)
					G.icon_state = "liquid"
				if(GAS)
					G.icon_state = "vapour"
				if(SOLID)
					G.icon_state = "solid"
			G.name += " ([lowertext(href_list["name"])])"
			G.reagents.add_reagent(id,30)
			energy--
			src.updateUsrDialog()
			return
		else
			usr << browse(null, "window=chem_dispenser")
			return

		src.add_fingerprint(usr)
		return

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if(stat & BROKEN)
			return
		user.machine = src
		var/dat = ""
		for(var/re in dispensable_reagents)
			for(var/da in typesof(/datum/reagent) - /datum/reagent)
				var/datum/reagent/temp = new da()
				if(temp.id == re)
					dat += "<A href='?src=\ref[src];dispense=[temp.id];state=[temp.reagent_state];name=[temp.name]'>[temp.name]</A><BR>"
					dat += "[temp.description]<BR><BR>"
		user << browse("<TITLE>Chemical Dispenser</TITLE>Chemical dispenser:<BR>Energy = [energy]<BR><BR>[dat]", "window=chem_dispenser")

		onclose(user, "chem_dispenser")
		return

/obj/machinery/chem_dispenser/attackby(obj/item/weapon/reagent_containers/glass/dispenser/B, mob/user)
	if(istype(B))
		del(B)
		user << "You place the glass into the machine."
		//if (energy < max_energy)
		//	energy++
		spawn(0)
			for(var/mob/O in hearers(src, null))
				O.show_message("<B>[src] whirs as it recycles the glass!</B>", 1)
		return
	..()


/obj/machinery/chem_dispenser/attackby(obj/item/weapon/vending_charge/chemistry/V, mob/user)
	if (istype(V,/obj/item/weapon/vending_charge/chemistry))
		energy += V.charge_amt
		del(V)
		user << "You load the charge into the machine."
		return
	..()

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/chem_master/
	name = "CheMaster 3000"
	density = 1
	anchored = 1
	layer = 2.5
	icon = 'chemical.dmi'
	icon_state = "mixer0"
	var/beaker = null

	ex_act(severity)
		switch(severity)
			if(1.0)
				del(src)
				return
			if(2.0)
				if (prob(50))
					del(src)
					return

	blob_act()
		if (prob(25))
			del(src)

	meteorhit()
		del(src)
		return

	attackby(var/obj/item/weapon/reagent_containers/glass/B as obj, var/mob/user as mob)
		if(!istype(B, /obj/item/weapon/reagent_containers/glass) && !istype(B,/obj/item/weapon/reagent_containers/syringe))
			return

		if(src.beaker)
			if(istype(beaker,/obj/item/weapon/reagent_containers/syringe))
				user << "A syringe is already loaded into the machine."
			else
				user << "A beaker is already loaded into the machine."
			return

		src.beaker =  B
		user.drop_item()
		B.loc = src
		if(istype(B,/obj/item/weapon/reagent_containers/syringe))
			user << "You add the syringe to the machine!"
			src.updateUsrDialog()
			icon_state = "mixers"
		else
			user << "You add the beaker to the machine!"
			src.updateUsrDialog()
			icon_state = "mixer1"

	Topic(href, href_list)
		if(stat & BROKEN) return
		if(usr.stat || usr.restrained()) return
		if(!in_range(src, usr)) return

		usr.machine = src
		if(!beaker) return
		var/datum/reagents/R = beaker:reagents

		if (href_list["isolate"])
			R.isolate_reagent(href_list["isolate"])
			src.updateUsrDialog()
			return
		else if (href_list["remove"])
			R.del_reagent(href_list["remove"])
			src.updateUsrDialog()
			return
		else if (href_list["remove5"])
			R.remove_reagent(href_list["remove5"], 5)
			src.updateUsrDialog()
			return
		else if (href_list["remove1"])
			R.remove_reagent(href_list["remove1"], 1)
			src.updateUsrDialog()
			return
		else if (href_list["analyze"])
			var/dat = "<TITLE>Chemmaster 3000</TITLE>Chemical infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			usr << browse(dat, "window=chem_master;size=575x400")
			return
		else if (href_list["main"])
			attack_hand(usr)
			return
		else if (href_list["eject"])
			beaker:loc = src.loc
			beaker = null
			icon_state = "mixer0"
			src.updateUsrDialog()
			return
		else if (href_list["createpill"])
			var/name = input(usr,"Name:","Name your pills!",R.get_master_reagent_name())
			if(!name || name == " ") name = R.get_master_reagent_name()
			var/pillsprite = input("What should the pills look like?", "Pill Style", "Cancel") in list(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20)
			var/pillstrength = input(usr, "What amount of chemicals per pill?", "Pill Strength", R.total_volume)
			if(pillstrength == 0) //no peel heer
				return
			if (pillstrength < 1 || pillstrength > R.total_volume)
				pillstrength = R.total_volume
			while (R.total_volume >= pillstrength)
				var/obj/item/weapon/reagent_containers/pill/P = new/obj/item/weapon/reagent_containers/pill(src.loc)
				P.name = "[name] Pill"
				P.icon_state = "pill[pillsprite]"
				R.trans_to(P,pillstrength)
			src.updateUsrDialog()
			return
		else if (href_list["createbottle"])
			var/obj/item/weapon/reagent_containers/glass/bottle/P = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc)
			var/name = input(usr,"Name:","Name your bottle!",R.get_master_reagent_name())
			if(!name || name == " ") name = R.get_master_reagent_name()
			P.name = "[name] Bottle"
			R.trans_to(P,30)
			src.updateUsrDialog()
			return
		else
			usr << browse(null, "window=chem_master")
			return

		src.add_fingerprint(usr)
		return

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if(stat & BROKEN)
			return
		user.machine = src
		var/dat = ""
		if(!beaker)
			dat = "Please insert beaker or syringe.<BR>"
			dat += "<A href='?src=\ref[src];close=1'>Close</A>"
		else
			var/datum/reagents/R = beaker:reagents
			dat += "<A href='?src=\ref[src];eject=1'>Eject</A><BR><BR>"
			if(!R.total_volume)
				dat += "[beaker] is empty."
			else
				dat += "Contained reagents:<BR>"
				for(var/datum/reagent/G in R.reagent_list)
					dat += "[G.name] , [G.volume] Units - <A href='?src=\ref[src];isolate=[G.id]'>(Isolate)</A> <A href='?src=\ref[src];remove=[G.id]'>(Remove all)</A> <A href='?src=\ref[src];remove5=[G.id]'>(Remove 5)</A> <A href='?src=\ref[src];remove1=[G.id]'>(Remove 1)</A> <A href='?src=\ref[src];analyze=1;desc=[G.description];name=[G.name]'>(Analyze)</A><BR>"
				dat += "<BR><A href='?src=\ref[src];createpill=1'>Create pills</A><BR>"
				dat += "<A href='?src=\ref[src];createbottle=1'>Create bottle (30 units max)</A>"
		user << browse("<TITLE>Chemmaster 3000</TITLE>Chemmaster menu:<BR><BR>[dat]", "window=chem_master;size=575x400")
		onclose(user, "chem_master")
		return