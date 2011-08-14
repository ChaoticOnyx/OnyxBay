// the entire manufacturing.dm

/datum/manufacture
	var/name = null
	var/item = null
	var/cost1 = null
	var/cost2 = null
	var/cost3 = null
	var/cname1 = null
	var/cname2 = null
	var/cname3 = null
	var/amount1 = 0
	var/amount2 = 0
	var/amount3 = 0
	var/create = 1
	var/time = 5

/obj/machinery/manufacturer
	name = "Manufacturing Unit"
	desc = "A standard fabricator unit capable of producing certain items from mined ore."
	icon = 'surgery.dmi'
	icon_state = "fab-idle"
	density = 1
	anchored = 1
	//mats = 25
	var/working = 0
	var/panelopen = 0
	var/powconsumption = 0
	var/hacked = 0
	var/acceptdisk = 0
	var/malfunction = 0
	var/electrified = 0
	var/dl_list = null
	var/list/available = list()
	var/list/diskload = list()
	var/list/download = list()
	var/list/hidden = list()
	var/wires = 15
	var/const
		WIRE_EXTEND = 1
		WIRE_DISK = 2
		WIRE_MALF = 3
		WIRE_SHOCK = 4

	New()
		..()

	process()
		..()
		if (src.working) use_power(src.powconsumption)
		if(src.electrified > 0) src.electrified--

	ex_act(severity)
		switch(severity)
			if(1.0) del(src)
			if(2.0)
				if (prob(60)) stat |= BROKEN
			if(3.0)
				if (prob(30)) stat |= BROKEN
		return

	blob_act()
		if (prob(25)) del src
		return

	meteorhit()
		if (prob(50)) del src
		return

	power_change()
		if(stat & BROKEN) icon_state = "fab-broken"
		else
			if( powered() )
				if (src.working) src.icon_state = "fab-active"
				else src.icon_state = "fab-idle"
				stat &= ~NOPOWER
			else
				spawn(rand(0, 15))
					src.icon_state = "fab-off"
					stat |= NOPOWER

	attack_hand(var/mob/user as mob)
		if(stat & BROKEN) return
		if(stat & NOPOWER) return
		if(src.electrified != 0) src.manuf_zap(user, 33)

		user.machine = src
		var/dat = "<B>[src.name]</B><BR><HR>"

		if(src.working)
			dat += "This unit is currently busy."
			user << browse(dat, "window=manufact;size=400x500")
			onclose(user, "manufact")
			return

		var/AMTmaux = 0
		var/AMTmoli = 0
		var/AMTphar = 0
		var/AMTclar = 0
		var/AMTbohr = 0
		var/AMTereb = 0
		var/AMTcere = 0
		var/AMTplas = 0
		var/AMTuqil = 0
		var/AMTtele = 0
		var/AMTfabr = 0

		for(var/obj/item/weapon/ore/O in src.contents)
			if (istype(O,/obj/item/weapon/ore/mauxite)) AMTmaux++
			if (istype(O,/obj/item/weapon/ore/molitz)) AMTmoli++
			if (istype(O,/obj/item/weapon/ore/pharosium)) AMTphar++
			if (istype(O,/obj/item/weapon/ore/claretine)) AMTclar++
			if (istype(O,/obj/item/weapon/ore/bohrum)) AMTbohr++
			if (istype(O,/obj/item/weapon/ore/erebite)) AMTereb++
			if (istype(O,/obj/item/weapon/ore/cerenkite)) AMTcere++
			if (istype(O,/obj/item/weapon/ore/plasmastone)) AMTplas++
			if (istype(O,/obj/item/weapon/ore/uqill)) AMTuqil++
			if (istype(O,/obj/item/weapon/ore/telecrystal)) AMTtele++
			if (istype(O,/obj/item/weapon/ore/fabric)) AMTfabr++

		dat += "<B>Available Minerals</B><BR>"
		if (AMTmaux) dat += "<A href='?src=\ref[src];eject=1'><B>Mauxite:</B></A> [AMTmaux]<br>"
		if (AMTmoli) dat += "<A href='?src=\ref[src];eject=2'><B>Molitz:</B></A> [AMTmoli]<br>"
		if (AMTphar) dat += "<A href='?src=\ref[src];eject=3'><B>Pharosium:</B></A> [AMTphar]<br>"
		if (AMTclar) dat += "<A href='?src=\ref[src];eject=4'><B>Claretine:</B></A> [AMTclar]<br>"
		if (AMTbohr) dat += "<A href='?src=\ref[src];eject=5'><B>Bohrum:</B></A> [AMTbohr]<br>"
		if (AMTereb) dat += "<A href='?src=\ref[src];eject=6'><B>Erebite:</B></A> [AMTereb]<br>"
		if (AMTcere) dat += "<A href='?src=\ref[src];eject=7'><B>Cerenkite:</B></A> [AMTcere]<br>"
		if (AMTplas) dat += "<A href='?src=\ref[src];eject=8'><B>Plasma:</B></A> [AMTplas]<br>"
		if (AMTuqil) dat += "<A href='?src=\ref[src];eject=9'><B>Uqill:</B></A> [AMTuqil]<br>"
		if (AMTtele) dat += "<A href='?src=\ref[src];eject=10'><B>Telecrystal:</B></A> [AMTtele]<br>"
		if (AMTfabr) dat += "<A href='?src=\ref[src];eject=11'><B>Fabric:</B></A> [AMTfabr]<br>"
		if (!AMTmaux && !AMTmoli && !AMTphar && !AMTclar && !AMTbohr && !AMTereb && !AMTcere && !AMTplas && !AMTuqil && !AMTtele && !AMTfabr)
			dat += "No minerals currently loaded.<br>"

		dat += {"<HR>
		<B>Available Schematics</B>"}

		for(var/datum/manufacture/A in src.available)
			dat += {"<BR><A href='?src=\ref[src];disp=\ref[A]'>
			<b><u>[A.name]</u></b></A><br>
			<b>Cost:</b> [A.amount1] [A.cname1]"}
			if (A.cost2) dat += ", [A.amount2] [A.cname2]"
			if (A.cost3) dat += ", [A.amount3] [A.cname3]"
			dat += "<br><b>Time:</b> [A.time] Seconds<br>"

		for(var/datum/manufacture/A in src.download)
			dat += {"<BR><A href='?src=\ref[src];disp=\ref[A]'>
			<b><u>[A.name]</u></b></A> (Downloaded)<br>
			<b>Cost:</b> [A.amount1] [A.cname1]"}
			if (A.cost2) dat += ", [A.amount2] [A.cname2]"
			if (A.cost3) dat += ", [A.amount3] [A.cname3]"
			dat += "<br><b>Time:</b> [A.time] Seconds<br>"

		for(var/datum/manufacture/A in src.diskload)
			dat += {"<BR><A href='?src=\ref[src];disp=\ref[A]'>
			<b><u>[A.name]</u></b></A> (Disk)<br>
			<b>Cost:</b> [A.amount1] [A.cname1]"}
			if (A.cost2) dat += ", [A.amount2] [A.cname2]"
			if (A.cost3) dat += ", [A.amount3] [A.cname3]"
			dat += "<br><b>Time:</b> [A.time] Seconds<br>"

		if (src.hacked)
			for(var/datum/manufacture/A in src.hidden)
				dat += {"<BR><A href='?src=\ref[src];disp=\ref[A]'>
				<b><u>[A.name]</u></b></A> (Secret)<br>
				<b>Cost:</b> [A.amount1] [A.cname1]"}
				if (A.cost2) dat += ", [A.amount2] [A.cname2]"
				if (A.cost3) dat += ", [A.amount3] [A.cname3]"
				dat += "<br><b>Time:</b> [A.time] Seconds<br>"

		dat += "<hr>"

		if (src.dl_list)
			dat += {"<A href='?src=\ref[src];download=1'>Download Available Schematics</A><BR>
			<A href='?src=\ref[src];delete=2'>Clear Downloaded Schematics</A><BR>"}

		if (src.acceptdisk)
			dat += {"<A href='?src=\ref[src];delete=1'>Clear Disk Schematics</A><BR>"}

		user << browse(dat, "window=manufact;size=400x500")
		onclose(user, "manufact")

		if (src.panelopen)
			var/list/manuwires = list(
			"Amber" = 1,
			"Teal" = 2,
			"Indigo" = 3,
			"Lime" = 4,
			)
			var/pdat = "<B>[src] Maintenance Panel</B><hr>"
			for(var/wiredesc in manuwires)
				var/is_uncut = src.wires & APCWireColorToFlag[manuwires[wiredesc]]
				pdat += "[wiredesc] wire: "
				if(!is_uncut)
					pdat += "<a href='?src=\ref[src];cutwire=[manuwires[wiredesc]]'>Mend</a>"
				else
					pdat += "<a href='?src=\ref[src];cutwire=[manuwires[wiredesc]]'>Cut</a> "
					pdat += "<a href='?src=\ref[src];pulsewire=[manuwires[wiredesc]]'>Pulse</a> "
				pdat += "<br>"

			pdat += "<br>"
			pdat += "The yellow light is [(src.electrified == 0) ? "off" : "on"].<BR>"
			pdat += "The blue light is [src.malfunction ? "flashing" : "on"].<BR>"
			pdat += "The white light is [src.hacked ? "on" : "off"].<BR>"
			pdat += "The [src.acceptdisk ? "green" : "red"] light is on.<BR>"

			user << browse(pdat, "window=manupanel")
			onclose(user, "manupanel")

	Topic(href, href_list)
		if(stat & BROKEN) return
		if(stat & NOPOWER) return
		if(usr.stat || usr.restrained())
			return

		if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))))
			usr.machine = src

			if (href_list["download"])
				if (src.electrified) src.manuf_zap(usr, 33)
				if(!src.dl_list) usr << "\red This unit is not capable of downloading any additional schematics."
				else
					var/amtdl = 0
					//var/dontload = 0
					if (src.dl_list == "robotics")
						/*for(var/i = robotics_research.starting_tier, i <= robotics_research.max_tiers, i++)
							for(var/datum/roboresearch/X in robotics_research.researched_items[i])
								for (var/datum/manufacture/S in X.schematics)
									for (var/datum/manufacture/A in src.download)
										if (istype(S,A)) dontload = 1
									if (!dontload)
										src.download += new S.type(src)
										amtdl++
									else dontload = 0*/
						if (amtdl) usr << "\blue [amtdl] new schematics downloaded from Robotics Research Database."
						else usr << "\red No new schematics currently available in Robotics Research Database."

			if (href_list["delete"])
				if (src.electrified) src.manuf_zap(usr, 33)
				var/operation = text2num(href_list["delete"])
				if(operation == 1) // Clear Disk Schematics
					var/amtgone = 0
					for(var/datum/manufacture/D in src.diskload)
						src.diskload-= D
						amtgone++
					if (amtgone) usr << "\blue Cleared [amtgone] schematics from database."
					else usr << "\red No disk-loaded schematics detected in database."
				if(operation == 2) // Clear Download Schematics
					var/amtgone = 0
					for(var/datum/manufacture/D in src.download)
						src.download-= D
						amtgone++
					if (amtgone) usr << "\blue Cleared [amtgone] schematics from database."
					else usr << "\red No downloaded schematics detected in database."

			if (href_list["eject"])
				var/operation = text2num(href_list["eject"])
				var/ejectamt = 0
				var/ejecting = null
				switch(operation)
					if(1) ejecting = /obj/item/weapon/ore/mauxite
					if(2) ejecting = /obj/item/weapon/ore/molitz
					if(3) ejecting = /obj/item/weapon/ore/pharosium
					if(4) ejecting = /obj/item/weapon/ore/claretine
					if(5) ejecting = /obj/item/weapon/ore/bohrum
					if(6) ejecting = /obj/item/weapon/ore/erebite
					if(7) ejecting = /obj/item/weapon/ore/cerenkite
					if(8) ejecting = /obj/item/weapon/ore/plasmastone
					if(9) ejecting = /obj/item/weapon/ore/uqill
					if(10) ejecting = /obj/item/weapon/ore/telecrystal
					if(11) ejecting = /obj/item/weapon/ore/fabric
					else
						usr << "\red Error. Unknown ore type."
						return
				sleep(3)
				ejectamt = input(usr,"How many units do you want to eject?","Eject Materials") as num
				for(var/obj/item/weapon/ore/O in src.contents)
					if (ejectamt <= 0) break
					if (istype(O, ejecting))
						O.loc = usr.loc
						ejectamt--

			if (href_list["disp"])
				if (src.electrified) src.manuf_zap(usr, 33)
				var/datum/manufacture/I = locate(href_list["disp"])
				// Material Check
				var/A1 = 0
				var/A2 = 0
				var/A3 = 0
				for(var/obj/item/weapon/ore/O in src.contents)
					if (istype(O,I.cost1)) A1++
					if (istype(O,I.cost2)) A2++
					if (istype(O,I.cost3)) A3++
				if (A1 < I.amount1 || A2 < I.amount2 || A3 < I.amount3)
					usr << "\red Insufficient materials to manufacture that item."
					return
				// Consume Mats
				var/C1 = I.amount1
				var/C2 = I.amount2
				var/C3 = I.amount3
				for(var/obj/item/weapon/ore/O in src.contents)
					if (istype(O,I.cost1) && C1)
						del O
						C1--
					if (istype(O,I.cost2) && C2)
						del O
						C2--
					if (istype(O,I.cost3) && C3)
						del O
						C3--
				// Manufacture Item
				src.icon_state = "fab-active"
				src.working = 1
				var/worktime = I.time * 10
				var/powconsume = 1500
				/*for(var/i = robotics_research.starting_tier, i <= robotics_research.max_tiers, i++)
					for(var/datum/roboresearch/a in robotics_research.researched_items[i])
						if (a.manubonus)
							worktime -= a.timebonus
							if (a.multiplier != 0) worktime /= a.multiplier
							powconsume -= a.powbonus*/
				if (worktime < 1) worktime = 1
				src.powconsumption = powconsume
				if (src.malfunction)
					for(var/mob/O in viewers(src, null)) O.show_message(text("\red [] starts making a horrible grinding noise!", src), 1)
					src.powconsumption += 3000
					worktime += 3
					worktime *= 3
				src.updateUsrDialog()
				sleep(worktime)
				var/make = I.create
				while (make > 0)
					new I.item(src.loc)
					make--
				src.working = 0
				src.icon_state = "fab-idle"
				src.updateUsrDialog()

			if ((href_list["cutwire"]) && (src.panelopen))
				if (src.electrified) src.manuf_zap(usr, 100)
				var/twire = text2num(href_list["cutwire"])
				/*if (istype(usr, /mob/living/silicon))
					if (usr:modtype == "Eng")
						if (src.isWireColorCut(twire))
							src.mend(twire)
						else
							src.cut(twire)*/
				if (!( istype(usr.equipped(), /obj/item/weapon/wirecutters) ))		//Was an else if
					usr << "You need wirecutters!"
					return
				else if (src.isWireColorCut(twire))
					src.mend(twire)
				else
					src.cut(twire)

			if ((href_list["pulsewire"]) && (src.panelopen))
				if (src.electrified) src.manuf_zap(usr, 100)
				var/twire = text2num(href_list["pulsewire"])
				/*if (istype(usr, /mob/living/silicon))
					if (usr:modtype == "Eng")
						if (src.isWireColorCut(twire))
							usr << "You can't pulse a cut wire."
							return
						else
							src.pulse(twire)
							src.updateUsrDialog()
						return*/
				if (!istype(usr.equipped(), /obj/item/device/multitool))	//Was an else if
					usr << "You need a multitool!"
					return
				else if (src.isWireColorCut(twire))
					usr << "You can't pulse a cut wire."
					return
				else
					src.pulse(twire)

			src.updateUsrDialog()
		return

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		var/load = 0
		if(istype(W, /obj/item/weapon/ore/))
			if (!W:manuaccept) user << "\red This type of mineral is not usable as building materials."
			else
				for(var/mob/O in viewers(user, null)) O.show_message(text("\blue [] loads [] into the [].", user, W, src), 1)
				load = 1
		else if(istype(W, /obj/item/weapon/sheet/))
			for(var/mob/O in viewers(user, null)) O.show_message(text("\blue [] loads [] into the [].", user, W, src), 1)
			if(istype(W, /obj/item/weapon/sheet/metal))
				for (var/amt = W:amount, amt > 0, amt--) new /obj/item/weapon/ore/mauxite(src)
			if(istype(W, /obj/item/weapon/sheet/r_metal))
				for (var/amt = W:amount, amt > 0, amt--)
					new /obj/item/weapon/ore/mauxite(src)
					new /obj/item/weapon/ore/mauxite(src)
			if(istype(W, /obj/item/weapon/sheet/glass))
				for (var/amt = W:amount, amt > 0, amt--) new /obj/item/weapon/ore/molitz(src)
			if(istype(W, /obj/item/weapon/sheet/rglass))
				for (var/amt = W:amount, amt > 0, amt--)
					new /obj/item/weapon/ore/mauxite(src)
					new /obj/item/weapon/ore/molitz(src)
			load = 2
		else if (istype(W, /obj/item/weapon/plant/wheat/metal))
			new /obj/item/weapon/ore/mauxite(src)
			load = 2
		/*else if(istype(W, /obj/item/weapon/cable_coil/))
			for(var/mob/O in viewers(user, null)) O.show_message(text("\blue [] loads [] into the [].", user, W, src), 1)
			for (var/amt = W:amount, amt > 0, amt--)
				new /obj/item/weapon/ore/pharosium(src)
				amt--
			load = 2*/
		else if(istype(W, /obj/item/weapon/shard))
			new /obj/item/weapon/ore/molitz(src)
			load = 2
		else if(istype(W, /obj/item/weapon/shard/crystal))
			if (prob(80)) new /obj/item/weapon/ore/molitz(src)
			else new /obj/item/weapon/ore/plasmastone(src)
			load = 2
		else if(istype(W, /obj/item/weapon/rods))
			for (var/amt = W:amount, amt > 0, amt--) new /obj/item/weapon/ore/mauxite(src)
			load = 2
		else if(istype(W, /obj/item/clothing/))
			if(istype(W, /obj/item/clothing/under/))
				new /obj/item/weapon/ore/fabric(src)
				load = 2
			if(istype(W, /obj/item/clothing/suit/))
				if(!istype(W,/obj/item/clothing/suit/armor) && !istype(W,/obj/item/clothing/suit/cyborg_suit) && !istype(W,/obj/item/clothing/suit/swat_suit))
					new /obj/item/weapon/ore/fabric(src)
					new /obj/item/weapon/ore/fabric(src)
					if(istype(W,/obj/item/clothing/suit/space/)) new /obj/item/weapon/ore/fabric(src)
					load = 2
		else if(istype(W, /obj/item/weapon/disk/data/schematic))
			if (!src.acceptdisk) user << "\red This unit is unable to accept disks."
			else
				var/amtload = 0
				var/dontload = 0
				for (var/datum/manufacture/WS in W:schematics)
					for (var/datum/manufacture/A in src.available)
						if (istype(WS,A)) dontload = 1
					for (var/datum/manufacture/B in src.download)
						if (istype(WS,B)) dontload = 1
					for (var/datum/manufacture/C in src.diskload)
						if (istype(WS,C)) dontload = 1
					for (var/datum/manufacture/D in src.hidden)
						if (istype(WS,D) && src.hacked) dontload = 1
					if (!dontload)
						src.diskload += new WS.type(src)
						amtload++
					else dontload = 0
				if (amtload) user << "\blue [amtload] new schematics downloaded from disk."
				else user << "\red No new schematics available on disk."
			if (src.electrified) src.manuf_zap(usr, 66)
		else if (istype(W, /obj/item/weapon/satchel/mining))
			for(var/mob/V in viewers(user, null)) V.show_message(text("\blue [] uses the []'s automatic ore loader on []!", user, src, W), 1)
			var/amtload = 0
			for (var/obj/item/weapon/ore/M in W.contents)
				if (!M.manuaccept) continue
				M.loc = src
				amtload++
			if (amtload) user << "\blue [amtload] pieces of ore loaded from [W]!"
			else user << "\red No ore loaded!"
		else if(istype(W, /obj/item/weapon/card/emag))
			src.hacked = 1
			user << "\blue You remove the [src]'s product locks!"
		else if(istype(W, /obj/item/weapon/screwdriver))
			if (src.electrified)
				src.manuf_zap(usr, 100)
			if (!src.panelopen)
				src.overlays += image('surgery.dmi', "fab-panel")
				src.panelopen = 1
			else
				src.overlays = null
				src.panelopen = 0
			user << "You [src.panelopen ? "open" : "close"] the maintenance panel."
		else ..()

		if (load == 1)
			user.u_equip(W)
			W.loc = src
			if ((user.client && user.s_active != src))
				user.client.screen -= W
			W.dropped()
		else if (load == 2)
			user.u_equip(W)
			W.dropped()
			if ((user.client && user.s_active != src))
				user.client.screen -= W
			del W

		src.updateUsrDialog()

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (istype(O, /obj/crate/))
			for(var/mob/V in viewers(user, null)) V.show_message(text("\blue [] uses the []'s automatic ore loader on []!", user, src, O), 1)
			var/amtload = 0
			for (var/obj/item/weapon/ore/M in O.contents)
				if (!M.manuaccept) continue
				M.loc = src
				amtload++
			if (amtload) user << "\blue [amtload] pieces of ore loaded from [O]!"
			else user << "\red No ore loaded!"
		else if (istype(O, /obj/item/weapon/ore/))
			for(var/mob/V in viewers(user, null)) V.show_message(text("\blue [] begins quickly stuffing ore into []!", user, src), 1)
			var/staystill = user.loc
			for(var/obj/item/weapon/ore/M in view(1,user))
				if (!M.manuaccept) continue
				if (istype(M, /obj/item/weapon/ore/cerenkite) && user.mining_radcheck(user) == 0) user.radiation += 10
				M.loc = src
				sleep(3)
				if (user.loc != staystill) break
			user << "\blue You finish stuffing ore into [src]!"
		else if (istype(O, /obj/item/weapon/plant/wheat/metal))
			for(var/mob/V in viewers(user, null)) V.show_message(text("\blue [] begins quickly stuffing [O] into []!", user, src), 1)
			var/staystill = user.loc
			for(var/obj/item/weapon/plant/wheat/metal/M in view(1,user))
				new /obj/item/weapon/ore/mauxite(src)
				del M
				sleep(3)
				if (user.loc != staystill) break
			user << "\blue You finish stuffing [O] into [src]!"
		else ..()
		src.updateUsrDialog()

	// Hacking stuff

	proc/isWireColorCut(var/wireColor)
		var/wireFlag = APCWireColorToFlag[wireColor]
		return ((src.wires & wireFlag) == 0)

	proc/isWireCut(var/wireIndex)
		var/wireFlag = APCIndexToFlag[wireIndex]
		return ((src.wires & wireFlag) == 0)

	proc/cut(var/wireColor)
		var/wireFlag = APCWireColorToFlag[wireColor]
		var/wireIndex = APCWireColorToIndex[wireColor]
		src.wires &= ~wireFlag
		switch(wireIndex)
			if(WIRE_EXTEND) src.hacked = 0
			if(WIRE_SHOCK) src.electrified = -1
			if(WIRE_DISK) src.acceptdisk = 0
			if(WIRE_MALF) src.malfunction = 1

	proc/mend(var/wireColor)
		var/wireFlag = APCWireColorToFlag[wireColor]
		var/wireIndex = APCWireColorToIndex[wireColor] //not used in this function
		src.wires |= wireFlag
		switch(wireIndex)
			if(WIRE_SHOCK) src.electrified = 0
			if(WIRE_MALF) src.malfunction = 0

	proc/pulse(var/wireColor)
		var/wireIndex = APCWireColorToIndex[wireColor]
		switch(wireIndex)
			if(WIRE_EXTEND)
				if (src.hacked) src.hacked = 0
				else src.hacked = 1
			if (WIRE_SHOCK) src.electrified = 30
			if (WIRE_DISK)
				if (src.acceptdisk) src.acceptdisk = 0
				else src.acceptdisk = 1
			if (WIRE_MALF)
				if (src.malfunction) src.malfunction = 0
				else src.malfunction = 1

	proc/manuf_zap(mob/user, prb)
		if(istype(user, /mob/living/silicon/)) return
		if(!prob(prb)) return
		if(src.stat & (BROKEN|NOPOWER))	return
		if(istype(user, /mob/living/carbon/human/))
			if (istype(user:gloves, /obj/item/clothing/gloves/yellow)) return
		/*for(var/datum/power/resist_electric/E in user.powers)
			if (E.variant == 2)
				user.fireloss -= 15
				user.bruteloss -= 15
				user.toxloss -= 15
				user << "\blue You absorb the electrical shock, healing your body!"
				return
			else
				user << "\blue You feel electricity course through you harmlessly!"
				return*/
		var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
		s.set_up(5, 1, usr)
		s.start()
		user << "\red You are shocked by [src]!"
		user.fireloss += 15
		user.stunned += 20
		user.weakened += 20

/obj/item/weapon/disk/data/schematic
	name = "Manufacturer Schematic Disk"
	desc = "Contains schematics for use in a Manufacturing Unit."
	var/list/schematics = list()

	New()
		..()
		//debuggin'
		src.schematics += new /datum/manufacture/screwdriver(src)

// Fabricator Defines

/obj/machinery/manufacturer/general
	name = "General Manufacturer"
	desc = "A manufacturing unit calibrated to produce tools and general purpose items."

	New()
		..()
		src.available += new /datum/manufacture/screwdriver(src)
		src.available += new /datum/manufacture/wirecutters(src)
		src.available += new /datum/manufacture/wrench(src)
		src.available += new /datum/manufacture/crowbar(src)
		src.available += new /datum/manufacture/extinguisher(src)
		src.available += new /datum/manufacture/welder(src)
		src.available += new /datum/manufacture/weldingmask(src)
		src.available += new /datum/manufacture/multitool(src)
		src.available += new /datum/manufacture/metal5(src)
		src.available += new /datum/manufacture/metalR(src)
		src.available += new /datum/manufacture/glass5(src)
		src.available += new /datum/manufacture/glassR(src)
		src.available += new /datum/manufacture/atmos_can(src)
		//src.available += new /datum/manufacture/cable(src)
		src.available += new /datum/manufacture/light_bulb(src)
		src.available += new /datum/manufacture/light_tube(src)
		src.available += new /datum/manufacture/breathmask(src)
		src.available += new /datum/manufacture/RCDammo(src)
		src.available += new /datum/manufacture/cola_bottle(src)
		//src.hidden += new /datum/manufacture/vuvuzela(src)
		//src.hidden += new /datum/manufacture/harmonica(src)
		src.hidden += new /datum/manufacture/bikehorn(src)
		//src.hidden += new /datum/manufacture/stunrounds

/obj/machinery/manufacturer/robotics
	name = "Robotics Fabricator"
	desc = "A manufacturing unit calibrated to produce robot-related equipment."
	acceptdisk = 1
	dl_list = "robotics"

	New()
		..()
		src.available += new /datum/manufacture/robo_frame(src)
		src.available += new /datum/manufacture/robo_head(src)
		src.available += new /datum/manufacture/robo_chest(src)
		src.available += new /datum/manufacture/robo_arm_r(src)
		src.available += new /datum/manufacture/robo_arm_l(src)
		src.available += new /datum/manufacture/robo_leg_r(src)
		src.available += new /datum/manufacture/robo_leg_l(src)
		src.available += new /datum/manufacture/robo_stmodule(src)
		//src.available += new /datum/manufacture/cable(src)
		src.available += new /datum/manufacture/powercell(src)
		src.available += new /datum/manufacture/crowbar(src)
		src.available += new /datum/manufacture/scalpel(src)
		src.available += new /datum/manufacture/circular_saw(src)
		src.available += new /datum/manufacture/implanter
		src.hidden += new /datum/manufacture/flash(src)

/obj/machinery/manufacturer/mining
	name = "Mining Fabricator"
	desc = "A manufacturing unit calibrated to produce mining related equipment."
	acceptdisk = 1

	New()
		..()
		src.available += new /datum/manufacture/pick(src)
		src.available += new /datum/manufacture/powerpick(src)
		src.available += new /datum/manufacture/blastchargeslite(src)
		src.available += new /datum/manufacture/blastcharges(src)
		src.available += new /datum/manufacture/powerhammer(src)
		src.available += new /datum/manufacture/drill(src)
		src.available += new /datum/manufacture/cutter(src)
		src.available += new /datum/manufacture/breathmask(src)
		src.available += new /datum/manufacture/spacesuit(src)
		src.available += new /datum/manufacture/spacehelm(src)
		src.available += new /datum/manufacture/oresatchel(src)
		src.available += new /datum/manufacture/jetpack(src)
		src.available += new /datum/manufacture/geoscanner(src)
		src.available += new /datum/manufacture/eyes_meson(src)
		src.available += new /datum/manufacture/miningbelt(src)
		//src.available += new /datum/manufacture/rigsuit(src)
		//src.available += new /datum/manufacture/righelm(src)
		src.hidden += new /datum/manufacture/RCD(src)
		src.hidden += new /datum/manufacture/RCDammo(src)

// Schematic Defines
// General/Miscellaneous

/datum/manufacture/crowbar
	name = "Crowbar"
	item = /obj/item/weapon/crowbar
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 1
	time = 5
	create = 1

/datum/manufacture/screwdriver
	name = "Screwdriver"
	item = /obj/item/weapon/screwdriver
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 1
	time = 5
	create = 1

/datum/manufacture/wirecutters
	name = "Wirecutters"
	item = /obj/item/weapon/wirecutters
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 1
	time = 5
	create = 1

/datum/manufacture/wrench
	name = "Wrench"
	item = /obj/item/weapon/wrench
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 1
	time = 5
	create = 1
/*
/datum/manufacture/vuvuzela
	name = "Vuvuzela"
	item = /obj/item/weapon/vuvuzela
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 1
	time = 5
	create = 1

/datum/manufacture/harmonica
	name = "Harmonica"
	item = /obj/item/weapon/harmonica
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 1
	time = 5
	create = 1
*/
/datum/manufacture/cola_bottle
	name = "Glass Bottle"
	item = /obj/item/weapon/reagent_containers/food/drinks/cola_bottle
	cost1 = /obj/item/weapon/ore/molitz
	cname1 = "Molitz"
	amount1 = 1
	time = 4
	create = 1

/datum/manufacture/bikehorn
	name = "Bicycle Horn"
	item = /obj/item/weapon/bikehorn
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 1
	time = 5
	create = 1
/*
/datum/manufacture/stunrounds
	name = ".38 Stunner Rounds"
	item = /obj/item/weapon/ammo/bullets/a38/stun
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 7
	cost2 = /obj/item/weapon/ore/pharosium
	cname2 = "Pharosium"
	amount2 = 3
	time = 25
	create = 1
*/
/datum/manufacture/extinguisher
	name = "Fire Extinguisher"
	item = /obj/item/weapon/extinguisher
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 1
	cost2 = /obj/item/weapon/ore/molitz
	cname2 = "Molitz"
	amount2 = 1
	time = 8
	create = 1

/datum/manufacture/welder
	name = "Welding Tool"
	item = /obj/item/weapon/weldingtool
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 1
	cost2 = /obj/item/weapon/ore/pharosium
	cname2 = "Pharosium"
	amount2 = 1
	time = 8
	create = 1

/datum/manufacture/multitool
	name = "Multi Tool"
	item = /obj/item/device/multitool
	cost1 = /obj/item/weapon/ore/molitz
	cname1 = "Molitz"
	amount1 = 1
	cost2 = /obj/item/weapon/ore/pharosium
	cname2 = "Pharosium"
	amount2 = 1
	time = 8
	create = 1

/datum/manufacture/weldingmask
	name = "Welding Mask"
	item = /obj/item/clothing/head/helmet/welding
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 2
	cost2 = /obj/item/weapon/ore/molitz
	cname2 = "Molitz"
	amount2 = 2
	time = 10
	create = 1

/datum/manufacture/light_bulb
	name = "Light Bulb"
	item = /obj/item/weapon/light/bulb
	cost1 = /obj/item/weapon/ore/molitz
	cname1 = "Molitz"
	amount1 = 1
	time = 4
	create = 1

/datum/manufacture/light_tube
	name = "Light Tube"
	item = /obj/item/weapon/light/tube
	cost1 = /obj/item/weapon/ore/molitz
	cname1 = "Molitz"
	amount1 = 1
	time = 4
	create = 1

/datum/manufacture/metal5
	name = "Sheet Metal (x5)"
	item = /obj/item/weapon/sheet/metal
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 5
	time = 8
	create = 5

/datum/manufacture/metalR
	name = "Reinforced Metal"
	item = /obj/item/weapon/sheet/r_metal
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 2
	time = 12
	create = 1

/datum/manufacture/glass5
	name = "Glass Panel (x5)"
	item = /obj/item/weapon/sheet/glass
	cost1 = /obj/item/weapon/ore/molitz
	cname1 = "Molitz"
	amount1 = 5
	time = 8
	create = 5

/datum/manufacture/glassR
	name = "Reinforced Glass Panel"
	item = /obj/item/weapon/sheet/rglass
	cost1 = /obj/item/weapon/ore/molitz
	cname1 = "Molitz"
	amount1 = 1
	cost2 = /obj/item/weapon/ore/mauxite
	cname2 = "Mauxite"
	amount2 = 1
	time = 12
	create = 1

/datum/manufacture/atmos_can
	name = "Portable Gas Canister"
	item = /obj/machinery/portable_atmospherics/canister
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 2
	time = 10
	create = 1

/datum/manufacture/miningbelt
	name = "Mining Belt"
	item = /obj/item/weapon/storage/miningbelt
	cost1 = /obj/item/weapon/ore/fabric
	cname1 = "Fabric"
	amount1 = 1
	time = 5
	create = 1

/*
/datum/manufacture/cable
	name = "Electrical Cable Piece"
	item = /obj/item/weapon/cable_coil/cut
	cost1 = /obj/item/weapon/ore/pharosium
	cname1 = "Pharosium"
	amount1 = 1
	time = 3
	create = 1
*/
/datum/manufacture/RCD
	name = "Rapid Construction Device"
	item = /obj/item/weapon/rcd
	cost1 = /obj/item/weapon/ore/bohrum
	cname1 = "Bohrum"
	amount1 = 5
	cost2 = /obj/item/weapon/ore/uqill
	cname2 = "Uqill"
	amount2 = 1
	cost3 = /obj/item/weapon/ore/pharosium
	cname3 = "Pharosium"
	amount3 = 10
	time = 90
	create = 1

/datum/manufacture/RCDammo
	name = "Compressed Matter Cartridge"
	item = /obj/item/weapon/rcd_ammo
	cost1 = /obj/item/weapon/ore/uqill
	cname1 = "Uqill"
	amount1 = 1
	time = 15
	create = 1


/******************** Robotics **************************/

/datum/manufacture/robo_frame
	name = "Cyborg Frame"
	item = /obj/item/robot_parts/robot_suit
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 18
	time = 45
	create = 1

/datum/manufacture/robo_chest
	name = "Cyborg Chest"
	item = /obj/item/robot_parts/chest
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 12
	time = 30
	create = 1

/datum/manufacture/robo_head
	name = "Cyborg Head"
	item = /obj/item/robot_parts/head
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 12
	time = 30
	create = 1

/datum/manufacture/robo_arm_r
	name = "Cyborg Arm (Right)"
	item = /obj/item/robot_parts/r_arm
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 6
	time = 15
	create = 1

/datum/manufacture/robo_arm_l
	name = "Cyborg Arm (Left)"
	item = /obj/item/robot_parts/l_arm
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 6
	time = 15
	create = 1

/datum/manufacture/robo_leg_r
	name = "Cyborg Leg (Right)"
	item = /obj/item/robot_parts/r_leg
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 6
	time = 15
	create = 1

/datum/manufacture/robo_leg_l
	name = "Cyborg Leg (Left)"
	item = /obj/item/robot_parts/l_leg
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 6
	time = 15
	create = 1

/datum/manufacture/robo_stmodule
	name = "Standard Cyborg Module"
	item = /obj/item/weapon/robot_module/standard
	cost1 = /obj/item/weapon/ore/pharosium
	cname1 = "Pharosium"
	amount1 = 2
	cost2 = /obj/item/weapon/ore/molitz
	cname2 = "Molitz"
	amount2 = 3
	time = 40
	create = 1

/datum/manufacture/scalpel
	name = "Scalpel"
	item = /obj/item/weapon/scalpel
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 1
	time = 5
	create = 1

/datum/manufacture/circular_saw
	name = "Circular Saw"
	item = /obj/item/weapon/circular_saw
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 1
	time = 5
	create = 1

/datum/manufacture/powercell
	name = "Power Cell"
	item = /obj/item/weapon/cell
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 4
	cost2 = /obj/item/weapon/ore/molitz
	cname2 = "Molitz"
	amount2 = 4
	cost3 = /obj/item/weapon/ore/pharosium
	cname3 = "Pharosium"
	amount3 = 4
	time = 30
	create = 1

/datum/manufacture/flash
	name = "Flash"
	item = /obj/item/device/flash
	cost1 = /obj/item/weapon/ore/molitz
	cname1 = "Molitz"
	amount1 = 2
	cost2 = /obj/item/weapon/ore/pharosium
	cname2 = "Pharosium"
	amount2 = 2
	time = 15
	create = 1



// Robotics Research

/datum/manufacture/implanter
	name = "Implanter"
	item = /obj/item/weapon/implanter
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 1
	time = 3
	create = 1

/datum/manufacture/secbot
	name = "Security Drone"
	item = /obj/machinery/bot/secbot
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 10
	cost2 = /obj/item/weapon/ore/pharosium
	cname2 = "Pharosium"
	amount2 = 5
	cost3 = /obj/item/weapon/ore/molitz
	cname3 = "Molitz"
	amount3 = 5
	time = 60
	create = 1

/datum/manufacture/floorbot
	name = "Construction Drone"
	item = /obj/machinery/bot/floorbot
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 10
	cost2 = /obj/item/weapon/ore/pharosium
	cname2 = "Pharosium"
	amount2 = 5
	cost3 = /obj/item/weapon/ore/molitz
	cname3 = "Molitz"
	amount3 = 5
	time = 60
	create = 1

/datum/manufacture/medbot
	name = "Medical Drone"
	item = /obj/machinery/bot/medbot
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 10
	cost2 = /obj/item/weapon/ore/pharosium
	cname2 = "Pharosium"
	amount2 = 5
	cost3 = /obj/item/weapon/ore/molitz
	cname3 = "Molitz"
	amount3 = 5
	time = 60
	create = 1
/*
/datum/manufacture/firebot
	name = "Firefighting Drone"
	item = /obj/machinery/bot/firebot
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 10
	cost2 = /obj/item/weapon/ore/pharosium
	cname2 = "Pharosium"
	amount2 = 5
	cost3 = /obj/item/weapon/ore/molitz
	cname3 = "Molitz"
	amount3 = 5
	time = 60
	create = 1
*/
/datum/manufacture/cleanbot
	name = "Sanitation Drone"
	item = /obj/machinery/bot/cleanbot
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 10
	cost2 = /obj/item/weapon/ore/pharosium
	cname2 = "Pharosium"
	amount2 = 5
	cost3 = /obj/item/weapon/ore/molitz
	cname3 = "Molitz"
	amount3 = 5
	time = 60
	create = 1
/*
/datum/manufacture/robup_jetpack
	name = "Propulsion Upgrade"
	item = /obj/item/weapon/roboupgrade/jetpack
	cost1 = /obj/item/weapon/ore/pharosium
	cname1 = "Pharosium"
	amount1 = 3
	cost2 = /obj/item/weapon/ore/mauxite
	cname2 = "Mauxite"
	amount2 = 5
	time = 60
	create = 1

/datum/manufacture/robup_speed
	name = "Speed Upgrade"
	item = /obj/item/weapon/roboupgrade/speed
	cost1 = /obj/item/weapon/ore/pharosium
	cname1 = "Pharosium"
	amount1 = 3
	cost2 = /obj/item/weapon/ore/molitz
	cname2 = "Molitz"
	amount2 = 5
	time = 60
	create = 1

/datum/manufacture/robup_recharge
	name = "Recharge Pack"
	item = /obj/item/weapon/roboupgrade/rechargepack
	cost1 = /obj/item/weapon/ore/pharosium
	cname1 = "Pharosium"
	amount1 = 5
	time = 60
	create = 1

/datum/manufacture/robup_repairpack
	name = "Repair Pack"
	item = /obj/item/weapon/roboupgrade/repairpack
	cost1 = /obj/item/weapon/ore/pharosium
	cname1 = "Pharosium"
	amount1 = 5
	time = 60
	create = 1

/datum/manufacture/robup_physshield
	name = "Force Shield Upgrade"
	item = /obj/item/weapon/roboupgrade/physshield
	cost1 = /obj/item/weapon/ore/claretine
	cname1 = "Claretine"
	amount1 = 2
	cost2 = /obj/item/weapon/ore/mauxite
	cname2 = "Mauxite"
	amount2 = 10
	time = 90
	create = 1

/datum/manufacture/robup_fireshield
	name = "Heat Shield Upgrade"
	item = /obj/item/weapon/roboupgrade/fireshield
	cost1 = /obj/item/weapon/ore/claretine
	cname1 = "Claretine"
	amount1 = 2
	cost2 = /obj/item/weapon/ore/molitz
	cname2 = "Molitz"
	amount2 = 10
	time = 90
	create = 1

/datum/manufacture/robup_aware
	name = "Operational Upgrade"
	item = /obj/item/weapon/roboupgrade/aware
	cost1 = /obj/item/weapon/ore/claretine
	cname1 = "Claretine"
	amount1 = 2
	cost2 = /obj/item/weapon/ore/molitz
	cname2 = "Molitz"
	amount2 = 5
	cost3 = /obj/item/weapon/ore/pharosium
	cname3 = "Pharosium"
	amount3 = 5
	time = 90
	create = 1

/datum/manufacture/robup_efficiency
	name = "Efficiency Upgrade"
	item = /obj/item/weapon/roboupgrade/efficiency
	cost1 = /obj/item/weapon/ore/uqill
	cname1 = "Uqill"
	amount1 = 3
	cost2 = /obj/item/weapon/ore/claretine
	cname2 = "Claretine"
	amount2 = 10
	time = 120
	create = 1

/datum/manufacture/robup_repair
	name = "Self-Repair Upgrade"
	item = /obj/item/weapon/roboupgrade/repair
	cost1 = /obj/item/weapon/ore/uqill
	cname1 = "Uqill"
	amount1 = 3
	cost2 = /obj/item/weapon/ore/bohrum
	cname2 = "Bohrum"
	amount2 = 10
	time = 120
	create = 1

/datum/manufacture/robup_teleport
	name = "Teleport Upgrade"
	item = /obj/item/weapon/roboupgrade/teleport
	cost1 = /obj/item/weapon/ore/uqill
	cname1 = "Uqill"
	amount1 = 3
	cost2 = /obj/item/weapon/ore/telecrystal
	cname2 = "Telecrystal"
	amount2 = 2
	time = 120
	create = 1

/datum/manufacture/robup_expand
	name = "Expansion Upgrade"
	item = /obj/item/weapon/roboupgrade/expand
	cost1 = /obj/item/weapon/ore/uqill
	cname1 = "Uqill"
	amount1 = 3
	cost2 = /obj/item/weapon/ore/cerenkite
	cname2 = "Cerenkite"
	amount2 = 1
	time = 120
	create = 1

/datum/manufacture/robup_chargexpand
	name = "Charge Expander Upgrade"
	item = /obj/item/weapon/roboupgrade/chargeexpand
	cost1 = /obj/item/weapon/ore/claretine
	cname1 = "Claretine"
	amount1 = 5
	time = 70
	create = 1

/datum/manufacture/robup_meson
	name = "Optical Meson Upgrade"
	item = /obj/item/weapon/roboupgrade/opticmeson
	cost1 = /obj/item/weapon/ore/molitz
	cname1 = "Molitz"
	amount1 = 2
	cost2 = /obj/item/weapon/ore/pharosium
	cname2 = "Pharosium"
	amount2 = 4
	time = 90
	create = 1

/datum/manufacture/robup_thermal
	name = "Optical Thermal Upgrade"
	item = /obj/item/weapon/roboupgrade/opticthermal
	cost1 = /obj/item/weapon/ore/molitz
	cname1 = "Molitz"
	amount1 = 4
	cost2 = /obj/item/weapon/ore/pharosium
	cname2 = "Pharosium"
	amount2 = 8
	time = 90
	create = 1

/datum/manufacture/deafhs
	name = "Auditory Headset"
	item = /obj/item/device/radio/headset/deaf
	cost1 = /obj/item/weapon/ore/pharosium
	cname1 = "Pharosium"
	amount1 = 3
	cost2 = /obj/item/weapon/ore/molitz
	cname2 = "Molitz"
	amount2 = 3
	time = 40
	create = 1

/datum/manufacture/visor
	name = "VISOR Prosthesis"
	item = /obj/item/clothing/glasses/visor
	cost1 = /obj/item/weapon/ore/pharosium
	cname1 = "Pharosium"
	amount1 = 3
	cost2 = /obj/item/weapon/ore/molitz
	cname2 = "Molitz"
	amount2 = 3
	time = 40
	create = 1

/datum/manufacture/implant_robotalk
	name = "Machine Translator Implant"
	item = /obj/item/weapon/implantcase/robotalk
	cost1 = /obj/item/weapon/ore/pharosium
	cname1 = "Pharosium"
	amount1 = 3
	cost2 = /obj/item/weapon/ore/molitz
	cname2 = "Molitz"
	amount2 = 3
	time = 40
	create = 1

/datum/manufacture/implant_bloodmonitor
	name = "Blood Monitor Implant"
	item = /obj/item/weapon/implantcase/bloodmonitor
	cost1 = /obj/item/weapon/ore/pharosium
	cname1 = "Pharosium"
	amount1 = 3
	cost2 = /obj/item/weapon/ore/molitz
	cname2 = "Molitz"
	amount2 = 3
	time = 40
	create = 1
*/
// Mining Gear

/datum/manufacture/pick
	name = "Pickaxe"
	item = /obj/item/weapon/pickaxe
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 1
	time = 5
	create = 1

/datum/manufacture/powerpick
	name = "Powered Pick"
	item = /obj/item/weapon/pickaxe/powered
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 3
	cost2 = /obj/item/weapon/ore/pharosium
	cname2 = "Pharosium"
	amount2 = 5
	time = 10
	create = 1

/datum/manufacture/blastchargeslite
	name = "Low-Yield Mining Explosives (x5)"
	item = /obj/item/weapon/breaching_charge/mining/light
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 5
	cost1 = /obj/item/weapon/ore/molitz
	cname1 = "Molitz"
	amount1 = 5
	cost3 = /obj/item/weapon/ore/pharosium
	cname3 = "Pharosium"
	amount3 = 10
	time = 40
	create = 5

/datum/manufacture/blastcharges
	name = "Mining Explosives (x5)"
	item = /obj/item/weapon/breaching_charge/mining
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 10
	cost1 = /obj/item/weapon/ore/molitz
	cname1 = "Molitz"
	amount1 = 10
	cost3 = /obj/item/weapon/ore/pharosium
	cname3 = "Pharosium"
	amount3 = 20
	time = 60
	create = 5

/datum/manufacture/powerhammer
	name = "Power Hammer"
	item = /obj/item/weapon/powerhammer
	cost1 = /obj/item/weapon/ore/bohrum
	cname1 = "Bohrum"
	amount1 = 7
	cost2 = /obj/item/weapon/ore/pharosium
	cname2 = "Pharosium"
	amount2 = 12
	time = 70
	create = 1

/datum/manufacture/drill
	name = "Laser Drill"
	item = /obj/item/weapon/drill
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 20
	cost1 = /obj/item/weapon/ore/bohrum
	cname1 = "Bohrum"
	amount1 = 10
	cost3 = /obj/item/weapon/ore/claretine
	cname3 = "Claretine"
	amount3 = 15
	time = 90
	create = 1

/datum/manufacture/cutter
	name = "Plasma Cutter"
	item = /obj/item/weapon/cutter
	cost1 = /obj/item/weapon/ore/bohrum
	cname1 = "Bohrum"
	amount1 = 20
	cost2 = /obj/item/weapon/ore/claretine
	cname2 = "Claretine"
	amount2 = 20
	cost3 = /obj/item/weapon/ore/erebite
	cname3 = "Erebite"
	amount3 = 5
	time = 120
	create = 1

/datum/manufacture/eyes_meson
	name = "Optical Meson Scanner"
	item = /obj/item/clothing/glasses/meson
	cost1 = /obj/item/weapon/ore/molitz
	cname1 = "Molitz"
	amount1 = 3
	cost2 = /obj/item/weapon/ore/pharosium
	cname2 = "Pharosium"
	amount2 = 2
	time = 10
	create = 1

/datum/manufacture/geoscanner
	name = "Geological Scanner"
	item = /obj/item/weapon/oreprospector
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 1
	cost2 = /obj/item/weapon/ore/pharosium
	cname2 = "Pharosium"
	amount2 = 1
	cost3 = /obj/item/weapon/ore/molitz
	cname3 = "Molitz"
	amount3 = 1
	time = 8
	create = 1
/*
/datum/manufacture/rigsuit
	name = "RIG Suit"
	item = /obj/item/clothing/suit/space/engineering_rig
	cost1 = /obj/item/weapon/ore/bohrum
	cname1 = "Bohrum"
	amount1 = 20
	cost2 = /obj/item/weapon/ore/uqill
	cname2 = "Uqill"
	amount2 = 5
	time = 90
	create = 1

/datum/manufacture/righelm
	name = "RIG Helmet"
	item = /obj/item/clothing/head/helmet/space/rig
	cost1 = /obj/item/weapon/ore/bohrum
	cname1 = "Bohrum"
	amount1 = 10
	cost2 = /obj/item/weapon/ore/cerenkite
	cname2 = "Cerenkite"
	amount2 = 3
	time = 90
	create = 1
*/
/datum/manufacture/breathmask
	name = "Breath Mask"
	item = /obj/item/clothing/mask/breath
	cost1 = /obj/item/weapon/ore/fabric
	cname1 = "Fabric"
	amount1 = 1
	time = 5
	create = 1

/datum/manufacture/spacesuit
	name = "Space Suit"
	item = /obj/item/clothing/suit/space
	cost1 = /obj/item/weapon/ore/fabric
	cname1 = "Fabric"
	amount1 = 3
	cost2 = /obj/item/weapon/ore/mauxite
	cname2 = "Mauxite"
	amount2 = 3
	time = 15
	create = 1

/datum/manufacture/spacehelm
	name = "Space Helmet"
	item = /obj/item/clothing/head/helmet/space
	cost1 = /obj/item/weapon/ore/fabric
	cname1 = "Fabric"
	amount1 = 2
	cost2 = /obj/item/weapon/ore/molitz
	cname2 = "Molitz"
	amount2 = 2
	time = 10
	create = 1

/datum/manufacture/oresatchel
	name = "Ore Satchel"
	item = /obj/item/weapon/satchel/mining
	cost1 = /obj/item/weapon/ore/fabric
	cname1 = "Fabric"
	amount1 = 5
	time = 5
	create = 1

/datum/manufacture/jetpack
	name = "Jetpack"
	item = /obj/item/weapon/tank/jetpack
	cost1 = /obj/item/weapon/ore/bohrum
	cname1 = "Bohrum"
	amount1 = 2
	cost2 = /obj/item/weapon/ore/pharosium
	cname2 = "Pharosium"
	amount2 = 10
	time = 60
	create = 1