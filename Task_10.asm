
format ELF64
public _start

section '.data' writeable
    password db '1234'
    password_len = $ - password

    msg_input db 'Enter password: '
    input_len = $ - msg_input

    msg_wrong db 'Incorrect password', 10
    wrong_len = $ - msg_wrong

    msg_success db 'Successful', 10
    success_len = $ - msg_success

    msg_fail db 'Failed', 10
    fail_len = $ - msg_fail

section '.bss' writeable
    input rb 128

section '.text' executable

_start:
    mov r12, 5

auth_loop:
    ; Приглашение ко вводу
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_input
    mov rdx, input_len
    syscall

    ; Ввод пароля через read
    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 128
    syscall

    test rax, rax
    jle wrong_password

    ; Сохраняем длину введённой строки
    mov r14, rax

    ; Убираем символ перевода строки
    xor rcx, rcx

find_end:
    cmp rcx, r14
    jge check_length

    cmp byte [input+rcx], 10
    je check_length

    inc rcx
    jmp find_end

check_length:
    ; Проверяем длину пароля
    cmp rcx, password_len
    jne wrong_password

    ; Сравниваем пароль посимвольно
    xor rsi, rsi

compare_loop:
    cmp rsi, password_len
    jge correct_password

    mov al, [input+rsi]
    cmp al, [password+rsi]
    jne wrong_password

    inc rsi
    jmp compare_loop

correct_password:
    ; Пароль правильный
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_success
    mov rdx, success_len
    syscall

    jmp exit_program

wrong_password:
    ; Выводим сообщение об ошибке
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_wrong
    mov rdx, wrong_len
    syscall

    ; Уменьшаем количество попыток
    dec r12
    jnz auth_loop

    ; Все попытки использованы
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_fail
    mov rdx, fail_len
    syscall

exit_program:
    mov rax, 60
    xor rdi, rdi
    syscall
