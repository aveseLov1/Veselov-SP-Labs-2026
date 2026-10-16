format ELF64
public _start

section '.bss' writeable
    buffer      rb 1048576
    outbuf      rb 1048576
    starts      rq 131072
    lengths     rq 131072

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

    ; Проверка последнего символа
    xor rbx, rbx
    test r13, r13
    jz parse_lines

    cmp byte [buffer+r13-1], 10
    jne parse_lines
    mov rbx, 1

parse_lines:
    xor r9, r9          ; Количество строк
    xor r8, r8          ; Начало текущей строки
    xor rcx, rcx        ; Индекс символа

scan_lines:
    cmp rcx, r13
    jae finish_scan

    cmp byte [buffer+rcx], 10
    jne next_char

    mov [starts+r9*8], r8

    mov rax, rcx
    sub rax, r8
    mov [lengths+r9*8], rax

    inc r9
    lea r8, [rcx+1]

next_char:
    inc rcx
    jmp scan_lines

finish_scan:
    ; Последняя строка без символа перевода строки
    cmp r8, r13
    jae prepare_output

    mov [starts+r9*8], r8

    mov rax, r13
    sub rax, r8
    mov [lengths+r9*8], rax

    inc r9

prepare_output:
    xor r10, r10       ; Позиция в выходном буфере

    test r9, r9
    jz write_result

    dec r9

reverse_lines:
    ; Получение начала и длины строки
    mov rax, [starts+r9*8]
    mov rdx, [lengths+r9*8]

    ; Копирование строки
    lea rsi, [buffer+rax]
    lea rdi, [outbuf+r10]
    mov rcx, rdx
    rep movsb

    add r10, rdx

    ; Добавление перевода строки
    cmp r9, 0
    jne add_newline

    cmp rbx, 1
    jne next_line

add_newline:
    mov byte [outbuf+r10], 10
    inc r10

next_line:
    test r9, r9
    jz write_result

    dec r9
    jmp reverse_lines

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
    mov rsi, outbuf
    mov rdx, r10

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
