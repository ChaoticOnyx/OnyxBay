

/obj/item/weapon/anobattery
	name = "Anomaly power battery"
	icon = 'anomaly.dmi'
	icon_state = "anobattery0"
	var/list/datum/anomalyeffect/e = list()
	var/capacity = 200

	var/list/power = list()

/obj/item/weapon/anobattery/proc/UpdateSprite()
	var/p = (GetTotalPower()/capacity)*100
	var/s = round(p,25)
	icon_state = "anobattery[s]"

/obj/item/weapon/anobattery/proc/AddPower(var/datum/anomalyeffect/n,var/npower)
	var/curpower
	for(var/v in power)
		curpower += power["[v]"]
	if(curpower+npower > capacity)
		return 0
	if(!e["[n.effectname]"])
		e["[n.effectname]"]=n
		n.range=1
		n.magnitude=1
		n.o = src
	power["[n.effectname]"]+=npower
	UpdateSprite()
	return 1


/obj/item/weapon/anobattery/proc/DebugAddPower(var/name,var/npower)
	var/datum/anomalyeffect/n
	var/path = text2path("/datum/anomalyeffect/[name]")
	n = new path
	return AddPower(n,npower)

/obj/item/weapon/anobattery/proc/TakePower(var/datum/anomalyeffect/n,var/npower)
	power["[n.effectname]"] -= npower
	if(power["[n.effectname]"]<1)
		power.Remove("[n.effectname]")
	UpdateSprite()

/obj/item/weapon/anobattery/proc/GetPower(var/datum/anomalyeffect/n)
	return power["[n.effectname]"]


/obj/item/weapon/anobattery/proc/GetTotalPower()
	var/curpower = 0
	for(var/v in power)
		curpower += power["[v]"]
	return curpower


/obj/item/weapon/anodevice
	name = "Anomaly power utilizer"
	icon = 'anomaly.dmi'
	icon_state = "anodev"
	var/cooldown
	var/timing = 0
	var/time = 60
	var/obj/item/weapon/anobattery/b

/obj/item/weapon/anodevice/proc/UpdateSprite()
	if(!b)
		icon_state = "anodev"
		return
	var/p = (b.GetTotalPower()/b.capacity)*100
	var/s = round(p,25)
	icon_state = "anodev[s]"

/obj/item/weapon/anodevice/proc/interact(var/mob/user)


	user.machine = src

	var/dat
	if(cooldown)
		dat = "Cooldown in progress"
	else
		if(!b)
			dat += "<BR>Please insert battery"

		if(b)
			dat += "<BR>[b.name] inserted <BR> Total Power - [b.GetTotalPower()]/[b.capacity]"
			dat += "<BR>Effects:"
			for(var/v in b.e)
				var/datum/anomalyeffect/e = b.e["[v]"]
				dat += "<BR>	[e.fluff] <BR>		power	[e.magnitude*(e.range+1)]/[b.power["[e.effectname]"]]<BR>magnitude [e.magnitude]<A href='?src=\ref[src];mu=[e.effectname]'>+</a> <A href='?src=\ref[src];muu=[e.effectname]'>++</a> <A href='?src=\ref[src];mdd=[e.effectname]'>--</a> <A href='?src=\ref[src];md=[e.effectname]'>-</a><BR>range [e.range]<A href='?src=\ref[src];ru=[e.effectname]'>+</a> <A href='?src=\ref[src];ruu=[e.effectname]'>++</a> <A href='?src=\ref[src];rdd=[e.effectname]'>-</a> <A href='?src=\ref[src];rd=[e.effectname]'>-</a>"
			dat+="<BR> Estimated cooldown [round(ccooldown()/4)+1]"
			dat += "<BR><A href='?src=\ref[src];a=1'>Activate</a>"
			if(timing)
				dat += "<BR>Timing [time]"
				dat += "<BR><A href='?src=\ref[src];ts=0'>Stop timer</a>"
			else
				dat += "<BR>Not Timing [time]"
				dat += "<BR><A href='?src=\ref[src];st=1'>Start timer</a>"
			dat += "<BR>T <A href='?src=\ref[src];tu=1'>+</a> <A href='?src=\ref[src];tu=10'>++</a>"
			dat += "<BR>T <A href='?src=\ref[src];td=1'>-</a> <A href='?src=\ref[src];td=10'>--</a>"
			dat += "<BR><A href='?src=\ref[src];ejectb=1'>Eject battery</a>"

	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return


/obj/item/weapon/anodevice/attackby(var/obj/I as obj, var/mob/user as mob)

	if(istype(I, /obj/item/weapon/anobattery))
		if(!b)
			user << "You insert the battery."
			user.drop_item()
			I.loc = src
			for(var/v in I:e)
				var/datum/anomalyeffect/e = I:e["[v]"]
				e.o = src
			src.b = I
			UpdateSprite()
	else
		..()

/obj/item/weapon/anodevice/attack_self(mob/user as mob)
	interact(user)

/obj/item/weapon/anodevice/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/item/weapon/anodevice/attack_paw(var/mob/user as mob)

	return src.attack_hand(user)
	return


/obj/item/weapon/anodevice/process()
	if(timing)
		time--
		for (var/mob/M in viewers(1, src.loc))
			if (M.client && M.machine == src)
				src.attack_self(M)
		if(!time)
			if(!cooldown)
				for(var/v in b.e)
					var/datum/anomalyeffect/e = b.e["[v]"]
					b.TakePower(e,e.magnitude*(e.range+1))
					e.Activate()
				processing_items.Add(src)
				UpdateSprite()
				cooldown=round(ccooldown()/4)
			time = 60
			timing = 0
	if(src.cooldown)
		src.cooldown--
		if(1>src.cooldown)
			for(var/mob/m in hearers(get_turf(src)))
				var/t = pick("chimes","pings","buzzes")
				m<<"The [src.name] [t]"
			if(!timing)
				processing_items.Remove(src)
			for(var/v in b.e)
				var/datum/anomalyeffect/e = b.e["[v]"]
				if(e.magnitude*(e.range+1)>b.power["[e.effectname]"])
					e.magnitude = 1
					e.range = 0
			cooldown = 0



/obj/item/weapon/anodevice/proc/ccooldown()
	var/power
	for(var/v in b.e)
		var/datum/anomalyeffect/e = b.e["[v]"]
		power+=e.magnitude*(e.range+1)
	return power

/obj/item/weapon/anodevice/Topic(href, href_list)
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src

		if (href_list["mu"])
			var/effectname = href_list["mu"]
			var/datum/anomalyeffect/e = b.e["[effectname]"]
			if((e.magnitude+1)*(e.range+1)<=b.power["[effectname]"])
				e.magnitude++
		if (href_list["ru"])
			var/effectname = href_list["ru"]
			var/datum/anomalyeffect/e = b.e["[effectname]"]
			if((e.range+2)*e.magnitude<=b.power["[effectname]"])
				e.range++
		if (href_list["md"])
			var/effectname = href_list["md"]
			var/datum/anomalyeffect/e = b.e["[effectname]"]
			if(e.magnitude>0)
				e.magnitude--
		if (href_list["rd"])
			var/effectname = href_list["rd"]
			var/datum/anomalyeffect/e = b.e["[effectname]"]
			if(e.range>0)
				e.range--
		if (href_list["muu"])
			var/effectname = href_list["muu"]
			var/datum/anomalyeffect/e = b.e["[effectname]"]
			if((e.magnitude+10)*(e.range+1)<=b.power["[effectname]"])
				e.magnitude+=10
		if (href_list["ruu"])
			var/effectname = href_list["ruu"]
			var/datum/anomalyeffect/e = b.e["[effectname]"]
			if((e.range+11)*e.magnitude<=b.power["[effectname]"])
				e.range+=10
		if (href_list["mdd"])
			var/effectname = href_list["mdd"]
			var/datum/anomalyeffect/e = b.e["[effectname]"]
			if(e.magnitude-10>0)
				e.magnitude-=10
		if (href_list["rdd"])
			var/effectname = href_list["rrd"]
			var/datum/anomalyeffect/e = b.e["[effectname]"]
			if(e.range-10>=0)
				e.range-=10
		if(href_list["st"])
			processing_items.Add(src)
			timing = 1
		if(href_list["ts"])
			if(!cooldown)
				processing_items.Remove(src)
			timing = 0
		if(href_list["tu"])
			time += text2num(href_list["tu"])
		if(href_list["td"])
			var/amt = text2num(href_list["td"])
			if(amt>0)
				time -= amt

		if (href_list["a"])
			for(var/v in b.e)
				var/datum/anomalyeffect/e = b.e["[v]"]
				b.TakePower(e,e.magnitude*(e.range+1))
				e.Activate()

			processing_items.Add(src)
			UpdateSprite()
			cooldown=round(ccooldown()/4)+1
		if (href_list["ejectb"])
			src.b.loc = get_turf(src)
			for(var/v in b.e)
				var/datum/anomalyeffect/e = b.e["[v]"]
				e.o = b
			src.b = null
			UpdateSprite()
		if (href_list["close"])
			if(usr.machine == src)
				usr.machine = null

		src.add_fingerprint(usr)
	src.updateUsrDialog()
	for (var/mob/M in viewers(1, src.loc))
		if (M.client && M.machine == src)
			src.attack_self(M)
	return
