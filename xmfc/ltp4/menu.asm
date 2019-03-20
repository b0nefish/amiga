**********************************************************************
**
**
**      Demo selector (Ltp4 DemoDisk)
**
**      AsmONE version !
**
**      Auteur:
**      B.Sebastien [Ostyl]
**
**      Date:
**      26/08/00
**
**
**********************************************************************

;MakeFinal      EQU     1
;A500           EQU     1

NStar           EQU     60

        INCDIR  Includes:
        INCLUDE Startup.asm

        INCLUDE Hardware/custom.i

        INCLUDE Macros/Macros.i
        INCLUDE Macros/Copper.i
        INCLUDE Macros/Blitter.i

        INCLUDE Hardware/bplbits.i

        _CHIP   a0
        Move    #DMAF_SETCLR+DMAF_MASTER,dmacon(a0)
        Move    #INTF_SETCLR+INTF_INTEN,intena(a0)

        Moveq   #0,d0
        Lea     Song,a0
        Sub.L   a1,a1
        Lea     SampleBuffer,a2
        Bsr.W   P61_Init
        Tst.L   d0
        Bne.B   Error

        Bsr.W   InitStar
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
        Bsr.W   BlitClr
        Bsr.W   Selector
        Bsr.W   CopperWaves
        Bsr.W   StarsScript
        Bsr.W   MoveStars
        _CHIP   a6
        Bsr.W   P61_Music
        Bsr.W   DisplayStars
        Bsr.W   ScreenSwap
        Rts

InitDisplay
        Lea     VidePTR1,a0
        Move.L  #Vide,d0
        Move.L  #3,d1
        Move.L  #40*144,d2
        InitPtr

        Lea     VidePTR2,a0
        Move.L  #Text,d0
        Move.L  #3,d1
        Move.L  #40*144,d2
        InitPtr
        
        _CHIP   a0

        Moveq   #0,d0   
        Move    #$38,ddfstrt(a0)
        Move    #$d0,ddfstop(a0)

        IFND    A500
        Move    d0,fmode(a0)
        Fenetre 129,41,320,256,a0
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

        Lea     $dff002,a0
        WBlt    a0

        Lea     StarsCopper,a0
        Move.L  EcranPhysique(pc),d0
        Moveq   #3,d1
        Move.L  #40*256,d2
        InitPtr
        
        Rts

EcranLogique    Dc.L    StarsScreen1
EcranPhysique   Dc.L    StarsScreen2


**********************************************************************
**
**      Selector
**
**********************************************************************

Selector
        Move    Cmpt(pc),Old
        Move    $dff00a,Cmpt

ymouse  Move    Old(pc),d0
        Move    Cmpt(pc),d1
        Andi    #$ff00,d0
        Andi    #$ff00,d1
        Moveq   #9,d2
        Lsr     d2,d0
        Lsr     d2,d1
        Sub.B   d0,d1
        Ext     d1      
        Beq.B   MenuDone

        Tst     d1
        Bmi.B   nn
        Tst     MenuOffset
        Ble.B   nn
        Subi    #40*6,MenuOffset
        Subq    #6,MenuCnt

nn      Tst     d1
        Bpl     MenuDone
        Cmpi    #40*6*29,MenuOffset
        Bge.B   MenuDone
er      Addi    #40*6,MenuOffset
        Addq    #6,MenuCnt
        
MenuDone 
        Move    MenuCnt(pc),d0
        Bpl.B   Plus
        Neg     d0
Plus    Add     #32,d0
        Lsr     #6,d0
        IFND    A500
        Move    d0,DemoN
        ELSE
        Move    d0,$7fffe
        ENDC
        Rts

Cmpt    Ds      1
Old     Ds      1
MenuCnt Ds      1
DemoN   Ds      1

**********************************************************************
**
**      Wave
**
**********************************************************************

CopperWaves
        Addq    #2,Angle1
        Subq    #6,Angle2

        Lea     WaveCopper+4,a0
        Lea     SinTab(pc),a1
        Lea     CosTab(pc),a2   
        Lea     Menu+(40*60),a3

        Move    #60-1,d0

        Move    #511,d1
        Move    Angle1(pc),d2
        Move    Angle2(pc),d3
        Andi    d1,d2
        Andi    d1,d3
        Move    d2,d4
        Move    d3,d5

        Moveq   #0,d7

CopperWave
        Moveq   #0,d1

;--- vertical wave      
;
        Subq    #3,d4
        Addq    #6,d5
        Andi    #511,d4
        Andi    #511,d5

        Move    d4,d6
        Add     d6,d6
        Move    (a1,d6.W),d1    

        Move    d5,d6
        Add     d6,d6
        Add     (a1,d6.W),d1
        
        Muls    #10,d1
        Asr     #8,d1
        Addq    #1,d7
        Add     d7,d1
        Mulu    #40,d1
        Add     MenuOffset(pc),d1

        Move    #40*315,d2

;--- rempli la copperlist
;
        Ext.L   d1
        Add.L   a3,d1
        
FillCopper
        Move    d1,6(a0)
        Swap    d1
        Move    d1,2(a0)
        Swap    d1
        Add.L   d2,d1
        Move    d1,14(a0)
        Swap    d1
        Move    d1,10(a0)
        Swap    d1
        Add.L   d2,d1
        Move    d1,22(a0)
        Swap    d1
        Move    d1,18(a0)
        Lea     (3*8)+8(a0),a0
        Dbf     d0,CopperWave
        Rts

Angle1  Ds      1
Angle2  Ds      1

MenuOffset      Ds      1

        Include asm:xmfc_demodisk/theplayer.asm

**********************************************************************
**
**      3d-starfield
**
**********************************************************************

Largeur EQU     320/8
Hauteur EQU     256

InitStar
        Lea     Star3d(pc),a0
        Move    #NStar-1,d1

LoopFirst
        Bsr.B   Rnd
        Move    d0,(a0)+
        Bsr.B   Rnd
        Move    d0,(a0)+
        Bsr.B   Rnd
        Move    d0,(a0)+
        Dbf     d1,LoopFirst
        Rts

;-------------
;---- Ran ----
;d0>    0 < x < 255
;
Rnd     Movem.L a0/a1/d1/d2,-(sp)
        Lea     ScrambleTabLo(pc),a0
        Lea     ScrambleTabHi(pc),a1
        Moveq   #0,d0
        Moveq   #0,d1
        Move.B  $dff007,d0
        Move.B  d0,d1
        Moveq   #$f,d2
        And.B   d2,d0
        Lsr.B   #4,d1
        Move.B  (a0,d0.W),d0
        Move.B  (a1,d1.W),d1
        Or.B    d1,d0
        Move.B  $bfd800,d1
        Ext     d0
        Ext     d1
        Sub     d1,d0
        Asl     #4,d0
        Movem.L (sp)+,a0/a1/d1/d2
        Rts

ScrambleTabLo   Dc.B    $1,$9,$e,$a,$3,$6,$0,$f,$7,$4,$c,$2,$8,$5,$b,$d
ScrambleTabHi   Dc.B    $e0,$30,$60,$b0,$00,$90,$20,$70,$c0,$f0,$80,$10
                Dc.B    $d0,$40,$50,$a0

;-----------------------------
;-----------------------------
;Rotation & Translation
;
MoveStars
        Movem.L d0-a5,-(sp)

        Lea     Star3d(pc),a3
        Lea     NewStar3d(pc),a5

        Move.L  CameraControl(pc),a4
        Move    #511,d1

;Angle A
        Move    StarAngleX(pc),d0
        Add     (a4),d0
        And     d1,d0
        Move    d0,StarAngleX   

;Angle B
        Move    StarAngleY(pc),d0
        Add     2(a4),d0
        And     d1,d0
        Move    d0,StarAngleY

;Angle C
        Move    StarAngleZ(pc),d0
        Add     4(a4),d0
        And     d1,d0
        Move    d0,StarAngleZ

        Lea     SinTab(pc),a1
        Lea     CosTab(pc),a2
        Move    #NStar-1,d0

Loop3d  Move.L  d0,-(sp)
        Moveq   #0,d0
        Moveq   #0,d2
        Moveq   #0,d4

        Movem   (a3),d0/d2/d4           ;d0=x d2=y d4=z 
        Move.L  d0,d1
        Move.L  d2,d3
        Move.L  d4,d5

;Rotation des etoiles autour de Z
;
        Move    StarAngleZ(pc),d6       
        Add     d6,d6
        Move    (a1,d6.W),d7            ;d7=sin x
        Move    (a2,d6.W),d6            ;d6=cos x
        Muls    d6,d0                   ;x=(x*cos)
        Muls    d7,d2                   ;y=(y*sin)
        Muls    d7,d1                   ;x1=(x1*sin)
        Muls    d6,d3                   ;y1=(y1*cos)
        Add.L   d2,d0
        Sub.L   d1,d3
        Asr.L   #8,d0
        Asr.L   #8,d3

        Move    d0,(a5)+
        Move    d3,(a5)+
        Move    d5,(a5)+

;----------------------
;---- Translations ----
;
        Movem   (a3),d0-d2
        Add     6(a4),d0
        Add     8(a4),d1
        Add     10(a4),d2
        Move    #255,d3
        And     d3,d0
        And     d3,d1
        And     d3,d2
        Ext     d0
        Ext     d1
        Ext     d2
        Move    d0,(a3)+
        Move    d1,(a3)+
        Move    d2,(a3)+
        Move.L  (sp)+,d0

        Dbf     d0,Loop3d
        Movem.L (sp)+,d0-a5
        Rts

StarAngleX      Dc      0
StarAngleY      Dc      0
StarAngleZ      Dc      0


Star3d          Ds.L    3*NStar
NewStar3d       Ds      3*NStar*2

;-----------------------------
;-----------------------------
;>a0    ecran
;>a1    tableau des points 3d
;>d5    nb points
;

Focale  EQU     200
XAdd    EQU     320/2
YAdd    EQU     Hauteur/2

x       EQU     0
y       EQU     2
z       EQU     4

nx      EQU     0
ny      EQU     2
nz      EQU     4

XClipGauche     EQU     1
XClipDroit      EQU     320-1
YClipHaut       EQU     1
YClipBas        EQU     Hauteur-1
ZClip           EQU     200

DisplayStars
        Move.L  EcranLogique(pc),a0
        Lea     NewStar3d(pc),a1
        Lea     Star3d(pc),a3
        Lea     MulsTab(pc),a4

        Lea     $dff002,a5

        Move    #NStar-1,d5

;-------------------------------
;---- Clipping & Projection ----
;
LoopStar
        Move    nz(a1),d2
        Addi    #150,d2
        Cmpi    #ZClip,d2
        Bgt.W   Out

Xcoord  Moveq   #0,d0
        Moveq   #0,d1
        Moveq   #0,d4

        Move    (a1),d0                 ;(nx=0)
        Ext.L   d0
        Tst     d2
        Beq.B   XDivs0
        Asl.L   #7,d0
        Divs    d2,d0
        Ext.L   d0
        Asr.L   d0

XDivs0  Move    #XAdd,d4
        Add.L   d4,d0
        Cmpi    #XClipGauche,d0
        Bmi.B   Out
        Cmpi    #XClipDroit,d0
        Bpl.B   Out
        
Ycoord  Move    ny(a1),d1
        Ext.L   d1
        Tst     d2
        Beq.B   YDivs0
        Asl.L   #7,d1
        Divs    d2,d1
        Ext.L   d1
        Asr.L   d1

YDivs0  Move    #YAdd,d4
        Add.L   d4,d1   
        Cmpi    #YClipHaut,d1
        Bmi.B   Out
        Cmpi    #YClipBas,d1
        Bpl.B   Out

Plot    Addq.L  #nx+ny+nz,a1
        Addq.L  #x+y+z,a3

;--------------------
;---- BitPlotter ----
;
        Lea     Largeur*Hauteur(a0),a2

        Move.L  d0,d3
        Lsr     #3,d3   
        Add     d1,d1
        Add     (a4,d1.W),d3
        Not     d0
        Moveq   #$7,d1
        And.B   d1,d0

        WBlt    a5

Ink1    Cmpi    #100,d2         ;blancs
        Bgt.B   Ink2
        Bset    d0,(a0,d3.L)
        Dbf     d5,LoopStar
        Rts

Ink2    Cmpi    #120,d2         ;moyen
        Bgt.B   Ink3
        Bset    d0,(a2,d3.L)
        Dbf     d5,LoopStar
        Rts

Ink3    Bset    d0,(a0,d3.L)
        Bset    d0,(a2,d3.L)
        Dbf     d5,LoopStar
        Rts

Out     Addq.L  #2*3,a3
        Addq.L  #nx+ny+nz,a1
        Dbf     d5,LoopStar
        Rts

;-----------------------------
;-----------------------------
;
StarsScript
        Move.L  #Mode1,CameraControl
        Rts

Mode1   Dc      0,0,1
        Dc      -4,2,2
        
Mode2   Dc      0,1,0
        Dc      0,0,-12

Mode3   Dc      0,1,0
        Dc      -10,0,-10

Mode4   Dc      0,0,3
        Dc      0,0,-20

Mode5   Dc      2,0,3
        Dc      0,-1,-2

**********************************************************************
**
**      Blitter clearing
**
**********************************************************************

BlitClr Lea     $dff002,a0
        Move.L  EcranLogique(pc),d1
        Move    #$0100,d2
        Move    #(Hauteur*2)*64+(Largeur/2),d3
        Moveq   #0,d4
        WBlt    a0
        Move.L  d1,bltdpt-2(a0)
        Move    d2,bltcon0-2(a0)
        Move    d4,bltcon1-2(a0)
        Move.L  d4,bltafwm-2(a0)
        Move    d4,bltdmod-2(a0)
        Move    d3,bltsize-2(a0)
        Rts

CameraControl   Dc.L    0

        EVEN

k       SET     0
MulsTab REPT    260
        Dc      k
k       SET     k+40
        ENDR

**********************************************************************
**
**      FASTMEM DATAS SECTION
**
**********************************************************************

SinTab  Incbin  Includes:Table/sin
CosTab  Incbin  Includes:Table/cos

**********************************************************************
**
**      CHIPMEM DATAS SECTION
**
**********************************************************************

        SECTION ChipMemDatas,DATA_C

CopperList

StarsCopper
        CMove   0,$e4   ;2
        CMove   0,$e6
        CMove   0,$ec   ;4
        CMove   0,$ee
        CMove   0,$f4   ;6
        CMove   0,$f6

VidePTR1
        CMove   0,$e0   ;1
        CMove   0,$e2
        CMove   0,$e8   ;3
        CMove   0,$ea
        CMove   0,$f0   ;5
        CMove   0,$f2

        CMove   $6000+BPLF_COLOR+BPLF_DPF,bplcon0
        CMove   0,bplcon1
        CMove   0,bpl1mod
        CMove   0,bpl2mod

        WaitRefresh
        SprCtrl 0,0,0,1
        SprCtrl 1,0,0,1
        SprCtrl 2,0,0,1
        SprCtrl 3,0,0,1
        SprCtrl 4,0,0,1
        SprCtrl 5,0,0,1
        SprCtrl 6,0,0,1
        SprCtrl 7,0,0,1

        Incbin  'menu.pal'
        CMove   $eef,color+(9*2)
        CMove   $778,color+(10*2)
        CMove   $446,color+(11*2)

        SetCopW 0,120

WaveCopper
        REPT    60
        IncCWait
        CMove   0,$e0   ;1
        CMove   0,$e2
        CMove   0,$e8   ;3
        CMove   0,$ea
        CMove   0,$f0   ;5
        CMove   0,$f2
        CMove   0,bplcon1
        ENDR

        IncCWait
VidePTR2
        CMove   0,$e0   ;1
        CMove   0,$e2
        CMove   0,$e8   ;3
        CMove   0,$ea
        CMove   0,$f0   ;5
        CMove   0,$f2

        CEnd

Menu    Incbin  'menu.raw'
Text    Incbin  'text.raw'
Song    Incbin  'p61.music'

        SECTION BlankArea,BSS_C

StarsScreen1    Ds.B    40*256*3
StarsScreen2    Ds.B    40*256*3        
SampleBuffer    Ds.B    70000   
Vide            Ds.B    40*144*3
