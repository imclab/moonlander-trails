//#define EMULATION_MODE
#define IR_ENABLED

int const A_STEP_PIN        = 34; 
int const A_DIR_PIN         = 36; 
int const A_ERROR_PIN       = 24; 
int const B_STEP_PIN        = 44; 
int const B_DIR_PIN         = 46; 
int const B_ERROR_PIN       = 26; 

int const A_END_STOP_MIN_PIN = 28; 
int const A_END_STOP_MAX_PIN = 32; 
int const B_END_STOP_MIN_PIN = 38; 
int const B_END_STOP_MAX_PIN = 42;

int const BOTH_RESET_PIN = 48;

int const A_CALIBRATION_PIN = 30;
int const B_CALIBRATION_PIN = 40;

boolean const CALIBRATABLE = true; 

int const PEN_DROP_PIN = 2; // or 42? 
int const A_BRAKE_PIN = 3;
int const B_BRAKE_PIN = 4;

int const IR_PIN = 50; 

int const STATE_WAITING = 0; 
int const STATE_ERROR = 1; 
int const STATE_RESETTING = 2; 
int const STATE_CALIBRATING = 3; 
int const STATE_DRAWING = 4; 

String const stateStrings[] = {"Waiting", "Error", "Resetting", "Calibrating", "Drawing"}; 

int const COMMAND_MOVE = 0; 
int const COMMAND_DRAW = 1; 
int const COMMAND_DRAW_DIRECT = 2; 

String const commandStrings[] = {"MOVE", "DRAW", "DRDI"}; 
