Program Description
Write and test a MASM program to perform the following tasks (check the Requirements section for specifics on program modularization):

Implement and test two macros for string processing. These macros should use Irvine’s ReadString to get input from the user, and WriteString procedures to display output.
mGetString:  Display a prompt (input parameter, by reference), then get the user’s keyboard input into a memory location (output parameter, by reference). You may also need to provide a count (input parameter, by value) for the length of input string you can accommodate and a provide a number of bytes read (output parameter, by reference) by the macro.
mDisplayString:  Print the string which is stored in a specified memory location (input parameter, by reference).
Implement and test two procedures for signed integers which use string primitive instructions
ReadVal: 
Invoke the mGetString macro (see parameter requirements above) to get user input in the form of a string of digits.
Convert (using string primitives) the string of ascii digits to its numeric value representation (SDWORD), validating the user’s input is a valid number (no letters, symbols, etc).
Store this one value in a memory variable (output parameter, by reference). 
WriteVal: 
Convert a numeric SDWORD value (input parameter, by value) to a string of ASCII digits.
Invoke the mDisplayString macro to print the ASCII representation of the SDWORD value to the output.
Write a test program (in main) which uses the ReadVal and WriteVal procedures above to:
Get 10 valid integers from the user. Your ReadVal will be called within the loop in main. Do not put your counted loop within ReadVal.
Stores these numeric values in an array.
Display the integers, their sum, and their truncated average.
Your ReadVal will be called within the loop in main. Do not put your counted loop within ReadVal.
Program Requirements
User’s numeric input must be validated the hard way:
Read the user's input as a string and convert the string to numeric form.
If the user enters non-digits other than something which will indicate sign (e.g. ‘+’ or ‘-‘), or the number is too large for 32-bit registers, an error message should be displayed and the number should be discarded.
If the user enters nothing (empty input), display an error and re-prompt.
ReadInt, ReadDec, WriteInt, and WriteDec are not allowed in this program.
mDisplayString must be used to display all strings.
Conversion routines must appropriately use the LODSB and/or STOSB operators for dealing with strings.
All procedure parameters must be passed on the runtime stack using the STDCall calling convention (see Module 7, Exploration 1 - Passing Parameters on the Stack). Strings also must be passed by reference.
Prompts, identifying strings, and other memory locations must be passed by address to the macros.
Used registers must be saved and restored by the called procedures and macros.
The stack frame must be cleaned up by the called procedure.
Procedures (except main) must not reference data segment variables by name. There is a significant penalty attached to violations of this rule.  Some global constants (properly defined using EQU, =, or TEXTEQU and not redefined) are allowed. These must fit the proper role of a constant in a program (master values used throughout a program which, similar to HI and LO in Project 5).
The program must use Register Indirect addressing or string primitives (e.g. STOSD) for integer (SDWORD) array elements, and Base+Offset addressing for accessing parameters on the runtime stack.
Procedures may use local variables when appropriate.
The program must be fully documented and laid out according to the CS271 Style Guide. This includes a complete header block for identification, description, etc., a comment outline to explain each section of code, and proper procedure headers/documentation.
