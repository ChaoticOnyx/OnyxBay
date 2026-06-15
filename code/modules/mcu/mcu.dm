/// Throttle disengages at (throttle_temp - hysteresis) to prevent oscillation
#define MCU_THROTTLE_HYSTERESIS 5
/// Board won't restart until it cools below (shutdown_temp - this)
#define MCU_RESTART_COOLDOWN 20
/// Ticks at ≥95% utilization before sustained-load penalty kicks in
#define MCU_SUSTAINED_THRESHOLD 5
/// Throttled frequency multiplier
#define MCU_THROTTLE_MULT 0.5
/// Player can overclock up to this multiplier above max_frequency
#define MCU_MAX_OVERCLOCK_MULT 1.5
/// Fraction of cooling_k remaining in vacuum (radiation only)
#define MCU_VACUUM_COOLING_FACTOR 0.01
/// Below this many moles, treat environment as vacuum
#define MCU_VACUUM_MOLES_THRESHOLD 0.1
/// Steep power ramp above 0.9 utilization - models worst-case
/// switching activity when CPU never hits idle micro-gaps.
/// At util=1.0, effective utilization becomes 1.0 + this value.
#define MCU_BUSY_POWER_BONUS 4.0
/// Sustained load penalty increment per tick above threshold.
#define MCU_SUSTAINED_PENALTY_STEP  0.25
#define MCU_SUSTAINED_PENALTY_CAP 5.0
#define MCU_MEMORY_CORRUPTION_FREQUENCY (1 MINUTE)
/// Reference mass for MCU dose calculations (kg). Affects dose magnitude - tune coefficients accordingly.
#define MCU_RAD_MASS 0.1
/// Minimum interval between radiation effect rolls.
#define MCU_RAD_TICK_INTERVAL (1 SECONDS)
/// effective_dose * coeff = probability% of SEU per tick.
#define MCU_RAD_SEU_COEFF 0.5
/// effective_dose * coeff = number of corrupted bytes per SEU event.
#define MCU_RAD_SEU_BYTE_COEFF 0.3
/// Hard cap on bytes corrupted in a single SEU.
#define MCU_RAD_SEU_MAX_BYTES 16
/// effective_dose * coeff = probability% of SEL per tick.
#define MCU_RAD_SEL_COEFF 0.05
/// Default TID limit before permanent failure (game units).
#define MCU_DEFAULT_TID_LIMIT 100
/// TID ratio: mild degradation warning + 1.5x error multiplier.
#define MCU_TID_WARN_RATIO 0.50
/// TID ratio: visible degradation + 2x error multiplier.
#define MCU_TID_DEGRADE_RATIO 0.75

#define MCU_STATE_OFF 0
#define MCU_STATE_ON 1
#define MCU_MAX_MESSAGES 25
#define MCU_GC_COLLECT_INTERVAL (5 SECONDS)
#define MCU_CALLSTACK_DEPTH 16

/obj/item/device/mcu
	name = "generic MCU"
	desc = "A microcontroller unit. This one seems to be a prototype."
	icon = 'icons/obj/mcu.dmi'
	icon_state = "green"
	w_class = ITEM_SIZE_TINY

	var/datum/script/__script = null
	var/list/__included_files = list()
	var/__state = MCU_STATE_OFF
	var/__wait_ds = 0
	var/obj/item/mcu_module/__wait_module = null
	var/__last_think = 0
	var/__last_compile = 0
	var/__last_gc_collect = 0
	var/__used_memory = 0
	var/list/__callstack = list()
	var/list/__messages = list()
	var/__interrupts_enabled = TRUE

	var/ram_size = 65536 // 64 KB
	/// User-set frequency. Hz
	var/target_frequency = 1000000 // 1 MHz
	/// Actual running frequency (target * throttle multiplier). Hz
	var/frequency = 1000000
	/// Hardware minimum. Hz
	var/min_frequency = 500000 // 500 kHz
	/// OC goes above this. Hz
	var/max_frequency = 1000000 // 1 MHz
	/// Heat capacity. J/K
	var/thermal_mass = 4.0
	/// Power draw when on but CPU idle. W
	var/P_idle = 2 WATT
	/// Dynamic power per MHz at full load. W/MHz
	var/K_power = 8
	/// Thermal conductance to environment. W/K
	var/cooling_k = 0.10

	/// CPU frequency halved. K
	var/throttle_temp = 65 CELSIUS
	/// Emergency power-off. K
	var/shutdown_temp = 90 CELSIUS
	/// Board takes physical damage. K
	var/damage_temp = 95 CELSIUS

	/// Current board temperature. K
	var/temperature = 20 CELSIUS
	var/throttled = FALSE
	/// Consecutive ticks at >=95% utilization
	var/sustained_full_ticks = 0
	var/oc_unlocked = FALSE
	var/oc_ram_protection = FALSE
	/// Forbid re-programming of the MCU.
	var/flash_protection = FALSE

	/// Radiation hardening factor. 0.0 = fully vulnerable, 1.0 = immune.
	var/rad_hardening = 0.0
	/// Accumulated Total Ionizing Dose (game-units, from calc_equivalent_dose).
	var/accumulated_tid = 0.0
	/// TID threshold for permanent failure.
	var/tid_limit = MCU_DEFAULT_TID_LIMIT
	/// Permanently destroyed by cumulative radiation.
	var/rad_dead = FALSE

	/// The maximum severity of an EMP the board can survive.
	var/emp_hardening = 0
	var/emp_dead = FALSE

	var/broken = FALSE

	var/pci_slots = 2

	var/list/obj/item/mcu_module/__pci_devices = null
	var/obj/item/cell/__battery = null

	var/weakref/__chassis = null

/obj/item/device/mcu/Initialize()
	. = ..()

	ASSERT(pci_slots >= 0)
	__pci_devices = new /list(pci_slots)

/obj/item/device/mcu/Destroy()
	set_next_think(0)
	__wait_module = null

	if(!QDELETED(__script))
		qdel(__script)
		__script = null
		SSmcu.total_mcu -= 1

	for(var/obj/item/mcu_module/M in __pci_devices)
		if(!QDELETED(M))
			qdel(M)

	if(!QDELETED(__battery))
		qdel(__battery)
		__battery = null

	. = ..()

/obj/item/device/mcu/examine(mob/user, infix)
	. = ..()

	if(!user.IsAdvancedToolUser())
		return

	if(user.Adjacent(src))
		if(broken)
			. += SPAN_DANGER("The board is completely broken and unusable!")

		if(emp_dead)
			. += SPAN_DANGER("The circuitry is burnt out from EMP. It will never function again.")

		if(rad_dead)
			. += SPAN_DANGER("The circuitry is burnt out from radiation. It will never function again.")
		else
			ASSERT(tid_limit != 0)
			var/tid_ratio = accumulated_tid / tid_limit

			if(tid_ratio >= MCU_TID_DEGRADE_RATIO)
				. += SPAN_WARNING("The board shows significant brown discoloration from radiation exposure.")
			else if(tid_ratio >= MCU_TID_WARN_RATIO)
				. += SPAN_WARNING("You notice slight discoloration on the board - possibly radiation.")

			if(issilicon(user) || hasHUD(user, HUD_SCIENCE))
				. += "Radiation: [accumulated_tid]/[tid_limit] TID"

		if(issilicon(user) || hasHUD(user, HUD_SCIENCE))
			. += "Temperature: [CONV_KELVIN_CELSIUS(temperature)]°C"
		else
			if(temperature < 30 CELSIUS)
				. += "It feels [SPAN_NOTICE("cool")] to the touch."
			else if(temperature < 45 CELSIUS)
				. += "It feels [SPAN_NOTICE("warm")] to the touch."
			else if(temperature < 60 CELSIUS)
				. += "It feels [SPAN_WARNING("hot")] to the touch."
			else if(temperature < 80 CELSIUS)
				. += "It feels [SPAN_WARNING("painfully hot")]! You pull your hand away."
			else if(temperature < 100 CELSIUS)
				. += "It is [SPAN_DANGER("searing hot")]! Touching it would burn you."
			else
				. += "It is [SPAN_DANGER("glowing with heat")]! The air around it shimmers."

		if(oc_unlocked)
			. += "The [SPAN_WARNING("OC")] jumper is set - overclocking enabled."
		else
			. += "The OC jumper is in default position."

		if(flash_protection)
			. += "The write-protect OTP fuse appears [SPAN_DANGER("burned")]."

		if(__battery)
			var/charge_percent = __battery.maxcharge > 0 ? round(__battery.charge / __battery.maxcharge * 100) : 0
			var/charge_span

			if(charge_percent > 50)
				charge_span = SPAN_NOTICE("[charge_percent]%")
			else if(charge_percent > 20)
				charge_span = SPAN_WARNING("[charge_percent]%")
			else
				charge_span = SPAN_DANGER("[charge_percent]%")

			. += "A [__battery] is installed. Charge indicator: [charge_span]."
		else
			. += "There is [SPAN_WARNING("no battery")] installed."

	if(is_on())
		if(throttled)
			. += "A small LED blinks [SPAN_WARNING("orange")]."
		else
			. += "A small LED glows [SPAN_NOTICE("green")]."
	else
		if(temperature >= (shutdown_temp - MCU_RESTART_COOLDOWN))
			. += "A small LED blinks [SPAN_DANGER("red")]. It needs to cool down."
		else
			. += "A small LED is off."

	if(user.Adjacent(src))
		var/list/modules = list()

		for(var/obj/item/mcu_module/M in __pci_devices)
			if(QDELETED(M))
				continue

			modules += SPAN_NOTICE("[M.name]")

		if(length(modules) > 0)		
			. += "Modules are connected to the board: [english_list(modules)]"

/obj/item/device/mcu/tgui_static_data(mob/user)
	. = ..()
	.["declarations"] = GLOB.script_mcu_decls.generate_completions()

/obj/item/device/mcu/tgui_data(mob/user)
	var/list/data = list(
		"compile_errors" = list(),
		"runtime_errors" = list(),
		"messages" = __messages,
		"is_on" = is_on(),
	)

	if(QDELETED(__script))
		return data
	
	var/compile_error_kind = __script.get_compile_error_kind()
	var/compile_error_pos = __script.get_compile_error_pos()

	if(compile_error_kind != 0)
		var/message = ""

		switch(compile_error_kind)
			if(Z_SCRIPT_COMPILE_ERROR_EXPECTED_OP)
				message = "Expected an operation"
			if(Z_SCRIPT_COMPILE_ERROR_UNKNOWN_OP)
				message = "An unknown operation"
			if(Z_SCRIPT_COMPILE_ERROR_BAD_OP_ARGS)
				message = "Bad operation arguments"
			if(Z_SCRIPT_COMPILE_ERROR_BAD_STRING_LITERAL)
				message = "Bad string literal"
			if(Z_SCRIPT_COMPILE_ERROR_BAD_SYMBOL_LITERAL)
				message = "Bad symbol literal"
			if(Z_SCRIPT_COMPILE_ERROR_BAD_NUMBER_LITERAL)
				message = "Bad number literal"
			if(Z_SCRIPT_COMPILE_ERROR_TOO_BIG_INT)
				message = "Number is too big"
			if(Z_SCRIPT_COMPILE_ERROR_SYNTAX)
				message = "Bad syntax"
			if(Z_SCRIPT_COMPILE_ERROR_UNKNOWN_LABEL)
				message = "Unknown label"

		data["compile_errors"] += list(list(
			"pos" = compile_error_pos,
			"message" = message,
		))
	
	var/runtime_error_kind = __script.get_runtime_error_kind()
	var/runtime_error_ip = __script.get_runtime_error_ip()

	if(runtime_error_kind != 0)
		var/message = ""
		var/pos = __script.get_op_pos(runtime_error_ip)

		switch(runtime_error_kind)
			if(Z_SCRIPT_RUNTIME_ERROR_DIVISION_BY_ZERO)
				message = "Division by zero"
			if(Z_SCRIPT_RUNTIME_ERROR_TYPE_MISMATCH)
				message = "Type mismatch"
			if(Z_SCRIPT_RUNTIME_ERROR_STACK_UNDERFLOW)
				message = "Stack underflow"
			if(Z_SCRIPT_RUNTIME_ERROR_STACK_OVERFLOW)
				message = "Stack overflow"
			if(Z_SCRIPT_RUNTIME_ERROR_UNKNOWN_OPCODE)
				message = "Unknown opcode"
			if(Z_SCRIPT_RUNTIME_ERROR_UNDEFINED_FUNCTION)
				message = "Undefined function"
			if(Z_SCRIPT_RUNTIME_ERROR_UNDEFINED_VARIABLE)
				message = "Undefined variable"
			if(Z_SCRIPT_RUNTIME_ERROR_INVALID_BIT_SHIFT)
				message = "Invalid bit shift"
			if(Z_SCRIPT_RUNTIME_ERROR_FUNCTION)
				message = "Function error"

		data["runtime_errors"] += list(list(
			"pos" = pos,
			"message" = message,
		))

	return data

/obj/item/device/mcu/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ScriptEditor")
		ui.open()

/obj/item/device/mcu/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(.)
		return
	
	switch(action)
		if("start")
			power_on(usr)

			return TRUE
		if("stop")
			power_off(usr)

			return TRUE
		if("compile")
			if(!config.mcu.enable || SSmcu.total_mcu >= config.mcu.hardcap)
				to_chat(usr, SPAN_WARNING("Some indescribable force is preventing the board from programming."))
				return

			if(is_on())
				to_chat(usr, SPAN_WARNING("The MCU must be powered off before programming."))
				return

			if(flash_protection)
				to_chat(usr, SPAN_WARNING("The OTP fuse is burned. \The [src] cannot be reprogrammed."))
				return

			if(world.time - __last_compile < 2 SECONDS)
				to_chat(usr, SPAN_WARNING("Wait before the next compilation."))
				return

			__last_compile = world.time

			__included_files = params["included_files"]
			if(!islist(__included_files))
				__included_files = list()

			if(QDELETED(__script))
				__script = new(ram_size)
				SSmcu.total_mcu += 1
			
			try
				__script.reset(TRUE, TRUE, TRUE)
				__script.gc_collect()
				GLOB.script_mcu_decls.register_functions(__script, src, __included_files)
				GLOB.script_mcu_decls.register_vars(__script, __included_files)

				switch(__script.compile(params["code"]))
					if(Z_SCRIPT_COMPILE_RESULT_ERROR)
						to_chat(usr, SPAN_WARNING("The script has errors!"))
						return TRUE
					if(Z_SCRIPT_COMPILE_RESULT_OUT_OF_LIMITS)
						to_chat(usr, SPAN_WARNING("The script is too complex!"))
						return TRUE
					if(Z_SCRIPT_COMPILE_RESULT_OUT_OF_MEMORY)
						to_chat(usr, SPAN_WARNING("The script is too big!"))
						return TRUE
			catch
				to_chat(usr, SPAN_WARNING("Failed to compile the source code!"))
				return TRUE

			to_chat(usr, "Code compiled successfully")

			return TRUE

/obj/item/device/mcu/attackby(obj/item/W, mob/user)
	if(!user.IsAdvancedToolUser())
		return ..()

	if(istype(W, /obj/item/jtag_programmer))
		// Just warnings
		if(is_on())
			to_chat(user, SPAN_WARNING("The MCU must be powered off before programming."))

		if(flash_protection)
			to_chat(user, SPAN_WARNING("The OTP fuse is burned. \The [src] cannot be reprogrammed."))
		
		tgui_interact(user)

		return
	else if(isMultitool(W))
		var/upper_bound = oc_unlocked ? round(max_frequency * MCU_MAX_OVERCLOCK_MULT) : max_frequency
		var/new_freq = input(user, "Enter new frequency in Hz between [min_frequency] and [upper_bound]", "Multitool") as num|null

		if(QDELETED(src) || QDELETED(user) || !user.Adjacent(src))
			return

		if(new_freq != null)
			set_target_frequency(new_freq, user)

		return
	else if(isScrewdriver(W))
		playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
		set_oc_unlocked(!oc_unlocked, user)

		return
	else if(istype(W, /obj/item/weldingtool))
		if(flash_protection)
			to_chat(user, SPAN_WARNING("The OTP fuse is already burned."))
			return

		var/obj/item/weldingtool/WT = W
		var/confirm = alert(user, "Burn the write-protect OTP fuse? This is PERMANENT and will prevent any future reprogramming.", "Burn OTP Fuse", "Yes", "No")

		if(confirm != "Yes")
			return

		if(!WT.use_tool(src, user, delay = 1 SECOND, amount = 1))
			return

		if(QDELETED(src) || QDELETED(user) || !user.Adjacent(src))
			return

		flash_protection = TRUE
		user.visible_message( \
			SPAN_NOTICE("[user] carefully burns the OTP fuse on \the [src]."), \
			SPAN_NOTICE("You burn the OTP fuse. The firmware is now permanently locked.") \
		)

		return
	else if(istype(W, /obj/item/cell))
		if(!QDELETED(__battery))
			to_chat(user, SPAN_WARNING("There is a battery already"))
			return

		if(!user.drop(W, src))
			return

		__battery = W
		user.visible_message(\
			"[user] inserts \the [W] into \the [src].", \
			"You insert \the [W] into \the [src]." \
		)

		return
	else if(istype(W, /obj/item/mcu_module))
		var/obj/item/mcu_module/M = W

		try_add_pci(M, user)

		return
	else if(istype(W, /obj/item/stack/nanopaste))
		var/obj/item/stack/nanopaste/P = W

		if (accumulated_tid <= 0)
			to_chat(user, SPAN_NOTICE("[src] shows no signs of radiation-induced oxide degradation."))
			return

		if(!do_after(user, 1, src, TRUE))
			return

		if (!P.use(1))
			to_chat(user, SPAN_WARNING("There isn't enough nanopaste left."))
			return

		accumulated_tid = max(0, accumulated_tid - 5)

		if(accumulated_tid <= 0)
			user.visible_message( \
				SPAN_NOTICE("[user] finishes treating [src] with [W]. The device hums back to life."), \
				SPAN_NOTICE("You apply [W] to [src], restoring the irradiated semiconductor lattice. The device is fully operational now.") \
			)
		else if(accumulated_tid > 15)
			user.visible_message( \
				SPAN_NOTICE("[user] applies [W] to [src], but the device still looks damaged."), \
				SPAN_NOTICE("You apply [W] to [src], but severe radiation damage remains. The oxide layers are still degraded.") \
			)
		else
			user.visible_message( \
				SPAN_NOTICE("[user] carefully applies [W] to [src], repairing some damage."), \
				SPAN_NOTICE("You apply [W] to [src], annealing some of the radiation-induced charge traps. Further treatment is needed.") \
			)

		return

	return ..()

/obj/item/device/mcu/proc/__interact(mob/user)
	if(!user.IsAdvancedToolUser())
		return FALSE

	for(var/i = 1 to pci_slots)
		var/obj/item/mcu_module/M = __pci_devices[i]

		if(QDELETED(M))
			continue

		if(M.__interact(user))
			return TRUE
	
	return FALSE

/obj/item/device/mcu/attack_self(mob/user)
	if(__interact(user))
		return

	return ..()

/obj/item/device/mcu/proc/try_add_pci(obj/item/mcu_module/M, mob/activator = null)
	ASSERT(M.__pci_slot == null)
	ASSERT(M.__host == null)

	var/slot = null

	for(var/i = 1 to pci_slots)
		if(__pci_devices[i] == null)
			slot = i
			break

	if(slot == null)
		if(activator)
			to_chat(activator, SPAN_WARNING("No more PCI slots available."))

		return FALSE

	if(activator)
		if(!activator.drop(M, src))
			return FALSE
	else
		M.forceMove(src)

	M.__pci_slot = slot
	M.__host = weakref(src)
	ASSERT(__pci_devices[slot] == null)
	__pci_devices[slot] = M

	M.__reset(TRUE)

	if(activator)
		activator.visible_message(
			"[activator] inserts \the [M] to \the [src]", \
			SPAN_NOTICE("You insert \the [M] to \the [src].") \
		)

	return TRUE

/obj/item/device/mcu/emp_act(severity)
	if(!QDELETED(__battery))
		__battery.emp_act(severity)

	for(var/obj/item/mcu_module/M in __pci_devices)
		if(QDELETED(M))
			continue

		M.emp_act(severity)

	if(emp_dead)
		return

	if(severity > emp_hardening)
		emergency_shutdown(FALSE)
		emp_dead = TRUE

/obj/item/device/mcu/bullet_act(obj/item/projectile/P, def_zone)
	..()

	if(P.damage != 0)
		destroy(TRUE)

/obj/item/device/mcu/ex_act(severity)
	if(!QDELETED(__battery))
		__battery.ex_act(severity)

	for(var/obj/item/mcu_module/M in __pci_devices)
		if(QDELETED(M))
			continue

		M.ex_act(severity)

	destroy(TRUE)

/obj/item/device/mcu/melt()
	..()

	emergency_shutdown(FALSE)
	qdel(src)

/obj/item/device/mcu/proc/destroy(complete = FALSE)
	emergency_shutdown(FALSE)
	visible_message(SPAN_DANGER("\The [src] breaks apart!"))

	var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
	sparks.set_up(3, 1, get_turf(src))
	sparks.start()

	if(!QDELETED(__battery))
		if(prob(50))
			visible_message(SPAN_DANGER("\The [__battery] breaks apart!"))
			qdel(__battery)
		else
			__battery.forceMove(get_turf(src))
			__battery.throw_at_random(FALSE, 2, 1)
		
		__battery = null

	for(var/obj/item/mcu_module/M in __pci_devices)
		if(QDELETED(M))
			continue

		ASSERT(try_detach_pci_module(M, null) == TRUE)

		if(prob(50))
			visible_message(SPAN_DANGER("\The [M] breaks apart!"))
			qdel(M)

			continue

		M.forceMove(get_turf(src))
		M.throw_at_random(FALSE, 2, 1)

	if(complete)
		qdel(src)
	else
		broken = TRUE

/obj/item/device/mcu/proc/set_oc_unlocked(new_state, mob/activator = null)
	oc_unlocked = new_state

	if(activator)
		activator.visible_message(
			"[activator] switches a safety jumper on \the [src]", \
			SPAN_NOTICE("You switch the safety jumper on \the [src]. Overclocking is now [oc_unlocked ? "enabled" : "disabled"].") \
		)

	set_target_frequency(target_frequency)

/// Set target frequency.
/// Clamps to valid range based on oc_unlocked state.
/obj/item/device/mcu/proc/set_target_frequency(new_freq, activator = null)
	var/upper_limit = max_frequency
	if(oc_unlocked)
		upper_limit = round(max_frequency * MCU_MAX_OVERCLOCK_MULT)

	target_frequency = clamp(new_freq, min_frequency, upper_limit)

	if(activator)
		to_chat(activator, SPAN_NOTICE("Frequency set to [target_frequency] Hz."))

	// Immediately apply (will be adjusted by throttle in __post_tick)
	__update_effective_frequency()

/// Total electrical power draw in Watts.
/// P = P_idle + K_eff * F_MHz * utilization * load_penalty
///
/// Overclock (F > F_max): K grows quadratically (models voltage increase).
/// Sustained full load: +10 % per extra tick after threshold, up to x2.
/// Power calculation uses EFFECTIVE frequency (what actually runs).
/// but OC penalty based on TARGET (what player set).
/obj/item/device/mcu/proc/calculate_power(util)
	if(!is_on())
		return 0

	// Hz -> MHz
	var/F_mhz = frequency / 1000000
	// W/MHz
	var/K = K_power

	// Real CPUs need higher voltage to be stable above rated freq;
	// power ~ V² ~ (F/F_max)²
	if(target_frequency > max_frequency)
		var/oc_ratio = target_frequency / max_frequency
		K *= (oc_ratio * oc_ratio)

	var/eff_util = effective_utilization(util)

	// Models transistor-level inefficiency when chip never enters
	// low-power idle gaps. Kicks in after MCU_SUSTAINED_THRESHOLD
	// consecutive full-load ticks; caps at ×2 total.
	var/load_penalty = 1.0

	if(sustained_full_ticks > MCU_SUSTAINED_THRESHOLD)
		var/extra = sustained_full_ticks - MCU_SUSTAINED_THRESHOLD
		load_penalty += clamp(extra * MCU_SUSTAINED_PENALTY_STEP, 0, MCU_SUSTAINED_PENALTY_CAP)

	return P_idle + K * F_mhz * eff_util * load_penalty

/// Maps raw utilization (0.0-1.0) to effective power utilization.
///
/// util 0.01: returns ~0.015
/// util 0.50: returns ~0.60
/// util 0.90: returns ~1.2
/// util 1.00: returns ~3.0 (busy-loop penalty)
/obj/item/device/mcu/proc/effective_utilization(util)
	if(util <= 0)
		return 0

	var/base = 0.005

	if(util <= 0.9)
		return base + util * 1.2

	var/linear_part = base + 0.9 * 1.2  // ~1.085
	var/t = (util - 0.9) / 0.1  // 0.0-1.0
	var/penalty = MCU_BUSY_POWER_BONUS * t * t

	return linear_part + 0.1 * 1.2 * t + penalty

/obj/item/device/mcu/proc/power_on(mob/activator = null)
	throttled = FALSE
	sustained_full_ticks = 0

	if(rad_dead || emp_dead)
		if(activator)
			to_chat(activator, SPAN_WARNING("\The [src] is unresponsive - the circuitry is dead."))

		return FALSE

	if(broken)
		if(activator)
			to_chat(activator, SPAN_WARNING("\The [src] is broken and cannot be powered on."))

		return FALSE

	if(!config.mcu.enable || SSmcu.total_running >= config.mcu.hardcap)
		if(activator)
			to_chat(activator, SPAN_WARNING("Some indescribable force is preventing the board from starting."))

		return FALSE

	if(temperature >= (shutdown_temp - MCU_RESTART_COOLDOWN))
		if(activator)
			to_chat(activator, SPAN_WARNING("\The [src] is too hot to restart!"))

		return FALSE

	if(is_on())
		if(activator)
			to_chat(activator, SPAN_WARNING("\The [src] is already powered on!"))

		return FALSE

	if(QDELETED(__script))
		if(activator)
			to_chat(activator, SPAN_WARNING("\The [src] fails to start."))

		return FALSE

	// Wh
	var/min_boot_charge = P_idle / 3600
	if(!__try_drain_power(min_boot_charge, FALSE))
		if(activator)
			to_chat(activator, SPAN_WARNING("There is no power to start."))

		return FALSE

	for(var/obj/item/mcu_module/M in __pci_devices)
		if(QDELETED(M))
			continue

		M.__power_on()

	__script.set_ip(0)
	__script.reset(TRUE, FALSE, TRUE)
	__script.gc_collect()
	GLOB.script_mcu_decls.register_vars(__script, __included_files)
	__state = MCU_STATE_ON
	__messages = list()
	__wait_ds = 0
	__interrupts_enabled = TRUE
	SSmcu.total_running += 1

	if(activator)
		activator.visible_message("[activator] turns \the [src] on.", "You turn \the [src] on.")

	if(__chassis != null)
		__chassis.resolve().__on_mcu_on()

	set_next_think(world.time + world.tick_lag)
	__last_think = world.time

	return TRUE

/obj/item/device/mcu/proc/is_on()
	if(QDELETED(__script))
		return FALSE

	return __state == MCU_STATE_ON

/obj/item/device/mcu/proc/power_off(mob/activator = null, is_trap = FALSE)
	throttled = FALSE
	sustained_full_ticks = 0

	if(!is_on())
		if(activator)
			to_chat(activator, SPAN_WARNING("The CPU is not turned on."))

		return FALSE

	if(activator)
		activator.visible_message("[activator] turns \the [src] off.", "You turn \the [src] off.")

	__state = MCU_STATE_OFF
	SSmcu.total_running -= 1

	for(var/obj/item/mcu_module/M in __pci_devices)
		if(QDELETED(M))
			continue

		M.__power_off()
	
	if(__chassis != null)
		__chassis.resolve().__on_mcu_off(is_trap)

	return TRUE

/obj/item/device/mcu/proc/emergency_shutdown(is_trap = FALSE)
	throttled = FALSE
	sustained_full_ticks = 0

	if(!is_on())
		return

	visible_message(SPAN_WARNING("[src] shuts down!"))
	power_off(null, is_trap)

/obj/item/device/mcu/proc/remove_battery(mob/activator = null)
	if(QDELETED(__battery))
		if(activator)
			to_chat(activator, SPAN_WARNING("There is no battery to remove."))

		return FALSE

	if(activator)
		if(!activator.put_in_hands(__battery))
			__battery.forceMove(get_turf(src))
	else
		__battery.forceMove(get_turf(src))

	__battery = null
	emergency_shutdown(FALSE)

	return TRUE

/obj/item/device/mcu/proc/__try_drain_power(amount, recharge_battery = FALSE)
	amount *= config.mcu.power_scale

	if(__chassis != null)
		var/obj/item/mcu_chassis/C = __chassis.resolve()

		if(C.has_external_power_source && C.try_drain_power(amount))
			if(recharge_battery && !QDELETED(__battery) && __battery.charge < __battery.maxcharge)
				var/recharge_amount = __battery.maxcharge * config.mcu.battery_recharge_percent

				if(C.try_drain_power(recharge_amount))
					__battery.add_charge(recharge_amount)

			return TRUE

	if(QDELETED(__battery))
		return FALSE

	return __battery.use(amount)

/obj/item/device/mcu/think()
	var/delta_ds = world.time - __last_think
	var/delta_s = delta_ds * 0.1
	__last_think = world.time

	set_next_think(world.time + world.tick_lag)

	__wait_ds = max(0, __wait_ds - delta_ds)

	if(!QDELETED(__wait_module) && __wait_module.ready)
		__wait_module = null

	// Generated heat
	var/P = 0 WATT
	var/energy_Wh = 0

	if(is_on() && __wait_ds <= 0 && __wait_module == null)
		var/budget_ds = ((delta_ds * config.mcu.budget_percent) / 100) / SSmcu.total_running
		var/max_ops = round((frequency * budget_ds) / 10)
		var/budget_util = 0.0
		var/ret = null

		try
			ret = __script.run_script(max_ops, budget_ds, 50000, &budget_util)

			if(ret == Z_SCRIPT_FUNCTION_ERROR)
				tgui_update()
				emergency_shutdown(TRUE)

				return
		catch
			tgui_update()
			emergency_shutdown(TRUE)

			return

		__used_memory = __script.get_used_memory()

		if(world.time - __last_gc_collect > MCU_GC_COLLECT_INTERVAL)
			__script.gc_collect()
			__last_gc_collect = world.time

		// Sustained full-load tracking
		if(budget_util >= 0.95)
			sustained_full_ticks++
		else
			sustained_full_ticks = max(0, sustained_full_ticks - 2)

		P = calculate_power(budget_util)

		for(var/obj/item/mcu_module/M in __pci_devices)
			if(QDELETED(M))
				continue

			P += M.power_usage

		// Convert W to Wh: energy = power * time
		// Wh = W * (seconds / 3600)
		energy_Wh = P * delta_s / 3600
		
		if(__try_drain_power(energy_Wh, TRUE) == FALSE)
			emergency_shutdown(FALSE)
			// MCU is now off, but we still process thermal below

	var/datum/gas_mixture/M = return_air()

	if(M)
		// Newton's law of cooling:
		// dT = (P_gen - k * (T - T_amb)) * dt / C

		// K
		var/T_ambient = M.temperature
		// In vacuum convective cooling is negligible - only radiation remains. W/K
		var/effective_k = cooling_k

		if(__chassis != null)
			var/obj/item/mcu_chassis/C = __chassis.resolve()
			effective_k += C.cooling_bonus

		if(M.get_total_moles() < MCU_VACUUM_MOLES_THRESHOLD)
			effective_k *= MCU_VACUUM_COOLING_FACTOR

		// W
		var/Q_dissipated = effective_k * (temperature - T_ambient)
		// K
		var/delta_T = (P - Q_dissipated) * delta_s / thermal_mass
		temperature = max(T_ambient, temperature + delta_T)

		var/heat_to_env = Q_dissipated * delta_s
		if (heat_to_env > 0 && M.get_total_moles() >= MCU_VACUUM_MOLES_THRESHOLD)
			M.add_thermal_energy(heat_to_env)

	if(temperature >= damage_temp)
		__take_thermal_damage(delta_s)

	__process_radiation(delta_s)

	// Radiation or TID may have shut us down since is_running was last set
	if(rad_dead || !is_on())
		return

	if(!oc_unlocked && temperature >= shutdown_temp)
		var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
		sparks.set_up(3, 1, get_turf(src))
		sparks.start()

		emergency_shutdown(FALSE)

		return

	// Throttling (disabled when OC unlocked)
	if(oc_unlocked)
		throttled = FALSE
	else
		if(!throttled && temperature >= throttle_temp)
			throttled = TRUE
		else if(throttled && temperature < (throttle_temp - MCU_THROTTLE_HYSTERESIS))
			throttled = FALSE

	__update_effective_frequency()

/// Called every tick while temperature ≥ damage_temp.
/// Severity proportional to how far above threshold.
/obj/item/device/mcu/proc/__take_thermal_damage(delta_s)
	var/excess = temperature - damage_temp
	// 0-N scale
	var/severity = excess / 10
	var/corruption_interval = max(5 SECONDS, MCU_MEMORY_CORRUPTION_FREQUENCY / severity)

	THROTTLE(thermal_corruption_cd, corruption_interval)

	if(thermal_corruption_cd)
		if(severity >= 3 && prob(30))
			var/datum/effect/effect/system/spark_spread/sparks = new()
			sparks.set_up(2, 1, get_turf(src))
			sparks.start()

/obj/item/device/mcu/proc/__process_radiation(delta_s)
	if(rad_dead)
		return

	var/list/sources = SSradiation.get_sources_in_range(src)
	if(!length(sources))
		return

	var/total_dose = 0

	for(var/datum/radiation_source/S in sources)
		var/datum/radiation/R = S.travel(src)

		if(!R?.is_ionizing())
			continue

		total_dose += R.calc_equivalent_dose(MCU_RAD_MASS)

	total_dose *= config.mcu.rad_scale

	if(total_dose <= 0)
		return

	var/effective_dose = total_dose * (1.0 - rad_hardening)
	if(effective_dose <= 0)
		return

	// TID accumulation (always, even when powered off)
	accumulated_tid += effective_dose * delta_s

	if(accumulated_tid >= tid_limit)
		__radiation_tid_failure()
		
		return

	// Active effects only when running
	if(!is_on())
		return

	THROTTLE(rad_effect_cd, MCU_RAD_TICK_INTERVAL)
	if(!rad_effect_cd)
		return

	// TID degradation amplifies error rates
	ASSERT(tid_limit != 0)
	var/tid_ratio = accumulated_tid / tid_limit
	var/degrade_mult = 1.0

	if(tid_ratio >= MCU_TID_DEGRADE_RATIO)
		degrade_mult = 2.0
	else if(tid_ratio >= MCU_TID_WARN_RATIO)
		degrade_mult = 1.5

	// SEU - Single Event Upset (memory corruption)
	// var/seu_prob = clamp(effective_dose * MCU_RAD_SEU_COEFF * degrade_mult, 0, 95)

	// if(prob(seu_prob))
	// 	var/ram_len = Z_MACHINE_GET_RAM_SIZE(id)
	// 	var/bytes_to_corrupt = clamp(round(effective_dose * MCU_RAD_SEU_BYTE_COEFF), 1, MCU_RAD_SEU_MAX_BYTES)

	// 	for(var/i in 1 to bytes_to_corrupt)
	// 		var/addr = rand(0, ram_len - 1)
	// 		Z_MACHINE_WRITE_RAM_BYTE(id, addr, rand(0, 255))

	// SEL - Single Event Latchup (overcurrent -> shutdown)
	var/sel_prob = clamp(effective_dose * MCU_RAD_SEL_COEFF * degrade_mult, 0, 30)

	if(prob(sel_prob))
		var/turf/T = get_turf(src)
		var/datum/effect/effect/system/spark_spread/sparks = new()
		sparks.set_up(4, 1, T)
		sparks.start()

		emergency_shutdown(FALSE)

/// Permanent destruction from accumulated Total Ionizing Dose.
/obj/item/device/mcu/proc/__radiation_tid_failure()
	rad_dead = TRUE

	visible_message(SPAN_DANGER("\The [src] emits a faint whine and goes permanently dark - total ionizing dose exceeded!"))

	var/turf/T = get_turf(src)
	if(T)
		var/datum/effect/effect/system/spark_spread/sparks = new
		sparks.set_up(5, 1, T)
		sparks.start()

	if(is_on())
		emergency_shutdown(FALSE)

	name = "burnt-out [initial(name)]"
	desc = "[initial(desc)]\n[SPAN_DANGER("The circuitry is visibly discolored and warped. Irreparable radiation damage.")]"
	// icon_state = "fried" // if you have the sprite

/// Recalculate effective frequency from target + throttle state.
/// Called every tick and after target changes.
/obj/item/device/mcu/proc/__update_effective_frequency()
	if(throttled)
		frequency = round(target_frequency * MCU_THROTTLE_MULT)
	else
		frequency = target_frequency

	frequency = max(frequency, min_frequency)

/obj/item/device/mcu/verb/turn_on()
	set src in view(1)
	set name = "Turn On"
	set category = "Object"

	if(!usr.IsAdvancedToolUser())
		return

	power_on(usr)

/obj/item/device/mcu/verb/turn_off()
	set src in view(1)
	set name = "Turn Off"
	set category = "Object"

	if(!usr.IsAdvancedToolUser())
		return

	power_off(usr, FALSE)

/obj/item/device/mcu/verb/eject_battery()
	set src in view(1)
	set name = "Eject Battery"
	set category = "Object"

	if(!usr.IsAdvancedToolUser())
		return

	remove_battery(usr)

/obj/item/device/mcu/verb/eject_module()
	set src in view(1)
	set name = "Eject Module"
	set category = "Object"

	if(!usr.IsAdvancedToolUser())
		return

	var/list/module_names = list()
	var/counter = 1

	for(var/obj/item/mcu_module/M in __pci_devices)
		module_names["[counter]. [M.name]"] = M
		counter++

	var/choice = input(usr, "Select a PCI module to remove:", "Remove PCI Module") as null|anything in module_names

	if(!choice || !usr.Adjacent(src))
		return

	var/obj/item/mcu_module/selected_module = module_names[choice]
	if(QDELETED(selected_module))
		return

	ASSERT(try_detach_pci_module(selected_module, usr) == TRUE)

/obj/item/device/mcu/proc/try_detach_pci_module_at(slot, mob/activator = null)
	return try_detach_pci_module(__pci_devices[slot], activator)

/obj/item/device/mcu/proc/try_detach_pci_module(obj/item/mcu_module/M, mob/activator = null)
	if(QDELETED(M) || M.__pci_slot == null)
		return FALSE

	__pci_devices[M.__pci_slot] = null
	M.__pci_slot = null
	M.__host = null
	M.__reset(FALSE)

	if(activator)
		if(!activator.put_in_hands(M))
			M.forceMove(get_turf(src))

		activator.visible_message(
			"[activator] removes \the [M] from \the [src].",
			SPAN_NOTICE("You remove \the [M] from \the [src].")
		)
	else
		M.forceMove(get_turf(src))

	return TRUE

/obj/item/device/mcu/proc/__print_function()
	if(length(args) == 0)
		return Z_SCRIPT_FUNCTION_OK

	__messages += list(jointext(args, " "))

	if(length(__messages) > MCU_MAX_MESSAGES)
		__messages.Cut(1, 2)

	tgui_update()

	return Z_SCRIPT_FUNCTION_OK

/obj/item/device/mcu/proc/__printf_function()
	var/msg = args[1]
	var/result = ""
	var/arg_idx = 2
	var/i = 1
	var/msg_len = length_char(msg)

	while(i <= msg_len)
		var/char = copytext_char(msg, i, i + 1)

		if(char == "\\")
			if(i < msg_len)
				var/next_char = copytext_char(msg, i + 1, i + 2)
				if(next_char == "{" || next_char == "}" || next_char == "\\")
					result += next_char
					i += 2

					continue
			
			result += "\\"
			i++

			continue

		if(char == "{" && i < msg_len && copytext_char(msg, i + 1, i + 2) == "}")
			if(arg_idx > length(args))
				return Z_SCRIPT_FUNCTION_ERROR
			
			result += "[args[arg_idx]]"
			arg_idx++
			i += 2

			continue

		result += char
		i++

	__messages += list(result)

	if(length(__messages) > MCU_MAX_MESSAGES)
		__messages.Cut(1, 2)

	tgui_update()

	return Z_SCRIPT_FUNCTION_OK

/obj/item/device/mcu/proc/__var_function()
	for(var/V in args)
		__script.set_var(V, null, Z_SCRIPT_VAR_CAST_NONE)

	return Z_SCRIPT_FUNCTION_OK

/obj/item/device/mcu/proc/__wait_function()
	var/time_ms = max(0, args[1])
	__wait_ds = round(time_ms * 1e-2)

	return Z_SCRIPT_FUNCTION_YIELD

/obj/item/device/mcu/proc/__rand_int_function()
	var/lower = args[1] || 0
	var/upper = args[2] || 2

	__script.set_var(args[3], rand(lower, upper - 1), Z_SCRIPT_VAR_CAST_INT)

	return Z_SCRIPT_FUNCTION_OK

/obj/item/device/mcu/proc/__rand_float_function()
	var/lower = args[1] || 0
	var/upper = args[2] || 1
	var/factor = rand(0, 99999) / 100000

	__script.set_var(args[3], lower + factor * (upper - lower), Z_SCRIPT_VAR_CAST_NONE)

	return Z_SCRIPT_FUNCTION_OK

/obj/item/device/mcu/proc/push_callstack(yield_after_return = FALSE)
	if(length(__callstack) >= MCU_CALLSTACK_DEPTH)
		return FALSE

	__callstack.Add(list(list(
		__script.get_ip(),
		yield_after_return,
	)))

	return TRUE

/obj/item/device/mcu/proc/__call_function()
	if(push_callstack())
		return Z_SCRIPT_FUNCTION_OK

	__script.set_ip(args[1])

	return Z_SCRIPT_FUNCTION_ERROR

/obj/item/device/mcu/proc/__return_function()
	if(length(__callstack) == 0)
		return Z_SCRIPT_FUNCTION_ERROR

	var/len = length(__callstack)
	var/list/stack = __callstack[len]
	var/ip = stack[1]
	var/yield_after_return = stack[2]

	__callstack.Cut(len)
	__script.set_ip(ip)

	if(yield_after_return)
		return Z_SCRIPT_FUNCTION_YIELD

	return Z_SCRIPT_FUNCTION_OK

/obj/item/device/mcu/proc/__get_temperature_function()
	__script.set_var(args[1], CONV_KELVIN_CELSIUS(temperature), Z_SCRIPT_VAR_CAST_INT)

	return Z_SCRIPT_FUNCTION_OK

/obj/item/device/mcu/proc/__is_overheating_function()
	__script.set_var(args[1], temperature >= shutdown_temp, Z_SCRIPT_VAR_CAST_INT)

	return Z_SCRIPT_FUNCTION_OK

/obj/item/device/mcu/proc/__is_throttled_function()
	__script.set_var(args[1], temperature >= throttle_temp, Z_SCRIPT_VAR_CAST_INT)

	return Z_SCRIPT_FUNCTION_OK

/obj/item/device/mcu/proc/__get_battery_charge_function()
	var/charge = QDELETED(__battery) ? 0 : __battery.charge * 1000
	__script.set_var(args[1], charge, Z_SCRIPT_VAR_CAST_INT)

	return Z_SCRIPT_FUNCTION_OK

/obj/item/device/mcu/proc/__is_external_power_function()
	__script.set_var(args[1], __chassis != null, Z_SCRIPT_VAR_CAST_INT)

	return Z_SCRIPT_FUNCTION_OK

/obj/item/device/mcu/proc/__set_interrupts_function()
	__interrupts_enabled = args[1] != 0

	return Z_SCRIPT_FUNCTION_OK

/obj/item/device/mcu/proc/__pci_get_device_count_function()
	var/pci_devices = 0

	for(var/obj/item/mcu_module/M in __pci_devices)
		if(QDELETED(M))
			continue
		
		pci_devices += 1

	__script.set_var(args[1], pci_devices, Z_SCRIPT_VAR_CAST_INT)

	return Z_SCRIPT_FUNCTION_OK

/obj/item/device/mcu/proc/__pci_wait_ready_function()
	var/obj/item/mcu_module/M = args[1]

	if(!istype(M))
		return Z_SCRIPT_FUNCTION_ERROR

	if(M.ready)
		return Z_SCRIPT_FUNCTION_OK
	
	__wait_module = M
	return Z_SCRIPT_FUNCTION_YIELD

/obj/item/device/mcu/proc/__pci_get_device_function()
	var/idx = args[1] + 1

	if(idx > length(__pci_devices) || QDELETED(__pci_devices[idx]))
		__script.set_var(args[2], null, Z_SCRIPT_VAR_CAST_OBJECT)

		return Z_SCRIPT_FUNCTION_OK

	__script.set_var(args[2], __pci_devices[idx], Z_SCRIPT_VAR_CAST_OBJECT)

	return Z_SCRIPT_FUNCTION_OK

/obj/item/device/mcu/proc/__pci_get_device_type_function()
	var/obj/item/mcu_module/M = args[1]

	#define X(type_path, pci_constant) if(istype(M, type_path)) { __script.set_var(args[2], pci_constant, Z_SCRIPT_VAR_CAST_INT); } else
	MCU_MODULE_LIST
	#undef X
	{
		__script.set_var(args[2], null, Z_SCRIPT_FUNCTION_ERROR)
	}

	return Z_SCRIPT_FUNCTION_OK

/obj/item/device/mcu/proc/__is_ready_function()
	var/obj/item/mcu_module/M = args[1]

	if(!istype(M))
		return Z_SCRIPT_FUNCTION_ERROR

	__script.set_var(args[2], M.ready, Z_SCRIPT_VAR_CAST_INT)

	return Z_SCRIPT_FUNCTION_OK

/obj/item/device/mcu/standard
	name = "NCR-1000 MCU"
	desc = "A reliable general-purpose microcontroller by Nanotrasen Cybernetics. \
		The NCR-1000 offers balanced performance for everyday automation tasks."
	icon_state = "green"

	ram_size = 65536 // 64 KB
	target_frequency = 1000000 // 1 MHz
	frequency = 1000000
	min_frequency = 250000 // 250 kHz
	max_frequency = 2000000 // 2 MHz

	pci_slots = 4

	P_idle = 2 WATT
	K_power = 6
	rad_hardening = 0.0

/obj/item/device/mcu/standard/upgraded
	name = "NCR-2000 MCU"
	desc = "An upgraded variant of the NCR-1000 with doubled memory \
		and improved clock speeds. Popular in industrial automation."
	icon_state = "blue"

	ram_size = 262144 // 256 KB
	target_frequency = 2000000 // 2 MHz default
	frequency = 2000000
	min_frequency = 500000 // 500 kHz
	max_frequency = 4000000 // 4 MHz

	pci_slots = 8

	P_idle = 3 WATT
	K_power = 10
	rad_hardening = 0.0

/obj/item/device/mcu/standard/pro
	name = "NCR-4000 Pro"
	desc = "The professional-grade NCR-4000 features expanded memory \
		and high clock speeds for demanding computational tasks."
	icon_state = "black"

	ram_size = 1048576 // 1 MB
	target_frequency = 4000000 // 4 MHz default
	frequency = 4000000
	min_frequency = 1000000 // 1 MHz
	max_frequency = 8000000 // 8 MHz

	pci_slots = 16

	thermal_mass = 6.0
	P_idle = 5 WATT
	K_power = 12
	cooling_k = 0.12
	rad_hardening = 0.05
	emp_hardening = 1

/obj/item/device/mcu/lowpower
	name = "Whisper-LP8"
	desc = "An ultra-efficient microcontroller designed for long-term \
		deployment in remote sensors and monitoring equipment. \
		Sacrifices raw performance for exceptional battery life."
	icon_state = "white"

	ram_size = 32768 // 32 KB
	target_frequency = 500000 // 500 kHz
	frequency = 500000
	min_frequency = 125000 // 125 kHz
	max_frequency = 1000000 // 1 MHz

	pci_slots = 2

	thermal_mass = 2.0
	P_idle = 0.3 WATT
	K_power = 3
	cooling_k = 0.15
	rad_hardening = 0.10
	emp_hardening = 1

	throttle_temp = 70 CELSIUS
	shutdown_temp = 95 CELSIUS
	damage_temp = 100 CELSIUS

/obj/item/device/mcu/lowpower/plus
	name = "Whisper-LP16"
	desc = "An enhanced low-power MCU with additional memory. \
		Ideal for autonomous systems requiring extended operation \
		without frequent battery replacement."
	icon_state = "cyan"

	ram_size = 65536 // 64 KB
	target_frequency = 750000 // 750 kHz default
	frequency = 750000
	min_frequency = 100000 // 100 kHz
	max_frequency = 1500000 // 1.5 MHz

	pci_slots = 4

	thermal_mass = 2.5
	P_idle = 0.5 WATT
	K_power = 4
	cooling_k = 0.15
	rad_hardening = 0.15
	emp_hardening = 1

/obj/item/device/mcu/lowpower/industrial
	name = "Whisper-LP32i"
	desc = "Industrial-grade low-power MCU with generous memory \
		and hardened components. Designed for harsh environments \
		where reliability trumps performance."
	icon_state = "yellow"

	ram_size = 131072 // 128 KB
	target_frequency = 1000000 // 1 MHz default
	frequency = 1000000
	min_frequency = 250000 // 250 kHz
	max_frequency = 2000000 // 2 MHz

	pci_slots = 6

	thermal_mass = 5.0
	P_idle = 1 WATT
	K_power = 5
	cooling_k = 0.20
	rad_hardening = 0.50
	tid_limit = 250

	throttle_temp = 75 CELSIUS
	shutdown_temp = 100 CELSIUS
	damage_temp = 110 CELSIUS
	emp_hardening = 2

/obj/item/device/mcu/overclock/lite
	name = "Fury-S1 Starter"
	desc = "Entry-level overclocking MCU. A taste of Cybersun performance \
		for those not ready to commit to full thermal chaos."
	icon_state = "red"

	ram_size = 65536 // 64 KB
	target_frequency = 1500000
	frequency = 1500000
	min_frequency = 750000
	max_frequency = 3000000

	pci_slots = 4

	thermal_mass = 6.0
	P_idle = 5 WATT
	K_power = 12
	cooling_k = 0.10
	rad_hardening = 0.0

	throttle_temp = 60 CELSIUS
	shutdown_temp = 85 CELSIUS
	damage_temp = 90 CELSIUS

	oc_unlocked = TRUE
	oc_ram_protection = TRUE

/obj/item/device/mcu/overclock
	name = "Fury-X1"
	desc = "A high-performance MCU from Cybersun Industries, \
		engineered for extreme overclocking. Features unlocked \
		multipliers and reinforced power delivery. \
		Handle with care - thermals can be... aggressive."
	icon_state = "black_red"

	ram_size = 262144 // 256 KB
	target_frequency = 2000000 // 2 MHz
	frequency = 2000000
	min_frequency = 1000000 // 1 MHz
	max_frequency = 4000000 // 4 MHz -> 6 MHz OC

	pci_slots = 8

	thermal_mass = 8.0
	P_idle = 8 WATT
	K_power = 15
	cooling_k = 0.08
	rad_hardening = 0.0

	throttle_temp = 60 CELSIUS
	shutdown_temp = 85 CELSIUS
	damage_temp = 90 CELSIUS

	oc_unlocked = TRUE
	oc_ram_protection = TRUE

/obj/item/device/mcu/overclock/extreme
	name = "Fury-X2 Extreme"
	desc = "The flagship of Cybersun's Fury line. Binned for maximum \
		overclocking potential with exotic cooling solutions in mind. \
		Warning: May void warranty, sanity, and fire suppression systems."
	icon_state = "black_copper"

	ram_size = 1048576 // 1 MB
	target_frequency = 4000000 // 4 MHz default
	frequency = 4000000
	min_frequency = 2000000 // 2 MHz
	max_frequency = 8000000 // 8 MHz -> 12MHz OC

	pci_slots = 16

	thermal_mass = 12.0
	P_idle = 15 WATT
	K_power = 18
	cooling_k = 0.06
	rad_hardening = 0.0

	throttle_temp = 55 CELSIUS
	shutdown_temp = 80 CELSIUS
	damage_temp = 85 CELSIUS

	oc_unlocked = TRUE
	oc_ram_protection = TRUE

/obj/item/device/mcu/flex
	name = "Flex-V1"
	desc = "A versatile MCU featuring an exceptionally wide frequency range. \
		Can scale from near-idle power sipping to respectable performance \
		on demand. Perfect for variable workloads."
	icon_state = "purple"

	ram_size = 65536 // 64 KB
	target_frequency = 1000000 // 1 MHz default
	frequency = 1000000
	min_frequency = 100000 // 100 kHz
	max_frequency = 4000000 // 4 MHz

	pci_slots = 6

	thermal_mass = 5.0
	P_idle = 1 WATT
	K_power = 7
	cooling_k = 0.12
	rad_hardening = 0.05

	throttle_temp = 65 CELSIUS
	shutdown_temp = 90 CELSIUS
	damage_temp = 95 CELSIUS

/obj/item/device/mcu/flex/pro
	name = "Flex-V2 Pro"
	desc = "The enhanced Flex-V2 adds more memory and extends \
		the frequency ceiling while maintaining the signature \
		wide operating range. Ideal for adaptive systems."
	icon_state = "dark_purple"

	ram_size = 262144 // 256 KB
	target_frequency = 2000000 // 2 MHz default
	frequency = 2000000
	min_frequency = 125000 // 125 kHz
	max_frequency = 6000000 // 6 MHz
	rad_hardening = 0.05

	pci_slots = 12

	thermal_mass = 6.0
	P_idle = 2 WATT
	K_power = 11
	cooling_k = 0.14

/obj/item/device/mcu/flex/max
	name = "Flex-V3 Max"
	desc = "The ultimate in frequency flexibility. The V3 Max \
		spans from deep sleep frequencies to high-performance modes, \
		with generous 192KB of RAM for complex applications."
	icon_state = "gradient"

	ram_size = 786432 // 768 KB
	target_frequency = 2000000 // 2 MHz default
	frequency = 2000000
	min_frequency = 62500 // 62.5 kHz
	max_frequency = 8000000 // 8 MHz
	rad_hardening = 0.10
	emp_hardening = 1

	pci_slots = 18

	thermal_mass = 7.0
	P_idle = 3 WATT
	K_power = 11
	cooling_k = 0.15

/obj/item/device/mcu/hardened
	name = "Aegis-H1 Hardened MCU"
	desc = "A radiation-hardened microcontroller designed for \
		extreme environments. Features ECC memory, triple modular \
		redundancy, and silicon-on-insulator fabrication. \
		Slower but virtually indestructible — even near a supermatter."
	icon_state = "warning"

	ram_size = 131072 // 128 KB
	target_frequency = 1000000 // 1 MHz default
	frequency = 1000000
	min_frequency = 500000 // 500 kHz
	max_frequency = 2000000 // 2 MHz

	pci_slots = 4

	thermal_mass = 10.0
	P_idle = 4 WATT
	K_power = 12
	cooling_k = 0.25
	rad_hardening = 0.90
	tid_limit = 1000
	emp_hardening = 4

	throttle_temp = 80 CELSIUS
	shutdown_temp = 110 CELSIUS
	damage_temp = 120 CELSIUS

/obj/item/device/mcu/legacy
	name = "RetroTech Z80-NT"
	desc = "A nostalgic recreation of ancient computing technology \
		using modern fabrication. Beloved by hobbyists and \
		historians alike. Extremely power-efficient but limited."
	icon_state = "brown"

	ram_size = 32768 // 32 KB
	target_frequency = 500000 // 500 kHz default
	frequency = 500000
	min_frequency = 250000 // 250 kHz
	max_frequency = 750000 // 750 kHz

	thermal_mass = 3.0
	P_idle = 0.2 WATT
	K_power = 2
	cooling_k = 0.20
	rad_hardening = 0.0

	pci_slots = 2

	throttle_temp = 70 CELSIUS
	shutdown_temp = 95 CELSIUS
	damage_temp = 100 CELSIUS

#undef MCU_STATE_OFF
#undef MCU_STATE_ON
#undef MCU_MAX_MESSAGES
#undef MCU_GC_COLLECT_INTERVAL
#undef MCU_CALLSTACK_DEPTH
