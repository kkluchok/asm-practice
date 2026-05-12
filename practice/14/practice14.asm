BITS 32
GLOBAL _start

SECTION .data
    msg_n      db "N: ", 0
    msg_num    db "Num: ", 0
    msg_orig   db "Original:", 10, 0
    msg_sort   db 10, "Sorted:", 10, 0
    msg_med    db 10, "Median: ", 0
    space      db " ", 0
    newline    db 10

SECTION .bss
    n_val      resd 1
    array      resd 100
    i_idx      resd 1
    j_idx      resd 1
    min_idx    resd 1
    tmp_buf    resb 32
    tmp_char   resb 16

SECTION .text
_start:
    ; --- Ввід N ---
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_n
    mov edx, 3
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, tmp_buf
    mov edx, 30
    int 0x80

    xor eax, eax
    mov esi, tmp_buf
.p_n:
    movzx edx, byte [esi]
    cmp dl, 10
    je .p_n_e
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc esi
    jmp .p_n
.p_n_e:
    mov [n_val], eax

    ; --- Заповнення масиву ---
    mov dword [i_idx], 0
.fill:
    mov eax, [i_idx]
    cmp eax, [n_val]
    jge .show_orig
    
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_num
    mov edx, 5
    int 0x80
    
    mov eax, 3
    mov ebx, 0
    mov ecx, tmp_buf
    mov edx, 30
    int 0x80
    
    xor eax, eax
    mov esi, tmp_buf
.p_v:
    movzx edx, byte [esi]
    cmp dl, 10
    je .p_v_e
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc esi
    jmp .p_v
.p_v_e:
    mov ebx, [i_idx]
    mov [array + ebx*4], eax
    inc dword [i_idx]
    jmp .fill

.show_orig:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_orig
    mov edx, 10
    int 0x80
    
    mov dword [i_idx], 0
.p_o_l:
    mov eax, [i_idx]
    cmp eax, [n_val]
    jge .do_sort
    
    ; Вивід числа прямо тут (без call)
    mov eax, [array + eax*4]
    mov ebx, 10
    xor ecx, ecx
.c1_o: xor edx, edx
    div ebx
    push edx
    inc ecx
    test eax, eax
    jnz .c1_o
.c2_o: pop edx
    add dl, '0'
    mov [tmp_char], dl
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, tmp_char
    mov edx, 1
    int 0x80
    pop ecx
    loop .c2_o

    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    inc dword [i_idx]
    jmp .p_o_l

.do_sort:
    mov dword [i_idx], 0
.o_s:
    mov eax, [n_val]
    dec eax
    cmp [i_idx], eax
    jge .show_sort
    mov eax, [i_idx]
    mov [min_idx], eax
    inc eax
    mov [j_idx], eax
.i_s:
    mov eax, [j_idx]
    cmp eax, [n_val]
    jge .swp
    mov ebx, [min_idx]
    mov ecx, [array + eax*4]
    mov edx, [array + ebx*4]
    cmp ecx, edx
    jge .n_j
    mov [min_idx], eax
.n_j: inc dword [j_idx]
    jmp .i_s
.swp:
    mov eax, [i_idx]
    mov ebx, [min_idx]
    mov ecx, [array + eax*4]
    mov edx, [array + ebx*4]
    mov [array + eax*4], edx
    mov [array + ebx*4], ecx
    inc dword [i_idx]
    jmp .o_s

.show_sort:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_sort
    mov edx, 8
    int 0x80
    mov dword [i_idx], 0
.p_s_l:
    mov eax, [i_idx]
    cmp eax, [n_val]
    jge .med
    mov eax, [array + eax*4]
    mov ebx, 10
    xor ecx, ecx
.c1_s: xor edx, edx
    div ebx
    push edx
    inc ecx
    test eax, eax
    jnz .c1_s
.c2_s: pop edx
    add dl, '0'
    mov [tmp_char], dl
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, tmp_char
    mov edx, 1
    int 0x80
    pop ecx
    loop .c2_s
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    inc dword [i_idx]
    jmp .p_s_l

.med:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_med
    mov edx, 8
    int 0x80
    mov eax, [n_val]
    dec eax
    shr eax, 1
    mov eax, [array + eax*4]
    mov ebx, 10
    xor ecx, ecx
.c1_m: xor edx, edx
    div ebx
    push edx
    inc ecx
    test eax, eax
    jnz .c1_m
.c2_m: pop edx
    add dl, '0'
    mov [tmp_char], dl
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, tmp_char
    mov edx, 1
    int 0x80
    pop ecx
    loop .c2_m

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    mov eax, 1
    xor ebx, ebx
    int 0x80