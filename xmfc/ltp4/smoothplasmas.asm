**********************************************************************
**
**
**      SmoothPlasmas (Ltp4 DemoDisk)
**
**      AsmONE version !
**
**      Auteur:
**      B.Sebastien [Ostyl]
**
**      Date:
**      25/08/00
**
**
**********************************************************************

;MakeFinal      EQU     1
;A500           EQU     1

        INCDIR  INCLUDES:
        INCLUDE Startup.asm

        INCLUDE Hardware/custom.i
        INCLUDE Hardware/dmabits.i
        INCLUDE Hardware/bplbits.i
        INCLUDE Macros/Macros.i
        INCLUDE Macros/Copper.i
        INCLUDE Macros/Blitter.i

Dep=54
Height=190

Start   _CHIP   a0
        Move    #DMAF_SETCLR+DMAF_MASTER+DMAF_BLITTER+DMAF_BLITHOG,dmacon(a0)
        Move    #INTF_SETCLR+INTF_INTEN,intena(a0)

        Moveq   #0,d0
        Lea     Song,a0
        Sub.L   a1,a1
        Lea     SampleBuffer,a2
        Bsr.W   P61_Init
        Tst.L   d0
        Bne.B   Error

        Bsr.W   InitEcran

        Move.L  #Vbl,Lev3Vbl
        Move.L  #Vbl,Lev3Copper
        Move    #INTF_SETCLR+INTF_COPPER,$dff000+intena

Main    WaitLMB Main

        _CHIP   a6
        Bsr.W   P61_End

Error   Moveq   #0,d0
        Rts

;==================================
;----------------------------------
;
Vbl     Bsr.W   Plasma
        Bsr.W   Scroller
        Move    VblCount(pc),d0
        Andi    #255,d0
        Bne.B   NoNew
        Bsr.W   ChangePlasma
NoNew   Addq    #1,VblCount

        Rts

VblCount        Dc      1

;==================================
;----------------------------------
;Initialise l'ecran
;
Largeur EQU     (320/16)*2
Hauteur EQU     180

InitEcran
        Lea     PlasmaPicPTR,a0
        Move.L  #PlasmaPic,d0
        Move    d0,6(a0)
        Swap    d0
        Move    d0,2(a0)

        Lea     ScrollPtr,a0
        Move.L  #EcranScroll,d0
        Moveq   #3,d1
        Move.L  #42*33,d2
        InitPtr
        
        _CHIP   a5
        Moveq   #0,d0                           
        IFND    A500
        Fenetre 140,44,320,246,a5
        ELSE
        Move    #$2c8c,diwstrt(a5)
        Move    #$22cc,diwstop(a5)
        ENDC
        Move    d0,bplcon2(a5)
        Lea     Copper,a0
        Move.L  a0,cop1lc(a5)   
        Move    d0,copjmp1(a5)

        Move    #DMAF_SETCLR+DMAF_COPPER,dmacon(a5)
        Rts

        Include asm:xmfc_demodisk/theplayer.asm

**********************************************************************
**
**      3 Bitplanes Scrolling
**
**********************************************************************

Scroller
        Lea     $dff002,a5

        Lea     CharsWidth(pc),a1
        Moveq   #0,d0
        Move.B  Chr(pc),d0      
        Move.B  (a1,d0.W),d1

        Move.B  ScrollCnt(pc),d0
        And.B   d1,d0
        Bne.W   ScrollEnd

Text    Lea     ScrollText(pc),a1
        Move    ChrCnt(pc),d0
        Lea     (a1,d0.W),a1
        Addq    #1,ChrCnt

        Moveq   #0,d0
        Move.B  (a1),d0
        Bne.B   Decode
        Clr     ChrCnt
        Bra.B   Text

Decode  Sub.B   #32,d0
        Move.B  d0,Chr
        Add     d0,d0
        Clr.B   ScrollCnt

;-------------------------
;---- Copie une fonte ----
;-------------------------
;
        Lea     CharSet,a1
        Lea     (a1,d0.L),a1    
        Lea     EcranScroll+40,a2
        Moveq   #-1,d0
        Move    #(944/8)-2,d2
        Move    #42-2,d3
        Move.L  #(%0000100100000000!A)<<16,d4
        Move    #(33*3*64)+1,d5
        Moveq   #0,d6

BltLoop
        WBlt    a5
        Move.L  a1,bltapt-2(a5)
        Move.L  a2,bltdpt-2(a5) 
        Move    d2,bltamod-2(a5)
        Move    d3,bltdmod-2(a5)
        Move.L  d0,bltafwm-2(a5)                
        Move.L  d4,bltcon0-2(a5)
        Move    d5,bltsize-2(a5)        

ScrollEnd

        _CHIP   a6
        Bsr.W   P61_Music

;---------------------------
;---- Decale la memoire ----
;---------------------------
;
        Lea     $dff002,a5

        Lea     EcranScroll,a1
        Lea     (42*33*3)-2(a1),a1
        Moveq   #0,d0
        Moveq   #-1,d1
        Move.L  #((%0100100100000000!A)<<16)!%10,d2
        WBlt    a5
        Move.L  a1,bltapt-2(a5)
        Move.L  a1,bltdpt-2(a5) 
        Move.L  d0,bltamod-2(a5)
        Move.L  d1,bltafwm-2(a5)                
        Move.L  d2,bltcon0-2(a5)
        Move    #(33*3*64)+21,bltsize-2(a5)

        Addq.B  #2,ScrollCnt
        Rts

CharsWidth
        Dc.B    7,3,7,7,7,7,7,7,7,7
        Dc.B    7,7,7,7,7,7,7,7,7,7
        Dc.B    7,7,7,7,7,7,7,7,7,7
        Dc.B    7,7,7,7,7,7,7,7,7,7
        Dc.B    7,3,7,7,3,7,7,7,7,7
        Dc.B    7,7,7,7,7,7,7,7,7,7
        Dc.B    7,7,7,7,7,7,7,7,7,7
        Dc.B    7,7,7,7,7,7,7,7,7,7
        EVEN

ChrCnt          Dc      0
ScrollCnt       Dc.B    0
Chr             Ds.B    1

ScrollText
        Dc.B    "         "
        Dc.B    "X-METAL FORCE CREW PRESENT TO YOU A SMALL TRIP INTO "  
        Dc.B    "PLASMA WORLD..."
        Dc.B    "             "
        Dc.B    "HAVE YOU NOTICED HOW THESE PLASMAS ARE SMOOTH ? HE! "
        Dc.B    "THIS IS BECAUSE THE COPPER SPLIT ARENT 4 PIXELS WIDTH "
        Dc.B    "BUT THEY ARE 1 PIXEL WIDTH...  "
        Dc.B    "YES, AGAIN AND AGAIN I'M UNBEATABLE....       "
        Dc.B    "CREDITS FOR THIS PART ARE: AS ALMOST USUALLY HOT CODING BY "
        Dc.B    "OSTYL, THESE NICE 3 BITPLANES CHARSET BY VISION "
        Dc.B    "         "
        Dc.B    "OH DAWN I'VE TO FILL UP THIS LAME SCROLLER...      "
        Dc.B    "YEP, I'M SITTING HERE NOW AT THIS GREAT PARTY, "
        Dc.B    "AND THE TEMPERATURE IS NOW REACHING THE HELL... "
        Dc.B    "MY AMIGA IS MELTING ON THE TABLE, OH NO !!    "
        Dc.B    "MOST OF PEOPLE ARE BUSYING AROUND ME... YEAH, IT'S COOL "
        Dc.B    "COZ NOBODY ARE PLAYING HERE !! "
        Dc.B    "          "
        Dc.B    "THE DEADLINE IS COMMING SOON AND I'VE A "
        Dc.B    "LOT OF LITTLE THINGS TO FIX ON THIS DISK... "
        Dc.B    " BYE...    KAN DU FORSTAR DANSK ??  FARVEL !     "
        Dc.B    "      AU REVOIR !!! OLDSCHOOL ROULEZ.. .. .."
        Dc.B    "   DESTROY YOUR LEFT RAH BUTTON OR DIE !! !! !! !! !! !!"
        Dc.B    "                     ",0
        EVEN

**********************************************************************
**
**      Double curves smooth RGB plasma
**
**********************************************************************

ChangePlasma
        Addq.L  #1,PlasmaCount
        Move.L  PlasmaCount(pc),d0
        Moveq   #7,d1
        Andi.L  d1,d0
        Add.L   d0,d0
        Add.L   d0,d0
        Move.L  ExemplesList(pc,d0.L),CurrentExemple
        Rts

ExemplesList
        Dc.L    PlasmaExemple1
        Dc.L    PlasmaExemple2
        Dc.L    PlasmaExemple3
        Dc.L    PlasmaExemple4
        Dc.L    PlasmaExemple5
        Dc.L    PlasmaExemple6
        Dc.L    PlasmaExemple7
        Dc.L    PlasmaExemple8


PlasmaCount     Ds.L    1
CurrentExemple  Dc.L    PlasmaExemple1


Plasma  Lea     $dff002,a5

        Move.L  CurrentExemple(pc),a6

        Lea     Table(pc),a0
        Move.L  a0,a1
        Add     Pt1(pc),a0
        Add     Pt2(pc),a1
        Move.L  16(a6),a2
        Lea     Pt_Rgb(pc),a3
        Movem.L a0-a1,(a3)
        Movem.L a0-a1,8(a3)
        Movem.L a0-a1,16(a3)
        Move.L  AdCop(pc),d5
        Move    #64*Height+1,d6

        Moveq   #-1,d0

        WBlt    a5
        Move.L  12(a6),bltcon0-2(a5)
        Move.L  d0,bltafwm-2(a5)
        Clr.L   bltcmod-2(a5)
        Clr     bltamod-2(a5)
        Move    #51*4+2,bltdmod-2(a5)

****

        Moveq   #(50/2)-1,d0

Loop1   REPT    2

        Movem.L (a3),a0-a1
        Move    (a0),d1
        Add     (a1),d1
        Add     d1,d1
        Lea     (a2,d1.W),a4
        Move.L  a4,d2
        Addq    #8,a0
        Addq    #8,a1
        Move.L  a0,(a3)+
        Move.L  a1,(a3)+

        Movem.L (a3),a0-a1
        Move    (a0),d1
        Add     (a1),d1
        Add     d1,d1
        Lea     (a2,d1.W),a4
        Move.L  a4,d3
        Addq    #8,a0
        Addi    #12,a1
        Move.L  a0,(a3)+
        Move.L  a1,(a3)+

        Movem.L (a3),a0-a1
        Move    (a0),d1
        Add     (a1),d1
        Add     d1,d1
        Lea     (a2,d1.W),a4
        Move.L  a4,d4
        Addi    #16,a0
        Addi    #14,a1
        Movem.L a0-a1,(a3)
        Subi    #16,a3

; remplissage de la copperlist
;
        IFND    A500
        WBlt    a5
        ENDIF
        Movem.L d2-d5,bltcpt-2(a5)
        Move    d6,bltsize-2(a5)
        Addq.L  #4,d5

        ENDR
        Dbra    d0,Loop1

****

        Lea     Table(pc),a0
        Move.L  a0,a1
        Add     Pt3(pc),a0
        Add     Pt4(pc),a1
        Move.L  AdCop(pc),a2
        Subi    #9,a2

        Moveq   #(Height/2)-1,d0
        Move.B  #$7e,d3
        Moveq   #15,d4
        Move    (a6),a3
        Move    2(a6),a4
        Move    #52*4,a5

Loop2   REPT    2
        Move    (a0),d1
        Add     (a1),d1
        Lsr     d1
        Move    d1,d2
        Lsr     d1
        And.B   d3,d1
        Addq    #8,d1
        Bset    #0,d1
        Move.B  d1,(a2)
        And.B   d4,d2
        Move    d2,5(a2)
        Add     a3,a0
        Add     a4,a1
        Addi    a5,a2
        ENDR
        Dbra    d0,Loop2

****

        Move    #511*2,d0

        Move    Pt1(pc),d1
        Add     4(a6),d1
        And     d0,d1
        Move    d1,Pt1
        
        Move    Pt2(pc),d1
        Add     6(a6),d1
        And     d0,d1
        Move    d1,Pt2

        Move    Pt3(pc),d1
        Add     8(a6),d1
        And     d0,d1
        Move    d1,Pt3

        Move    Pt4(pc),d1
        Add     10(a6),d1
        And     d0,d1
        Move    d1,Pt4

        Rts

Pt_Rgb  Ds.L    6
        
Table   DC.W    $0032,$0033,$0034,$0034,$0035,$0035,$0036,$0037,$0037,$0038
        DC.W    $0038,$0039,$003A,$003A,$003B,$003B,$003C,$003D,$003D,$003E
        DC.W    $003E,$003F,$0040,$0040,$0041,$0041,$0042,$0043,$0043,$0044
        DC.W    $0044,$0045,$0045,$0046,$0047,$0047,$0048,$0048,$0049,$0049
        DC.W    $004A,$004A,$004B,$004B,$004C,$004C,$004D,$004E,$004E,$004F
        DC.W    $004F,$0050,$0050,$0050,$0051,$0051,$0052,$0052,$0053,$0053
        DC.W    $0054,$0054,$0055,$0055,$0056,$0056,$0056,$0057,$0057,$0058
        DC.W    $0058,$0058,$0059,$0059,$005A,$005A,$005A,$005B,$005B,$005B
        DC.W    $005C,$005C,$005C,$005D,$005D,$005D,$005E,$005E,$005E,$005E
        DC.W    $005F,$005F,$005F,$0060,$0060,$0060,$0060,$0061,$0061,$0061
        DC.W    $0061,$0061,$0062,$0062,$0062,$0062,$0062,$0062,$0063,$0063
        DC.W    $0063,$0063,$0063,$0063,$0063,$0063,$0063,$0064,$0064,$0064
        DC.W    $0064,$0064,$0064,$0064,$0064,$0064,$0064,$0064,$0064,$0064
        DC.W    $0064,$0064,$0064,$0064,$0064,$0064,$0064,$0064,$0064,$0064
        DC.W    $0063,$0063,$0063,$0063,$0063,$0063,$0063,$0063,$0062,$0062
        DC.W    $0062,$0062,$0062,$0062,$0061,$0061,$0061,$0061,$0061,$0060
        DC.W    $0060,$0060,$0060,$005F,$005F,$005F,$005F,$005E,$005E,$005E
        DC.W    $005D,$005D,$005D,$005C,$005C,$005C,$005B,$005B,$005B,$005A
        DC.W    $005A,$005A,$0059,$0059,$0059,$0058,$0058,$0057,$0057,$0056
        DC.W    $0056,$0056,$0055,$0055,$0054,$0054,$0053,$0053,$0053,$0052
        DC.W    $0052,$0051,$0051,$0050,$0050,$004F,$004F,$004E,$004E,$004D
        DC.W    $004D,$004C,$004C,$004B,$004A,$004A,$0049,$0049,$0048,$0048
        DC.W    $0047,$0047,$0046,$0046,$0045,$0044,$0044,$0043,$0043,$0042
        DC.W    $0042,$0041,$0040,$0040,$003F,$003F,$003E,$003D,$003D,$003C
        DC.W    $003C,$003B,$003A,$003A,$0039,$0039,$0038,$0037,$0037,$0036
        DC.W    $0036,$0035,$0034,$0034,$0033,$0032,$0032,$0031,$0031,$0030
        DC.W    $002F,$002F,$002E,$002E,$002D,$002C,$002C,$002B,$002B,$002A
        DC.W    $0029,$0029,$0028,$0027,$0027,$0026,$0026,$0025,$0025,$0024
        DC.W    $0023,$0023,$0022,$0022,$0021,$0020,$0020,$001F,$001F,$001E
        DC.W    $001E,$001D,$001C,$001C,$001B,$001B,$001A,$001A,$0019,$0019
        DC.W    $0018,$0018,$0017,$0017,$0016,$0016,$0015,$0015,$0014,$0014
        DC.W    $0013,$0013,$0012,$0012,$0011,$0011,$0010,$0010,$000F,$000F
        DC.W    $000F,$000E,$000E,$000D,$000D,$000C,$000C,$000C,$000B,$000B
        DC.W    $000B,$000A,$000A,$0009,$0009,$0009,$0008,$0008,$0008,$0007
        DC.W    $0007,$0007,$0006,$0006,$0006,$0006,$0005,$0005,$0005,$0004
        DC.W    $0004,$0004,$0004,$0004,$0003,$0003,$0003,$0003,$0002,$0002
        DC.W    $0002,$0002,$0002,$0002,$0001,$0001,$0001,$0001,$0001,$0001
        DC.W    $0001,$0001,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        DC.W    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        DC.W    $0000,$0000,$0000,$0000,$0000,$0000,$0001,$0001,$0001,$0001
        DC.W    $0001,$0001,$0001,$0001,$0002,$0002,$0002,$0002,$0002,$0002
        DC.W    $0003,$0003,$0003,$0003,$0003,$0004,$0004,$0004,$0004,$0005
        DC.W    $0005,$0005,$0005,$0006,$0006,$0006,$0007,$0007,$0007,$0007
        DC.W    $0008,$0008,$0008,$0009,$0009,$000A,$000A,$000A,$000B,$000B
        DC.W    $000B,$000C,$000C,$000D,$000D,$000D,$000E,$000E,$000F,$000F
        DC.W    $0010,$0010,$0010,$0011,$0011,$0012,$0012,$0013,$0013,$0014
        DC.W    $0014,$0015,$0015,$0016,$0016,$0017,$0017,$0018,$0018,$0019
        DC.W    $0019,$001A,$001A,$001B,$001C,$001C,$001D,$001D,$001E,$001E
        DC.W    $001F,$001F,$0020,$0021,$0021,$0022,$0022,$0023,$0024,$0024
        DC.W    $0025,$0025,$0026,$0026,$0027,$0028,$0028,$0029,$0029,$002A
        DC.W    $002B,$002B,$002C,$002D,$002D,$002E,$002E,$002F,$0030,$0030
        DC.W    $0031,$0031,$0032,$0033,$0033,$0034,$0034,$0035,$0036,$0036
        DC.W    $0037,$0038,$0038,$0039,$0039,$003A,$003B,$003B,$003C,$003C
        DC.W    $003D,$003E,$003E,$003F,$003F,$0040,$0041,$0041,$0042,$0042
        DC.W    $0043,$0043,$0044,$0045,$0045,$0046,$0046,$0047,$0047,$0048
        DC.W    $0048,$0049,$004A,$004A,$004B,$004B,$004C,$004C,$004D,$004D
        DC.W    $004E,$004E,$004F,$004F,$0050,$0050,$0051,$0051,$0052,$0052
        DC.W    $0053,$0053,$0054,$0054,$0054,$0055,$0055,$0056,$0056,$0057
        DC.W    $0057,$0057,$0058,$0058,$0059,$0059,$0059,$005A,$005A,$005B
        DC.W    $005B,$005B,$005C,$005C,$005C,$005D,$005D,$005D,$005D,$005E
        DC.W    $005E,$005E,$005F,$005F,$005F,$005F,$0060,$0060,$0060,$0060
        DC.W    $0061,$0061,$0061,$0061,$0061,$0062,$0062,$0062,$0062,$0062
        DC.W    $0062,$0063,$0063,$0063,$0063,$0063,$0063,$0063,$0063,$0064
        DC.W    $0064,$0064,$0064,$0064,$0064,$0064,$0064,$0064,$0064,$0064
        DC.W    $0064,$0064,$0064,$0064,$0064,$0064,$0064,$0064,$0064,$0064
        DC.W    $0064,$0064,$0063,$0063,$0063,$0063,$0063,$0063,$0063,$0063
        DC.W    $0063,$0062,$0062,$0062,$0062,$0062,$0061,$0061,$0061,$0061
        DC.W    $0061,$0060,$0060,$0060,$0060,$005F,$005F,$005F,$005F,$005E
        DC.W    $005E,$005E,$005E,$005D,$005D,$005D,$005C,$005C,$005C,$005B
        DC.W    $005B,$005B,$005A,$005A,$0059,$0059,$0059,$0058,$0058,$0058
        DC.W    $0057,$0057,$0056,$0056,$0055,$0055,$0055,$0054,$0054,$0053
        DC.W    $0053,$0052,$0052,$0051,$0051,$0050,$0050,$004F,$004F,$004E
        DC.W    $004E,$004D,$004D,$004C,$004C,$004B,$004B,$004A,$004A,$0049
        DC.W    $0049,$0048,$0047,$0047,$0046,$0046,$0045,$0045,$0044,$0044
        DC.W    $0043,$0042,$0042,$0041,$0041,$0040,$003F,$003F,$003E,$003E
        DC.W    $003D,$003C,$003C,$003B,$003B,$003A,$0039,$0039,$0038,$0038
        DC.W    $0037,$0036,$0036,$0035,$0035,$0034,$0033,$0033,$0032,$0032
        DC.W    $0031,$0030,$0030,$002F,$002E,$002E,$002D,$002D,$002C,$002B
        DC.W    $002B,$002A,$002A,$0029,$0028,$0028,$0027,$0027,$0026,$0025
        DC.W    $0025,$0024,$0024,$0023,$0022,$0022,$0021,$0021,$0020,$0020
        DC.W    $001F,$001E,$001E,$001D,$001D,$001C,$001C,$001B,$001B,$001A
        DC.W    $0019,$0019,$0018,$0018,$0017,$0017,$0016,$0016,$0015,$0015
        DC.W    $0014,$0014,$0013,$0013,$0012,$0012,$0011,$0011,$0011,$0010
        DC.W    $0010,$000F,$000F,$000E,$000E,$000D,$000D,$000D,$000C,$000C
        DC.W    $000B,$000B,$000B,$000A,$000A,$000A,$0009,$0009,$0009,$0008
        DC.W    $0008,$0008,$0007,$0007,$0007,$0006,$0006,$0006,$0005,$0005
        DC.W    $0005,$0005,$0004,$0004,$0004,$0004,$0003,$0003,$0003,$0003
        DC.W    $0003,$0002,$0002,$0002,$0002,$0002,$0002,$0001,$0001,$0001
        DC.W    $0001,$0001,$0001,$0001,$0001,$0000,$0000,$0000,$0000,$0000
        DC.W    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        DC.W    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$0001
        DC.W    $0001,$0001,$0001,$0001,$0001,$0001,$0001,$0002,$0002,$0002
        DC.W    $0002,$0002,$0002,$0003,$0003,$0003,$0003,$0003,$0004,$0004
        DC.W    $0004,$0004,$0005,$0005,$0005,$0006,$0006,$0006,$0006,$0007
        DC.W    $0007,$0007,$0008,$0008,$0008,$0009,$0009,$0009,$000A,$000A
        DC.W    $000A,$000B,$000B,$000C,$000C,$000C,$000D,$000D,$000E,$000E
        DC.W    $000E,$000F,$000F,$0010,$0010,$0011,$0011,$0012,$0012,$0013
        DC.W    $0013,$0014,$0014,$0015,$0015,$0016,$0016,$0017,$0017,$0018
        DC.W    $0018,$0019,$0019,$001A,$001A,$001B,$001B,$001C,$001C,$001D
        DC.W    $001E,$001E,$001F,$001F,$0020,$0020,$0021,$0021,$0022,$0023
        DC.W    $0023,$0024,$0024,$0025,$0026,$0026,$0027,$0027,$0028,$0029
        DC.W    $0029,$002A,$002A,$002B,$002C,$002C,$002D,$002D,$002E,$002F
        DC.W    $002F,$0030,$0030,$0031,$0032,$0032,$0033,$0034,$0034,$0035
        DC.W    $0035,$0036,$0037,$0037,$0038,$0038,$0039,$003A,$003A,$003B
        DC.W    $003B,$003C,$003D,$003D,$003E,$003E,$003F,$0040,$0040,$0041
        DC.W    $0041,$0042,$0043,$0043,$0044,$0044,$0045,$0045,$0046,$0047
        DC.W    $0047,$0048,$0048,$0049,$0049,$004A,$004A,$004B,$004B,$004C
        DC.W    $004C,$004D,$004E,$004E,$004F,$004F,$0050,$0050,$0051,$0051
        DC.W    $0051,$0052,$0052,$0053,$0053,$0054,$0054,$0055,$0055,$0056
        DC.W    $0056,$0056,$0057,$0057,$0058,$0058,$0058,$0059,$0059,$005A
        DC.W    $005A,$005A,$005B,$005B,$005B,$005C,$005C,$005C,$005D,$005D
        DC.W    $005D,$005E,$005E,$005E,$005F,$005F,$005F,$005F,$0060,$0060
        DC.W    $0060,$0060,$0061,$0061,$0061,$0061,$0061,$0062,$0062,$0062
        DC.W    $0062,$0062,$0062,$0063,$0063,$0063,$0063,$0063,$0063,$0063
        DC.W    $0063,$0063,$0064,$0064,$0064,$0064,$0064,$0064,$0064,$0064
        DC.W    $0064,$0064,$0064,$0064,$0064,$0064,$0064,$0064,$0064,$0064
        DC.W    $0064,$0064,$0064,$0064,$0064,$0063,$0063,$0063,$0063,$0063
        DC.W    $0063,$0063,$0063,$0062,$0062,$0062,$0062,$0062,$0062,$0061
        DC.W    $0061,$0061,$0061,$0061,$0060,$0060,$0060,$0060,$005F,$005F
        DC.W    $005F,$005F,$005E,$005E,$005E,$005D,$005D,$005D,$005C,$005C
        DC.W    $005C,$005B,$005B,$005B,$005A,$005A,$005A,$0059,$0059,$0059
        DC.W    $0058,$0058,$0057,$0057,$0056,$0056,$0056,$0055,$0055,$0054
        DC.W    $0054,$0053,$0053,$0052,$0052,$0052,$0051,$0051,$0050,$0050
        DC.W    $004F,$004F,$004E,$004E,$004D,$004D,$004C,$004C,$004B,$004A
        DC.W    $004A,$0049,$0049,$0048,$0048,$0047,$0047,$0046,$0046,$0045
        DC.W    $0044,$0044,$0043,$0043,$0042,$0041,$0041,$0040,$0040,$003F
        DC.W    $003F,$003E,$003D,$003D,$003C,$003C,$003B,$003A,$003A,$0039
        DC.W    $0039,$0038,$0037,$0037,$0036,$0035,$0035,$0034,$0034,$0033
        DC.W    $0032,$0032,$0031,$0031,$0030,$002F,$002F,$002E,$002E,$002D
        DC.W    $002C,$002C,$002B,$002A,$002A,$0029,$0029,$0028,$0027,$0027
        DC.W    $0026,$0026,$0025,$0024,$0024,$0023,$0023,$0022,$0022,$0021
        DC.W    $0020,$0020,$001F,$001F,$001E,$001E,$001D,$001C,$001C,$001B
        DC.W    $001B,$001A,$001A,$0019,$0019,$0018,$0018,$0017,$0017,$0016
        DC.W    $0016,$0015,$0015,$0014,$0014,$0013,$0013,$0012,$0012,$0011
        DC.W    $0011,$0010,$0010,$000F,$000F,$000F,$000E,$000E,$000D,$000D
        DC.W    $000C,$000C,$000C,$000B,$000B,$000A,$000A,$000A,$0009,$0009
        DC.W    $0009,$0008,$0008,$0008,$0007,$0007,$0007,$0006,$0006,$0006
        DC.W    $0006,$0005,$0005,$0005,$0004,$0004,$0004,$0004,$0004,$0003
        DC.W    $0003,$0003,$0003,$0002,$0002,$0002,$0002,$0002,$0002,$0001
        DC.W    $0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0000,$0000
        DC.W    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        DC.W    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        DC.W    $0000,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0002
        DC.W    $0002,$0002,$0002,$0002,$0002,$0003,$0003,$0003,$0003,$0003
        DC.W    $0004,$0004,$0004,$0004,$0005,$0005,$0005,$0005,$0006,$0006
        DC.W    $0006,$0007,$0007,$0007,$0007,$0008,$0008,$0008,$0009,$0009
        DC.W    $000A,$000A,$000A,$000B,$000B,$000B,$000C,$000C,$000D,$000D
        DC.W    $000D,$000E,$000E,$000F,$000F,$0010,$0010,$0010,$0011,$0011
        DC.W    $0012,$0012,$0013,$0013,$0014,$0014,$0015,$0015,$0016,$0016
        DC.W    $0017,$0017,$0018,$0018,$0019,$0019,$001A,$001A,$001B,$001C
        DC.W    $001C,$001D,$001D,$001E,$001E,$001F,$001F,$0020,$0021,$0021
        DC.W    $0022,$0022,$0023,$0024,$0024,$0025,$0025,$0026,$0026,$0027
        DC.W    $0028,$0028,$0029,$002A,$002A,$002B,$002B,$002C,$002D,$002D
        DC.W    $002E,$002E,$002F,$0030,$0030,$0031

Pt1     Ds      1
Pt2     Ds      1
Pt3     Ds      1
Pt4     Ds      1
AdCop   Dc.L    PlasmaCopper+10

PlasmaExemple1
        Dc      1*2,3*2
        Dc      -1*2,3*2
        Dc      1*2,2*2
        Dc.L    ((%0000100100000000!A)<<16)
        Dc.L    ColorList4

PlasmaExemple2
        Dc      3*2,4*2
        Dc      -4*2,-1*2
        Dc      -10*2,2*2       
        Dc.L    ((%0000100100000000!A)<<16)
        Dc.L    ColorList3

PlasmaExemple3
        Dc      1*2,2*2
        Dc      -4*2,-2*2
        Dc      -5*2,-6*2       
        Dc.L    ((%0000100100000000!A)<<16)
        Dc.L    ColorList2

PlasmaExemple4
        Dc      6*2,1*2
        Dc      10*2,1*2
        Dc      12*2,6*2
        Dc.L    ((%0000100100000000!A)<<16)
        Dc.L    ColorList5


PlasmaExemple5
        Dc      6*2,1*2
        Dc      17*2,4*2
        Dc      12*2,6*2
        Dc.L    ((%0000100100000000!A)<<16)
        Dc.L    ColorList6


PlasmaExemple6
        Dc      1*2,3*2
        Dc      -1*2,3*2
        Dc      1*2,6*2
        Dc.L    ((%0000100100000000!A)<<16)
        Dc.L    ColorList7

PlasmaExemple7
        Dc      6*2,1*2
        Dc      10*2,1*2
        Dc      12*2,6*2
        Dc.L    ((%0000100100000000!A)<<16)
        Dc.L    ColorList2


PlasmaExemple8
        Dc      6*2,1*2
        Dc      10*2,1*2
        Dc      18*2,6*2
        Dc.L    ((%0000100100000000!A)<<16)
        Dc.L    ColorList7

        SECTION ChipDatas,Data_C

************************
**
**      COPPERLIST
**
************************

Copper  CMove   BPLF_COLOR,bplcon0

        WaitRefresh
        SprCtrl 0,0,0,0
        SprCtrl 1,0,0,0
        SprCtrl 2,0,0,0
        SprCtrl 3,0,0,0
        SprCtrl 4,0,0,0
        SprCtrl 5,0,0,0
        SprCtrl 6,0,0,0
        SprCtrl 7,0,0,0

        CWait   0,Dep

PlasmaPicPTR
        BplPtr  1
        CMove   $28,ddfstrt
        CMove   $d8,ddfstop
        CMove   $1000+BPLF_COLOR,bplcon0
        CMove   0,bpl1mod
        CMove   0,bpl2mod
        CMove   $eee,color

        SetCopW 57,Dep

PlasmaCopper
        Rept    Height
        IncCWait
        CMove   0,bplcon1
        Rept    25
        CMove   0,color
        CMove   0,color+2
        ENDR
        ENDR
kl
        IncCWait
        CMove   BPLF_COLOR,bplcon0
        CMove   $eee,color

        IncCWait
        CMove   $000,color

        CPal
        SetCopW 0,-1
        IncCWait
        CMove   INTF_SETCLR+INTF_COPPER,intreq
        IncCWait

ScrollPtr
        BplPtr  3
        CMove   $38,ddfstrt
        CMove   $d0,ddfstop
        CMove   $3200,bplcon0           
ScrollCopper
        CMove   0,bplcon1
        CMove   2,bpl1mod
        CMove   2,bpl2mod
        CMove   DMAF_SETCLR+DMAF_RASTER,dmacon
        Incbin  'fonts.clist'
        CEnd

pA      Set     0
pB      Set     1

ColorList
        Rept    360
        Dc      (pA/3)*256
pA      Set     pA+pB
        If      pA=45
pB      Set     -1
        Endc
        If      pA=0
pB      Set     1
        Endc
        Endr

ColorList2
        Incbin  'plasma1.rgb'

ColorList3
        Incbin  'plasma2.rgb'

ColorList4
        Incbin  'plasma3.rgb'
        
ColorList5
        Incbin  'plasma4.rgb'

ColorList6
        Incbin  'plasma5.rgb'

ColorList7
        Incbin  'plasma6.rgb'

;---
CharSet         Incbin  'fonts_944x33.raw'
PlasmaPic       Blk     24*Height,$00ff
Song            Incbin  'p61.music'

                SECTION Vide,Bss_C
                                
                Ds      42*33*3
EcranScroll     Ds.B    42*33*3

SampleBuffer    Ds.B    2000
