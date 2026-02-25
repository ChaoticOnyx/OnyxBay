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
// 1MB
#define MCU_MAX_ELF_FILE_SIZE 1000000
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

/obj/item/device/mcu
	name = "generic MCU"
	desc = "A microcontroller unit. This one seems to be a prototype."
	icon = 'icons/obj/assemblies/electronic_components.dmi'
	icon_state = "template"
	w_class = ITEM_SIZE_TINY

	var/id = 0
	var/ram_size = 32768 // 32 KB
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

	var/pci_slots = 2

	var/list/__pci_devices = null
	var/obj/item/cell/__battery = null
	var/__elf_path = null

/obj/item/device/mcu/New()
	ASSERT(pci_slots <= Z_MAX_PCI_DEVICES)
	ASSERT(pci_slots >= 0)

	id = Z_MACHINE_CREATE()

	Z_MACHINE_SET_FREQUENCY(id, initial(target_frequency))
	Z_MACHINE_CONNECT(id, src)
	Z_MACHINE_SET_RAM_SIZE(id, ram_size)
	Z_MACHINE_SET_POST_TICK_PROC(id, nameof(.proc/__post_tick))
	Z_MACHINE_SET_TRAP_PROC(id, nameof(.proc/__trap))
	Z_MACHINE_SET_SYSCALL_PROC(id, nameof(.proc/__syscall))

	__pci_devices = new /list(pci_slots)

	..()

/obj/item/device/mcu/Destroy()
	Z_MACHINE_DESTROY(id)

	. = ..()

/obj/item/device/mcu/examine(mob/user, infix)
	. = ..()

	if(user.Adjacent(src))
		if(rad_dead)
			. += SPAN_DANGER("The circuitry is burnt out from radiation. It will never function again.")

			ASSERT(tid_limit != 0)
			var/tid_ratio = accumulated_tid / tid_limit
			if(tid_ratio >= MCU_TID_DEGRADE_RATIO)
				. += SPAN_WARNING("The board shows significant brown discoloration from radiation exposure.")
			else if(tid_ratio >= MCU_TID_WARN_RATIO)
				. += SPAN_WARNING("You notice slight discoloration on the board - possibly radiation.")

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

	if(Z_MACHINE_GET_STATE(id) == Z_MSTATE_RUNNING)
		if(throttled)
			. += "A small LED blinks [SPAN_WARNING("orange")]."
		else
			. += "A small LED glows [SPAN_NOTICE("green")]."
	else
		if(temperature >= (shutdown_temp - MCU_RESTART_COOLDOWN))
			. += "A small LED blinks [SPAN_DANGER("red")]. It needs to cool down."
		else
			. += "A small LED is off."

/obj/item/device/mcu/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/jtag_programmer))
		if(flash_protection)
			to_chat(user, SPAN_WARNING("The OTP fuse is burned. \The [src] cannot be reprogrammed."))
			return ..()

		var/elf_file = input(user, "Upload an ELF file", "JTAG Programmer") as file|null

		if(QDELETED(src) || !elf_file || QDELETED(user) || !user.Adjacent(src))
			return ..()

		if(length(elf_file) > MCU_MAX_ELF_FILE_SIZE)
			to_chat(user, SPAN_WARNING("The file's size is too big [length(elf_file)] ([MCU_MAX_ELF_FILE_SIZE] max)"))
			return ..()

		var/tmp_file = "data/z/elf/[rand(9999999)].elf"

		while(fexists(tmp_file))
			tmp_file = "data/z/elf/[rand(9999999)].elf"

		fcopy(elf_file, tmp_file)

		if(!Z_MACHINE_LOAD_ELF(id, tmp_file))
			switch(Z_GET_LAST_ERROR())
				if(Z_ERROR_OUT_OF_RAM)
					to_chat(user, "Failed to load the ELF file: does not fit into the RAM")
				if(Z_ERROR_BAD_ELF)
					to_chat(user, "Failed to load the ELF file: bad or unsupported ELF file")
		else
			to_chat(user, SPAN_NOTICE("ELF file uploaded successfully."))

		if(__elf_path != null)
			fdel(__elf_path)
		
		__elf_path = tmp_file
	else if(isMultitool(W))
		var/upper_bound = oc_unlocked ? round(max_frequency * MCU_MAX_OVERCLOCK_MULT) : max_frequency
		var/new_freq = input(user, "Enter new frequency in Hz between [min_frequency] and [upper_bound]", "Multitool") as num|null

		if(QDELETED(src) || QDELETED(user) || !user.Adjacent(src))
			return ..()

		if(new_freq != null)
			set_target_frequency(new_freq, user)
	else if(isScrewdriver(W))
		set_oc_unlocked(!oc_unlocked, user)
	else if(isWelder(W))
		if(flash_protection)
			to_chat(user, SPAN_WARNING("The OTP fuse is already burned."))
			return ..()
		
		var/obj/item/weldingtool/WT = W
		var/confirm = alert(user, "Burn the write-protect OTP fuse? This is PERMANENT and will prevent any future reprogramming.", "Burn OTP Fuse", "Yes", "No")

		if(confirm != "Yes")
			return ..()

		if(!WT.use_tool(src, user, delay = 1 SECOND, amount = 1))
			return ..()

		if(QDELETED(src) || QDELETED(user) || !user.Adjacent(src))
			return
		
		flash_protection = TRUE
		user.visible_message( \
			SPAN_NOTICE("[user] carefully burns the OTP fuse on \the [src]."), \
			SPAN_NOTICE("You burn the OTP fuse. The firmware is now permanently locked.") \
		)
	else if(istype(W, /obj/item/cell))
		if(!QDELETED(__battery))
			to_chat(user, SPAN_WARNING("There is a battery already"))
			return ..()
		
		if(!user.drop(W, src))
			return ..()

		__battery = W
		user.visible_message(\
			"[user] inserts \the [W] into \the [src].", \
			"You insert \the [W] into \the [src]." \
		)
	else if(istype(W, /obj/item/mcu_module))
		var/obj/item/mcu_module/M = W
		
		try_add_pci(M, user)

	return ..()

/obj/item/device/mcu/proc/try_add_pci(obj/item/mcu_module/M, mob/activator = null)
	ASSERT(M.device_type > 0)
	ASSERT(M.__pci_slot == null)
	ASSERT(M.__host == null)

	var/has_slots = FALSE
	for(var/i = 1 to pci_slots)
		if(__pci_devices[i + 1] == null)
			has_slots = TRUE
			break

	if(!has_slots)
		if(activator)
			to_chat(activator, SPAN_WARNING("No more PCI slots available."))
		
		return FALSE

	var/slot = Z_MACHINE_TRY_ATTACH_PCI(id, M.device_type)

	if(slot == null)
		if(activator)
			to_chat(activator, SPAN_WARNING("It looks like [M] won't work here."))
		
		return FALSE
	
	if(activator && !activator.drop(M, src))
		return FALSE
	else
		M.forceMove(src)

	M.__pci_slot = slot
	M.__host = weakref(src)
	ASSERT(__pci_devices[slot + 1] == null)
	__pci_devices[slot + 1] = M

	M.__reset(TRUE)

	if(activator)
		activator.visible_message(
			"[activator] inserts \the [M] to \the [src]", \
			SPAN_NOTICE("You insert \the [M] to \the [src].") \
		)

	return TRUE

/obj/item/device/mcu/proc/__trap()
	emergency_shutdown()

/obj/item/device/mcu/proc/__syscall(pci_slot, ...)
	ASSERT(pci_slot <= pci_slots)

	var/obj/item/mcu_module/M = __pci_devices[pci_slot + 1]
	return M.__syscall(arglist(args.Copy(2)))

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
	if(id == 0)
		return 0

	if(Z_MACHINE_GET_STATE(id) != Z_MSTATE_RUNNING)
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

	if(!config.game.mcu_enable || SSmcu.total_running >= config.game.mcu_hardcap)
		if(activator)
			to_chat(activator, SPAN_WARNING("Some indescribable force is preventing the board from starting."))
		
		return FALSE

	if(rad_dead)
		if(activator)
			to_chat(activator, SPAN_WARNING("\The [src] is unresponsive - the circuitry is dead."))

		return FALSE

	if(temperature >= (shutdown_temp - MCU_RESTART_COOLDOWN))
		if(activator)
			to_chat(activator, SPAN_WARNING("\The [src] is too hot to restart!"))

		return FALSE

	if(Z_MACHINE_GET_STATE(id) == Z_MSTATE_RUNNING)
		if(activator)
			to_chat(activator, SPAN_WARNING("\The [src] is already powered on!"))

		return FALSE

	if(QDELETED(__battery))
		__battery = null
		
		if(activator)
			to_chat(activator, SPAN_WARNING("\The [src] has no battery to power!"))
		
		return FALSE
	
	if(__elf_path == null)
		if(activator)
			to_chat(activator, SPAN_WARNING("\The [src] fails to start."))
		
		return FALSE

	// Wh
	var/min_boot_charge = P_idle / 3600
	if(!__battery.check_charge(min_boot_charge))
		if(activator)
			to_chat(activator, SPAN_WARNING("\The [src]'s battery is too low to start."))

		return FALSE

	ASSERT(Z_MACHINE_RESET(id) == TRUE)
	ASSERT(Z_MACHINE_LOAD_ELF(id, __elf_path) == TRUE)
	Z_MACHINE_SET_STATE(id, Z_MSTATE_RUNNING)
	Z_MACHINE_SET_SENSORS(id, CONV_KELVIN_CELSIUS(temperature), 0, temperature >= shutdown_temp, temperature >= throttle_temp)
	SSmcu.total_running += 1

	if(activator)
		activator.visible_message("[activator] turns \the [src] on.", "You turn \the [src] on.")

	return TRUE

/obj/item/device/mcu/proc/power_off(mob/activator = null)
	throttled = FALSE
	sustained_full_ticks = 0

	if(Z_MACHINE_GET_STATE(id) == Z_MSTATE_STOPPED)
		if(activator)
			to_chat(activator, SPAN_WARNING("The CPU is not turned on."))

		return
	
	if(activator)
		activator.visible_message("[activator] turns \the [src] off.", "You turn \the [src] off.")

	Z_MACHINE_SET_STATE(id, Z_MSTATE_STOPPED)
	SSmcu.total_running -= 1

/obj/item/device/mcu/proc/emergency_shutdown()
	throttled = FALSE
	sustained_full_ticks = 0

	if(Z_MACHINE_GET_STATE(id) != Z_MSTATE_RUNNING)
		return

	visible_message(SPAN_WARNING("[src] shuts down!"))
	power_off()

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
	emergency_shutdown()

	return TRUE

/obj/item/device/mcu/proc/__post_tick(delta_us)
	var/delta_s = delta_us * 1e-6

	// Generated heat
	var/P = 0 WATT
	var/is_running = Z_MACHINE_GET_STATE(id) == Z_MSTATE_RUNNING
	var/energy_Wh = 0

	if(is_running)
		if(QDELETED(__battery))
			__battery = null
			emergency_shutdown()
			is_running = FALSE
			// Continue to thermal calculations - residual heat still dissipates
		else
			var/util = Z_MACHINE_GET_UTILIZATION(id)

			// Sustained full-load tracking
			if(util >= 0.95)
				sustained_full_ticks++
			else
				sustained_full_ticks = max(0, sustained_full_ticks - 2)

			P = calculate_power(util)

			// Convert W to Wh: energy = power * time
			// Wh = W * (seconds / 3600)
			energy_Wh = P * delta_s / 3600
			__battery.use(energy_Wh * config.game.mcu_power_scale)

			if(__battery.charge <= 0)
				emergency_shutdown()
				is_running = FALSE
				// MCU is now off, but we still process thermal below

	var/turf/T = get_turf(src)
	var/datum/gas_mixture/M = T?.return_air()

	if(!T || !M)
		return

	// Newton's law of cooling:
	// dT = (P_gen - k * (T - T_amb)) * dt / C

	// K
	var/T_ambient = M.temperature
	// In vacuum convective cooling is negligible - only radiation remains. W/K
	var/effective_k = cooling_k

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

	if(!is_running)
		return

	// Radiation or TID may have shut us down since is_running was last set
	if(rad_dead || Z_MACHINE_GET_STATE(id) != Z_MSTATE_RUNNING)
		return

	if(!oc_unlocked && temperature >= shutdown_temp)
		var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
		sparks.set_up(3, 1, T)
		sparks.start()

		emergency_shutdown()

		return

	// Overclock instability (based on TARGET, not effective)
	if(target_frequency > max_frequency)
		var/oc_severity = (target_frequency / max_frequency) - 1

		if(!oc_ram_protection && prob(oc_severity * 100))
			__trigger_overclock_error()

	// Throttling (disabled when OC unlocked)
	if(oc_unlocked)
		throttled = FALSE
	else
		if(!throttled && temperature >= throttle_temp)
			throttled = TRUE
		else if(throttled && temperature < (throttle_temp - MCU_THROTTLE_HYSTERESIS))
			throttled = FALSE

	// Power consumption per minute in mWh (milliwatt-hours per minute)
	// P (watts) * (1/60) hours = Wh per minute * 1000 = mWh per minute
	var/power_per_minute_mWh = round(P * config.game.mcu_power_scale * 1000 / 60)

	Z_MACHINE_SET_SENSORS(id, \
		CONV_KELVIN_CELSIUS(temperature), \
		power_per_minute_mWh, \
		temperature >= shutdown_temp, \
		temperature >= throttle_temp \
	)

	// Apply effective frequency
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
		var/ram_len = Z_MACHINE_GET_RAM_SIZE(id)
		var/bytes_to_corrupt = clamp(round(severity), 1, 8)

		for(var/i in 1 to bytes_to_corrupt)
			var/ram_addr = rand(0, ram_len - 1)
			var/ram_value = rand(0, 255)
			Z_MACHINE_WRITE_RAM_BYTE(id, ram_addr, ram_value)

		if(severity >= 3 && prob(30))
			var/datum/effect/effect/system/spark_spread/sparks = new()
			sparks.set_up(2, 1, get_turf(src))
			sparks.start()

/obj/item/device/mcu/proc/__trigger_overclock_error()
	THROTTLE(mem_corruption_cd, MCU_MEMORY_CORRUPTION_FREQUENCY)

	if(mem_corruption_cd)
		var/ram_len = Z_MACHINE_GET_RAM_SIZE(id)
		var/bytes_to_corrupt = rand(1, 8)

		for(var/i in 1 to bytes_to_corrupt)
			var/ram_addr = rand(0, ram_len - 1)
			var/ram_value = rand(0, 255)
			Z_MACHINE_WRITE_RAM_BYTE(id, ram_addr, ram_value)

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
	if(Z_MACHINE_GET_STATE(id) != Z_MSTATE_RUNNING)
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
	var/seu_prob = clamp(effective_dose * MCU_RAD_SEU_COEFF * degrade_mult, 0, 95)

	if(prob(seu_prob))
		var/ram_len = Z_MACHINE_GET_RAM_SIZE(id)
		var/bytes_to_corrupt = clamp(round(effective_dose * MCU_RAD_SEU_BYTE_COEFF), 1, MCU_RAD_SEU_MAX_BYTES)

		for(var/i in 1 to bytes_to_corrupt)
			var/addr = rand(0, ram_len - 1)
			Z_MACHINE_WRITE_RAM_BYTE(id, addr, rand(0, 255))

	// SEL - Single Event Latchup (overcurrent -> shutdown)
	var/sel_prob = clamp(effective_dose * MCU_RAD_SEL_COEFF * degrade_mult, 0, 30)

	if(prob(sel_prob))
		var/turf/T = get_turf(src)
		var/datum/effect/effect/system/spark_spread/sparks = new()
		sparks.set_up(4, 1, T)
		sparks.start()

		emergency_shutdown()

/// Permanent destruction from accumulated Total Ionizing Dose.
/obj/item/device/mcu/proc/__radiation_tid_failure()
	rad_dead = TRUE

	visible_message(SPAN_DANGER("\The [src] emits a faint whine and goes permanently dark - total ionizing dose exceeded!"))

	var/turf/T = get_turf(src)
	if(T)
		var/datum/effect/effect/system/spark_spread/sparks = new
		sparks.set_up(5, 1, T)
		sparks.start()

	if(Z_MACHINE_GET_STATE(id) == Z_MSTATE_RUNNING)
		emergency_shutdown()

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

	Z_MACHINE_SET_FREQUENCY(id, frequency)

/obj/item/device/mcu/verb/turn_on()
	set name = "Turn On"
	set category = "Object"

	power_on(usr)

/obj/item/device/mcu/verb/turn_off()
	set name = "Turn Off"
	set category = "Object"

	power_off(usr)

/obj/item/device/mcu/verb/eject_battery()
	set name = "Eject Battery"
	set category = "Object"

	remove_battery(usr)

/obj/item/device/mcu/verb/eject_module()
	set name = "Eject Module"
	set category = "Object"

	var/list/module_names = list()
	var/counter = 1

	for(var/obj/item/mcu_module/M in __pci_devices)
		module_names["[counter]. [M.name]"] = M
		counter++
	
	var/choice = input(usr, "Select a PCI module to remove:", "Remove PCI Module") as null|anything in module_names
	
	if(isnull(choice) || !usr.Adjacent(src))
		return
	
	var/obj/item/mcu_module/selected_module = module_names[choice]
	if(QDELETED(selected_module))
		return
	
	ASSERT(__pci_devices[selected_module.__pci_slot + 1] == selected_module)
	__pci_devices[selected_module.__pci_slot + 1] = null

	ASSERT(Z_MACHINE_TRY_DETACH_PCI(id, selected_module.__pci_slot) == TRUE)

	selected_module.__pci_slot = null
	selected_module.__host = null
	selected_module.__reset(FALSE)

	if(!usr.put_in_hands(selected_module))
		selected_module.forceMove(get_turf(src))
	
	usr.visible_message(
		"[usr] removes \the [selected_module] from \the [src].",
		SPAN_NOTICE("You remove \the [selected_module] from \the [src].")
	)

/obj/item/device/mcu/standard
	name = "NCR-1000 MCU"
	desc = "A reliable general-purpose microcontroller by Nanotrasen Cybernetics. \
		The NCR-1000 offers balanced performance for everyday automation tasks."
	
	ram_size = 32768 // 32 KB
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
	
	ram_size = 65536 // 64 KB
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
	
	ram_size = 131072 // 128 KB
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

/obj/item/device/mcu/lowpower
	name = "Whisper-LP8"
	desc = "An ultra-efficient microcontroller designed for long-term \
		deployment in remote sensors and monitoring equipment. \
		Sacrifices raw performance for exceptional battery life."
	
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
	
	throttle_temp = 70 CELSIUS
	shutdown_temp = 95 CELSIUS
	damage_temp = 100 CELSIUS

/obj/item/device/mcu/lowpower/plus
	name = "Whisper-LP16"
	desc = "An enhanced low-power MCU with additional memory. \
		Ideal for autonomous systems requiring extended operation \
		without frequent battery replacement."
	
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

/obj/item/device/mcu/lowpower/industrial
	name = "Whisper-LP32i"
	desc = "Industrial-grade low-power MCU with generous memory \
		and hardened components. Designed for harsh environments \
		where reliability trumps performance."
	
	ram_size = 131072 // 128 KB
	target_frequency = 1000000 // 1 MHz default
	frequency = 1000000
	min_frequency = 250000 // 250 kHz
	max_frequency = 2000000 // 2 MHz
	
	pci_slots = 8

	thermal_mass = 5.0
	P_idle = 1 WATT
	K_power = 5
	cooling_k = 0.20
	rad_hardening = 0.50
	tid_limit = 250
	
	throttle_temp = 75 CELSIUS
	shutdown_temp = 100 CELSIUS
	damage_temp = 110 CELSIUS

/obj/item/device/mcu/overclock
	name = "Fury-X1"
	desc = "A high-performance MCU from Cybersun Industries, \
		engineered for extreme overclocking. Features unlocked \
		multipliers and reinforced power delivery. \
		Handle with care - thermals can be... aggressive."
	
	ram_size = 65536 // 64 KB
	target_frequency = 2000000 // 2 MHz default
	frequency = 2000000
	min_frequency = 1000000 // 1 MHz
	max_frequency = 4000000 // 4 MHz -> 6MHz OC
	
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
	
	ram_size = 131072 // 128 KB
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
	
	ram_size = 49152 // 48 KB
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
	
	ram_size = 98304 // 96 KB
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
	
	ram_size = 196608 // 192 KB
	target_frequency = 2000000 // 2 MHz default
	frequency = 2000000
	min_frequency = 62500 // 62.5 kHz
	max_frequency = 8000000 // 8 MHz
	rad_hardening = 0.10
	
	pci_slots = 24

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
	
	ram_size = 65536 // 64 KB
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
	
	throttle_temp = 80 CELSIUS
	shutdown_temp = 110 CELSIUS
	damage_temp = 120 CELSIUS

/obj/item/device/mcu/legacy
	name = "RetroTech Z80-NT"
	desc = "A nostalgic recreation of ancient computing technology \
		using modern fabrication. Beloved by hobbyists and \
		historians alike. Extremely power-efficient but limited."
	
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
