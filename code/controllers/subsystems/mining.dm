#define SIGNAL_CARGO_MINING_NEW_ARGS "cargo_mining_new_args"

#define MINING_BASE_REWARD     1
#define MINING_REWARD_EXPONENT 1.1

#define MINING_MULT_FNV1A   0.6
#define MINING_MULT_MURMUR  0.8
#define MINING_MULT_XXHASH  1.0
#define MINING_MULT_BLAKE2S 1.5
#define MINING_MULT_SHA256  2.0

/// ~25% chance
#define DIFF_LEVEL_1 0x40000000
/// 12.5% chance
#define DIFF_LEVEL_2 0x20000000
/// ~6% chance
#define DIFF_LEVEL_3 0x10000000
/// 3% chance
#define DIFF_LEVEL_4 0x08000000
/// ~1.5% chance
#define DIFF_LEVEL_5 0x04000000
/// ~0.4% chance
#define DIFF_LEVEL_6 0x01000000
/// ~0.1% chance
#define DIFF_LEVEL_7 0x00400000
/// ~0.02% chance
#define DIFF_LEVEL_8 0x00100000

#define MINING_DIFFICULTY_WINDOW    10
#define MINING_TARGET_BLOCK_TIME    150
#define MINING_ADJUSTMENT_INTERVAL  300
#define MINING_MAX_DIFFICULTY_LEVEL 8
#define MINING_MIN_DIFFICULTY_LEVEL 1

#define MINING_THRESHOLD_TOO_FAST 0.5
#define MINING_THRESHOLD_TOO_SLOW 2.0

SUBSYSTEM_DEF(mining)
	name = "Mining"
	priority = SS_PRIORITY_MINING
	wait = 10 SECONDS

	var/list/difficulty_levels = list(
		DIFF_LEVEL_1,
		DIFF_LEVEL_2,
		DIFF_LEVEL_3,
		DIFF_LEVEL_4,
		DIFF_LEVEL_5,
		DIFF_LEVEL_6,
		DIFF_LEVEL_7,
		DIFF_LEVEL_8,
	)
	
	var/list/algo_multipliers
	var/list/algo_names

	var/current_hash_algo
	var/current_seed
	var/current_difficulty
	var/current_diff_level = MINING_MIN_DIFFICULTY_LEVEL
	var/list/cargo_args

	var/list/block_timestamps = list()
	var/total_blocks_found = 0
	var/last_adjustment_time = 0
	var/total_rewards_paid = 0

/datum/controller/subsystem/mining/Initialize()
	algo_multipliers = list(
		"[Z_MINING_BLOCK_POW_HASH_FNV1A]"        = MINING_MULT_FNV1A,
		"[Z_MINING_BLOCK_POW_HASH_MURMUR_HASH3]" = MINING_MULT_MURMUR,
		"[Z_MINING_BLOCK_POW_HASH_XX_HASH]"      = MINING_MULT_XXHASH,
		"[Z_MINING_BLOCK_POW_HASH_BLAKE2S]"      = MINING_MULT_BLAKE2S,
		"[Z_MINING_BLOCK_POW_HASH_SHA256]"       = MINING_MULT_SHA256
	)

	algo_names = list(
		"[Z_MINING_BLOCK_POW_HASH_FNV1A]"        = "FNV-1a",
		"[Z_MINING_BLOCK_POW_HASH_MURMUR_HASH3]" = "MurmurHash3",
		"[Z_MINING_BLOCK_POW_HASH_XX_HASH]"      = "xxHash",
		"[Z_MINING_BLOCK_POW_HASH_BLAKE2S]"      = "BLAKE2s",
		"[Z_MINING_BLOCK_POW_HASH_SHA256]"       = "SHA-256"
	)

	last_adjustment_time = world.time
	regenerate_challenge()

	return ..()

/datum/controller/subsystem/mining/fire()
	check_difficulty_adjustment()

/datum/controller/subsystem/mining/stat_entry()
	if(current_hash_algo == null || current_seed == null || current_difficulty == null)
		return ..()

	var/avg_time = calculate_average_block_time()
	
	var/msg = "TB:[total_blocks_found] "
	msg += "TRP:[total_rewards_paid] "
	msg += "CDL:[current_diff_level] "
	msg += "ALG:[algo_names["[current_hash_algo]"] || "Unknown"] "
	msg += "AVG:[avg_time] "
	msg += "TBT:[MINING_TARGET_BLOCK_TIME] "
	msg += "EXP:[calculate_reward(current_hash_algo, current_difficulty)] "

	return ..(msg)

/datum/controller/subsystem/mining/proc/regenerate_challenge()
	current_hash_algo = pick(                 \
		Z_MINING_BLOCK_POW_HASH_FNV1A,        \
		Z_MINING_BLOCK_POW_HASH_MURMUR_HASH3, \
		Z_MINING_BLOCK_POW_HASH_BLAKE2S,      \
		Z_MINING_BLOCK_POW_HASH_XX_HASH,      \
		Z_MINING_BLOCK_POW_HASH_SHA256        \
	)

	current_seed = rand(0, 0x7FFFFFFF)
	current_difficulty = difficulty_levels[current_diff_level]
	
	cargo_args = list(
		Z_MINING_BLOCK_ALGORITHM_POW,
		current_hash_algo,
		current_seed,
		current_difficulty
	)

	SEND_GLOBAL_SIGNAL(SIGNAL_CARGO_MINING_NEW_ARGS, cargo_args)

/datum/controller/subsystem/mining/proc/on_block_found()
	var/reward = calculate_reward(current_hash_algo, current_difficulty)

	total_blocks_found++
	total_rewards_paid += reward
	record_block_timestamp()

	current_seed = rand(0, 0x7FFFFFFF)
	cargo_args[3] = current_seed

	SEND_GLOBAL_SIGNAL(SIGNAL_CARGO_MINING_NEW_ARGS, cargo_args)
	
	return reward

/datum/controller/subsystem/mining/proc/record_block_timestamp()
	block_timestamps += world.time
	
	while(length(block_timestamps) > MINING_DIFFICULTY_WINDOW)
		block_timestamps.Cut(1, 2)

/datum/controller/subsystem/mining/proc/check_difficulty_adjustment()
	if(world.time - last_adjustment_time < MINING_ADJUSTMENT_INTERVAL)
		return

	last_adjustment_time = world.time

	if(!length(block_timestamps))
		if(decrease_difficulty())
			regenerate_challenge()

		return

	var/avg_block_time = calculate_average_block_time()
	
	var/last_block_time = block_timestamps[length(block_timestamps)]
	var/time_since_last = (world.time - last_block_time) / 10
	
	var/effective_avg = max(avg_block_time, time_since_last)

	if(effective_avg <= 0)
		return

	var/time_ratio = effective_avg / MINING_TARGET_BLOCK_TIME
	var/old_level = current_diff_level

	if(time_ratio < MINING_THRESHOLD_TOO_FAST)
		increase_difficulty()
	else if(time_ratio > MINING_THRESHOLD_TOO_SLOW)
		decrease_difficulty()

	if(old_level != current_diff_level)
		regenerate_challenge()

/datum/controller/subsystem/mining/proc/calculate_average_block_time()
	if(length(block_timestamps) < 2)
		return 0

	var/first_time = block_timestamps[1]
	var/last_time = block_timestamps[length(block_timestamps)]
	var/total_time = (last_time - first_time) / 10
	var/block_count = length(block_timestamps) - 1

	return total_time / block_count

/datum/controller/subsystem/mining/proc/increase_difficulty()
	if(current_diff_level >= MINING_MAX_DIFFICULTY_LEVEL)
		return FALSE
	
	current_diff_level++
	current_difficulty = difficulty_levels[current_diff_level]
	
	return TRUE

/datum/controller/subsystem/mining/proc/decrease_difficulty()
	if(current_diff_level <= MINING_MIN_DIFFICULTY_LEVEL)
		return FALSE
	
	current_diff_level--
	current_difficulty = difficulty_levels[current_diff_level]
	
	return TRUE

/datum/controller/subsystem/mining/proc/get_difficulty_level(difficulty)
	for(var/i = length(difficulty_levels), i >= 1, i--)
		if(difficulty <= difficulty_levels[i])
			return i

	return 1

/datum/controller/subsystem/mining/proc/calculate_reward(hash_algo, difficulty)
	var/diff_level = get_difficulty_level(difficulty)
	var/diff_mult = diff_level ** MINING_REWARD_EXPONENT
	var/algo_mult = algo_multipliers["[hash_algo]"] || 1.0
	var/reward = MINING_BASE_REWARD * diff_mult * algo_mult
	
	return max(1, round(reward, 1))

#undef MINING_BASE_REWARD
#undef MINING_REWARD_EXPONENT

#undef MINING_MULT_FNV1A
#undef MINING_MULT_MURMUR
#undef MINING_MULT_XXHASH
#undef MINING_MULT_BLAKE2S
#undef MINING_MULT_SHA256

#undef DIFF_LEVEL_1
#undef DIFF_LEVEL_2
#undef DIFF_LEVEL_3
#undef DIFF_LEVEL_4
#undef DIFF_LEVEL_5
#undef DIFF_LEVEL_6
#undef DIFF_LEVEL_7
#undef DIFF_LEVEL_8

#undef MINING_DIFFICULTY_WINDOW
#undef MINING_TARGET_BLOCK_TIME
#undef MINING_ADJUSTMENT_INTERVAL
#undef MINING_MAX_DIFFICULTY_LEVEL
#undef MINING_MIN_DIFFICULTY_LEVEL

#undef MINING_THRESHOLD_TOO_FAST
#undef MINING_THRESHOLD_TOO_SLOW
