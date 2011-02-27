var
	hsboxspawn = 1
	list
		hrefs = list(
					"hsbsuit" = "Suit Up (Space Travel Gear)",
					"hsbmetal" = "Spawn 50 Metal",
					"hsbglass" = "Spawn 50 Glass",
					"hsbairlock" = "Spawn Airlock",
					"hsbregulator" = "Spawn Air Regulator",
					"hsbfilter" = "Spawn Air Filter",
					"hsbcanister" = "Spawn Canister",
					"hsbfueltank" = "Spawn Welding Fuel Tank",
					"hsbwater	tank" = "Spawn Water Tank",
					"hsbtoolbox" = "Spawn Toolbox",
					"hsbmedkit" = "Spawn Medical Kit")

mob
	var
		datum/hSB/sandbox = null
	proc
		CanBuild()
			if(master_mode == "sandbox")
				sandbox = new/datum/hSB
				sandbox.owner = src.ckey
				if(src.client.holder)
					sandbox.admin = 1
				verbs += new/mob/proc/sandbox_panel
		sandbox_panel()
			if(sandbox)
				sandbox.update()

datum/hSB
	var
		owner = null
		admin = 0
		create_object_nonadmin_html = null
	proc
		update()
			var/hsbpanel = "<center><b>h_Sandbox Panel</b></center><hr>"
			if(admin)
				hsbpanel += "<b>Administration Tools:</b><br>"
				hsbpanel += "- <a href=\"?\ref[src];hsb=hsbtobj\">Toggle Object Spawning</a><br><br>"
			hsbpanel += "<b>Regular Tools:</b><br>"
			for(var/T in hrefs)
				hsbpanel += "- <a href=\"?\ref[src];hsb=[T]\">[hrefs[T]]</a><br>"
			if(hsboxspawn)
				hsbpanel += "- <a href=\"?\ref[src];hsb=hsbobj\">Spawn Object</a><br><br>"
			usr << browse(hsbpanel, "window=hsbpanel")
	Topic(href, href_list)
		if(!(src.owner == usr.ckey)) return
		if(!usr) return //I guess this is possible if they log out or die with the panel open? It happened.
		if(href_list["hsb"])
			switch(href_list["hsb"])
				if("hsbtobj")
					if(!admin) return
					if(hsboxspawn)
						world << "<b>Sandbox:  [usr.key] has disabled object spawning!</b>"
						hsboxspawn = 0
						return
					if(!hsboxspawn)
						world << "<b>Sandbox:  [usr.key] has enabled object spawning!</b>"
						hsboxspawn = 1
						return
				if("hsbsuit")
					var/mob/living/carbon/human/P = usr
					if(P.wear_suit)
						P.wear_suit.loc = P.loc
						P.wear_suit.layer = initial(P.wear_suit.layer)
						P.wear_suit = null
					P.wear_suit = new/obj/item/clothing/suit/space(P)
					P.wear_suit.layer = 20
					if(P.head)
						P.head.loc = P.loc
						P.head.layer = initial(P.head.layer)
						P.head = null
					P.head = new/obj/item/clothing/head/helmet/space(P)
					P.head.layer = 20
					if(P.wear_mask)
						P.wear_mask.loc = P.loc
						P.wear_mask.layer = initial(P.wear_mask.layer)
						P.wear_mask = null
					P.wear_mask = new/obj/item/clothing/mask/gas(P)
					P.wear_mask.layer = 20
					if(P.back)
						P.back.loc = P.loc
						P.back.layer = initial(P.back.layer)
						P.back = null
					P.back = new/obj/item/weapon/tank/jetpack(P)
					P.back.layer = 20
					P.internal = P.back
				if("hsbmetal")
					var/obj/item/weapon/sheet/hsb = new/obj/item/weapon/sheet/metal
					hsb.amount = 50
					hsb.loc = usr.loc
				if("hsbglass")
					var/obj/item/weapon/sheet/hsb = new/obj/item/weapon/sheet/glass
					hsb.amount = 50
					hsb.loc = usr.loc
				if("hsbairlock")
					var/obj/machinery/door/hsb = new/obj/machinery/door/airlock

					//TODO: DEFERRED make this better, with an HTML window or something instead of 15 popups
					hsb.req_access = list()
					var/accesses = get_all_accesses()
					for(var/A in accesses)
						if(alert(usr, "Will this airlock require [get_access_desc(A)] access?", "Sandbox:", "Yes", "No") == "Yes")
							hsb.req_access += A

					hsb.loc = usr.loc
					usr << "<b>Sandbox:  Created an airlock."
				if("hsbcanister")
					var/list/hsbcanisters = typesof(/obj/machinery/portable_atmospherics/canister/) - /obj/machinery/portable_atmospherics/canister/
					var/hsbcanister = input(usr, "Choose a canister to spawn.", "Sandbox:") in hsbcanisters + "Cancel"
					if(!(hsbcanister == "Cancel"))
						new hsbcanister(usr.loc)
				if("hsbfueltank")
					//var/obj/hsb = new/obj/weldfueltank
					//hsb.loc = usr.loc
				if("hsbwatertank")
					//var/obj/hsb = new/obj/watertank
					//hsb.loc = usr.loc
				if("hsbtoolbox")
					var/obj/item/weapon/storage/hsb = new/obj/item/weapon/storage/toolbox/mechanical
					for(var/obj/item/device/radio/T in hsb)
						del(T)
					new/obj/item/weapon/crowbar (hsb)
					hsb.loc = usr.loc
				if("hsbmedkit")
					var/obj/item/weapon/storage/firstaid/hsb = new/obj/item/weapon/storage/firstaid/regular
					hsb.loc = usr.loc
				if("hsbobj")

					if(!hsboxspawn) return

					var/list/selectable = list()
					for(var/O in typesof(/obj/item/))
					//Note, these istypes don't work
						if(istype(O, /obj/item/weapon/gun))
							continue
						if(istype(O, /obj/item/assembly))
							continue
						if(istype(O, /obj/item/weapon/camera))
							continue
						if(istype(O, /obj/item/weapon/cloaking_device))
							continue
						if(istype(O, /obj/item/weapon/dummy))
							continue
						if(istype(O, /obj/item/weapon/sword))
							continue
						if(istype(O, /obj/item/device/shield))
							continue
						selectable += O

					if (!create_object_nonadmin_html)
						var/objectjs
						objectjs = dd_list2text(selectable, ";")
						create_object_nonadmin_html = file2text('create_object.html')
						create_object_nonadmin_html = dd_replacetext(create_object_nonadmin_html, "null /* object types */", "\"[objectjs]\"")

					usr << browse(dd_replacetext(create_object_nonadmin_html, "/* ref src */", "\ref[src]"), "window=create_object;size=425x475")

		if (href_list["object_list"])
			var/atom/loc = usr.loc

			var/dirty_paths
			if (istext(href_list["object_list"]))
				dirty_paths = list(href_list["object_list"])
			else if (istype(href_list["object_list"], /list))
				dirty_paths = href_list["object_list"]

			var/paths = list()
			var/removed_paths = list()
			for (var/dirty_path in dirty_paths)
				var/path = text2path(dirty_path)
				if (!path)
					removed_paths += dirty_path
				else if (!ispath(path, /obj) && !ispath(path, /turf) && !ispath(path, /mob))
					removed_paths += dirty_path
				else if (ispath(path, /obj/item/weapon/gun/energy/pulse_rifle))
					removed_paths += dirty_path
				else
					paths += path

			if (!paths)
				return
			else if (length(paths) > 5)
				alert("Select less object types, jerko.")
				return
			else if (length(removed_paths))
				alert("Removed:\n" + dd_list2text(removed_paths, "\n"))

			var/list/offset = dd_text2list(href_list["offset"],",")
			var/number = dd_range(1, 100, text2num(href_list["object_count"]))
			var/X = offset.len > 0 ? text2num(offset[1]) : 0
			var/Y = offset.len > 1 ? text2num(offset[2]) : 0
			var/Z = offset.len > 2 ? text2num(offset[3]) : 0

			for (var/i = 1 to number)
				switch (href_list["offset_type"])
					if ("absolute")
						for (var/path in paths)
							new path(locate(0 + X,0 + Y,0 + Z))

					if ("relative")
						if (loc)
							for (var/path in paths)
								new path(locate(loc.x + X,loc.y + Y,loc.z + Z))
						else
							return

			if (number == 1)
				log_admin("[key_name(usr)] created a [english_list(paths)]")
				for(var/path in paths)
					if(ispath(path, /mob))
						message_admins("[key_name_admin(usr)] created a [english_list(paths)]", 1)
						break
			else
				log_admin("[key_name(usr)] created [number]ea [english_list(paths)]")
				for(var/path in paths)
					if(ispath(path, /mob))
						message_admins("[key_name_admin(usr)] created [number]ea [english_list(paths)]", 1)
						break
			return