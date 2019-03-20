**********************************************************************
**
**
**      Vector-3d (Ltp4 DemoDisk)
**
**      AsmONE version !
**
**      Auteur:
**      B.Sebastien [Ostyl]
**
**      Date:
**      10/08/00
**
**
**********************************************************************

;MakeFinal      EQU     1
;A500           EQU     1

        INCDIR  Includes:
        INCLUDE Startup.asm

        INCLUDE Hardware/custom.i

        INCLUDE Macros/Macros.i
        INCLUDE Macros/Copper.i
        INCLUDE Macros/Blitter.i

        INCLUDE Hardware/bplbits.i

        _CHIP   a0
        Move    #DMAF_SETCLR+DMAF_MASTER+DMAF_BLITHOG,dmacon(a0)
        Move    #INTF_SETCLR+INTF_INTEN,intena(a0)

        Moveq   #0,d0
        Lea     Song,a0
        Sub.L   a1,a1
        Lea     SampleBuffer,a2
        Bsr.W   P61_Init
        Tst.L   d0
        Bne.B   Error

        Bsr.W   InitStarField
        Bsr.B   InitDisplay

        Move.L  #VblInterrupt,Lev3Vbl
        Move    #DMAF_SETCLR+DMAF_BLITTER+DMAF_BLITHOG,$dff000+dmacon
        Move    #INTF_SETCLR+INTF_VERTB,$dff000+intena

WaitMouseHit

        WaitLMB WaitMouseHit

        _CHIP   a6
        Bsr.W   P61_End

Error   Rts

VblInterrupt
        Bsr.W   Scroller
        Bsr.W   Clr
        _CHIP   a6
        Bsr.W   P61_Music
        Bsr.W   Make3d
        Bsr.W   ScrollStars
        Bsr.W   BlitPlasma
        Bsr.W   MoveLogo
        Bsr.W   ScreenSwap

        Move    VblCount(pc),d0
        Andi    #255,d0
        Bne.B   FinVbl
        Bsr.W   Change3d
FinVbl  Addq    #1,VblCount
        Rts

VblCount        Dc      1

InitDisplay
        Lea     BitplansScroll,a0
        Move.L  #ScreenScroller,d0
        Moveq   #3,d1
        Move.L  #44*31,d2
        InitPtr

        Lea     BitplansLogo,a0
        Move.L  #Logo,d0
        Moveq   #3,d1
        Move.L  #40*74,d2
        InitPtr

        _CHIP   a0
        Moveq   #0,d0   
        Move    #$38,ddfstrt(a0)
        Move    #$d0,ddfstop(a0)

        IFND    A500
        Move    d0,fmode(a0)
        Fenetre 129,41,320,257,a0
        Move    d0,bplcon3(a0)
        ELSE
        Move    #$2981,diwstrt(a0)
        Move    #$29c1,diwstop(a0)
        ENDC

        Move    d0,bplcon1(a0)
        Move    d0,bplcon2(a0)
        Move    d0,bpl1mod(a0)
        Move    d0,bpl2mod(a0)
        
        Lea     CopperList,a1
        Move.L  a1,cop1lc(a0)   
        Move    d0,copjmp1(a0)

        Move    #DMAF_SETCLR+DMAF_COPPER+DMAF_RASTER,dmacon(a0)
        Rts

;==================================
;----------------------------------
;
InitStarField
        Lea     StarsField+11,a0
        Moveq   #100-1,d3

StarsLoop1
        Moveq   #0,d0
        Moveq   #0,d1
        Move.B  $dff007,d0
        Move.B  $dff006,d1
        Move.B  $bfe801,d2
        Eor.B   d1,d0
        Eor.B   d2,d0
        Ext     d0
        Move.B  d0,(a0)
        Lea     24(a0),a0
        Dbf     d3,StarsLoop1
        Rts

;-----------------------------
;-----------------------------
;Bascule l'écran logique et 
;l'écran physqiue
;
ScreenSwap
        Move.L  EcranLogique(pc),d0
        Move.L  EcranPhysique(pc),d1
        Move.L  d0,EcranPhysique
        Move.L  d1,EcranLogique

        Lea     Bitplans3d,a0   
        Move.L  EcranPhysique(pc),d0
        Move    d0,6(a0)
        Swap    d0
        Move    d0,2(a0)

        Move    #DMAF_SETCLR+DMAF_RASTER,dmacon(a5)
        Rts

EcranLogique    Dc.L    Ecran1
EcranPhysique   Dc.L    Ecran2


MoveLogo
        Lea     SinTab(pc),a0

        Move    Logo1Sinus(pc),d0
        Andi    #511,d0
        Add     d0,d0
        Move    (a0,d0),d0
        Asr     #3,d0
        Move    d0,d3
        Neg     d3

        Lea     MovLogo1,a0
        Subi    #14,d0
        Move    d0,d1
        Andi.B  #15,d0
        Move.B  d0,d2
        Lsl.B   #4,d2
        Or.B    d2,d0
        Move.B  d0,3(a0)
        Addq    #1,d1
        Neg     d1
        Asr     #4,d1
        Add     d1,d1
        Move    d1,6(a0)
        Move    d1,10(a0)

        Lea     PlasmaCopper+(24*34),a0
        Neg     d1
        Move    d1,18(a0)
        Move    d1,22(a0)

        Subi    #14,d3
        Move    d3,d1
        Andi.B  #15,d3
        Move.B  d3,d2
        Lsl.B   #4,d2
        Or.B    d2,d3
        Move    #bplcon1,12(a0)
        Move.B  d3,15(a0)
        Addq    #1,d1
        Neg     d1
        Asr     #4,d1
        Add     d1,d1
        Add     d1,18(a0)
        Add     d1,22(a0)

        Addq    #4,Logo1Sinus
        Rts

Logo1Sinus      Ds      1
Logo2Sinus      Ds      1

**********************************************************************
**
**      3d part
**
**      by Robotronik / XMFC
**
**********************************************************************

Change3d        
        Lea     MyObject(pc),a0
        Addq.L  #1,ObjectCount
        Move.L  ObjectCount(pc),d0
        Andi    #3,d0
        Lsl     #3,d0
        Move.L  (a0,d0.W),CurrentPNTS
        Move.L  4(a0,d0.W),CurrentPOLS
        Rts

CurrentPNTS     Dc.L    Sph_pnts                
CurrentPOLS     Dc.L    Sph_lines

Make3d  Lea     SinTab(pc),a0
        Lea     CosTab(pc),a1
        Move.L  CurrentPNTS(pc),a2
        Lea     Obj_2d(pc),a3
        Move.L  (a2)+,d0
        Divu    #12,d0
        Bsr.W   Rotation3d

        Move.L  EcranLogique(pc),a0
        Move.L  CurrentPOLS(pc),a1
        Lea     Obj_2d(pc),a2
        Move.L  (a1)+,d4
        Lsr     #3,d4
        Subq    #1,d4

        Lea     $dff002,a5
        
Trace3d Move    2(a1),d0
        Move    4(a1),d1        
        Lsl     #3,d0
        Lsl     #3,d1
        Lea     (a2,d0.W),a3
        Lea     (a2,d1.W),a4
        Move.L  (a3)+,d0
        Move.L  (a3),d1
        Move.L  (a4)+,d2
        Move.L  (a4),d3
        Bsr.W   LineDraw
        Lea     8(a1),a1
        Dbf     d4,Trace3d

        Bsr.W   FadeLineIN
        ;Bsr.W  FadeLineOut
        Rts

**********************************************************************
**
**      3d-Rotation
**
**********************************************************************

Rotation3d
        Movem.L d0-a5,-(sp)
        
        Move    #511,d1

        Move    AngleX(pc),d2
        Addq    #2,d2
        And     d1,d2
        Move    d2,AngleX

        Move    AngleY(pc),d2
        Subq    #3,d2
        And     d1,d2
        Move    d2,AngleY

        Move    AngleZ(pc),d2
        Addq    #1,d2
        And     d1,d2   
        Move    d2,AngleZ

        Subq    #1,d0
        Bmi.W   Stop

Loop    Move.L  d0,-(sp)

        Movem.L (a2)+,d0/d2/d4          ;d0=x d2=y d4=z 
        Move.L  d0,d1
        Move.L  d2,d3
        Move.L  d4,d5

;Rotate around X-Axis
;
        Move    AngleX(pc),d6
        Add     d6,d6   
        Move    (a0,d6.W),d7            ;d7=sin x
        Move    (a1,d6.W),d6            ;d6=cos x
        Muls    d6,d2                   ;y=(y*cos)
        Muls    d7,d4                   ;z=(z*sin)
        Muls    d7,d3                   ;y1=(y1*sin)
        Muls    d6,d5                   ;z1=(z1*cos)
        Add.L   d4,d2
        Sub.L   d3,d5           
        Asr.L   #8,d2
        Asr.L   #8,d5
        Move.L  d2,d3
        Move.L  d5,d4   
 
;Rotate around Y-Axis
;
        Move    AngleY(pc),d6
        Add     d6,d6   
        Move    (a0,d6.W),d7            ;d7=sin x
        Move    (a1,d6.W),d6            ;d6=cos x
        Muls    d6,d0                   ;x=(x*cos)
        Muls    d7,d4                   ;z=(z*sin)
        Muls    d7,d1                   ;x1=(x1*sin)
        Muls    d6,d5                   ;z1=(z1*cos)
        Add.L   d4,d0
        Sub.L   d1,d5
        Asr.L   #8,d0
        Asr.L   #8,d5
        Move.L  d0,d1

;Rotate around Z-Axis
;
        Move    AngleZ(pc),d6
        Add     d6,d6   
        Move    (a0,d6.W),d7            ;d7=sin x
        Move    (a1,d6.W),d6            ;d6=cos x
        Muls    d6,d0                   ;x=(x*cos)
        Muls    d7,d2                   ;y=(y*sin)
        Muls    d7,d1                   ;x1=(x1*sin)
        Muls    d6,d3                   ;y1=(y1*cos)
        Add.L   d2,d0
        Sub.L   d1,d3

** Transformation 3d -> 2d

        Add.L   Position_Z(pc),d5
        Beq.B   yu
        Asr.L   d0
        Asr.L   d3
        Divs    d5,d0
        Divs    d5,d3
yu      Ext.L   d0
        Ext.L   d3
        Addi.L  #320/2,d0
        Addi.L  #156/2,d3
        Move.L  d0,(a3)+
        Move.L  d3,(a3)+
        Move.L  (sp)+,d0
        Dbf     d0,Loop

Stop    Movem.L (sp)+,d0-a5
        Rts

AngleX  Ds      1
AngleY  Ds      1
AngleZ  Ds      1

Position_Z      Dc.L    2000

**********************************************************************
**
**      DrawLine blitter
**
**********************************************************************

LineDraw
        Movem.L d4/a0-a4,-(sp)
        Moveq   #0,d4

DeltaX  Sub     d0,d2           
        Bpl.B   DeltaY  
        Neg     d2
        Addq.B  #4,d4

DeltaY  Sub     d1,d3   
        Bpl.B   SortDelta
        Neg     d3
        Addq.B  #2,d4

SortDelta
        Cmp     d2,d3   
        Ble.B   Size
        Exg     d2,d3
        Addq.B  #1,d4
        
Size    Move    d2,d7
        Addq.B  #1,d7
        Asl     #6,d7           
        Addq.B  #2,d7

BltAPtl Move.L  d3,d6           
        Add     d6,d6           
        Sub     d2,d6

        Add     d3,d3           
        Move    d3,d5

BltconB Lea     TableOct(pc),a1
        Move.B  (a1,d4.W),d4    
        Cmp     d2,d3
        Bge.B   BltAMod
        Bset    #6,d4

BltAMod Add     d2,d2   
        Sub     d2,d3
        Move    d3,d2

BltCDptl
        Move    d1,d3
        Add     d1,d1
        Add     d1,d1
        Add     d3,d1
        Lsl     #3,d1
        Move.L  d0,d3
        Asr     #3,d0   
        Add     d0,d1
        Lea     (a0,d1.W),a0

BltConA And     #$f,d3
        Move.L  d3,d0
        Ror     #4,d3
        Or      #$bca,d3

        WBlt    a5

        Moveq   #40,d0
        Moveq   #-1,d1
        Move    d3,bltcon0-2(a5)                
        Move    d4,bltcon1-2(a5)                
        Move.L  d1,bltafwm-2(a5)                
        Move.L  a0,bltcpt-2(a5)         
        Move.L  d6,bltapt-2(a5)         
        Move.L  a0,bltdpt-2(a5)         
        Move    d0,bltcmod-2(a5)                
        Move    d5,bltbmod-2(a5)                
        Move    d2,bltamod-2(a5)                
        Move    d0,bltdmod-2(a5)                
        Move    LineMask(pc),bltbdat-2(a5)
        Move    #$c000,bltadat-2(a5)    
        Move    d7,bltsize-2(a5)

        Movem.L (sp)+,d4/a0-a4
        Rts

TableOct
        Dc.B    %10001
        Dc.B    %00001
        Dc.B    %11001
        Dc.B    %00101
        Dc.B    %10101
        Dc.B    %01001
        Dc.B    %11101
        Dc.B    %01101

        EVEN

FadeLineIN
        Move    LineMask(pc),d0
        Lsl     d0
        Bcs.B   Ha
        Addq    #1,d0
        Move    d0,LineMask
        Subi.L  #64,Position_Z
Ha      Rts

FadeLineOut
        Move    LineMask(pc),d0
        Lsr     d0
        Move    d0,LineMask
        Rts

LineMask        Dc      0

**********************************************************************
**
**      Screen clearing
**
**********************************************************************

Clr     Lea     $dff002,a5
        Move.L  EcranLogique(pc),d1
        Addq.L  #8,d1
        Move    #$0100,d2
        Move    #(148*64)+11,d3
        Moveq   #0,d4
        WBlt    a5
        Move.L  d1,bltdpt-2(a5)
        Move    d2,bltcon0-2(a5)
        Move    d4,bltcon1-2(a5)
        Move.L  d4,bltafwm-2(a5)
        Move    #18,bltdmod-2(a5)
        Move    d3,bltsize-2(a5)
        Rts

**********************************************************************
**
**      Scroll routine
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
        Bne.W   ShiftMemScroll

Text    Lea     ScrollText(pc),a1
        Move    ChrCnt(pc),d0
        Lea     (a1,d0.W),a1
        Addq    #1,ChrCnt

        Moveq   #0,d0
        Move.B  (a1),d0
        Bne.B   GetFont
        Clr     ChrCnt
        Bra.B   Text
        
GetFont Sub.B   #32,d0
        Move.B  d0,Chr
        Add     d0,d0
        Add     d0,d0
        Clr.B   ScrollCnt

;-------------------------
;---- Copie une fonte ----
;-------------------------
;
        Lea     Fontes,a1
        Lea     (a1,d0.L),a1    ; pointeur sur la fonte à copier
        
        Lea     ScreenScroller+40,a2
        Moveq   #-1,d0
        Move.L  #(((1888/8)-4)<<16)!(44-4),d2
        Move.L  #(%0000100100000000!A)<<16,d3
        Move    #(31*3)*64+2,d4

        WBlt    a5      
        Move.L  a1,bltapt-2(a5)
        Move.L  a2,bltdpt-2(a5) 
        Move.L  d2,bltamod-2(a5)
        Move.L  d0,bltafwm-2(a5)                
        Move.L  d3,bltcon0-2(a5)
        Move    d4,bltsize-2(a5)        

;---------------------------
;---- Décale la memoire ----
;---------------------------
;
ShiftMemScroll
        Lea     ScreenScroller,a1
        Lea     (44*31*3)-2(a1),a1
        Moveq   #0,d0
        Moveq   #-1,d1
        Move.L  #((%0100100100000000!A)<<16)!%10,d2

        WBlt    a5
        Move.L  a1,bltapt-2(a5)
        Move.L  a1,bltdpt-2(a5) 
        Move.L  d0,bltamod-2(a5)
        Move.L  d1,bltafwm-2(a5)                
        Move.L  d2,bltcon0-2(a5)
        Move    #(31*3)*64+44,bltsize-2(a5)
        Addq.B  #2,ScrollCnt

Leave   Rts

Delay   WaitRMB Delay
        Rts

CharsWidth
        Dc.B    15,15,15,15,15,15,15,15,15,15
        Dc.B    15,15,15,15,15,15,15,15,15,15
        Dc.B    15,15,15,15,15,15,15,15,15,15
        Dc.B    15,15,15,15,15,15,15,15,15,15
        Dc.B    15,07,15,15,15,15,15,15,15,15
        Dc.B    15,15,15,15,15,15,15,15,15,15
        Dc.B    15,15,15,15,15,15,15,15,15,15
        Dc.B    15,15,15,15,15,15,15,15,15,15

ChrCnt          Ds      1
ScrollCnt       Ds.B    1
Chr             Ds.B    1

ScrollText
        Dc.B    "          "
        Dc.B    "WELCOME TO ANOTHER HIGH QUALITY PRODUCTION FROM X.M.C.F "
        Dc.B    "THIS IS ANOTHER COOL PART OF THIS LTP4 DEMO DISK CALLED "
        Dc.B    "VEKTOR-DEMO AND IT IS SIMPLY GREAT DONT YOU KNOW ??? "
        Dc.B    "          "
        Dc.B    "I'VE NOTHING MUCH TO SAY EXCEPTED I THINK THIS PARTY "
        Dc.B    "IS ALL RIGHT AND FILLED WITH MANY GREAT PEOPLES...    "
        Dc.B    "          "
        Dc.B    "IF YOU WANT TO CONTACT ME THEN JUST TRY IRCNET "
        Dc.B    "(DEMOFR) OK GUYZ !! "
        Dc.B    "I'M NOW QUITE BORED TO TYPE SCROLLER... YOU WILL FIND ALL "
        Dc.B    "THE GREETINGS IN THE LAST PART CALLED WEIRD-SINUS "
        Dc.B    "    SEE YOU ALL DUDES !! !!    BYYYEE..............."  
        Dc.B    0
        Even

**********************************************************************
**
**      Simple plasma
**
**********************************************************************

BlitPlasma
        Lea     $dff002,a5

        Lea     SinTab(pc),a0
        Lea     CosTab(pc),a1
        Move    RedAng(pc),d0
        Move    GreAng(pc),d1
        Move    BluAng(pc),d2
        Add     d0,d0
        Add     d1,d1
        Add     d2,d2

        Move    (a1,d0.W),d3
        Add     (a0,d2.W),d3
        Add     d3,d3
        Sub     (a1,d1.W),d3

        Move    (a0,d1.W),d4
        Add     (a1,d2.W),d4
        Add     (a0,d0.W),d4

        Move    (a1,d2.W),d5
        Add     (a0,d1.W),d5
        Sub     d0,d5

        Lea     PlasmaData,a0
        Asr     #6,d3
        Asr     #4,d4
        Asr     #2,d5
        Addi    #200*2,d3
        Addi    #40*2,d4
        Addi    #120*2,d5
        Ext.L   d3
        Ext.L   d4
        Ext.L   d5
        Lea     (a0,d3.L),a1
        Lea     (a1,d4.L),a2
        Lea     (a0,d5.L),a0

        Lea     PlasmaCopper+10,a3
        Moveq   #$16,d0
        Moveq   #-1,d1
        Move.L  #[(%1000111100000000!(A!B!C))<<16]![%0100000000000000],d2
        Moveq   #0,d3

        WBlt    a5      
        Move.L  a0,bltapt-2(a5)
        Move.L  a1,bltbpt-2(a5)
        Move.L  a2,bltcpt-2(a5)
        Move.L  a3,bltdpt-2(a5) 
        Move.L  d0,bltamod-2(a5)
        Move.L  d3,bltcmod-2(a5)
        Move.L  d1,bltafwm-2(a5)                
        Move.L  d2,bltcon0-2(a5)
        Move    #(72*64)+1,bltsize-2(a5)

        Move    RedAng(pc),d0
        Move    GreAng(pc),d1
        Move    BluAng(pc),d2
        Move    #511,d3
        Addq    #2,d0
        Subq    #6,d1
        Addq    #3,d2
        And     d3,d0
        And     d3,d1
        And     d3,d2
        Move    d0,RedAng
        Move    d1,GreAng
        Move    d2,BluAng
        Rts

RedAng  Ds      1
GreAng  Ds      1
BluAng  Ds      1

**********************************************************************
**
**      StarField
**
**********************************************************************

ScrollStars
        Lea     StarsField+11,a0
        Moveq   #(100/10)-1,d0
        Moveq   #1,d1
        Moveq   #2,d2   
        Moveq   #24,d3

ScrollStarsLoop
        Add.B   d1,(a0)
        Add.L   d3,a0
        Add.B   d2,(a0)
        Add.L   d3,a0
        Add.B   d1,(a0)
        Add.L   d3,a0
        Add.B   d2,(a0)
        Add.L   d3,a0
        Add.B   d1,(a0)
        Add.L   d3,a0
        Add.B   d2,(a0)
        Add.L   d3,a0
        Add.B   d1,(a0)
        Add.L   d3,a0
        Add.B   d2,(a0)
        Add.L   d3,a0
        Add.B   d1,(a0)
        Add.L   d3,a0
        Add.B   d2,(a0)
        Add.L   d3,a0
        Dbf     d0,ScrollStarsLoop
        Rts

        Include asm:xmfc_demodisk/theplayer.asm

**********************************************************************
**
**      FASTMEM DATAS SECTION
**
**********************************************************************

Colors  Incbin  'bar.colors'

ObjectCount     Dc.L    0

MyObject        Dc.L    Sph_pnts
                Dc.L    Sph_lines

                Dc.L    Ltp4_pnts
                Dc.L    Ltp4_lines

                Dc.L    Tour_pnts
                Dc.L    Tour_lines

                Dc.L    XMFC_pnts
                Dc.L    XMFC_lines
        
Sph_pnts        Incbin  'dat:demodiskltp4/vektors/sphere.pnts'
Sph_lines       Incbin  'dat:demodiskltp4/vektors/sphere.lines'

Ltp4_pnts       Incbin  'dat:demodiskltp4/vektors/ltp4.pnts'
Ltp4_lines      Incbin  'dat:demodiskltp4/vektors/ltp4.lines'

Tour_pnts       Incbin  'dat:demodiskltp4/vektors/tour.pnts'
Tour_lines      Incbin  'dat:demodiskltp4/vektors/tour.lines'

XMFC_pnts       Incbin  'dat:demodiskltp4/vektors/xmfc.pnts'
XMFC_lines      Incbin  'dat:demodiskltp4/vektors/xmfc.lines'

Obj_2d          Ds.L    3*100


SinTab  Incbin  Includes:Table/sin
CosTab  Incbin  Includes:Table/cos

**********************************************************************
**
**      CHIPMEM DATAS SECTION
**
**********************************************************************

        SECTION ChipMemDatas,DATA_C

CopperList

        CWait   0,40
        SprCtrl 0,0,0,1
        SprCtrl 1,0,0,1
        SprCtrl 2,0,0,1
        SprCtrl 3,0,0,1
        SprCtrl 4,0,0,1
        SprCtrl 5,0,0,1
        SprCtrl 6,0,0,1
        SprCtrl 7,0,0,1

;=======================================
;---------------------------------------

        CWait   0,41

BitplansScroll
        BplPtr  3
        
        CMove   $3200,bplcon0
        CMove   0,bplcon1
        CMove   4,bpl1mod
        CMove   4,bpl2mod
        Incbin  'dat:demodiskltp4/vektors/charset.clist'

        SetCopW 0,44
        IncCWait
        CMove   $000,color+14
        IncCWait
        CMove   $002,color+14
        IncCWait
        CMove   $114,color+14
        IncCWait
        CMove   $1116,color+14
        IncCWait
        CMove   $228,color+14
        IncCWait
        CMove   $33a,color+14
        IncCWait
        CMove   $55c,color+14
        IncCWait
        CMove   $99e,color+14

        IncCWait
        CMove   $fff,color+14

        IncCWait
        CMove   $510,color+14
        IncCWait
        CMove   $620,color+14
        IncCWait
        CMove   $730,color+14
        IncCWait
        CMove   $941,color+14
        IncCWait
        CMove   $a52,color+14
        IncCWait
        CMove   $c64,color+14
        IncCWait
        CMove   $d75,color+14
        IncCWait
        CMove   $e86,color+14
        IncCWait
        CMove   $f97,color+14


;=======================================
;---------------------------------------

        CWait   0,41+31
        CMove   BPLF_COLOR,bplcon0
        CMove   0,color

        CWait   0,76

;=======================================
;---------------------------------------

Bitplans3d
        BplPtr  1

        CMove   $1000+BPLF_COLOR,bplcon0
        CMove   0,bpl1mod
        CMove   0,bpl2mod
        CMove   0,color
        CMove   $f42,color+(1*2)
        CMove   $578,color+(17*2)
        CMove   $ddd,color+(19*2)

SprtYpos        SET     100
                SetCopW 0,SprtYpos

StarsField      Rept    (100/2)+1
                IncCWait
                CMove   0,color
                SprCtrl 0,0,SprtYpos,1
                CMove   $8000,$144
                CMove   $0000,$146
SprtYpos        SET     SprtYpos+1      
                IncCWait
                CMove   0,color
                SprCtrl 0,0,SprtYpos,1
                CMove   $8000,$144
                CMove   $8000,$146
SprtYpos        SET     SprtYpos+1      
                ENDR

;=======================================
;---------------------------------------

        SetCopW 0,223
        IncCWait

MovLogo1
        CMove   0,bplcon1
        CMove   0,bpl1mod
        CMove   0,bpl2mod
        CMove   BPLF_COLOR,bplcon0
        Incbin  'dat:demodiskltp4/vektors/logo.cpal'

        IncCWait

BitplansLogo
        BplPtr  3
        CMove   $3000+BPLF_COLOR,bplcon0

;=======================================
;---------------------------------------

PlasmaCopper
        REPT    30
        IncCWait
        CMove   $000,$1be
        CMove   $000,color
        CMove   $000,$1be
        CMove   $000,bpl1mod
        CMove   $000,bpl2mod
        ENDR

        CPal
        SetCopW 0,-1
        IncCWait
        CMove   $000,color
        CMove   $000,$1be
        CMove   $000,bpl1mod
        CMove   $000,bpl2mod

        REPT    42
        IncCWait
        CMove   $000,$1be
        CMove   $000,color
        CMove   $000,$1be
        CMove   $000,bpl1mod
        CMove   $000,bpl2mod
        ENDR

        CMove   0,color

;=======================================
;---------------------------------------


        CEnd

Fontes  Incbin  'dat:demodiskltp4/vektors/charset.raw'
Logo    Incbin  'dat:demodiskltp4/vektors/logo.raw'
Song    Incbin  'dat:demodiskltp4/vektors/p61.music'

                EVEN

col             SET     $000


PlasmaData      REPT    10

                REPT    15
                Dc      col
                Dc      col
                Dc      col
col             SET     col+$100
                ENDR

col             SET     $f00

                REPT    15
                Dc      col
                Dc      col
                Dc      col
col             SET     col-$100
                ENDR    

col             SET     $000

                REPT    15
                Dc      col
col             SET     col+$100
                ENDR

col             SET     $f00

                REPT    15
                Dc      col
                Dc      col
col             SET     col-$100
                ENDR    

                ENDR


        SECTION BlankArea,BSS_C

                Ds.B    88*40*3
ScreenScroller  Ds.B    88*40*3

                Ds.B    40*100
Ecran1          Ds.B    40*256
                Ds.B    40*100
Ecran2          Ds.B    40*256
                Ds.B    40*100

SampleBuffer    Ds.B    50000
