; practice11.asm
; I/O: int 80h (sys_read, sys_write)
; blocks: I/O, parse, math, logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
    prompt      db "Enter height (5-25): ", 0
    prompt_len  equ $ - prompt
    newline     db 10

SECTION .bss
    buf         resb 16
    line_buf    resb 128      ; буфер для формування одного рядка
    h           resd 1

SECTION .text
_start:

; ---------------- I/O (Input) ----------------
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buf
    mov edx, 16
    int 0x80

; ---------------- parse (Height) ----------------
    call str_to_int
    mov [h], eax

; ---------------- loops (Outer: Rows) ----------------
    xor esi, esi        ; i = 0 (поточний рядок)
row_loop:
    cmp esi, [h]
    jge exit

    ; Підготовка до формування рядка в line_buf
    mov edi, line_buf

    ; math (spaces = h - i - 1)
    mov ecx, [h]
    sub ecx, esi
    dec ecx
    js skip_spaces      ; якщо h=1 і i=0

; ---------------- loops (Inner 1: Spaces) ----------------
space_loop:
    test ecx, ecx
    jz skip_spaces
    mov byte [edi], ' '
    inc edi
    loop space_loop

skip_spaces:
    ; math (stars = 2 * i + 1)
    mov ecx, esi
    shl ecx, 1
    inc ecx

; ---------------- loops (Inner 2: Stars) ----------------
star_loop:
    mov byte [edi], '*'
    inc edi
    loop star_loop

    ; додаємо перенос рядка в буфер
    mov byte [edi], 10
    inc edi

; ---------------- I/O (Print Buffer) ----------------
    ; Розрахунок довжини сформованого рядка
    mov edx, edi
    sub edx, line_buf
    mov ecx, line_buf
    call print_line

    inc esi
    jmp row_loop

; ---------------- memory (exit) ----------------
exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

; --- Subroutines ---

; print_line(ecx=buf, edx=len)
print_line:
    push eax
    push ebx
    mov eax, 4
    mov ebx, 1
    int 0x80
    pop ebx
    pop eax
    ret

str_to_int:
    xor eax, eax
    mov ebx, buf
.next:
    movzx edx, byte [ebx]
    cmp dl, 10
    je .done
    cmp dl, '0'
    jb .done
    cmp dl, '9'
    ja .done
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc ebx
    jmp .next
.done:
    ret