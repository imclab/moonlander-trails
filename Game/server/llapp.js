	var connect = require('connect'), 
	ws = require('websocket.io'), 
	connections = [], 
	lastID = 0; 

//var fs = require('fs'); 	
var app = connect(); 



app.use(connect.static(__dirname+'/public'));
app.listen( 8001); 

console.log(__dirname+'/public'); 
console.log(ws); 

//setInterval(function() { 
//	broadcast(null, "hi!"+connections.length); 
//}, 500); 




function broadcast(from, msg) {
  connections.forEach(function (socket) {
    if (from !== socket) {
      socket.send(msg);
    }
  });
}

ws.attach(app).on('connection', function(sock){
	
	console.log('connected'); ; 
	sock.send(JSON.stringify({type:'connect', id:lastID})); 
	//broadcast(sock, JSON.stringify({type:'join', id: lastID })); 
	sock.id = Date.now(); 
	//sock.stream = fs.createWriteStream("data/"+sock.id+".txt"); 
	//sock.stream.write('{"time":'+Date.now()+', positions : [');
	lastID++; 
	
	for(var i=0; i<connections.length;i++) { 
		sock.send(JSON.stringify({type:'join', id:connections[i].id})); 
	}
	
	connections.push(sock); 
	
	sock.on('message', function(msg) { 
	//	console.log(msg); 
		var data = JSON.parse(msg); 
		if(msg.type = 'update'){
			broadcast(sock, msg);
			//sock.stream.write(data.x+','+data.y+','+data.a+','); 
		}
		
		
		
		
		
	}).on('close', function() { 
		// now clean up 
		broadcast(sock, JSON.stringify({type:"leave", id: sock.id}));
	  	var i = connections.indexOf(sock);
		console.log('disconnected'); 
	    // remove the cached connection
	    if (i !== -1) {
	      connections.splice(i, 1);
		//sock.stream.write(']}');
	    	//sock.stream.end(); 
		}
	}); 
}); 
