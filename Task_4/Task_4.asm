format ELF64
public _start
public exit
public print_symb

section '.data' writable
    num dq 5277616985
    place db ?

section '.text' executable
_start:
    mov rax, [num]
    xor r8, r8
    mov rcx, 10
    .iter:
        xor rdx, rdx
        div rcx
        add r8, rdx
        cmp rax, 0
    jne .iter

    mov rax, r8
    mov rcx, 10
    xor rbx, rbx
    .print_loop:
        xor rdx, rdx
        div rcx
        add rdx, '0'
        push rdx
        inc rbx
        cmp rax, 0
    jne .print_loop
    .pop_loop:
        pop rax
        push rbx
        call print_symb
        pop rbx
        dec rbx
        cmp rbx, 0
    jne .pop_loop

    mov al, 0xA
    call print_symb
    call exit

print_symb:
    push rax
    mov eax, 4
    mov ebx, 1
    pop rdx
    mov [place], dl
    mov ecx, place
    mov edx, 1
    int 0x80
    ret

exit:
    mov eax, 1
    mov ebx, 0
    int 0x80
