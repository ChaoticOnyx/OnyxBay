/datum
	var/tmp/gc_destroyed //Time when this object was destroyed.
	var/tmp/is_processing = FALSE
	var/list/active_timers  //for SStimer

	/// Components attached to this datum.
	var/list/datum_components = list()
	/// Any datum registered to receive signals from this datum is in this list.
	var/list/comp_lookup = list()
	/// Lazy associated list of signals that are run when the datum receives that signal
	var/list/signal_procs = list()

	// Thinking
	var/is_thinking = FALSE
	var/list/_think_ctxs = list()
	var/datum/think_context/_main_think_ctx

#ifdef TESTING
	var/tmp/running_find_references
	var/tmp/last_find_references = 0
	#ifdef REFERENCE_TRACKING_DEBUG
	/// Stores info about where refs are found, used for sanity checks and testing
	var/list/found_refs
	#endif
#endif

// The following vars cannot be edited by anyone
/datum/VV_static()
	return ..() + list("gc_destroyed", "is_processing")

// Default implementation of clean-up code.
// This should be overridden to remove all references pointing to the object being destroyed.
// Return the appropriate QDEL_HINT; in most cases this is QDEL_HINT_QUEUE.
/datum/proc/Destroy(force=FALSE)
	SHOULD_CALL_PARENT(TRUE)

	tag = null
	SSnano && SSnano.close_uis(src)
	var/list/timers = active_timers
	active_timers = null
	for(var/thing in timers)
		var/datum/timedevent/timer = thing
		if (timer.spent)
			continue
		qdel(timer)

	var/list/dc = datum_components
	if(dc)
		var/all_components = dc[/datum/component]
		if(length(all_components))
			for(var/datum/component/component as anything in all_components)
				qdel(component, FALSE, TRUE)
		else
			var/datum/component/C = all_components
			qdel(C, FALSE, TRUE)
		dc.Cut()

	clear_signal_refs()
	clear_think()

	return QDEL_HINT_QUEUE

/// Only override this if you know what you're doing. You do not know what you're doing
/// This is a threat
/datum/proc/clear_signal_refs()
	var/list/lookup = comp_lookup
	if(lookup)
		for(var/sig in lookup)
			var/list/comps = lookup[sig]
			if(length(comps))
				for(var/datum/component/comp as anything in comps)
					comp.unregister_signal(src, sig)
			else
				var/datum/component/comp = comps
				comp.unregister_signal(src, sig)
		comp_lookup = lookup = null

	for(var/target in signal_procs)
		unregister_signal(target, signal_procs[target])

/datum/proc/Process()
	set waitfor = 0
	return PROCESS_KILL

// Sometimes you just want to end yourself
/datum/proc/qdel_self()
	qdel(src)

// Thinking procs.
// INTENSIVE COPYPASTA FOR THE SAKE OF SPEED

/datum/proc/think()
	return

/// Schedules the next call of the `/datum/proc/think`.
///
/// * `time` - when to call the "think" proc. Falsy value stops from thinking (including the contexts).
/datum/proc/set_next_think(time)
	if(!_main_think_ctx)
		_main_think_ctx = new(time, CALLBACK(src, .proc/think))
	else
		_main_think_ctx.next_think = time

	if(!time)
		clear_think()
		return

	if(!is_thinking)
		is_thinking = TRUE

		ASSIGN_THINK_GROUP(_main_think_ctx.group, time)
		SSthink.contexts_groups[_main_think_ctx.group] += _main_think_ctx
	else
		var/new_group
		ASSIGN_THINK_GROUP(new_group, time)

		if(_main_think_ctx.group != new_group)
			SSthink.contexts_groups[_main_think_ctx.group] -= _main_think_ctx
			SSthink.contexts_groups[new_group] += _main_think_ctx
			_main_think_ctx.group = new_group

	SSthink.next_group_run[_main_think_ctx.group] = SSthink.next_group_run[_main_think_ctx.group] == 0 ? _main_think_ctx.next_think : min(SSthink.next_group_run[_main_think_ctx.group], _main_think_ctx.next_think)

/// Creates a thinking context.
///
/// * `name` - name of the context.
/// * `clbk` - a proc which should be called.
/// * `time` - when to call the context.
/datum/proc/add_think_ctx(name, datum/callback/clbk, time)
	if(!time)
		CRASH("Invalid time")

	if(_think_ctxs[name])
		CRASH("Thinking context [name] is exists")

	_think_ctxs[name] = new /datum/think_context(time, clbk)
	var/datum/think_context/ctx = _think_ctxs[name]

	if(!is_thinking)
		is_thinking = TRUE

		SSthink.contexts_groups[ctx.group] += ctx
		SSthink.next_group_run[ctx.group] = SSthink.next_group_run[ctx.group] == 0 ? ctx.next_think : min(SSthink.next_group_run[ctx.group], ctx.next_think)

/// Sets the next time for thinking in a context.
///
/// * `name` - name of the context.
/// * `time` - when to call the context. Falsy value removes the context.
/datum/proc/set_next_think_ctx(name, time)
	if(!time)
		_think_ctxs -= name

		return

	var/datum/think_context/ctx = _think_ctxs[name]
	ctx.next_think = time
	var/new_group
	ASSIGN_THINK_GROUP(new_group, time)

	if(ctx.group != new_group)
		SSthink.contexts_groups[ctx.group] -= ctx
		SSthink.contexts_groups[new_group] += ctx
		ctx.group = new_group

	SSthink.next_group_run[ctx.group] = SSthink.next_group_run[ctx.group] == 0 ? ctx.next_think : min(SSthink.next_group_run[ctx.group], ctx.next_think)

/// Removes self from `SSthink`, deletes all thinking contexts.
/// Mainly used in `/proc/Destroy`.
/datum/proc/clear_think()
	if(is_thinking)
		is_thinking = FALSE
	
	QDEL_LIST_ASSOC_VAL(_think_ctxs)
	qdel(_main_think_ctx)
