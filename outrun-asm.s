# Outrun calculator in asm

.section .data

filenamemissing:
.ascii "Anna tiedoston nimi argumenttina\n\0"

.section .text
.globl main
main:
  cmp $2, %rdi
  jne noarg

  

  mov $0, %rax
  ret

noarg:
  mov $filenamemissing, %rdi
  xor %rax, %rax
  call printf
  mov $1, %rdi
  call exit


