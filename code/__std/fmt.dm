/// Formats a number to human readable form with the appropriate SI unit.
/// 
/// Supports SI exponents between 1e-15 to 1e15, but properly handles numbers outside that range as well.
/// Examples:
/// * `fmt_siunit(1234, "Pa", 1)` -> `"1.2 kPa"`
/// * `fmt_siunit(0.5345, "A", 0)` -> `"535 mA"`
/// * `fmt_siunit(1000, "Pa", 4)` -> `"1 kPa"`
/// Arguments:
/// * value - The number to convert to text. Can be positive or negative.
/// * unit - The base unit of the number, such as "Pa" or "W".
/// * maxdecimals - Maximum amount of decimals to display for the final number. Defaults to 1.
/proc/fmt_siunit(value, unit, maxdecimals=1)
	var/static/list/prefixes = list("f","p","n","μ","m","","k","M","G","T","P")

	// We don't have prefixes beyond this point
	// and this also captures value = 0 which you can't compute the logarithm for
	// and also byond numbers are floats and doesn't have much precision beyond this point anyway
	if(abs(value) <= 1e-18)
		return "0 [unit]"

	var/exponent = clamp(log(10, abs(value)), -15, 15) // Calculate the exponent and clamp it so we don't go outside the prefix list bounds
	var/divider = 10 ** (round(exponent / 3) * 3) // Rounds the exponent to nearest SI unit and power it back to the full form
	var/coefficient = round(value / divider, 10 ** -maxdecimals) // Calculate the coefficient and round it to desired decimals
	var/prefix_index = round(exponent / 3) + 6 // Calculate the index in the prefixes list for this exponent

	// An edge case which happens if we round 999.9 to 0 decimals for example, which gets rounded to 1000
	// In that case, we manually swap up to the next prefix if there is one available
	if(coefficient >= 1000 && prefix_index < 11)
		coefficient /= 1e3
		prefix_index++

	var/prefix = prefixes[prefix_index]
	return "[coefficient] [prefix][unit]"
