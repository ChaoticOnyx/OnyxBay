SUBSYSTEM_DEF(virus)
	name = "Virus Processing System"
	priority = SS_PRIORITY_VIRUSES
	flags = SS_NO_INIT
	wait = 1

	var/list/viruses_life = list()              // Queue of viruses to life
	var/position = 1                            // Helper index to order newly activated viruses properly

/datum/controller/subsystem/virus/stat_entry()
	..("C:[viruses_life.len]")

/datum/controller/subsystem/virus/fire(resumed = FALSE)
	if(paused_ticks >= 10) // The likeliest fail mode, due to the fast tick rate, is that it can never clear the full queue, running resumed every tick and accumulating a backlog.
		log_and_message_admins(SPAN_DANGER("Alert. [name] report <b>LEVEL ONE DEFCON</b>, automatically attempt to avoid server lags by disabling viruses."))
		disable()          // As this SS deals with optional and potentially abusable content, it will autodisable if overtaxing the server.
		return

	var/list/viruses_life = src.viruses_life
	while(length(viruses_life))
		var/list/entry = viruses_life[viruses_life.len]
		position = viruses_life.len
		viruses_life.len--
		if(!length(entry))
			if(MC_TICK_CHECK)
				break
			continue

		var/datum/disease2/disease/circuit = entry[1]
		entry.Cut(1,2)
		if(QDELETED(circuit))
			if(MC_TICK_CHECK)
				break
			continue

		circuit.process()
		if(MC_TICK_CHECK)
			break
	position = null

/datum/controller/subsystem/virus/disable()
	..()
	viruses_life.Cut()
	log_and_message_admins("[name] has been disabled.")

/datum/controller/subsystem/virus/enable()
	..()
	log_and_message_admins("[name] processing has been enabled.")

// Store the entries like this so that components can be queued multiple times at once.
// With immediate set, will generally imitate the order of the call stack if execution happened directly.
// With immediate off, you go to the bottom of the pile.
/datum/controller/subsystem/virus/proc/queue_virus(datum/disease2/disease/circuit, immediate = TRUE)
	if(!can_fire)
		return
	var/list/entry = list(circuit) + args.Copy(3)
	if(!immediate || !position)
		viruses_life.Insert(1, list(entry))
		if(position)
			position++
	else
		viruses_life.Insert(position, list(entry))

/datum/controller/subsystem/virus/proc/dequeue_virus(datum/disease2/disease/circuit)
	var/i = 1
	while(i <= length(viruses_life)) // Either i increases or length decreases on every iteration.
		var/list/entry = viruses_life[i]
		if(length(entry) && entry[1] == circuit)
			viruses_life.Cut(i, i+1)
			if(position > i)
				position--
		else
			i++
