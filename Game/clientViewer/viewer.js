
// screen size variables
var SCREEN_WIDTH = 0,
	SCREEN_HEIGHT = 0,
	HALF_WIDTH = window.innerWidth / 2,
	HALF_HEIGHT = window.innerHeight / 2, 
	MAX_PLAYERS = 100, 
	touchable = "ontouchstart" in window, 
	fps = 60, 
	mpf = 1000/fps, 
	counter = 0, 
	skippedFrames, 
	startTime = Date.now(), 
	playerCount = 0; 
	
var landscape = new Landscape(), 
	players = {},
	lowestVisibleLandscape = 0, 
	highestPlayer = 800,
	actionRectangle, 
	smoothedRectangle, 
	viewRectangle, 
	debug = false, 
	showCurrentData = false; 
	

// canvas element and 2D context
	canvas = document.createElement( 'canvas' ),
	context = canvas.getContext( '2d' ),
	trailsCanvas = document.createElement('canvas'), 
	trailsContext = trailsCanvas.getContext('2d'),
	trailsCanvasSize = new Vector2(2000,1200), 
	trailsOffset = new Vector2(500,400), 
	trailsScale = 4, 

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
	
	initWebSocket();
	// CANVAS SET UP
	
	document.body.appendChild(canvas); 
	
	stats.domElement.style.position = 'absolute';
	stats.domElement.style.top = (SCREEN_HEIGHT-45)+'px';
	document.body.appendChild( stats.domElement );
	
	
	canvas.width = SCREEN_WIDTH; 
	canvas.height = SCREEN_HEIGHT;	
	
	trailsCanvas.width = trailsCanvasSize.x*trailsScale; 
	trailsCanvas.height = trailsCanvasSize.y*trailsScale; 
	trailsContext.strokeStyle = 'white'; 
	trailsContext.globalCompositeOperation = 'lighter'; 
	trailsContext.scale(trailsScale, trailsScale); 
	trailsContext.translate(trailsOffset.x,trailsOffset.y); 
	
	window.addEventListener('resize', resizeGame);
	window.addEventListener('orientationchange', resizeGame);
	
	KeyTracker.addKeyUpListener("D", toggleDebug); 
	

	resizeGame();
	
	actionRectangle = new Rectangle(0,0,SCREEN_WIDTH, SCREEN_HEIGHT), 
	smoothedRectangle = new Rectangle(0,0,SCREEN_WIDTH, SCREEN_HEIGHT); 
	viewRectangle = new Rectangle(0,0,SCREEN_WIDTH, SCREEN_HEIGHT); 
	
	setInterval(loop, 1000/60); 
	//render();
	
}

function toggleDebug() { 
debug = !debug;
	
}
/* LUNARGRAPH TEST CODE
function startDrawing(id) { 
	if(currentDrawingPlayerId!=-1) return; 
	
	console.log("starting to draw id : ", id); 
	currentDrawingPlayerId = id; 
	
}
function stopDrawing(id) { 
	if(id!=currentDrawingPlayerId) return; 
	
	console.log("stopping drawing id : ", id); 
	currentDrawingPlayerId = -1; 
}
*/
//

	
function loop() {
	
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

	checkWebSockets();
	stats.update(); 
	
	var speed = 0.01; 
	smoothedRectangle.setLeft(smoothedRectangle.x + ((actionRectangle.x - smoothedRectangle.x)*speed)); 
	smoothedRectangle.setTop(smoothedRectangle.y + ((actionRectangle.y - smoothedRectangle.y)*speed)); 
	smoothedRectangle.setRight(smoothedRectangle.getRight() +  ((actionRectangle.getRight() - smoothedRectangle.getRight())*speed)); 
	smoothedRectangle.setBottom(smoothedRectangle.getBottom() + ((actionRectangle.getBottom() - smoothedRectangle.getBottom())*speed)); 
	
	// fix aspect ratio
	viewRectangle.x = smoothedRectangle.x; 
	viewRectangle.y = smoothedRectangle.y; 
	viewRectangle.width = smoothedRectangle.width; 
	viewRectangle.height = smoothedRectangle.height; 


	var screenratio = SCREEN_WIDTH/SCREEN_HEIGHT; 
	var actionratio = viewRectangle.width/viewRectangle.height; 
	
	if(screenratio>actionratio) { 
	
			
		var newwidth = viewRectangle.height * screenratio; 
		var midx = (viewRectangle.x + (viewRectangle.width/2)); 
		var newx = midx - newwidth/2; 
	
		var diff = viewRectangle.x - newx;
		//if(newx<0) 
		viewRectangle.x -= diff*0.3; 
		//else viewRectangle.x = newx; 
		
		viewRectangle.width = newwidth; 
		
	} else { 
		
		
		var newheight = viewRectangle.width / screenratio; 
		var midy = (viewRectangle.y +(viewRectangle.height/2)); 
		var newy = midy - newheight/2; 
		viewRectangle.y = newy; 
		viewRectangle.height = newheight; 
		
	} 
	
	updateView(); 
	render(); 
	
}

	
function render() { 
//	requestAnimationFrame(render);
	
	var c = context; 
	
	c.clearRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);


	if(skippedFrames>0) { 
		c.fillStyle = 'green'; 
		c.fillRect(0,0,10*skippedFrames,10);
	}
	c.save(); 
//	view.scale =0.5;
	if(!debug) { 
		c.scale(view.scale, view.scale); 
		c.translate(-view.x, -view.y); 
		//c.translate(-viewRectangle.x*view.scale, -viewRectangle.y*view.scale);
		///c.scale(view.scale, view.scale); 
	
	
	} else { 
		// THIS CODE SHOWS THE actionRectangle 
		c.beginPath(); 
		c.moveTo(actionRectangle.getLeft()+2, actionRectangle.getTop()+2); 
		c.lineTo(actionRectangle.getRight()-2, actionRectangle.getBottom()-2); 
		c.strokeStyle = 'blue'; 
		c.lineWidth = 2;
		c.rect(actionRectangle.x, actionRectangle.y, actionRectangle.width,actionRectangle.height); 
		c.stroke();

		c.beginPath(); 
		c.moveTo(smoothedRectangle.getLeft()+2, smoothedRectangle.getTop()+2); 
		c.lineTo(smoothedRectangle.getRight()-2, smoothedRectangle.getBottom()-2); 
		c.strokeStyle = 'red'; 
		c.lineWidth = 2;
		c.rect(smoothedRectangle.x, smoothedRectangle.y, smoothedRectangle.width,smoothedRectangle.height); 
		c.stroke();

		c.beginPath(); 
		c.moveTo(viewRectangle.getLeft()+2, viewRectangle.getTop()+2); 
		c.lineTo(viewRectangle.getRight()-2, viewRectangle.getBottom()-2); 
		c.strokeStyle = 'green'; 
		c.lineWidth = 2;
		c.rect(viewRectangle.x, viewRectangle.y, viewRectangle.width,viewRectangle.height); 
		c.stroke();
	
		c.beginPath(); 
		c.moveTo(view.left+2, view.top+2); 
		c.lineTo(view.right-2, view.bottom-2); 
		c.strokeStyle = 'white'; 
		c.lineWidth = 1;
		c.rect(view.x, view.y, view.width,view.height); 
		c.stroke();
	}	
	
	c.save(); 
	c.translate(-trailsOffset.x, -trailsOffset.y); 
	c.scale(1/trailsScale, 1/trailsScale);
	//trailsContext.fillStyle = 'cyan';
	//trailsContext.fillRect(0,0,trailsCanvas.width, trailsCanvas.height);
	 
	c.drawImage(trailsCanvas, 0,0);
	c.restore(); 
		
	landscape.render(context, view);
	
	playerCount = 0; 
	var firstID = ""; 
	for (var id in players) {
		if(playerCount == 0) firstID = id; 
		var player = players[id]; 
		
		playerCount++; 
		player.render(context, view.scale); 
	}
	
	//c.globalCompositeOperation = 'lighter';
	//c.lineWidth = 1.5/view.scale; 
	//c.strokeStyle = 'rgb(20,50,200)';
		
	/*if(playerCount>MAX_PLAYERS) delete players[firstId]; 
	
	for (var id in players) {
		c.beginPath();
		players[id].addPositionsToPath(c, view); 
		c.stroke();
	}*/		


	
		
	
	c.restore();
	
	// var imagedata = c.getImageData(0,0,SCREEN_WIDTH, SCREEN_HEIGHT); 
	// var p = new Vector2(0,0); 
	// for (var id in players) {
	// 	var player = players[id];
	// 	var positions = player.positions; 
	// 	var numpositions = positions.length;  
	// 
	// 	for(var i = 0; i<numpositions; i++) { 
	// 		p.copyFrom(positions[i]);
	// 		
	// 		p.x-=view.x; 
	// 		p.y-=view.y; 
	// 		p.multiplyEq(view.scale); 
	// 		if ((p.x<0) || (p.x>SCREEN_WIDTH) || (p.y<0) || (p.y>SCREEN_HEIGHT)) continue; 
	// 		
	// 		drawPixel(imagedata, p.x, p.y); 
	// 		
	// 	}
	// 	
	// }
	// 
	// c.putImageData(imagedata, 0,0); 
	
	
	
}



function updatePlayers() { 
	
	var top = 10000; 
	var bottom = -100000; 
	var left = 100000; 
	var right = -100000; 
	
	var playerCount = 0; 
	
	for (var id in players) {
	
		var player = players[id]; 
	
				
		player.update(trailsContext); 
		
			if ((player.smoothedPos.y<-1000) ||
				(player.smoothedPos.x<-1000) || 
				(player.smoothedPos.x>3000)) 
					continue; 
		
		if((player.current) &&(!player.paused)) playerCount++; 
		else continue; 
	
	
		
		var landY = getLandscapeY(player.smoothedPos.x); 
		var altitude = landY - player.smoothedPos.y;
	
		if(altitude > 300) landY = landscape.bottom;
//	console.log(altitude, landY);
		if(landY>bottom) 
			bottom = landY;
		if(player.smoothedPos.y<top) {
			//if(player.smoothedPos.y>-2000) 
			top = player.smoothedPos.y; 
			//else 
			//	continue; 
		}	
		if(player.smoothedPos.x<left) 
			left = player.smoothedPos.x; 
		if(player.smoothedPos.x>right) 
			right = player.smoothedPos.x; 

		//LUNARGRAPH TEST CODE 
		/*
		if((id == currentDrawingPlayerId) && (player.paused)) { 	
			stopDrawing(currentDrawingPlayerId);  
			console.log("player paused"); 
		}*/
	}
//	view.bottom = lowestVisibleLandscape;
	if(playerCount == 0) { 
		actionRectangle.x = 0;//landscape.tileWidth/2; 
		actionRectangle.y = 0; 
		actionRectangle.width = landscape.tileWidth; 
		actionRectangle.height = 700; 
	} else { 
		actionRectangle.x = left; 
		actionRectangle.y = top; 
		actionRectangle.width = right - left; 
	
		actionRectangle.height = bottom-top; 
		
		
		var verticalpadding = Math.min(Math.max(actionRectangle.height*0.2, 60), 200); 
		var horizpadding = Math.min(Math.max(actionRectangle.width*0.2, 60), 80); 

		
		actionRectangle.y -= verticalpadding; 
		actionRectangle.height +=verticalpadding*2;
		
		actionRectangle.x -=horizpadding; 
		actionRectangle.width += horizpadding*2; 
		if(actionRectangle.getBottom() > landscape.bottom +20) actionRectangle.setBottom(landscape.bottom +20); 
		
	}
	

}





function drawPixel(imagedata, x, y) { 

	 
    var i = ((y>>0) * imagedata.width + (x>>0)) * 4;

    imagedata.data[i] += 40;
    imagedata.data[i+1] += 80;
    imagedata.data[i+2] += 255;
    imagedata.data[i+3] = 255;
	
}

function updateView() 
{
	
	view.x = viewRectangle.getLeft(); 
	view.y = viewRectangle.getTop(); 
	//view.bottom = viewRectangle.getBottom(); 

	// 	
	 	view.scale = SCREEN_WIDTH/viewRectangle.width; 
		
	//var zoomamount  = 0,
	// 	marginx  = SCREEN_WIDTH *0.2,
	//	margintop = SCREEN_HEIGHT * 0.2,
	//	marginbottom = SCREEN_HEIGHT * 0.3;
	
	// if((!zoomedIn) && (lander.altitude < 60)) {
	// 	setZoom(true);
	// } else if((zoomedIn) && (lander.altitude > 160)) {
	// 	setZoom(false);	
	// }
		
	//zoomamount = view.scale;
	
	
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
	
	
	view.left = view.x; 
	view.top = view.y; 
	view.right = view.left + (SCREEN_WIDTH/view.scale); 
	view.bottom = view.top + (SCREEN_HEIGHT/view.scale); 
	view.width = view.right-view.left; 
	view.height = view.bottom-view.top; 
	
	
	

}




function setZoom(zoom ) 
{
	if(zoom){
		//view.scale = SCREEN_HEIGHT/700*6;				
		//zoomedIn = true;
		//view.x = -lander.pos.x * view.scale + (SCREEN_WIDTH / 2);
		//view.y = -lander.pos.y * view.scale + (SCREEN_HEIGHT * 0.25);
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
		player.scale = 0.25; 
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
	//context.webkitImageSmoothingEnabled = false;
	
	setZoom(zoomedIn ) 
	stats.domElement.style.top = (SCREEN_HEIGHT-45)+'px';
//	infoDisplay.arrangeBoxes(SCREEN_WIDTH, SCREEN_HEIGHT); 

}

function getLandscapeY(x) { 

	var lines = landscape.lines; 
	x = x%landscape.tileWidth; 
		
	while(x<0){ 
		x+=landscape.tileWidth; 
	}


	for(var i=0; i<lines.length; i++ ) { 
		line = lines[i]; 
		// if the ship overlaps this line
		if((x>line.p1.x) && (x<line.p2.x)){ 

			return line.p2.y; 
		}
	}


}


function Rectangle(x, y, width, height) { 
	
	this.x = x; 
	this.y = y; 
	this.width = width; 
	this.height = height; 
	
	this.getBottom = function() { 
		return this.y+this.height; 
	}
	this.getLeft = function () { 
		return this.x; 
	}
	this.getRight = function () { 
		return this.x+this.width; 
	}
	this.getTop = function() { 
		return this.y; 
	}
	this.setBottom = function(bottom) { 
		this.height = bottom - this.y; 
	}
	this.setRight = function (right){ 
		this.width = right - this.x; 
	}
	this.setTop = function(top) { 
		this.height -= (top-this.y); 
		this.y = top; 
	}
	this.setLeft = function(left) { 
		this.width -= (this.x-left); 
		this.x = left; 
	}
	
}
