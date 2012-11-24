
// header defining the interface of the source.
#ifndef _MULTIBUTTON_H
#define _MULTIBUTTON_H

// include Arduino basic header.
#include <Arduino.h>

// the definition of the stack class.


class MultiButton { 
	public: 
		MultiButton(); 
		~MultiButton(); 
		void init(int minvalue, int maxvalue); 
		bool pressed; 
		
		int maxValue; 
		int minValue;
	private: 
		
	
};

MultiButton :: MultiButton() { 
	pressed = false; 
	
}

void MultiButton :: init(int minvalue, int maxvalue) {
	maxValue = maxvalue; 
	minValue = minvalue; 
	
}

MultiButton :: ~MultiButton() {
	
	
}



#endif // _MULTIBUTTON_H
