/*

	New events system, by Sukasa
	 * Much easier to add to
	 * Very, very simple code, easy to maintain

*/


var/list/EventTypes = typesof(/datum/event) - /datum/event
var/datum/event/ActiveEvent = null
var/datum/event/LongTermEvent = null

/proc/SpawnEvent()
	if(ActiveEvent)
		return
	var/Type = pick(EventTypes)
	ActiveEvent = new Type()
	ActiveEvent.Announce()
	if (!ActiveEvent)
		return
	spawn(0)
		while (ActiveEvent.ActiveFor < ActiveEvent.Lifetime)
			ActiveEvent.Tick()
			ActiveEvent.ActiveFor++
			sleep(10)
		ActiveEvent.Die()
		del ActiveEvent


