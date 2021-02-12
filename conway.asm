myss        SEGMENT PARA STACK 's'
            DW 100 DUP(?)
myss        ENDS

myds        SEGMENT PARA 'd'
n 			DW 10				;stacke input olarak atilacak olan parametre
temp 		DW ?				;registerlari saklarken push pop islemlerinde kullanilacak
myds        ENDS

mycs        SEGMENT PARA 'k'
            ASSUME CS:mycs, DS:myds, SS:myss

ANA proc    far
    push    ds
    xor     ax, ax						;DataSegmenti kullanmak icin gerekli ayarlamalar
    push    ax
    mov     ax, myds
    mov     ds, ax
 
 
    push    n            ; 10 degeri stacke parametre olarak pushlanacak, direkt integer pushlanamadigi icin sayi degiskenine atandi
    call    far ptr CONWAY  ; CONWAY proseduru stackten input degerini alacak
    pop     ax              ; CONWAYin stacke return ettigi deger AX registerina atanacak   
    call    PRINTINT        ; AXte saklanan degeri onluk tabanda ekrana yazdir
	
	
    retf
ANA endp

CONWAY proc far
	mov temp,SP
	push AX
	push CX		;kullanilan regleri sakla
	push DX
	push BX
	push temp
	push BP
           		   
    mov     bp, sp
    add     bp, 16          ; 6 adet word buyuklugunde deger pushlandi(12 byte) + 4 byte'lik far return degeri = 16
    mov     ax, [bp]        ; stackteki input degerini ax'e ata
    
    cmp     ax, 0
    ja      pozitif
    xor ax,ax     ;n =0 ise 0 degerini dondur ve bitir
    jmp     bitti
pozitif:
    cmp     ax, 2
    ja      recur			;n, 0 degilse ve 2den kucuk veya esitse 1 degeri ver ve bitir
    mov     ax, 1
    jmp     bitti

    
recur:
    dec     ax		; AXte tutulan n degeri n-1 oldu
    push    ax		; n-1 degeri hesaplanacagi icin stacke koyduk
    call    far ptr CONWAY  ; A(n-1)i cagir
    pop     bx		; A(n-1) degerini BXe ata


    push    bx
    call    far ptr CONWAY  ; A(A(n-1)) islemi
    pop     cx              ; sonucu CXe ata


    inc     ax
    sub     ax, bx			;A(n-A(n-1)) islemi
    push    ax
    call    far ptr CONWAY
    pop     ax		; sonucu AXe ata

    add     ax, cx	; bulunan degerleri topla ve sonucu bul sonuc = A(A(n-1))+A(n-A(n - 1)). AXte saklanacak
    
bitti:
    mov [bp], ax        ; AXteki sonuc stacke aktarildi
	pop BP
	add SP, 2			;SPyi pushlamadigimiz icin pop ederken stack pointer degeri 2 arttirildi, manuel bir pop islemi
	pop BX
	pop DX
	pop CX
	pop AX
                 
    retf                   
CONWAY endp

PRINTINT proc
	push cx
	push ax		;kullanilan registerlari sakla
	push dx
	push bx
    xor cx,cx 
    xor dx,dx 	;dx bolmeyi etkilemesin diye sifirlandi
lbl: 
    cmp ax,0 
    je bastir              
    mov bx,10                
    div bx          ; islemi bize son rakami verecek              
    push dx                      
    inc cx                      
    xor dx,dx 
    jmp lbl 
bastir: 
    cmp cx,0 
    je exit     
    pop dx          
    add dx,48         			;rakamin degerine 48 ekleyerek ASCII degerine ulasiyoruz  
	mov ah,2 		
    int 21h         ;rakami ekrana bastir
    dec cx 
    jmp bastir 
exit: 	
	pop bx
	pop dx
	pop ax
	pop cx
	ret                   
PRINTINT endp


mycs ENDS
     END ANA
