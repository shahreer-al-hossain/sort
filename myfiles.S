.data

.balign 4
        pattern: .asciz "%14[^\n]%*c"
.balign 4
        input: .asciz "Please enter the name of the input file: "
.balign 4
        finished: .asciz "\nThe file is successfully sorted. Please check the contents of output.txt.\n\n"
.balign 4
        badopenmsg: .asciz "This file cannot be opended. Please check if the name of the file in entered correctly and if the file exists in the same directory.\n"
.balign 4
	tooLarge: .asciz "This file has more than 1024 integers. Please reduce the size of your list.\n"
.balign 4
        readmode: .asciz "rb"
.balign 4
        writefile: .asciz "output.txt"
.balign 4
        writemode: .asciz "wb"
.balign 4
        return: .word 0
.balign 4
        scanformat: .asciz "%li"
.balign 4
        printformat: .asciz "%li\n"
.balign 32
        array: .space 4096
.balign 4
        filename: .space 32
.balign 4
        filepointer: .word 4

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

// Storing the link register to call it back at the end
        ldr r1, =return
        str lr, [r1]

        ldr r0, =input
        bl printf
	

// Scanning in the name of the input file
        ldr r0, addr_of_pattern
        ldr r1, addr_of_filename
        bl scanf

// Opening the input file using the fopen C function
        ldr r0, addr_of_filename
        ldr r1, =readmode
        bl fopen
        mov r4, r0 /* File Pointer is returned by the fopen C function to refister r0 */
        ldr r1, =filepointer
        str r0, [r1]

// Checking if the file is openable
        ldr r0, =filepointer
        ldr r0, [r0]
        cmp r0, #0       /* If the file pointer is null then exit the program */
        beq badopen

// Initialize the readloop counter (register r5)  
        mov r5, #0
        ldr r6, =array

// A while loop is used to read the contents of the input file. 
// The fscanf function is used to read the file line by line.
// The feof C function reutrns a non-zero number to register r0 when the end of the file is reached.
// The return code of feof is used as the loop condition for the while loop.  
readloop:
        mov r0, r4
        bl feof
        cmp r0, #0
        bne sort
	cmp r5, #4096
	bgt SizeError
        mov r0, r4
        ldr r1, =scanformat
        mov r2, r6
        bl fscanf
        add r5, r5, #4
        add r6, r6, #4
        b readloop

// A selection sort is used to sort the contents of the array that were read from the input file.
// The sorting algorithm sorts positive and negative integers in an ascending order. 
sort:
    SUB r9, r5, #4      /* stores length of array */
    mov r5, #0          /* array parser for first loop */
    mov r6, #0          /* stores index of minimum */
    mov r7, #0          /* temp */
    mov r8, #0          /* array parser for second loop */
    ldr r10, =array     /* loading the address of the array */
    mov r11, #0         /* used to obtain offset for min */
    mov r12, #0         /* used to obtain offset for second parser access */

outerloop:
    cmp r5, r9          /* check if first parser reached end of array */
    beq write           /* if it did the array is sorted and braches to write subroutine */
    mov r6, r5          /* set the min index to the current position */
    mov r8, r6          /* set the second parser to where first parser is at */
    b innerloop         /* start looking for min in this subarray */

innerloop:
    cmp r8, r9          /* if the loop reaches end of list, then min is found */
    beq increment       /* get out of this loop and increment 1st parser */

    ADD r7, r10, r6     /* adds offset to r10 address storing it in r7 */
    ldr r11,  [r7]      /* loads value of min in r11 */

    ADD r7, r10, r8     /* adds offset to r10 address storing it in r7 */
    ldr r12, [r7]       /* loads value of second parse into r12 */

    cmp  r11, r12       /* compare current min to the current position of 2nd parser */
    movgt r6, r8        /* set new min to current position of 2nd parser */
                        /* if value of 2nd parser is samller than min */
    add r8, r8, #4      /* increment second parser */
    b innerloop         /* repeat */

increment:
    ADD r11, r10, r5    /* adds offset to r10 address stored in r11 */
    ldr r8, [r11]       /* loads value in memory address in r11 to r8 */
    ADD r12, r10, r6    /* adds offset to r10 address stored in r12 */
    ldr r7, [r12]       /* loads value in memory address in r12 to r7 */
    str r8, [r12]       /* stores value of first parser where min was */
    str r7, [r11]       /* store value of min where first parser was */
    add r5, r5, #4      /* increment the first parser */
    b outerloop         /* branch to outerloop1 instructions */

// The input file is closed is using fclose C function.
// A new output file is created, and it is opened using the fopen C function.
// The file pointer of the output file is returned to register r0. 
write:
        mov r0, r4
        bl fclose

        ldr r0, =writefile
        ldr r1, =writemode
        bl fopen
        mov r4, r0
        mov r5, #0
        ldr r6, =array

// A for loop is used to write the contents of the array to the output file.
// The fprintf C function is used to write the contents line by line.
// When the loop counter reaches the size of the input file, the loop terminates.
writeloop:
        cmp r5, r9
        beq end
        mov r0, r4
        ldr r1, =printformat
        ldr r2, [r6]
        bl fprintf
        add r5, r5, #4
        add r6, r6, #4
        b writeloop

// The link register is restored.
// The output file is closed using the fclose C function. 
end:
        mov r0, r4
        bl fclose
        ldr r0, =finished
        bl printf
        ldr lr, =return
        ldr lr, [lr]
        bx lr

badopen:
        ldr r0, =badopenmsg
        bl printf
        ldr lr, =return
        ldr lr, [lr]
        bx lr

SizeError:
        ldr r0, =tooLarge
        bl printf
        ldr lr, =return
        ldr lr, [lr]
        bx lr
	
addr_of_pattern: .word pattern
addr_of_filename: .word filename
