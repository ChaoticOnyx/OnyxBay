// rust_g.dm - DM API for rust_g extension library
//
// #define RUSTG_OVERRIDE_BUILTINS
// Enable replacement rust-g functions for certain builtins. Off by default.

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
	dll_call(RUST_G_LOCATION, "cnoise_generate", percentage, smoothing_iterations, birth_limit, death_limit, width, height)

#define rustg_dmi_strip_metadata(fname) dll_call(RUST_G_LOCATION, "dmi_strip_metadata", fname)
#define rustg_dmi_create_png(path, width, height, data) dll_call(RUST_G_LOCATION, "dmi_create_png", path, width, height, data)
#define rustg_dmi_resize_png(path, width, height, resizetype) dll_call(RUST_G_LOCATION, "dmi_resize_png", path, width, height, resizetype)

#define rustg_file_read(fname) dll_call(RUST_G_LOCATION, "file_read", fname)
#define rustg_file_exists(fname) dll_call(RUST_G_LOCATION, "file_exists", fname)
#define rustg_file_write(text, fname) dll_call(RUST_G_LOCATION, "file_write", text, fname)
#define rustg_file_append(text, fname) dll_call(RUST_G_LOCATION, "file_append", text, fname)

#ifdef RUSTG_OVERRIDE_BUILTINS
	#define file2text(fname) rustg_file_read("[fname]")
	#define text2file(text, fname) rustg_file_append(text, "[fname]")
#endif

#define rustg_git_revparse(rev) dll_call(RUST_G_LOCATION, "rg_git_revparse", rev)
#define rustg_git_commit_date(rev) dll_call(RUST_G_LOCATION, "rg_git_commit_date", rev)

#define rustg_hash_string(algorithm, text) dll_call(RUST_G_LOCATION, "hash_string", algorithm, text)
#define rustg_hash_file(algorithm, fname) dll_call(RUST_G_LOCATION, "hash_file", algorithm, fname)

#define RUSTG_HASH_MD5 "md5"
#define RUSTG_HASH_SHA1 "sha1"
#define RUSTG_HASH_SHA256 "sha256"
#define RUSTG_HASH_SHA512 "sha512"

#ifdef RUSTG_OVERRIDE_BUILTINS
	#define md5(thing) (isfile(thing) ? rustg_hash_file(RUSTG_HASH_MD5, "[thing]") : rustg_hash_string(RUSTG_HASH_MD5, thing))
#endif

#define RUSTG_HTTP_METHOD_GET "get"
#define RUSTG_HTTP_METHOD_PUT "put"
#define RUSTG_HTTP_METHOD_DELETE "delete"
#define RUSTG_HTTP_METHOD_PATCH "patch"
#define RUSTG_HTTP_METHOD_HEAD "head"
#define RUSTG_HTTP_METHOD_POST "post"
#define rustg_http_request_blocking(method, url, body, headers, options) dll_call(RUST_G_LOCATION, "http_request_blocking", method, url, body, headers, options)
#define rustg_http_request_async(method, url, body, headers, options) dll_call(RUST_G_LOCATION, "http_request_async", method, url, body, headers, options)
#define rustg_http_check_request(req_id) dll_call(RUST_G_LOCATION, "http_check_request", req_id)

#define RUSTG_JOB_NO_RESULTS_YET "NO RESULTS YET"
#define RUSTG_JOB_NO_SUCH_JOB "NO SUCH JOB"
#define RUSTG_JOB_ERROR "JOB PANICKED"

#define rustg_json_is_valid(text) (RUST_G_LOCATION_dll_call(RUST_G_LOCATION, "json_is_valid", text) == "true")

#define rustg_log_write(fname, text, format) dll_call(RUST_G_LOCATION, "log_write", fname, text, format)
/proc/rustg_log_close_all() return dll_call(RUST_G_LOCATION, "log_close_all")

#define rustg_noise_get_at_coordinates(seed, x, y) dll_call(RUST_G_LOCATION, "noise_get_at_coordinates", seed, x, y)

#define rustg_sql_connect_pool(options) dll_call(RUST_G_LOCATION, "sql_connect_pool", options)
#define rustg_sql_query_async(handle, query, params) dll_call(RUST_G_LOCATION, "sql_query_async", handle, query, params)
#define rustg_sql_query_blocking(handle, query, params) dll_call(RUST_G_LOCATION, "sql_query_blocking", handle, query, params)
#define rustg_sql_connected(handle) dll_call(RUST_G_LOCATION, "sql_connected", handle)
#define rustg_sql_disconnect_pool(handle) dll_call(RUST_G_LOCATION, "sql_disconnect_pool", handle)
#define rustg_sql_check_query(job_id) dll_call(RUST_G_LOCATION, "sql_check_query", "[job_id]")
