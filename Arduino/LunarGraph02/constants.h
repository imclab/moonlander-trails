

//#define USE_TEST_MACHINE

#ifdef USE_TEST_MACHINE

// STEPPER MOTOR VERSION ------------------------------------

int const A_JOG_UP_PIN   = A10; 
int const A_JOG_DOWN_PIN = A11; 
int const B_JOG_UP_PIN   = A12; 
int const B_JOG_DOWN_PIN = A13; 

int const RESET_BUTTON_PIN = 18; 

// NOT CONNECTED IN THIS SETUP 

int const A_END_STOP_MIN_PIN = 22; // pin 21
int const A_END_STOP_MAX_PIN = 23; // pin 20
int const B_END_STOP_MIN_PIN = 24; // pin 19
int const B_END_STOP_MAX_PIN = 25; // pin 18

//int const A_END_STOP_MIN_INTERRUPT = 2; // pin 21
//int const A_END_STOP_MAX_INTERRUPT = 3; // pin 20
//int const B_END_STOP_MIN_INTERRUPT = 4; // pin 19
//int const B_END_STOP_MAX_INTERRUPT = 5; // pin 18



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
//
//int const A_END_STOP_MIN_INTERRUPT = 1; // pin 21
//int const A_END_STOP_MAX_INTERRUPT = 0; // pin 20
//int const B_END_STOP_MIN_INTERRUPT = 5; // pin 19
//int const B_END_STOP_MAX_INTERRUPT = 4; // pin 18


#endif

int const A_CALIBRATION_PIN = 6;
int const B_CALIBRATION_PIN = 8;


int const STATE_WAITING = 0; 
int const STATE_RESET = 1; 
int const STATE_CALIBRATING = 2; 
int const STATE_BUSY = 3; 
int const STATE_EMERGENCY_STOP = 4; 





