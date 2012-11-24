

//#define USE_TEST_MACHINE

#ifdef USE_TEST_MACHINE

// STEPPER MOTOR VERSION ------------------------------------
//
//int const A_JOG_UP_PIN   = A0; 
//int const A_JOG_DOWN_PIN = A1; 
//int const B_JOG_UP_PIN   = A2; 
//int const B_JOG_DOWN_PIN = A3; 
//
//int const RESET_BUTTON_PIN = A5; 
//
//// NOT CONNECTED IN THIS SETUP 
//
//int const A_END_STOP_MIN_PIN = 4; // pin 21
//int const A_END_STOP_MAX_PIN = 2; // pin 20
//int const B_END_STOP_MIN_PIN = 2; // pin 19
//int const B_END_STOP_MAX_PIN = 2; // pin 18
//
//int const A_CALIBRATION_PIN = 2;
//int const B_CALIBRATION_PIN = 2;
//
//boolean const CALIBRATABLE = false; 

#else

// DC MOTOR VERSION ------------------------------------------

int const A_JOG_UP_PIN      = A1; 
int const A_JOG_DOWN_PIN    = A2; 
int const B_JOG_UP_PIN      = 28; 
int const B_JOG_DOWN_PIN    = 30; 
int const RESET_BUTTON_PIN  = 32;
int const SPARE_BUTTON_PIN  = A0;

int const A_STEP_PIN        = 43; 
int const A_DIR_PIN         = 45; 
int const A_ERR_RESET_PIN   = 41; 
int const B_STEP_PIN        = 47; 
int const B_DIR_PIN         = 49; 
int const B_ERR_RESET_PIN   = 39; 


int const A_END_STOP_MIN_PIN = 46; 
int const A_END_STOP_MAX_PIN = 48; 
int const B_END_STOP_MIN_PIN = 31; 
int const B_END_STOP_MAX_PIN = 33; 


int const A_CALIBRATION_PIN = 50;
int const B_CALIBRATION_PIN = 35;


boolean const CALIBRATABLE = true; 

int const PEN_DROP_PIN = 42; // or 42? 
int const A_BRAKE_PIN = 40;
int const B_BRAKE_PIN = 51;

#endif



int const STATE_WAITING = 0; 
int const STATE_ERROR = 1; 
int const STATE_RESETTING = 2; 
int const STATE_CALIBRATING = 3; 
int const STATE_DRAWING = 4; 

String const stateStrings[] = {"Waiting", "Error", "Resetting", "Calibrating", "Drawing"}; 

int const COMMAND_MOVE = 0; 
int const COMMAND_DRAW = 1; 
int const COMMAND_DRAW_DIRECT = 2; 
