GLOBAL_VAR_INIT(contract_recon_target_count, 3)
GLOBAL_LIST_EMPTY(all_contracts)
GLOBAL_LIST_INIT(contracts_steal_items, list(
	"the prototype psychoscope" = 						list(CONTRACT_STEAL_SCIENCE, /obj/item/clothing/glasses/psychoscope),
	"the captain's antique laser gun" = 				list(CONTRACT_STEAL_MILITARY, /obj/item/weapon/gun/energy/captain),
	"a bluespace rift generator in hand teleporter" =	list(CONTRACT_STEAL_SCIENCE, /obj/item/integrated_circuit/manipulation/bluespace_rift),
	"an RCD" = 											list(CONTRACT_STEAL_OPERATION, /obj/item/weapon/rcd),
	// "a jetpack" = 										list(CONTRACT_STEAL_OPERATION, /obj/item/weapon/tank/jetpack), // jetpack doesn't stuff in STD, redo STD then uncomment this.
	"a captain's jumpsuit" = 							list(CONTRACT_STEAL_UNDERPANTS, /obj/item/clothing/under/rank/captain),
	"a pair of magboots" = 								list(CONTRACT_STEAL_OPERATION, /obj/item/clothing/shoes/magboots),
	"the [station_name()] blueprints" = 				list(CONTRACT_STEAL_OPERATION, /obj/item/blueprints),
	// "a nasa voidsuit" = 								list(CONTRACT_STEAL_OPERATION, /obj/item/clothing/suit/space/void),
	"a sample of slime extract" = 						list(CONTRACT_STEAL_SCIENCE, /obj/item/slime_extract),
	"a piece of corgi meat" = 							list(CONTRACT_STEAL_OPERATION, /obj/item/weapon/reagent_containers/food/snacks/meat/corgi),
	"a research director's jumpsuit" = 					list(CONTRACT_STEAL_UNDERPANTS, /obj/item/clothing/under/rank/research_director),
	"a chief engineer's jumpsuit" = 					list(CONTRACT_STEAL_UNDERPANTS, /obj/item/clothing/under/rank/chief_engineer),
	"a chief medical officer's jumpsuit" = 				list(CONTRACT_STEAL_UNDERPANTS, /obj/item/clothing/under/rank/chief_medical_officer),
	"a head of security's jumpsuit" = 					list(CONTRACT_STEAL_UNDERPANTS, /obj/item/clothing/under/rank/head_of_security),
	"a head of personnel's jumpsuit" = 					list(CONTRACT_STEAL_UNDERPANTS, /obj/item/clothing/under/rank/head_of_personnel),
	"the hypospray" = 									list(CONTRACT_STEAL_SCIENCE, /obj/item/weapon/reagent_containers/hypospray),
	"the captain's pinpointer" = 						list(CONTRACT_STEAL_OPERATION, /obj/item/weapon/pinpointer),
	"an ion pistol" = 									list(CONTRACT_STEAL_MILITARY, /obj/item/weapon/gun/energy/ionrifle/small),
	"a 9mm submachine gun" = 							list(CONTRACT_STEAL_MILITARY, /obj/item/weapon/gun/projectile/automatic/wt550),
	"an riot helmet" = 									list(CONTRACT_STEAL_OPERATION, /obj/item/clothing/head/helmet/riot),
	"an riot armor vest" = 								list(CONTRACT_STEAL_OPERATION, /obj/item/clothing/suit/armor/riot),
	"an ballistic helmet" = 							list(CONTRACT_STEAL_MILITARY, /obj/item/clothing/head/helmet/ballistic),
	"an ballistic armor vest" = 						list(CONTRACT_STEAL_MILITARY, /obj/item/clothing/suit/armor/bulletproof),
	"an ablative helmet" = 								list(CONTRACT_STEAL_MILITARY, /obj/item/clothing/head/helmet/ablative),
	"an ablative armor vest" = 							list(CONTRACT_STEAL_MILITARY, /obj/item/clothing/suit/armor/laserproof)
))
GLOBAL_LIST_INIT(syndicate_factions, list(
	"\The Trauma Team Interspace",
	"\The MiliSpace",
	"\The Biospacenica",
	"\The Kang Too",
	"\The NovaPlasma",
	"\The Dynamoon Technologies",
	"\The NanoSaka"
))

/datum/antag_contract
	var/name
	var/desc
	var/reward = 0
	var/completed = FALSE
	var/datum/mind/completed_by
	var/unique = FALSE

	var/intent
	var/datum/mind/target_mind

	var/reason
	var/datum/contract_organization/organization

/datum/antag_contract/proc/create_contract(Creason, target)
	return

/datum/antag_contract/proc/create_explain_text(target_and_task)
	desc = "My client is [organization.name], [reason]. They have information the target is located on [GLOB.using_map.station_name]. \
	Your mission[prob(25) ? ", should you choose to accept it, is to" : " is to"] [target_and_task] The reward for closing this contract is [reward] TC"

/datum/antag_contract/proc/can_place()
	if(unique)
		for(var/datum/antag_contract/C in GLOB.all_contracts)
			if(istype(C, type) && !C.completed)
				return FALSE
	return !!name && !!desc

/datum/antag_contract/proc/place()
	GLOB.all_contracts += src
	if(organization)
		organization.add_contract(src)

/datum/antag_contract/proc/remove()
	GLOB.all_contracts -= src
	if(organization)
		organization.remove_conract(src)

// Called on every contract when a mob is despawned - currently, this can only happen when someone cryos
/datum/antag_contract/proc/on_mob_despawned(datum/mind/M)
	return

/datum/antag_contract/proc/complete(obj/item/device/uplink/close_uplink)
	if(!istype(close_uplink))
		return
	if(completed)
		warning("Contract completed twice: [name] [desc]")
	var/datum/mind/M = close_uplink.uplink_owner
	completed = TRUE
	completed_by = M

	if(M)
		M.completed_contracts++
		if(M.current)
			to_chat(M.current, SPAN_NOTICE("Contract completed: [name] ([reward] TC). Nice work, [M.current]."))

	close_uplink.uses += reward


// A contract to steal a specific item - allows you to check all contents (recursively) for the target item
/datum/antag_contract/item

/datum/antag_contract/item/proc/on_container(obj/item/weapon/storage/briefcase/std/container)
	if(check(container))
		complete(container.uplink)

/datum/antag_contract/item/proc/check(obj/item/weapon/storage/container)
	return check_contents(container.GetAllContents())

/datum/antag_contract/item/proc/check_contents(list/contents)
	warning("Item contract does not implement check_contents(): [name] [desc]")
	return FALSE

/datum/antag_contract/implant
	name = "Implant"
	reward = 14
	intent = CONTRACT_IMPACT_MILITARY

/datum/antag_contract/implant/New(datum/contract_organization/contract_organization, reason, datum/mind/target)
	organization = contract_organization
	create_contract(reason, target)
	..()

/datum/antag_contract/implant/create_contract(Creason, datum/mind/target)
	if(!Creason)
		reason = pick("they want to known the target's patterns", "they want to know the status of the target's importance for [GLOB.using_map.company_name]", "they want to know what the target does on [GLOB.using_map.station_name]")
	else
		reason = Creason

	var/mob/living/carbon/human/H
	if(!target)
		var/list/candidates = SSticker.minds.Copy()

		// Don't target the same player twice
		for(var/datum/antag_contract/implant/C in GLOB.all_contracts)
			candidates -= C.target_mind

		while(candidates.len)
			var/datum/mind/candidate_mind = pick(candidates)
			candidates -= candidate_mind

			// Implant contracts are 75% less likely to target contract-based antags to reduce the amount of cheesy self-implants
			if(GLOB.traitors.is_antagonist(target_mind))
				if(prob(25))
					reason = "they want to check the target's loylity to the Syndicate"
					reward = reward * 1.5
				else
					continue

			H = candidate_mind.current
			if(!istype(H) || H.stat == DEAD || !is_station_turf(get_turf(H)))
				continue

			target_mind = candidate_mind
			name = "[name] [H.real_name]"
			break
	else
		H = target.current
		if(!istype(H))
			remove()
			return
		target_mind = target
		name = "[name] [H.real_name]"
	create_explain_text("implant [H.real_name] with a spying implant.")

/datum/antag_contract/implant/can_place()
	return ..() && target_mind

/datum/antag_contract/implant/proc/check(obj/item/weapon/implant/spy/implant)
	if(completed)
		return
	if(implant.imp_in && implant.imp_in.mind == target_mind)
		complete(implant.hidden_uplink)

/datum/antag_contract/implant/on_mob_despawned(datum/mind/M)
	if(M == target_mind)
		remove()

/datum/antag_contract/item/steal
	name = "Steal"
	reward = 10
	intent = CONTRACT_IMPACT_OPERATION
	var/target_desc
	var/target_type

/datum/antag_contract/item/steal/proc/get_steal_reason(type)
	var/s_type = type
	var/reasonn
	if(!s_type)
		s_type = pick(CONTRACT_STEAL_MILITARY, CONTRACT_STEAL_OPERATION, CONTRACT_STEAL_SCIENCE, CONTRACT_STEAL_UNDERPANTS)
	switch(s_type)
		if(CONTRACT_STEAL_MILITARY)
			reasonn = pick("they want to use this item to reverse engineer it for combat extraction mission", "they want to use this item to use in combat extraction missions")
		if(CONTRACT_STEAL_OPERATION)
			reasonn = pick("they want to use this item for their operation on [GLOB.using_map.company_name]'s objects", "they need to use this item for their important spy mission")
		if(CONTRACT_STEAL_SCIENCE)
			reasonn = pick("they want to reverse engineer this item", "they need to use this item for their important scientific work")
		if(CONTRACT_STEAL_UNDERPANTS)
			reasonn = pick("they want to use this item for their spy operation on [GLOB.using_map.company_name]'s stations", "they want to use this item to confuse loyal [GLOB.using_map.company_name]'s employees")
	return reasonn

/datum/antag_contract/item/steal/New(datum/contract_organization/contract_organization, reason, target)
	organization = contract_organization
	create_contract(reason, target)
	..()

/datum/antag_contract/item/steal/create_contract(Creason, target)
	target_type = target
	if(!target_type)
		var/list/candidates = GLOB.contracts_steal_items.Copy()
		for(var/datum/antag_contract/item/steal/C in GLOB.all_contracts)
			candidates.Remove(C.target_desc)
		if(candidates.len)
			target_desc = pick(candidates)
			var/list/target_data = candidates[target_desc]
			reason = get_steal_reason(target_data[1])
			target_type = target_data[2]
	else
		if(Creason)
			reason = Creason
		else
			reason = get_steal_reason()
		var/obj/item/I = new target_type()
		target_desc = I.name
		qdel(I)
	name += " [target_desc]"
	create_explain_text("steal [target_desc] and send it via STD (find out in Devices and Tools).")

/datum/antag_contract/item/steal/can_place()
	return ..() && target_type

/datum/antag_contract/item/steal/check_contents(list/contents)
	return locate(target_type) in contents

/datum/antag_contract/item/steal_ai
	name = "Steal active AI"
	reward = 20
	intent = CONTRACT_IMPACT_HIJACK
	var/target_desc = "a functional AI"
	var/mob/living/silicon/ai/AI

/datum/antag_contract/item/steal_ai/New(datum/contract_organization/contract_organization, reason, target)
	organization = contract_organization
	create_contract(reason, target)
	..()

/datum/antag_contract/item/steal_ai/create_contract(Creason, mob/living/silicon/ai/target)
	if(!Creason)
		reason = pick("they want to execute intelligence virus on main [GLOB.using_map.company_name]'s AI using local AI core")
	else
		reason = Creason
	if(target)
		AI = target
	else
		if(length(ai_list))
			var/list/mob/living/silicon/ai/valid_AIs = list()
			for(var/mob/living/silicon/ai/AI in ai_list)
				if(AI.stat != DEAD)
					valid_AIs.Add(AI)
			AI = pick(valid_AIs)
	target_desc = "[target_desc] [AI.name]"
	create_explain_text("steal [target_desc] and send it via STD (find out in Devices and Tools).")

/datum/antag_contract/item/steal_ai/can_place()
	return ..() && istype(AI)

/datum/antag_contract/item/steal_ai/check_contents(list/contents)
	var/obj/item/weapon/aicard/card = locate() in contents
	return card?.carded_ai == AI

/datum/antag_contract/item/blood
	name = "Steal blood samples"
	unique = TRUE
	reward = 10
	intent = CONTRACT_IMPACT_OPERATION & CONTRACT_IMPACT_SOCIAL
	var/count

/datum/antag_contract/item/blood/New(datum/contract_organization/contract_organization, reason, target)
	organization = contract_organization
	create_contract(reason, target)
	..()

/datum/antag_contract/item/blood/create_contract(Creason, target)
	if(!Creason)
		reason = pick("they want to research the NT employee genome")
	else
		reason = Creason
	if(!isnum_safe(target))
		count = rand(3, 6)
	else
		count = target
	create_explain_text("send blood samples of [count] different people in separate containers via STD (find out in Devices and Tools).")

/datum/antag_contract/item/blood/check_contents(list/contents)
	var/list/samples = list()
	for(var/obj/item/weapon/reagent_containers/C in contents)
		var/list/data = C.reagents?.get_data(/datum/reagent/blood)
		if(!data || (data["blood_DNA"] in samples))
			continue
		samples += data["blood_DNA"]
		if(samples.len >= count)
			return TRUE
	return FALSE

/datum/antag_contract/item/assasinate
	name = "Assasinate"
	reward = 12
	intent = CONTRACT_IMPACT_MILITARY
	var/obj/item/organ/external/head/target

/datum/antag_contract/item/assasinate/New(datum/contract_organization/contract_organization, reason, datum/mind/target)
	organization = contract_organization
	create_contract(reason, target)
	..()

/datum/antag_contract/item/assasinate/create_contract(Creason, datum/mind/target)
	if(!Creason)
		reason = pick("the target shut down their agent on mission", "the target important to NanoTransen")
	else
		reason = Creason

	var/mob/living/carbon/human/H
	if(target)
		H = target.current
		if(!istype(H))
			remove()
			return
		target = H.organs_by_name[BP_HEAD]
		if(!target)
			remove()
			return
	else
		var/list/candidates = SSticker.minds.Copy()
		for(var/datum/antag_contract/item/assasinate/C in GLOB.all_contracts)
			candidates -= C.target_mind
		while(candidates.len)
			target_mind = pick(candidates)
			candidates -= target_mind
			H = target_mind.current
			if(!istype(H) || H.stat == DEAD || !is_station_turf(get_turf(H)))
				continue
			target = H.organs_by_name[BP_HEAD]
			if(!target)
				continue
			if(GLOB.traitors.is_antagonist(target_mind))
				if(prob(25))
					reason = "the target has betrayed the Syndicate and must be eliminated"
					reward = reward * 1.5
				else
					continue
			break
	name = "[name] [target_mind.current.real_name]"
	var/datum/gender/T = gender_datums[target_mind.current.get_gender()]
	create_explain_text("assasinate [target_mind.current.real_name] and send [T.his] [target.name] via STD (find out in Devices and Tools) as a proof.")

/datum/antag_contract/item/assasinate/can_place()
	return ..() && target

/datum/antag_contract/item/assasinate/check_contents(list/contents)
	return target in contents

/datum/antag_contract/item/assasinate/on_mob_despawned(datum/mind/M)
	if(M == target_mind)
		remove()

/datum/antag_contract/item/dump
	name = "Dump"
	unique = TRUE
	reward = 8
	var/sum

/datum/antag_contract/item/dump/New(datum/contract_organization/contract_organization, reason, target)
	..()
	organization = contract_organization
	create_contract(reason, target)

/datum/antag_contract/item/dump/create_contract(Creason, target)
	if(!Creason)
		reason = pick("they want to finance their agent on another object of [GLOB.using_map.company_name]'s station", "they want to update their stocks on local [GLOB.using_map.company_name]'s market")
	else
		reason = Creason
	if(!isnum_safe(target))
		sum = rand(30, 40) * 500
	else
		sum = target
	name += " [sum] cash"
	create_explain_text("extract a sum of [sum] credits from [GLOB.using_map.company_name] economy and send it via STD (find out in Devices and Tools).")

/datum/antag_contract/item/dump/check_contents(list/contents)
	var/received = 0
	for(var/obj/item/weapon/spacecash/cash in contents)
		received += cash.worth
	return received >= sum

/datum/antag_contract/item/research
	name = "Steal research"
	unique = TRUE
	reward = 6
	var/list/datum/design/targets = list()
	var/static/counter = 0

/datum/antag_contract/item/research/New(datum/contract_organization/contract_organization, reason, list/datum/design/target)
	..()
	organization = contract_organization
	create_contract(reason, target)

/datum/antag_contract/item/research/create_contract(Creason, list/datum/design/target)
	if(!Creason)
		reason = pick("a foreigh research division needs your help in acquiring valuable scientific data", "they have high-likely rumors about some designs located on [GLOB.using_map.station_name]")
	else
		reason = Creason
	var/list/targets_name = list()
	if(!islist(target))
		var/list/datum/design/candidates = list()
		for(var/design_path in subtypesof(/datum/design))
			var/datum/design/D = new design_path
			if(D.name)
				if(!length(D.req_tech))
					continue
				for(var/tech_name in D.req_tech)
					if(D.req_tech[tech_name] <= 2)
						continue
				candidates.Add(D)
		for(var/datum/antag_contract/item/research/C in GLOB.all_contracts)
			candidates.Remove(C.targets)
		while(candidates.len && targets.len < 8)
			var/datum/design/D = pick(candidates)
			if(D?.build_path)
				targets.Add(D.type)
				targets_name.Add(D.name)
			candidates.Remove(D)
	else
		for(var/datum/design/R in target)
			if(R?.build_path)
				targets.Add(R)
				targets_name.Add(R.name)
	create_explain_text("send a fabricator data disk with one of the following designs via STD (find out in Devices and Tools):<br>[english_list(targets_name, and_text = " or ")].")

/datum/antag_contract/item/research/can_place()
	return ..() && targets.len && counter < 3

/datum/antag_contract/item/research/place()
	..()
	++counter

/datum/antag_contract/item/research/check_contents(list/contents)
	for(var/obj/item/weapon/disk/design_disk/D in contents)
		if(D.blueprint.type in targets)
			return TRUE
	return FALSE

/datum/antag_contract/recon
	name = "Recon"
	reward = 12
	var/list/area/targets = list()

/datum/antag_contract/recon/New(datum/contract_organization/contract_organization, reason, list/area/target)
	organization = contract_organization
	create_contract(reason, target)
	..()

/datum/antag_contract/recon/create_contract(Creason, list/area/target)
	if(!Creason)
		reason = pick("they want to know what objects located in this area")
	else
		reason = Creason
	if(islist(target))
		for(var/area/A in target)
			targets.Add(A)
	else
		var/list/candidates = get_filtered_areas(GLOB.is_station_but_not_space_or_shuttle_area)
		for(var/datum/antag_contract/recon/C in GLOB.all_contracts)
			if(C.completed)
				continue
			candidates -= C.targets
		while(candidates.len && targets.len < GLOB.contract_recon_target_count)
			var/area/area_target = pick(candidates)
			if((area_target.area_flags & AREA_FLAG_RAD_SHIELDED) && !(area_target.area_flags & AREA_FLAG_EXTERNAL))
				candidates -= area_target
				continue
			targets += area_target
	create_explain_text("activate 3 spy bug by spy monitor (Bug kit) in one of the following locations: [english_list(targets, and_text = " or ")] and let them work without interruption for 10 minutes.")

/datum/antag_contract/recon/can_place()
	return ..() && targets.len

/datum/antag_contract/recon/proc/check(obj/item/device/spy_monitor/sensor)
	if(completed)
		return
	for(var/area/A in sensor.active_recon_areas_list)
		if(A in targets)
			complete(sensor.uplink)
