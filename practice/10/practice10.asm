; practice10.asm
; I/O: int 80h (sys_read, sys_write)
; blocks: I/O, parse, math, logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
    msg_input   db "Enter a number: ", 0
    msg_input_l equ $ - msg_input
    msg_bin     db "Binary: ", 0
    msg_pop     db 10, "Popcount: ", 0
    msg_mod     db 10, "Modified (set 0,4, clear 7): ", 0
    newline     db 10
    space       db " "

SECTION .bss
    buf         resb 16
    tmp_buf     resb 16
    num         resd 1
    modified    resd 1

SECTION .text
_start:

; ---------------- I/O (Input) ----------------
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_input
    mov edx, msg_input_l
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buf
    mov edx, 16
    int 0x80

; ---------------- parse (String to Int) ----------------
    call str_to_int
    mov [num], eax

; ---------------- I/O (Binary Print Loop) ----------------
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_bin
    mov edx, 8
    int 0x80

    mov eax, [num]
    mov ecx, 32         ; 32 біти
.bin_loop:
    push ecx
    rol eax, 1          ; виштовхуємо старший біт у CF
    push eax            ; зберігаємо число

    jc .print_one
    mov byte [tmp_buf], '0'
    jmp .do_print
.print_one:
    mov byte [tmp_buf], '1'
.do_print:
    mov eax, 4
    mov ebx, 1
    mov ecx, tmp_buf
    mov edx, 1
    int 0x80

    pop eax             ; відновлюємо число
    pop ecx             ; відновлюємо лічильник

    ; додаємо пробіл кожні 4 біти
    test cl, 3          ; перевірка чи cl ділиться на 4 (крім 0)
    jnz .no_space
    cmp cl, 1
    jbe .no_space
    push eax
    push ecx
    mov eax, 4
    mov ecx, space
    mov edx, 1
    int 0x80
    pop ecx
    pop eax
.no_space:
    loop .bin_loop

; ---------------- math (Popcount) ----------------
    mov eax, [num]
    xor edx, edx        ; тут буде лічильник одиниць
    mov ecx, 32
.pop_loop:
    test eax, 1         ; перевіряємо молодший біт
    jz .not_one
    inc edx
.not_one:
    shr eax, 1
    loop .pop_loop

    push edx            ; зберігаємо popcount
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_pop
    mov edx, 11
    int 0x80
    pop eax
    call print_uint     ; вивід popcount

; ---------------- logic (Bit masks) ----------------
    ; Задача: set біти 0 та 4, clear біт 7
    mov eax, [num]

    ; Set bits (OR з маскою)
    or eax, (1 << 0)    ; встановити p
    or eax, (1 << 4)    ; встановити q

    ; Clear bit (AND з інвертованою маскою)
    and eax, ~(1 << 7)  ; скинути r

    mov [modified], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_mod
    mov edx, 30
    int 0x80

    mov eax, [modified]
    call print_uint

; ---------------- memory (exit) ----------------
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80

; --- Functions ---

str_to_int:
    xor eax, eax
    mov esi, buf
.next:
    movzx edx, byte [esi]
    cmp dl, 10
    je .done
    cmp dl, '0'
    jb .done
    cmp dl, '9'
    ja .done
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc esi
    jmp .next
.done:
    ret

print_uint:
    mov ecx, tmp_buf + 15
    mov byte [ecx], 0
    mov ebx, 10
.p_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec ecx
    mov [ecx], dl
    test eax, eax
    jnz .p_loop
    mov eax, 4
    mov ebx, 1
    mov edx, tmp_buf + 15
    sub edx, ecx
    int 0x80
    ret