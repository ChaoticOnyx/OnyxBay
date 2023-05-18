// For instances where we don't want a design showing up due to it being for debug/sanity purposes
#define DESIGN_ID_IGNORE "IGNORE_THIS_DESIGN"

#define RESEARCH_MATERIAL_DESTROY_ID "__destroy"

//! Techweb names for new point types. Can be used to define specific point values for specific types of research (science, security, engineering, etc.)
#define TECHWEB_POINT_TYPE_GENERIC "General Research"
#define TECHWEB_POINT_TYPE_GENERIC_ENGINEERING "General Research"
#define TECHWEB_POINT_TYPE_GENERIC "General Research"
#define TECHWEB_POINT_TYPE_GENERIC "General Research"

#define TECHWEB_POINT_TYPE_DEFAULT TECHWEB_POINT_TYPE_GENERIC

#define TECHWEB_POINT_TYPE_MATERIAL "Materials Research"
#define TECHWEB_POINT_TYPE_ENGINEERING "Engineering Research"
#define TECHWEB_POINT_TYPE_PLASMA "Plasmatech Research"
#define TECHWEB_POINT_TYPE_POWER "Powerstorage Research"
#define TECHWEB_POINT_TYPE_BLUESPACE "Bluespace Research"
#define TECHWEB_POINT_TYPE_BIO "Biotech Research"
#define TECHWEB_POINT_TYPE_COMBAT "Combat Research"
#define TECHWEB_POINT_TYPE_MAGNET "Magnets Research"
#define TECHWEB_POINT_TYPE_DATA "Programming Research"
#define TECHWEB_POINT_TYPE_ILLEGAL "Illegal Research"
#define TECHWEB_POINT_TYPE_ARCANE "Arcane Research"

//! Associative names for techweb point values, see: [all_nodes][code/modules/research/techweb/all_nodes.dm]
#define TECHWEB_POINT_TYPE_LIST_ASSOCIATIVE_NAMES list(\
	TECHWEB_POINT_TYPE_GENERIC = "General Research",\
	TECHWEB_POINT_TYPE_MATERIAL = "Materials Research",\
	TECHWEB_POINT_TYPE_ENGINEERING = "Engineering Research",\
	TECHWEB_POINT_TYPE_PLASMA = "Plasmatech Research",\
	TECHWEB_POINT_TYPE_POWER = "Powerstorage Research",\
	TECHWEB_POINT_TYPE_BLUESPACE = "Bluespace Research",\
	TECHWEB_POINT_TYPE_BIO = "Biotech Research",\
	TECHWEB_POINT_TYPE_COMBAT = "Combat Research",\
	TECHWEB_POINT_TYPE_MAGNET = "Magnets Research",\
	TECHWEB_POINT_TYPE_DATA = "Programming Research",\
	TECHWEB_POINT_TYPE_ILLEGAL = "Illegal Research",\
	TECHWEB_POINT_TYPE_ARCANE = "Arcane Research",\
	)

//! Amount of points gained per second by a single R&D server, see: [research][code/controllers/subsystem/research.dm]
#define TECHWEB_SINGLE_SERVER_INCOME 52.3

#define SHEET_MATERIAL_AMOUNT 2000

#define IMPRINTER	0x1	//For circuits. Uses glass/chemicals.
#define PROTOLATHE	0x2	//New stuff. Uses glass/metal/chemicals
#define MECHFAB		0x4	//Mechfab
#define CHASSIS		0x8	//For protolathe, but differently
