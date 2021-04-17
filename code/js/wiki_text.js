var status_tag = document.getElementById("status");
window.onerror = function(message, source, lineno, colno, error) {
	if (!status_tag) return false;
	else status_tag.innerHTML += "<br>" + message; // Don't scare players with IE error popups
	return true;
}
// Topic should be specified before invoking this code
if(typeof topic === 'undefined' || !topic) throw new Error("Topic is not specified!");
if(typeof mainPage === 'undefined') var mainPage = "https://wiki.ss13.ru";
var paramsBody = "/api.php?action=parse&page=" + topic + "&redirects=true&prop=wikitext&contentformat=text/x-wiki&disableeditsection=true&disabletoc=true&format=json&formatversion=2";
var body = document.createElement("body");
var body_loading_complete = false;
var title = topic;

var parseBody = function (response) {
	if (response.error) throw new Error(response.error.info ? response.error.info : "Unidentified API Error");
	if (status_tag) status_tag.innerHTML += "<br>Loading content...";
	body.innerHTML = response.parse.wikitext;
	
	title = response.parse.title
	
	// Searching for scpecific {{Ingame}} template and removing everything before it, and itself
	var ingame_index = body.innerHTML.indexOf("{{Ingame");
	if (ingame_index !== -1) {
		body.innerHTML = body.innerHTML.slice(ingame_index);
		var titl = body.innerHTML.match(/\|title=(.+?)[\|\}]/);
		if(titl && titl[1]) title = titl[1];
		ingame_index = body.innerHTML.indexOf("}}");
		body.innerHTML = body.innerHTML.slice(ingame_index + 2);
	}
	else throw new Error("Information is blocked!");
	
	document.title = title;

	// Replace every wiki tag with gibberish
	body.innerHTML = body.innerHTML.replace(/(\[+|\{+)[^\]\}]*(\]+|\}+)/g, "<i>DATA_ERROR</i>"); // Regex is better gibberish than actual gibberish
	
	body_loading_complete = true;
};

//  MediaWiki API request to get page's content
var scriptBody = document.createElement("script");
scriptBody.src = mainPage + paramsBody + "&callback=parseBody";
document.body.appendChild(scriptBody);

// Overwrite itself (the whole document)
var scriptOverwrite = document.createElement("script");
var ending = "window.onload = function() {\
	if(!body_loading_complete) throw new Error('Loading failed');\
	if (typeof ref !== 'undefined' && ref.length > 0) window.location = '?src=[0x'+Number(ref).toString(16)+'];title='+title;\
	if(status_tag) status_tag.innerHTML = body.innerHTML;\
	else document.getElementsByTagName(\"body\")[0].innerHTML = body.innerHTML;\
	}"
scriptOverwrite.innerHTML = ending;
document.body.appendChild(scriptOverwrite);
