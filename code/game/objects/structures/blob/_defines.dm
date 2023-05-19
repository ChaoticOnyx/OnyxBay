#define BLOB_MAX_DISTANCE_FROM_CORE 10
#define BLOB_MIN_CHANCE_TO_SPAWN 1

// Damage for a blob.
#define BLOB_EXPLOSION_BASE_DAMAGE 100
#define BLOB_WELDING_BASE_DAMAGE 55
#define BLOB_SHAPR_BASE_DAMAGE 20
#define BLOB_EDGE_BASE_DAMAGE 40
#define BLOB_BLUNT_BASE_DAMAGE 10
#define BLOB_DAMAGE_CAP 100

// Health regeneration.
/// In percents of max health.
#define BLOB_REGENERATION_MULTIPLIER 0.2
/// The distance in tiles where a blob regenerates by that multiplier without penalties.
#define BLOB_EFFICIENT_REGENERATION_DISTANCE 6

// Cooldowns.
#define BLOB_ATTACK_COOLDOWN 3 SECOND
#define BLOB_EXPAND_COOLODNW 5 SECONDS
#define BLOB_UPGRADE_COOLDOWN 10 SECONDS
#define BLOB_HEAL_COOLDOWN 5 SECOND

// Chances.
#define BLOB_EXPAND_CHANCE 13
#define BLOB_UPGRADE_CHANCE 15

// Default blob.
#define BLOB_HEALTH 40
#define BLOB_DAMAGE 3

// Reinforced blob.
#define BLOB_REINFORCED_HEALTH 60
#define BLOB_REINFORCED_DAMAGE 7

// Node blob.
#define BLOB_NODE_HEALTH 150
#define BLOB_NODE_DAMAGE 5

// Core blob.
#define BLOB_CORE_HEALTH 200
#define BLOB_CORE_DAMAGE 13

/*
	Structure:
	list(
		current_blob_type = list(
			new_type = chance_to_upgrade
		)
	)
*/
#define BLOB_UPGRADE_TREE list(\
	/obj/structure/blob = list(\
		/obj/structure/blob/node = 5,\
		/obj/structure/blob/reinforced = 20\
	),\
)
