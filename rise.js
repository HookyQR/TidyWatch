'use strict';

const j2000 = 2451545.0 - 68.184/86400;
let n = new Date();
n.setHours(0,0,0,0);
n -= 946681200000;
n /= 1000*60*60*24;
console.log(n);
n |= 0;

let long = 174.7762;
let lat  = -41.2866;

let j = n - long/360;


let M = ((357.5291 + 0.98560028 * j) % 360)/180*Math.PI;

let C = 1.9148 * Math.sin(M) +
        0.0200 * Math.sin(2*M) +
        0.0003 * Math.sin(3*M);

// Check out the perihelion
let l = (M + C + Math.PI + 102.9372/180*Math.PI);
console.log("L",l);
let J = 2451545.5 + j + 0.0053 * Math.sin(M) - 0.0069 * Math.sin(2*l);
console.log("J",J,j+2451545.5);

let dec = Math.asin(Math.sin(l) * Math.sin(23.44/180*Math.PI));
console.log(Math.sin(23.44/180*Math.PI));
let ha = Math.acos((Math.sin(-0.83/180*Math.PI) - Math.sin(lat/180*Math.PI)*Math.sin(dec))/Math.cos(lat/180*Math.PI)/Math.cos(dec));

console.log(ha/2/Math.PI);
h /= 2* Math.PI;
h 
let n = new Date();
n.set
