#define BLOB_EXAPNDING_COOLDOWN 5 SECONDS

// Damage for a blob.
#define BLOB_EXPLOSION_BASE_DAMAGE 150
#define BLOB_WELDING_BASE_DAMAGE 15
#define BLOB_SHAPR_BASE_DAMAGE 5
#define BLOB_EDGE_BASE_DAMAGE 10
#define BLOB_BLUNT_BASE_DAMAGE 2

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
#define BLOB_FIRE_RESIST 1
#define BLOB_BRUTE_RESIST 1
#define BLOB_DAMAGE 1

// Reinforced blob.
#define BLOB_REINFORCED_HEALTH 80
#define BLOB_REINFORCED_FIRE_RESIST 4
#define BLOB_REINFORCED_BRUTE_RESIST 6
#define BLOB_REINFORCED_DAMAGE 3

// Node blob.
#define BLOB_NODE_HEALTH 150
#define BLOB_NODE_FIRE_RESIST 7
#define BLOB_NODE_BRUTE_RESIST 10
#define BLOB_NODE_DAMAGE 5

// Core blob.
#define BLOB_CORE_HEALTH 200
#define BLOB_CORE_FIRE_RESIST 3
#define BLOB_CORE_BRUTE_RESIST 4
#define BLOB_CORE_DAMAGE 6

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
