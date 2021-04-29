/hook/roundstart/proc/run_contract_fixer()
	GLOB.traitors.fixer.roundstart()
	return TRUE

/datum/contract_fixer
	var/name = "\The Syndicate Operations System"
	var/list/datum/contract_organization/organizations = list()
	var/enable_roundstart_proc = TRUE // set FALSE when roundstart proc replaced with storyteller
	var/time_to_nex_contract = 5 MINUTES

/datum/contract_fixer/New()
	for(var/org_path in subtypesof(/datum/contract_organization/syndicate))
		var/datum/contract_organization/syndicate = new org_path(src)
		organizations.Add(syndicate)

/datum/contract_fixer/proc/return_contracts(datum/mind/M)
	var/list/datum/antag_contract/avaliable_contracts = list()
	for(var/datum/contract_organization/CO in organizations)
		avaliable_contracts += CO.get_contracts(M)
	// for(var/datum/antag_contract/contract in contracts)
	// 	if(!contract.completed && !(M && (contract?.target_mind == M) && prob(85))) // 15 percent to show contract to contract target
	// 		avaliable_contracts.Add(contract)
	return avaliable_contracts

/datum/contract_fixer/proc/roundstart()
	if(enable_roundstart_proc)
		create_random_contract(min(6 + round(SSticker.minds.len / 5), 12))
		addtimer(CALLBACK(src, .proc/contract_tick), time_to_nex_contract)

/datum/contract_fixer/proc/contract_tick()
	create_random_contract(1)
	addtimer(CALLBACK(src, .proc/contract_tick), time_to_nex_contract)

/datum/contract_fixer/proc/create_random_contract(count = 1)
	while(--count)
		var/datum/contract_organization/CO = pick(organizations)
		CO.create_random_contract()

/datum/contract_organization
	var/name = "This is bug!"
	var/list/datum/antag_contract/contracts = list()
	var/intents // what contracts organization prefers?
	var/datum/contract_fixer/holder

/datum/contract_organization/New(datum/contract_organization/CO)
	holder = CO

/datum/contract_organization/proc/get_contracts(datum/mind/M)
	var/list/datum/antag_contract/avaliable_contracts = list()
	for(var/datum/antag_contract/contract in contracts)
		if(!contract.completed && !(M && (contract?.target_mind == M) && prob(85))) // 15 percent to show contract to contract target
			avaliable_contracts.Add(contract)
	return avaliable_contracts

/datum/contract_organization/proc/create_random_contract()
	var/list/candidates = (subtypesof(/datum/antag_contract))
	while(candidates.len)
		var/contract_type = pick(candidates)
		var/datum/antag_contract/C = new contract_type(src)
		var/not_avaliable = (intents ^ C.intent || prob(75))
		if(!C.can_place() && not_avaliable)
			candidates -= contract_type
			qdel(C)
			continue
		C.place()
		if(C.unique)
			candidates -= contract_type
		break

/datum/contract_organization/proc/add_contract(datum/antag_contract/AC)
	contracts.Add(AC)

/datum/contract_organization/proc/remove_conract(datum/antag_contract/AC)
	contracts.Remove(AC)

/datum/contract_organization/syndicate/tti
	name = "\The Trauma Team Interspace"
	intents = CONTRACT_IMPACT_SOCIAL & CONTRACT_IMPACT_OPERATION
/datum/contract_organization/syndicate/ms
	name = "\The MiliSpace"
	intents = CONTRACT_IMPACT_MILITARY & CONTRACT_IMPACT_HIJACK
/datum/contract_organization/syndicate/bs
	name = "\The Biospacenica"
	intents = CONTRACT_IMPACT_SOCIAL
/datum/contract_organization/syndicate/kt
	name = "\The Kang Too"
	intents = CONTRACT_IMPACT_SOCIAL & CONTRACT_IMPACT_OPERATION & CONTRACT_IMPACT_MILITARY
/datum/contract_organization/syndicate/nv
	name = "\The NovaPlasma"
	intents = CONTRACT_IMPACT_SOCIAL & CONTRACT_IMPACT_OPERATION
/datum/contract_organization/syndicate/dt
	name = "\The Dynamoon Technologies"
	intents = CONTRACT_IMPACT_SOCIAL & CONTRACT_IMPACT_HIJACK
/datum/contract_organization/syndicate/ns
	name = "\The NanoSaka"
	intents = CONTRACT_IMPACT_SOCIAL & CONTRACT_IMPACT_OPERATION & CONTRACT_IMPACT_MILITARY & CONTRACT_IMPACT_HIJACK
