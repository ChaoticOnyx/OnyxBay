'use strict';

module.exports = function stoplag() {
	return new Promise((resolve, reject) => {
		setTimeout(100, resolve);
	});
}
