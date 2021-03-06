SYSEXIT		= 1
SYSREAD		= 3
SYSWRITE 	= 4
STDOUT		= 1
STDIN		= 0
EXIT_SUCCESS	= 0

MALE_POCZATEK 	= 0x61
MALE_KONIEC	= 0x7A
DUZE_POCZATEK	= 0x41
DUZE_KONIEC	= 0x5A



.align 32
.bss
	.comm bufor,1
	
.text
	text_hello: .ascii "\wpisales: \n"
	text_hello_length= . - text_hello
.data
	tablica: .space 512
.global _start 

_start:
	mov $0, %edi

petla_wczytywania:

	mov $SYSREAD, %eax
	mov $STDIN, %ebx
	mov $bufor, %ecx
	mov $1, %edx

	int $0x80

	#sprawdzam cyz to enter, zeby zakonczyc:
	mov $0xA, %ebx 
	mov bufor, %eax 
	cmp %eax, %ebx
		je ending
	
	#sprawdzam czy to duza lub mala litera:
	mov $DUZE_POCZATEK, %ebx
	mov bufor, %eax
	cmp %ebx, %eax
		jge duzalitera

	jmp dotablicy

dotablicy:

	#wprowadzam gotowe do tablicy:
	movb bufor, %ah
        movb %ah, tablica(,%edi,1)
	
	inc %edi
	jmp petla_wczytywania


duzalitera:
	#czy lapie sie w zakres duzych?
	mov $DUZE_KONIEC, %ebx
	mov bufor, %eax
	cmp %ebx, %eax
		#jesli nie, to moze jest mala:
		jg malalitera

	add $0x20, bufor
	jmp dotablicy

malalitera:
	#czy lapie sie w zakres malych?
	mov $MALE_POCZATEK, %ebx
	mov bufor, %eax
	cmp %ebx, %eax
		jl dotablicy
	
	mov $MALE_KONIEC, %ebx
	mov bufor, %eax
	cmp %ebx, %eax
		jg dotablicy
	
	mov $0x20, %ah	
	sub %ah, bufor
	
	jmp dotablicy

ending:
	inc %edi
	movb $0xA, tablica(,%edi,1)
	 
	mov $SYSWRITE, %eax
        mov $STDOUT, %ebx
        mov $text_hello, %ecx
        mov $text_hello_length, %edx

        int $0x80

        mov $SYSWRITE, %eax
        mov $STDOUT, %ebx
        mov $tablica, %ecx 
	mov %edi, %edx

        int $0x80
	
	
	mov $SYSEXIT, %eax
	mov $EXIT_SUCCESS, %ebx

	int $0x80



