Player = function() { 
	
	var pos = this.pos = new Vector2(0,0),
	
		thrustBuild = 0,
	
		bouncing = 0, 
		exploding = false, 
	
		counter = 0, 
		 positions = [],
	//	currentPositionIndex = 0,  
		// 	rotations = [], 
		// 	thrustLevels = [],
		updates = [],
		currentUpdateIndex = 0, 
		
		smoothedPos = this.smoothedPos = new Vector2(), 
		targetRotation = 0;
		
		  
		
		
	this.paused = false; 
	this.rotation = 0; 
	this.thrusting = 0;
	this.scale = 0.8; 
	this.colour = 'white';
	this.lat = 0; 
	this.long = 0; 
	this.city = ""; 
	this.country = ""; 
	this.current = true;
	this.lastUpdate = Date.now();
	this.positions = positions; 
	
	var shapes = this.shapes = [],
		shapePos = this.shapePos = [],
		shapeVels = this.shapeVels = []; 
	
	
	var reset = this.reset = function () { 
		
		pos.reset(110,150); 
		smoothedPos.copyFrom(pos); 
		thrustBuild = 0; 
		bouncing = 0; 
		//this.active = true; 
		exploding = false; 
		for(var i=0; i<shapePos.length; i++) { 
			shapePos[i].reset(0,0); 
		}
		
	};
		
	reset(); 
	

	
	// this.rotate = function(direction) { 
	// 	var now = new Date().getTime(); 
	// 	if(now - lastRotationTime > 80) {
	// 		
	// 		targetRotation+=direction*15; 
	// 		targetRotation = clamp(targetRotation, -90, 90); 
	// 		
	// 		lastRotationTime = now; 
	// 	}
	// 	
	// };
	this.addUpdate = function(updateObj) { 
		updates.push(updateObj); 
	}
	// this.updatePosition = function(x, y, rotation, thrust) { 
	// 	positions.push(new Vector2(x,y)); 
	// 	rotations.push(rotation);
	// 	thrustLevels.push(thrust);
	// 	
	// }

	this.update = function() { 
	//	console.log(currentPositionIndex, positions.length);
		// updates should come through every 100 ms
		if((currentUpdateIndex<updates.length-1)&&(Date.now()-this.lastUpdate>=80)) { 
			currentUpdateIndex++; 
			//console.log(pos, positions[currentPositionIndex], currentPositionIndex); 
			do {
				var update = updates[currentUpdateIndex]; 
			
				if(update.type == 'update') { 
					pos.reset(update.x/100, update.y/100); 
					targetRotation = update.a;
				
					thrustBuild = update.t;
					this.lastUpdate = Date.now();
					this.paused = false;
					positions.push(pos.clone()); 
				} else if(update.type == 'crashed') { 
					this.crash();
					smoothedPos.copyFrom(pos); 
					
				} 
			
				//console.log(update);
				currentUpdateIndex++; 
			} while ((update.type!='update') || (currentUpdateIndex<updates.length-1)); 
			
		} else if(Date.now()-this.lastUpdate>10000) { 
			//console.log("paused"); 
		  this.paused = true; 	

		}	
		
		var diff = pos.minusNew(smoothedPos); 
		diff.multiplyEq(0.1); 
		smoothedPos.plusEq(diff);
		
		this.rotation += ((targetRotation-this.rotation)*0.2);
		
		counter++; 
		
		if(exploding) this.updateShapesAnimation(); 
				
		
	
		setThrustVolume(thrustBuild); 
		
	};
	
	this.render = function(c, scale) { 
		c.globalCompositeOperation = 'lighter'; 
		
	
		// draw the latest data for the ship
	//	console.log(positions.length);
		// if((positions.length>0) && (this.current)) { 
		// 	c.save(); 
		// 		
		// 	c.translate(positions[positions.length-1].x, positions[positions.length-1].y); 
		// 	c.scale(this.scale, this.scale); 
		// 	c.lineWidth = 1/(this.scale * scale); 
		// //	c.rotate(rotations[rotations.length-1] * TO_RADIANS); 
		// 	c.strokeStyle = 'green'; 
		// 
		// 	c.beginPath(); 
		// 
		// 	//this.renderShapes(c);
		// 	c.arc(0,0,5,0,Math.PI*2,true); 
		// 		
		// 	c.stroke(); 
		// 
		// 	c.restore(); 
		//  }
		// draw the smoothed data
		if(this.current) {
			c.save(); 
			//console.log(pos.x, pos.y);
			c.translate(smoothedPos.x, smoothedPos.y); 
			c.scale(this.scale, this.scale); 
			c.lineWidth = 1/(this.scale * scale); 
			c.rotate(this.rotation * TO_RADIANS); 
		//	c.strokeStyle = this.colour; 
			if(this.paused) {
				c.strokeStyle = '#444'; 
			} else {
				c.globalCompositeOperation = 'source-over'; 
				c.strokeStyle = this.colour; 
			}
		
	
			c.beginPath(); 
		
			 this.renderShapes(c);
		
			if((thrustBuild>0) &&(!exploding)) {
				c.lineTo(0,11+(thrustBuild*20*((((counter>>1)%3)*0.2)+1)));
				c.closePath(); 
			}	
		
			
			c.stroke(); 
			c.restore(); 
		}
		
	
		
		c.globalCompositeOperation = 'source-over'; 
		
		this.colour = 'white'; 
		 
	};
	
	this.addPositionsToPath = function(c, view) { 
		var w = 1.5/view.scale; 
		var numpositions = positions.length; 
		for(var i = 0; i<numpositions; i++) { 
			var p = positions[i]; 
			if((p.x>view.left) && (p.x<view.right) && (p.y>view.top) &&(p.y<view.bottom)){
				c.moveTo(p.x, p.y); 
				c.lineTo(p.x+w, p.y); 
			}
		}
	
	
	}
	
	this.crash = function () { 
		this.rotation = targetRotation = 0; 
		this.active = false; 
		exploding = true; 
		thrustBuild = 0; 
		thrusting = 0;
		
	};
	this.land = function () { 
		this.active  =false; 
		thrustBuild = 0; 
	};
	this.makeBounce = function() { 
		bouncing = Math.PI*2;	
		
	};
	
	this.defineShape = function(){
		
		var m='m',
			l='l',
			r='r', 
			cp='cp'; 
		
	
		var min = 2.6, max = 5; 
		var shape = []; 
			
		shape.push(m, min, -max); 
		shape.push(l, max, -min); 
		shape.push(l, max, min); 
		shape.push(l, min, max); 
		shape.push(l, -min, max); 
		shape.push(l, -max, min); 
		shape.push(l, -max, -min); 
		shape.push(l, -min, -max);
		shape.push(cp); 
		
		shapes.push(shape); 
		shapeVels.push(new Vector2(1,-2.5)); 
		
		shapes.push([r, -6,5,12,2]); 
		shapeVels.push(new Vector2(2,-1.5)); 
		
		shape = []; 
		// left leg
		shape.push(m, -5, 7.5); 
		shape.push(l, -9, 13); 
		shape.push(m, -11, 13); 
		shape.push(l, -7, 13); 
		shapes.push(shape); 
		shapeVels.push(new Vector2(0,-3)); 
		
		shape = []; 
		// right leg
		shape.push(m,5,7.5); 
		shape.push(l,9,13); 
		shape.push(m,11,13); 
		shape.push(l,7,13);	
		shapes.push(shape); 
		shapeVels.push(new Vector2(3,-1)); 
		
		shape = [];
		//thruster left
		shape.push(m,-3,7.5); 
		shape.push(l,-5,12); 
		shape.push(l,-4.5,13);
		shapes.push(shape); 
		shapeVels.push(new Vector2(1,-1)); 
	
		shape = [];		
		// thruster right  
		shape.push(m,3,7.5); 
		shape.push(l,5,12); 
		shape.push(l,4.5,13); 
		shapes.push(shape); 
		shapeVels.push(new Vector2(2.5,-1)); 

		shape = [];			
		// thruster bottom
		shape.push(m,4,11); 
		shape.push(l,-4,11); 
		shapes.push(shape); 
		shapeVels.push(new Vector2(2,-0.5)); 
		
		for(var i=0; i<shapes.length; i++) { 
			shapePos.push(new Vector2(1,-0.5)); 
		}
		
	};
	this.defineShape(); 
	
	this.updateShapesAnimation = function() { 
		if(!exploding) return; 
		
		for (var i=0; i<shapePos.length; i++) { 
		 	shapePos[i].plusEq(shapeVels[i]); 
		}
		
	};
	
	this.renderShapes = function(c) { 
		
		var shapes = this.shapes, 
			shapePos = this.shapePos, 
			shapeVels = this.shapeVels; 
		
		for (var i=0; i<shapes.length; i++) { 
			var s = shapes[i].slice(0); 
			
			c.save(); 
			c.translate(shapePos[i].x, shapePos[i].y); 
			//if(exploding) shapePos[i].plusEq(shapeVels[i]); 
			//console.log(i, shapePos[i], shapeVels[i]); 
			
			while(s.length>0) { 
				
				var cmd = s.shift(); 
				switch(cmd) {
					
					case 'm': 
					c.moveTo(s.shift(), s.shift()); 
					break; 
					
					case 'l': 
					c.lineTo(s.shift(), s.shift()); 
					break; 
					
					case 'cp': 
					c.closePath(); 
					break; 
				
					case 'r' : 
					c.rect(s.shift(), s.shift(), s.shift(), s.shift()); 
					break; 
					
					default : 
					console.log ('bad command!'); 
				}
				
			}
			c.restore(); 
			
			
		}
		
		
		
		
	};
	
};