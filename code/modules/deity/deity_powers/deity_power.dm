/datum/deity_power
	var/name
	var/desc
	var/list/requirements
	var/list/resource_cost = list() // Name = cost
	var/list/building_requirements
	/// Type expected
	var/expected_type
	var/power_path
	var/icon
	var/icon_state

/datum/deity_power/proc/manifest(atom/target, mob/living/deity/D)
	if(can_manifest(target, D) && pay_costs(D))
		return TRUE

/datum/deity_power/proc/can_manifest(atom/target, mob/living/deity/D)
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

/datum/deity_power/proc/pay_costs(mob/living/deity/D)
	for(var/name in resource_cost)
		if(!D.form.use_resource(name, resource_cost[name]))
			return FALSE

	return TRUE

/datum/deity_power/proc/get_printed_cost()
	var/list/cost = list()
	for(var/res in resource_cost)
		var/datum/deity_resource/resource = res
		var/printed_cost = "<font color=\"[resource.name_color]\">[resource.name]</font>"
		cost += list(printed_cost, resource_cost[res])

	return cost

/datum/deity_power/proc/_get_image()
	if(!isnull(icon) && !isnull(icon_state))
		return image(icon = icon, icon_state = icon_state)

	else
		var/atom/A = power_path
		return image(icon = initial(A.icon), icon_state = initial(A.icon_state))

/datum/deity_power/proc/_get_name()
	if(!isnull(name))
		return name

	else
		var/atom/A = power_path
		return initial(A.name)
