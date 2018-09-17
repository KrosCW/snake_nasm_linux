[bits 64]

section		.data
;console const
	clrscr db 27, '[H', 27, '[2J'
	termios:        times 36 db 0
	stdin:          equ 0
	ICANON:         equ 1<<1
	ECHO:           equ 1<<3
	
;map const
	border      db 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', 10, 13
	border_body db 'X                                                          X', 10, 13
	apple db '$'
	snake_part db '***'
	
;test buttons
	up db 'up' 
	down db 'down'
	left db 'left'
	right db 'right'

section .bss
;console control	
	readkey resb 1
	key_data resb 1
	gotoYYXX resb 8

;snake
	snake_size resb 1
	head_x resb 1
	head_y resb 1
	
;apple
	apple_x resb 1
	apple_y resb 1
	
;map
	map resb 60*20

%include "const.txt"

section		.text
	    global _start

canonical_off:
fin:		
        call read_stdin_termios

        ; clear canonical bit in local mode flags
        push rax
        mov eax, ICANON
        not eax
        and [termios+12], eax
        pop rax
        mov al,0
        mov [termios+OFFSET+VMIN],al
        mov [termios+OFFSET+VTIME],al

        call write_stdin_termios
        ret

echo_off:
        call read_stdin_termios

        ; clear echo bit in local mode flags
        push rax
        mov eax, ECHO
        not eax
        and [termios+12], eax
        pop rax

        call write_stdin_termios
        ret

canonical_on:
        call read_stdin_termios

        ; set canonical bit in local mode flags
        or dword [termios+12], ICANON

        call write_stdin_termios
        ret

echo_on:
        call read_stdin_termios

        ; set echo bit in local mode flags
        or dword [termios+12], ECHO

        call write_stdin_termios
        ret

read_stdin_termios:
        push rax
        push rbx
        push rcx
        push rdx

        mov eax, 36h
        mov ebx, stdin
        mov ecx, 5401h
        mov edx, termios
        int 80h

        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret

write_stdin_termios:
        push rax
        push rbx
        push rcx
        push rdx

        mov eax, 36h
        mov ebx, stdin
        mov ecx, 5402h
        mov edx, termios
        int 80h

        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret

;offset functions

draw_head:
	xor eax,eax
	mov al, [head_y]
	mov ah, 0
	mov bl, 10
	div bl
	add al, 48
	add ah, 48
	
	mov [gotoYYXX+2], al
	mov [gotoYYXX+3], ah
	
	mov al, [head_x]
	mov ah, 0
	div bl
	add al, 48
	add ah, 48
	
	mov [gotoYYXX+5], al
	mov [gotoYYXX+6], ah
	
	mov eax, 4
	mov ebx, 2
	mov ecx, gotoYYXX
	mov edx, 8
	int 80h
	
	mov eax, 4
	mov ebx, 2
	mov ecx, snake_part
	mov edx, 1
	int 80h
	ret

new_snake_size:
	add [snake_size], byte 1
	jmp start_offset
	ret
	
yes:
	mov eax, 4
	mov ebx, 2
	mov ecx, border
	mov edx, 1
	int 80h
	ret

offset:
	call draw_head
	
	xor eax, eax
	mov al, [head_y]
	mov bl, 60
	mul bl
	add ax, [head_x]
	
	
	
	cmp [map+eax], byte 127
	jz exit
	
	cmp [map+eax], byte 126
	jz new_snake_size
	
start_offset:
	
		
	
	
	
	
	ret




;kyebord functions

save_key_data_w:
	mov eax, [readkey]
	mov [key_data], eax
data_w:
	sub [head_y], byte 1
	
	jmp new_coord_is_accept
	ret

save_key_data_s:
	mov eax, [readkey]
	mov [key_data], eax
data_s:
	add [head_y], byte 1
	jmp new_coord_is_accept
	ret
	
save_key_data_a:
	mov eax, [readkey]
	mov [key_data], eax
data_a:
	sub [head_x], byte 1
	jmp new_coord_is_accept
	ret
	
save_key_data_d:
	mov eax, [readkey]
	mov [key_data], eax
data_d:
	add [head_x], byte 1
	jmp new_coord_is_accept
	ret
	
prekey_is_w_s:
	cmp [readkey], byte 'w'
	jz data_w
	
	cmp [readkey], byte 's'
	jz data_s
;optimization down!	
	cmp [readkey], byte 'a'
	jz save_key_data_a
	
	cmp [readkey], byte 'd'
	jz save_key_data_d
	
	ret

prekey_is_a_d:
	cmp [readkey], byte 'w'
	jz save_key_data_w
	
	cmp [readkey], byte 's'
	jz save_key_data_s
	
	cmp [readkey], byte 'a'
	jz data_a
	
	cmp [readkey], byte 'd'
	jz data_d
	
	ret
	

	ret

press_save:
	
	cmp [key_data], byte 'w'
	jz prekey_is_w_s
	
	cmp [key_data], byte 's'
	jz prekey_is_w_s
	
	cmp [key_data], byte 'a'
	jz prekey_is_a_d
	
	cmp [key_data], byte 'd'
	jz prekey_is_a_d
	
;update_data_key:	
	jmp new_coord_is_accept

	ret

read_processing:

;read char
	mov [readkey], byte 0 

	mov eax, 3
	mov ebx, 2
	mov ecx, readkey
	mov edx, 1	
	int 80h	
	
	
	cmp [readkey], byte 'w'
	jz press_save
	
	cmp [readkey], byte 's'
	jz press_save
	
	cmp [readkey], byte 'a'
	jz press_save
	
	cmp [readkey], byte 'd'
	jz press_save
	
	cmp [key_data], byte 'w'
	jz data_w
	
	cmp [key_data], byte 's'
	jz data_s
	
	cmp [key_data], byte 'a'
	jz data_a
	
	cmp [key_data], byte 'd'
	jz data_d


new_coord_is_accept:
	
	
	ret



;first functions

set_and_draw_objects:


;map draw
	mov eax, 4 
	mov ebx, 2
	mov ecx, border
	mov edx, 62
    int 80h
    
    mov ecx, 19
border_body_draw:
	push rcx
	mov eax, 4 
	mov ebx, 2
	mov ecx, border_body
	mov edx, 62
    int 80h
	pop rcx
loop border_body_draw

	mov eax, 4 
	mov ebx, 2
	mov ecx, border
	mov edx, 62
	int 80h


;apple arrey
	mov [map+620-1], byte 126 ; 126 is apple - $
	
	
	
;apple draw
	mov [gotoYYXX+2], byte '1'
	mov [gotoYYXX+3], byte '0'
	
	mov [gotoYYXX+5], byte '5'
	mov [gotoYYXX+6], byte '5'
	
	mov eax, 4
	mov ebx, 2
	mov ecx, gotoYYXX
	mov edx, 8
	int 80h
	
	mov eax, 4
	mov ebx, 2
	mov ecx, apple
	mov edx, 1
	int 80h
	
;snake arrey
	mov [map+183], byte 3
	mov [map+184], byte 2
	mov [map+185], byte 1
	

;snake draw

	mov [gotoYYXX+2], byte '0'
	mov [gotoYYXX+3], byte '3'
	
	mov [gotoYYXX+5], byte '1'
	mov [gotoYYXX+6], byte '5'
	
	mov eax, 4
	mov ebx, 1
	mov ecx, gotoYYXX
	mov edx, 8
	int 80h
	
	mov eax, 4
	mov ebx, 1
	mov ecx, snake_part
	mov edx, 3
	int 80h
	
	ret

initialization_value:

;snake initialization
	mov [snake_size], byte 3
	mov [head_x], 	  byte 1
	mov [head_y], 	  byte 7

;apple initialization
	mov [apple_x],	  byte 55
	mov [apple_y],	  byte 10
	
;console initialization
	mov [gotoYYXX],   byte 27
	mov [gotoYYXX+1], byte '['
	mov [gotoYYXX+2], byte '#' ;Y = 2 hight, 3 low
	mov [gotoYYXX+3], byte '#' ;
	mov [gotoYYXX+4], byte ';'
	mov [gotoYYXX+5], byte '#' ;X = 5 hight, 6 low
	mov [gotoYYXX+6], byte '#' ;
	mov [gotoYYXX+7], byte 'H'
	
	mov [readkey],	  byte 'd'
	mov [key_data],	  byte 'd'
	
;map initialization
	mov [map], byte 127 ;127 is border - X
	mov ecx, 59
first_row:
	mov [map+ecx], byte 127
loop first_row

	mov ecx, 18
row:
	mov al, 60
	mov ebx, ecx
	mul bl
	sub ax, 1
	
	mov[map+eax], byte 127
	mov [map+eax+59], byte 127
	
	push rcx
	
		mov ecx, 58
	column:
		mov ebx, eax
		add ebx, ecx
		mov [map+ebx], byte 0
	loop column	
	pop rcx	
	loop row
	
	mov ebx, 1199-60
	mov ecx, 60
last_row:
	mov [map+ebx+ecx], byte 127
loop last_row
	ret


_start:
main:
;clrscr
	mov eax, 4 
	mov ebx, 2
	mov ecx, clrscr
	mov edx, 7
    int 80h
	
	call echo_off
	call canonical_off	
	call initialization_value
	call set_and_draw_objects

repeat:
	call read_processing;
	call offset
	
	mov ecx, 100000
str:
	call echo_off
loop str

	jmp repeat
	
	
exit:
	
;	mov eax, 4
;	mov ebx, 1
;	mov ecx, new
;	mov edx, 1
;	int 80h

;mov ax, 30
;mov bl, 150
;div bl

	call echo_on
	
	mov rax, 1
	mov rbx, 0	
	int 0x80
