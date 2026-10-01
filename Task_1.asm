
format ELF64
public _start

section '.data' writeable
    msg db 'ASCII code = '
    msg_len = $ - msg
    newline db 10

section '.bss' writeable
    buffer rb 32

section '.text' executable

_start:
    ; Проверяем количество аргументов
    mov rax, [rsp]
    cmp rax, 2
    jne exit_error

    ; Получаем первый символ аргумента
    mov rsi, [rsp+16]
    movzx rax, byte [rsi]

    ; Сохраняем ASCII-код
    mov r12, rax

    ; Выводим сообщение
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, msg_len
    syscall

    ; Выводим число
    mov rax, r12
    call print_number

    ; Перевод строки
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    jmp exit_success

print_number:
    lea rsi, [buffer+32]
    mov r8, 10

.convert:
    xor edx, edx
    div r8
    add dl, '0'
    dec rsi
    mov [rsi], dl
    test rax, rax
    jnz .convert

    lea rdx, [buffer+32]
    sub rdx, rsi

    mov rax, 1
    mov rdi, 1
    syscall
    ret

exit_error:
    mov rax, 60
    mov rdi, 1
    syscall

exit_success:
    mov rax, 60
    xor rdi, rdi
    syscall
