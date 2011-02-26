/datum/taobj
	var/name
	var/desc
	var/datum/taobj/loc
	var/list/datum/taobj/contents = list()
	var/list/tags = list()



/datum/taobj/proc/Move(var/datum/taobj/newloc)
	if(loc)
		loc.contents.Remove(name)
	loc = newloc
	newloc.contents[name]=src




/datum/textadv
	var/list/datum/taobj/objects = list()
	var/datum/taobj/player

/datum/textadv/New()
	var/datum/taobj/p = new()
	p.name = "YOURSELF"
	p.tags+="PLAYER"
	p.tags+="MOB"
	p.desc = "Handsome and brave looking."
	player = p
	var/datum/taobj/r = new()
	r.name = "CLEARING"
	r.tags+="ROOM"
	r.desc = "A wide clearing."
	player.Move(r)
	var/datum/taobj/c = new()
	c.name = "CHEST"
	c.desc = "A wooden chest"


	var/datum/taobj/s = new()
	s.name = "SWORD"
	s.tags+="ITEM"
	s.tags["WEAPON"] = 5
	s.desc = "A fine weapon."
	s.Move(c)
	c.Move(r)
	objects+=r
	objects+=p
	objects+=s
	objects+=c

/datum/textadv/proc/Do(var/msg as text)

	var/l = lentext(msg)
	//if(findtext(msg," ",l,l+1)==0)
	//	msg+=" "
	var/list/tokens = list()
	tokens = stringsplit(msg, " ")
	for(var/v in tokens)
		tokens[v]=uppertext(tokens[v])
		if(v=="AT"||v=="WITH"||v=="ON"||v=="IN")
			tokens.Remove(v)
	switch(tokens[1])
		if("LOOK","EXAMINE")
			if(tokens.len==1)
				return cLook(player.loc.name)
			else
				return cLook(tokens[2])
		if("TAKE","GET","PICKUP")
			if(tokens.len == 1)
				return "Take what?"
			else
				return cGet(tokens[2])
		else
			return "Unknown command"

/datum/textadv/proc/searchrec(var/datum/taobj/container, var/target,var/visible = 1)
	for(var/v in container.contents)
		if(v==target)
			return container.contents[v]
		else
			var/datum/taobj/other = container.contents[v]
			if(other.contents.len && !other.tags.Find("CLOSED"))
				var/datum/taobj/rec = searchrec(other,target,visible)
				if(rec)
					return rec
	return null

/datum/textadv/proc/cGet(var/target)
	var/datum/taobj/room = player.loc
	var/datum/taobj/object = null
	object=searchrec(room,target)
	if(object)
		if(object.tags.Find("ITEM"))
			object.Move(player)
			return "You take the [object.name]."
		else
			return "You can't take the [object.name]."
	else
		return "You can't see any [target] to take."


/datum/textadv/proc/cLook(var/target)
	var/datum/taobj/room = player.loc
	if(room.name==target)

		var/msg = "[room.desc]<br>In the [room.name] you can see:"
		for(var/v in room.contents)
			var/datum/taobj/o = room.contents[v]
			if(!o.tags.Find("INVISIBLE"))
				msg+="<br>	[o.name]"
		return msg
	else
		var/datum/taobj/object = searchrec(room,target)
		if(object)
			var/msg = "[object.desc]"
			if(object.contents.len && !object.tags.Find("CLOSED"))
				for(var/v in object.contents)
					msg+="<br>In the [object.name] you can see:"
					var/datum/taobj/o = object.contents[v]
					if(!o.tags.Find("INVISIBLE"))
						msg+="<br>	[o.name]"
			return msg
		else
			return "Can't see any [target]"



