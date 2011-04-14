#define trgrdsz 20
#define trgrdvw 5

/obj/landmark/mapload/travel

/datum/travgrid
	var/list/list/datum/travloc/grid[trgrdsz][trgrdsz]
	var/list/datum/travevent/events = new
	var/datum/travevent/ship/Luna
	var/list/messagebacks = new

var/travlocsize = 50
var/travx
var/travy

var/datum/travgrid/tgrid= new()

/datum/travgrid/proc/Announce(var/msg)
	for(var/o in messagebacks)
		o:tAnnounce(msg)

/datum/travgrid/proc/Setup()
	for(var/a = 1 to trgrdsz)
		for(var/b = 1 to trgrdsz)
			var/datum/travloc/t = new/datum/travloc()
			t.x = a
			t.y = b
			t.grid = src
			src.grid[a][b]=t

	Luna = tgrid.MakeEvent(/datum/travevent/ship/Luna,rand(2)+5,5-rand(1))
	var/datum/travevent/met = tgrid.MakeEvent(/datum/travevent/meteor,Luna.loc.x,Luna.loc.y+3)
	met.yvel = -0.5
	for(var/i = 1 to 20)
		var/a = rand(1,trgrdsz)
		var/b = rand(1,trgrdsz)
		var/datum/travloc/t = grid[a][b]
		if(t==Luna.loc)
			break
		var/datum/travevent/m = tgrid.MakeEvent(/datum/travevent/meteor,a,b)
		m.yvel = rand(-10,10)/10
		m.xvel = rand(-10,10)/10
	Luna.pic.icon = icon('travel.dmi',"luna",EAST)


/datum/travgrid/proc/Tick()
	for(var/datum/travevent/t in events)
		t.Update()
	return 1

/datum/travgrid/proc/MakeEvent(var/type,var/x,var/y)
	var/datum/travevent/t = new type
	var/datum/travloc/l = src.grid[x][y]
	l.contents.Add(t)
	t.loc = grid[x][y]
	events+=t
	t.Move(t.loc)
	return t


/datum/travloc
	var/x
	var/y
	var/list/datum/travevent/contents = new
	var/datum/travgrid/grid

/datum/travloc/proc/Interface(var/mob/m)
	var/dat
	dat+="Grid [x]-[y]<BR>"
	dat+="<BR>Notable entities:"
	if(contents.len)
		for(var/datum/travevent/t in contents)
			dat+="<BR>[t.Info()]"
	else
		dat+="<BR>None"
	m << browse(dat, "window=data;size=400x500")
	onclose(m, "data")

/datum/travevent
	var/x = 0
	var/y = 0  //Location internal coordinates, for deciding when to move
	var/datum/travloc/loc
	var/xvel = 0
	var/yvel = 0
	var/icon/pic
	var/name

/datum/travevent/ship
	var/speed = 0
	var/bearing = 0
	var/lidc = 0
	var/dir = EAST
	var/brake = 0
	name = "Ship"

/datum/travevent/meteor
	name = "Meteor shower"
	var/density
	var/grace = 0

/datum/travevent/New()
	pic = new()
	pic.icon = 'travel.dmi'

/datum/travevent/proc/Move(var/datum/travloc/newloc)
	for(var/datum/travevent/t in loc.contents)
		Cleared(t)
		t.Cleared(src)
	loc.contents.Remove(src)
	loc = newloc
	loc.contents.Add(src)
	for(var/datum/travevent/t in loc.contents)
		Entered(t)
		t.Entered(src)


/datum/travevent/proc/Interact(var/datum/travevent/t)
	t.Interacted(src)

/datum/travevent/proc/Interacted(var/datum/travevent/t)

/datum/travevent/proc/Info()
	var/dat
	dat += "<BR>[name]"
	dat += "<BR>Center of mass x,y [x],[y]"
	dat += "<BR>Velocity x,y [xvel],[yvel]"
	return dat

/datum/travevent/meteor/Info()
	var/dat = ..()
	dat += "<BR>Density [density]"
	return dat


/datum/travevent/proc/Update()
	x+=xvel
	y+=yvel
	if(x< -travlocsize)
		if(loc.x-1)
			Move(loc.grid.grid[loc.x-1][loc.y])
		x = x + travlocsize * 2
	if(y< -travlocsize)
		if(loc.y-1)
			Move(loc.grid.grid[loc.x][loc.y-1])
		y = y + travlocsize * 2
	if(x> travlocsize)
		if(loc.x!=trgrdsz)
			Move(loc.grid.grid[loc.x+1][loc.y])
		x = x - travlocsize * 2
	if(y> travlocsize)
		if(loc.y!=trgrdsz)
			Move(loc.grid.grid[loc.x][loc.y+1])
		y = y - travlocsize * 2
	if(loc.contents.len > 1)
		for(var/datum/travevent/t in loc.contents)
			Interact(t)

/datum/travevent/ship/Update()
	if(brake==1)
		if(xvel>0)
			xvel-=min(xvel,0.25)
		else
			xvel-=min(xvel,-0.25)
		if(yvel>0)
			yvel-=min(yvel,0.25)
		else
			yvel-=min(yvel,-0.25)
		if(!xvel&&!yvel)
			brake=0
	var/xadd = speed
	var/yadd = 0
	var/nxadd = xadd * cos(bearing) -yadd * sin(bearing)
	var/nyadd = xadd * sin(bearing) + yadd * cos(bearing)


	xvel+=round(nxadd,0.01)
	yvel+=-round(nyadd,0.01)
	return ..()

/datum/travevent/ship/proc/Turn(var/ang)
	bearing+=ang
	var/diff = bearing-lidc
	if(diff<=-45)
		dir = turn(dir,45)
		lidc-=45
	else if(diff>=45)
		dir = turn(dir,-45)
		lidc+=45
	pic = icon('travel.dmi',"luna",dir)

/datum/travevent/ship/New()
	..()
	pic = icon('travel.dmi',"luna")

/datum/travevent/proc/Cleared(var/datum/travevent/t)

/datum/travevent/proc/Entered(var/datum/travevent/t)

/datum/travevent/meteor/Entered(var/datum/travevent/t)
	if(istype(t,/datum/travevent/ship/Luna))
		grace = rand(3)+4
		loc.grid.Announce("The ship is now travelling through a meteor shower")

/datum/travevent/meteor/Cleared(var/datum/travevent/t)
	if(istype(t,/datum/travevent/ship/Luna))
		loc.grid.Announce("The ship has cleared the meteor shower")

/datum/travevent/meteor/New()
	..()
	density = rand(40)+15
	pic.icon= icon('travel.dmi',"meteor")

/datum/travevent/proc/Meteor(var/amt)

/datum/travevent/ship/Luna
	name = "Luna"
/datum/travevent/ship/Luna/Move()
	..()
	travx=loc.x
	travy=loc.y


/datum/travevent/ship/Luna/Meteor(var/amt)
	var/num = amt
	while(num>0)
		//world << "LOOOL"
		spawn(0)
			spawn_meteor()
		num--

/datum/travevent/meteor/Meteor(var/amt)
	density+=amt
/datum/travevent/meteor/Interact(var/datum/travevent/t)
	if(grace!=0)
		grace--
	else if(rand(4)==1)
		t.Meteor(1)
		density-=1
	//	world << "LOL"
		if(density<1)
			for(var/datum/travevent/te in loc.contents)
				Cleared(te)
			del src


/obj/machinery/computer/travel
	name = "Helm Control"
	icon = 'computer.dmi'
	icon_state = "steering"
	req_access = list(access_captain)
	var/datum/travevent/ship/Luna/Luna
	var/transmit = 1

/obj/machinery/computer/travel/New()
	spawn
		while(!Luna)
			if(tgrid.Luna)
				Luna=tgrid.Luna
				tgrid.messagebacks.Add(src)
			else
				sleep(10)
	..()
	if(!machines.Find(src))
		machines.Add(src)

/obj/machinery/computer/travel/attack_hand(var/mob/user)
	user.machine = src
	var/dat
	dat+="Map:"
	user << browse_rsc(icon('travel.dmi',"space"),"space.png")
	for(var/a = min(travy+trgrdvw,trgrdsz),a>=max(travy-trgrdvw,1),a--)
		dat+="<BR><TR>"
		for(var/b = max(travx-trgrdvw,1) to min(travx+trgrdvw,trgrdsz))
			var/icon/t = icon('travel.dmi',"space")
			var/nam = "space"
			var/datum/travloc/l = tgrid.grid[b][a]
			for(var/datum/travevent/d in l.contents)
				var/icon/i = d.pic
				i.Blend(t)
				t=i
				t.SwapColor(rgb(0,0,0,0),rgb(255,255,255,255))
				nam = "\ref[d]"
				user << browse_rsc(t,"[nam].png")
			dat+="<A href='?src=\ref[src];loc=\ref[l]'><img border=\"0\" src=\"[nam].png\"/></a>"
			dat+="</TD>"
		dat+="</TR>"
	dat+="<BR>"
	dat+="<BR>Current location: Grid [Luna.loc.x] - [Luna.loc.y]"
	dat+="<BR>Velocity x,y [Luna.xvel],[Luna.yvel]"
	dat+="<BR>Centre of mass x,y [Luna.x],[Luna.y]"
	var/bear = Luna.bearing%360
	if(bear<0)
		bear = 360+bear
	dat+="<BR>Bearing [bear] <A href='?src=\ref[src];b=22.5'>+</a> <A href='?src=\ref[src];b=-22.5'>-</a>"

	if(!Luna.brake)
		if(!Luna.speed)
			dat+="<BR><A href='?src=\ref[src];e=0.25'>Turn on engines</a>"
		else
			dat+="<BR><A href='?src=\ref[src];e=0'>Turn off engines</a>"
		dat+="<BR><A href='?src=\ref[src];brake=1;e=0'>Turn on autobraking</a>"
	else
		dat+="<BR><A href='?src=\ref[src];brake=0'>Turn off autobraking</a>"

	if(!transmit==1)
		dat+="<BR><A href='?src=\ref[src];t=1'>Turn on radio warnings</a>"
	else
		dat+="<BR><A href='?src=\ref[src];t=0'>Turn off radio warnings</a>"
	dat+="<BR><A href='?src=\ref[src];close=1'>Close</a>"
	user << browse(dat, "window=computer;size=500x500")
	onclose(user, "computer",src)


/obj/machinery/computer/travel/process()
	for (var/mob/M in viewers(1, src.loc))
		if (M.client && M.machine == src)
			src.attack_hand(M)

/obj/machinery/computer/travel/proc/tAnnounce(var/msg)
	if(transmit==1)
		radioalert("[msg]!","[src.name]")
	state(msg)

/obj/machinery/computer/travel/Topic(href, href_list)
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src
		if (href_list["loc"])
			var/datum/travloc/l = locate(href_list["loc"])
			l.Interface(usr)
		if (href_list["b"])
			var/ang = text2num(href_list["b"])
			Luna.Turn(ang)
		if (href_list["e"])
			var/speed = text2num(href_list["e"])
			Luna.speed = speed
		if (href_list["brake"])
			var/brake = text2num(href_list["brake"])
			Luna.brake = brake
		if (href_list["close"])
			if(usr.machine == src)
				usr.machine = null
				usr<<browse(null,"window=computer")
		if (href_list["t"])
			var/speed = text2num(href_list["t"])
			transmit = speed
		src.add_fingerprint(usr)
	src.updateUsrDialog()

	for (var/mob/M in viewers(1, src.loc))
		if (M.client && M.machine == src)
			src.attack_hand(M)
	return