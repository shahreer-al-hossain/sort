.data

.balign 4
pattern: .asciz "%14[^\n]%*c"

.balign 4
input: .asciz "Enter your input file: "

.balign 4
readmode: .asciz "rb"


.balign 4
writefile: .asciz "output.txt"


.balign 4
writemode: .asciz "w"


.balign 4
return: .word 0


.balign 4
scanformat: .asciz "%li"


.balign 4
printformat: .asciz "%li\n"


.balign 32
a: .space 4096

.balign 4
	filename: .space 16
.text

.global main
.global fopen
.global fprintf
.global fclose
.global fscanf
.global printf
.global feof
.global scanf

main:
        ldr r1, =return
        str lr, [r1]

	ldr r0, =input
	bl printf

	ldr r0, addr_of_pattern
	ldr r1, addr_of_filename
	bl scanf

	ldr r0, addr_of_filename
        

        ldr r1, =readmode
        bl fopen
	
        mov r4, r0

        mov r5, #0
        ldr r6, =a
	

loop:
	mov r0, r4
	bl feof
	cmp r0, #0
	bne sort
        mov r0, r4
        ldr r1, =scanformat
        mov r2, r6
        bl fscanf
	
	
        add r5, r5, #4
        add r6, r6, #4
        b loop

sort:
    
    SUB r9, r5, #4 /* stores length of array */
    mov r5,#0  /*array parser for first loop*/
    mov r6, #0  /* #stores index of minimum*/
    mov r7, #0 /* #temp*/
    mov r8, #0 /*# array parser for second loop*/
    ldr r10, =a /*# the array*/
    mov r11, #0 /*#used to obtain offset for min*/
    mov r12, #0 /*# used to obtain offset for second parser access*/


loop3:
    cmp r5, r9 /*# check if first parser reached end of array*/
    beq write /* #if it did array is sorted write it to file*/
    mov r6, r5 /*#set the min index to the current position*/
    mov r8, r6 /*#set the second parser to where first parser is at*/
    b loop4 /*#start looking for min in this subarray*/

loop4:
    cmp r8, r9 /* #if reached end of list min is found*/
    beq increment /* #get out of this loop and increment 1st parser**/

 
    ADD r7, r10, r6 /* adds offset to r10 address storing it in r7 */
    ldr r11,  [r7] /* loads value of min in r11 */
  
    ADD r7, r10, r8 /* adds offset to r10 address storing in r7 */
    ldr r12, [r7]  /*  loads value of second parse into r12 */
 
    cmp  r11, r12 /* #compare current min to the current position of 2nd parser !!!!!*/
    
    
    movgt r6, r8 /*# set new min to current position of second parser */
    add r8, r8, #4 /*increment second parser*/

 
    b loop4 /*repeat */

increment:
    ADD r11, r10, r5 /* adds offset to r10 address stored in r11*/
    ldr r8, [r11] /* loads value in memory address in r11 to r8*/
    ADD r12, r10, r6 /*ads offset to r10 address stored in r12 */
    ldr r7, [r12] /* loads value in memory address in r12 to r7 */
    

    
 
    str r8, [r12] /* # stores value of first parser where min was !!!!!*/
    str r7, [r11] /*# store value of min where first parser was !!!!!*/

    add r5, r5, #4 /*#increment the first parser*/
    b loop3 /*#go to loop1*/


write:
        mov r0, r4
        bl fclose
        ldr r0, =writefile
        ldr r1, =writemode
        bl fopen
        mov r4, r0
        mov r5, #0
        ldr r6, =a

loop2:
        cmp r5, r9
        beq end
        mov r0, r4
        ldr r1, =printformat
        ldr r2, [r6]
        bl fprintf
        add r5, r5, #4
        add r6, r6, #4
        b loop2

end:
        mov r0, r4
        bl fclose
        ldr lr, =return
        ldr lr, [lr]
        bx lr


addr_of_pattern: .word pattern
addr_of_filename: .word filename
