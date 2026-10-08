
format ELF64
public _start

section '.bss' writeable
    input rb 128
    output rb 32

section '.data' writeable
    msg db 'Enter n: '
    msg_len = $ - msg
    result_msg db 'Result = '
    result_len = $ - result_msg
    newline db 10

section '.text' executable

_start:
    ; Приглашение ко вводу
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, msg_len
    syscall

    ; Читаем n
    call read_int
    mov r12, rax

    xor r14, r14
    mov r13, 1

sum_loop:
    cmp r13, r12
    jg sum_done

    ; k * (k+1)
    mov rax, r13
    lea rbx, [r13+1]
    imul rax, rbx

    ; Умножаем на (3k+1)
    mov rbx, r13
    imul rbx, 3
    add rbx, 1
    imul rax, rbx

    ; Умножаем на (3k+2)
    mov rbx, r13
    imul rbx, 3
    add rbx, 2
    imul rax, rbx

    ; (-1)^k
    test r13, 1
    jz positive

    neg rax

positive:
    add r14, rax

    inc r13
    jmp sum_loop

sum_done:
    ; Вывод результата
    mov rax, 1
    mov rdi, 1
    mov rsi, result_msg
    mov rdx, result_len
    syscall

    mov rax, r14
    call print_int
    call print_newline

    jmp exit_program


; Чтение целого числа
read_int:
    xor eax, eax
    xor edi, edi
    mov rsi, input
    mov edx, 128
    syscall

    test rax, rax
    jle read_zero

    mov rcx, rax
    mov rsi, input
    xor eax, eax
    mov r8, 1

    cmp byte [rsi], '-'
    jne parse_loop

    mov r8, -1
    inc rsi
    dec rcx

parse_loop:
    test rcx, rcx
    jz parse_done

    movzx rdx, byte [rsi]
    cmp rdx, '0'
    jb parse_done
    cmp rdx, '9'
    ja parse_done

    imul rax, 10
    sub rdx, '0'
    add rax, rdx

    inc rsi
    dec rcx
    jmp parse_loop

parse_done:
    imul rax, r8
    ret

read_zero:
    xor eax, eax
    ret


; Вывод целого числа
print_int:
    lea rsi, [output+32]
    mov r8, 10
    xor r9d, r9d

    test rax, rax
    jns convert

    mov r9b, 1
    neg rax

convert:
    xor edx, edx
    div r8
    add dl, '0'
    dec rsi
    mov [rsi], dl

    test rax, rax
    jnz convert

    test r9b, r9b
    jz output_number

    dec rsi
    mov byte [rsi], '-'

output_number:
    lea rdx, [output+32]
    sub rdx, rsi

    mov rax, 1
    mov rdi, 1
    syscall
    ret


print_newline:
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    ret


exit_program:
    mov rax, 60
    xor rdi, rdi
    syscall
