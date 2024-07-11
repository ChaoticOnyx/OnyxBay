/// Map of reagent names to its datum path
GLOBAL_LIST_INIT(name2reagent, build_name2reagentlist())

/// Builds map of reagent name to its datum path
/proc/build_name2reagentlist()
	. = list()

	//build map with keys stored seperatly
	var/list/name_to_reagent = list()
	var/list/only_names = list()
	for(var/reagent in subtypesof(/datum/reagent))
		var/datum/reagent/R = reagent
		var/name = initial(R.name)
		if(length(name))
			name_to_reagent[name] = reagent
			only_names += name

	//sort keys
	only_names = sort_list(only_names)

	//build map with sorted keys
	for(var/name as anything in only_names)
		.[name] = name_to_reagent[name]
