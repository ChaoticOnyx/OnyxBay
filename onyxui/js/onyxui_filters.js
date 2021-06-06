// Round a number to the nearest integer
Sqrl.filters.define('round', function(number) {
	return Math.round(number);
});

// Returns the number fixed to 1 decimal
Sqrl.filters.define('fixed', function(number) {
	return Math.round(number * 10) / 10;
});

// Round a number down to integer
Sqrl.filters.define('floor', function(number) {
	return Math.floor(number);
});

// Round a number up to integer
Sqrl.filters.define('ceil', function(number) {
	return Math.ceil(number);
});

// Format a string (~string("Hello {0}, how are {1}?", 'Martin', 'you') becomes "Hello Martin, how are you?")
Sqrl.filters.define('string', function(arguments) {
	if (arguments.length == 0)
	{
		return '';
	}
	else if (arguments.length == 1)
	{
		return arguments[0];
	}
	else if (arguments.length > 1)
	{
		stringArgs = [];
		for (var i = 1; i < arguments.length; i++)
		{
			stringArgs.push(arguments[i]);
		}
		return arguments[0].format(stringArgs);
	}

	return '';
});

// From http://stackoverflow.com/questions/2901102/how-to-print-a-number-with-commas-as-thousands-separators-in-javascript
Sqrl.filters.define('formatNumber', function(x) {
	var parts = x.toString().split(".");
	parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
	return parts.join(".");
});

// Capitalize the first letter of a string. From http://stackoverflow.com/questions/1026069/capitalize-the-first-letter-of-string-in-javascript
Sqrl.filters.define('capitalize', function(string) {
	return string.charAt(0).toUpperCase() + string.slice(1);
});

Sqrl.filters.define('stringify', function(jsonObject) {
	return JSON.stringify(jsonObject);
});
