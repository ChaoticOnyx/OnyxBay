/obj/map_ent/logic_relay
	name = "logic_relay"
	icon_state = "logic_relay"

	var/ev_tags = list()

/obj/map_ent/logic_relay/activate()
	for(var/tag in ev_tags)
		var/obj/map_ent/E = locate(tag)

		if(!istype(E))
			crash_with("tag `[tag]` is invalid")
			continue
		
		E.activate()
