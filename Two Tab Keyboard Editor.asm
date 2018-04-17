bits 16
org 0x7C00
cli
    mov ah,0x02
    mov al,6
    mov dl,0x80
    mov ch,0
    mov dh , 0
    mov cl ,2
    mov bx , startl
    int 0x13
    jmp startl
  
times (510 - ($ - $$)) db 0
db 0x55, 0xAA 
    
    startl:
    cli
    xor ax , ax
    mov ss ,ax
    mov sp , 0xffff
    mov edi , 0xb8000
    mov ebp,0xb9000
    mov esi,edi
    NULL1:
       mov byte[esi],0
       add esi,2
       cmp esi,0xB8FA0
       jne NULL1
    NULL2:
          mov byte[ebp],0
       add ebp,2
       cmp ebp,0xB9FA0
       jne NULL2
mov bx,ScanCodeTable

     M:
     call pointer
       in al,0x64
       and al,0x1
       jz M
       in al,0x60
       
  cntrlM:
   
    cmp al,0x1D ;control make
    jne cntrlB
    KL:
    mov byte[status],1
    jmp M
        
  cntrlB:
     cmp al,0x9D; control break
     jne checkChar
     mov byte[status],0
     jmp M
       
   checkChar: ; ctrl  
       cmp byte[status],1
       jne SHLmake
       cmp al,0x2E ; C
       jne VV
       call Coppy
       jmp M
       VV:
       cmp al,0x2F; V
       jne AA
       call paste
       AA:
       cmp al,0x1E ; A
       jne XX
       call Shadeall
       XX:
       cmp al,0x2D ;X
       jne M
       call Cut
       jmp M
   SHLmake:
        cmp al,0x2A ;SHL make
       jne SHRmake
       mov bx,ScanCodeTableshift
       jmp M
   SHRmake:
       cmp al,0x36 ; SHR make
       jne SHLbreak 
        mov bx,ScanCodeTableshift
        jmp M
   SHLbreak:
        cmp al,0xaa; SHL break
        jne SHRbreak
         mov bx,ScanCodeTable
          jmp M
   SHRbreak:
         cmp al,0xB6; SH break
         jne DWNarraw
         mov bx,ScanCodeTable
         jmp M
       
  DWNarraw:
       cmp al,0x50 ;arraw down make
       jne UParraw
       call RemovShade
       add edi,160
       jmp M
  UParraw:
       cmp al,0x48; UP arraw make 
       jne LFTarraw
       call RemovShade
       sub edi,160
       jmp M
  LFTarraw: 
       cmp al,0x4B; left arraw make
       jne RIGHTarraw
       call RemovShade
       sub edi,2   
       jmp M
       
  RIGHTarraw: 
       cmp al,0x4D; right arraw make
       jne  Entr
       call RemovShade
       add edi,2
       jmp M
  Entr:
       cmp al,0x1C ;enter make
       jne delete
       cmp byte[edi+2],0
       je C
       mov eax,edi
       cmp byte[page],0
       je DF
       sub eax,0xb9000 
       jmp D
       DF:
       sub eax,0xB8000
       D:
       mov ecx,160
       xor edx,edx
       div ecx
       sub edx,160
       neg edx

       mov ecx,edx
       shr ecx,1
       mov al,0
    QR:
       push ecx
       mov esi,edi
       mov cl,[esi]
      jR:
       mov dl,cl
       add esi,2
       mov cl,[esi]
       mov[esi],dl
       cmp cl,0
       jne jR
       mov [edi],al
       add edi,2
       pop ecx
       loop QR
       jmp M
       
     C: 
       mov eax,edi
       cmp byte[page],0
       je df
       sub eax,0xb9000 
       jmp D2
       df:
       sub eax,0xB8000
       D2:
       mov ecx,160
       xor edx,edx
       div ecx
       sub edx,160
       neg edx
       add edi,edx 
       jmp M
  delete:
      cmp al,0x53; delete make
      jne backspace
      mov esi,edi
      K:
      mov cl,[esi+2]
      mov [esi],cl
      add esi,2
      cmp cl,0 
      jne K
      jmp M 
  backspace:
      cmp al,0x0E; bckspace make
      jne capslock
      call Delt
      mov esi,edi
     L:
      mov cl,[esi]
      mov [esi-2],cl
      add esi,2
      cmp cl,0 
      jne L
      sub edi,2
      jmp M   
      
capslock:
      cmp al,0x3A ;capslock make
      jne  Multitabs    
      cmp bx ,ScanCodeTableCapslock
      jne SG
      mov bx, ScanCodeTable
      jmp M
    SG:
      mov bx, ScanCodeTableCapslock
      jmp M

      
  Multitabs:
      cmp al,0x3B ; F1
      jne F2
      
      cmp byte[page],0
      je M
      
      mov [saveaddrs+4],edi  
      mov byte[page],0
      mov edi,[saveaddrs]
      mov al,0 ; page
      mov ah,5 ; change video page
      int 0x10
      jmp M
      F2:
      cmp al,0x3C; F2
      jne home
      
      cmp byte[page],1
      je M
      
      mov [saveaddrs],edi
      mov byte[page],1
     mov edi,[saveaddrs+4]
     mov al,1 ; page
      mov ah,5 ; change video page
      int 0x10
      jmp M
      
 home:
     cmp al,0x47;home make
     jne end
     mov eax,edi
     cmp byte[page],0
     je D3
     sub eax,0xb9000 
     jmp RY
     D3:
     sub eax,0xB8000
    RY:
     mov ecx,160     
     xor edx,edx
     div ecx
     sub  edi,edx 
     jmp M
     
 end:  
    cmp al,0x4F ;end make
    jne Shading
    mov eax,edi
    cmp byte[page],0
    je p11
    sub eax,0xB9000
    jmp po1
    p11:
    sub eax,0xB8000
    po1:
    mov ecx,160
    xor edx,edx
    div ecx  
    sub edx,160
    neg edx
    sub edx,2
    add edi,edx
    bak:
    cmp byte[edi-2],0
    jne M
    sub edi,2
    jmp bak   
      

      
 Shading:;compare with four bytes
 
 
   cmp al,0xE0 ;araaw make
   jne  Tab
   N: 
       in al,0x64
       and al,0x1
       jz N
       in al,0x60
       cmp al,0xaa ;SHL make
       je NNL 
       SHRM:   
       cmp al,0xb6 ;SHR make
       je NNL
       jne araaws
  NNL:   
       in al,0x64
       and al,0x1
       jz NNL
       in al,0x60
       cmp al,0xE0
       jne M
  UAL: ;UP Araaw Leftshift
       in al,0x64
       and al,0x1
       jz UAL
       in al,0x60
       cmp al,0x48 ;up arraw
       jne DAL
       mov ecx,80
       TT:
       cmp byte[edi],0
       jne RT
       sub edi,2
       loop TT
       jmp M
       RT:
       mov byte[edi-1],55
       sub edi,2
       loop TT
       jmp M
 DAL: ;Dwn Araaw Leftshift
    cmp al,0x50  ;dwn araaw 
       jne RAL
       mov ecx,80
       WW:
       cmp byte[edi],0
       jne PT
       add edi,2
       loop WW
       jmp M
       PT:
       mov byte[edi+1],55
       add edi,2 
       loop WW
       jmp M
 RAL: ;Right Araaw Leftshift
   cmp al,0x4d ;right arraw
      jne LAL
      cmp byte[edi],0
      je M   
      mov byte[edi+1],55
      add edi,2 
      jmp M
 LAL: ;Left Araaw Leftshift
   cmp al,0x4b  ;left arraw                       
       je laL
       jmp M
    laL:
     cmp byte[edi-2],0
     je M
     mov byte[edi-1],55
     sub edi,2
     jmp M
         
  araaws:   
    cmp al,0x48 ; up make
    je UParraw
    cmp al,0x50  ;dwn make
    je DWNarraw
    cmp al,0x4d ;right make
    je RIGHTarraw
    cmp al,0x4b ; left make
    je  LFTarraw
    cmp al,0x47 ;home make
    je home
    cmp al,0x4F ;end make
    je end
    cmp al,0x53; delete make
    je delete
      jmp M
      
 Tab:
    cmp al,0x0F; TAB make 
    jne  print
    mov ecx,4
    mov al,' '
    WE:
    push ecx
       mov esi,edi
       mov cl,[esi]
       jj:
       mov dl,cl
       add esi,2
       mov cl,[esi]
       mov[esi],dl
       cmp cl,0
       jne jj
       mov [edi],al
       add edi,2
    pop ecx
       loop WE
       jmp M
             
   print: 
       
       cmp al,0x80
       ja M       
       ;Shifting:  12345
       mov esi,edi
       mov cl,[esi]
       j:
       mov dl,cl
       add esi,2
       mov cl,[esi]
       mov[esi],dl
       cmp cl,0
       jne j
       xlat 
       mov [edi],al
       add edi,2
       jmp M
       
    pointer:
    push ebx
    mov eax,edi
    cmp byte[page],0
    je p1
    sub eax,0xB9000
    jmp po
    p1:
    sub eax,0xB8000
    po:
    mov ecx,160
    xor edx,edx
    div ecx 
    ;edx= col (dl) , eax= row (dh)
    shr dl,1 ; from 160 to 80 
    mov dh,al
    
    mov bh,[page]
    mov ah,2
    int 0x10
    pop  ebx
    ret
      
  Coppy:
    xor ecx,ecx
    xor ebp,ebp
    cmp byte[page],0
    je I
    mov esi,0xb9000
    jmp KU
    I:
    mov esi,0xb8000
    KU:
    add esi,2
    inc ecx 
    cmp ecx,2000
    jg BN
    cmp byte[esi-1],55
    jne KU  
    mov cl,[esi-2]
    mov [Memo+ebp],cl
    inc ebp
    jmp KU
    BN:
    ret
    
   paste:
       xor ecx,ecx
       MNZR:
       push ecx
       mov esi,edi
       mov cl,[esi]
       jK:
       mov dl,cl
       add esi,2
       mov cl,[esi]
       mov[esi],dl
       cmp cl,0
       jne jK
       pop ecx
       mov al,[Memo+ecx] 
       cmp al,0
       je mn
       inc ecx
       mov [edi],al
       add edi,2
       jmp MNZR
       mn:
       ret
       
 RemovShade:
       cmp byte[page],0
       je Remove1
       jmp Remove2
      Remove1:
       mov esi,0xB8000
       re:
       mov byte[esi+1],0x07 ; screen color
       add esi,2
       cmp esi,0xB8FA0
       jb re
       ret 
      Remove2:  
        mov esi,0xB9000
       re2:
       mov byte[esi+1],0x07
       add esi,2
       cmp esi,0xB9FA0
       jb re2
       ret     
 Shadeall:
       cmp byte[page],0
       je SH1
       jmp SH2
    SH1: 
       mov esi,0xB8000
       mo:
       cmp byte[esi],0
       jne shade 
       add esi,2
       cmp esi,0xB8FA0
       ja mout
       jmp mo
      shade:
      mov byte[esi+1],55 
       add esi,2
       cmp esi,0xB8FA0
       ja mout
       jmp mo
       mout:
       ret
   SH2:    
       mov esi,0xB9000
       mo2:
       cmp byte[esi],0
       jne shade2 
       add esi,2
       cmp esi,0xB9FA0
       ja mout2
       jmp mo2
      shade2:
      mov byte[esi+1],55 
       add esi,2
       cmp esi,0xB9FA0
       ja mout2
       jmp mo2
       mout2:
       ret 
       
 Cut:
      call Coppy  
      cmp byte[page],0
      je cu1
      jmp cu2
    cu1:
      mov esi,0xb8000
      ko:
      cmp byte[esi+1],55
      je del
      add esi,2 
      cmp esi,0xB8FA0
      ja cout
      jmp ko
     del: 
      mov byte[esi],0
      add esi,2 
      cmp esi,0xB8FA0
      ja cout
      jmp ko
      cout: 
       call RemovShade
         ret
    cu2:
      mov esi,0xb9000
      ko2:
      cmp byte[esi+1],55
      je del2
      add esi,2 
      cmp esi,0xB9FA0
      ja cout2
      jmp ko2
      del2: 
      mov byte[esi],0
      add esi,2 
      cmp esi,0xB9FA0
      ja cout2
      jmp ko2
      cout2: 
       call RemovShade
         ret     
            
  Delt: 
  
          cmp byte[page],0
          je de
          jmp de2
       de:      
          mov esi,0xb8000 
          SD: 
          cmp byte[esi+1],55 ;color
          je CT    
           add esi,2
           cmp esi,0xB8FA0
           ja CTout
           jmp SD
           CT:
           mov byte[esi],0
           add esi,2
           cmp esi,0xB8FA0
           ja CTout
           jmp SD           
          CTout:
          call RemovShade
          ret 
      de2:      
          mov esi,0xb9000 
          SD2: 
          cmp byte[esi+1],55 ;color
          je CT2    
           add esi,2
           cmp esi,0xB9FA0
           ja CTout2
           jmp SD2
           CT2:
           mov byte[esi],0
           add esi,2
           cmp esi,0xB9FA0
           ja CTout2
           jmp SD2           
          CTout2:
          call RemovShade
          ret                                    
                                            
status: db 0 ; copy  
page: db 0
saveaddrs:dd 0xb8000,0xb9000
     ScanCodeTable: db   "//1234567890-=//qwertyuiop[]//asdfghjkl;'`/\zxcvbnm,.//// /" 
  ScanCodeTableshift: db '//!@#$%^&*()_+//QWERTYUIOP{}//ASDFGHJKL:"~/|ZXCVBNM<>?/// /'
ScanCodeTableCapslock:db "//1234567890-=//QWERTYUIOP[]//ASDFGHJKL;'`/\ZXCVBNM,.//// /"
Memo:times(2000) db 0 
times (0x400000 - 512) db 0

db 	0x63, 0x6F, 0x6E, 0x65, 0x63, 0x74, 0x69, 0x78, 0x00, 0x00, 0x00, 0x02
db	0x00, 0x01, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
db	0x20, 0x72, 0x5D, 0x33, 0x76, 0x62, 0x6F, 0x78, 0x00, 0x05, 0x00, 0x00
db	0x57, 0x69, 0x32, 0x6B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x78, 0x04, 0x11
db	0x00, 0x00, 0x00, 0x02, 0xFF, 0xFF, 0xE6, 0xB9, 0x49, 0x44, 0x4E, 0x1C
db	0x50, 0xC9, 0xBD, 0x45, 0x83, 0xC5, 0xCE, 0xC1, 0xB7, 0x2A, 0xE0, 0xF2
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00