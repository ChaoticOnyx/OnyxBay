var status_tag = document.getElementById("status");
window.onerror = function(message, source, lineno, colno, error) {
	if (!status_tag) return false;
	else status_tag.innerHTML += "<br>" + message; // Don't scare players with IE error popups
	return true;
}
// Topic should be specified before invoking this code
if(typeof topic === 'undefined' || !topic) throw new Error("Topic is not specified!");
if(typeof mainPage === 'undefined') var mainPage = "https://wiki.ss13.ru";
if(typeof censorship === 'undefined') var censorship = 0;
var paramsHead = "/api.php?action=parse&page=" + topic + "&redirects=true&prop=headhtml&contentformat=text/plain&format=json"; // Alternative "useskin" is "minerva" (big font, no decor)
var paramsBody = "/api.php?action=parse&page=" + topic + "&redirects=true&prop=text&contentformat=text/plain&disableeditsection=true&format=json"; // Alternative "useskin" is "minerva" (big font, no decor)
var html = document.createElement("html");
var body = document.createElement("body");
var head_loading_complete = false;
var body_loading_complete = false;
var title = topic;

var parseHead = function (response) {
	if (response.error) throw new Error(response.error.info ? response.error.info : "Unidentified API Error");
	if (status_tag) status_tag.innerHTML += "<br>Loading topic decor...";
	html.innerHTML = response.parse.headhtml["*"];
	title = response.parse.title;
	html.getElementsByTagName("title")[0].innerHTML = title;
	
	// Fixing relative paths for styles
	var links = html.getElementsByTagName("link");
	for (var i=0;i<links.length;i++) links[i].href = mainPage + links[i].getAttribute("href");
	
	head_loading_complete = true;
};

var parseBody = function (response) {
	if (response.error) throw new Error(response.error.info ? response.error.info : "Unidentified API Error");
	if (status_tag) status_tag.innerHTML += "<br>Loading content...";
	body.innerHTML = response.parse.text["*"];
	
	// Searching for scpecific {{Ingame}} template and removing everything BEFORE it, and itself
	var ingame = body.querySelector("#allowed_ingame");
	if (ingame) {
		title = ingame.getElementsByTagName("data")[0].innerHTML
		html.getElementsByTagName("title")[0].innerHTML = title;
		var prev = ingame.previousSibling;
		while(prev) {
			ingame.parentElement.removeChild(prev);
			prev = ingame.previousSibling;
		}
		ingame.parentElement.removeChild(ingame);
	}
	else throw new Error("Information is blocked!");
	
	// Searching for scpecific {{NT_Censorship}} template and removing everything INSIDE it
	if (censorship !== 0) {
		var forbidden = body.getElementsByClassName("NT_Censorship");
		for (var i=0;i<forbidden.length;i++) forbidden[i].innerHTML = "<div style='text-align: center; font-size: 121%; margin-top: 10px'><i>*вырезано*</i></div>"; //forbidden[i].parentElement.removeChild(forbidden[i]);
	}

	// Deactivate all links (except the table of contents)
	var i = 0;
	var lnk = body.getElementsByTagName("a")[i];
	while(lnk) {
		if(lnk.getElementsByClassName("toctext").length == 0)
			lnk.outerHTML = lnk.innerHTML;
		else
			i++;
		lnk = body.getElementsByTagName("a")[i];
	}
	
	// Fixing relative paths for images
	var images = body.getElementsByTagName("img");
	for (var i=0;i<images.length;i++) images[i].src = mainPage + images[i].getAttribute("src");
	
	// Cutting footer (if any)
	var guidemenu = body.querySelector("#guidemenu");
	if (guidemenu) guidemenu.parentElement.removeChild(guidemenu);
	var jobmenu = body.querySelector("#jobmenu");
	if (jobmenu) jobmenu.parentElement.removeChild(jobmenu);
	var racemenu = body.querySelector("#racemenu");
	if (racemenu) racemenu.parentElement.removeChild(racemenu);
	
	html.getElementsByTagName("body")[0].innerHTML = body.innerHTML;
	body_loading_complete = true;
};

//  MediaWiki API request to get page's html head
var scriptHead = document.createElement("script");
scriptHead.src = mainPage + paramsHead + "&callback=parseHead";
document.body.appendChild(scriptHead);

//  MediaWiki API request to get page's content
var scriptBody = document.createElement("script");
scriptBody.src = mainPage + paramsBody + "&callback=parseBody";
document.body.appendChild(scriptBody);

// Overwrite itself (the whole document)
var scriptOverwrite = document.createElement("script");
var ending = "window.onload = function() {\
	if(!head_loading_complete || !body_loading_complete) throw new Error('Loading failed');\
	if (typeof ref !== 'undefined' && ref.length > 0) window.location = '?src=[0x'+Number(ref).toString(16)+'];title='+title;\
	document.getElementsByTagName(\"html\")[0].innerHTML = html.innerHTML;\
	}"
scriptOverwrite.innerHTML = ending;
document.body.appendChild(scriptOverwrite);
