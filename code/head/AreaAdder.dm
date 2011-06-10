obj/item/weapon/areaadd
	name = "Area something"
	icon = 'pda.dmi'
	icon_state = "cart"
	item_state = "electronic"
	var/turf/Xturf
	var/turf/Yturf
var/datum/areamanger/areaManger = new()
datum/areamanger
	var/count = 0
	var/list/areas = list()
obj/item/weapon/areaadd/attack_self(mob/user)
	if(Xturf && Yturf)
		var/newname = input(user,"Choose a name for the new area! Write Cancel to quit","Area","New Area")
		//if(newname == "Cancel" || newname == "cancel")
		//	Xturf = null
		//	Yturf = null
		var/list/turfs = block(Xturf,Yturf)
		if(turfs.len <= 0)
			user << "NO TURFS"
			return
		areaManger.count++
		if(areaManger.count > 10)
			user << "No more custom areas"
			return
		var/namer = Num2text2(areaManger.count)
		world << namer
		var/type = "/area/custom/"
		var/area/custom/NA = new type ()
		NA.name = newname
		for(var/turf/T in turfs)
			var/area/A = T.loc
			if(A.name != "Space")
				continue
			NA.contents += T
		Xturf = null
		Yturf = null
		user << "Area defined"
		return
	var/area/A = user.loc.loc
	if(!A)
		user << "Can't find an area"
		return
	if(A.name != "Space")
		user << "Can't find an area 2"
		return
	if(!Xturf)
		Xturf = user.loc
		user << "First Cord has been added."
	else if(!Yturf)
		Yturf = user.loc
		user << "Second cord has been added.."

obj/item/weapon/apcinabox
	name = "APC IN A BOX!"
	icon = 'items.dmi'
	icon_state = "game_kit"
obj/item/weapon/apcinabox/attack_self(mob/user)
	var/area/A = user.loc.loc
	if(!A)
		return
	if(!istype(A,/area/custom))
		user << "You can't do that here."
		return

	var/list/turfs = view(user,1)
	if(!locate(/turf/simulated/wall) in turfs)
		user << "No wall nerby"
		return
	var/obj/machinery/power/apc/P = new(user.loc)
	for(var/turf/simulated/wall/T in turfs)
		var/dir = get_dir(T,P)
		if(dir == 1 || dir == 2 || dir == 4 || dir == 8)

			P.dir = dir
			break
obj/machinery/verb/checkmachines()
	set src in view(5)
	if(machines.Find(src,1,0))
		usr << "Found it"
	else
		usr << "Nope"
area/
	var/iscustom = 0
area/custom/
area/custom/one
area/custom/two
area/custom/three
area/custom/four
area/custom/five
area/custom/six
area/custom/seven
area/custom/eight
area/custom/nine
area/custom/ten


var/datum/textnumbers/getnums = new()
datum/textnumbers
	var/list/numer = list("zero","one","two","three","four","five","six","seven","eight","nine","ten")
datum/textnumbers/proc/GetNum(var/num)
	return numer[num]
/proc/Num2text2(var/num)
	if(!getnums)
		getnums = new()
	var/hurr = getnums.GetNum(num)
	if(!hurr)
		return 0
	return hurr