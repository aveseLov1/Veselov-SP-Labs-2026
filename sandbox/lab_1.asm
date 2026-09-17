format ELF executable 3
entry start

segment readable executable
start:
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    mov ecx, fam        ; адрес строки
    mov edx, fam_len
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, nam
    mov edx, nam_len
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, otch
    mov edx, otch_len
    int 0x80

    mov eax, 1          ; sys_exit
    xor ebx, ebx
    int 0x80

segment readable writeable
fam  db 'Веселов', 0x0A
fam_len = $ - fam
nam  db 'Артём', 0x0A
nam_len = $ - nam
otch db 'Денисович', 0x0A
otch_len = $ - otch
