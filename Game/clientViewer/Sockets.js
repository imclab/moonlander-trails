var ws, 
	wsID, 
	wsConnected = false, 
	players = {},
	connectionRetryTimeout = 1000; 
	


function initWebSocket() { 

	if(WEB_SOCKET_URL!="") { 
		ws = new WebSocket("ws://"+WEB_SOCKET_URL); 
		console.log('Attempting connection '+WEB_SOCKET_URL); 
		
		
		ws.onopen = function(e) { 

			console.log('Connected to '+WEB_SOCKET_URL); 
			wsConnected = true; 
			
			sendSocket(JSON.stringify({type:'register'}));

		};
		
		// not sure we need this for the normal client... 
		ws.onmessage = function(e) { 
			//console.log(e.data); 
			
			var msg = JSON.parse(e.data); 

			if(msg.type=='connect') { 
				wsID = msg.id;

			} else if(msg.type=='join') {
				// add new player object
			} else if(msg.type=='update') { 
				// update player object
				if(!players[msg.id]) { 
					players[msg.id] = new Player(); 
					players[msg.id].scale =  0.25;
					samples.beep.play();

				}
				var player = players[msg.id]; 
				player.addUpdate(msg);  
				player.thrusting = (msg.t == 1);

			}  else if(msg.type=='crash') {
					console.log(e.data); 
				var player = players[msg.id]; 
				if(player) player.crash(); 

				//stopDrawing(msg.id);  

			}  else if(msg.type=='land') {
				// add new player object
					console.log(e.data); 
				var player = players[msg.id]; 
				if(player) player.land(); 

			//	stopDrawing(msg.id);  

			} else if(msg.type=='restart') {
				console.log(e.data); 

				
				var player = players[msg.id]; 
				if(player) player.reset(); 


				//startDrawing(msg.id); 


			} else if(msg.type=='over') { 
				
				console.log(e.data); 
				
			} else if(msg.type=='leave') { 
			// delete player object
				//stopDrawing(msg.id); 
				
				if(players[msg.id]) {
					//delete players[msg.id]; 
					players[msg.id].current = false;
				}
				console.log(e.data); 
			} else if(msg.type=='location') {
				console.log(e.data); 
				if(players[msg.id]) {
					//delete players[msg.id]; 
					var p = players[msg.id]
					p.lat = msg.lat; 
					p.long = msg.long; 
					p.city = msg.city; 
					p.country = msg.country;
				}
			}

		};
		ws.onclose = function(e) { 
			wsConnected = false; 
			console.log("disconnected from "+WEB_SOCKET_URL); 
			if(connectionRetryTimeout) { 
				setTimeout(initWebSocket,connectionRetryTimeout);  
			}
		};
	}


}

function sendSocket(msg) { 
	if(wsConnected ) 
		ws.send(msg); 

}
