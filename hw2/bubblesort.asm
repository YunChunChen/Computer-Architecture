# [Author]      Yun-Chun (Jonhhy) Chen
# [Affiliation] Department of Electrical Engineering, National Taiwan University
# [Language]    Assembly code
# [Function]    Perform bubble sort algorithm
# [Description] This code performs bubble sort algorithm which takes in any number of inputs.
#               To launch this program, users are adviced to install QtSpim compiler since 
#               the code in written under MIPS environment.
# [Usage]       When the program is launched, the console will prompt with a message that
#               user has to enter the number of inputs in the very beginning. Later on,
#               enter the numbers sequentially. However, each input number needs to be separated
#               by an "enter" or a "return" key. Space key is not supported by QtSpim compiler.
#               The result will be printed afterwards.

       .globl main
main: 
       # print msg1, "How many numbers of input?"
       li    $v0, 4           # print_string syscall code = 4
       la    $a0, msg1        # store message in $a0
       syscall

       # read the input from user
       li    $v0, 5           # read_int syscall code = 5
       syscall

       # store the number of inputs
       add   $s0, $v0, 0      # store number of inputs in $s0

       # memory allocation, address will be in $v0
       mul   $t0, $s0, 4      # multiply $s0 by 4 and store into $t0
       addi  $a0, $t0, 0      # allocate "$s0" memory
       li    $v0, 9           # sbrk
       syscall

       # store the address of the memory in $s1
       addi  $s1, $v0, 0      # store the address in $s1

       # print msg2, "Enter the numbers"
       li    $v0, 4           # print_string syscall code = 4
       la    $a0, msg2        # store message in $a0
       syscall

       # parameter initialization
       li    $t0, 0           # inner loop index
       li    $t1, 0           # outer loop index
       li    $s2, 0           # input index, offset use
       li    $s3, 0           # input index, counting use

input: 
       # read the input from user
       li    $v0, 5           # read_int syscall code = 5
       syscall

       add   $s4, $s2, $s1    # $s4 = $s2(offset) + $s1(base address)
       sw    $v0, 0($s4)      # store word from $v0 to 0($s4)
       addi  $s2, $s2, 4      # increment $s2(offset index) by 4
       addi  $s3, $s3, 1      # increment $s3(counting index) by 1
       
       bne   $s3, $s0, input  # if $s3 != $s0, read input from user

       li    $s2, 0           # set $s2(offset index) to 0
       li    $s3, 0           # set $s3(counting index) to 0
       li    $t8, 1           # set $t8 to 1

       # if only 1 input, go to result stage directly
       beq   $s0, $t8, result

       addi  $t0, $t1, 1      # $t0(inner loop index) = $t1(output loop index) + 1, "j = i+1"

bubblesort:
       mul   $t2, $t0, 4      # multiply $t0 by 4 and store the value to $t2 (get offset) "case: j"
       mul   $t3, $t1, 4      # multiply $t1 b7 4 and store the value to $t3 (get offset) "case: i"

       add   $t4, $s1, $t2    # $t4("j-th element") = $s1(base address) + $t2(offset of "j-th element")
       add   $t5, $s1, $t3    # $t5("i-th element") = $s1(base address) + $t3(offset of "i-th element")

       lw    $t6, 0($t4)      # load word from 0($t4) ("j-th element") to $t6
       lw    $t7, 0($t5)      # load word from 0($t5) ("i-th element") to $t7

       # if $t7 > $t6, swap two numbers
       bgt   $t7, $t6, swap

       j     inner

swap:  
       sw    $t7, 0($t4)      # store word from $t7 to 0($t4)
       sw    $t6, 0($t5)      # store word from $t6 to 0($t5)
       j     inner            # jump to inner stage

inner:
       addi  $t0, $t0, 1      # $t0(inner loop index, "j") = $t0(inner loop index, "j") + 1 
       beq   $t0, $s0, outer  # if $t0(inner loop index) == $s0(number of inputs), jump to outer stage
       j     bubblesort       # jump to bubblesort

outer:
       addi  $t1, $t1, 1      # increment $t1(outer loop index by 1, "i = i+1")
       beq   $t1, $s0, result # if $t1(outer loop index, "i") == $s0(number of inputs), jump to result stage
       add   $t0, $t1, 0      # move $t1 to $t0                "j = i"
       addi  $t0, $t0, 1      # add 1 to $t0(inner loop index) "j = i+1"
       beq   $t0, $s0, result # if $t0(inner loop index, "j") == $s0(number of inputs), jump to result stage
       j     bubblesort       # jump to bubblesort stage

result:
       # print results
       li    $v0, 4
       la    $a0, msg3
       syscall

       li    $s2, 0           # set $s2(offset) to 0
       li    $s3, 0           # set $s3(loop index) to 0
       j     output

output:
       # print the output
       li    $v0, 1           # print_int syscall code = 1
       add   $s4, $s2, $s1    # $s4 = $s2(offset) + $s1(base address)
       lw    $a0, 0($s4)      # load word from 0($s4) to $a0
       syscall                # print_int inside $a0

       # print space 
       li    $v0, 4
       la    $a0, msg4
       syscall

       addi  $s2, $s2, 4      # increment $s2(offset) by 4
       addi  $s3, $s3, 1      # increment $s3(loop index) by 1

       bne   $s3, $s0, output # if $s3 != $s0, print integer  

       # print new line and terminate the program
       li    $v0, 4           # print new line
       la    $a0, msg5        # new line
       syscall

	li    $v0, 10 	      # termination   
       syscall

       .data
msg1:  .asciiz"How many numbers do you want to enter ?\n"
msg2:  .asciiz"\nEnter the number(s):\n"
msg3:  .asciiz"\nResult:\n"
msg4:  .asciiz" "
msg5:  .asciiz"\n\n"
