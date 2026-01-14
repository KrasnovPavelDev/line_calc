; this program reads lines from the standard input
; stream, each containing the decimal representation
; of the first number, an arithmetic operator, and
; the decimal representation of the second number.
; in response to each line read, the program prints
; the result of the specified operation

global _start

section .data
error_msg       db      "Error", 10
em_len          equ     $-error_msg

new_line        db      10
nl_len          equ     $-new_line

section .bss
char            resb    1
char_len        equ     $-char

num_1_dec       resb    10
num_1_len       resd    1
num_1_bin       resd    1

num_2_dec       resb    10
num_2_len       resd    1
num_2_bin       resd    1

result_dec      resb    10
result_bin      resd    1
expression      resb    1

section .text
_start:
    xor     esi, esi    ; current program status
	xor     edi, edi    ; index of array

main:
    mov     eax, 3      ; read call
    mov     ebx, 0      ; standard input
    mov     ecx, char
    mov     edx, char_len
    int     80h
    
    cmp     eax, 1      ; we check the input
    jne     eof_reached ;  result for error and EOF
    
    mov     al, [char]

	cmp     al, "*"
	je      change_status
	cmp     al, "+"
	je      change_status
	cmp     al, "-"
	je      change_status
	cmp     al, "/"
	je      change_status
	cmp     al, "0"
	jl      check_error
	cmp     al, "9"
	jg      check_error

	cmp     esi, 0
	je      inc_num_1
	cmp     esi, 1
	je      inc_num_2

inc_num_1:              ; we save digit by digit
	mov	    [num_1_dec+edi], al
	inc	    edi
	jmp	    main

inc_num_2:
	mov	    [num_2_dec+edi], al
	inc	    edi
	jmp	    main

change_status:          ; we change the program
	cmp     esi, 0      ;  status to read the second
	jne	    print_error ;  number and the operation
	cmp	    edi, 0      ;  sign
	je	    print_error
	mov	    [expression], al
	mov	    [num_1_len], edi
	xor	    edi, edi
	mov	    esi, 1
	jmp	    main

eof_reached:
check_error:
	cmp     esi, 1
	jne	    print_error
	cmp	    edi, 0
	je      print_error
	
    mov	    [num_2_len], edi
	mov	    esi, [num_1_len]
	dec	    esi
	xor	    ecx, ecx
	mov 	ebx, 1

to_bin_1:
	mov     al, [num_1_dec+esi]
	sub     eax, 48
	mul     ebx         ; we convert the number
	add     ecx, eax    ;  to binary numeral system
	mov     eax, ebx
	mov     ebx, 10
	imul	ebx
	mov     ebx, eax
	dec     esi
	cmp     esi, 0
	jge     to_bin_1
	mov     [num_1_bin], ecx

	mov     esi, [num_2_len]
	dec     esi
	xor     ecx, ecx
	mov     ebx, 1
to_bin_2:
	mov     al, [num_2_dec+esi]
	sub     eax, 48
	mul     ebx         ; we convert the number
	add     ecx, eax    ;  to binary numeral system
	mov     eax, ebx
	mov     ebx, 10
	mul     ebx
	mov     ebx, eax
	dec     esi
	cmp     esi, 0
	jge     to_bin_2
	mov     [num_2_bin], ecx

	mov     al, [expression]
	cmp     al, "*"
	je      mul_nums
	cmp     al, "+"
	je      add_nums
	cmp     al, "-"
	je      sub_nums
	cmp     al, "/"
	je      div_nums

mul_nums:
	mov     eax, [num_1_bin]
	mov     ebx, [num_2_bin]
	mul     ebx
	mov     [result_bin], eax
	jmp     end_of_calculations

add_nums:
	mov     eax, [num_1_bin]
	mov	    ebx, [num_2_bin]
	add	    eax, ebx
	mov	    [result_bin], eax
	jmp	    end_of_calculations

sub_nums:
	mov	    eax, [num_1_bin]
	mov	    ebx, [num_2_bin]
	sub	    eax, ebx
	mov	    [result_bin], eax
	jmp	    end_of_calculations

div_nums:
	mov	    eax, [num_1_bin]
	mov	    ebx, [num_2_bin]
	div	    ebx
	mov	    [result_bin], eax
	jmp	    end_of_calculations

end_of_calculations:
	mov	    eax, [result_bin]
    xor     edi, edi
	mov	    ebx, 10

bin_to_dec:
	cmp	    eax, 10     ; we convert the result to
	jl  	end_bin_to_dec
	div	    ebx         ;  decimal numeral system
	add	    dl, 48
	mov	    [result_dec+edi], dl
	inc	    edi
	jmp	    bin_to_dec

end_bin_to_dec:
	add	    al, 48
	mov	    [result_dec+edi], al

print_result:
    mov     esi, result_dec
    add     esi, edi

    mov     eax, 4      ; write call
    mov     ebx, 1      ; standard output
    mov     ecx, esi
    mov     edx, 1
    int     80h

	dec	    edi
	cmp	    edi, 0
	jge	    print_result

    mov     eax, 4      ; write call
    mov     ebx, 1      ; standard output
    mov     ecx, new_line
    mov     edx, nl_len
    int     80h

	jmp	    _start

print_error:
    mov     eax, 4      ; write call
    mov     ebx, 1      ; standard output
    mov     ecx, error_msg
    mov     edx, em_len
    int     80h

end_program:
	mov     eax, 1      ; _exit call
    mov     ebx, 0      ; success code
    int     80h
