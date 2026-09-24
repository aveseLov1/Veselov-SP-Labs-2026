format ELF64
public _start
public exit
public print_symb

section '.data' writable
    array db 66 dup ('+')
    place db 1

section '.text' executable
_start:
    mov rdx, 1            ; номер строки (1, 2, 3, ...)
    xor rcx, rcx          ; индекс в массиве array
    .row:
        mov rbx, 1        ; номер символа в строке
        .col:
            mov al, [array + rcx]
            push rdx
            push rbx
            push rcx
            call print_symb
            pop rcx
            pop rbx
            pop rdx
            inc rbx
            inc rcx
            cmp rbx, rdx  ; сравнение: номер символа <= номер строки?
        jle .col
        push rdx
        push rcx
        mov al, 0xA
        call print_symb   ; перевод строки
        pop rcx
        pop rdx
        inc rdx
        cmp rdx, 11       ; 11 строк (1+2+...+11 = 66)
    jle .row
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
