
/datum/construction_UI/table
	states = list(	"table",
					"table_middle",

					"tabledir&dir=1", "tabledir&dir=2", "tabledir&dir=4", "tabledir&dir=8",
					"tabledir&dir=5", "tabledir&dir=6", "tabledir&dir=9", "tabledir&dir=10",

					"table_1tilethick&dir=1", "table_1tilethick&dir=2", "table_1tilethick&dir=4", "table_1tilethick&dir=8",
					"table_1tilethick&dir=5", "table_1tilethick&dir=6", "table_1tilethick&dir=9", "table_1tilethick&dir=10",

					"table_1tileendtable&dir=1", "table_1tileendtable&dir=2", "table_1tileendtable&dir=4", "table_1tileendtable&dir=8")

	icon = 'structures.dmi'
	default_state = "table"

	var/obj/item/weapon/table_parts/parts
	var/turf/standing

/datum/construction_UI/table/New(atom/loc, mob/user, obj/item/weapon/table_parts/parts)
	if(istype(parts, /obj/item/weapon/table_parts/reinforced) && !istype(src, /datum/construction_UI/table/reinforced))
		new /datum/construction_UI/table/reinforced(loc, user, parts)
		del(src)
		return

	src.parts = parts
	standing = user.loc
	..()

/datum/construction_UI/table/Topic(href, href_list[])
	if(!user || !standing || !parts || user.loc != standing)
		del(src)
	else
		return ..()

/datum/construction_UI/table/build(state, dir)
	var/obj/table/T = new /obj/table(loc)
	T.icon_state = state
	T.dir = dir
	T.add_fingerprint(user)
	del(parts)





/datum/construction_UI/table/reinforced
	states = list(	"reinf_table",
					"reinf_middle",

					"reinf_tabledir&dir=1", "reinf_tabledir&dir=2", "reinf_tabledir&dir=4", "reinf_tabledir&dir=8",
					"reinf_tabledir&dir=5", "reinf_tabledir&dir=6", "reinf_tabledir&dir=9", "reinf_tabledir&dir=10",

					"reinf_1tilethick&dir=1", "reinf_1tilethick&dir=2", "reinf_1tilethick&dir=4", "reinf_1tilethick&dir=8",
					"reinf_1tilethick&dir=5", "reinf_1tilethick&dir=6", "reinf_1tilethick&dir=9", "reinf_1tilethick&dir=10",

					"reinf_1tileendtable&dir=1", "reinf_1tileendtable&dir=2", "reinf_1tileendtable&dir=4", "reinf_1tileendtable&dir=8")

	default_state = "reinf_table"

/datum/construction_UI/table/reinforced/build(state, dir)
	var/obj/table/reinforced/T = new /obj/table/reinforced(loc)
	T.icon_state = state
	T.dir = dir
	T.add_fingerprint(user)
	del(parts)