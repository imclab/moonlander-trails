

//#define USE_TEST_MACHINE

#ifdef USE_TEST_MACHINE

// STEPPER MOTOR VERSION ------------------------------------

int const A_JOG_UP_PIN   = A0; 
int const A_JOG_DOWN_PIN = A1; 
int const B_JOG_UP_PIN   = A2; 
int const B_JOG_DOWN_PIN = A3; 

int const RESET_BUTTON_PIN = A5; 

// NOT CONNECTED IN THIS SETUP 

int const A_END_STOP_MIN_PIN = 2; // pin 21
int const A_END_STOP_MAX_PIN = 2; // pin 20
int const B_END_STOP_MIN_PIN = 2; // pin 19
int const B_END_STOP_MAX_PIN = 2; // pin 18

int const A_CALIBRATION_PIN = 2;
int const B_CALIBRATION_PIN = 2;

boolean const CALIBRATABLE = false; 

#else

// DC MOTOR VERSION ------------------------------------------

int const A_JOG_UP_PIN   = 32; 
int const A_JOG_DOWN_PIN = 40; 
int const B_JOG_UP_PIN   = 36; 
int const B_JOG_DOWN_PIN = 44; 
int const RESET_BUTTON_PIN = 52; 

int const A_STEP_PIN     = 13; 
int const A_DIR_PIN      = 12; 
int const A_ERR_RESET_PIN    = 10; 
int const B_STEP_PIN     = 14; 
int const B_DIR_PIN      = 15; 
int const B_ERR_RESET_PIN    = 16; 


int const A_END_STOP_MIN_PIN = 3; // pin 21
int const A_END_STOP_MAX_PIN = 2; // pin 20
int const B_END_STOP_MIN_PIN = 17; // pin 19
int const B_END_STOP_MAX_PIN = 9; // pin 18


int const A_CALIBRATION_PIN = 6;
int const B_CALIBRATION_PIN = 8;


boolean const CALIBRATABLE = true; 

#endif




int const STATE_WAITING = 0; 
int const STATE_ERROR = 1; 
int const STATE_RESETTING = 2; 
int const STATE_CALIBRATING = 3; 
int const STATE_DRAWING = 4; 


String const stateStrings[] = {"Waiting", "Error", "Resetting", "Calibrating", "Drawing"}; 


