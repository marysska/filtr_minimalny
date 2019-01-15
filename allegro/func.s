;rdi	= mapOut
;rsi	= mapIn
;rdx	= window




;w programie r14 i r15 to liczniki wierszy i kolumn w ramce r9 i r10 liczniki wierszy i kolumn w calym obrazie 11 12 13 to minima r8 to dystans, a rozmiar wiersza, b adres, 
;d zawiera wielkosc okna i padding
; c zostawione do licznikow , rdi i rsi zgodnie z argumentami funkcji

section .bss

window: resb 1
distance: resb 1
width: resd 1 
padding: resb 1
size_of_line: resd 1
how_much_to_skip: resd 1
height: resd 1
last_column: resd 1


section	.text
global  func

func:
	push	r12
	push	r13
	push	r14
	push	r15

	push	rbp
	mov	rbp,	rsp

	mov	[window], dl
	sub 	rdx , 1
	shr	rdx, 1
	mov	[distance] , dl ;zapisz dystans ile sie ogladasz 
	mov 	ecx, [rsi+18]    ;to sa 4 bajty
	mov 	[width], ecx
	lea	rcx, [rcx+2*rcx]		;tyle pikseli na wiersz
	mov	rbx , 3
	and	rbx, rcx
	mov 	rax, 4
	sub	rax, rbx
	and	rax, 3			; w eax mamy padding
	mov	[padding], al
	add	rax, rcx
	mov	[size_of_line], eax
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
	
		
start:   

	xor r8, r8
	mov r8b, [distance] 
	mov ecx, [width]
	sub ecx, r8d
	sub ecx, r8d
	mov [last_column], ecx	
	lea rbx, [r8+2*r8];
	not rbx
	add rbx, 1
	mov eax, [how_much_to_skip]
	sub rbx, rax    ;to jest wiersze co nie mozesz razy dystans
	push rbx
	mov eax, [size_of_line]
	mov dl, [window]
	mov dh, [padding]
	mov r9d, [height]
	sub r9, r8
	sub r9, r8			;ile linii przetwazamy 



przepisz_poczatek:	; ustaw liczniki

	mov rcx, r8
	lea rcx, [rcx+2*rcx]
	mov r10, [last_column]				;zaladuj ile kolumn bedziesz przetwazac   ladujesz tyle razy ile wierszy
	rep movsb

			


f_lines:					;kopiowanie po bajcie - konwersja 1 pixelu

	mov r14b, dl			;licznik wierszy
	mov r15b, dl			;licznik kolumn
	pop rbx				;wez ze stosu startowa
	push rbx			;zeby pozniej mogl pobrac
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
	sub r15b, 1
	jnz real_filtr				; sprawdz czy to nie ostatnia kolumna w ramce

next_line_in_window:
	pop rbx
	push rcx
	mov ecx, eax
	add rbx, rcx
	pop rcx
	push rbx
	mov r15b, dl
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


	sub r10, 1
	jnz f_lines

next_line:
	xor rcx, rcx
	mov cl, dh
	lea rcx, [r8+2*r8]
	rep movsb		;przepisywanie koncowki



sprawdz_cz_p:
	

	sub r9, 1
	jz przepisz_koniec
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
	pop rbx			;pozbadz sie ze stosu
	mov ecx, [how_much_to_skip]
	rep movsb


epilog:

	pop	rbp
	pop 	r15
	pop	r14
	pop	r13
	pop	r12
	ret

