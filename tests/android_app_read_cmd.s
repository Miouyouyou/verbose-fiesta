.syntax unified
.data
 
 android_app_msgread_off    = 64
 android_app_msgread_value  = 1
 syscall_read_good_result   = 1
 syscall_read_failed_result = 0

/* Pad the false structure with 0 until the msgread field */
.Lspecial_mark:
	.int 0xcafecafe
android_app:
 .skip android_app_msgread_off, 0
android_app_msgread_addr:
 .int android_app_msgread_value

syscall_read_next_result:
 .int 0

messages:
success:
success_correct_msgread_value:
  .asciz "File descriptor %d (%d) correct\n"
errors:
error_unexpected_msgread_value:
  .asciz "Unexpected file descriptor ! %d (%d)\n"

.text

// r0: msgread (FD)
// r1: read store address
// r2: read size
.globl syscall_read
.arm
syscall_read:
	push {lr}
	ldr r2, =android_app_msgread_addr
	ldr r2, [r2]
	mov r5, r1 // r5 <- store address
	mov r1, r0 // r1 <- msgread (FD)
	ldr r0, =success_correct_msgread_value
	cmp r1, r2
	ldrne r0, =error_unexpected_msgread_value
	bl printf
.LSyscallReadEnd:
	pop {lr}
	bx lr

.globl syscall_exit
.arm
syscall_exit:
	mov r0, #0
	mov r7, #1
	svc 0

.globl test_android_app_read_cmd
.arm
test_android_app_read_cmd:
	ldr r0, =android_app
	bl android_app_read_cmd
	b syscall_exit
