var ws, 
	wsID, 
	wsConnected = false, 
	players = {},
	connectionRetryTimeout = 1000, 
	lastMessageTime = Date.now(); 
	
function checkWebSockets() { 
	if((wsConnected) && (Date.now()-lastMessageTime>30000)) { 
		ws.close(); 
	}
	
	
}

function initWebSocket() { 

	if(WEB_SOCKET_URL!="") { 
		ws = new WebSocket("ws://"+WEB_SOCKET_URL); 
		console.log('Attempting connection '+WEB_SOCKET_URL); 
		
		
		ws.onopen = function(e) { 

			console.log('Connected to '+WEB_SOCKET_URL); 
			wsConnected = true; 
			
			sendSocket(JSON.stringify({type:'register'}));
			lastMessageTime = Date.now(); 

		};
		
		// not sure we need this for the normal client... 
		ws.onmessage = function(e) { 
			//console.log(e.data); 
			lastMessageTime = Date.now();
			var msg = JSON.parse(e.data); 

			if(msg.type=='connect') { 
				wsID = msg.id;

			} else if(msg.id){
			 
				if(!players[msg.id]) { 
					players[msg.id] = new Player(); 
					players[msg.id].scale =  0.27;
					players[msg.id].current = false;
				

				}
		
				var player = players[msg.id]; 
				if(player) { 
					
					if(msg.type=='location') {
						player.lat = msg.lat; 
						player.lon = msg.lon; 
						player.city = msg.city; 
						player.country = msg.country;
						console.log('location : ', player.city, player.country);
						
					} else { 
						if(player.updates.length==0)
							samples.beep.play();
						
						player.addUpdate(msg);
					}
				}
			}

// if(msg.type=='crash') {
// else if(msg.type=='land') {
// else if(msg.type=='restart') {
// else if(msg.type=='over') { 
// else if(msg.type=='leave') { 

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
