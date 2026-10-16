format ELF64
public _start

section '.bss' writeable
    buffer rb 1048576

section '.text' executable

_start:
    ; Проверка аргументов
    cmp qword [rsp], 3
    jne exit

    ; Открытие входного файла
    mov rax, 2
    mov rdi, [rsp+16]
    xor rsi, rsi
    syscall
    test rax, rax
    js exit
    mov r14, rax

    ; Чтение файла
    xor rax, rax
    mov rdi, r14
    mov rsi, buffer
    mov rdx, 1048576
    syscall
    test rax, rax
    js close_input
    mov r13, rax

    ; Закрытие входного файла
    mov rax, 3
    mov rdi, r14
    syscall

    xor r8, r8          ; Начало предложения
    xor r9, r9          ; Текущая позиция

scan_text:
    cmp r9, r13
    jae write_result

    mov al, [buffer+r9]

    ; Проверка конца предложения
    cmp al, '.'
    je reverse_sentence

    cmp al, '!'
    je reverse_sentence

    cmp al, '?'
    je reverse_sentence

    inc r9
    jmp scan_text

reverse_sentence:
    ; Левая и правая границы предложения
    mov r10, r8
    mov r11, r9

reverse_loop:
    cmp r10, r11
    jae reverse_done

    ; Обмен символов
    mov al, [buffer+r10]
    mov dl, [buffer+r11]

    mov [buffer+r10], dl
    mov [buffer+r11], al

    inc r10
    dec r11

    jmp reverse_loop

reverse_done:
    ; Следующее предложение
    lea r8, [r9+1]
    inc r9
    jmp scan_text

write_result:
    ; Создание выходного файла
    mov rax, 2
    mov rdi, [rsp+24]
    mov rsi, 577
    mov rdx, 420
    syscall
    test rax, rax
    js exit
    mov r15, rax

    ; Запись результата
    mov rdi, r15
    mov rsi, buffer
    mov rdx, r13

write_loop:
    test rdx, rdx
    jz finish

    mov rax, 1
    syscall
    test rax, rax
    jle close_output

    add rsi, rax
    sub rdx, rax

    jmp write_loop

close_output:
    mov rax, 3
    mov rdi, r15
    syscall
    jmp exit

finish:
    mov rax, 3
    mov rdi, r15
    syscall

exit:
    mov rax, 60
    xor rdi, rdi
    syscall

close_input:
    mov rax, 3
    mov rdi, r14
    syscall
    jmp exit
