/hook/roundstart/proc/run_contract_fixer()
	GLOB.traitors.fixer.roundstart()
	return TRUE

/datum/contract_fixer
	var/name = "\The Syndicate Operations System"
	var/list/datum/contract_organization/organizations = list()
	var/list/organizations_by_name = list()
	var/enable_roundstart_proc = TRUE // set FALSE when roundstart proc replaced with storyteller
	var/time_to_nex_contract = 5 MINUTES

/datum/contract_fixer/New()
	for(var/org_path in subtypesof(/datum/contract_organization/syndicate))
		new org_path(src)

/datum/contract_fixer/proc/return_contracts(datum/mind/M)
	var/list/datum/antag_contract/avaliable_contracts = list()
	for(var/datum/contract_organization/CO in organizations)
		avaliable_contracts += CO.get_contracts(M)
	return avaliable_contracts

/datum/contract_fixer/proc/roundstart()
	if(enable_roundstart_proc)
		create_random_contract(min(6 + round(SSticker.minds.len / 5), 12))
		addtimer(CALLBACK(src, .proc/contract_tick), time_to_nex_contract)

/datum/contract_fixer/proc/contract_tick()
	create_random_contract(1)
	addtimer(CALLBACK(src, .proc/contract_tick), time_to_nex_contract)

/datum/contract_fixer/proc/create_random_contract(count = 1)
	while(count--)
		var/datum/contract_organization/CO = pick(organizations)
		CO.create_random_contract()

/datum/contract_organization
	var/name = "This is bug!"
	var/list/datum/antag_contract/contracts = list()
	var/intents // what contracts organization prefers?
	var/datum/contract_fixer/holder

/datum/contract_organization/New(datum/contract_fixer/CF)
	ASSERT(intents)
	holder = CF
	holder.organizations.Add(src)
	holder.organizations_by_name[name] = src

/datum/contract_organization/proc/get_contracts(datum/mind/M)
	var/list/datum/antag_contract/avaliable_contracts = list()
	for(var/datum/antag_contract/contract in contracts)
		if(!contract.completed && !(M && (contract?.target_mind == M) && prob(85))) // 15 percent to show contract to contract target
			avaliable_contracts.Add(contract)
	return avaliable_contracts

/datum/contract_organization/proc/create_random_contract()
	var/list/candidates = (subtypesof(/datum/antag_contract))
	candidates.Remove(/datum/antag_contract/item) // place banned contracts here, e.g. parent contracts without intent
	while(candidates.len)
		var/contract_type = pick(candidates)
		var/datum/antag_contract/C = new contract_type(src)
		if(!C)
			continue
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
	AC.place()

/datum/contract_organization/proc/remove_conract(datum/antag_contract/AC)
	AC.remove()

/client/proc/edit_traitor_contracts()
	set name = "Syndicate Contracts Menu"
	set category = "Special Verbs"
	set desc = "Add/remove/edit traitor contracts"

	if(!check_rights(R_ADMIN))
		return
	holder.edit_contracts()

/datum/admins/proc/edit_contracts()
	if(GAME_STATE <= RUNLEVEL_SETUP)
		to_chat(usr, SPAN("danger", "The game hasn't started yet!"))
		return

	var/out = "<meta charset=\"utf-8\"><b>The Syndicate Operations Menu</b>"
	out += "<hr><b>Contracts (Operations|Objectives)</b></br>"
	for(var/datum/antag_contract/contract in GLOB.traitors.fixer.return_contracts())
		out += "<br><b>Contract [contract.name]:</b> <small>[contract.desc]</small> "
		if(contract.completed)
			out += "(<font color='green'>completed</font>)"
		else
			out += "(<font color='red'>incompleted</font>)"
		out += " <a href='?src=\ref[src];obj_remove=\ref[contract];contract_action=1'>\[remove contract]</a>"
	out += "<hr><a href='?src=\ref[src];obj_add=1;contract_action=1'>\[add contract]</a><br><br>"
	show_browser(usr, out, "window=edit_contracts[src]")

/datum/contract_organization/syndicate/tti
	name = "Trauma Team Interspace"
	intents = CONTRACT_IMPACT_SOCIAL | CONTRACT_IMPACT_OPERATION
/datum/contract_organization/syndicate/ms
	name = "MiliSpace"
	intents = CONTRACT_IMPACT_MILITARY | CONTRACT_IMPACT_HIJACK
/datum/contract_organization/syndicate/bs
	name = "Biospacenica"
	intents = CONTRACT_IMPACT_SOCIAL
/datum/contract_organization/syndicate/kt
	name = "Kang Too"
	intents = CONTRACT_IMPACT_SOCIAL | CONTRACT_IMPACT_OPERATION | CONTRACT_IMPACT_MILITARY
/datum/contract_organization/syndicate/nv
	name = "NovaPlasma"
	intents = CONTRACT_IMPACT_SOCIAL | CONTRACT_IMPACT_OPERATION
/datum/contract_organization/syndicate/dt
	name = "Dynamoon Technologies"
	intents = CONTRACT_IMPACT_SOCIAL | CONTRACT_IMPACT_HIJACK
/datum/contract_organization/syndicate/ns
	name = "NanoSaka"
	intents = CONTRACT_IMPACT_SOCIAL | CONTRACT_IMPACT_OPERATION | CONTRACT_IMPACT_MILITARY | CONTRACT_IMPACT_HIJACK
