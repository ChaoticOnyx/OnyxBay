var/__z_name = null

/proc/__z_detect()
	if (__z_name != null)
		return
	
	if(world.system_type == MS_WINDOWS)
		if(fexists("libz.native.dll"))
			__z_name = "libz.native.dll"
		else
			__z_name = "libz.dll"
	else
		// Fuck you zlib
		// UPD: And linux too
		if(fexists("./liblibz.native.so"))
			__z_name = "./liblibz.native.so"
		else
			__z_name = "./liblibz.so"

#define Z_ERROR_OUT_OF_ID "OutOfId"
#define Z_ERROR_OUT_OF_MEMORY "OutOfMemory"
#define Z_ERROR_MACHINE_NOT_FOUND "MachineNotFound"
#define Z_ERROR_FILE_NOT_FOUND "FileNotFound"
#define Z_ERROR_FILE_TOO_BIG "FileTooBig"
#define Z_ERROR_OUT_OF_RAM "OutOfRam"
#define Z_ERROR_BAD_ELF "BadElf"
#define Z_ERROR_BAD_STATE "BadState"
#define Z_ERROR_SLOT_NOT_FOUND "SlotNotFound"
#define Z_ERROR_BAD_SRC "BadSrc"
#define Z_ERROR_UNKNOWN "Unknown"
#define Z_ERROR_ALREADY_RUNNING "AlreadyRunning"
#define Z_ERROR_FAILED_TO_START "FailedToStart"
#define Z_ERROR_SCRIPT_NOT_FOUND "ScriptNotFound"
#define Z_ERROR_BAD_INT "BadInt"
#define Z_ERROR_UNSUPPORTED_TYPE "UnsupportedType"
#define Z_ERROR_VAR_NOT_FOUND "VarNotFound"
#define Z_ERROR_OUT_OF_LIMITS "OutOfLimits"
#define Z_ERROR_ALREDY_EXISTS "AlreadyExists"
#define Z_ERROR_BAD_TYPINGS "BadTypings"
#define Z_ERROR_OUT_OF_RANGE "OutOfRange"

// Global

/// Returns the last error message from the backend, or null if no error.
#define Z_GET_LAST_ERROR(...) call_ext(__z_name, "byond:Z_get_last_error")()

/// Frees all the resources and the memory used by the library.
#define Z_DEINIT(...) call_ext(__z_name, "byond:Z_deinit")()

// WebSocket

// Callback signatures:
//   ON_TEXT_PROC(content: string, address: string, connection_index: number)
//   ON_BINARY_PROC(content: list, address: string, connection_index: number)
//   ON_DISCONNECT_PROC()
// Inside of the ON_TEXT_PROC and ON_BINARY_PROC you can return any falsy value
// to disconnect the connection. But you should not try to disconnect any other connections
// during the callback call.

/// PORT - the port to listen on, 0 for a random port.
/// ON_TEXT_PROC - the callback to call when a text message received, may be null.
/// ON_BINARY_PROC - the callback to call when a binary message received, may be null.
/// CFG - a string of a JSON object with options.
/// Options:
/// - max_connections = 256
/// - max_connections_per_ip = 5
/// - handshake_timeout_ms = 5000
/// - idle_timeout_ms = 300000
/// - ping_interval_ms = 30000
/// - pong_timeout_ms = 10000
/// - max_message_size = 1 * 1024 * 1024
/// - max_frame_size = 1 * 1024 * 1024
/// - max_handshake_size = 8192
/// - max_write_buffer_size = 64 * 1024
/// - rate_limit_messages_per_sec = 25
/// - rate_limit_bytes_per_sec = 1 * 1024 * 1024
/// - initial_message_timeout_ms = 5000
/// - afk_timeout_ms = 0
/// - trust_x_real_ip = false
/// - log = false (0/1)
/// Returns false if the server failed to start (see Z_ERROR_ALREADY_RUNNING, Z_ERROR_FAILED_TO_START).
#define Z_WS_START(PORT, ON_TEXT_PROC, ON_BINARY_PROC, CFG) call_ext(__z_name, "byond:Z_ws_start")(PORT, ON_TEXT_PROC, ON_BINARY_PROC, CFG)

/// Sends a content to the connection by id.
/// Pass a string to send a text message, or a list to send a binary message.
/// Returns false if failed to send, or the connection not found, or the server is not running.
#define Z_WS_SEND(IDX, CONTENT) call_ext(__z_name, "byond:Z_ws_send")(IDX, CONTENT)

/// Ties the OBJ object with the connection.
/// Returns false if the connection not found, or if the connection is already tied, or the server is not running.
#define Z_WS_TIE(IDX, OBJ, ON_TEXT_PROC, ON_BINARY_PROC, ON_DISCONNECT_PROC) call_ext(__z_name, "byond:Z_ws_tie")(IDX, OBJ, ON_TEXT_PROC, ON_BINARY_PROC, ON_DISCONNECT_PROC)

/// Returns a connection id tied to the OBJ, or null if the object is not tied.
#define Z_WS_GET_TIED(OBJ) call_ext(__z_name, "byond:Z_ws_get_tied")(OBJ)

/// Unties the connection with the tied object.
/// Returns false if the connection was not tied, or the connection not found, or the server is not running.
#define Z_WS_UNTIE(IDX) call_ext(__z_name, "byond:Z_ws_untie")(IDX)

/// Disconnects the connection.
/// Returns false if the connection was not found, or the server is not running.
/// Do not call this inside of ON_*_PROC callbacks.
#define Z_WS_DISCONNECT(IDX) call_ext(__z_name, "byond:Z_ws_disconnect")(IDX)

/// Returns true if tick succeeded, false if the server was not running.
/// Returns null on error (e.g., out of memory, see Z_ERROR_OUT_OF_MEMORY).
#define Z_WS_TICK(...) call_ext(__z_name, "byond:Z_ws_tick")()

/// Returns a port the WebSocket server is running on.
/// Returns null if the WebSocket server is not running.
#define Z_WS_GET_PORT(...) call_ext(__z_name, "byond:Z_ws_get_port")()

/// Returns a JSON string with stats:
/// - sent_kilobytes_per_second
/// - received_kilobytes_per_second
/// - tick_duration_ms
/// Returns null if the server is not running or a error was occured.
#define Z_WS_STATS(...) call_ext(__z_name, "byond:Z_ws_stats")()

/// Returns connections count.
/// Returns null if the WebSocket server is not running.
#define Z_WS_CONNECTIONS(...) call_ext(__z_name, "byond:Z_ws_connections")()

/// Stops the WebSocket server. Returns true if the server was running.
#define Z_WS_STOP(...) call_ext(__z_name, "byond:Z_ws_stop")()

// Crypto

/// Generates a LEN bytes and encodes them in url-safe base64 string without padding.
#define Z_CRYPTO_RANDOM_BASE64(LEN) call_ext(__z_name, "byond:Z_crypto_random_base64")(LEN)

/// Content and key must be a string.
/// Returns a url-safe base64 string without padding.
#define Z_CRYPTO_HMAC_SHA256(CONTENT, KEY) call_ext(__z_name, "byond:Z_crypto_hmac_sha256")(CONTENT, KEY)

// Scripting

#define Z_SCRIPT_VAR_CAST_NONE 0
#define Z_SCRIPT_VAR_CAST_INT 1
#define Z_SCRIPT_VAR_CAST_SYMBOL 2
#define Z_SCRIPT_VAR_CAST_OBJECT 3
#define Z_SCRIPT_VAR_CAST_ADDRESS 4

#define Z_SCRIPT_CREATE(SRC, MEMORY_SIZE) call_ext(__z_name, "byond:Z_script_create")(SRC, MEMORY_SIZE)

#define Z_SCRIPT_DESTROY(ID) call_ext(__z_name, "byond:Z_script_destroy")(ID)

#define Z_SCRIPT_HAS_VAR(ID, NAME) call_ext(__z_name, "byond:Z_script_has_var")(ID, NAME)

#define Z_SCRIPT_SET_VAR(ID, NAME, VALUE, CAST) call_ext(__z_name, "byond:Z_script_set_var")(ID, NAME, VALUE, CAST)

#define Z_SCRIPT_GET_VAR(ID, NAME) call_ext(__z_name, "byond:Z_script_get_var")(ID, NAME)

#define Z_SCRIPT_VAR_TYPE_NULL 0
#define Z_SCRIPT_VAR_TYPE_INT 1
#define Z_SCRIPT_VAR_TYPE_FLOAT 2
#define Z_SCRIPT_VAR_TYPE_STRING 3
#define Z_SCRIPT_VAR_TYPE_SYMBOL 4
#define Z_SCRIPT_VAR_TYPE_OBJECT 5
#define Z_SCRIPT_VAR_TYPE_ADDRESS 6

#define Z_SCRIPT_GET_VAR_TYPE(ID, NAME) call_ext(__z_name, "byond:Z_script_get_var_type")(ID, NAME)

#define Z_SCRIPT_UNSET_VAR(ID, NAME) call_ext(__z_name, "byond:Z_script_unset_var")(ID, NAME)

#define Z_SCRIPT_TYPING_NULL (1 << 0)
#define Z_SCRIPT_TYPING_INT (1 << 1)
#define Z_SCRIPT_TYPING_FLOAT (1 << 2)
#define Z_SCRIPT_TYPING_STRING (1 << 3)
#define Z_SCRIPT_TYPING_SYMBOL (1 << 4)
#define Z_SCRIPT_TYPING_OBJECT (1 << 5)
#define Z_SCRIPT_TYPING_ADDRESS (1 << 6)
#define Z_SCRIPT_TYPING_ANY (Z_SCRIPT_TYPING_NULL | Z_SCRIPT_TYPING_INT | Z_SCRIPT_TYPING_FLOAT | Z_SCRIPT_TYPING_STRING | Z_SCRIPT_TYPING_SYMBOL | Z_SCRIPT_TYPING_OBJECT | Z_SCRIPT_TYPING_ADDRESS)
#define Z_SCRIPT_TYPING_ANY_PRIMITIVE (Z_SCRIPT_TYPING_NULL | Z_SCRIPT_TYPING_INT | Z_SCRIPT_TYPING_FLOAT | Z_SCRIPT_TYPING_STRING | Z_SCRIPT_TYPING_SYMBOL | Z_SCRIPT_TYPING_ADDRESS)
#define Z_SCRIPT_TYPING_VARARGS (1 << 7)

#define Z_SCRIPT_FUNCTION_ERROR 0
#define Z_SCRIPT_FUNCTION_OK 1
#define Z_SCRIPT_FUNCTION_YIELD 2
#define Z_SCRIPT_REGISTER_FUNCTION(ID, NAME, CALLBACK, SRC, TYPINGS) call_ext(__z_name, "byond:Z_script_register_function")(ID, NAME, CALLBACK, SRC, TYPINGS)

#define Z_SCRIPT_UNREGISTER_FUNCTION(ID, NAME) call_ext(__z_name, "byond:Z_script_unregister_function")(ID, NAME)

#define Z_SCRIPT_COMPILE_RESULT_ERROR 0
#define Z_SCRIPT_COMPILE_RESULT_OK 1
#define Z_SCRIPT_COMPILE_RESULT_OUT_OF_MEMORY 2
#define Z_SCRIPT_COMPILE_RESULT_OUT_OF_LIMITS 3

#define Z_SCRIPT_COMPILE_ERROR_EXPECTED_OP 1
#define Z_SCRIPT_COMPILE_ERROR_UNKNOWN_OP 2
#define Z_SCRIPT_COMPILE_ERROR_BAD_OP_ARGS 3
#define Z_SCRIPT_COMPILE_ERROR_BAD_STRING_LITERAL 4
#define Z_SCRIPT_COMPILE_ERROR_BAD_SYMBOL_LITERAL 5
#define Z_SCRIPT_COMPILE_ERROR_BAD_NUMBER_LITERAL 6
#define Z_SCRIPT_COMPILE_ERROR_TOO_BIG_INT 7
#define Z_SCRIPT_COMPILE_ERROR_SYNTAX 8
#define Z_SCRIPT_COMPILE_ERROR_UNKNOWN_LABEL 9

#define Z_SCRIPT_COMPILE(ID, CODE, MAX_OPCODES, MAX_STRINGS) call_ext(__z_name, "byond:Z_script_compile")(ID, CODE, MAX_OPCODES, MAX_STRINGS)

#define Z_SCRIPT_GET_COMPILE_ERROR_KIND(ID) call_ext(__z_name, "byond:Z_get_compile_error_kind")(ID)

#define Z_SCRIPT_GET_COMPILE_ERROR_POS(ID) call_ext(__z_name, "byond:Z_get_compile_error_pos")(ID)

#define Z_SCRIPT_RESULT_ERROR 0
#define Z_SCRIPT_RESULT_OK 1
#define Z_SCRIPT_RESULT_YIELDED 2
#define Z_SCRIPT_RESULT_OUT_OF_LIMITS 3

#define Z_SCRIPT_RUNTIME_ERROR_DIVISION_BY_ZERO 1
#define Z_SCRIPT_RUNTIME_ERROR_TYPE_MISMATCH 2
#define Z_SCRIPT_RUNTIME_ERROR_STACK_UNDERFLOW 3
#define Z_SCRIPT_RUNTIME_ERROR_STACK_OVERFLOW 4
#define Z_SCRIPT_RUNTIME_ERROR_UNKNOWN_OPCODE 5
#define Z_SCRIPT_RUNTIME_ERROR_UNDEFINED_FUNCTION 6
#define Z_SCRIPT_RUNTIME_ERROR_UNDEFINED_VARIABLE 7
#define Z_SCRIPT_RUNTIME_ERROR_INVALID_BIT_SHIFT 8
#define Z_SCRIPT_RUNTIME_ERROR_FUNCTION 9

#define Z_SCRIPT_RUN(ID, MAX_OPS, MAX_TIME_DS, TIME_CHECK_INTERVAL, TIME_UTIL) call_ext(__z_name, "byond:Z_script_run")(ID, MAX_OPS, MAX_TIME_DS, TIME_CHECK_INTERVAL, TIME_UTIL)

#define Z_SCRIPT_GET_RUNTIME_ERROR_KIND(ID) call_ext(__z_name, "byond:Z_get_runtime_error_kind")(ID)

#define Z_SCRIPT_GET_RUNTIME_ERROR_IP(ID) call_ext(__z_name, "byond:Z_get_runtime_error_ip")(ID)

#define Z_SCRIPT_RESET(ID, CLEAR_VARS, CLEAR_FUNCTIONS, CLEAR_STACK) call_ext(__z_name, "byond:Z_script_reset")(ID, CLEAR_VARS, CLEAR_FUNCTIONS, CLEAR_STACK)

#define Z_SCRIPT_GC_COLLECT(ID) call_ext(__z_name, "byond:Z_script_gc_collect")(ID)

#define Z_SCRIPT_GET_IP(ID) call_ext(__z_name, "byond:Z_script_get_ip")(ID)

#define Z_SCRIPT_SET_IP(ID, IP) call_ext(__z_name, "byond:Z_script_set_ip")(ID, IP)

#define Z_SCRIPT_GET_OP_POS(ID, IP) call_ext(__z_name, "byond:Z_script_get_op_pos")(ID, IP)

#define Z_SCRIPT_GET_USED_MEMORY(ID) call_ext(__z_name, "byond:Z_script_get_used_memory")(ID)

// Hash

#define Z_HASH_XXHASH32(SEED, VALUE) call_ext(__z_name, "byond:Z_hash_xxhash32")(SEED, VALUE)
