
// screen size variables
var SCREEN_WIDTH = window.innerWidth,
	SCREEN_HEIGHT = window.innerHeight,
	HALF_WIDTH = window.innerWidth / 2,
	HALF_HEIGHT = window.innerHeight / 2, 
	touchable = "ontouchstart" in window, 
	fps = 60, 
	mpf = 1000/fps, 
	counter = 0, 
	skippedFrames, 
	startTime = Date.now(); 
	
var ws, 
	wsID; 

	
	landscape = new Landscape(), 
	players = {}, 
	


// canvas element and 2D context
	canvas = document.createElement( 'canvas' ),
	context = canvas.getContext( '2d' ),

// to store the current x and y mouse position
	mouseX = 0, mouseY = 0, 
	
	stats = new Stats(),

// to convert from degrees to radians, 
// multiply by this number!
	TO_RADIANS = Math.PI / 180, 
	
	view = {x:0,
			y:0, 
			scale :1, 
			left :0, 
			right : 0, 
			top :0, 
			bottom:0}, 
	zoomedIn = false, 
	zoomFactor = 4;

window.addEventListener("load", init);


function init() 
{
	
	ws = new WebSocket("ws://node.seb.ly:8001"); 
	ws.onopen = function(e) { 
		
		console.log('connected'); 
		wsConnected = true; 
		
		ws.send(JSON.stringify({type:'register'}));
		
	} 
	ws.onmessage = function(e) { 
	
		
		var msg = JSON.parse(e.data); 
		
		if(msg.type=='connect') { 
			wsID = msg.id;
			
		} else if(msg.type=='join') {
			// add new player object
		} else if(msg.type=='update') { 
			// update player object
			if(!players[msg.id]) { 
				players[msg.id] = new Lander(); 
				players[msg.id].scale =  0.25;
				samples.beep.play();
				
			}
			var player = players[msg.id]; 
			player.updatePosition(msg.x/100, msg.y/100, msg.a, msg.t);  
			player.thrusting = (msg.t == 1);
			
		}  else if(msg.type=='crash') {
				console.log(e.data); 
			var player = players[msg.id]; 
			if(player) player.crash(); 
		}  else if(msg.type=='land') {
			// add new player object
				console.log(e.data); 
			var player = players[msg.id]; 
			if(player) player.land(); 
		} else if(msg.type=='restart') {
				console.log(e.data); 
			// add new player object
			var player = players[msg.id]; 
			if(player) player.reset(); 
		} else if(msg.type=='leave') { 
		// delete player object
			if(players[msg.id]) delete players[msg.id]; 
				console.log(e.data); 
		}
			
			
		
	}
	ws.onclose = function(e) { 
		wsConnected = false; 
		console.log("disconnected!"); 
	}
	
	// CANVAS SET UP
	
	document.body.appendChild(canvas); 
	
	stats.domElement.style.position = 'absolute';
	stats.domElement.style.top = (SCREEN_HEIGHT-45)+'px';
	document.body.appendChild( stats.domElement );
	
	
	canvas.width = SCREEN_WIDTH; 
	canvas.height = SCREEN_HEIGHT;	

	
	window.addEventListener('resize', resizeGame);
	window.addEventListener('orientationchange', resizeGame);
	
	
	resizeGame();
	
	loop();
	
}



//

	
function loop() {
	requestAnimationFrame(loop);

	skippedFrames = 0; 
		
	counter++; 
	var c = context; 
	
	var elapsedTime = Date.now() - startTime; 
	var elapsedFrames = Math.floor(elapsedTime/mpf); 
	var renderedTime = counter*mpf; 
		
	if(elapsedFrames<counter) {
			c.fillStyle = 'green'; 
			c.fillRect(0,0,10,10);
		counter--;
		return; 
	}
	
	
	updatePlayers();
	
	while(elapsedFrames > counter) {
		
		
		counter++; 
	
		skippedFrames ++; 
		if (skippedFrames>30) {
			//set to paused
			counter = elapsedFrames; 
		} 
		
		updatePlayers(); 

	}

	stats.update(); 
	
	updateView(); 
	render(); 
	
}

function updatePlayers() { 
	
		for (var id in players) {
			var player = players[id]; 

			player.update(); 
		}
	
	
	}
	
	
function render() { 
	
	var c = context; 
	
	//c.fillStyle="rgb(0,0,0)";
	c.clearRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
	//c.fillRect(lander.left, lander.top, lander.right-lander.left, lander.bottom-lander.top);
	if(skippedFrames>0) { 
		c.fillStyle = 'green'; 
		c.fillRect(0,0,10*skippedFrames,10);
	}
	c.save(); 
	c.translate(view.x, view.y); 
	c.scale(view.scale, view.scale); 
	
	// THIS CODE SHOWS THE VIEWPORT 
	// c.beginPath(); 
	// 	c.moveTo(view.left+2, view.top+2); 
	// 	c.lineTo(view.right-2, view.bottom-2); 
	// 	c.strokeStyle = 'blue'; 
	// 	c.lineWidth = 2;
	// 	c.rect(view.left, view.top, view.right-view.left, view.bottom-view.top); 
	// 	c.stroke();
	// 	

	landscape.render(context, view);
	//lander.render(context, view.scale);
	
	for (var id in players) {
		var player = players[id]; 
	
		player.render(context, view.scale); 
	}
	
	
	c.restore();

	
}



function updateView() 
{
	var zoomamount  = 0,
	 	marginx  = SCREEN_WIDTH *0.2,
		margintop = SCREEN_HEIGHT * 0.2,
		marginbottom = SCREEN_HEIGHT * 0.3;
	
	// if((!zoomedIn) && (lander.altitude < 60)) {
	// 	setZoom(true);
	// } else if((zoomedIn) && (lander.altitude > 160)) {
	// 	setZoom(false);	
	// }
		
	zoomamount = view.scale;
	
	
	// if(((lander.pos.x * zoomamount) + view.x < marginx)){
	// 	view.x = -(lander.pos.x * zoomamount) + marginx;
	// } else if (((lander.pos.x * zoomamount) + view.x > SCREEN_WIDTH - marginx)) {
	// 	view.x = -(lander.pos.x * zoomamount) + SCREEN_WIDTH - marginx;
	// }
	// 
	// if((lander.pos.y * zoomamount) + view.y < margintop) {
	// 	view.y = -(lander.pos.y * zoomamount) + margintop;
	// } else if ((lander.pos.y * zoomamount) + view.y > SCREEN_HEIGHT - marginbottom) {
	// 	view.y = -(lander.pos.y * zoomamount) + SCREEN_HEIGHT - marginbottom;
	// }
	
	
	view.left = -view.x/view.scale; 
	view.top = -view.y/view.scale; 
	view.right = view.left + (SCREEN_WIDTH/view.scale); 
	view.bottom = view.top + (SCREEN_HEIGHT/view.scale); 
	

}




function setZoom(zoom ) 
{
	if(zoom){
		view.scale = SCREEN_HEIGHT/700*6;				
		zoomedIn = true;
		view.x = -lander.pos.x * view.scale + (SCREEN_WIDTH / 2);
		view.y = -lander.pos.y * view.scale + (SCREEN_HEIGHT * 0.25);
		//lander.scale = 0.25;
	
	} 
	else {
		
		view.scale = SCREEN_HEIGHT/700;
		zoomedIn = false;
		//lander.scale = 0.6;
		view.x = 0;
		view.y = 0;
	}
	
	for (var id in players) { 
		var player = players[id]; 
		//player.scale = lander.scale; 
	}
	
	
}

// returns a random number between the two limits provided 
function randomRange(min, max){
	return ((Math.random()*(max-min)) + min); 
}

function clamp(value, min, max) { 
	return (value<min) ? min : (value>max) ? max : value; 
}

function map(value, min1, max1, min2, max2) { 
	return (((value-min1)/(max1-min1)) * (max2-min2))+min2;
}


function resizeGame (event) { 
	
	var newWidth = window.innerWidth; 
	var newHeight = window.innerHeight; 
	
	if((SCREEN_WIDTH== newWidth) && (SCREEN_HEIGHT==newHeight)) return; 
	if(touchable) window.scrollTo(0,-10); 
	
	SCREEN_WIDTH = canvas.width = newWidth; 
	SCREEN_HEIGHT = canvas.height = newHeight; 
	
	setZoom(zoomedIn ) 
	stats.domElement.style.top = (SCREEN_HEIGHT-45)+'px';
//	infoDisplay.arrangeBoxes(SCREEN_WIDTH, SCREEN_HEIGHT); 

}
