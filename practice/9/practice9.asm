; practice9.asm
; I/O: int 80h (sys_read, sys_write)
; blocks: I/O, parse, math, logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
    prompt      db "Enter n (100-1000): ", 0
    prompt_len  equ $ - prompt
    row_prefix  db ": ", 0
    newline     db 10
    hash        db "#"

    ; LCG constants
    multiplier  dd 1103515245
    increment   dd 12345
    modulus     dd 2147483647 ; 2^31 - 1
    seed        dd 42         ; початкове значення

SECTION .bss
    buf         resb 16
    freq        resd 10       ; масив частот для цифр 0-9
    n           resd 1
    current_x   resd 1
    tmp_buf     resb 16

SECTION .text
_start:

; ---------------- I/O (Prompt) ----------------
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

; ---------------- I/O (Read n) ----------------
    mov eax, 3
    mov ebx, 0
    mov ecx, buf
    mov edx, 16
    int 0x80

; ---------------- parse (n) ----------------
    call str_to_int
    mov [n], eax

; ---------------- memory (init) ----------------
    mov eax, [seed]
    mov [current_x], eax

    ; Обнулення масиву частот
    xor ecx, ecx
clear_freq:
    mov dword [freq + ecx*4], 0
    inc ecx
    cmp ecx, 10
    jl clear_freq

; ---------------- loops & math (LCG generation) ----------------
    mov edi, [n]
gen_loop:
    ; LCG: x = (a*x + c) mod 2^31
    mov eax, [current_x]
    mov edx, [multiplier]
    mul edx
    add eax, [increment]
    and eax, 0x7FFFFFFF ; mod 2^31
    mov [current_x], eax

    ; Отримуємо значення 0..9 для гістограми
    xor edx, edx
    mov ebx, 10
    div ebx             ; залишок у EDX (0..9)

    ; logic (increment frequency)
    inc dword [freq + edx*4]

    dec edi
    jnz gen_loop

; ---------------- loops & I/O (Display histogram) ----------------
    xor esi, esi        ; esi = поточний рядок (0..9)
display_loop:
    ; Вивід цифри рядка
    mov eax, esi
    add eax, '0'
    mov [tmp_buf], al
    mov eax, 4
    mov ebx, 1
    mov ecx, tmp_buf
    mov edx, 1
    int 0x80

    ; Вивід префікса ": "
    mov eax, 4
    mov ecx, row_prefix
    mov edx, 2
    int 0x80

    ; loops (Print hashes)
    mov edi, [freq + esi*4] ; кількість #
    test edi, edi
    jz row_done
print_hashes:
    push eax
    push ebx
    push ecx
    push edx
    mov eax, 4
    mov ebx, 1
    mov ecx, hash
    mov edx, 1
    int 0x80
    pop edx
    pop ecx
    pop ebx
    pop eax
    dec edi
    jnz print_hashes

row_done:
    ; Перехід на новий рядок
    mov eax, 4
    mov ecx, newline
    mov edx, 1
    int 0x80

    inc esi
    cmp esi, 10
    jl display_loop

; ---------------- memory (exit) ----------------
    mov eax, 1
    xor ebx, ebx
    int 0x80

; --- Utility: String to Integer ---
str_to_int:
    xor eax, eax
    mov ecx, buf
.next_digit:
    movzx edx, byte [ecx]
    cmp dl, 10
    je .done
    cmp dl, '0'
    jb .done
    cmp dl, '9'
    ja .done
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc ecx
    jmp .next_digit
.done:
    ret