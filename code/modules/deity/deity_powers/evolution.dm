/datum/evolution_category
	var/name
	var/list/items = list()

/datum/evolution_category/New()
	for(var/path in items)
		var/datum/evolution_package/pack = new path()
		items -= path
		items += pack

	return ..()

/datum/evolution_package
	var/name
	var/desc
	var/icon
	var/tier
	var/unlocked = FALSE
	var/list/requirements
	var/list/resource_cost = list() // Name = cost
	var/list/building_requirements
	var/list/unlocked_by = list()
	var/list/unlocks = list()

/datum/evolution_package/proc/can_evolve(mob/living/deity/D)
	for(var/type in resource_cost)
		if(!D.form.has_enough_resource(type, resource_cost[type]))
			var/datum/deity_resource/dr = D.form.get_resource(type)
			to_chat(D, SPAN_WARNING("You do not have enough [dr.name]!"))
			return FALSE

	if(building_requirements)
		for(var/type in building_requirements)
			if(D.get_building_type_amount(type) < building_requirements[type])
				var/obj/structure/O = type
				to_chat(D, SPAN_WARNING("You need more [initial(O.name)]!"))
				return FALSE

	return TRUE

/datum/evolution_package/proc/pay_costs(mob/living/deity/D)
	for(var/name in resource_cost)
		if(!D.form.use_resource(name, resource_cost[name]))
			return FALSE

	return TRUE

/datum/evolution_package/proc/evolve(mob/living/deity/D)
	if(can_evolve(D) && pay_costs(D))
		return TRUE
