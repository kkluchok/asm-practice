; practice8.asm
; I/O: int 80h
; blocks: I/O, parse, math, logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
    msg_minus1 db "-1", 0
    space      db " ", 0
    newline    db 10

SECTION .bss
    buf        resb 1024    ; загальний буфер для вводу
    arr        resd 100     ; основний масив
    res_idx    resd 100     ; масив знайдених індексів
    n          resd 1
    target     resd 1
    count      resd 1
    first_idx  resd 1
    tmp        resb 16      ; для конвертації чисел у рядок
    p_buf      resd 1       ; ПЕРЕЙМЕНОВАНО з ptr на p_buf (щоб не було помилок)

SECTION .text
_start:

; ---------------- I/O (Read all input) ----------------
    mov eax, 3          ; sys_read
    mov ebx, 0          ; stdin
    mov ecx, buf
    mov edx, 1024
    int 0x80

    mov dword [p_buf], buf

; ---------------- parse (n) ----------------
    call next_int
    mov [n], eax

; ---------------- loops (fill array) ----------------
    xor ecx, ecx
fill_loop:
    push ecx
    call next_int
    pop ecx
    mov [arr + ecx*4], eax
    inc ecx
    cmp ecx, [n]
    jl fill_loop

; ---------------- parse (target) ----------------
    call next_int
    mov [target], eax

; ---------------- logic (linear search) ----------------
    mov dword [first_idx], -1
    mov dword [count], 0
    xor ecx, ecx        ; i = 0
    xor edi, edi        ; j = 0

search_loop:
    mov eax, [arr + ecx*4]
    cmp eax, [target]
    jne skip_found

    inc dword [count]
    mov [res_idx + edi*4], ecx
    inc edi

    cmp dword [first_idx], -1
    jne skip_found
    mov [first_idx], ecx

skip_found:
    inc ecx
    cmp ecx, [n]
    jl search_loop

; ---------------- I/O (Output results) ----------------
    ; Вивід першого індексу
    mov eax, [first_idx]
    cmp eax, -1
    jne print_first
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_minus1
    mov edx, 2
    int 0x80
    jmp first_done
print_first:
    call print_int
first_done:
    call print_newline

    ; Вивід кількості
    mov eax, [count]
    call print_int
    call print_newline

    ; Вивід усіх індексів
    xor ecx, ecx
print_all_loop:
    cmp ecx, [count]
    jge all_done
    push ecx
    mov eax, [res_idx + ecx*4]
    call print_int
    pop ecx
    mov eax, ecx
    inc eax
    cmp eax, [count]
    jge skip_space
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    pop ecx
skip_space:
    inc ecx
    jmp print_all_loop

all_done:
    call print_newline

exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

; ---------------- FUNCTIONS ----------------

next_int:
    push ebx
    push esi
    mov esi, [p_buf]
    xor eax, eax
    xor ebx, ebx
.skip:
    mov bl, [esi]
    cmp bl, 0
    je .done
    cmp bl, '0'
    jb .next
    cmp bl, '9'
    jbe .parse
.next:
    inc esi
    jmp .skip
.parse:
    mov bl, [esi]
    cmp bl, '0'
    jb .done
    cmp bl, '9'
    ja .done
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp .parse
.done:
    mov [p_buf], esi
    pop esi
    pop ebx
    ret

print_int:
    push eax
    push ebx
    push ecx
    push edx
    mov ecx, tmp + 15
    mov byte [ecx], 0
    mov ebx, 10
    test eax, eax
    jnz .convert
    dec ecx
    mov byte [ecx], '0'
    jmp .write
.convert:
    dec ecx
    xor edx, edx
    div ebx
    add dl, '0'
    mov [ecx], dl
    test eax, eax
    jnz .convert
.write:
    mov edx, tmp + 15
    sub edx, ecx
    mov eax, 4
    mov ebx, 1
    int 0x80
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

print_newline:
    push eax
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    pop eax
    ret