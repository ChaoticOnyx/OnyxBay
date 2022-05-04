//Check if an /atom/movable that has been Destroyed has been correctly placed into nullspace and if not, throws a runtime and moves it to nullspace
#define GC_CHECK_AM_NULLSPACE(D, hint) \
	if(istype(D, /atom/movable)) {\
		var/atom/movable/AM = D; \
		if(AM.loc != null) {\
			crash_with("QDEL("+hint+"): "+AM.name+" was supposed to be in nullspace but isn't \
						(LOCATION= "+AM.loc.name+" ("+AM.loc.x+","+AM.loc.y+","+AM.loc.z+") )! Destroy didn't do its job!"); \
			AM.forceMove(null); \
		} \
	}

SUBSYSTEM_DEF(garbage)
	name = "Garbage"
	priority = SS_PRIORITY_GARBAGE
	wait = 2 SECONDS
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND|SS_NO_INIT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	init_order = SS_INIT_GARBAGE

	var/list/collection_timeout = list(GC_FILTER_QUEUE, GC_CHECK_QUEUE, GC_DEL_QUEUE)	// deciseconds to wait before moving something up in the queue to the next level

	//Stat tracking
	var/delslasttick = 0            // number of del()'s we've done this tick
	var/gcedlasttick = 0            // number of things that gc'ed last tick
	var/totaldels = 0
	var/totalgcs = 0

	var/highest_del_time = 0
	var/highest_del_tickusage = 0

	var/list/pass_counts
	var/list/fail_counts

	var/list/items = list()         // Holds our qdel_item statistics datums

	//Queue
	var/list/queues
	var/avoid_harddel = FALSE //Avoid hard del

	#ifdef TESTING
	var/list/reference_find_on_fail = list()
	#endif


/datum/controller/subsystem/garbage/PreInit()
	InitQueues()

/datum/controller/subsystem/garbage/stat_entry(msg)
	var/list/counts = list()
	for (var/list/L in queues)
		counts += length(L)
	msg += "Q:[counts.Join(",")]|D:[delslasttick]|G:[gcedlasttick]|"
	msg += "GR:"
	if (!(delslasttick+gcedlasttick))
		msg += "n/a|"
	else
		msg += "[round((gcedlasttick/(delslasttick+gcedlasttick))*100, 0.01)]%|"

	msg += "TD:[totaldels]|TG:[totalgcs]|"
	if (!(totaldels+totalgcs))
		msg += "n/a|"
	else
		msg += "TGR:[round((totalgcs/(totaldels+totalgcs))*100, 0.01)]%"
	msg += " P:[pass_counts.Join(",")]"
	msg += "|F:[fail_counts.Join(",")]"
	..(msg)

/datum/controller/subsystem/garbage/Shutdown()
	//Adds the del() log to the qdel log file
	var/list/dellog = list()

	//sort by how long it's wasted hard deleting
	sortTim(items, cmp=/proc/cmp_qdel_item_time, associative = TRUE)
	for(var/path in items)
		var/datum/qdel_item/I = items[path]
		dellog += "Path: [path]"
		if (I.failures)
			dellog += "\tFailures: [I.failures]"
		dellog += "\tqdel() Count: [I.qdels]"
		dellog += "\tDestroy() Cost: [I.destroy_time]ms"
		if (I.hard_deletes)
			dellog += "\tTotal Hard Deletes: [I.hard_deletes]"
			dellog += "\tTime Spent Hard Deleting: [I.hard_delete_time]ms"
		if (I.slept_destroy)
			dellog += "\tSleeps: [I.slept_destroy]"
		if (I.no_respect_force)
			dellog += "\tIgnored force: [I.no_respect_force] times"
		if (I.no_hint)
			dellog += "\tNo hint: [I.no_hint] times"
	log_qdel(dellog.Join("\n"))

/datum/controller/subsystem/garbage/fire()
	//the fact that this resets its processing each fire (rather then resume where it left off) is intentional.
	var/queue = GC_QUEUE_FILTER

	while(state == SS_RUNNING)
		switch(queue)
			if(GC_QUEUE_FILTER)
				HandleQueue(GC_QUEUE_FILTER)
				queue = GC_QUEUE_FILTER + 1
			if(GC_QUEUE_CHECK)
				HandleQueue(GC_QUEUE_CHECK)
				queue = GC_QUEUE_CHECK + 1
			if(GC_QUEUE_HARDDELETE)
				HandleQueue(GC_QUEUE_HARDDELETE)
				if(state == SS_PAUSED) //make us wait again before the next run.
					state = SS_RUNNING
				break

/datum/controller/subsystem/garbage/proc/InitQueues()
	if(isnull(queues)) // Only init the queues if they don't already exist, prevents overriding of recovered lists
		queues = new(GC_QUEUE_COUNT)
		pass_counts = new(GC_QUEUE_COUNT)
		fail_counts = new(GC_QUEUE_COUNT)
		for(var/i in 1 to GC_QUEUE_COUNT)
			queues[i] = list()
			pass_counts[i] = 0
			fail_counts[i] = 0

/datum/controller/subsystem/garbage/proc/HandleQueue(level = GC_QUEUE_CHECK)
	if(level == GC_QUEUE_CHECK)
		delslasttick = 0
		gcedlasttick = 0
	var/cut_off_time = world.time - collection_timeout[level] // ignore entries newer then this
	var/list/queue = queues[level]
	var/static/lastlevel
	var/static/count = 0
	if(count) // runtime last run before we could do this.
		var/c = count
		count = 0 // so if we runtime on the Cut, we don't try again.
		var/list/lastqueue = queues[lastlevel]
		lastqueue.Cut(1, c + 1)

	lastlevel = level

	for(var/i in 1 to length(queue))
		var/list/L = queue[i]
		if(length(L) < 2)
			count++
			if(MC_TICK_CHECK)
				break
			continue

		var/GCd_at_time = L[1]
		if(GCd_at_time > cut_off_time)
			break // Everything else is newer, skip them
		count++
		var/refID = L[2]

		var/datum/D
		D = locate(refID)

		if(!D || D.gc_destroyed != GCd_at_time) // So if something else coincidently gets the same ref, it's not deleted by mistake
			++gcedlasttick
			++totalgcs
			pass_counts[level]++
			#ifdef TESTING
			reference_find_on_fail -= refID		//It's deleted we don't care anymore.
			#endif
			if(MC_TICK_CHECK)
				return
			continue

		// Something's still referring to the qdel'd object.
		fail_counts[level]++
		switch(level)
			if(GC_QUEUE_CHECK)
				#ifdef TESTING
				if(reference_find_on_fail[refID])
					D.find_references()
				#ifdef GC_FAILURE_HARD_LOOKUP
				else
					D.find_references()
				#endif
				reference_find_on_fail -= refID
				#endif
				var/type = D.type
				var/datum/qdel_item/I = items[type]

				if(!I.failures)
					crash_with("GC: -- \ref[D] | [type] was unable to be GC'd --")
				I.failures++
			if(GC_QUEUE_HARDDELETE)
				if(avoid_harddel)
					continue
				HardDelete(D)
				if(MC_TICK_CHECK)
					return
				continue

		Queue(D, level+1)

		if(MC_TICK_CHECK)
			return
	if(count)
		queue.Cut(1, count + 1)
		count = 0

/datum/controller/subsystem/garbage/proc/Queue(datum/D, level = GC_QUEUE_FILTER)
	if(isnull(D))
		return
	if(level > GC_QUEUE_COUNT)
		HardDelete(D)
		return
	var/gctime = world.time
	var/refid = "\ref[D]"

	D.gc_destroyed = gctime
	var/list/queue = queues[level]

	queue[++queue.len] = list(gctime, refid) // not += for byond reasons

//this is mainly to separate things profile wise.
/datum/controller/subsystem/garbage/proc/HardDelete(datum/D)
	var/time = world.timeofday
	var/tick = TICK_USAGE
	var/ticktime = world.time
	++delslasttick
	++totaldels
	var/type = D.type
	var/refID = "\ref[D]"

	del(D)

	tick = (TICK_USAGE-tick+((world.time-ticktime)/world.tick_lag*100))

	var/datum/qdel_item/I = items[type]

	I.hard_deletes++
	I.hard_delete_time += TICK_DELTA_TO_MS(tick)


	if(tick > highest_del_tickusage)
		highest_del_tickusage = tick
	time = world.timeofday - time
	if(!time && TICK_DELTA_TO_MS(tick) > 1)
		time = TICK_DELTA_TO_MS(tick)/100
	if(time > highest_del_time)
		highest_del_time = time
	if(time > 10)
		log_game("Error: [type]([refID]) took longer than 1 second to delete (took [time/10] seconds to delete)")
		message_admins("Error: [type]([refID]) took longer than 1 second to delete (took [time/10] seconds to delete).")
		postpone(time)

/datum/controller/subsystem/garbage/Recover()
	InitQueues() //We first need to create the queues before recovering data
	if(istype(SSgarbage.queues))
		for(var/i in 1 to SSgarbage.queues.len)
			queues[i] |= SSgarbage.queues[i]

/datum/controller/subsystem/garbage/proc/toggle_harddel(state = TRUE)
	if(state == avoid_harddel)
		return
	avoid_harddel = state
	return

/datum/qdel_item
	var/name = ""
	var/qdels = 0			//Total number of times it's passed thru qdel.
	var/destroy_time = 0	//Total amount of milliseconds spent processing this type's Destroy()
	var/failures = 0		//Times it was queued for soft deletion but failed to soft delete.
	var/hard_deletes = 0 	//Different from failures because it also includes QDEL_HINT_HARDDEL deletions
	var/hard_delete_time = 0//Total amount of milliseconds spent hard deleting this type.
	var/no_respect_force = 0//Number of times it's not respected force=TRUE
	var/no_hint = 0			//Number of times it's not even bother to give a qdel hint
	var/slept_destroy = 0	//Number of times it's slept in its destroy

/datum/qdel_item/New(mytype)
	name = "[mytype]"

#ifdef TESTING
/proc/qdel_and_find_ref_if_fail(datum/thing_to_del, force = FALSE)
	thing_to_del.qdel_and_find_ref_if_fail(force)

/datum/proc/qdel_and_find_ref_if_fail(force = FALSE)
	SSgarbage.reference_find_on_fail["\ref[src]"] = TRUE
	qdel(src, force)
#endif

// Should be treated as a replacement for the 'del' keyword.
// Datums passed to this will be given a chance to clean up references to allow the GC to collect them.
/proc/qdel(datum/D, force=FALSE, ...)
	if(!istype(D))
		del(D)
		return

	var/datum/qdel_item/I = SSgarbage.items[D.type]
	if(!I)
		I = SSgarbage.items[D.type] = new /datum/qdel_item(D.type)
	I.qdels++

	if(isnull(D.gc_destroyed))
		// Give the components a chance to prevent their parent from being deleted.
		if(SEND_SIGNAL(D, SIGNAL_PREQDELETING, D, force) || SEND_GLOBAL_SIGNAL(SIGNAL_PREQDELETING, D, force))
			return
		D.gc_destroyed = GC_CURRENTLY_BEING_QDELETED
		var/start_time = world.time
		var/start_tick = world.tick_usage
		SEND_SIGNAL(D, SIGNAL_QDELETING, D, force) // Let the (remaining) components know about the result of Destroy
		SEND_GLOBAL_SIGNAL(SIGNAL_QDELETING, D, force)
		var/hint = D.Destroy(arglist(args.Copy(2))) // Let our friend know they're about to get fucked up.
		if(world.time != start_time)
			I.slept_destroy++
		else
			I.destroy_time += TICK_USAGE_TO_MS(start_tick)
		if(!D)
			return
		switch(hint)
			if(QDEL_HINT_QUEUE)		//qdel should queue the object for deletion.
				GC_CHECK_AM_NULLSPACE(D, "QDEL_HINT_QUEUE")
				SSgarbage.Queue(D)
			if(QDEL_HINT_IWILLGC)
				D.gc_destroyed = world.time
				return
			if(QDEL_HINT_LETMELIVE)	//qdel should let the object live after calling destory.
				if(!force)
					D.gc_destroyed = null //clear the gc variable (important!)
					return
				// Returning LETMELIVE after being told to force destroy
				// indicates the objects Destroy() does not respect force
				#ifdef TESTING
				if(!I.no_respect_force)
					crash_with("WARNING: [D.type] has been force deleted, but is \
						returning an immortal QDEL_HINT, indicating it does \
						not respect the force flag for qdel(). It has been \
						placed in the queue, further instances of this type \
						will also be queued.")
				#endif
				I.no_respect_force++

				SSgarbage.Queue(D)
			if(QDEL_HINT_HARDDEL)		//qdel should assume this object won't gc, and queue a hard delete using a hard reference to save time from the locate()
				GC_CHECK_AM_NULLSPACE(D, "QDEL_HINT_HARDDEL")
				SSgarbage.Queue(D, GC_QUEUE_HARDDELETE)
			if(QDEL_HINT_HARDDEL_NOW)	//qdel should assume this object won't gc, and hard del it post haste.
				SSgarbage.HardDelete(D)
			if(QDEL_HINT_FINDREFERENCE)//qdel will, if TESTING is enabled, display all references to this object, then queue the object for deletion.
				SSgarbage.Queue(D)
				#ifdef TESTING
				D.find_references()
				#endif
			if (QDEL_HINT_IFFAIL_FINDREFERENCE) //qdel will, if TESTING is enabled and the object fails to collect, display all references to this object.
				SSgarbage.Queue(D)
				#ifdef TESTING
				SSgarbage.reference_find_on_fail["\ref[D]"] = TRUE
				#endif
			else
				#ifdef TESTING
				if(!I.no_hint)
					log_to_dd("WARNING: [D.type] is not returning a qdel hint. It is being placed in the queue. Further instances of this type will also be queued.")
				#endif
				I.no_hint++
				SSgarbage.Queue(D)
	else if(D.gc_destroyed == GC_CURRENTLY_BEING_QDELETED)
		CRASH("[D.type] destroy proc was called multiple times, likely due to a qdel loop in the Destroy logic")

#ifdef TESTING

/datum/verb/find_refs()
	set category = "Debug"
	set name = "Find References"
	set src in world

	find_references(FALSE)

/datum/proc/find_references(skip_alert)
	running_find_references = type
	if(usr && usr.client)
		if(usr.client.running_find_references)
			testing("CANCELLED search for references to a [usr.client.running_find_references].")
			usr.client.running_find_references = null
			running_find_references = null
			//restart the garbage collector
			SSgarbage.can_fire = TRUE
			SSgarbage.next_fire = world.time + world.tick_lag
			return

		if(!skip_alert)
			if(alert("Running this will lock everything up for about 5 minutes.  Would you like to begin the search?", "Find References", "Yes", "No") == "No")
				running_find_references = null
				return

	//this keeps the garbage collector from failing to collect objects being searched for in here
	SSgarbage.can_fire = FALSE

	if(usr?.client)
		usr.client.running_find_references = type

	testing("Beginning search for references to a [type].")

	var/starting_time = world.time

	DoSearchVar(GLOB, "GLOB") //globals
	for(var/datum/thing in world) //atoms (don't believe its lies)
		DoSearchVar(thing, "World -> [thing.type]", search_time = starting_time)

	for(var/datum/thing) //datums
		DoSearchVar(thing, "Datums -> [thing.type]", search_time = starting_time)

	for(var/client/thing) //clients
		DoSearchVar(thing, "Clients -> [thing.type]", search_time = starting_time)

	testing("Completed search for references to a [type].")
	if(usr?.client)
		usr.client.running_find_references = null
	running_find_references = null

	//restart the garbage collector
	SSgarbage.can_fire = TRUE
	SSgarbage.next_fire = world.time + world.tick_lag

/datum/verb/qdel_then_find_references()
	set category = "Debug"
	set name = "qdel() then Find References"
	set src in world

	qdel(src, TRUE)		//Force.
	if(!running_find_references)
		find_references(TRUE)

/datum/verb/qdel_then_if_fail_find_references()
	set category = "Debug"
	set name = "qdel() then Find References if GC failure"
	set src in world

	qdel_and_find_ref_if_fail(src, TRUE)

//Byond type ids
#define TYPEID_NULL "0"
#define TYPEID_NORMAL_LIST "f"
//helper macros
#define GET_TYPEID(ref) ( ( (length(ref) <= 10) ? "TYPEID_NULL" : copytext(ref, 4, length(ref)-6) ) )
#define IS_NORMAL_LIST(L) (GET_TYPEID("\ref[L]") == TYPEID_NORMAL_LIST)

/datum/proc/DoSearchVar(potential_container, container_name, recursive_limit = 64, search_time = world.time)
	#ifdef REFERENCE_TRACKING_DEBUG
	if(!found_refs)
		found_refs = list()
	#endif

	if(usr?.client && !usr.client.running_find_references)
		return

	if (!recursive_limit)
		testing("Recursion limit reached. [container_name]")
		return

	if(istype(potential_container, /datum))
		var/datum/datum_container = potential_container
		if(datum_container.last_find_references == search_time)
			return

		datum_container.last_find_references = search_time
		var/list/vars_list = datum_container.vars

		for(var/varname in vars_list)
			if (varname == "vars")
				continue
			var/variable = vars_list[varname]

			if(variable == src)
				#ifdef REFERENCE_TRACKING_DEBUG
				found_refs[varname] = TRUE
				#endif
				testing("Found [type] \ref[src] in [datum_container.type]'s \ref[datum_container] [varname] var. [container_name]")

			else if(islist(variable))
				DoSearchVar(variable, "[container_name] \ref[datum_container] -> [varname] (list)", recursive_limit - 1, search_time)

	else if(islist(potential_container))
		var/normal = IS_NORMAL_LIST(potential_container)
		for(var/element_in_list in potential_container)
			// Check normal entrys
			if(element_in_list == src)
				#ifdef REFERENCE_TRACKING_DEBUG
				found_refs[potential_container] = TRUE
				#endif
				testing("Found [type] \ref[src] in list [container_name].")

			//Check assoc entrys
			else if(element_in_list && !isnum(element_in_list) && normal && potential_container[element_in_list] == src)
				#ifdef REFERENCE_TRACKING_DEBUG
				found_refs[potential_container] = TRUE
				#endif
				testing("Found [type] \ref[src] in list [container_name]\[[element_in_list]\]")

			//Check normal sublists
			else if(islist(element_in_list))
				DoSearchVar(element_in_list, "[container_name] -> [element_in_list] (list)", recursive_limit - 1, search_time)

			//Check assoc sublists
			else if(element_in_list && !isnum(element_in_list) && normal && islist(potential_container[element_in_list]))
				DoSearchVar(potential_container[element_in_list], "[container_name]\[[element_in_list]\] -> [potential_container[element_in_list]] (list)", recursive_limit - 1, search_time)

	#ifndef FIND_REF_NO_CHECK_TICK
	CHECK_TICK
	#endif

#endif
