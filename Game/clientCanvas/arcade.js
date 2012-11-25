KeyTracker.addKeyUpListener('0', function() { if(gameState==PLAYING) lander.thrust(0);});
KeyTracker.addKeyUpListener('1', function() { if(gameState==PLAYING) lander.thrust(0.11);});
KeyTracker.addKeyUpListener('2', function() { if(gameState==PLAYING) lander.thrust(0.22);});
KeyTracker.addKeyUpListener('3', function() { if(gameState==PLAYING) lander.thrust(0.33);});
KeyTracker.addKeyUpListener('4', function() { if(gameState==PLAYING) lander.thrust(0.44);});
KeyTracker.addKeyUpListener('5', function() { if(gameState==PLAYING) lander.thrust(0.55);});
KeyTracker.addKeyUpListener('6', function() { if(gameState==PLAYING) lander.thrust(0.66);});
KeyTracker.addKeyUpListener('7', function() { if(gameState==PLAYING) lander.thrust(0.77);});
KeyTracker.addKeyUpListener('8', function() { if(gameState==PLAYING) lander.thrust(0.88);});
KeyTracker.addKeyUpListener('9', function() { if(gameState==PLAYING) lander.thrust(1);});

leftKey = 'L'; 
rightKey = 'R'; 
startKey = 'T'; 
selectKey = 'E'; 
abortKey = 'B'; 
KeyTracker.addKeyUpListener(startKey, onStartKey); 

startMessage = "PLAY LUNAR LANDER<br><br>PRESS START BUTTON<br>";
singlePlayMode = true; 

function onStartKey() { 
	
	if(gameState==WAITING) 
		newGame(); 
	else {
		gameState=GAMEOVER;
		sendGameOver();
		restartLevel();
	}
}