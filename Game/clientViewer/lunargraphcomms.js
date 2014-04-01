	var wslocal = null;
	var host = "localhost";
	var port = 8086;
	var socket = "p5websocket";
	//console.log('hello'); 

	function ready(){
		console.log("opening socket : "+"ws://"+host+":"+port+"/"+socket); 
	
		wslocal = new WebSocket("ws://"+host+":"+port+"/"+socket); 
		wslocal.onopen = function(e) { 
		
			console.log('connected to local socket'); 
			wsLocalConnected = true; 
			
			
		
		};
		wslocal.onmessage = function(e) { 
			console.log(e.data); 
			if(e.data.indexOf("sendlandscape")!=-1) { 
				sendLandscape(); 
				
			}
		
		};
		wslocal.onclose = function(e) { 
			wsLocalConnected = false; 
			console.log("disconnected local!"); 
			console.log(e);
			port++; 
			if(port==8090) port = 8081; 
			setTimeout(ready, 100); 
		};
		
		

	}

	window.addEventListener("load", ready, false);

		
function sendLandscape() { 
	for(var i = 0; i<landscape.points.length; i++) { 
		
		wslocal.send("landscape:"+i+","+landscape.points[i].x+","+landscape.points[i].y); 
		
		
		
	}
	wslocal.send("landscapeend"); 
	
	
}
