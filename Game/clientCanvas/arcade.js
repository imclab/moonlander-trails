KeyTracker.addKeyUpListener('0', function() { lander.thrust(0);});
KeyTracker.addKeyUpListener('1', function() { lander.thrust(0.11);});
KeyTracker.addKeyUpListener('2', function() { lander.thrust(0.22);});
KeyTracker.addKeyUpListener('3', function() { lander.thrust(0.33);});
KeyTracker.addKeyUpListener('4', function() { lander.thrust(0.44);});
KeyTracker.addKeyUpListener('5', function() { lander.thrust(0.55);});
KeyTracker.addKeyUpListener('6', function() { lander.thrust(0.66);});
KeyTracker.addKeyUpListener('7', function() { lander.thrust(0.77);});
KeyTracker.addKeyUpListener('8', function() { lander.thrust(0.88);});
KeyTracker.addKeyUpListener('9', function() { lander.thrust(1);});

leftKey = 'L'; 
rightKey = 'R'; 
startKey = 'T'; 
selectKey = 'E'; 
abortKey = 'B'; 
KeyTracker.addKeyUpListener(startKey, onStartKey); 


function onStartKey() { 
	
		if(gameState==WAITING) newGame(); 
		
	}