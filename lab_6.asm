
format ELF64
public main

extrn initscr
extrn endwin
extrn start_color
extrn init_pair
extrn noecho
extrn cbreak
extrn curs_set
extrn nodelay
extrn wgetch
extrn wmove
extrn waddch
extrn wattron
extrn wattroff
extrn wrefresh
extrn napms
extrn ioctl

section '.data' writeable

    winsz dw 0, 0, 0, 0

    delay dd 80
    current_pair dd 1

section '.text' executable

main:

    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    ; Инициализация ncurses
    call initscr
    mov rbp, rax

    call start_color
    call noecho
    call cbreak

    mov edi, 0
    call curs_set

    ; Красный цвет
    mov edi, 1
    mov esi, 1
    xor edx, edx
    call init_pair

    ; Зеленый цвет
    mov edi, 2
    mov esi, 2
    xor edx, edx
    call init_pair

    ; Неблокирующее чтение клавиатуры
    mov rdi, rbp
    mov esi, 1
    call nodelay

    ; Получение размеров терминала
    mov edi, 1
    mov esi, 0x5413
    lea rdx, [winsz]
    xor eax, eax
    call ioctl

    movzx r15d, word [winsz]
    movzx ebx, word [winsz + 2]

    ; Проверка размеров
    test r15d, r15d
    jnz .rows_ok
    mov r15d, 24

.rows_ok:

    test ebx, ebx
    jnz .cols_ok
    mov ebx, 80

.cols_ok:

    ; Начальная позиция: правый верхний угол
    xor r12d, r12d

    mov r13d, ebx
    dec r13d

    ; Направление влево
    mov r14d, -1

    ; Первый цвет - красный
    mov dword [current_pair], 1

.loop:

    ; Проверка клавиатуры
    mov rdi, rbp
    call wgetch

    ; Выход по R
    cmp eax, 'r'
    je .exit

    ; Изменение скорости по H
    cmp eax, 'h'
    jne .draw

    mov eax, [delay]

    cmp eax, 20
    jbe .reset_speed

    sub eax, 10
    mov [delay], eax
    jmp .draw

.reset_speed:

    mov dword [delay], 100

.draw:

    ; Включение текущего цвета
    mov rdi, rbp
    mov esi, [current_pair]
    shl esi, 8
    call wattron

    ; Перемещение курсора
    mov rdi, rbp
    mov esi, r12d
    mov edx, r13d
    call wmove

    ; Выбор символа
    cmp r14d, -1
    jne .draw_right

    ; Движение влево
    test r13d, r13d
    jz .arrow_left

    mov esi, '-'
    jmp .print

.arrow_left:

    mov esi, '<'
    jmp .print

.draw_right:

    ; Проверка последнего столбца
    mov eax, ebx
    dec eax

    cmp r13d, eax
    je .arrow_right

    mov esi, '-'
    jmp .print

.arrow_right:

    mov esi, '>'

.print:

    ; Вывод горизонтальной линии
    mov rdi, rbp
    call waddch

    ; Выключение цвета
    mov rdi, rbp
    mov esi, [current_pair]
    shl esi, 8
    call wattroff

    ; Обновление экрана
    mov rdi, rbp
    call wrefresh

    ; Задержка
    mov edi, [delay]
    call napms

    ; Проверка направления
    cmp r14d, -1
    jne .move_right

    ; Движение влево
    test r13d, r13d
    jz .turn_right

    dec r13d
    jmp .loop

.turn_right:

    ; Проверка нижней границы
    mov eax, r12d
    add eax, 2
    cmp eax, r15d
    jae .restart

    ; Включение текущего цвета
    mov rdi, rbp
    mov esi, [current_pair]
    shl esi, 8
    call wattron

    ; Стрелка вниз на левом краю
    mov rdi, rbp
    mov esi, r12d
    inc esi
    xor edx, edx
    call wmove

    mov rdi, rbp
    mov esi, 'v'
    call waddch

    ; Выключение цвета
    mov rdi, rbp
    mov esi, [current_pair]
    shl esi, 8
    call wattroff

    mov rdi, rbp
    call wrefresh

    ; Переход на следующую строку
    add r12d, 2
    mov r14d, 1

    jmp .loop

.move_right:

    ; Проверка правого края
    mov eax, ebx
    dec eax

    cmp r13d, eax
    je .turn_left

    inc r13d
    jmp .loop

.turn_left:

    ; Проверка нижней границы
    mov eax, r12d
    add eax, 2
    cmp eax, r15d
    jae .restart

    ; Включение текущего цвета
    mov rdi, rbp
    mov esi, [current_pair]
    shl esi, 8
    call wattron

    ; Стрелка вниз строго в последнем столбце
    mov rdi, rbp
    mov esi, r12d
    inc esi

    mov edx, ebx
    dec edx

    call wmove

    mov rdi, rbp
    mov esi, 'v'
    call waddch

    ; Выключение цвета
    mov rdi, rbp
    mov esi, [current_pair]
    shl esi, 8
    call wattroff

    mov rdi, rbp
    call wrefresh

    ; Переход на следующую строку
    add r12d, 2

    mov r13d, ebx
    dec r13d

    mov r14d, -1

    jmp .loop

.restart:

    ; Возврат в начальную позицию
    xor r12d, r12d

    mov r13d, ebx
    dec r13d

    mov r14d, -1

    ; Смена цвета
    cmp dword [current_pair], 1
    jne .set_red

    mov dword [current_pair], 2
    jmp .loop

.set_red:

    mov dword [current_pair], 1
    jmp .loop

.exit:

    ; Завершение ncurses
    call endwin

    xor eax, eax

    add rsp, 8

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx

    ret
