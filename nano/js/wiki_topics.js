var titles = [];
var parseCat = function (response) {
	if (response.error) throw new Error(response.error.info ? response.error.info : "Unidentified API Error");
	titles = titles.concat(response.query.categorymembers);
};