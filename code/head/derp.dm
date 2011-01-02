mob/proc/cr_browsermap(zlevel=1,tilesizex=16,tilesizey=16,denytypes[0],windowname="map",browseopt="")
	////////Send the map to the mob's browser window
	var/filename="crmap[ckey].tmp"

	//Display "please wait" message
	src << browse("<body bgcolor=black text=white><p align=center>\
	<font size=5 face='Verdana'>...please wait...</font></body>","window=[windowname],\
	size=[min(world.maxx*16+50,630)]x[min(world.maxy*16+150,450)],[browseopt]")

	var/html="<html><body bgcolor=black><table border=0 cellspacing=0 cellpadding=0>"

	//If the temp. file exists, delete it
	if (fexists(filename)) fdel(filename)

	//Display everything in the world
	for (var/y=world.maxy,y>=0,y--)
		html+="</tr><tr>"
		text2file(html,filename)
		html=""
		sleep()
		for (var/x=1,x<=world.maxx,x++)
			//Turfs
			var/turf/simulated/T=locate(x,y,zlevel)
			if (!T) continue
			var/icon/I=icon(T.icon,T.icon_state)
			var/imgstring=dd_replacetext("[T.type]-[T.icon_state]","/","_")

			//Movable atoms
	/*		for (var/atom/movable/A in T)
				//Make sure it's allowed to be displayed
				var/allowed=1
				for (var/X in denytypes)
					if (istype(A,X))
						allowed=0
						break
				if (!allowed) continue

				if (A.icon) I.Blend(icon(A.icon,A.icon_state,A.dir),ICON_OVERLAY)
				imgstring+=dd_replacetext("__[A.type]_[A.icon_state]","/","_")*/

			//Output it
			src << browse_rsc(I,"[imgstring].dmi")
			html+="<td><img src=\"[imgstring].dmi\" width=[tilesizex] height=[tilesizey]></td>"

	text2file("</table></body></html>",filename)

	//Display it
	src << browse(file(filename),"window=[windowname],\
	size=[min(world.maxx*16+50,630)]x[min(world.maxy*16+150,450)],[browseopt]")