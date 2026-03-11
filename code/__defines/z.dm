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

// Machines

#define Z_MSTATE_STOPPED (1)
#define Z_MSTATE_RUNNING (2)

#define Z_MAX_PCI_DEVICES 18

#define Z_DEVICE_TYPE_TTS 1
#define Z_DEVICE_TYPE_SERIAL_TERMINAL 2
#define Z_DEVICE_TYPE_SIGNALER 3
#define Z_DEVICE_TYPE_GPS 4
#define Z_DEVICE_TYPE_LIGHT 5
#define Z_DEVICE_TYPE_ENV_SENSOR 6

#define Z_TTS_N2B_CMD_SAY 1
#define Z_TTS_B2N_CMD_READY_STATUS 1

#define Z_SERIAL_N2B_CMD_WRITE 1
#define Z_SERIAL_B2N_CMD_WRITE 1
#define Z_SERIAL_N2B_CMD_SET_RAW_MODE 2

#define Z_SIGNALER_N2B_CMD_SET 1
#define Z_SIGNALER_N2B_CMD_SEND 2
#define Z_SIGNALER_B2N_CMD_PULSE 1
#define Z_SIGNALER_B2N_CMD_READY_STATUS 2

#define Z_LIGHT_N2B_CMD_SET 1
#define Z_LIGHT_B2N_CMD_READY_STATUS 1

#define Z_ENV_SENSOR_N2B_CMD_UPDATE 1
#define Z_ENV_SENSOR_B2N_CMD_READY_STATUS 1
#define Z_ENV_SENSOR_B2N_CMD_UPDATE 2

// All machine IDs are numeric handles returned by Z_MACHINE_CREATE.

/// Creates a new machine. Returns numeric machine ID.
/// Machine starts with no RAM and default frequency (1 MHz), not yet runnable.
#define Z_MACHINE_CREATE(SRC) call_ext(__z_name, "byond:Z_machine_create")(SRC)

/// Resets a machine: zeroes all CPU registers and clears RAM contents.
/// Frequency, RAM size, and connected BYOND object are preserved.
/// ELF must be reloaded after reset.
#define Z_MACHINE_RESET(ID) call_ext(__z_name, "byond:Z_machine_reset")(ID)

/// Allocates RAM for a machine in bytes. Frees previous RAM.
/// Machine is not runnable until RAM is set and ELF is loaded.
#define Z_MACHINE_SET_RAM_SIZE(ID, SIZE) call_ext(__z_name, "byond:Z_machine_set_ram_size")(ID, SIZE)

/// Returns the size of the RAM in bytes
#define Z_MACHINE_GET_RAM_SIZE(ID) call_ext(__z_name, "byond:Z_machine_get_ram_size")(ID)

/// Returns a byte from the RAM at the specified address
#define Z_MACHINE_READ_RAM_BYTE(ID, ADDRESS) call_ext(__z_name, "byond:Z_machine_read_ram_byte")(ID, ADDRESS)

/// Writes a byte to the RAM at the specified address
#define Z_MACHINE_WRITE_RAM_BYTE(ID, ADDRESS, VALUE) call_ext(__z_name, "byond:Z_machine_write_ram_byte")(ID, ADDRESS, VALUE)

/// Reads multiple bytes from the RAM at the specified address into the DST list
#define Z_MACHINE_READ_RAM_BYTES(ID, ADDRESS, DST) call_ext(__z_name, "byond:Z_machine_read_ram_bytes")(ID, ADDRESS, DST)

/// Writes multiple bytes to the RAM at the specified address from the SRC list
#define Z_MACHINE_WRITE_RAM_BYTES(ID, ADDRESS, SRC) call_ext(__z_name, "byond:Z_machine_write_ram_bytes")(ID, ADDRESS, SRC)

/// Sets CPU clock frequency in Hz. Determines how many cycles
/// the machine gets per tick. Default: 1 MHz.
#define Z_MACHINE_SET_FREQUENCY(ID, FREQ) call_ext(__z_name, "byond:Z_machine_set_frequency")(ID, FREQ)

/// Sets a machine's state, possible values: Z_MSTATE_STOPPED, Z_MSTATE_RUNNING
#define Z_MACHINE_SET_STATE(ID, STATE) call_ext(__z_name, "byond:Z_machine_set_state")(ID, STATE)

/// Returns a machine's state
#define Z_MACHINE_GET_STATE(ID) call_ext(__z_name, "byond:Z_machine_get_state")(ID)

/// Returns `cycles_executed / budget` at the previous`Z_MACHINES_TICK`
#define Z_MACHINE_GET_UTILIZATION(ID) call_ext(__z_name, "byond:Z_machine_get_utilization")(ID)

/// Returns `cycles_executed` at the previous`Z_MACHINES_TICK`, might not fit into f32
#define Z_MACHINE_GET_EXECUTED(ID) call_ext(__z_name, "byond:Z_machine_get_executed")(ID)

#define Z_MACHINE_SET_SENSORS(ID, TEMP, OVERHEAT, THROTTLED) call_ext(__z_name, "byond:Z_machine_set_sensors")(ID, TEMP, OVERHEAT, THROTTLED)

#define Z_MACHINE_SET_POWER(ID, BATTERY_CHARGE, HAS_EXTERNAL_SOURCE) call_ext(__z_name, "byond:Z_machine_set_power")(ID, BATTERY_CHARGE, HAS_EXTERNAL_SOURCE)

#define Z_MACHINE_SET_SHIFT_ID(ID, SHIFT_ID) call_ext(__z_name, "byond:Z_machine_set_shift_id")(ID, SHIFT_ID)

/// Sets the proc to be called after tick in Z_MACHINES_TICK.
#define Z_MACHINE_SET_POST_TICK_PROC(ID, PROC) call_ext(__z_name, "byond:Z_machine_set_post_tick_proc")(ID, PROC)

#define Z_MACHINE_SET_TRAP_PROC(ID, PROC) call_ext(__z_name, "byond:Z_machine_set_trap_proc")(ID, PROC)

#define Z_MACHINE_SET_SYSCALL_PROC(ID, PROC) call_ext(__z_name, "byond:Z_machine_set_syscall_proc")(ID, PROC)

/// Manually adds cycles and mtime to the machine registers.
/// Useful for simulating elapsed time or debugging.
#define Z_MACHINE_APPEND_COUNTERS(ID, CYCLES, IDLE_CYCLES, MTIME) call_ext(__z_name, "byond:Z_machine_append_counters")(ID, CYCLES, IDLE_CYCLES, MTIME)

/// Loads a RISC-V ELF binary from the given file path into the machine's RAM.
/// RAM must be allocated first via Z_MACHINE_SET_RAM_SIZE.
#define Z_MACHINE_LOAD_ELF(ID, PATH) call_ext(__z_name, "byond:Z_machine_load_elf")(ID, PATH)

#define Z_MACHINE_SYSCALL(ID, SLOT, ARGS...) call_ext(__z_name, "byond:Z_machine_syscall")(ID, SLOT, ARGS)

/// Attaches a PCI device to a machine. Returns PCI slot id.
#define Z_MACHINE_TRY_ATTACH_PCI(ID, TYPE_ID) call_ext(__z_name, "byond:Z_machine_try_attach_pci")(ID, TYPE_ID)

/// Detaches a PCI device from a machine.
#define Z_MACHINE_TRY_DETACH_PCI(ID, SLOT) call_ext(__z_name, "byond:Z_machine_try_detach_pci")(ID, SLOT)

#define Z_MACHINE_DUMP_REGISTERS(ID) call_ext(__z_name, "byond:Z_machine_dump_registers")(ID)

/// Destroys a machine and frees all its resources.
#define Z_MACHINE_DESTROY(ID) call_ext(__z_name, "byond:Z_machine_destroy")(ID)

/// Executes all runnable machines for DELTA_US microseconds of emulated time.
/// Budget and scheduling are handled internally by the backend.
/// MMIO events trigger mmio_read/mmio_write on connected BYOND objects.
#define Z_MACHINES_TICK(DELTA_US) call_ext(__z_name, "byond:Z_machines_tick")(DELTA_US)

/// Returns JSON string with global emulator statistics.
/// Fields: total_instructions, total_cycles, total_ticks,
///         last_wall_us, last_budget_us, last_machines_served,
///         last_machines_starved, load_avg
#define Z_MACHINES_STATS(...) call_ext(__z_name, "byond:Z_machines_stats")()

/// Sets the max percentage of delta time the emulator may use (10-80).
/// Lower = more time for game logic, higher = faster emulation.
#define Z_MACHINES_SET_BUDGET(PERCENT) call_ext(__z_name, "byond:Z_machines_set_budget")(PERCENT)

// Crypto

/// Generates a LEN bytes and encodes them in url-safe base64 string without padding.
#define Z_CRYPTO_RANDOM_BASE64(LEN) call_ext(__z_name, "byond:Z_crypto_random_base64")(LEN)

/// Content and key must be a string.
/// Returns a url-safe base64 string without padding.
#define Z_CRYPTO_HMAC_SHA256(CONTENT, KEY) call_ext(__z_name, "byond:Z_crypto_hmac_sha256")(CONTENT, KEY)
