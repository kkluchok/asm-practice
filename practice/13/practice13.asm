; practice13.asm - Memory operations: Array reverse & Palindrome check
; I/O: sys_read/sys_write (int 80h)
; blocks: I/O, parse, logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
    msg_n      db "Enter n (5-200): ", 0
    msg_item   db "Enter number: ", 0
    msg_orig   db "Original: ", 0
    msg_rev    db 10, "Reversed: ", 0
    msg_pal    db 10, "PALINDROME: ", 0
    msg_yes    db "YES", 10, 0
    msg_no     db "NO", 10, 0
    space      db " ", 0

SECTION .bss
    n_val      resd 1
    array1     resd 200      ; Вихідний масив
    array2     resd 200      ; Буфер для реверсу
    tmp_buf    resb 32
    tmp_char   resb 2

SECTION .text
_start:

; ---------------- I/O (Read n) ----------------
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_n
    mov edx, 17
    int 0x80

    call read_int
    mov [n_val], eax

; ---------------- loops (Fill Array) ----------------
    xor esi, esi
fill_loop:
    cmp esi, [n_val]
    jge start_processing

    push esi
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_item
    mov edx, 14
    int 0x80
    
    call read_int
    pop esi
    mov [array1 + esi*4], eax
    inc esi
    jmp fill_loop

; ---------------- memory (Copy & Reverse) ----------------
start_processing:
    ; Копіювання з реверсом: array1 (початок) -> array2 (кінець)
    mov ecx, [n_val]
    lea esi, [array1]
    lea edi, [array2]
    mov eax, ecx
    dec eax
    shl eax, 2
    add edi, eax        ; EDI вказує на останній елемент array2

reverse_copy:
    mov edx, [esi]
    mov [edi], edx
    add esi, 4
    sub edi, 4
    loop reverse_copy

; ---------------- I/O (Print Original) ----------------
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_orig
    mov edx, 10
    int 0x80
    lea esi, [array1]
    call print_array

; ---------------- I/O (Print Reversed) ----------------
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_rev
    mov edx, 11
    int 0x80
    lea esi, [array2]
    call print_array

; ---------------- logic (Palindrome check) ----------------
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_pal
    mov edx, 12
    int 0x80

    mov ecx, [n_val]
    lea esi, [array1]
    lea edi, [array2]
    cld                 ; Clear direction flag
    repe cmpsd          ; Порівнюємо блоки пам'яті (array1 vs array2)
    jne .not_pal

    mov ecx, msg_yes
    mov edx, 4
    jmp .finish_pal
.not_pal:
    mov ecx, msg_no
    mov edx, 3
.finish_pal:
    mov eax, 4
    mov ebx, 1
    int 0x80

; ---------------- memory (Exit) ----------------
    mov eax, 1
    xor ebx, ebx
    int 0x80

; --- Допоміжні підпрограми ---

read_int:
    ; Читає рядок і перетворює в число
    mov eax, 3
    mov ebx, 0
    mov ecx, tmp_buf
    mov edx, 31
    int 0x80
    
    xor eax, eax
    mov esi, tmp_buf
.p_loop:
    movzx edx, byte [esi]
    cmp dl, 10
    je .p_end
    cmp dl, '0'
    jb .p_end
    cmp dl, '9'
    ja .p_end
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc esi
    jmp .p_loop
.p_end:
    ret

print_array:
    ; Друкує [n_val] чисел з адреси в ESI
    mov ebp, [n_val]
.print_loop:
    test ebp, ebp
    jz .done
    mov eax, [esi]
    push esi
    push ebp
    call write_num
    
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    
    pop ebp
    pop esi
    add esi, 4
    dec ebp
    jmp .print_loop
.done:
    ret

write_num:
    ; Перетворює число в EAX на рядок і друкує
    mov ebx, 10
    xor ecx, ecx
.c1: xor edx, edx
    div ebx
    push edx
    inc ecx
    test eax, eax
    jnz .c1
.c2: pop edx
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
    ret