// rust_g.dm - DM API for rust_g extension library
//
// To configure, create a `rust_g.config.dm` and set what you care about from
// the following options:
//
// #define RUST_G "path/to/rust_g"
// Override the .dll/.so detection logic with a fixed path or with detection
// logic of your own.
//
// #define RUSTG_OVERRIDE_BUILTINS
// Enable replacement rust-g functions for certain builtins. Off by default.

#ifndef RUST_G
// Default automatic RUST_G detection.
// On Windows, looks in the standard places for `rust_g.dll`.
// On Linux, looks in `.`, `$LD_LIBRARY_PATH`, and `~/.byond/bin` for either of
// `librust_g.so` (preferred) or `rust_g` (old).

/* This comment bypasses grep checks */ /var/__rust_g

/proc/__detect_rust_g()
	if (world.system_type == UNIX)
		if (fexists("./librust_g.so"))
			// No need for LD_LIBRARY_PATH badness.
			return __rust_g = "./librust_g.so"
		else if (fexists("./rust_g"))
			// Old dumb filename.
			return __rust_g = "./rust_g"
		else if (fexists("[world.GetConfig("env", "HOME")]/.byond/bin/rust_g"))
			// Old dumb filename in `~/.byond/bin`.
			return __rust_g = "rust_g"
		else
			// It's not in the current directory, so try others
			return __rust_g = "librust_g.so"
	else
		return __rust_g = "rust_g"

#define RUST_G (__rust_g || __detect_rust_g())
#endif

// Handle 515 call() -> call_ext() changes
#if DM_VERSION >= 515
#define RUSTG_CALL call_ext
#else
#define RUSTG_CALL call
#endif

/// Gets the version of rust_g
/proc/rustg_get_version() return RUSTG_CALL(RUST_G, "get_version")()


/**
 * Sets up the Aho-Corasick automaton with its default options.
 *
 * The search patterns list and the replacements must be of the same length when replace is run, but an empty replacements list is allowed if replacements are supplied with the replace call
 * Arguments:
 * * key - The key for the automaton, to be used with subsequent rustg_acreplace/rustg_acreplace_with_replacements calls
 * * patterns - A non-associative list of strings to search for
 * * replacements - Default replacements for this automaton, used with rustg_acreplace
 */
#define rustg_setup_acreplace(key, patterns, replacements) RUSTG_CALL(RUST_G, "setup_acreplace")(key, json_encode(patterns), json_encode(replacements))

/**
 * Sets up the Aho-Corasick automaton using supplied options.
 *
 * The search patterns list and the replacements must be of the same length when replace is run, but an empty replacements list is allowed if replacements are supplied with the replace call
 * Arguments:
 * * key - The key for the automaton, to be used with subsequent rustg_acreplace/rustg_acreplace_with_replacements calls
 * * options - An associative list like list("anchored" = 0, "ascii_case_insensitive" = 0, "match_kind" = "Standard"). The values shown on the example are the defaults, and default values may be omitted. See the identically named methods at https://docs.rs/aho-corasick/latest/aho_corasick/struct.AhoCorasickBuilder.html to see what the options do.
 * * patterns - A non-associative list of strings to search for
 * * replacements - Default replacements for this automaton, used with rustg_acreplace
 */
#define rustg_setup_acreplace_with_options(key, options, patterns, replacements) RUSTG_CALL(RUST_G, "setup_acreplace")(key, json_encode(options), json_encode(patterns), json_encode(replacements))

/**
 * Run the specified replacement engine with the provided haystack text to replace, returning replaced text.
 *
 * Arguments:
 * * key - The key for the automaton
 * * text - Text to run replacements on
 */
#define rustg_acreplace(key, text) RUSTG_CALL(RUST_G, "acreplace")(key, text)

/**
 * Run the specified replacement engine with the provided haystack text to replace, returning replaced text.
 *
 * Arguments:
 * * key - The key for the automaton
 * * text - Text to run replacements on
 * * replacements - Replacements for this call. Must be the same length as the set-up patterns
 */
#define rustg_acreplace_with_replacements(key, text, replacements) RUSTG_CALL(RUST_G, "acreplace_with_replacements")(key, text, json_encode(replacements))

/**
 * This proc generates a cellular automata noise grid which can be used in procedural generation methods.
 *
 * Returns a single string that goes row by row, with values of 1 representing an alive cell, and a value of 0 representing a dead cell.
 *
 * Arguments:
 * * percentage: The chance of a turf starting closed
 * * smoothing_iterations: The amount of iterations the cellular automata simulates before returning the results
 * * birth_limit: If the number of neighboring cells is higher than this amount, a cell is born
 * * death_limit: If the number of neighboring cells is lower than this amount, a cell dies
 * * width: The width of the grid.
 * * height: The height of the grid.
 */
#define rustg_cnoise_generate(percentage, smoothing_iterations, birth_limit, death_limit, width, height) \
	RUSTG_CALL(RUST_G, "cnoise_generate")(percentage, smoothing_iterations, birth_limit, death_limit, width, height)

/**
 * This proc generates a grid of perlin-like noise
 *
 * Returns a single string that goes row by row, with values of 1 representing an turned on cell, and a value of 0 representing a turned off cell.
 *
 * Arguments:
 * * seed: seed for the function
 * * accuracy: how close this is to the original perlin noise, as accuracy approaches infinity, the noise becomes more and more perlin-like
 * * stamp_size: Size of a singular stamp used by the algorithm, think of this as the same stuff as frequency in perlin noise
 * * world_size: size of the returned grid.
 * * lower_range: lower bound of values selected for. (inclusive)
 * * upper_range: upper bound of values selected for. (exclusive)
 */
#define rustg_dbp_generate(seed, accuracy, stamp_size, world_size, lower_range, upper_range) \
	RUSTG_CALL(RUST_G, "dbp_generate")(seed, accuracy, stamp_size, world_size, lower_range, upper_range)


#define rustg_dmi_strip_metadata(fname) RUSTG_CALL(RUST_G, "dmi_strip_metadata")(fname)
#define rustg_dmi_create_png(path, width, height, data) RUSTG_CALL(RUST_G, "dmi_create_png")(path, width, height, data)
#define rustg_dmi_resize_png(path, width, height, resizetype) RUSTG_CALL(RUST_G, "dmi_resize_png")(path, width, height, resizetype)
/**
 * input: must be a path, not an /icon; you have to do your own handling if it is one, as icon objects can't be directly passed to rustg.
 *
 * output: json_encode'd list. json_decode to get a flat list with icon states in the order they're in inside the .dmi
 */
#define rustg_dmi_icon_states(fname) RUSTG_CALL(RUST_G, "dmi_icon_states")(fname)

#define rustg_file_read(fname) RUSTG_CALL(RUST_G, "file_read")(fname)
#define rustg_file_exists(fname) (RUSTG_CALL(RUST_G, "file_exists")(fname) == "true")
#define rustg_file_write(text, fname) RUSTG_CALL(RUST_G, "file_write")(text, fname)
#define rustg_file_append(text, fname) RUSTG_CALL(RUST_G, "file_append")(text, fname)
#define rustg_file_get_line_count(fname) text2num(RUSTG_CALL(RUST_G, "file_get_line_count")(fname))
#define rustg_file_seek_line(fname, line) RUSTG_CALL(RUST_G, "file_seek_line")(fname, "[line]")

#ifdef RUSTG_OVERRIDE_BUILTINS
	#define file2text(fname) rustg_file_read("[fname]")
	#define text2file(text, fname) rustg_file_append(text, "[fname]")
#endif

/// Returns the git hash of the given revision, ex. "HEAD".
#define rustg_git_revparse(rev) RUSTG_CALL(RUST_G, "rg_git_revparse")(rev)

/**
 * Returns the date of the given revision in the format YYYY-MM-DD.
 * Returns null if the revision is invalid.
 */
#define rustg_git_commit_date(rev) RUSTG_CALL(RUST_G, "rg_git_commit_date")(rev)

#define rustg_hash_string(algorithm, text) RUSTG_CALL(RUST_G, "hash_string")(algorithm, text)
#define rustg_hash_file(algorithm, fname) RUSTG_CALL(RUST_G, "hash_file")(algorithm, fname)
#define rustg_hash_generate_totp(seed) RUSTG_CALL(RUST_G, "generate_totp")(seed)
#define rustg_hash_generate_totp_tolerance(seed, tolerance) RUSTG_CALL(RUST_G, "generate_totp_tolerance")(seed, tolerance)

#define RUSTG_HASH_MD5 "md5"
#define RUSTG_HASH_SHA1 "sha1"
#define RUSTG_HASH_SHA256 "sha256"
#define RUSTG_HASH_SHA512 "sha512"
#define RUSTG_HASH_XXH64 "xxh64"
#define RUSTG_HASH_BASE64 "base64"

/// Encode a given string into base64
#define rustg_encode_base64(str) rustg_hash_string(RUSTG_HASH_BASE64, str)
/// Decode a given base64 string
#define rustg_decode_base64(str) RUSTG_CALL(RUST_G, "decode_base64")(str)

#ifdef RUSTG_OVERRIDE_BUILTINS
	#define md5(thing) (isfile(thing) ? rustg_hash_file(RUSTG_HASH_MD5, "[thing]") : rustg_hash_string(RUSTG_HASH_MD5, thing))
#endif

#define RUSTG_HTTP_METHOD_GET "get"
#define RUSTG_HTTP_METHOD_PUT "put"
#define RUSTG_HTTP_METHOD_DELETE "delete"
#define RUSTG_HTTP_METHOD_PATCH "patch"
#define RUSTG_HTTP_METHOD_HEAD "head"
#define RUSTG_HTTP_METHOD_POST "post"
#define rustg_http_request_blocking(method, url, body, headers, options) RUSTG_CALL(RUST_G, "http_request_blocking")(method, url, body, headers, options)
#define rustg_http_request_async(method, url, body, headers, options) RUSTG_CALL(RUST_G, "http_request_async")(method, url, body, headers, options)
#define rustg_http_check_request(req_id) RUSTG_CALL(RUST_G, "http_check_request")(req_id)

/// Generates a spritesheet at: [file_path][spritesheet_name]_[size_id].png
/// The resulting spritesheet arranges icons in a random order, with the position being denoted in the "sprites" return value.
/// All icons have the same y coordinate, and their x coordinate is equal to `icon_width * position`.
///
/// hash_icons is a boolean (0 or 1), and determines if the generator will spend time creating hashes for the output field dmi_hashes.
/// These hashes can be heplful for 'smart' caching (see rustg_iconforge_cache_valid), but require extra computation.
///
/// Spritesheet will contain all sprites listed within "sprites".
/// "sprites" format:
/// list(
///     "sprite_name" = list( // <--- this list is a [SPRITE_OBJECT]
///         icon_file = 'icons/path_to/an_icon.dmi',
///         icon_state = "some_icon_state",
///         dir = SOUTH,
///         frame = 1,
///         transform = list([TRANSFORM_OBJECT], ...)
///     ),
///     ...,
/// )
/// TRANSFORM_OBJECT format:
/// list("type" = RUSTG_ICONFORGE_BLEND_COLOR, "color" = "#ff0000", "blend_mode" = ICON_MULTIPLY)
/// list("type" = RUSTG_ICONFORGE_BLEND_ICON, "icon" = [SPRITE_OBJECT], "blend_mode" = ICON_OVERLAY)
/// list("type" = RUSTG_ICONFORGE_SCALE, "width" = 32, "height" = 32)
/// list("type" = RUSTG_ICONFORGE_CROP, "x1" = 1, "y1" = 1, "x2" = 32, "y2" = 32) // (BYOND icons index from 1,1 to the upper bound, inclusive)
///
/// Returns a SpritesheetResult as JSON, containing fields:
/// list(
///     "sizes" = list("32x32", "64x64", ...),
///     "sprites" = list("sprite_name" = list("size_id" = "32x32", "position" = 0), ...),
///     "dmi_hashes" = list("icons/path_to/an_icon.dmi" = "d6325c5b4304fb03", ...),
///     "sprites_hash" = "a2015e5ff403fb5c", // This is the xxh64 hash of the INPUT field "sprites".
///     "error" = "[A string, empty if there were no errors.]"
/// )
/// In the case of an unrecoverable panic from within Rust, this function ONLY returns a string containing the error.
#define rustg_iconforge_generate(file_path, spritesheet_name, sprites, hash_icons) RUSTG_CALL(RUST_G, "iconforge_generate")(file_path, spritesheet_name, sprites, "[hash_icons]")
/// Returns a job_id for use with rustg_iconforge_check()
#define rustg_iconforge_generate_async(file_path, spritesheet_name, sprites, hash_icons) RUSTG_CALL(RUST_G, "iconforge_generate_async")(file_path, spritesheet_name, sprites, "[hash_icons]")
/// Returns the status of an async job_id, or its result if it is completed. See RUSTG_JOB DEFINEs.
#define rustg_iconforge_check(job_id) RUSTG_CALL(RUST_G, "iconforge_check")("[job_id]")
/// Clears all cached DMIs and images, freeing up memory.
/// This should be used after spritesheets are done being generated.
#define rustg_iconforge_cleanup RUSTG_CALL(RUST_G, "iconforge_cleanup")
/// Takes in a set of hashes, generate inputs, and DMI filepaths, and compares them to determine cache validity.
/// input_hash: xxh64 hash of "sprites" from the cache.
/// dmi_hashes: xxh64 hashes of the DMIs in a spritesheet, given by `rustg_iconforge_generate` with `hash_icons` enabled. From the cache.
/// sprites: The new input that will be passed to rustg_iconforge_generate().
/// Returns a CacheResult with the following structure: list(
///     "result": "1" (if cache is valid) or "0" (if cache is invalid)
///     "fail_reason": "" (emtpy string if valid, otherwise a string containing the invalidation reason or an error with ERROR: prefixed.)
/// )
/// In the case of an unrecoverable panic from within Rust, this function ONLY returns a string containing the error.
#define rustg_iconforge_cache_valid(input_hash, dmi_hashes, sprites) RUSTG_CALL(RUST_G, "iconforge_cache_valid")(input_hash, dmi_hashes, sprites)
/// Returns a job_id for use with rustg_iconforge_check()
#define rustg_iconforge_cache_valid_async(input_hash, dmi_hashes, sprites) RUSTG_CALL(RUST_G, "iconforge_cache_valid_async")(input_hash, dmi_hashes, sprites)

#define RUSTG_ICONFORGE_BLEND_COLOR "BlendColor"
#define RUSTG_ICONFORGE_BLEND_ICON "BlendIcon"
#define RUSTG_ICONFORGE_CROP "Crop"
#define RUSTG_ICONFORGE_SCALE "Scale"

#define RUSTG_JOB_NO_RESULTS_YET "NO RESULTS YET"
#define RUSTG_JOB_NO_SUCH_JOB "NO SUCH JOB"
#define RUSTG_JOB_ERROR "JOB PANICKED"

#define rustg_json_is_valid(text) (RUSTG_CALL(RUST_G, "json_is_valid")(text) == "true")

#define rustg_log_write(fname, text, format) RUSTG_CALL(RUST_G, "log_write")(fname, text, format)
/proc/rustg_log_close_all() return RUSTG_CALL(RUST_G, "log_close_all")()

#define rustg_noise_get_at_coordinates(seed, x, y) RUSTG_CALL(RUST_G, "noise_get_at_coordinates")(seed, x, y)

/// Register a list of nodes into a rust library. This list of nodes must have been serialized in a json.
/// {
///		"position": { x: 0, y: 0, z: 0 },
///		"mask": 0,
///		"links": [{x: 0, y: 0, z: 1}]
/// }
/// A node cannot link twice to the same node and shouldn't link itself either.
#define rustg_update_nodes_astar(json) RUSTG_CALL(RUST_G, "update_nodes_astar")(json)

/// Remove the node with node position.
#define rustg_remove_node_astar(node_pos) RUSTG_CALL(RUST_G, "remove_node_astar")(node_pos)

/// Compute the shortest path between start_node and goal_node using A*.
#define rustg_generate_path_astar(strat_node_pos, goal_node_pos, pass_bit, deny_bit, costs) RUSTG_CALL(RUST_G, "generate_path_astar")(strat_node_pos, goal_node_pos, istext(pass_bit) ? pass_bit : num2text(pass_bit), istext(deny_bit) ? deny_bit : num2text(deny_bit), isnull(costs) ? "null" : costs)

#define rustg_prom_init(port) RUSTG_CALL(RUST_G, "prom_init")(istext(port) ? port : num2text(port))

#define rustg_prom_set_labels(labels) RUSTG_CALL(RUST_G, "prom_set_labels")(json_encode(labels))

// Counters

#define rustg_prom_counter_register(id, desc) RUSTG_CALL(RUST_G, "prom_counter_register")(id, desc)

#define rustg_prom_counter_inc(id, labels) RUSTG_CALL(RUST_G, "prom_counter_inc")(id, json_encode(labels))

#define rustg_prom_counter_inc_by(id, value, labels) RUSTG_CALL(RUST_G, "prom_counter_inc_by")(id, istext(value) ? value : num2text(value), json_encode(labels))

// Integer gauges

#define rustg_prom_gauge_int_register(id, desc) RUSTG_CALL(RUST_G, "prom_gauge_int_register")(id, desc)

#define rustg_prom_gauge_int_inc(id, labels) RUSTG_CALL(RUST_G, "prom_gauge_int_inc")(id, json_encode(labels))

#define rustg_prom_gauge_int_inc_by(id, value, labels) RUSTG_CALL(RUST_G, "prom_gauge_int_inc_by")(id, istext(value) ? value : num2text(value), json_encode(labels))

#define rustg_prom_gauge_int_dec(id, labels) RUSTG_CALL(RUST_G, "prom_gauge_int_dec")(id, json_encode(labels))

#define rustg_prom_gauge_int_dec_by(id, value, labels) RUSTG_CALL(RUST_G, "prom_gauge_int_dec_by")(id, istext(value) ? value : num2text(value), json_encode(labels))

#define rustg_prom_gauge_int_set(id, value, labels) RUSTG_CALL(RUST_G, "prom_gauge_int_set")(id, istext(value) ? value : num2text(value), json_encode(labels))

// Float gauges

#define rustg_prom_gauge_float_register(id, desc) RUSTG_CALL(RUST_G, "prom_gauge_float_register")(id, desc)

#define rustg_prom_gauge_float_inc(id, labels) RUSTG_CALL(RUST_G, "prom_gauge_float_inc")(id, json_encode(labels))

#define rustg_prom_gauge_float_inc_by(id, value, labels) RUSTG_CALL(RUST_G, "prom_gauge_float_inc_by")(id, istext(value) ? value : num2text(value), json_encode(labels))

#define rustg_prom_gauge_float_dec(id, labels) RUSTG_CALL(RUST_G, "prom_gauge_float_dec")(id), json_encode(labels)

#define rustg_prom_gauge_float_dec_by(id, value, labels) RUSTG_CALL(RUST_G, "prom_gauge_float_dec_by")(id, istext(value) ? value : num2text(value), json_encode(labels))

#define rustg_prom_gauge_float_set(id, value, labels) RUSTG_CALL(RUST_G, "prom_gauge_float_set")(id, istext(value) ? value : num2text(value), json_encode(labels))

// Simple

/// Returns a random integer in range from `i32::MIN` to `i32::MAX`
#define rustg_rand_i32(...) text2num(RUSTG_CALL(RUST_G, "rand_i32")())

/// Returns a random integer in range from `u32::MIN` to `u32::MAX`
#define rustg_rand_u32(...) text2num(RUSTG_CALL(RUST_G, "rand_u32")())

/// Returns a random integer in range from `f32::MIN` to `f32::MAX`
#define rustg_rand_f32(...) text2num(RUSTG_CALL(RUST_G, "rand_f32")())

/// Returns a random i32 value in range `[low, high)`
#define rustg_rand_range_i32(low, high) text2num(RUSTG_CALL(RUST_G, "rand_range_i32")(istext(low) ? low : num2text(low), istext(high) ? high : num2text(high)))

/// Returns a random u32 value in range `[low, high)`
#define rustg_rand_range_u32(low, high) text2num(RUSTG_CALL(RUST_G, "rand_range_u32")(istext(low) ? low : num2text(low), istext(high) ? high : num2text(high)))

/// Returns a random f32 value in range `[low, high)`
#define rustg_rand_range_f32(low, high) text2num(RUSTG_CALL(RUST_G, "rand_range_f32")(istext(low) ? low : num2text(low), istext(high) ? high : num2text(high)))

/// Returns a bool with a probability p of being true.
#define rustg_rand_bool(p) text2num(RUSTG_CALL(RUST_G, "rand_bool")(istext(p) ? p : num2text(p)))

/// Returns a bool with a probability of numerator/denominator of being true. I.e. gen_ratio(2, 3) has chance of 2 in 3, or about 67%, of returning true.
/// If numerator == denominator, then the returned value is guaranteed to be true. If numerator == 0, then the returned value is guaranteed to be false.
#define rustg_rand_ratio(nominator, denominator) ext2num(RUSTG_CALL(RUST_G, "rand_ratio")(istext(nominator) ? nominator : num2text(nominator), istext(denominator) ? denominator : num2text(denominator)))

// Related to real-valued quantities that grow linearly (e.g. errors, offsets):

// Normal distribution

/// The normal distribution `N(mean, std_dev**2)`. From mean and standard deviation
/// Parameters:
/// mean (μ, unrestricted)
/// standard deviation (σ, must be finite)
#define rustg_rand_normal_sample(mean, std_dev) text2num(RUSTG_CALL(RUST_G, "rand_normal_sample")(istext(mean) ? mean : num2text(mean), istext(std_dev) ? std_dev : num2text(std_dev)))

/// The normal distribution `N(mean, std_dev**2)`. From mean and coefficient of variation
/// Parameters:
/// mean (μ, unrestricted)
/// coefficient of variation (cv = abs(σ / μ))
#define rustg_rand_normal_cv_sample(mean, cv) text2num(RUSTG_CALL(RUST_G, "rand_normal_cv_sample")(istext(mean) ? mean : num2text(mean), istext(cv) ? cv : num2text(cv)))

// Skew

/// The skew normal distribution `SN(location, scale, shape)`.
/// The skew normal distribution is a generalization of the Normal distribution to allow for non-zero skewness.
/// It has the density function, for scale > 0, f(x) = 2 / scale * phi((x - location) / scale) * Phi(alpha * (x - location) / scale) where phi and Phi are the density and distribution of a standard normal variable.
#define rustg_rand_skew_sample(location, scale, shape) text2num(RUSTG_CALL(RUST_G, "rand_skew_sample")(istext(location) ? location : num2text(location), istext(scale) ? scale : num2text(scale), istext(shape) ? shape : num2text(shape))

// Cauchy

/// The Cauchy distribution `Cauchy(median, scale)`.
/// This distribution has a density function: f(x) = 1 / (pi * scale * (1 + ((x - median) / scale)^2))
#define rustg_rand_cauchy_sample(median, scale) text2num(RUSTG_CALL(RUST_G, "rand_cauchy_sample")(istext(median) ? median : num2text(median), istext(scale) ? scale : num2text(scale)))

// Related to Bernoulli trials (yes/no events, with a given probability):

// Binomial

/// The binomial distribution Binomial(n, p).
/// This distribution has density function: f(k) = n!/(k! (n-k)!) p^k (1-p)^(n-k) for k >= 0.
#define rustg_rand_binomial_sample(n, p) text2num(RUSTG_CALL(RUST_G, "rand_binomial_sample")(istext(n) ? n : num2text(n), istext(p) ? p : num2text(p)))

// Geometric

/// The geometric distribution `Geometric(p)` bounded to [0, u64::MAX].
/// This is the probability distribution of the number of failures before the first success in a series of Bernoulli trials.
/// It has the density function `f(k) = (1 - p)^k p` for` k >= 0`, where p is the probability of success on each trial.
/// This is the discrete analogue of the exponential distribution.
#define rustg_rand_geometric_sample(p) text2num(RUSTG_CALL(RUST_G, "rand_geometric_sample")(istext(p) ? p : num2text(p)))

// Hypergeometric

/// The hypergeometric distribution Hypergeometric(N, K, n).
/// This is the distribution of successes in samples of size n drawn without replacement from a population of size N containing K success states.
/// It has the density function: f(k) = binomial(K, k) * binomial(N-K, n-k) / binomial(N, n), where binomial(a, b) = a! / (b! * (a - b)!).
/// The binomial distribution is the analogous distribution for sampling with replacement. It is a good approximation when the population size is much larger than the sample size.
#define rustg_rand_hypergeometric_sample(N, K, n) text2num(RUSTG_CALL(RUST_G, "rand_hypergeometric_sample")(istext(N) ? N : num2text(N), istext(K) ? K : num2text(K), istext(n) ? n : num2text(n)))

// Related to positive real-valued quantities that grow exponentially (e.g. prices, incomes, populations):

// Log

// The log-normal distribution ln N(mean, std_dev**2).
// If X is log-normal distributed, then ln(X) is N(mean, std_dev**2) distributed.

/// Construct, from (log-space) mean and standard deviation
/// Parameters are the “standard” log-space measures (these are the mean and standard deviation of the logarithm of samples):
/// mu (μ, unrestricted) is the mean of the underlying distribution
/// sigma (σ, must be finite) is the standard deviation of the underlying Normal distribution
#define rustg_rand_log_sample(mu, sigma) text2num(RUSTG_CALL(RUST_G, "rand_log_sample")(istext(mu) ? mu : num2text(mu), istext(sigma) ? sigma : num2text(sigma)))

/// Construct, from (linear-space) mean and coefficient of variation
/// Parameters are linear-space measures:
/// mean (μ > 0) is the (real) mean of the distribution
/// coefficient of variation (cv = σ / μ, requiring cv ≥ 0) is a standardized measure of dispersion
/// As a special exception, μ = 0, cv = 0 is allowed (samples are -inf).
#define rustg_rand_log_mean_cv_sample(mean, cv) text2num(RUSTG_CALL(RUST_G, "rand_log_mean_cv_sample")(istext(mean) ? mean : num2text(mean), istext(cv) ? cv : num2text(cv)))

// Related to the occurrence of independent events at a given rate:

// Pareto

/// Samples floating-point numbers according to the Pareto distribution
#define rustg_rand_pareto_sample(scale, shape) text2num(RUSTG_CALL(RUST_G, "rand_pareto_sample")(istext(scale) ? scale : num2text(scale), istext(shape) ? shape : num2text(shape)))

// Poisson

/// The Poisson distribution `Poisson(lambda)`.
/// This distribution has a density function: f(k) = lambda^k * exp(-lambda) / k! for k >= 0.
#define rustg_rand_poisson_sample(lambda) text2num(RUSTG_CALL(RUST_G, "rand_poisson_sample")(istext(lambda) ? lambda : num2text(lambda)))

// Exp

/// The exponential distribution Exp(lambda).
/// This distribution has density function: f(x) = lambda * exp(-lambda * x) for x > 0, when lambda > 0. For lambda = 0, all samples yield infinity.
#define rustg_rand_exp_sample(lambda) text2num(RUSTG_CALL(RUST_G, "rand_exp_sample")(istext(lambda) ? lambda : num2text(lambda)))

// Weibull

/// Samples floating-point numbers according to the Weibull distribution
#define rustg_rand_weibull_sample(scale, shape) text2num(RUSTG_CALL(RUST_G, "rand_weibull_sample")(istext(scale) ? scale : num2text(scale), istext(shape) ? shape : num2text(shape)))

// Gumbel

/// Samples floating-point numbers according to the Gumbel distribution
/// This distribution has density function: f(x) = exp(-(z + exp(-z))) / σ, where z = (x - μ) / σ, μ is the location parameter, and σ the scale parameter.
#define rustg_rand_gumbel_sample(location, scale) text2num(RUSTG_CALL(RUST_G, "rand_gumbel_sample")(istext(location) ? location : num2text(location), istext(scale) ? scale : num2text(scale)))

// Frechet

/// Samples floating-point numbers according to the Fréchet distribution
/// This distribution has density function: f(x) = [(x - μ) / σ]^(-1 - α) exp[-(x - μ) / σ]^(-α) α / σ, where μ is the location parameter, σ the scale parameter, and α the shape parameter.
#define rustg_rand_frechet_sample(location, scale, shape) text2num(RUSTG_CALL(RUST_G, "rand_frechet_sample")(istext(location) ? location : num2text(location), istext(scale) ? scale : num2text(scale), istext(shape) ? shape : num2text(shape)))

// Zeta

/// Samples integers according to the zeta distribution.
/// The zeta distribution is a limit of the Zipf distribution.
/// Sometimes it is called one of the following: discrete Pareto, Riemann-Zeta, Zipf, or Zipf–Estoup distribution.
/// It has the density function f(k) = k^(-a) / C(a) for k >= 1, where a is the parameter and C(a) is the Riemann zeta function.
#define rustg_rand_zeta_sample(a) text2num(RUSTG_CALL(RUST_G, "rand_zeta_sample")(istext(a) ? a : num2text(a)))

// Zipf

/// Samples integers according to the Zipf distribution.
/// The samples follow Zipf’s law: The frequency of each sample from a finite set of size n is inversely proportional to a power of its frequency rank (with exponent s).
/// For large n, this converges to the Zeta distribution.
/// For s = 0, this becomes a uniform distribution.
#define rustg_rand_zipf_sample(n, s) text2num(RUSTG_CALL(RUST_G, "rand_zipf_sample")(istext(n) ? n : num2text(n), istext(s) ? s : num2text(s)))

// Gamma and derived distributions:

// Gamma

/// The Gamma distribution Gamma(shape, scale) distribution.
/// The density function of this distribution is
/// `f(x) =  x^(k - 1) * exp(-x / θ) / (Γ(k) * θ^k)`
/// where Γ is the Gamma function, k is the shape and θ is the scale and both k and θ are strictly positive.
/// The algorithm used is that described by Marsaglia & Tsang 20001, falling back to directly sampling from an Exponential for shape == 1, and using the boosting technique described in that paper for shape < 1.
#define rustg_rand_gamma_sample(shape, scale) text2num(RUSTG_CALL(RUST_G, "rand_gamma_sample")(istext(shape) ? shape : num2text(shape), istext(scale) ? scale : num2text(scale)))

// ChiSquared

/// The chi-squared distribution χ²(k), where k is the degrees of freedom.
/// For k > 0 integral, this distribution is the sum of the squares of k independent standard normal random variables.
/// For other k, this uses the equivalent characterisation χ²(k) = Gamma(k/2, 2).
#define rustg_rand_chisquared_sample(k) text2num(RUSTG_CALL(RUST_G, "rand_chisquared_sample")(istext(k) ? k : num2text(k)))

// StudentT

/// The Student t distribution, t(nu), where nu is the degrees of freedom.
#define rustg_rand_studentt_sample(n) text2num(RUSTG_CALL(RUST_G, "rand_studentt_sample")(istext(n) ? n : num2text(n)))

// FisherF

/// The Fisher F distribution F(m, n).
/// This distribution is equivalent to the ratio of two normalised chi-squared distributions, that is, F(m,n) = (χ²(m)/m) / (χ²(n)/n).
#define rustg_rand_fisherf_sample(m, n) text2num(RUSTG_CALL(RUST_G, "rand_fisherf_sample")(istext(m) ? m : num2text(m), istext(n) ? n : num2text(n)))

// Triangular distribution:

// Beta

/// The Beta distribution with shape parameters alpha and beta.
#define rustg_rand_beta_sample(alpha, beta) text2num(RUSTG_CALL(RUST_G, "rand_beta_sample")(istext(alpha) ? alpha : num2text(alpha), istext(beta) ? beta : num2text(beta)))

// Triangular

/// The triangular distribution.
/// A continuous probability distribution parameterised by a range, and a mode (most likely value) within that range.
/// The probability density function is triangular. For a similar distribution with a smooth PDF, see the Pert distribution.
#define rustg_rand_triangular_sample(min, max, mode) text2num(RUSTG_CALL(RUST_G, "rand_triangular_sample")(istext(min) ? min : num2text(min), istext(max) ? max : num2text(max), istext(mode) ? mode : num2text(mode)))

// Pert

// The PERT distribution.
// Similar to the Triangular distribution, the PERT distribution is parameterised by a range and a mode within that range.
// Unlike the Triangular distribution, the probability density function of the PERT distribution is smooth, with a configurable weighting around the mode.

/// Set up the PERT distribution with defined min, max and mode.
/// This is equivalent to calling Pert::new_shape with shape == 4.0.
#define rustg_rand_pert_sample(min, max, mode) text2num(RUSTG_CALL(RUST_G, "rand_pert_sample")(istext(min) ? min : num2text(min), istext(max) ? max : num2text(max), istext(mode) ? mode : num2text(mode)))

/// Set up the PERT distribution with defined min, max, mode and shape.
#define rustg_rand_pert_shape_sample(min, max, mode, shape) text2num(RUSTG_CALL(RUST_G, "rand_pert_shape_sample")(istext(min) ? min : num2text(min), istext(max) ? max : num2text(max), istext(mode) ? mode : num2text(mode), istext(shape) ? shape : num2text(shape)))

// Misc. distributions

// Inverse Gaussian

/// https://en.wikipedia.org/wiki/Inverse_Gaussian_distribution
#define rustg_rand_inverse_gaussian_sample(mean, shape) text2num(RUSTG_CALL(RUST_G, "rand_inverse_gaussian_sample")(istext(mean) ? mean : num2text(mean), istext(shape) ? shape : num2text(shape)))

// Normal Inverse Gaussian

/// https://en.wikipedia.org/wiki/Normal-inverse_Gaussian_distribution
#define rustg_rand_normal_inverse_gaussian(alpha, beta) text2num(RUSTG_CALL(RUST_G, "rand_normal_inverse_gaussian")(istext(alpha) ? alpha : num2text(alpha), istext(beta) ? beta : num2text(beta)))

#define rustg_sql_connect_pool(options) RUSTG_CALL(RUST_G, "sql_connect_pool")(options)
#define rustg_sql_query_async(handle, query, params) RUSTG_CALL(RUST_G, "sql_query_async")(handle, query, params)
#define rustg_sql_query_blocking(handle, query, params) RUSTG_CALL(RUST_G, "sql_query_blocking")(handle, query, params)
#define rustg_sql_connected(handle) RUSTG_CALL(RUST_G, "sql_connected")(handle)
#define rustg_sql_disconnect_pool(handle) RUSTG_CALL(RUST_G, "sql_disconnect_pool")(handle)
#define rustg_sql_check_query(job_id) RUSTG_CALL(RUST_G, "sql_check_query")("[job_id]")

#define rustg_time_microseconds(id) text2num(RUSTG_CALL(RUST_G, "time_microseconds")(id))
#define rustg_time_milliseconds(id) text2num(RUSTG_CALL(RUST_G, "time_milliseconds")(id))
#define rustg_time_reset(id) RUSTG_CALL(RUST_G, "time_reset")(id)

/// Returns the timestamp as a string
/proc/rustg_unix_timestamp()
	return RUSTG_CALL(RUST_G, "unix_timestamp")()

#define rustg_raw_read_toml_file(path) json_decode(RUSTG_CALL(RUST_G, "toml_file_to_json")(path) || "null")

/proc/rustg_read_toml_file(path)
	var/list/output = rustg_raw_read_toml_file(path)
	if (output["success"])
		return json_decode(output["content"])
	else
		CRASH(output["content"])

#define rustg_raw_toml_encode(value) json_decode(RUSTG_CALL(RUST_G, "toml_encode")(json_encode(value)))

/proc/rustg_toml_encode(value)
	var/list/output = rustg_raw_toml_encode(value)
	if (output["success"])
		return output["content"]
	else
		CRASH(output["content"])

#define rustg_url_encode(text) RUSTG_CALL(RUST_G, "url_encode")("[text]")
#define rustg_url_decode(text) RUSTG_CALL(RUST_G, "url_decode")(text)

#ifdef RUSTG_OVERRIDE_BUILTINS
	#define url_encode(text) rustg_url_encode(text)
	#define url_decode(text) rustg_url_decode(text)
#endif

/**
 * This proc generates a noise grid using worley noise algorithm
 *
 * Returns a single string that goes row by row, with values of 1 representing an alive cell, and a value of 0 representing a dead cell.
 *
 * Arguments:
 * * region_size: The size of regions
 * * threshold: the value that determines wether a cell is dead or alive
 * * node_per_region_chance: chance of a node existiing in a region
 * * size: size of the returned grid
 * * node_min: minimum amount of nodes in a region (after the node_per_region_chance is applied)
 * * node_max: maximum amount of nodes in a region
 */
#define rustg_worley_generate(region_size, threshold, node_per_region_chance, size, node_min, node_max) \
	RUSTG_CALL(RUST_G, "worley_generate")(region_size, threshold, node_per_region_chance, size, node_min, node_max)


