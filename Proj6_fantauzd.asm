TITLE Designing low-level I/O procedures     (Proj6_fantauzd.asm)

; Author: Dominic Fantauzzo
; Last Modified: 12/6/2023
; OSU email address: fantauzd@oregonstate.edu
; Course number/section: CS271 Section 400
; Project Number:         6        Due Date: 12/10/2023
; Description: This program creates macros to get a string from a user and to display a string.
;			   The program also creates procedures to read and write SDWORD values using string primitives.
;			   Finally, the program uses the macros and procedures above to get 10 valid integers from the
;			   user, store the integers in an array, display the integers, find and display their sum, and
;			   find and display their truncated average.



INCLUDE Irvine32.inc

; --------------------------
; Define any constants here
; --------------------------
STRINGMAX = 12						; most characters we can have in a string that we will convert and store as an SDWORD
NUMBEROFINPUTS = 10					; number of strings (representing numbers) that we will get from user


; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Displays a prompt then gets a string from the user's keyboard input. Moves the
; string into a memory location.
;
; Preconditions: Do not use eax, edx, ecx as arguments
;
; Receives:
; prompt         = array address for prompt to get string from user
; memoryLocation = A location in memory where the string can be stored
; maxLength      = value representing the maximum string length that may be used
; bytesRead      = an address to store a DWORD representing the number of bytes read
; 
; returns: memoryLocation = offset for user's input string
;		   bytesRead      = number of bytes read by the macro
; ---------------------------------------------------------------------------------
mGetString MACRO prompt:REQ, memoryLocation:REQ, maxLength:REQ, bytesRead:REQ
; --------------------------
; Display Prompt to user
; --------------------------
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	MOV		EDX, prompt
	CALL	WriteString
; --------------------------
; Save user input to memoryLocation
; --------------------------
	MOV		ECX, maxLength
	MOV		EDX, memoryLocation
	CALL	ReadString
	MOV		EBX, bytesRead
	MOV		[EBX], EAX					; store the number of bytes read at proper memory location
; --------------------------
; Clean up stack frame and end
; --------------------------
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
ENDM


; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Prints the string at the passed memory location.
;
; Preconditions: String at memoryLocation is 0 terminated
;
; Receives:
; memoryLocation = The address in memory where the string to be printed begins
; 
; returns: None, prints the string at memoryLocation
; ---------------------------------------------------------------------------------
mDisplayString MACRO memoryLocation:REQ
	PUSH	EDX
	MOV		EDX, memoryLocation
	CALL	WriteString
	POP		EDX
ENDM



.data

intro1				BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures",13,10,"Written by: Dominic Fantauzzo",13,10,0
intro2				BYTE	"Please provide 10 signed decimal integers. Each number needs to be small enough to fit inside a 32 bit register. After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.",13,10,0
prompt1				BYTE	"Please enter a signed number: ",0
errorMessage		BYTE	"ERROR: You did not enter a signed number or your number was too big.",13,10,0
retryMessage		BYTE	"Please try again: ",0
return1				BYTE	"You entered the following numbers:",13,10,0
sumMessage			BYTE	"The sum of these numbers is: ",0
sum					SDWORD	0
averageMessage		BYTE	"The truncated average is: ",0
average				SDWORD	0
goodbye1			BYTE	"Thanks for playing!",0
userString			BYTE	STRINGMAX DUP (0)
outputString		BYTE	11 DUP (0)
averageString		BYTE	11 DUP (0)
userInteger			SDWORD	0
userInputs			SDWORD	NUMBEROFINPUTS DUP (0)
bytesRead			DWORD	0
spaceFormat			BYTE	" ",0
commaFormat			BYTE	",",0


.code
main PROC
; --------------------------
; introduce program using Macros
; --------------------------
	mDisplayString	OFFSET intro1
	CALL	CrLf
	mDisplayString	OFFSET intro2
	CALL	CrLf
; --------------------------
; Gets all inputs from user and stores valid inputs at userInputs ([EBP + 8])
; --------------------------
	PUSH	OFFSET bytesRead
	PUSH	OFFSET userInteger
	PUSH	OFFSET errorMessage
	PUSH	OFFSET prompt1
	PUSH	OFFSET userString					; userString holds user input in string form (BYTE Array)
	PUSH	STRINGMAX							; stringMax is the size of userString (1 x 11 = 11)
	PUSH	NUMBEROFINPUTS
	PUSH	OFFSET userInputs
	CALL	GetAllInputs
; --------------------------
; Display numeric versions of all valid user inputs, with header
; --------------------------
	CALL	CrLf
	mDisplayString	OFFSET return1
	CALL	CrLf
	PUSH	OFFSET commaFormat
	PUSH	OFFSET spaceFormat
	PUSH	OFFSET outputString
	PUSH	NUMBEROFINPUTS
	PUSH	OFFSET userInputs
	CALL	DisplayAllInputs
	CALL	CrLf
; --------------------------
; Calculate sum
; --------------------------
	PUSH	OFFSET sum
	PUSH	NUMBEROFINPUTS
	PUSH	OFFSET userInputs
	CALL	CalculateSum
; --------------------------
; Display sum
; --------------------------
	Call	CrLf
	mDisplayString	OFFSET sumMessage
	PUSH	OFFSET outputString
	PUSH	sum
	CALL	WriteVal
	CALL	CrLf
; --------------------------
; Calculate average
; --------------------------
	PUSH	OFFSET average
	PUSH	NUMBEROFINPUTS
	PUSH	sum
	CALL	CalculateAverage
; --------------------------
; Display average
; --------------------------
	Call CrLf
	mDisplayString	OFFSET averageMessage
	PUSH	OFFSET	averageString
	PUSH	average
	CALL	WriteVal
	CALL	CrLf
; --------------------------
; Say Goodbye!
; --------------------------
	CALL	CrLf
	mDisplayString	OFFSET goodbye1
	CALL	CrLf
	CALL	CrLf

main ENDP


; ---------------------------------------------------------------------------------
; Name: CalculateAverage
; 
; Takes the a number of values and the sum of these values as parameters. Then calculates
; the truncated average and stores the result.
;
; Preconditions: [EBP + 16] references a location with type SDWORD. [EBP + 8] and
;					[EBP + 12] are based on the same group of numbers and are input
;					(value) parameters. Assumes sum has already been calculated.
;
; Postconditions: [EBP + 16] now holds the truncated average of all values that were used
;					to find the sum at [EBP + 8].
;
; Receives:
;		[EBP + 16]		= Reference to memory location to store average (output parameter)
;		[EBP + 12]		= Value representing number of integers that were used to find sum
;		[EBP + 8]		= Value representing the sum of the integers
;
; Returns: 
;		[EBP + 16]		= Reference to memory location with the truncated average of the integers
; ---------------------------------------------------------------------------------
CalculateAverage PROC
; --------------------------
; Build up stack frame, save registers, set our dividend and divisor registers
; --------------------------
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD
	MOV		EAX, [EBP + 8]					; place sum in EAX
	MOV		EBX, [EBP + 12]					; place number of values in EBX (divisor)
; --------------------------
; Calculate the average
; --------------------------
	CDQ
	IDIV	EBX								; EAX now holds truncated average (we don't care about remainder)
; --------------------------
; Store truncated average
; --------------------------
	MOV		EBX, [EBP + 16]
	MOV		[EBX], EAX
; --------------------------
; Clean up stack and return
; --------------------------
	POPAD
	POP		EBP
	RET		12								; We passed 3, 4 BYTE parametes so we use RET 12
CalculateAverage ENDP


; ---------------------------------------------------------------------------------
; Name: CalculateSum
; 
; Adds all the values in an array to find the sum. The stores the sum in a memory location.
;
; Preconditions: [EBP + 16] references a location with type SDWORD.
;				 [EBP + 12] is equal to LENGTHOF [EBP + 8] (If we want to sum all the values
;				 in the array). [EBP + 8] is an array of SDWORDs.
;
; Postconditions: [EBP + 16] now holds the sum of all values that are in the array
;					at [EBP + 8].
;
; Receives:
;		[EBP + 16]		= Reference to memory location to store sum (output parameter)
;		[EBP + 12]		= Value representing number of integers to sum
;		[EBP + 8]		= Reference to an array of integers that we want to find sum of
;
; Returns: 
;		[EBP + 16]		= sum of values in array at [EBP + 8]
; ---------------------------------------------------------------------------------
CalculateSum PROC
; --------------------------
; Build up stack frame, save registers, set destination, loop, and output registers
; --------------------------
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD
	MOV		EDI, [EBP + 8]						; EDI refers to first element in our SDWORD array
	MOV		ECX, [EBP + 12]						
	MOV		EBX, [EBP + 16]						; EBY holds output reference parameter
	XOR		EAX, EAX
; --------------------------
; Sum all the values in the array to EAX
; --------------------------
_findSum:
	ADD		EAX, [EDI]
	ADD		EDI, 4								; Add 4 as we are iterating over SDWORD (4 BYTE) values
	LOOP	_findSum
; --------------------------
; Store sum in the output parameter
; --------------------------
	MOV		[EBX], EAX
; --------------------------
; Clean up stack frame and return
; --------------------------
	POPAD
	POP		EBP
	RET		12									; We passed 3, 4 BYTE parametes so we use RET 12
CalculateSum ENDP


; ---------------------------------------------------------------------------------
; Name: ReadVal
; 
; Gets a string from the user using the mGetString Macro. Then validates that this string
; represents a valid SDWORD number. Converts the string to numeric representation and stores
; in memory.
;
; Preconditions: [EBP + 16] is equal to 11 when working with DWORD/SDWORD.
;				 [EBP + 16] is equal to LENGTHOF [EBP + 20] (We cannot take input that is
;				 longer than we can store). [EBP + 24] and [EBP + 28] are 0 terminated.
;
; Postconditions: [EBP + 24] now holds an SDWORD. This SDWORD is a numeric verion of a valid 
;					string that the user entered.
;
; Receives:
;		[EBP + 28]		= reference to DWORD holding the number of characters entered after mGetString
;		[EBP + 24]		= reference to single SDWORD for storing numeric version of user input
;		[EBP + 20]		= reference to string that tells user of Error
;		[EBP + 16]		= reference to string that prompts user for input
;		[EBP + 12]		= reference to array that can hold user input
;		[EBP + 8]		= Value representing maximum length of input string
;
; Returns: 
;		[EBP + 24]		= reference to single SDWORD with valid numeric version of user input string
; ---------------------------------------------------------------------------------
ReadVal PROC
; --------------------------
; Build up stack frame, save registers
; --------------------------
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD
; --------------------------
; Get a string from the user
; --------------------------
_getNewString:
	mGetString [EBP + 16], [EBP + 12], [EBP + 8], [EBP + 28]	; Afterwards, [EBP + 12] now holds user string
	MOV		ESI, [EBP + 12]										; Set our source register to [EBP + 12] so we can read our user input
	CLD															; Make sure we are reading front to back
; --------------------------
; Check that the string from the user is valid (digits form an SDWORD)
; --------------------------
; --------------------------
; First we will check that there are not too many digits
; --------------------------
	MOV		EAX, [EBP + 28]
	MOV		EBX, [EAX]							; EBX = number of digits entered by user
	XOR		EAX, EAX
	LODSB
	CMP		AL, 45								; Checks first digit to see if it is ASCII 45 ('-')
	JE		_negativeDigitCheck
	CMP		EBX, 10								; if positive cannot have more than 10 digits
	JA		_invalidInput
	JMP		_correctDigit
_negativeDigitCheck:
	CMP		EBX, 11								; if negative cannot have more than 11 digits
	JA		_invalidInput
_correctDigit:
	MOV		ESI, [EBP + 12]						; reset ESI to point to first digit
; --------------------------
; Once we know that we have the correct number of digits, we examine each digit
; --------------------------
	MOV		EBX, 0								; Use EBX to store current total number, starts at 0
_validateDigit:
	XOR		EAX, EAX							; Ensure no value currently in EAX
	LODSB										; Load a byte from user's string
; --------------------------
; Check that we have not reached a null value
; --------------------------
	CMP		AL, 0								; Since user entered string, 0 is ASCII NULL
	JE		_endDigit
; --------------------------
; Check that the string digit is a number
; --------------------------
	CMP		AL, 57
	JA		_invalidInput
	CMP		AL, 43								; We still need to check below 48 becuase ASCII for '-' and '+' are 45 and 43										
	JB		_invalidInput						; There is no valid digit below ASCII 43 ('+')
	JE		_validateDigit
	CMP		AL, 44
	JE		_invalidInput
	CMP		AL, 45
	JE		_validateDigit						; ASCII 45 is valid ('-')
	CMP		AL, 46
	JE		_invalidInput
	CMP		AL, 47
	JE		_invalidInput
	
; --------------------------
; If we made it through the checks then we can convert ASCII to int, 
; add to current total, and store
; --------------------------
	SUB		AL, 48
	PUSH	EAX
	MOV		EAX, EBX							; current total goes into EAX, freeing up EBX
	MOV		EBX, 10
	IMUL	EBX									; EAX now equals current total x 10, we slide current total one space left to make room for new digit
	POP		EBX									; EBX now equals our new digit
	JO		_invalidInput
	ADD		EAX, EBX							; EAX is our new current total
	JO		_invalidInput
	MOV		EBX, EAX
	JMP		_validateDigit						; Repeat for next digit
; --------------------------
; At last digit we verify something was entered, store integer representation, and return
; --------------------------
_endDigit:
	CMP		EBX, 0								; last check to make sure something was entered
	JE		_invalidInput
	MOV		ESI, [EBP + 12]						; load first digit (sign digit) into AL
	CLD
	LODSB
	CMP		AL, 45
	JE		_negativeInput						; If fist digit is ASCII 45 ('-') then int is negative
; --------------------------
; Store value in EAX and clean up stack frame
; --------------------------
_return:
	MOV		EDI, [EBP + 24]						; set EDI to memory location for single SDWORD
	MOV		[EDI], EBX							; store numeric version of input in [EBP + 24]
	POPAD
	POP		EBP
	RET		24									; We passed 6, 4 BYTE (DWORD) parameters so RET 16
; --------------------------
; If int is negative then we make it negative before storing and returning
; --------------------------
_negativeInput:
	neg EBX
	JMP _return
; --------------------------
; If input was invalid for any reason then we display error message and ask for new input
; --------------------------
_invalidInput:
	mDisplayString [EBP + 20]					; Display one-size fits all error message
	call CrLf
	JMP	_getNewString
ReadVal ENDP


; ---------------------------------------------------------------------------------
; Name: WriteVal
; 
; Converts a numeric SDWORD value to a string of ASCII digits and then displays that
; string using the mDisplayString macro
;
; Preconditions: [EBP + 12] is a BYTE array with a length of at least 11. [EBP + 8] is an
;					SDWORD value (input parameter).
;
; Postconditions: None
;
; Receives: 
;		[EBP + 12]		= Reference to array that can hold string representation of SDWORD
;		[EBP + 8]		= A valid SDWORD that we want to convert and display as string
;
; Returns: None
; ---------------------------------------------------------------------------------
WriteVal PROC
; --------------------------
; Build up stack frame, save registers, and set our destination, value, and loop register
; --------------------------
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD
	MOV		EDI, [EBP + 12]
	CLD											; Ensure we will be writing front to back (big digit first)
	MOV		EAX, [EBP + 8]						; EAX holds the value we want to convert
	MOV		ECX, 1
; --------------------------
; Check if the value we are converting is negative
; --------------------------
	CMP		EAX, 0
	JL		_makePositive
	JMP		_convertVal
_makePositive:
	neg		EAX
; --------------------------
; Convert the value to string representation
; --------------------------
; --------------------------
; Start by pushing each digit of the number to the stack
; --------------------------
_convertVal:
	MOV		EBX, 10
	CDQ
	IDIV	EBX
	CMP		EAX, 0
	JE		_lastDigit
	ADD		EDX, 48								; Adding 48 converts number to ASCII representation
	PUSH	EDX									; Each time we save a digit from our number, we add 1 to ECX
	INC		ECX
	JMP		_convertVal
_lastDigit:
	ADD		EDX, 48								; We set the last digit to 48, which is ASCII 0 (terminates string)
	PUSH	EDX
; --------------------------
; If the number is negative, place '-' sign on stack
; --------------------------
	MOV		EAX, [EBP + 8]						; original value still at [ENP + 8]
	CMP		EAX, 0
	JL		_negativeOutput
	XOR		EAX, EAX
	JMP		_storeString
_negativeOutput:
	PUSH	45									; ASCII 45 is negative sign ('-')
	INC		ECX									; Another value to remove from stack
	XOR		EAX, EAX
	JMP		_storeString
; --------------------------
; We tear down stack and build up string representation at [EBP + 12] (EDI)
; --------------------------
_storeString:
	POP		EAX
	STOSB
	LOOP	_storeString
; --------------------------
; Once loop ends, string is complete and can be displayed
; --------------------------
	mDisplayString [EBP + 12]
; --------------------------
; Clean up stack frame and return
; --------------------------
	POPAD
	POP		EBP
	RET		8									; We passed 2, 4 BYTE parameters so we use RET 8
WriteVal ENDP


; ---------------------------------------------------------------------------------
; Name: GetAllInputs
; 
; Overarching procedure that fills an array of SDWORDS with numeric representations of strings
; entered by a user. Repeats the ReadVal procedure to validate and obtain numeric values before
; storing them in array ([EBP + 8]).
;
; Preconditions: [EBP + 12] is equal to the LENGTHOF [EBP + 8] (We cannot get more inputs then
;					we can store). [EBP + 16] is equal to 11 when working with DWORD/SDWORD.
;					[EBP + 16] is equal to LENGTHOF [EBP + 20] (We cannot take input that is
;					longer than we can store). [EBP + 24] and [EBP + 28] are 0 terminated.
;					ReadVal procedure is available.
;
; Postconditions: [EBP + 8] is now full with SDWORDs that have been entered by the user and
;					validated.
;
; Receives: 
;		[EBP + 36]		= reference to DWORD holding the number of characters entered after mGetString
;		[EBP + 32]		= reference to single SDWORD for storing numeric version of user input
;		[EBP + 28]		= reference to string that tells user of Error
;		[EBP + 24]		= reference to string that prompts user for input
;		[EBP + 20]		= reference to array that can hold user input
;		[EBP + 16]		= Value representing maximum length of input string
;		[EBP + 12]		= Value representing number of inputs we will get from user
;		[EBP + 8]		= Reference to an empty array of SDWORDs, stores valid inputs
;
; Returns: 
;		[EBP + 8]		= Reference to an array of valid SDWORDs that were entered by user
; ---------------------------------------------------------------------------------
GetAllInputs PROC
; --------------------------
; Build up stack frame, set up EDI to store values, and save registers
; --------------------------
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD
	MOV		EDI, [EBP + 8]				; Move our destination register to our array of SDWORDs
	MOV		ESI, [EBP + 32]				; Move our source register to SDWORD output of ReadVal procedure
; --------------------------
; Use loop to get all the values from the user, using ReadVal procedure
; --------------------------
	MOV		ECX, [EBP + 12]				; loop repeats for each value we need from user
_getUserInput:
	PUSH	[EBP + 36]
	PUSH	[EBP + 32]
	PUSH	[EBP + 28]
	PUSH	[EBP + 24]
	PUSH	[EBP + 20]
	PUSH	[EBP + 16]
	CALL	ReadVal						; continues until valid input in [EBP + 32]
	MOV		EAX, [ESI]
	MOV		[EDI], EAX					; during each iteration, transfers single valid SDWORD output from ReadVal into array
	ADD		EDI, 4
	LOOP	_getUserInput
; --------------------------
; Clean up stack frame
; --------------------------
	POPAD
	POP		EBP
	RET		28							; We passsed 7 DWORD parameters so we use RET 28		
GetAllInputs ENDP

	
; ---------------------------------------------------------------------------------
; Name: DisplayAllInputs
; 
; Displays all the SDWORDs in an array of SDWORDs by converting them to a string representation
; and using the mWriteVal Macro. Uses commas and spaces to display the values as 
; comma-seperated-values.
;
; Preconditions: [EBP + 12] is equal to the length of [EBP + 8]. [EBP + 8] is an array of 
;					SDWORDs.
;
; Postconditions: [EBP + 16] now holds the string representation of the last SDWORD from
;					[EBP + 8]. This is the last valid input entered by the user. 
;
; Receives: 
;		[EBP + 24]		= Reference to BYTE array with comma character
;		[EBP + 20]		= Reference to BYTE array with space character
;		[EBP + 16]		= Reference to array that can hold string representation of SDWORD
;		[EBP + 12]		= Value representing number of inputs we will get from [EBP + 8]
;		[EBP + 8]		= Reference to an array of valid SDWORDs to be displayed
;
; Returns:
;		[EBP + 16]		= Reference to array holding a string representation of the last SDWORD in [EBP + 8]
; ---------------------------------------------------------------------------------
DisplayAllInputs PROC
; --------------------------
; Build up stack frame and set our source/destination registers and loop counter
; --------------------------
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD
	MOV		ESI, [EBP + 8]					; set source register to reference SDWORD array
	MOV		ECX, [EBP + 12]					; set loop counter to length of array
	MOV		EDI, [EBP + 16]
; --------------------------
; Use WriteVal and formatting to display all values in our SDWORD array
; --------------------------
_displayinput:
	MOV		EAX, [ESI]
	MOV		EBX, 0
	MOV		[EDI], EBX						; clear any values in memory location that will hold our string representation
	MOV		[EDI + 4], EBX
	MOV		[EDI + 8], EBX
	PUSH	EDI
	PUSH	EAX
	CALL	WriteVal						; converts number in EAX to string and displays it using WriteString
	CMP		ECX, 1
	JE		_next
_add_formatting:
	mDisplayString [EBP + 24]
	mDisplayString [EBP + 20]
_next:
	ADD		ESI, 4
	LOOP	_displayInput
	POPAD
	POP		EBP
	RET		20								; We passed 5, 4 BYTE parameters so we use RET 20
DisplayAllInputs ENDP

END main