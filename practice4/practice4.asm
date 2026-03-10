section .data
    ; memory: Дані
    msg_input db "Enter number: ", 0
    len_input equ $ - msg_input
    newline db 10

section .bss
    ; memory: Резервуємо місце під вхідний буфер
    input_buf resb 16

section .text
    global _start

_start:
    ; I/O: Запит на введення (опціонально, але для зручності)
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_input
    mov edx, len_input
    int 0x80

    ; I/O: Зчитуємо рядок з консолі
    mov eax, 3          ; sys_read
    mov ebx, 0          ; stdin
    mov ecx, input_buf
    mov edx, 16
    int 0x80

    ; parse: Перетворення зчитаного рядка в число
    xor eax, eax        ; Обнуляємо результат
    mov esi, input_buf  ; Початок буфера

.parse_loop:
    movzx ebx, byte [esi]
    cmp bl, 10          ; logic: перевірка на Enter (\n)
    je .done_parse
    cmp bl, 0           ; logic: перевірка на кінець рядка
    je .done_parse

    sub bl, '0'         ; math: символ у цифру
    imul eax, 10        ; math: EAX * 10
    add eax, ebx        ; EAX + цифра

    inc esi
    jmp .parse_loop

.done_parse:
    ; За умовою завдання: покласти число в регістр AX
    and eax, 0xFFFF

    ; logic: Готуємо число для твого коду з попередньої практичної
    ; Твій код з practice3 очікує число в EAX (або AX)

    ; --- Твій код з попередньої практичної (блоками) ---
    ; math: Конвертація числа в рядок через стек
    mov ebx, 10
    xor ecx, ecx        ; Лічильник цифр

.push_digits:
    xor edx, edx
    div ebx             ; Ділимо EAX на 10, залишок в EDX
    push edx            ; Зберігаємо цифру в стек
    inc ecx             ; Збільшуємо лічильник
    test eax, eax       ; Чи залишилося число?
    jnz .push_digits

.print_loop:
    ; logic: Витягуємо цифри зі стека і друкуємо
    push ecx            ; Зберігаємо загальний лічильник

    pop eax             ; (Тут невелика правка твоєї логіки для зручності)
    pop eax             ; Дістаємо цифру
    add al, '0'         ; math: цифра в ASCII

    mov [input_buf], al ; Використовуємо буфер як тимчасове місце

    push ecx            ; Повертаємо лічильник для циклу

    ; I/O: Вивід однієї цифри
    mov eax, 4
    mov ebx, 1
    mov ecx, input_buf
    mov edx, 1
    int 0x80

    pop ecx
    loop .print_loop

    ; I/O: Вивід символу нового рядка в кінці
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; I/O: Вихід
    mov eax, 1
    xor ebx, ebx
    int 0x80