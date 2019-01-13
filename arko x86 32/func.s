
section .bss


height: resd 1
width: resd 1 
buffIn: resd 1 ;adres na pierwszy element (?)
buffOut: resd 1
distance: resd 1 
padding: resd 1
size_of_line: resd 1
how_much_to_skip: resd 1
kolumna: resd 1
wiersz: resd 1
window: resd 1
byte_distance: resd 1
last_column: resd 1
start_filtr: resd 1

section	.text
global  func

func:
	push	ebp
	mov	ebp, esp
	mov	eax, DWORD [ebp+12]	;adres out
	mov	[buffOut], eax          ;niech jak cos zawiera to ares na bufor koncowy
	mov	ebx, DWORD [ebp+8]	;adres in
	mov 	[buffIn], ebx		;adres na bufor wej
	mov	edx, [ebp +20]
	mov	[window], edx
	sub 	edx, 1;
	shr 	edx, 1
	mov	[distance], edx		;mamy ile trzeba juz ogladac sie na bok 
	lea	edx, [edx+ 2*edx]
	mov	[byte_distance], edx
	mov	ecx,[ebx+18]
	mov	[width], ecx
	lea	ecx, [ecx + 2*ecx]	;szerokosc razy 3 - ile jest pikseli na wiersz
	mov	ebx, 3			;zaladuj 3 do ebx, zeby andowac - reszta z dzielenia przez4
	and     ebx, ecx		; w ebx reszta z dzielenia przez 4
	mov	eax, 4			; zaladuj 4 - dodaj tyle, zeby bylo wyrownanie
	sub	eax, ebx		; w eax dopelnienie 1/2/3/4 - zamiast 4 ma byc zero
	and     eax, 3			;mamy padding obliczony!
	mov 	[padding], eax
	add	eax, ecx		;mamy size wiersza
	mov 	[size_of_line], eax	;zaladowalismy rozmiar wiersza
	mov 	edx, [distance]
	mul	edx			;w edx i eax mamy wynik edx*eax - nie bedzie to wieksze niz eax
	mov	[how_much_to_skip], eax	;na pozniej - na koniec
	mov	edx, [buffIn]
	mov	ecx, [edx+22]
	mov	[height], ecx
	mov	ecx, [edx+10]
	add	ecx, eax		;dodaj to co nie mozesz przepisac plus naglowek
	mov 	ebx, ecx		;wskazuje gdzie teraz bedziemy pisac - pierwszy nieptrzetworzony pixel
	mov 	edi, [buffOut]
	mov	esi, [buffIn]
	rep movsb   			;przepisanie poczatka - x pierwszych wierszy oraz naglowek
	
		
start:   
	mov esi, [buffIn]
	mov edi, [buffOut]
	add esi, ebx	; w ebx bylo ile juz przepisalismy bajtow
	add edi, ebx 	;i mamy gdzie zaczynamy
	mov edx, [distance] 
	mov eax, edx
	add edx, 1	;dodaj 1 - jestes teraz w pierwszym wierszu po tym co nie mozesz
	mov [wiersz], edx
	mov ecx, [width]
	sub ecx, eax
	mov [last_column], ecx
	mov ebx, [byte_distance];
	not ebx
	add ebx, 1
	sub ebx, [how_much_to_skip]    ;to jest wiersze co nie mozesz razy dystans
	mov [start_filtr], ebx


przepisz_poczatek:	; ustaw liczniki
	mov edx, [distance]
	mov al, dl
	add edx, 1
	mov [kolumna], edx
	mov dl, al
	add dl, al
	add dl, al	;3 razy distance przepisujemy



przepisz_pocz_loop:
	mov ah,[esi]
	mov [edi], ah
	add edi, 1
	add esi ,1
	sub dl, 1
	test dl, dl
	jnz przepisz_pocz_loop




f_lines:					;kopiowanie po bajcie - konwersja 1 pixelu
	mov ah, [window]	;zaladuj licznik kolumn
	mov al, ah		;zaladuj licznik wierszy
	mov ebx, [start_filtr]	
	push ebx		
	mov cl, 255
	mov ch, 255
	mov dh, 255


real_filtr:
	cmp [esi+ebx],cl	;pamietaj ze zmienilas
	jb zmien_cl
	cmp [esi+ebx+1], ch
	jb zmien_ch
	cmp [esi+ebx+2], dh
	jb zmien_dh

next_pixel_to_look:
	sub ah, 1
	add ebx, 3
	test ah, ah
	jnz real_filtr
next_line_in_window:
	sub al, 1
	pop ebx
	add ebx, [size_of_line]
	push ebx
	mov ah, [window]
	test al, al
	jnz real_filtr
save:
	pop ebx
	mov BYTE[edi], cl
	mov BYTE[edi+1],ch
	mov BYTE[edi+2], dh
	add esi , 3
	add edi , 3

end_filtr_pixel:
	mov edx, [kolumna]
	add edx, 1
	mov  [kolumna], edx
	cmp [last_column], edx
	jae f_lines

next_line:
	mov edx, [wiersz]
	add edx, 1
	mov [wiersz], edx
	mov al, [distance]
	mov dl, al
	add dl, al
	add dl, al
	add dl, [padding]

przepisz_kon:
	mov ah,[esi]
	mov [edi], ah
	add edi, 1
	add esi ,1
	sub dl, 1
	test dl, dl
	jnz przepisz_kon
sprawdz_cz_p:
	mov eax , [height]	;sprawdz czy juz nie koniec
	sub eax, [distance]
	cmp [wiersz], eax
	ja przepisz_koniec
	jmp przepisz_poczatek

zmien_cl:
	mov cl, [esi+ebx]
	cmp [esi+ebx+1], ch
	jb zmien_ch
	cmp [esi+ebx+2], dh
	jb zmien_dh
	jmp next_pixel_to_look
zmien_ch:
	mov ch, [esi+ebx+1]
	cmp [esi+ebx+2], dh
	jb zmien_dh
	jmp next_pixel_to_look
zmien_dh:
	mov dh, [esi+ebx+2]
	jmp next_pixel_to_look




przepisz_koniec:
	mov ecx, [how_much_to_skip]
	rep movsb

epilog:
	pop	ebp
	ret

