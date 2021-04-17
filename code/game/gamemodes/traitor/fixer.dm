/hook/roundstart/proc/run_fixer()
	GLOB.traitors.fixer.roundstart()
	return TRUE

/datum/fixer
	var/name = "\The Syndicate Operations System"
	var/list/datum/antag_contract/contracts = list()
	var/enable_roundstart_proc = TRUE // set FALSE when roundstart proc replaced with storyteller
	var/time_to_nex_contract = 5 MINUTES

/datum/fixer/proc/return_contracts()
	var/list/datum/antag_contract/avaliable_contracts = list()
	for(var/datum/antag_contract/contract in contracts)
		if(!contract.completed)
			avaliable_contracts.Add(contract)
	return avaliable_contracts

/datum/fixer/proc/add_contract(datum/antag_contract/AC)
	contracts.Add(AC)

/datum/fixer/proc/remove_conract(datum/antag_contract/AC)
	contracts.Remove(AC)

/datum/fixer/proc/roundstart()
	if(enable_roundstart_proc)
		create_random_contract(min(6 + round(SSticker.minds.len / 5), 12))
		addtimer(CALLBACK(src, .proc/contract_tick), time_to_nex_contract)

/datum/fixer/proc/contract_tick()
	create_random_contract(1)
	addtimer(CALLBACK(src, .proc/contract_tick), time_to_nex_contract)

/datum/fixer/proc/create_random_contract(count = 1)
	var/list/candidates = (subtypesof(/datum/antag_contract))
	while(--count)
		while(candidates.len)
			var/contract_type = pick(candidates)
			var/datum/antag_contract/C = new contract_type
			if(!C.can_place())
				candidates -= contract_type
				qdel(C)
				continue
			C.place()
			if(C.unique)
				candidates -= contract_type
			break
