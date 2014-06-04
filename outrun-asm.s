# Outrun calculator in asm

.section .data

filenamemissing:
.asciz "Anna tiedoston nimi argumenttina\n"
filesizestr:
.asciz "Tiedoston koko on %ld\n"
readmode:
.asciz "r"
lineendsinspace:
.asciz "Rivi ei saa paattya tyhjaan\n"

printresult:
.asciz "Suurin summa on %d\n"

printheightsize:
.asciz "korkeus: %d, koko: %d\n"

.equ filename, -8
.equ filesize, -16
.equ filebuffer, -24
.equ contentend, -32
.equ tree_height, -40
.equ tree_size, -48
.equ tree_buffer, -56
.equ stack_space, 64

.section .text
.globl main
main:
  push %rbp
  mov %rsp, %rbp 
  sub $64, %rsp # reserve space on the stack
  cmp $2, %rdi
  jne noarg

  # save file name
  mov %rsi, %r8
  add $8, %r8
  mov (%r8), %r9
  mov %r9, filename(%rbp) # save the filename

  # get file size
  call get_file_size
  mov %rax, filesize(%rbp) # file size

  # alloc buffer
  mov filesize(%rbp), %rdi
  inc %rdi
  call malloc
  mov %rax, filebuffer(%rbp) # buffer


  # open file
  mov filename(%rbp), %rdi
  mov $readmode, %rsi
  call fopen
 
  # read file
  mov filebuffer(%rbp), %rdi # buf
  mov $1, %rsi # size
  mov filesize(%rbp), %rdx # count
  mov %rax, %rcx # file pointer
  call fread

  # Read file from end to beginning

  # calculate address of last element
  mov filebuffer(%rbp), %rax
  add filesize(%rbp), %rax
  dec %rax

skipnewlinesfromend:
  movzbl (%rax), %ebx
  cmp $10, %ebx
  dec %rax
  je skipnewlinesfromend
  
  mov %rax, contentend(%rbp) # save the address of last non-newline char
  movzbl (%rax), %ebx
  cmp $32, %ebx # lines should not end in spaces
  je dontendinspace

  # Figure out the tree size. It's the number of spaces + 1 on the last line
  xor %rbx, %rbx # count spaces in %rbx
countspaces:
  movb $32, %dh
  movb  (%rax), %ch
  cmp %dh, %ch
  jne skipinc # Only increment on space (' ' == 32)
  inc %rbx
skipinc:
  dec %rax
  movb $10, %dh
  movb (%rax), %ch
  cmp %dh, %ch
  jne countspaces # keep going until you hit '\n' == 10

  # tree height
  inc %rbx # height is spaces + 1
  mov %rbx, tree_height(%rbp)

  # tree size
  mov %rbx, %rcx
  imul %rcx, %rcx
  add %rbx, %rcx
  mov $2, %r8
  mov %rcx, %rax
  xor %rdx, %rdx
  idiv %r8
  mov %rax, tree_size(%rbp)  # tree size

  # allocate tree buffer
  mov $4, %r8 # int size
  imul %r8, %rcx
  mov %rcx, %rdi
  call malloc
  mov %rax, tree_buffer(%rbp) # tree buffer
  
  mov contentend(%rbp), %rbx # go through the file with %rbx
  xor %r10, %r10 # keep count of how many ints we have parsed
parsenext:
  xor %r8d, %r8d # this will be our next int
  movl $1, %r9d # powers of ten
  # we are guaranteed to be inside an integer, not whitespace
addnextdigit:
  movzbl (%rbx), %edx
  subl $48, %edx # substract '0'
  imull %r9d, %edx
  imull $10, %r9d # next power of ten
  addl %edx, %r8d
  dec %rbx

  movzbl (%rbx), %edx
  cmpl $32, %edx
  je skipwhitespacestartnewint
  cmpl $10, %edx
  je skipwhitespacestartnewint

  jmp addnextdigit

skipwhitespacestartnewint:
  movl %r8d, (%rax)
  add $4, %rax

actualskiploop:
  dec %rbx
  movzbl (%rbx), %edx
  cmpl $32, %edx
  je actualskiploop
  cmpl $10, %edx
  je actualskiploop

  # guaranteed to be either at int or on the first line
  
  inc %r10 # num parsed
  cmp %r10, tree_size(%rbp)
  jne parsenext

  # the tree is now parsed and in memory in reverse order
  
  # set up two pointers to go through the tree
  mov tree_buffer(%rbp), %r8 # fast pointer
  
  mov $4, %rax
  mov tree_height(%rbp), %r10
  imul %r10, %rax
  mov %r8, %r9
  add %rax, %r9 # slow pointer

  dec %r10 # use this to know when to stop
  mov %r10, %r11 # use this to know when to skip one for the fast pointer
  # go through the tree
treewalk:
  movl (%r8), %eax
  add $4, %r8
  movl (%r8), %ebx
  cmp %ebx, %eax
  cmovl %ebx, %eax # maximum of the two

  addl (%r9), %eax
  movl %eax, (%r9)
  add $4, %r9

  dec %r11
  test %r11, %r11
  jz fastpointerskip
  jmp treewalk

fastpointerskip:
  add $4, %r8
  dec %r10
  mov %r10, %r11
  test %r10, %r10
  jnz treewalk

  mov $printresult, %rdi
  mov (%r8), %rsi
  xor %rax, %rax
  call printf

  add $stack_space, %rsp
  pop %rbp
  xor %rax, %rax
  ret

noarg:
  mov $filenamemissing, %rdi
  xor %rax, %rax
  sub $8, %rsp
  call printf
  mov $1, %rdi
  call exit

dontendinspace:
  mov $lineendsinspace, %rdi
  xor %rax, %rax
  call printf
  mov $2, %rdi
  call exit

