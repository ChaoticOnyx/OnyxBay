/**
 * Defines for FTL jumping.
 * Returned from '/obj/machinery/ftl_shunt/core/initiate_jump()'.
 */

/// Not enough fuel
#define FTL_START_FAILURE_FUEL 1
/// Not enough power
#define FTL_START_FAILURE_POWER 2
/// FTL drive broken
#define FTL_START_FAILURE_BROKEN 3
/// FTL drive cooling down
#define FTL_START_FAILURE_COOLDOWN 4
/// Generic failure failure
#define FTL_START_FAILURE_OTHER 5
/// FTL drive initiated succesefully
#define FTL_START_CONFIRMED 6

/**
 * FTL drive flags.
 */

#define FTL_DRIVE_REQUIRES_FUEL      (1<<0)
#define FTL_DRIVE_REQUIRES_CHARGE    (1<<1)
#define FTL_DRIVE_MAKES_ANNOUNCEMENT (1<<2)

#define SHUNT_SEVERITY_MINOR 1
#define SHUNT_SEVERITY_MAJOR 2
#define SHUNT_SEVERITY_CRITICAL 3
#define SHUNT_SEVERITY_CATASTROPHIC 4

#define SHUNT_SABOTAGE_MINOR 1
#define SHUNT_SABOTAGE_MAJOR 2
#define SHUNT_SABOTAGE_CRITICAL 3
