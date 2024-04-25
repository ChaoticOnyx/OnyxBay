#define MATERIALS_ICON                   'icons/obj/materials.dmi'
#define MATERIAL_PLASTIC                 "plastic"
#define MATERIAL_PLASTEEL                "plasteel"
#define MATERIAL_STEEL                   "steel"
#define MATERIAL_GLASS                   "glass"
#define MATERIAL_GOLD                    "gold"
#define MATERIAL_SILVER                  "silver"
#define MATERIAL_DIAMOND                 "diamond"
#define MATERIAL_PLASMA                  "plasma"
#define MATERIAL_URANIUM                 "uranium"
#define MATERIAL_COTTON                  "cotton"
#define MATERIAL_CARBON                  "carbon"
#define MATERIAL_WOOD                    "wood"
#define MATERIAL_DARKWOOD                "darkwood"
#define MATERIAL_SANDSTONE               "sandstone"
#define MATERIAL_LEATHER                 "leather"
#define MATERIAL_IRON                    "iron"
#define MATERIAL_PLATINUM                "platinum"
#define MATERIAL_BRONZE                  "bronze"
#define MATERIAL_REINFORCED_GLASS        "rglass"
#define MATERIAL_PLASS                   "plass"
#define MATERIAL_REINFORCED_PLASS        "rplass"
#define MATERIAL_BLACK_GLASS             "bglass"
#define MATERIAL_REINFORCED_BLACK_GLASS  "rbglass"
#define MATERIAL_MARBLE                  "marble"
#define MATERIAL_RESIN                   "resin"
#define MATERIAL_CULT                    "cult"
#define MATERIAL_REINFORCED_CULT         "cult2"
#define MATERIAL_VOX                     "voxalloy"
#define MATERIAL_TITANIUM                "titanium"
#define MATERIAL_OSMIUM_CARBIDE_PLASTEEL "osmium-carbide plasteel"
#define MATERIAL_OSMIUM                  "osmium"
#define MATERIAL_HYDROGEN                "hydrogen"
#define MATERIAL_ADAMANTINE				 "adamantine"
#define MATERIAL_WASTE                   "waste"
#define MATERIAL_ELEVATORIUM             "elevatorium"
#define MATERIAL_ALIUMIUM                "aliumium"
#define MATERIAL_SAND                    "sand"
#define MATERIAL_GRAPHENE                "graphene"
#define MATERIAL_DEUTERIUM               "deuterium"
#define MATERIAL_TRITIUM                 "tritium"
#define MATERIAL_SUPERMATTER             "supermatter"
#define MATERIAL_PITCHBLENDE             "pitchblende"
#define MATERIAL_CARDBOARD               "cardboard"
#define MATERIAL_CLOTH                   "cloth"
#define MATERIAL_CARPET                  "carpet"
#define MATERIAL_THALAMUS                "thalamus"

#define DEFAULT_TABLE_MATERIAL MATERIAL_PLASTIC
#define DEFAULT_WALL_MATERIAL  MATERIAL_STEEL

#define MATERIAL_ALTERATION_NONE 0
#define MATERIAL_ALTERATION_NAME 1
#define MATERIAL_ALTERATION_DESC 2
#define MATERIAL_ALTERATION_COLOR 4
#define MATERIAL_ALTERATION_ALL (~MATERIAL_ALTERATION_NONE)

#define SHARD_SHARD "shard"
#define SHARD_SHRAPNEL "shrapnel"
#define SHARD_STONE_PIECE "piece"
#define SHARD_SPLINTER "splinters"
#define SHARD_SCRAP "scrap"
#define SHARD_NONE ""

#define MATERIAL_UNMELTABLE 0x1
#define MATERIAL_BRITTLE    0x2
#define MATERIAL_PADDING    0x4

#define TABLE_BRITTLE_MATERIAL_MULTIPLIER 4 // Amount table damage is multiplied by if it is made of a brittle material (e.g. glass)

/proc/get_icon_for_material(material)
	var/static/list/material_icons = list(
		MATERIAL_PLASTIC                    = icon(MATERIALS_ICON, "plastic"),
		MATERIAL_PLASTEEL                   = icon(MATERIALS_ICON, "plasteel"),
		MATERIAL_STEEL                      = icon(MATERIALS_ICON, "metal"),
		MATERIAL_GLASS                      = icon(MATERIALS_ICON, "glass"),
		MATERIAL_GOLD                       = icon(MATERIALS_ICON, "gold"),
		MATERIAL_SILVER                     = icon(MATERIALS_ICON, "silver"),
		MATERIAL_DIAMOND                    = icon(MATERIALS_ICON, "diamond"),
		MATERIAL_PLASMA                     = icon(MATERIALS_ICON, "solid_plasma"),
		MATERIAL_URANIUM                    = icon(MATERIALS_ICON, "uranium"),
		MATERIAL_COTTON                     = icon(MATERIALS_ICON, "cotton"),
		MATERIAL_CARBON                     = icon(MATERIALS_ICON, "carbon"),
		MATERIAL_WOOD                       = icon(MATERIALS_ICON, "wood"),
		MATERIAL_SANDSTONE                  = icon(MATERIALS_ICON, "sandstone"),
		MATERIAL_LEATHER                    = icon(MATERIALS_ICON, "leather"),
		MATERIAL_IRON                       = icon(MATERIALS_ICON, "iron"),
		MATERIAL_PLATINUM                   = icon(MATERIALS_ICON, "adamantine"),
		MATERIAL_ADAMANTINE					= icon(MATERIALS_ICON, "adamantine"),
		MATERIAL_BRONZE                     = icon(MATERIALS_ICON, "bronze"),
		MATERIAL_REINFORCED_GLASS           = icon(MATERIALS_ICON, "rglass"),
		MATERIAL_PLASS                      = icon(MATERIALS_ICON, "plass"),
		MATERIAL_REINFORCED_PLASS           = icon(MATERIALS_ICON, "rplass"),
		MATERIAL_MARBLE                     = icon(MATERIALS_ICON, "marble"),
		MATERIAL_TITANIUM                   = icon(MATERIALS_ICON, "titanium"),
		MATERIAL_OSMIUM_CARBIDE_PLASTEEL    = icon(MATERIALS_ICON, "plasteel"),
		MATERIAL_OSMIUM                     = icon(MATERIALS_ICON, "silver"),
		MATERIAL_HYDROGEN                   = icon(MATERIALS_ICON, "hydrogen"),
		MATERIAL_SAND                       = icon(MATERIALS_ICON, "sandstone"),
		MATERIAL_DEUTERIUM                  = icon(MATERIALS_ICON, "deuterium"),
		MATERIAL_TRITIUM                    = icon(MATERIALS_ICON, "tritium"),
		MATERIAL_CARDBOARD                  = icon(MATERIALS_ICON, "card"),
		MATERIAL_CLOTH                      = icon(MATERIALS_ICON, "cloth")
	)

	var/I = material_icons[material]

	if(!I)
		CRASH("[material] has no icon")

	return I

#undef MATERIALS_ICON
