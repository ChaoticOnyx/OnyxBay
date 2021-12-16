SUBSYSTEM_DEF(supply)
	name = "Supply"
	wait = 300 SECONDS
	priority = SS_PRIORITY_SUPPLY
	//Initializes at default time
	flags = SS_NO_TICK_CHECK

	var/illegal_alert_chance = 0
	//supply points // doloy pointy, just credits
	var/credits_per_process = 1500
	var/credits_per_slip = 200
	var/material_buy_prices = list(
		/material/platinum = 500,
		/material/plasma = 500
	) //Should only contain material datums, with values the profit per sheet sold.
	var/point_sources = list()
	//control
	var/ordernum
	var/list/shoppinglist = list()
	var/list/requestlist = list()
	var/list/donelist = list()
	var/list/master_supply_list = list()
	//shuttle movement
	var/movetime = 1200
	var/datum/shuttle/autodock/ferry/supply/shuttle
	//Material descriptions are added automatically; add to material_buy_prices instead.
	var/list/point_source_descriptions = list(
		"time"     = "Base station supply",
		"manifest" = "From exported manifests",
		"crate"    = "From exported crates",
		"virology" = "From uploaded antibody data",
		"gep"      = "From uploaded good explorer points",
		"cash"     = "From exported money",
		// If you're adding additional point sources, add it here in a new line. Don't forget to put a comma after the old last line.
	)
	var/datum/money_account/department_account = null

/datum/controller/subsystem/supply/Initialize()
	. = ..()
	ordernum = rand(1,9000)

	//Build master supply list
	for(var/decl/hierarchy/supply_pack/sp in cargo_supply_pack_root.children)
		if(sp.is_category())
			for(var/decl/hierarchy/supply_pack/spc in sp.children)
				master_supply_list += spc

	for(var/material_type in material_buy_prices)
		var/material/material = material_type //False typing
		var/material_name = initial(material.name)
		point_source_descriptions[material_name] = "From exported [material_name]"

	point_source_descriptions["total"] = "Total" // doing it here so it will be in the end

// Just add credits over time.
/datum/controller/subsystem/supply/fire()
	if(GAME_STATE < RUNLEVEL_GAME) // don't fire it yet as setup_economy() hasn't been called
		return
	add_credits_from_source(credits_per_process, "time")

/datum/controller/subsystem/supply/stat_entry()
	..(department_account ? "Credits: [department_account.money]" : "NO ACCOUNT")

//Supply-related helper procs.

/datum/controller/subsystem/supply/proc/add_credits_from_source(amount, source)
	//it would make a sense to stop supplying cargo account when it suspended but daaaaaaaamn anyway nobody can't withdraw anything from it in this case
	//and also i'm lazy to make cache and hooks for it
	var/reason
	switch(source)
		if("time")
			reason = "Base station supply"
		if("crate")
			reason = "Payment for exported crates"
		if("manifest")
			reason = "Payment for exported manifests"
		if("gep")
			reason = "Payment for exported survey disks" //lol it exists?
		if("virology")
			reason = "Payment for uploaded antibody data"
		if("cash")
			reason = "Payment for exported money"
		else //assume payment for selling valuable resources from material_buy_prices
			reason = "Payment for exported [source]"

	var/datum/transaction/T = new(SSsupply.department_account.owner_name, reason, amount, "NTGalaxyNet Terminal #[rand(111,1111)]")
	SSsupply.department_account.do_transaction(T)
	point_sources[source] += amount
	point_sources["total"] += amount

	//To stop things being sent to centcomm which should not be sent to centcomm. Recursively checks for these types.
/datum/controller/subsystem/supply/proc/forbidden_atoms_check(atom/A)
	if(istype(A,/mob/living))
		return 1
	if(istype(A,/obj/item/weapon/disk/nuclear))
		return 1
	if(istype(A,/obj/machinery/nuclearbomb))
		return 1
	if(istype(A,/obj/item/device/radio/beacon))
		return 1

	for(var/i=1, i<=A.contents.len, i++)
		var/atom/B = A.contents[i]
		if(.(B))
			return 1

/datum/controller/subsystem/supply/proc/sell()
	var/list/material_count = list()

	for(var/area/subarea in shuttle.shuttle_area)
		for(var/atom/movable/AM in subarea)
			if(AM.anchored)
				continue
			if(istype(AM, /obj/structure/closet/crate/))
				var/obj/structure/closet/crate/CR = AM
				callHook("sell_crate", list(CR, subarea))
				add_credits_from_source(CR.credits_per_crate, "crate")
				var/find_slip = 1

				for(var/atom in CR)
					// Sell manifests
					var/atom/A = atom
					if(find_slip && istype(A,/obj/item/weapon/paper/manifest))
						var/obj/item/weapon/paper/manifest/slip = A
						if(!slip.is_copy && slip.stamped && slip.stamped.len) //Any stamp works.
							add_credits_from_source(credits_per_slip, "manifest")
							find_slip = 0
						continue

					// Sell materials
					if(istype(A, /obj/item/stack))
						var/obj/item/stack/P = A
						var/material/material = P.get_material()
						if(material_buy_prices[material.type])
							material_count[material.type] += P.get_amount()
						continue

					// Must sell ore detector disks in crates
					if(istype(A, /obj/item/weapon/disk/survey))
						var/obj/item/weapon/disk/survey/D = A
						add_credits_from_source(round(D.Value() * 0.5), "gep")

					// sell cash
					if(istype(A, /obj/item/weapon/spacecash))
						var/obj/item/weapon/spacecash/cash = A
						add_credits_from_source(cash.worth, "cash")
			qdel(AM)

	if(material_count.len)
		for(var/material_type in material_count)
			var/profit = material_count[material_type] * material_buy_prices[material_type]
			var/material/material = material_type //False typing.
			add_credits_from_source(profit, initial(material.name))

// Alert crew to illegal items
/datum/controller/subsystem/supply/proc/alert_crew(chance, force = FALSE)
	var/announce = FALSE
	announce = prob(chance) || force
	if(announce)
		var/message = "Suspicious cargo shipment has been detected. Security intervention is recommended in the supply department."
		var/customname = "[GLOB.using_map.company_name] Cargo Security Departament"
		command_announcement.Announce(message, customname, new_sound = GLOB.using_map.command_report_sound, msg_sanitized = 1)

//Buyin
/datum/controller/subsystem/supply/proc/buy()
	if(!shoppinglist.len)
		return
	var/list/clear_turfs = list()

	for(var/area/subarea in shuttle.shuttle_area)
		for(var/turf/T in subarea)
			if(T.density)
				continue
			var/occupied = 0
			for(var/atom/A in T.contents)
				if(!A.simulated)
					continue
				occupied = 1
				break
			if(!occupied)
				clear_turfs += T
	for(var/S in shoppinglist)
		if(!clear_turfs.len)
			break
		var/turf/pickedloc = pick_n_take(clear_turfs)
		shoppinglist -= S
		donelist += S

		var/datum/supply_order/SO = S
		var/decl/hierarchy/supply_pack/SP = SO.object

		if(SP.contraband)
			illegal_alert_chance += 30
		else
			illegal_alert_chance += 5
		illegal_alert_chance = clamp(illegal_alert_chance, 0, 90)
		var/obj/A = new SP.containertype(pickedloc)
		A.SetName("[SP.containername][SO.comment ? " ([SO.comment])":"" ]")
		//supply manifest generation begin

		var/obj/item/weapon/paper/manifest/slip
		if(!SP.contraband)
			var/info = ""
			info +="<h3>[command_name()] Shipping Manifest</h3><hr><br>"
			info +="Order #[SO.ordernum]<br>"
			info +="Destination: [GLOB.using_map.station_name]<br>"
//			info +="[shoppinglist.len] PACKAGES IN THIS SHIPMENT<br>"
			info +="CONTENTS:<br><ul>"

			slip = new /obj/item/weapon/paper/manifest(A)
			slip.set_content(info, rawhtml = TRUE)
			slip.is_copy = 0

		//spawn the stuff, finish generating the manifest while you're at it
		if(SP.access)
			if(!islist(SP.access))
				A.req_access = list(SP.access)
			else if(islist(SP.access))
				var/list/L = SP.access // access var is a plain var, we need a list
				A.req_access = L.Copy()

		var/list/spawned = SP.spawn_contents(A)
		if(slip)
			for(var/atom/content in spawned)
				slip.info += "<li>[content.name]</li>" //add the item to the manifest
			slip.info += "</ul><br>CHECK CONTENTS AND STAMP BELOW THE LINE TO CONFIRM RECEIPT OF GOODS<hr>"
	alert_crew(illegal_alert_chance)
	illegal_alert_chance = 0

/datum/supply_order
	var/ordernum
	var/decl/hierarchy/supply_pack/object = null
	var/orderedby = null
	var/comment = null
	var/reason = null
	var/orderedrank = null //used for supply console printing
