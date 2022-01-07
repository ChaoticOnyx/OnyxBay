/decl/hierarchy/supply_pack/materials
	name = "Materials"

/decl/hierarchy/supply_pack/materials/New()
	for(var/thing in contains)
		var/obj/item/stack/material/S = thing
		var/material/mat = SSmaterials.get_material_by_name(initial(S.default_type))
		if(istype(mat) && mat.sale_price)
			cost += mat.sale_price * initial(S.amount)
	..()

// Material sheets (50 - full stack)
/decl/hierarchy/supply_pack/materials/steel50
	name = "50 steel sheets"
	contains = list(/obj/item/stack/material/steel/fifty)
	cost = 10
	containername = "\improper Steel sheets crate"

/decl/hierarchy/supply_pack/materials/glass50
	name = "50 glass sheets"
	contains = list(/obj/item/stack/material/glass/fifty)
	cost = 10
	containername = "\improper Glass sheets crate"

/decl/hierarchy/supply_pack/materials/wood50
	name = "50 wooden planks"
	contains = list(/obj/item/stack/material/wood/fifty)
	cost = 10
	containername = "\improper Wooden planks crate"

/decl/hierarchy/supply_pack/materials/plastic50
	name = "50 plastic sheets"
	contains = list(/obj/item/stack/material/plastic/fifty)
	cost = 10
	containername = "\improper Plastic sheets crate"

/decl/hierarchy/supply_pack/materials/marble50
	name = "50 slabs of marble"
	contains = list(/obj/item/stack/material/marble/fifty)
	cost = 20
	containername = "\improper Marble slabs crate"

/decl/hierarchy/supply_pack/materials/plasteel50
	name = "50 plasteel sheets"
	contains = list(/obj/item/stack/material/plasteel/fifty)
	cost = 20
	containername = "\improper Plasteel sheets crate"

/decl/hierarchy/supply_pack/materials/ocp50
	name = "50 osmium carbide plasteel sheets"
	contains = list(/obj/item/stack/material/ocp/fifty)
	cost = 20
	containername = "\improper Osmium carbide plasteel sheets crate"

// Material sheets (10 - Smaller amounts, less cost efficient)
/decl/hierarchy/supply_pack/materials/marble10
	name = "10 slabs of marble"
	contains = list(/obj/item/stack/material/marble/ten)
	cost = 20
	containername = "\improper Marble slabs crate"

/decl/hierarchy/supply_pack/materials/plasteel10
	name = "10 plasteel sheets"
	contains = list(/obj/item/stack/material/plasteel/ten)
	cost = 10
	containername = "\improper Plasteel sheets crate"

/decl/hierarchy/supply_pack/materials/ocp10
	name = "10 osmium carbide plasteel sheets"
	contains = list(/obj/item/stack/material/ocp/ten)
	cost = 20
	containername = "\improper Osmium carbide plasteel sheets crate"

// Material sheets of expensive materials. These are very expensive and therefore pretty hard
// to get without mining crew that would bring materials to sell in exchange.
/decl/hierarchy/supply_pack/materials/plasma10
	name = "10 plasma sheets"
	contains = list(/obj/item/stack/material/plasma/ten)
	cost = 20 // When sold yields 67 points.
	containername = "\improper Plasma sheets crate"

/decl/hierarchy/supply_pack/materials/gold10
	name = "10 gold sheets"
	contains = list(/obj/item/stack/material/gold/ten)
	cost = 20
	containername = "\improper Gold sheets crate"

/decl/hierarchy/supply_pack/materials/silver10
	name = "10 silver sheets"
	contains = list(/obj/item/stack/material/silver/ten)
	cost = 20
	containername = "\improper Silver sheets crate"

/decl/hierarchy/supply_pack/materials/uranium10
	name = "10 uranium sheets"
	contains = list(/obj/item/stack/material/uranium/ten)
	cost = 20
	containername = "\improper Uranium sheets crate"

/decl/hierarchy/supply_pack/materials/diamond10
	name = "10 diamond sheets"
	contains = list(/obj/item/stack/material/diamond/ten)
	cost = 20
	containername = "\improper Diamond sheets crate"
