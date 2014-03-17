outrun-scala:
	scalac *.scala

outrun-c:
	gcc *.c

outrun-asm:
	gcc *.s

cleanish:
	rm -f *.class *.o
