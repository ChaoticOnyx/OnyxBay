var/__z_name = null

/proc/__z_detect()
	if (__z_name != null)
		return
	
	if(world.system_type == MS_WINDOWS)
		if(fexists("z.native.dll"))
			__z_name = "z.native.dll"
		else
			__z_name = "z.dll"
	else
		if(fexists("libz.native.so"))
			__z_name = "libz.native.so"
		else
			__z_name = "libz.so"

#define Z_ERROR_OUT_OF_ID "OutOfId"
#define Z_ERROR_OUT_OF_MEMORY "OutOfMemory"
#define Z_ERROR_MACHINE_NOT_FOUND "MachineNotFound"
#define Z_ERROR_FILE_NOT_FOUND "FileNotFound"
#define Z_ERROR_FILE_TOO_BIG "FileTooBig"
#define Z_ERROR_OUT_OF_RAM "OutOfRam"
#define Z_ERROR_BAD_ELF "BadElf"
#define Z_ERROR_BAD_STATE "BadState"
#define Z_ERROR_SLOT_NOT_FOUND "SlotNotFound"
#define Z_ERROR_UNKNOWN "Unknown"

#define Z_MSTATE_STOPPED (1)
#define Z_MSTATE_RUNNING (2)

#define Z_MAX_PCI_DEVICES 18

#define Z_DEVICE_TYPE_TTS 1
#define Z_DEVICE_TYPE_SERIAL_TERMINAL 2
#define Z_DEVICE_TYPE_SIGNALER 3

#define Z_TTS_N2B_CMD_SAY 1
#define Z_TTS_B2N_CMD_READY_STATUS 1

#define Z_SERIAL_N2B_CMD_WRITE 1
#define Z_SERIAL_B2N_CMD_WRITE 1

#define Z_SIGNALER_N2B_CMD_SET 1
#define Z_SIGNALER_N2B_CMD_SEND 2
#define Z_SIGNALER_B2N_CMD_PULSE 1
#define Z_SIGNALER_B2N_CMD_READY_STATUS 2

// All machine IDs are numeric handles returned by Z_MACHINE_CREATE.

/// Returns the last error message from the backend, or null if no error.
#define Z_GET_LAST_ERROR(...) call_ext(__z_name, "byond:Z_get_last_error")()

/// Creates a new machine. Returns numeric machine ID.
/// Machine starts with no RAM and default frequency (1 MHz), not yet runnable.
#define Z_MACHINE_CREATE(...) call_ext(__z_name, "byond:Z_machine_create")()

/// Resets a machine: zeroes all CPU registers and clears RAM contents.
/// Frequency, RAM size, and connected BYOND object are preserved.
/// ELF must be reloaded after reset.
#define Z_MACHINE_RESET(ID) call_ext(__z_name, "byond:Z_machine_reset")(ID)

/// Binds a machine to a BYOND object for MMIO callbacks (mmio_read/mmio_write).
/// Pass null as OBJ to disconnect.
#define Z_MACHINE_CONNECT(ID, OBJ) call_ext(__z_name, "byond:Z_machine_connect")(ID, OBJ)

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

#define Z_MACHINE_SET_SENSORS(ID, TEMP, POWER_USAGE, OVERHEAT, THROTTLED) call_ext(__z_name, "byond:Z_machine_set_sensors")(ID, TEMP, POWER_USAGE, OVERHEAT, THROTTLED)

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

/// Shuts down the emulator, destroys all machines and frees all memory.
#define Z_DEINIT(...) call_ext(__z_name, "byond:Z_deinit")()
