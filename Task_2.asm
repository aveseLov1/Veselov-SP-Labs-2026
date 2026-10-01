
format ELF64
public _start

section '.data' writeable
    msg_result db 'Result = '
    msg_len = $ - msg_result

    msg_error db 'Error: division by zero', 10
    err_len = $ - msg_error

    newline db 10

section '.bss' writeable
    a   rq 1
    b   rq 1
    c   rq 1
    buf rb 32

section '.text' executable

_start:
    ; Сохраняем адрес argv
    mov r15, rsp

    ; Проверяем количество аргументов
    cmp qword [r15], 4
    jne exit_error

    ; Получаем a
    mov rdi, [r15+16]
    call atoi
    mov [a], rax

    ; Получаем b
    mov rdi, [r15+24]
    call atoi
    mov [b], rax

    ; Получаем c
    mov rdi, [r15+32]
    call atoi
    mov [c], rax

    ; Проверяем b = 0
    mov rbx, [b]
    test rbx, rbx
    jz division_error

    ; Вычисляем (c-b)-b
    mov rax, [c]
    sub rax, rbx
    sub rax, rbx

    ; Делим на b
    cqo
    idiv rbx

    ; Сохраняем результат
    mov r12, rax

    ; Выводим текст
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_result
    mov rdx, msg_len
    syscall

    ; Выводим число
    mov rax, r12
    call print_number

    ; Завершаем программу
    mov rax, 60
    xor rdi, rdi
    syscall


; --------------------------------
; Преобразование строки в число
; Вход: RDI = адрес строки
; Выход: RAX = число
; --------------------------------

atoi:
    xor rax, rax
    xor r8, r8

    mov r9, 1

    cmp byte [rdi], '-'
    jne .loop

    mov r9, -1
    inc rdi

.loop:
    movzx rdx, byte [rdi]
    test rdx, rdx
    jz .done

    cmp rdx, '0'
    jb .done
    cmp rdx, '9'
    ja .done

    imul rax, 10
    sub rdx, '0'
    add rax, rdx

    inc rdi
    jmp .loop

.done:
    imul rax, r9
    ret


; --------------------------------
; Вывод знакового числа
; Вход: RAX = число
; --------------------------------

print_number:
    lea rsi, [buf+32]
    mov r8, 10

    xor r9d, r9d
    test rax, rax
    jns .convert

    mov r9b, 1
    neg rax

.convert:
    xor edx, edx
    div r8

    add dl, '0'
    dec rsi
    mov [rsi], dl

    test rax, rax
    jnz .convert

    test r9b, r9b
    jz .output

    dec rsi
    mov byte [rsi], '-'

.output:
    lea rdx, [buf+32]
    sub rdx, rsi

    mov rax, 1
    mov rdi, 1
    syscall

    ret


division_error:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_error
    mov rdx, err_len
    syscall

    jmp exit_error


exit_error:
    mov rax, 60
    mov rdi, 1
    syscall
