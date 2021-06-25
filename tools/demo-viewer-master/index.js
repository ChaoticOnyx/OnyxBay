'use strict';
const Demo = require('./lib/loader.js');
const DemoPlayer = require('./lib/player.js');
document.addEventListener("DOMContentLoaded", async function() {
	let url = null;
	let querystring = new URLSearchParams(window.location.search);
	let status_holder = document.createElement("h1");
	if(querystring.has("demo_url")) {
		url = querystring.get("demo_url");
	} else if(querystring.has("roundid")) {
		url = window.demo_url_template.replace(/\{roundid}/g, querystring.get("roundid"));
	}
	if(url) {
		document.body.appendChild(status_holder);
		status_holder.textContent = "Fetching demo file...";
		try {
			let response = await fetch(url, {credentials: +querystring.get('send_credentials') ? 'include' : 'same-origin'});
			if(response.status != 200) {
				status_holder.textContent = "Error when fetching: " + response.status + " " + response.statusText;
			} else {
				await run_demo(response, status_holder);
			}
		} catch(e) {
			status_holder.textContent = `${e}`;
		}
	} else {
		let running = false;
		let fileselect = document.createElement("input");
		fileselect.type = "file";
		let button = document.createElement("input");
		button.type = "button";
		button.value = "Open demo from file";
		button.addEventListener("click", () => {
			if(!fileselect.files[0]) return;
			if(running) return;
			document.body.appendChild(status_holder);
			run_demo(fileselect.files[0], status_holder).catch(e => {
				status_holder.textContent = `${e}`;
			});
		});
		document.body.appendChild(fileselect);
		document.body.appendChild(button);
	}
});

let css_paths = [
	"code/modules/goonchat/browserassets/css/browserOutput.css",
	"tgui/packages/tgui-panel/styles/goon/chat-dark.scss",
]

async function run_demo(source, status_holder) {
	status_holder.textContent = "Parsing demo file...";
	let demo = new Demo(source);
	console.log(demo);
	await demo.initialized_promise;
	/*let turfs = new Map();
	let icons = new Map();
	let icon_promises = [];
	let completed = 0;
	for(let icon of demo.icons_used) {
		icon_promises.push((async () => {
			let url = "https://cdn.jsdelivr.net/gh/" + window.repository + "@" + demo.commit + "/" + icon;
			console.log(url);
			try {
				let icon_obj = await read_icon(url);
				icons.set(icon, icon_obj);
			} catch(e) {
				console.error(e);
			} finally {
				completed++;
				status_holder.textContent = "Downloading icons..." + (completed * 100 / demo.icons_used.length).toFixed(1) + "%";
			}
		})());
	}
	await Promise.all(icon_promises);*/
	window.demo_player = new DemoPlayer(demo, demo.loaded_icons);

	let chat_css = "";
	for(let path of css_paths) {
		try {
			let res = await fetch("https://cdn.jsdelivr.net/gh/" + window.repository + "@" + demo.commit + "/" + path);
			if(res.status == 200) {
				chat_css = await res.text();
			}
		} catch(e) {
			console.error(e);
		}
		
	}
	chat_css = chat_css.replace(/((?:^|[},])[^\@\{]*?)([a-zA-Z.#\[\]":=\-_][a-zA-Z0-9.# \[\]":=\-_]*)(?=.+\{)/g, "$1.chat_window $2");
	chat_css = chat_css.replace(/height: [^;]+%;/g, "");
	chat_css = chat_css.replace(/ ?html| ?body/g, "");
	let style = document.createElement("style");
	style.innerHTML = chat_css;
	document.head.appendChild(style);
	//console.log(icons);
}
