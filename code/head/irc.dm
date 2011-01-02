obj/item/weapon/areaadd
	name = "Area something"
	icon = 'pda.dmi'
	icon_state = "cart"
	item_state = "electronic"
	var/turf/Xturf
	var/turf/Yturf
var/datum/areamanger/AM = new()
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
		AM.count++
		if(AM.count > 10)
			user << "No more custom areas"
			return
		var/namer = Num2text2(AM.count)
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
//	iscustom = 1
//	ul_Lighting = 1
/*area/custom/New()
	spawn(1)
		tag = name
		ul_Prep()
		if(findtext(tag,":UL") != 0)
			related += src
			return

		master = src
		related = list(src)

		src.icon = 'alert.dmi'
		src.layer = 10

		if(name == "Space")			// override defaults for space
			requires_power = 0

		if(!requires_power)
			power_light = 1
			power_equip = 1
			power_environ = 1
			//luminosity = 1
			ul_Lighting = 0			// *DAL*
		else
			luminosity = 0
			//ul_SetLuminosity(0)		// *DAL*


		spawn(15)
			src.power_change()		// all machines set to current power level, also updates lighting icon
			alldoors = get_doors(src)*/
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