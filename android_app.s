.syntax unified
.arm
.data

/* Structure offsets */
	.Landroid_app_userData=           0
	.Landroid_app_onAppCmd=           4
	.Landroid_app_onInputEvent=       8
	.Landroid_app_activity=           12
	.Landroid_app_config=             16
	.Landroid_app_looper=             20
	.Landroid_app_inputQueue=         24
	.Landroid_app_window=             28
	.Landroid_app_contentRect=        32
	.Landroid_app_activityState=      48
	.Landroid_app_destroyRequested=   52
	.Landroid_app_mutex=              56
	.Landroid_app_cond=               60
	.Landroid_app_msgread=            64
	.Landroid_app_msgwrite=           68
	.Landroid_app_thread=             72
	.Landroid_app_cmdPollSource=      76
	.Landroid_app_inputPollSource=    88
	.Landroid_app_running=            100
	.Landroid_app_stateSaved=         104
	.Landroid_app_destroyed=          108
	.Landroid_app_redrawNeeded=       112
	.Landroid_app_pendingInputQueue=  116
	.Landroid_app_pendingWindow=      120
	.Landroid_app_pendingContentRect= 124
	
	LOOPER_ID_MAIN= 1
	/**
	 * Looper data ID of events coming from the AInputQueue of the
	 * application's window, which is returned as an identifier from
	 * ALooper_pollOnce().  The data for this identifier is a pointer to an
	 * android_poll_source structure.  These can be read via the inputQueue
	 * object of android_app.
	 */
	LOOPER_ID_INPUT= 2
	/**
	 * Start of user-defined ALooper identifiers.
	 */
	LOOPER_ID_USER= 3
	NULL= 0

	syscall_read_val=3
	sizeof_cmd=1
	
.text
.thumb_func
.thumb
.globl android_app_read_cmd
/* Uses android_app->msgread only */
// r0 : struct android_app address
android_app_read_cmd:
	push {r5-r6, lr}
	// r0 : struct android_app *
	subs sp, #4            // The stack address will be used as &cmd
	ldr r0, [r0, #.Landroid_app_msgread] // r0 : android_app->msgread
	mov r1, sp             // r1 : address to store the read value
	                       // Save it for checking purposes
	movs r5, #sizeof_cmd   // size of the value to read.
	movs r2, r5            // r2 <- r5 : size of the value to read
	blx syscall_read    // Call read(android_app->msgread, stack_addr, 1)
	// if the read call returned sizeof cmd then
	// returned value (r0) and sizeof cmd (#1) are equal
	subs r6, r0, r5
	ldr r0, [sp]
	cbnz r6, .LNoDataOnCmdPipe
.LReadCmdEnd:
	adds sp, #4 // Set the stack address back
	pop {r5-r6, lr}
	bx lr
.LNoDataOnCmdPipe:
	mvn r0, #0
	b .LReadCmdEnd
	
	/*
	            LOGV("APP_CMD_INPUT_CHANGED\n");
            pthread_mutex_lock(&android_app->mutex);
            if (android_app->inputQueue != NULL) {
                AInputQueue_detachLooper(android_app->inputQueue);
            }
            android_app->inputQueue = android_app->pendingInputQueue;
            if (android_app->inputQueue != NULL) {
                LOGV("Attaching input queue to looper");
                AInputQueue_attachLooper(android_app->inputQueue,
                        android_app->looper, LOOPER_ID_INPUT, NULL,
                        &android_app->inputPollSource);
            }
            pthread_cond_broadcast(&android_app->cond);
            pthread_mutex_unlock(&android_app->mutex);
            break;*/


/* Potential optimizations :
 - Placer pendingInputQueue et InputQueue ensemble !
*/
/*
.globl android_pre_exec_cmd
// r0 : struct android_app * address
// r1 : int8_t cmd
android_pre_exec_cmd_input_changed:
	push lr
	movs r5, r0  // r5 <- * android_app (Save it for future uses)
	mov r0, #android_app_mutex
	ldr r0, [r5, r0] // r0 <- android_app->mutex
	blx  phtread_mutex_lock
	mov r0, #android_app_inputQueue
	ldr  r0, [r5, r0] // r0 <- android_app->inputQueue
	cmp  r0, #NULL // if (android_app->inputQueue != NULL)
	blx.neq AInputQueue_detachLooper // call AInputQueue_detachLooper on it
	
	mov r0, #android_app_pendingInputQueue
	ldr  r0, [r5, r0] // r0 <- android_app->pendingInputQueue
	cmp r0, #NULL
	// if (android_app->pendingInputQueue == NULL)
	//   goto .Linputqueue_null
	b.eq .Linputqueue_null 
	subs sp, sp, #4 // Get some stack space for the last argument
	adds r6, r5, #android_app_inputPollSource
	str r6, [sp] // sp <- &android_app->inputPollSource
	adds r1, r5, #android_app_looper
	ldr r1, [r1] // r1 <- android_app->looper
	mov r2, #LOOPER_ID_INPUT // r2 <- LOOPER_ID_INPUT
	mov r3, #NULL            // r3 <- NULL
	blx AInputQueue_attachLooper
	adds sp, sp, #4 // Get back our stack space
.Linputqueue_null
	pop lr
	bx lr
*/
