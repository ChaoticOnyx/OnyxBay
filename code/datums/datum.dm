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
	/// Used to avoid unnecessary refstring creation in Destroy().
	var/has_state_machine = FALSE

	// Thinking
	var/list/_think_ctxs
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

	if(extensions)
		for(var/expansion_key in extensions)
			var/list/extension = extensions[expansion_key]
			if(islist(extension))
				extension.Cut()
			else
				qdel(extension)
		extensions = null

	clear_signal_refs()
	clear_think()
	weakref = null
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
/// * `time` - when to call the "think" proc. Falsy value stops from thinking.
/datum/proc/set_next_think(time)
	if(!time)
		_main_think_ctx?.stop()
		return

	if(QDELETED(_main_think_ctx))
		_main_think_ctx = new(time, CALLBACK(src, nameof(.proc/think)))
		SSthink.contexts_groups[_main_think_ctx.group] += _main_think_ctx
		CALC_NEXT_GROUP_RUN(_main_think_ctx)

		return

	_main_think_ctx.next_think = time

	if(!_main_think_ctx.group)
		ASSIGN_THINK_GROUP(_main_think_ctx.group, time)
		SSthink.contexts_groups[_main_think_ctx.group] += _main_think_ctx
	else
		var/new_group
		ASSIGN_THINK_GROUP(new_group, time)

		if(_main_think_ctx.group != new_group)
			SSthink.contexts_groups[_main_think_ctx.group] -= _main_think_ctx
			SSthink.contexts_groups[new_group] += _main_think_ctx
			_main_think_ctx.group = new_group

	CALC_NEXT_GROUP_RUN(_main_think_ctx)

/// Creates a thinking context.
///
/// * `name` - name of the context.
/// * `clbk` - a proc which should be called.
/// * `time` - when to call the context.
/datum/proc/add_think_ctx(name, datum/callback/clbk, time)
	LAZYINITLIST(_think_ctxs)

	if(!QDELETED(_think_ctxs[name]))
		CRASH("Thinking context [name] is exists")

	_think_ctxs[name] = new /datum/think_context(time, clbk)
	var/datum/think_context/ctx = _think_ctxs[name]

	if(time > 0)
		SSthink.contexts_groups[ctx.group] += ctx
		CALC_NEXT_GROUP_RUN(ctx)

/// Sets the next time for thinking in a context.
///
/// * `name` - name of the context.
/// * `time` - when to call the context. Falsy value removes the context.
/datum/proc/set_next_think_ctx(name, time)
	if(!time)
		_think_ctxs[name].stop()

		return

	var/datum/think_context/ctx = _think_ctxs[name]
	ctx.next_think = time

	if(!ctx.group)
		ASSIGN_THINK_GROUP(ctx.group, time)
		SSthink.contexts_groups[ctx.group] += ctx
	else
		var/new_group
		ASSIGN_THINK_GROUP(new_group, time)

		if(ctx.group != new_group)
			SSthink.contexts_groups[ctx.group] -= ctx
			SSthink.contexts_groups[new_group] += ctx
		ctx.group = new_group

	CALC_NEXT_GROUP_RUN(ctx)

/// Removes self from `SSthink`, deletes all thinking contexts.
/// Mainly used in `/proc/Destroy`.
/datum/proc/clear_think()
	set_next_think(0)
	QDEL_LIST_ASSOC_VAL(_think_ctxs)
	QDEL_NULL(_main_think_ctx)
