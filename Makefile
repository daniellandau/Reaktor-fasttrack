outrun-scala:
	scalac *.scala

outrun-c: OutRunCalculator.c
	gcc OutRunCalculator.c -o outrun-c

outrun-asm: *.s outrun-asm-helper.c
	gcc *.s outrun-asm-helper.c -o outrun-asm

generate: generate.c

cleanish:
	rm -f *.class *.o
