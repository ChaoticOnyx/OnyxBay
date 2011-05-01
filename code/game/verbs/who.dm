/mob/verb/who()
	set name = "Who"

	usr << "<b>Current Players:</b>"

	var/list/peeps = list()

	for (var/client/C)
		if (C.stealth && !usr.client.holder)
			peeps += "\t[C.fakekey]"
		else
			peeps += "\t[C][C.stealth ? " <i>(as [C.fakekey])</i>" : ""]"

	peeps = sortList(peeps)

	for (var/p in peeps)
		usr << p

	usr << "<b>Total Players: [length(peeps)]</b>"

/client/verb/adminwho()
	set category = "Commands"

	usr << "<b>Current Nobles :</b>"

	for (var/client/C)
		if(C.holder)
			if(usr.client.holder)
				usr << "[C.mob.key] is a [C.holder.rank][C.stealth ? " <i>(as [C.fakekey])</i>" : ""]"
			else if(!C.stealth)
				usr << "\t[pick(nobles)] [C]"

var/list/nobles = list("Baron","Bookkeeper","Captain of the Guard","Chief medical dwarf","Count","Dungeon master","Duke","General","Mayor","Outpost liaison","Sheriff","Champion")