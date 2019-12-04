; Nice tutorial: https://cs.lmu.edu/~ray/notes/nasmtutorial/

; Refer to printf from Clib.  
extern printf

; GCC looks for `main` by default.
global main 

; Section names appear to be more of a convention.
section .data
  ; db (byte), dw (word), dd (double word), dq (64bit) etc. are pseudo-
  ; instructions (translated to full instructions later).
  lower:     dd 172930
  upper:     dd 683082
	message:   db 'Passwords: %d', 10, 0 ; null-terminated string (10 = \n)

section .text

main:
  ; Some registers have special meanings in some contexts. There are also
  ; registers that must be preserved. These are: rbp, rbx, r12, r13, r14, r15.

  mov     esi, 0             ; number valid passwords
  mov     edi, [upper]       ; upper limit
  mov     r8d, [lower]       ; lower limit
  dec     r8d

loop:
  ; Check if ecx contains a valid password.
  ; + At least two adjacent digits are the same.
  ; + The digits never decrease.
  mov     eax, edi  ; Copy current password to eax (to extract digits).
  mov     r10d, 0   ; 0 -> initial; 1 -> adjacent found
  mov     r11d, 10  ; Store previous digit or 10 (from the least significant).

extract_next_digit:
  ; Extract current digit (mod 10), note that eax already contains the number.
  ; https://www.aldeid.com/wiki/X86-assembly/Instructions/div
  mov     edx, 0
  mov     ecx, 10
  div     ecx

  ; edx now contains `r9d mod 10` and eax `r9d ~/ 10`. We will to consider this
  ; number next.

check1:
  ; Compare with previous digit.
  cmp     edx, r11d
  je      equal_digit
  jmp     check2

equal_digit:
  ; We found a matching adjacent digit.
  mov     r10d, 1

check2:
  ; Compare with previous digit again.
  cmp     r11d, edx
  jnb     digit_ok ; Previous digit should not be below current one.
  jmp     next_password

digit_ok:
  mov      r11d, edx ; Store edx as previous digit.
  cmp      eax, 0    ; Check if there are any digits left (iff eax != 0).
  jne      extract_next_digit

  ; All digits were passed. Increment valid password counter if adjacent
  ; matching digits were found.
  cmp      r10d, 1
  jne      next_password
  inc      esi

  ; Print current password (for debugging)
  push     rax
  push     rsi
  push     rdi
  push     r8
  push     r10
  push     r11

  ; Note that the order of setting printf arguments matters here!
  mov      esi, edi
  mov      rdi, message
  mov      rax, 0
  call     printf

  pop      r11
  pop      r10
  pop      r8
  pop      rdi
  pop      rsi
  pop      rax

next_password:
  ; Check if the lower password limit is reached.
  dec     edi
  cmp     edi, r8d
  jne     loop
 
print_solution:
  ; Print solution
  mov     rdi, message       ; set 1st parameter (format)
  mov     esi, esi           ; set 2nd parameter (current_number)

  ; According to Stack Overflow:
  ; rax should contain the number of variable arguments passed in xmmN
  ; registers (note that printf uses varargs).
  mov     rax, 0

  ; Call adds 8 bytes to the stack to store a return pointer. For performance
  ; (?) reasons the stack pointer (rsp) should stay a multiple of 16 (bytes).
  ; However, if we do not care about stack pointer alignment the program still
  ; works. I decided to not care.
  call    printf

  ; Return
  ret
