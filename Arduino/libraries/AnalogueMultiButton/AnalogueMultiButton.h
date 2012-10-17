
// header defining the interface of the source.
#ifndef _ANALOGUEMULTIBUTTON_H
#define _ANALOGUEMULTIBUTTON_H

// include Arduino basic header.
#include <Arduino.h>
#include "MultiButton.h"

// the definition of the stack class.
class AnalogueMultiButton {
  public:

    AnalogueMultiButton ();
    ~AnalogueMultiButton ();
	bool init(int analoguePin); 

	int addButton(int minValue, int maxValue); 
	void update(); 
	
	bool isPressed(int buttonIndex); 

	MultiButton * buttons;
	int numButtons; 
	int allocatedButtons; 

  private:

    int pin;
	int lastChange; 
	int lastPinReading; 
	int tolerance; 

};


AnalogueMultiButton::AnalogueMultiButton () {
	numButtons = 0;
	allocatedButtons = 4; 
	
	buttons = (MultiButton*) malloc( sizeof (MultiButton) * allocatedButtons);
	if(buttons==NULL) { 
		// ERROR !
		allocatedButtons = 0; 
	}

}

AnalogueMultiButton::~AnalogueMultiButton() { 
	free (buttons); 
	buttons = NULL; 
	allocatedButtons =0; 
	numButtons = 0; 
	
}


bool AnalogueMultiButton::init(int analoguePin) { 
	pin = analoguePin;
	lastChange = millis(); 
	lastPinReading = 0; 
	tolerance = 20; 
}


int AnalogueMultiButton::addButton(int minValue, int maxValue) { 
	
	
	if(numButtons>=allocatedButtons) { 
		
		buttons = (MultiButton*) realloc (buttons, sizeof (MultiButton) * allocatedButtons+1);
		if(!buttons) { 
			// ERROR!
			Serial.println("ERROR allocating button memory. :( "); 
			return 0;
		} 
			
		
			
		
		
	}
	
	MultiButton button = MultiButton(); 
	
	button.init(minValue, maxValue); 
	buttons[numButtons] = button;
	
	Serial.print("adding button "); 
	Serial.print(numButtons); 
	Serial.println(" "); 
	
	
	allocatedButtons++; 
	numButtons++;
	
	return numButtons-1;
	
}

void AnalogueMultiButton::update() { 
	
	int value = analogRead(pin); 
	//Serial.println(value);
	if((millis() - lastChange > 100)  && (abs(lastPinReading-value)>tolerance)) { 
		
		
	
		for(int i = 0; i<numButtons; i++) { 
		
			 MultiButton & button = buttons[i];
			if((value > button.minValue) && (value <= button.maxValue)) {
				button.pressed = true; 
			} else { 
				button.pressed = false; 	
			}	
			Serial.print(i); 
			Serial.print(":");Serial.print(button.minValue);Serial.print(" "); Serial.print(value); Serial.print(" "); Serial.println(button.maxValue); 
			
			Serial.println(button.pressed); 
			//Serial.print(" "); 
		}
		
		Serial.println(" <<<<<<<< ");
		Serial.println(value);
		lastPinReading = value;
	}	

}

bool AnalogueMultiButton::isPressed(int buttonNumber) { 

	if(buttonNumber<numButtons) { 
		return buttons[buttonNumber].pressed; 
	} else { 
		// ERROR!
		return false; 
	}



}


#endif // _ANALOGUEMULTIBUTTON_H
