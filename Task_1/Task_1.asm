format ELF64
public _start
public exit
public print_symb

section '.data' writable
    S db "AMVtdiYVETHnNhuYwnWDVBqL"
    S_len = $ - S
    place db 1

section '.text' executable
_start:
    mov rcx, S_len
    .iter:
        mov al, [S + rcx - 1]
        push rcx
        call print_symb
        pop rcx
        dec rcx
        cmp rcx, 0
    jne .iter
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
