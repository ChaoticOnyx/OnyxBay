#define NO_GUARANTEE_NO_EXTRA_COST_DESC(X) "Installs an uplink into " + X + " if, and only if, found on your person. Has no TC cost."

#define SETUP_FAILED TRUE

GLOBAL_LIST_INIT(default_uplink_source_priority, list(
	/decl/uplink_source/pda,
	/decl/uplink_source/radio,
	/decl/uplink_source/unit))

/decl/uplink_source
	var/name
	var/desc

/decl/uplink_source/proc/setup_uplink_source(mob/M, amount)
	return SETUP_FAILED

/decl/uplink_source/proc/check_source_setup(mob/M)
	return FALSE

/decl/uplink_source/pda
	name = "PDA"
	desc = NO_GUARANTEE_NO_EXTRA_COST_DESC("a PDA")

/decl/uplink_source/pda/check_source_setup(mob/M)
	var/obj/item/device/pda/P = find_in_mob(M, /obj/item/device/pda)
	return (P ? P : FALSE)

/decl/uplink_source/pda/setup_uplink_source(mob/M, amount)
	var/obj/item/device/pda/P = check_source_setup(M)
	if(!P)
		return SETUP_FAILED

	var/pda_pass = "[rand(100,999)] [pick(GLOB.greek_letters)]"
	P.AddComponent(/datum/component/uplink, M.mind, TRUE, FALSE, null, amount)
	var/datum/component/uplink/uplink = P.get_component(/datum/component/uplink)
	uplink.unlock_code = pda_pass
	to_chat(M, "<span class='notice'>A portable object teleportation relay has been installed in your [P.name]. Simply enter the code \"[pda_pass]\" into the ringtone select to unlock its hidden features.</span>")
	M.mind.store_memory("<B>Uplink Passcode:</B> [pda_pass] ([P.name]).")

/decl/uplink_source/radio
	name = "Radio"
	desc = NO_GUARANTEE_NO_EXTRA_COST_DESC("a radio")

/decl/uplink_source/radio/check_source_setup(mob/M)
	var/obj/item/device/radio/R = find_in_mob(M, /obj/item/device/radio)
	return (R ? R : FALSE)

/decl/uplink_source/radio/setup_uplink_source(mob/M, amount)
	var/obj/item/device/radio/R = check_source_setup(M)
	if(!R)
		return SETUP_FAILED

	var/freq = PUBLIC_LOW_FREQ
	var/list/freqlist = list()
	while (freq <= PUBLIC_HIGH_FREQ)
		if (freq < 1451 || freq > PUB_FREQ)
			freqlist += freq
		freq += 2
		if ((freq % 2) == 0)
			freq += 1

	freq = freqlist[rand(1, freqlist.len)]
	R.AddComponent(/datum/component/uplink, M.mind, FALSE, FALSE, null, amount)
	var/datum/component/uplink/uplink = R.get_component(/datum/component/uplink)
	uplink.traitor_frequency = freq
	to_chat(M, "<span class='notice'>A portable object teleportation relay has been installed in your [R.name]. Simply dial the frequency [format_frequency(freq)] to unlock its hidden features.</span>")
	M.mind.store_memory("<B>Radio Freq:</B> [format_frequency(freq)] ([R.name]).")

/decl/uplink_source/implant
	name = "Implant"
	desc = "Teleports an uplink implant into your head. Costs at least half the initial TC amount."

/decl/uplink_source/implant/check_source_setup(mob/living/carbon/human/H)
	if(!istype(H))
		return FALSE

	var/obj/item/organ/external/head = H.organs_by_name[BP_HEAD]

	return (head ? head : FALSE)

/decl/uplink_source/implant/setup_uplink_source(mob/living/carbon/human/H, amount)
	var/obj/item/organ/external/head = check_source_setup(H)
	if(!head)
		return SETUP_FAILED

	var/obj/item/implant/uplink/U = new(H)
	U.imp_in = H
	U.implanted = TRUE
	U.part = head
	head.implants += U

	U.implanted(H, IMPLANT_TELECRYSTAL_AMOUNT(amount)) // This proc handles the installation feedback

/decl/uplink_source/unit
	name = "Uplink Unit"
	desc = "Teleports an uplink unit to your location. Grants you three extra TCs."

/decl/uplink_source/unit/check_source_setup(mob/M)
	return (M.back ? TRUE : FALSE)

/decl/uplink_source/unit/setup_uplink_source(mob/M, amount)
	var/obj/item/device/radio/uplink/U = new(M, M.mind, round(amount * 1.25))
	put_on_mob(M, U, "\A [U]")

/decl/uplink_source/telecrystals
	name = "Telecrystals"
	desc = "Get your telecrystals in pure form, without the means to trade them for goods."

/decl/uplink_source/telecrystals/setup_uplink_source(mob/M, amount)
	var/obj/item/stack/telecrystal/TC = new(M, amount)
	put_on_mob(M, TC, "[amount] telecrystal\s")

/decl/uplink_source/proc/find_in_mob(mob/M, type)
	for(var/item in M.get_equipped_items(TRUE))
		if(!istype(item, type))
			continue
		var/obj/item/I = item
		var/datum/component/uplink/U = I.get_component(/datum/component/uplink)
		if(!istype(U))
			return I

/decl/uplink_source/proc/put_on_mob(mob/M, atom/movable/AM, text)
	var/obj/O = M.equip_to_storage(AM)
	if(O)
		to_chat(M, "<span class='notice'>[text] can be found in your [O.name].</span>")
	else if(M.pick_or_drop(AM))
		to_chat(M, "<span class='notice'>[text] appear in your hands.</span>")
	else
		to_chat(M, "<span class='notice'>[text] appear at your location.</span>")

/proc/setup_uplink_source(mob/M, amount = DEFAULT_TELECRYSTAL_AMOUNT)
	if(!istype(M) || !M.mind)
		return FALSE

	var/list/priority_order
	if(M.client && M.client.prefs)
		priority_order = M.client.prefs.uplink_sources

	if(!priority_order || !priority_order.len)
		priority_order = list()
		for(var/entry in GLOB.default_uplink_source_priority)
			priority_order += decls_repository.get_decl(entry)

	for(var/entry in priority_order)
		var/decl/uplink_source/US = entry
		if(US.setup_uplink_source(M, amount) != SETUP_FAILED)
			return TRUE

	to_chat(M, "<span class='warning'>Either by choice or circumstance you will be without an uplink.</span>")
	return FALSE

/proc/check_uplink_sources(mob/M)
	if(!istype(M) || !M.mind)
		return FALSE

	var/list/sources_list = list()
	for(var/entry in GLOB.default_uplink_source_priority)
		sources_list += decls_repository.get_decl(entry)

	for(var/entry in sources_list)
		var/decl/uplink_source/source = entry
		if(source.check_source_setup(M))
			return TRUE
	return FALSE

#undef NO_GUARANTEE_NO_EXTRA_COST_DESC
#undef SETUP_FAILED
