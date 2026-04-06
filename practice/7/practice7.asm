; practice7_modified.asm
; I/O: int 80h
; blocks: I/O, parse, math/logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
    prompt db "Enter n (5..50): ", 0
    prompt_len equ $-prompt

    msg_min db 10, "Minimum value = ", 0
    len_min equ $-msg_min

    msg_max db 10, "Maximum value = ", 0
    len_max equ $-msg_max

    msg_idx db ", at index = ", 0
    len_idx equ $-msg_idx

    comma_space db ", ", 0

SECTION .bss
    buf resb 256
    arr resd 50
    n resd 1
    tmp resb 16

SECTION .text
_start:

; ---------------- I/O ----------------
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buf
    mov edx, 255
    int 0x80

; ---------------- parse ----------------
    mov esi, buf
    xor eax, eax

parse_loop:
    mov bl, [esi]
    cmp bl, 10
    je parse_done
    sub bl, '0'
    imul eax, eax, 10
    add eax, ebx
    inc esi
    jmp parse_loop

parse_done:
    mov [n], eax

; ---------------- validate n ----------------
    cmp eax, 5
    jl exit
    cmp eax, 50
    jg exit

; ---------------- fill array ----------------
    xor ecx, ecx

fill_loop:
    mov eax, ecx
    imul eax, 5          ; 5*i
    add eax, ecx          ; + i  => 6*i
    imul eax, eax        ; (6*i)^2

    mov [arr + ecx*4], eax

    inc ecx
    cmp ecx, [n]
    jl fill_loop

; ---------------- print array ----------------
    xor ecx, ecx

print_loop:
    mov eax, [arr + ecx*4]
    push ecx
    call print_int
    pop ecx

    mov eax, 4
    mov ebx, 1
    mov ecx, comma_space
    mov edx, 2
    int 0x80

    inc ecx
    cmp ecx, [n]
    jl print_loop

; ---------------- find min/max ----------------
    mov eax, [arr]
    mov ebx, eax    ; min
    mov edx, eax    ; max
    xor esi, esi    ; min index
    xor edi, edi    ; max index

    mov ecx, 1

find_loop:
    mov eax, [arr + ecx*4]

    cmp eax, ebx
    jge skip_min
    mov ebx, eax
    mov esi, ecx

skip_min:
    cmp eax, edx
    jle skip_max
    mov edx, eax
    mov edi, ecx

skip_max:
    inc ecx
    cmp ecx, [n]
    jl find_loop

; ---------------- print min ----------------
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_min
    mov edx, len_min
    int 0x80

    mov eax, ebx
    call print_int

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_idx
    mov edx, len_idx
    int 0x80

    mov eax, esi
    call print_int

; ---------------- print max ----------------
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_max
    mov edx, len_max
    int 0x80

    mov eax, edx
    call print_int

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_idx
    mov edx, len_idx
    int 0x80

    mov eax, edi
    call print_int

; ---------------- exit ----------------
exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

; ---------------- print_int ----------------
print_int:
    mov ecx, tmp + 15
    mov byte [ecx], 0
    mov ebx, 10

convert:
    dec ecx
    xor edx, edx
    div ebx
    add dl, '0'
    mov [ecx], dl
    test eax, eax
    jnz convert

    mov eax, 4
    mov ebx, 1
    mov edx, tmp + 16
    sub edx, ecx
    mov esi, ecx
    mov ecx, esi
    int 0x80
    ret