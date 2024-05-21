/datum/evolution_holder
	var/weakref/user
	var/list/evolution_categories
	var/list/unlocked_packages
	var/list/all_packages = list()
	var/list/default_modifiers

/datum/evolution_holder/New(mob/living/user)
	. = ..()
	src.user = weakref(user)
	for(var/path in default_modifiers)
		ADD_TRAIT(user, path)

	for(var/path in evolution_categories)
		var/datum/evolution_package/evo = new path(src)
		evolution_categories -= path
		evolution_categories += evo

/datum/evolution_holder/Destroy(force)
	user = null
	return ..()

/datum/evolution_category
	var/name
	var/list/items

/datum/evolution_category/New(datum/evolution_holder/evo_holder)
	. = ..()
	for(var/path in items)
		var/datum/evolution_package/pack = new path()
		items -= path
		LAZYDISTINCTADD(items, pack)
		LAZYDISTINCTADD(evo_holder.all_packages, pack)

/datum/evolution_package
	var/name
	var/desc
	var/icon
	var/tier
	var/cost = 1
	var/purchased = FALSE
	var/list/requirements
	var/list/resource_cost = list() // Name = cost
	var/list/building_requirements
	var/list/unlocked_by = list()
	var/list/datum/action/actions = list()
	var/list/datum/modifier/modifiers = list()
	var/weakref/user

/datum/evolution_package/proc/check_unlocked(datum/evolution_holder/evo_holder)
	if(!LAZYLEN(unlocked_by))
		return TRUE

	for(var/datum/evolution_package/pack in evo_holder.unlocked_packages)
		if(!LAZYISIN(unlocked_by, pack.type))
			continue

		return TRUE

	return FALSE

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

/datum/evolution_package/proc/pay_costs(mob/living/deity/D = null, mob/living/carbon/human/H = null)
	if(!isnull(D))
		for(var/name in resource_cost)
			if(!D.form.use_resource(name, resource_cost[name]))
				return FALSE

		if(cost > D?.form?.knowledge_points)
			return FALSE

		D?.form?.knowledge_points -= cost

	if(!isnull(H))
		var/datum/godcultist/godcultist = H.mind?.godcultist
		if(!godcultist?.spend_points(cost))
			return FALSE

	return TRUE

/datum/evolution_package/proc/evolve(mob/living/M)
	var/mob/living/deity/deity = get_associated_deity(M)
	if(!istype(deity))
		return FALSE

	if(!can_evolve(deity))
		return FALSE

	if(isdeity(M) && !pay_costs(M, null))
		return FALSE

	else if(ishuman(M) && !pay_costs(null, M))
		return FALSE

	if(ishuman(M))
		LAZYDISTINCTADD(M?.mind?.godcultist?.evo_holder.unlocked_packages, src)
		apply_followers_package(M)
		purchased = TRUE
		return TRUE

	else if(isdeity(M))
		LAZYDISTINCTADD(deity.form?.evo_holder.unlocked_packages, src)
		purchased = TRUE
		return TRUE

	else return FALSE

/datum/evolution_package/proc/get_associated_deity(mob/living/M)
	if(isdeity(M))
		return M

	else if(isliving(M))
		var/mob/living/deity/deity = M.mind?.godcultist?.linked_deity
		if(!isdeity(deity))
			return FALSE

		else return deity

	else return FALSE

/datum/evolution_package/proc/apply_followers_package(mob/living/carbon/human/M)
	src.user = weakref(M)
	for(var/action in actions)
		var/datum/action/act = new action(M)
		act.Grant(M)

	for(var/modifier in modifiers)
		ADD_TRAIT(M, modifier)
