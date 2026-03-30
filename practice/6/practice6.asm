BITS 32
GLOBAL _start

SECTION .data
    ask_a db "Input A: ", 0
    ask_a_len equ $ - ask_a
    ask_b db "Input B: ", 0
    ask_b_len equ $ - ask_b
    
    res_s_lt db "Signed: A < B", 10, 0
    res_s_gt db "Signed: A > B", 10, 0
    res_u_lt db "Unsigned: A < B", 10, 0
    res_u_gt db "Unsigned: A > B", 10, 0
    res_eq   db "A and B are equal", 10, 0

SECTION .bss
    buffer resb 16
    val_a  resd 1
    val_b  resd 1

SECTION .text
_start:
    ; --- Ввід числа A ---
    mov eax, 4
    mov ebx, 1
    mov ecx, ask_a
    mov edx, ask_a_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 16
    int 0x80
    call parse_int
    mov [val_a], eax

    ; --- Ввід числа B ---
    mov eax, 4
    mov ebx, 1
    mov ecx, ask_b
    mov edx, ask_b_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 16
    int 0x80
    call parse_int
    mov [val_b], eax

    ; --- Логіка порівняння ---
    mov eax, [val_a]
    mov ebx, [val_b]
    cmp eax, ebx
    je .equal_case

    ; Знакове (Signed) порівняння
    jg .signed_more
    mov ecx, res_s_lt
    jmp .print_s
.signed_more:
    mov ecx, res_s_gt
.print_s:
    mov edx, 14
    push ebx
    mov eax, 4
    mov ebx, 1
    int 0x80
    pop ebx

    ; Беззнакове (Unsigned) порівняння
    mov eax, [val_a]
    cmp eax, ebx
    ja .unsigned_more
    mov ecx, res_u_lt
    jmp .print_u
.unsigned_more:
    mov ecx, res_u_gt
.print_u:
    mov edx, 16
    mov eax, 4
    mov ebx, 1
    int 0x80
    jmp .end

.equal_case:
    mov eax, 4
    mov ebx, 1
    mov ecx, res_eq
    mov edx, 18
    int 0x80

.end:
    mov eax, 1
    xor ebx, ebx
    int 0x80

; Конвертація рядка в число
parse_int:
    xor eax, eax
    mov esi, ecx
.next_digit:
    movzx edx, byte [esi]
    cmp dl, 10
    je .stop
    cmp dl, '0'
    jb .stop
    cmp dl, '9'
    ja .stop
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc esi
    jmp .next_digit
.stop:
    ret