

/obj/item/weapon/anobattery
	name = "Anomaly power battery"
	icon = 'anomaly.dmi'
	icon_state = "anobattery"
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
				dat += "<BR>	[e.fluff] <BR>		power	[e.magnitude*(e.range+1)]/[b.power["[e.effectname]"]]<BR>magnitude [e.magnitude]<A href='?src=\ref[src];mu=[e.effectname]'>+</a> <A href='?src=\ref[src];md=[e.effectname]'>-</a><BR>range [e.range]<A href='?src=\ref[src];ru=[e.effectname]'>+</a> <A href='?src=\ref[src];rd=[e.effectname]'>-</a>"
			dat+="<BR> Estimated cooldown [round(ccooldown()/4)]"
			dat += "<BR><A href='?src=\ref[src];a=1'>Activate</a>"
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
	if(src.cooldown)
		src.cooldown--
		if(!src.cooldown)
			for(var/mob/m in hearers(get_turf(src)))
				var/t = pick("chimes","pings","buzzes")
				m<<"The [src.name] [t]"

				processing_items.Remove(src)



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
			if((e.magnitude+1)*(e.range+1)<b.power["[effectname]"])
				e.magnitude++
		if (href_list["ru"])
			var/effectname = href_list["ru"]
			var/datum/anomalyeffect/e = b.e["[effectname]"]
			if((e.range+2)*e.magnitude<b.power["[effectname]"])
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
		if (href_list["a"])
			for(var/v in b.e)
				var/datum/anomalyeffect/e = b.e["[v]"]
				e.Activate()
			processing_items.Add(src)
			UpdateSprite()
			cooldown=round(ccooldown()/4)
		if (href_list["ejectb"])
			src.b.loc = get_turf(src)
			src.b = null
			UpdateSprite()

		src.add_fingerprint(usr)
	src.updateUsrDialog()
	for (var/mob/M in viewers(1, src.loc))
		if (M.client && M.machine == src)
			src.attack_self(M)
	return
