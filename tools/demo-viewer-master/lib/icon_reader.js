'use strict';
let StreamPng = require('streampng');
let zlib = require('zlib');

const dirOrder = [2, 1, 4, 8, 6, 10, 5, 9];

module.exports = async function read_icon(url) {
	let response = await fetch(url);
	let data = await response.arrayBuffer();
	let blob = new Blob([data], {type:'image/png'});
	let image = document.createElement("img");
	image.src = URL.createObjectURL(blob);

	const obj = {image, icon_states: new Map(), icon_states_movement: new Map()};
	let png = new StreamPng(new Buffer(data));
	let [IHDR, zTXt] = await new Promise((resolve, reject) => {
		png.on('error', (err) => {
			reject(err);
		});
		let IHDR;
		let zTXt;
		png.on('IHDR', (chunk) => {
			IHDR = chunk;
			if(zTXt) {
				resolve([IHDR,zTXt]);
			}
		});
		png.on('zTXt', (chunk) => {
			zTXt = chunk;
			if(IHDR) {
				resolve([IHDR,zTXt]);
			}
		});
	});
	let inflated = await new Promise((resolve, reject) => {
		zlib.inflate(zTXt.compressedText, (err, data) => {
			if(err) reject(err);
			resolve(data);
		});
	});
	let desc = inflated.toString('ascii');
	let split = desc.split('\n');
	let iconWidth = 0;
	let iconHeight = 0;
	let parsedItems = [];
	let parsing = null;
	let totalFrames = 0;
	for(let i = 0; i < split.length; i++) {
		let regexResult = /\t?([a-zA-Z0-9]+) ?= ?"?([^\r\n"]+)/.exec(split[i]);
		if(!regexResult)
			continue;
		let key = regexResult[1];
		let val = regexResult[2];
		if(key == 'width') {
			iconWidth = +val;
		} else if(key == 'height') {
			iconHeight = +val;
		} else if(key == 'state') {
			if(parsing) {
				parsedItems.push(parsing);
			}
			parsing = {'state':val};
		} else if(key == 'dirs' || key == 'frames' || key == 'movement') {
			parsing[key] = +val;
		} else if(key == 'delay') {
			parsing.delay = JSON.parse('[' + val + ']');
		}
	}
	if(parsing) {
		parsedItems.push(parsing);
	}
	for(let i = 0; i < parsedItems.length; i++) {
		let item = parsedItems[i];
		totalFrames += item.frames * item.dirs;
		if(!item.delay) {
			item.delay = [1];
		}
		if(!item.frames) {
			item.frames = 1;
		}
		if(!item.dirs) {
			item.dirs = 1;
		}
	}
	if(!iconWidth && !iconHeight && totalFrames) {
		iconHeight = IHDR.height;
		iconWidth = IHDR.width / totalFrames;
	}
	let cols = IHDR.width / iconWidth;
	let iconIndex = 0;
	for(let i = 0; i < parsedItems.length; i++) {
		let item = parsedItems[i];
		let outItem = {};
		let name = item.state;
		outItem.dir_count = item.dirs;
		outItem.width = iconWidth;
		outItem.height = iconHeight;
		let dirs = new Map();
		for(let j = 0; j < item.dirs; j++) {
			let dir = {};
			let frames = [];
			dir.frames = frames;
			let total_delay = 0;
			for(let k = 0; k < item.frames; k++) {
				let thisIconIndex = iconIndex + (k * item.dirs) + j;
				frames.push({x:(thisIconIndex%cols)*iconWidth, y:Math.floor(thisIconIndex/cols)*iconHeight, delay: item.delay[k]});
				total_delay += item.delay[k];
			}
			dir.total_delay = total_delay;
			dirs.set(dirOrder[j], dir);
		}
		outItem.dirs = dirs;
		outItem.tile_size = 32;
		if(item.movement) {
			obj.icon_states_movement.set(name, outItem);
		} else {
			obj.icon_states.set(name, outItem);
		}
		iconIndex += item.dirs * item.frames;
	}
	return obj;
}
