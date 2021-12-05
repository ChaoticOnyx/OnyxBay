#define DMJIT_LIB "./libdmjit.so"
#define DMJIT_NATIVE CRASH("dm-jit not loaded")

/proc/dmjit_hook_main_init()
    if (world.system_type != UNIX)
        return

    log_debug_verbose(call(DMJIT_LIB, "auxtools_init")())
    log_debug_verbose(dmjit_hook_log_init())

    dmjit_compile_proc("/datum/controller/subsystem/garbage/proc/Queue")
    dmjit_compile_proc("/obj/machinery/alarm/proc/overall_danger_level")
    dmjit_compile_proc("/datum/controller/subsystem/processing/fire")
    dmjit_compile_proc("/obj/machinery/power/apc/Process")
    dmjit_compile_proc("/atom/movable/lighting_overlay/proc/update_overlay")
    dmjit_compile_proc("/turf/simulated/return_air")
    dmjit_compile_proc("/obj/machinery/alarm/proc/get_danger_level")

    log_debug_verbose(dmjit_install_compiled())


// INIT
/proc/dmjit_hook_log_init()
    DMJIT_NATIVE

// DEBUG
/proc/dmjit_hook_call(src)
    DMJIT_NATIVE

// DEBUG Re-enter
/proc/dmjit_on_test_call()
    DMJIT_NATIVE

// Dump call counts
/proc/dmjit_dump_call_count()
    DMJIT_NATIVE

// Dump opcode use counts
/proc/dmjit_dump_opcode_count()
    DMJIT_NATIVE

/proc/dmjit_dump_opcodes(name)
    DMJIT_NATIVE

/proc/dmjit_hook_compile()
    DMJIT_NATIVE

/proc/dmjit_compile_proc(name)
    DMJIT_NATIVE

/proc/dmjit_install_compiled()
    DMJIT_NATIVE

/proc/dmjit_toggle_hooks()
    DMJIT_NATIVE

/proc/dmjit_toggle_call_counts()
    DMJIT_NATIVE

/proc/dmjit_get_datum_ref_count(arg)
    DMJIT_NATIVE

/proc/dmjit_mark_time(name)
    DMJIT_NATIVE

/proc/dmjit_report_time(name)
    DMJIT_NATIVE

/proc/dmjit_call_hierarchy(name)
    DMJIT_NATIVE

/proc/dmjit_dump_deopts()
    DMJIT_NATIVE
