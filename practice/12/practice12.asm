; practice12.asm
; I/O: int 80h (sys_read, sys_write)
; blocks: I/O, parse, math, logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
    prompt_text db "Enter text: ", 0
    p_text_len  equ $ - prompt_text
    prompt_pat  db "Enter pattern: ", 0
    p_pat_len   equ $ - prompt_pat
    msg_pos     db "First position: ", 0
    msg_cnt     db 10, "Total count: ", 0
    msg_minus1  db "-1", 0
    newline     db 10

SECTION .bss
    text        resb 256
    pattern     resb 64
    text_len    resd 1
    pat_len     resd 1
    first_pos   resd 1
    total_count resd 1
    tmp_buf     resb 16

SECTION .text
_start:

; ---------------- I/O (Input) ----------------
    ; Text
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_text
    mov edx, p_text_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, text
    mov edx, 255
    int 0x80
    call sanitize_input
    mov [text_len], eax

    ; Pattern
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_pat
    mov edx, p_pat_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, pattern
    mov edx, 63
    int 0x80
    call sanitize_input
    mov [pat_len], eax

; ---------------- logic (Substring Search) ----------------
    mov dword [first_pos], -1
    mov dword [total_count], 0

    ; Перевірка на порожній шаблон
    mov eax, [pat_len]
    test eax, eax
    jz exit_program

    xor esi, esi        ; i (індекс у тексті)
outer_loop:
    mov eax, [text_len]
    sub eax, [pat_len]
    cmp esi, eax        ; чи вистачає залишку тексту для паттерна
    jg finish_search

    ; Внутрішній цикл перевірки
    xor edi, edi        ; j (індекс у паттерні)
check_match:
    mov eax, [pat_len]
    cmp edi, eax
    je found_match

    mov al, [text + esi + edi]
    mov bl, [pattern + edi]
    cmp al, bl
    jne next_step
    inc edi
    jmp check_match

found_match:
    ; Зберігаємо першу позицію
    cmp dword [first_pos], -1
    jne inc_count
    mov [first_pos], esi

inc_count:
    inc dword [total_count]
    ; Зсув на довжину паттерна (без перекриття)
    add esi, [pat_len]
    dec esi             ; компенсуємо inc esi в кінці
    jmp next_step

next_step:
    inc esi
    jmp outer_loop

finish_search:

; ---------------- I/O (Output Results) ----------------
    ; First Position
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_pos
    mov edx, 16
    int 0x80

    mov eax, [first_pos]
    cmp eax, -1
    jne print_fpos
    mov eax, 4
    mov ecx, msg_minus1
    mov edx, 2
    int 0x80
    jmp print_total
print_fpos:
    call print_uint

print_total:
    ; Total Count
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_cnt
    mov edx, 14
    int 0x80
    mov eax, [total_count]
    call print_uint

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

; ---------------- memory (exit) ----------------
exit_program:
    mov eax, 1
    xor ebx, ebx
    int 0x80

; --- Subroutines ---

; Видаляє \n та повертає довжину
sanitize_input:
    xor edx, edx
.loop:
    mov al, [ecx + edx]
    cmp al, 10
    je .fix
    cmp al, 0
    je .done
    inc edx
    jmp .loop
.fix:
    mov byte [ecx + edx], 0
.done:
    mov eax, edx
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