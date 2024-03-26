/**
 * Wrapper around basic verb addition operation, allows to perform batch addition via nested lists,
 * updates stat panel if supplied `target` is a client or client-controlled mob.
 *
 * Arguments:
 * * target - who the verb is being added to, `/client` or `/mob`.
 * * verb - typepath of a verb, or a list of typepaths, supports nesting.
 */
/proc/grant_verb(client/target, verb_or_list_to_add)
	if(!target)
		CRASH("grant_verb called without a target")

	var/mob/mob_target = null

	if(ismob(target))
		mob_target = target
		target = mob_target.client
	else if(!istype(target, /client))
		CRASH("grant_verb called on a non-mob and non-client")

	var/list/verbs_list = list()

	if(!islist(verb_or_list_to_add))
		verbs_list += verb_or_list_to_add
	else
		var/list/verb_listref = verb_or_list_to_add
		var/list/elements_to_process = verb_listref.Copy()
		while(length(elements_to_process))
			var/element_or_list = elements_to_process[length(elements_to_process)] //Last element
			elements_to_process.len--
			if(islist(element_or_list))
				elements_to_process += element_or_list //list/a += list/b adds the contents of b into a, not the reference to the list itself
			else
				verbs_list += element_or_list

	if(mob_target)
		mob_target.verbs += verbs_list
		if(!target)
			return //Our work is done.
	else
		target.verbs += verbs_list

	var/list/output_list = list()
	for(var/thing in verbs_list)
		var/procpath/verb_to_add = thing
		output_list[++output_list.len] = list(verb_to_add.category, verb_to_add.name)

	//target.stat_panel.send_message("add_verb_list", output_list)

/**
 * Wrapper around basic verb removal operation, allows to perform batch addition via nested lists,
 * updates stat panel if supplied `target` is a client or client-controlled mob.
 *
 * Arguments:
 * * target - who the verb is being removed from, `/client` or `/mob`.
 * * verb - typepath of a verb, or a list of typepaths, supports nesting.
 */
/proc/revoke_verb(client/target, verb_or_list_to_remove)
	var/mob/mob_target = null

	if(ismob(target))
		mob_target = target
		target = mob_target.client
	else if(!istype(target, /client))
		CRASH("revoke_verb called on a non-mob and non-client")

	var/list/verbs_list = list()
	if(!islist(verb_or_list_to_remove))
		verbs_list += verb_or_list_to_remove
	else
		var/list/verb_listref = verb_or_list_to_remove
		var/list/elements_to_process = verb_listref.Copy()
		while(length(elements_to_process))
			var/element_or_list = elements_to_process[length(elements_to_process)] //Last element
			elements_to_process.len--
			if(islist(element_or_list))
				elements_to_process += element_or_list //list/a += list/b adds the contents of b into a, not the reference to the list itself
			else
				verbs_list += element_or_list

	if(mob_target)
		mob_target.verbs -= verbs_list
		if(!target)
			return //Our work is done.
	else
		target.verbs -= verbs_list

	var/list/output_list = list()
	for(var/thing in verbs_list)
		var/procpath/verb_to_remove = thing
		output_list[++output_list.len] = list(verb_to_remove.category, verb_to_remove.name)

	//target.stat_panel.send_message("remove_verb_list", output_list)
