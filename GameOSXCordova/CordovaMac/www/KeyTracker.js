KeyTracker = new (function(){
	
	this.keysPressed = {}; 
	this.UP = 38; 
	this.LEFT = 37; 
	this.RIGHT = 39; 
	this.DOWN = 40; 
	this.keyListeners = []; 
	
	this.isKeyDown = function (key) { 
		if (typeof key == 'string')
			key = key.charCodeAt(0); 
		return(this.keysPressed[key]);
	};
	
	document.addEventListener("keydown", function(e) {	
		
		KeyTracker.keysPressed[e.keyCode] = true; 
		
		}); 
	document.addEventListener("keyup", 	function(e) {
		KeyTracker.keysPressed[e.keyCode] = false;}); 
		
	this.addKeyDownListener = function(key, func) { 
		if (typeof key == 'string')
			key = key.charCodeAt(0); 
		
		this.keyListeners.push({key:key, func:func});
		
	}
		
})();