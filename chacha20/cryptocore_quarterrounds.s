.syntax unified
.cpu cortex-m4

.global cryptocore_quarterrounds: 
.type cryptocore_quarterrounds, %function

cryptocore_quarterrounds: @(
                        @unsigned char *out,
                        @const unsigned char *in,
                        @const unsigned char *k,
                        @const unsigned char *c,
                    @)
    @R0 = out
    @R1 = in
    @R2 = k
    @R3 = c
    
    PUSH {R4-R12}
	@Approach is as follows: We load R1 and R3, and store them in R0. We keep them in R0 to be modified by the quarterrounds.
	@We now load R2 completely, and keep them in registers R5-R12.
	@This means that we will not have to load anything concerning R2 from memory anymore, since we keep them in R5-R12.
	@During the quarterrounds we will also store the modifications of these values in their registers R5-R12.
	@This greatly reduces memory access. By doing this we save (80 * 2) = 160 memory loads, and (80 * 2) = 160 memory stores. 
	
	@We will also push R1 and R2 to the stack so we can use those during the quarterrounds. We push them to the stack instead
	@of overwriting them because we will need their unscrambled values to add to the scrambled values.

	@R4 is used for the counter
	@R3 is completely unchanged

	@In the end we store all modified values in R5-R12 in R0.
	@We then pop R1 and R2 from the stack to access their unscrambled values.
	@We now add all values from R0 to their respective unscrambled value in R1-R3
	
    @Load and store@ R1 and R3
    LDM R3, {R4, R5, R6, R7}
    LDR R8, [R1, #8]
    LDR R9, [R1, #12]
    LDR R10, [R1, #0]
    LDR R11, [R1, #4]

    STR R4, [R0, #0]
    STR R5, [R0, #4]
    STR R6, [R0, #8]
    STR R7, [R0, #12]
    STR R8, [R0, #48]
    STR R9, [R0, #52]
    STR R10, [R0, #56]
    STR R11, [R0, #60]

    LDM R2, {R5-R12}

    PUSH {R1, R2}

    MOV R4, #10

quarterrounds:
    CMP R4, #0
    BEQ end

    @Load the values from R0
    LDR R1, [R0, #0]
	LDR R2, [R0, #48]

	@BEGIN quarterround
	ADD R1, R5
	EOR R2, R1
	ROR R2, #16

	ADD R9, R2
	EOR R5, R9
	ROR R5, #20

	ADD R1, R5
	EOR R2, R1
	ROR R2, #24

	ADD R9, R2
	EOR R5, R9
	ROR R5, #25
	@END quarterround
	
	@Store the changed values in R0
	STR R1, [R0, #0]
	STR R2, [R0, #48]

    @===== Quarterround 2 =====
	LDR R1, [R0, #4]
	LDR R2, [R0, #52]

	@BEGIN quarterround
	ADD R1, R6
	EOR R2, R1
	ROR R2, #16

	ADD R10, R2
	EOR R6, R10
	ROR R6, #20

	ADD R1, R6
	EOR R2, R1
	ROR R2, #24

	ADD R10, R2
	EOR R6, R10
	ROR R6, #25
	@END quarterround
	
	STR R1, [R0, #4]
	STR R2, [R0, #52]

    @===== Quarterround 3 =====
	LDR R1, [R0, #8]
	LDR R2, [R0, #56]

	@BEGIN quarterround
	ADD R1, R7
	EOR R2, R1
	ROR R2, #16

	ADD R11, R2
	EOR R7, R11
	ROR R7, #20

	ADD R1, R7
	EOR R2, R1
	ROR R2, #24

	ADD R11, R2
	EOR R7, R11
	ROR R7, #25
	@END quarterround
	
	STR R1, [R0, #8]
	STR R2, [R0, #56]

    @===== Quarterround 4 =====
	LDR R1, [R0, #12]
	LDR R2, [R0, #60]

	@BEGIN quarterround
	ADD R1, R8
	EOR R2, R1
	ROR R2, #16

	ADD R12, R2
	EOR R8, R12
	ROR R8, #20

	ADD R1, R8
	EOR R2, R1
	ROR R2, #24

	ADD R12, R2
	EOR R8, R12
	ROR R8, #25
	@END quarterround
	
	STR R1, [R0, #12]
	STR R2, [R0, #60]
    @[END OF THE COLUMN QUARTER ROUNDS]
    @[START OF THE DIAGONAL QUARTER ROUNDS]
    @===== Quarterround 5 =====
	LDR R1, [R0, #0]
	LDR R2, [R0, #60]

	@BEGIN quarterround
	ADD R1, R6
	EOR R2, R1
	ROR R2, #16

	ADD R11, R2
	EOR R6, R11
	ROR R6, #20

	ADD R1, R6
	EOR R2, R1
	ROR R2, #24

	ADD R11, R2
	EOR R6, R11
	ROR R6, #25
	@END quarterround
	
	STR R1, [R0, #0]
	STR R2, [R0, #60]

    @===== Quarterround 6 =====
	LDR R1, [R0, #4]
	LDR R2, [R0, #48]

	@BEGIN quarterround
	ADD R1, R7
	EOR R2, R1
	ROR R2, #16

	ADD R12, R2
	EOR R7, R12
	ROR R7, #20

	ADD R1, R7
	EOR R2, R1
	ROR R2, #24

	ADD R12, R2
	EOR R7, R12
	ROR R7, #25
	@END quarterround
	
	STR R1, [R0, #4]
	STR R2, [R0, #48]

    @===== Quarterround 7 =====
	LDR R1, [R0, #8]
	LDR R2, [R0, #52]

	@BEGIN quarterround
	ADD R1, R8
	EOR R2, R1
	ROR R2, #16

	ADD R9, R2
	EOR R8, R9
	ROR R8, #20

	ADD R1, R8
	EOR R2, R1
	ROR R2, #24

	ADD R9, R2
	EOR R8, R9
	ROR R8, #25
	@END quarterround
	
	STR R1, [R0, #8]
	STR R2, [R0, #52]

    @===== Quarterround 8 =====
	LDR R1, [R0, #12]
	LDR R2, [R0, #56]

	@BEGIN quarterround
	ADD R1, R5
	EOR R2, R1
	ROR R2, #16

	ADD R10, R2
	EOR R5, R10
	ROR R5, #20

	ADD R1, R5
	EOR R2, R1
	ROR R2, #24

	ADD R10, R2
	EOR R5, R10
	ROR R5, #25
	@END quarterround
	
	STR R1, [R0, #12]
	STR R2, [R0, #56]
    @[END OF THE DIAGONAL QUARTER ROUNDS]
    SUB R4, #1
    B quarterrounds

end:
    @Store all modified values from k, in R0.
    STR R5, [R0, #16]
    STR R6, [R0, #20]
    STR R7, [R0, #24]
    STR R8, [R0, #28]
    STR R9, [R0, #32]
    STR R10, [R0, #36]
    STR R11, [R0, #40]
    STR R12, [R0, #44]

    POP {R1, R2}
	@Adding first 4 values
	LDM R3!, {R4, R5, R6, R7}
	LDM R0, {R8, R9, R10, R11}

	ADD R8, R4
	ADD R9, R5
	ADD R10, R6
	ADD R11, R7

	STM R0!, {R8, R9, R10, R11}

	@Adding second 4 values
	LDM R2!, {R4, R5, R6, R7}
	LDM R0, {R8, R9, R10, R11}

	ADD R8, R4
	ADD R9, R5
	ADD R10, R6
	ADD R11, R7

	STM R0!, {R8, R9, R10, R11}

	@Adding third 4 values
	LDM R2!, {R4, R5, R6, R7}
	LDM R0, {R8, R9, R10, R11}

	ADD R8, R4
	ADD R9, R5
	ADD R10, R6
	ADD R11, R7

	STM R0!, {R8, R9, R10, R11}

	@Adding fourth 4 values
	LDR R4, [R1, #8]
    LDR R5, [R1, #12]
    LDR R6, [R1, #0]
    LDR R7, [R1, #4]
	LDM R0, {R8, R9, R10, R11}

	ADD R8, R4
	ADD R9, R5
	ADD R10, R6
	ADD R11, R7

	STM R0!, {R8, R9, R10, R11}
	
    POP {R4-R12}
    MOV R0, #0
    BX LR