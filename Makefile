snake:	snake.o
	ld -o snake snake.o
	
snake_dbg:  snake_dbg.o
	ld -o snake_dbg snake_dbg.o
	
snake_dbg.o:	snake.asm
	nasm -o snake_dbg.o -felf64 -F dwarf -g snake.asm

snake.o:	snake.asm const.txt
	nasm -felf64 snake.asm
	
const.txt:	const.c
	gcc -o const const.c
	./const >const.txt
    
clean:
	rm --force snake.o snake snake_dbg snake_dbg.o
	
