; ПРАКТИЧНА РОБОТА 5: Sum of Digits (Unsigned)
; ОС: Debian Linux (x86)

section .data
    msg_sum db "Sum of digits: ", 0
    len_sum equ $ - msg_sum
    msg_len db "Number length: ", 0
    len_len equ $ - msg_len
    newline db 0xA

section .bss
    buffer resb 16    ; Буфер для вводу
    out_buf resb 16   ; Буфер для виводу числа (itoa)
    num resd 1        ; Змінна для числа x
    sum_val resd 1    ; Змінна для суми цифр
    count_val resd 1  ; Змінна для кількості цифр

section .text
    global _start

_start:
    ; --- I/O: Ввід числа ---
    mov eax, 3          ; sys_read
    mov ebx, 0          ; stdin
    mov ecx, buffer
    mov edx, 16
    int 0x80

    ; --- parse: atoi (рядок у число) ---
    lea esi, [buffer]
    xor eax, eax        ; Обнуляємо результат
    xor ebx, ebx        ; Тимчасовий регістр для цифри
.parse_loop:
    movzx ebx, byte [esi]
    cmp bl, 0xA         ; Перевірка на перенос рядка
    je .parse_done
    cmp bl, '0'
    jb .parse_done
    cmp bl, '9'
    ja .parse_done
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp .parse_loop
.parse_done:
    mov [num], eax      ; Зберігаємо x

    ; --- math: обчислення суми та довжини ---
    xor ecx, ecx        ; Лічильник цифр (len)
    xor ebx, ebx        ; Сума цифр (sum)
    mov eax, [num]
    mov edi, 10         ; Дільник

.calc_loop:
    cmp eax, 0
    je .calc_finished
    xor edx, edx        ; КРИТИЧНО: обнуляємо EDX перед div
    div edi             ; EDX:EAX / 10 -> EAX (частка), EDX (залишок/цифра)
    add ebx, edx        ; Додаємо цифру до суми
    inc ecx             ; Збільшуємо лічильник довжини
    jmp .calc_loop

.calc_finished:
    mov [sum_val], ebx
    mov [count_val], ecx

    ; --- logic: Вивід результатів ---
    ; Вивід "Sum of digits: "
    push msg_sum
    push len_sum
    call print_string

    mov eax, [sum_val]
    call print_number

    ; Вивід "Number length: "
    push msg_len
    push len_len
    call print_string

    mov eax, [count_val]
    call print_number

    ; --- sys_exit ---
    mov eax, 1
    xor ebx, ebx
    int 0x80

; --- memory/subroutine: itoa (число у рядок) ---
print_number:
    lea edi, [out_buf + 15]
    mov byte [edi], 0xA ; Додаємо перенос рядка в кінець
    mov ebx, 10
.itoa_loop:
    dec edi
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    test eax, eax
    jnz .itoa_loop

    lea ecx, [edi]
    lea edx, [out_buf + 16]
    sub edx, ecx
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    int 0x80
    ret

print_string:
    pop ebp             ; Адреса повернення
    pop edx             ; Довжина
    pop ecx             ; Буфер
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    int 0x80
    push ebp
    ret