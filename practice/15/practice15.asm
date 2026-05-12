BITS 32
GLOBAL _start

SECTION .data
    msg_n      db "Enter n (0-12): ", 0
    msg_f      db "Factorial: ", 0
    msg_c      db 10, "Calls: ", 0
    msg_nl     db 10
    
SECTION .bss
    n_val      resd 1
    calls      resd 1
    tmp_buf    resb 32
    tmp_char   resb 16

SECTION .text
_start:
    ; --- Ввід N ---
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_n
    mov edx, 17
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, tmp_buf
    mov edx, 30
    int 0x80

    xor eax, eax
    mov esi, tmp_buf
.parse:
    movzx edx, byte [esi]
    cmp dl, 10
    je .done_p
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc esi
    jmp .parse
.done_p:
    mov [n_val], eax
    mov dword [calls], 0

    ; --- Виклик рекурсії ---
    call fact_func

    push eax    ; Зберігаємо результат факторіала

    ; --- Вивід "Factorial: " ---
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_f
    mov edx, 11
    int 0x80

    pop eax     ; Дістаємо результат
    call safe_write_num

    ; --- Вивід "Calls: " ---
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_c
    mov edx, 8
    int 0x80

    mov eax, [calls]
    call safe_write_num

    ; --- Вихід ---
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_nl
    mov edx, 1
    int 0x80
    mov eax, 1
    xor ebx, ebx
    int 0x80

; --- РЕКУРСИВНА ФУНКЦІЯ (Максимально проста) ---
fact_func:
    inc dword [calls]
    cmp eax, 1
    jbe .base
    
    push eax            ; Зберігаємо N у стеку
    dec eax
    call fact_func      ; Рекурсія
    pop ebx             ; Повертаємо N
    mul ebx             ; EAX = EAX * EBX
    ret
.base:
    mov eax, 1
    ret

; --- БЕЗПЕЧНИЙ ВИВІД ЧИСЛА (Не затирає стек) ---
safe_write_num:
    pushad              ; Ховаємо ВСІ регістри
    mov ebx, 10
    xor ecx, ecx
.c1:
    xor edx, edx
    div ebx
    push edx
    inc ecx
    test eax, eax
    jnz .c1
.c2:
    pop edx
    add dl, '0'
    mov [tmp_char], dl
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, tmp_char
    mov edx, 1
    int 0x80
    pop ecx
    loop .c2
    popad               ; Повертаємо ВСІ регістри
    ret