;rdi	= mapOut
;rsi	= mapIn
;rdx	= window

section .bss

window: resd 1
byte_distance: resb 1		;dystans razy 3 - przyjmuje, ze ramka nie ejst jakas nieograniczenie duze - w main sprawdz
distance: resb 1
width: resd 1 
padding: resq 1
size_of_line: resd 1
how_much_to_skip: resd 1
height: resd 1

last_column: resd 1
last_line: resd 1

section	.text
global  func

func:
	push	r12
	push	r13
	push	r14
	push	r15

	push	rbp
	mov	rbp,	rsp

	mov	[window], edx
	sub 	rdx , 1
	shr	rdx, 1
	mov	[distance] , dl ;zapisz dystans ile sie ogladasz 
	lea	rdx, [rdx+ 2*rdx]
	mov	[byte_distance], dl
	mov 	ecx, [rsi+18]    ;to sa 4 bajty
	mov 	[width], ecx
	lea	rcx, [rcx+2*rcx]		;tyle pikseli na wiersz
	mov	rbx , 3
	and	rbx, rcx
	mov 	rax, 4
	sub	rax, rbx
	and	rax, 3			; w eax mamy padding
	mov	[padding], rax
	add	rax, rcx
	mov	[size_of_line], eax
	xor  	rdx, rdx
	mov 	dl, [distance]
	mul 	edx			; w eax mamy size of line 
	mov	[how_much_to_skip], eax    ;raczej tyle styknie
	mov	ecx, [rsi+22]			;height
	mov	[height], ecx
	mov 	ecx, [rsi +10]
	add	ecx, eax
	mov 	ebx, ecx
	push	rsi
	rep 	movsb
	pop	rsi
	add	rsi, rbx
	;mov 	ebx, ecx		;wskazuje gdzie teraz bedziemy pisac - pierwszy nieptrzetworzony pixel
	
		
start:   
	xor rax, rax
	xor r8, r8
	mov r8b, [distance] 
	;mov al, r8b
	mov r9, r8	
	add r9, 1  ;r9 zawiera w ktorym wierszu jestesmy
	mov ecx, [width]
	sub ecx, r8d
	mov [last_column], ecx	
	xor rbx, rbx
	mov bl, [byte_distance];
	not rbx
	add rbx, 1
	mov eax, [how_much_to_skip]
	sub rbx, rax    ;to jest wiersze co nie mozesz razy dystans
	mov rax, rbx			;na zapas
	mov edx, [window]
	mov r11d, [height]
	sub r11, r8
	mov [last_line], r11d		;zapisz ostatnia linie do przetwrzenia


przepisz_poczatek:	; ustaw liczniki

	mov rcx, r8
	lea rcx, [rcx+2*rcx]
	mov r10, r8
	add r10, 1			;r10 to kolumna
	rep movsb

			


f_lines:					;kopiowanie po bajcie - konwersja 1 pixelu

	mov r14, rdx			;licznik wierszy
	mov r15, rdx			;licznik kolumn
	mov rbx, rax
	push rbx		
	mov r11b, 255			;ustaw minima wpisuj do calych zeby wyzerowac
	mov r12b, 255
	mov r13b, 255
	mov cl, 0


real_filtr:
	add cl, 1
	cmp BYTE[rsi+rbx], r11b							
	jb zmien_B
	cmp BYTE[rsi+rbx+1], r12b
	jb zmien_G
	cmp BYTE[rsi+rbx+2], r13b
	jb zmien_R

next_pixel_to_look:

	add rbx, 3
	;mov [edi], r15
	;add rdi, 8
	sub r15b, 1
	jnz real_filtr

next_line_in_window:
	pop rbx
	push rcx
	mov ecx, [size_of_line]
	add rbx, rcx
	pop rcx
	push rbx
	mov r15, rdx
	sub r14, 1
	jnz real_filtr

save:
	pop rbx												
	mov BYTE[rdi], r11b
	mov BYTE[rdi+1], r12b
	mov BYTE[rdi+2], r13b
	add rsi , 3
	add rdi , 3
       						;koniec testow

end_filtr_pixel:

	add r10, 1
	cmp DWORD[last_column], r10d
	jae f_lines

next_line:

	add r9d, 1		;zwieksz wartosc wierszy
	mov rcx, r8		;laduj dystas
	lea rcx, [rcx+2*rcx]
	add rcx, [padding]
	rep movsb		;przepisywanie koncowki



sprawdz_cz_p:
	
	cmp r9d, [last_line]
	ja przepisz_koniec
	jmp przepisz_poczatek

zmien_B:
	mov r11b, BYTE[rsi+rbx]
	cmp BYTE[rsi+rbx+1], r12b
	jb zmien_G
	cmp BYTE[rsi+rbx+2], r13b
	jb zmien_R
	jmp next_pixel_to_look
zmien_G:

	mov r12b, BYTE[rsi+rbx+1]
	cmp BYTE[rsi+rbx+2], r13b
	jb zmien_R
	jmp next_pixel_to_look
zmien_R:

	mov r13b, BYTE[rsi+rbx+2]
	jmp next_pixel_to_look


przepisz_koniec:
	mov ecx, [how_much_to_skip]
	rep movsb


epilog:

	pop	rbp
	pop 	r15
	pop	r14
	pop	r13
	pop	r12
	ret

