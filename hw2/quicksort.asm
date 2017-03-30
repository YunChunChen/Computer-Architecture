# Quick sort in assembly code

       .text

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
       li    $s2, 0           # set $s2(offset index) to 0
       li    $s3, 0           # set $s3(counting index) to 0

input: 
       # read the input from user
       li    $v0, 5           # read_int syscall code = 5
       syscall

       add   $s4, $s2, $s1    # $s4 = $s2(offset) + $s1(base address)
       sw    $v0, 0($s4)      # store word from $v0 to 0($s4)
       addi  $s2, $s2, 4      # increment $s2(offset index) by 4
       addi  $s3, $s3, 1      # increment $s3(counting index) by 1
       
       bne   $s3, $s0, input  # if $s3(counting index) != $s0(number of inputs), read input from user

       li    $t8, 1           # set $t8 to 1, for comparison use

       # if only 1 input, go to result stage directly
       beq   $s0, $t8, result

       li    $s2, 0           # left index of quick sort
       addi  $s3, $s0, -1     # $s5(right index) = $s0(number of inputs) - 1
       addi  $s4, $s2, -1     # $s4("i") = left - 1
       addi  $s5, $s3, 1      # $s5("j") = right + 1

       jal   quicksort        # jump to quicksort stage, the program counter will be stored into $ra

       j     result           # jump to the result stage

quicksort:
       
       addi  $sp, $sp, -20    # decrement $sp(stack pointer) by 20
       sw    $s2, 0($sp)      # store $s2 left
       sw    $s3, 4($sp)      # store $s3 right
       sw    $s4, 8($sp)      # store $s4 i
       sw    $s5, 12($sp)     # store $s5 j
       sw    $ra, 16($sp)     # store $ra return address

       # calculate the pivot
       add   $t0, $s2, $s3    
       div   $t0, $t0, 2      
       mul   $t0, $t0, 4      
       add   $t0, $t0, $s1    
       lw    $t0, 0($t0)      # $t0 : pivot

       bge   $s4, $s5, rec_1  # if $s4("i") >= $s5("j"), recursive_1

       j     loop_i

quicksort_1:

       addi  $sp, $sp, -28    # decrement $sp(stack pointer) by 20
       sw    $s2, 0($sp)      # store $s2 left
       sw    $s3, 4($sp)      # store $s3 right
       sw    $s4, 8($sp)      # store $s4 i
       sw    $s5, 12($sp)     # store $s5 j
       sw    $ra, 16($sp)     # store $ra return address
       sw    $a2, 20($sp)     # store $a2, previous left
       sw    $a3, 24($sp)     # store $a3, previous right

       bge   $s2, $s3, return # if $s2(left index) >= $s5(right index), go to return stage

       # calculate the pivot
       add   $t0, $s2, $s3    
       div   $t0, $t0, 2      
       mul   $t0, $t0, 4      
       add   $t0, $t0, $s1    
       lw    $t0, 0($t0)      # $t0 : pivot
       
       addi  $s4, $s2, -1     # i = left - 1
       addi  $s5, $s3, 1      # j = right + 1
       
       bge   $s4, $s5, rec_1  # if $s4("i") > $s5("j"), recursive_1

loop_i:
       addi  $s4, $s4, 1      # i += 1
       mul   $t1, $s4, 4      
       add   $t1, $t1, $s1    # $t1(a[i]) address
       lw    $t2, 0($t1)      # $t2(a[i]) data
       blt   $t2, $t0, loop_i # if $t2(a[i]) < $t0(pivot), go to loop_i
       
loop_j:
       addi  $s5, $s5, -1     # j -= 1
       mul   $t3, $s5, 4      
       add   $t3, $t3, $s1    # $t3(a[j]) address
       lw    $t4, 0($t3)      # $t4(a[j]) data
       bgt   $t4, $t0, loop_j # if $t4(a[j]) > $t0(pivot), go to loop_j
       blt   $s4, $s5, swap   # if $s4("i") < $s5("j"), go to swap       

rec_1:
       move  $a3, $s3         # copy right for later use
       addi  $s3, $s4, -1     # right = i - 1
       move  $a2, $s2         # copy left for later use
       jal   quicksort_1      # quicksort(a, left, i-1), recursive call

rec_2:
       addi  $s2, $s5, 1      # right = j + 1
       move  $s3, $a3         # move previous right to $s3
       jal   quicksort_1      # quicksort(a, j+1, right), recursive call
       j     return           # jump to result stage

swap:
       sw    $t4, 0($t1)
       sw    $t2, 0($t3)
       j     loop_i           # jump back to loop_i 

return:
       lw    $s2, 0($sp)      # load left
       lw    $s3, 4($sp)      # load right
       lw    $s4, 8($sp)      # load i
       lw    $s5, 12($sp)     # load j
       lw    $ra, 16($sp)     # load return address
       lw    $a2, 20($sp)     # load previous left
       lw    $a3, 24($sp)     # load previous right

       addi  $sp, $sp, 28     # increment $sp(stack pointer) by 20
       jr    $ra              # return to the address stored in $ra


result:
       # print results
       li    $v0, 4
       la    $a0, msg3
       syscall

       li    $s2, 0           # set $s2(offset index) to 0
       li    $s3, 0           # set $s3(counting index) to 0

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

       addi  $s2, $s2, 4      # increment $s2(offset index) by 4
       addi  $s3, $s3, 1      # increment $s3(counting index) by 1

       bne   $s3, $s0, output # if $s3(counting index) != $s0(number of inputs), print integer  

	li    $v0, 10 	  # termination   
       syscall

       .data
msg1:  .asciiz"How many numbers do you want to enter ?\n"
msg2:  .asciiz"\nEnter the number(s):\n"
msg3:  .asciiz"\nResult:\n"
msg4:  .asciiz" "