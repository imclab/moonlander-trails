	var connect = require('connect'), 
	ws = require('websocket.io'), 
	connections = [], 
	lastID = Date.now(); 

var fs = require('fs'); 	
var app = connect(); 



//app.use(connect.static(__dirname+'/public'));
app.listen( 8001); 

//console.log(__dirname+'/public'); 
//console.log(ws); 

//setInterval(function() { 
//	broadcast(null, "hi!"+connections.length); 
//}, 500); 




function broadcast(from, msg) {
  connections.forEach(function (socket) {
    if ((from !== socket) && (socket.viewer)){
      socket.send(msg);
	}
  });
}

ws.attach(app).on('connection', function(sock){
	
	//console.log(sock.req.headers.origin); 
	
	sock.id = Date.now(); 
	while(sock.id<=lastID) sock.id++;
	
	sock.send(JSON.stringify({type:'connect', id:sock.id})); 
	
	console.log('connected', sock.id ); 
	
	broadcast(sock, JSON.stringify({type:'join', id: sock.id })); 
	
	sock.viewer = false; 
	sock.stream = fs.createWriteStream("data/"+sock.id+".txt"); 
	sock.stream.write('{"time":'+Date.now()+', origin:'+sock.req.headers.origin+', positions : [');
	lastID = sock.id; 
	
	//send new client all the other current connections
	//for(var i=0; i<connections.length;i++) { 
	//	sock.send(JSON.stringify({type:'join', id:connections[i].id})); 
	//}
	
	connections.push(sock); 
	
	sock.on('message', function(msg) { 
	//	console.log(msg); 
	
		try{
			var data = JSON.parse(msg); 
		} catch(e) {
			console.log('invalid message : '+e); 
			//var data = {}; 
			return;
		}
		if(data.type == 'update'){
			broadcast(sock, msg);
			sock.stream.write(data.x+','+data.y+','+data.a+','); 
		} else if(data.type == 'register') { 
			sock.viewer = true; 
			
			console.log('adding viewer to socket : '+sock.id); 
		}

		
	
		
		
	}).on('close', function() { 
		// now clean up 
		broadcast(sock, JSON.stringify({type:"leave", id: sock.id}));
	  	var i = connections.indexOf(sock);
		console.log('disconnected', sock.id); 
	    // remove the cached connection
	    if (i !== -1) {
	      connections.splice(i, 1);
		  sock.stream.write(']}');
	      sock.stream.end(); 
		}
	}); 
}); 
