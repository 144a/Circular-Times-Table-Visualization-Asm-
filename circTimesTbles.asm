_main:
	LD	HL,-1
	CALL	__frameset

	// Set loop equal to 0
LD	(IX+-1),0

	// Set num of dots to 75
	LD	A,75
	LD	(_dotnum),A

	// Set Radius to 200
	LD	A,200
	LD	(_radius),A

	// Set dot radius to 10
	LD	A,10
	LD	(_dotrad),A
	
	// Set an offset of 110 for 
//center of circle
	LD	A,110
	LD	(_offset),A

	// Set Pi equal to 3.14159265
	LD	BC,4788187
	LD	(_PI),BC
	LD	A,64
	LD	(_PI+3),A

	// Starting Graphics Routines
	// Compiled by MateosLeChuga
	CALL	_gfx_Begin
	
	// Screen Buffer
	LD	BC,1
	PUSH	BC
	CALL	_gfx_SetDraw
	POP	BC

	JR	L_2

// Set up for loop to wait
	// for a key press
	// Only reads on buffer frame 
L_3:	
	LD	C,(IX+-1)
	LD	B,0
	// Calls rotate subroutine and 
	// passes loop counter
PUSH	BC
	CALL	_rotate
	POP	BC
	
	// Swap screen with screen buffer
	CALL	_gfx_SwapDraw
	
	// Increase loop counter
	INC	(IX+-1)

	// Loop conditions, checks to see
	// Checks to see if loop counter is
	// Greater than 50 or a key is 
// pressed
	CALL	_os_GetCSC
	OR	A,A
	JR	Z,L_3
	LD	A,(IX+-1)
	CP	A,50
	JR	C,L_3
	
	// End Graphics for close
	CALL	_gfx_End
	
	// Return to beginning of loop
LD	SP,IX
	POP	IX
	RET
	
	// Rotate Subroutine
_rotate:
	LD	HL,-38
	CALL	__frameset
	
	// Clear the drawing buffer
	LD	BC,255
	PUSH	BC
	CALL	_gfx_FillScreen
	POP	BC
	
	// Set up circle info for 
	// subroutine call by dividing 
	// the radius in half
	LD	A,(_radius)
	UEXT	HL
	LD	L,A
	LD	A,(_offset)
	LD	BC,2
	CALL	__idivs
	PUSH	HL
	UEXT	HL
	LD	L,A
	PUSH	HL
	LD	A,(_offset)
	UEXT	HL
	LD	L,A
	PUSH	HL
	CALL	_gfx_Circle
	
// Store half of the radius
LD	A,(_radius)
	UEXT	HL
	LD	L,A
	POP	BC
	POP	BC
	POP	BC
	LD	BC,2
	CALL	__idivs
	LD	A,L
	LD	(_halfrad),A

// Set up another loop for drawing
// Should increment from 0 to total // # of dots
LD	(IX+-1),0
	JR	L_9

L_7:
OR	A,A

// Calculating Approximate 
// Dot Number Distance

// Multiply Pi by 2
SBC	HL,HL
	LD	E,64
	LD	BC,(_PI)
LD	A,(_PI+3)
	CALL	__fmul
LD	(IX+-34),A

// Divide that answer by total 
// number of dots
UEXT	HL
	LD	A,(_dotnum)
	LD	L,A
	LD	A,H
	LD	(IX+-37),BC
	LD	BC,HL
	CALL	__ultof
	LD	E,A
	LD	HL,BC
	LD	BC,(IX+-37)
	LD	A,(IX+-34)
	CALL	__fdiv

	// Store that answer
	LD	(_aproxDotNum),BC
LD	(_aproxDotNum+3),A

// Find the remainder of 
// multiplication

// Start with multiplying loop 
// conditional 
// with input number (or first loop 
// conditional)
	LD	BC,(IX+6)
	CALL	__stoiu
	LD	DE,HL
	LD	A,(IX+-1)
	UEXT	HL
	LD	L,A
	LD	BC,HL
	LD	HL,DE
	CALL	__imuls

	// Find the modulo of the answer with 
	// the total number of dots
	LD	DE,HL
	LD	A,(_dotnum)
	UEXT	HL
	LD	L,A
	LD	BC,HL
	LD	HL,DE
	CALL	__irems
	LD	BC,HL
	CALL	__itol
	CALL	__ltof

	// Store that answer for later
	LD	(_temp1),BC
	LD	(_temp1+3),A
	


// Calculate temporary value for 
// angle calculation

// Multiply temp value 1 by Pi
	LD	A,(_PI+3)
	LD	E,A
	LD	A,(_temp1+3)
	LD	HL,(_PI)
	CALL	__fmul
	
	// Add current dot number
	LD	H,A
	LD	A,(_aproxDotNum+3)
	LD	E,A
	LD	A,H
	LD	HL,(_aproxDotNum)
	CALL	__fadd

 	// Store value for later
	LD	(_temp2),BC


	// Calculate Angle 1

	// Setup temp value 2 for cos
	// subroutine
	LD	C,A
	LD	B,0
	PUSH	BC
	LD	(_temp2+3),A
	LD	BC,(_temp2)
	PUSH	BC
	LD	(IX+-38),A
	CALL	_cos

	// Pop sum from the stack
	LD	A,(IX+-38)
	POP	BC
	POP	BC
	LD	(IX+-28),HL
	UEXT	HL
	
	// Load halfrad into the A register
	// Setup multiplication
	LD	A,(_halfrad)
	LD	L,A
	LD	A,H
	LD	BC,HL
	CALL	__ultof
	LD	(IX+-29),E
	LD	E,A
	LD	HL,BC
	LD	BC,(IX+-28)
	LD	A,(IX+-29)
	CALL	__fmul
	LD	(IX+-30),A
	UEXT	HL

	// Set up addition of offset
	LD	A,(_offset)
	LD	L,A
	LD	A,H
	LD	(IX+-33),BC
	LD	BC,HL
	CALL	__ultof
	
	// Add offset to the current answer
	LD	E,A
	LD	HL,BC
	LD	BC,(IX+-33)
	LD	A,(IX+-30)
	CALL	__fadd

	// Store value for later use
	LD	(_angle1),BC
	LD	(_angle1+3),A


	// Calculate Angle 2

// Setup temp value 2 for sin
	// subroutine
LD	A,(_temp2+3)
	LD	C,A
	LD	B,0
	PUSH	BC
	LD	BC,(_temp2)
	PUSH	BC
	LD	(IX+-38),A
	CALL	_sin

	// Pop sum from the stack
	LD	A,(IX+-38)
	POP	BC
	POP	BC
	LD	(IX+-20),HL
	UEXT	HL
	
	// Load halfrad into the A register
	// Setup multiplication
	LD	A,(_halfrad)
	LD	L,A
	LD	A,H
	LD	BC,HL
	CALL	__ultof
	LD	(IX+-21),E
	LD	E,A
	LD	HL,BC
	LD	BC,(IX+-20)
	LD	A,(IX+-21)
	CALL	__fmul
	LD	(IX+-22),A
	UEXT	HL
	
// Set up addition of offset
	LD	A,(_offset)
	LD	L,A
	LD	A,H
	LD	(IX+-25),BC
	LD	BC,HL
	CALL	__ultof

	// Add offset to the current answer
	LD	E,A
	LD	HL,BC
	LD	BC,(IX+-25)
	LD	A,(IX+-22)
	CALL	__fadd
	
	// Store value for later use
	LD	(_angle2),BC
	LD	(_angle2+3)
	
	// Recalculate temp value 2
	// Setup multiplication of 
	// # dots with current loop counter
	UEXT	HL
	LD	L,(IX+-1)
	LD	A,H
	LD	BC,HL
	CALL	__ultof
	LD	E,A
	LD	HL,BC
	LD	BC,(_aproxDotNum)
	LD	A,(_aproxDotNum+3)
	CALL	__fmul
	
	// Add Pi to the total
	LD	H,A
	LD	A,(_PI+3)
	LD	E,A
	LD	A,H
	LD	HL,(_PI)
	CALL	__fadd

	// Store answer
	LD	(_temp2),BC
	

	// Calculate Angle 3
	
	// Setup temp value 2 for cos
	// subroutine 
	LD	C,A
	LD	B,0
	PUSH	BC
	LD	(_temp2+3),A
	LD	BC,(_temp2)
	PUSH	BC
	LD	(IX+-38),A
	CALL	_cos
	
	// Pop sum from the stack
	LD	A,(IX+-38)
	POP	BC
	POP	BC
	LD	(IX+-12),HL
	UEXT	HL

	// Load halfrad into the A register
	// Setup multiplication
	LD	A,(_halfrad)
	LD	L,A
	LD	A,H
	LD	BC,HL
	CALL	__ultof
	LD	(IX+-13),E
	LD	E,A
	LD	HL,BC
	LD	BC,(IX+-12)
	LD	A,(IX+-13)
	CALL	__fmul
	LD	(IX+-14),A
	UEXT	HL

	// Set up addition of offset
	LD	A,(_offset)
	LD	L,A
	LD	A,H
	LD	(IX+-17),BC
	LD	BC,HL
	CALL	__ultof

	// Add offset to the current answer
	LD	E,A
	LD	HL,BC
	LD	BC,(IX+-17)
	LD	A,(IX+-14)
	CALL	__fadd

	// Store value for later use
	LD	(_angle3),BC
	LD	(_angle3+3),A
	

	// Calculate Angle 4
	
	// Setup temp value 2 for sin
	// subroutine 
	LD	A,(_temp2+3)
	LD	C,A
	LD	B,0
	PUSH	BC
	LD	BC,(_temp2)
	PUSH	BC
	LD	(IX+-38),A
	CALL	_sin
	
	// Pop sum from the stack
	LD	A,(IX+-38)
	POP	BC
	POP	BC
	LD	(IX+-4),HL
	UEXT	HL

	// Load halfrad into the A register
	// Setup multiplication
	LD	A,(_halfrad)
	LD	L,A
	LD	A,H
	LD	BC,HL
	CALL	__ultof
	LD	(IX+-5),E
	LD	E,A
	LD	HL,BC
	LD	BC,(IX+-4)
	LD	A,(IX+-5)
	CALL	__fmul
	LD	(IX+-6),A
	UEXT	HL

	// Set up addition of offset
	LD	A,(_offset)
	LD	L,A
	LD	A,H
	LD	(IX+-9),BC
	LD	BC,HL
	CALL	__ultof

	// Add offset to the current answer
	LD	E,A
	LD	HL,BC
	LD	BC,(IX+-9)
	LD	A,(IX+-6)
	CALL	__fadd

	// Store value for later use
	LD	(_angle4),BC
	LD	(_angle4+3),A
	
	
// Set up Line Graphics Subroutine
	
// Push Angle 4 to the stack
CALL	__ftol
	PUSH	BC

	// Push Angle 3 to the stack
	LD	BC,(_angle3)
	LD	A,(_angle3+3)
	CALL	__ftol
	PUSH	BC
	
	// Push Angle 2 to the stack
LD	BC,(_angle2)
	LD	A,(_angle2+3)
	CALL	__ftol
	PUSH	BC
	
	// Push Angle 1 to the stack
	LD	BC,(_angle1)
	LD	A,(_angle1+3)
	CALL	__ftol
	PUSH	BC
	
	// Call Line Subroutine
	CALL	_gfx_Line
	
	// Clear the stack
POP	BC
	POP	BC
	POP	BC
	POP	BC
	INC	(IX+-1)

// Ending loop condition check	
L_9:	
	LD	A,(_dotnum)
	CP	A,(IX+-1)

	// If loop counter meets conditions.
	// Jump to L_7

	JR	NC,L_7
	LD	SP,IX
	POP	IX
	RET	

	
