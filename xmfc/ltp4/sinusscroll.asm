**********************************************************************
**
**
**      SinusScroll (Ltp4 DemoDisk)
**
**      AsmONE version !
**
**      Auteur:
**      B.Sebastien [Ostyl]
**
**      Date:
**      24/08/00
**
**
**********************************************************************

        Incdir  Includes:
        Include Hardware/custom.i
        Include Hardware/intbits.i
        Include Hardware/bplbits.i
        Include Macros/macros.i
        Include Macros/blitter.i
        Include Macros/copper.i
        Include Macros/ecran.i

;MakeFinal      EQU     1
;A500           EQU     1
RasterTime      EQU     0
NStar           EQU     52

        Include Startup.asm

        _CHIP   a0
        Move    #DMAF_SETCLR+DMAF_MASTER+DMAF_BLITTER+DMAF_BLITHOG,dmacon(a0)
        Move    #INTF_SETCLR+INTF_INTEN,intena(a0)

SinusDemo
        Moveq   #0,d0
        Lea     Song,a0
        Sub.L   a1,a1
        Lea     SampleBuffer,a2
        Bsr.W   P61_Init
        Tst.L   d0
        Bne.B   Error

        Bsr.W   InitEcran
        Bsr.W   InitStar
        Bsr.W   MakeRaster

        Move.L  #VblInterrupt,Lev3Vbl
        Move    #INTF_SETCLR+INTF_VERTB,$dff000+intena

        Bsr.W   StarsScript
        Bsr.W   MoveStars

MouseLoop

        WaitLMB MouseLoop

        _CHIP   a0
        WaitBlt a0

        Jsr     P61_End

Error   Rts

VblInterrupt
        Bsr.W   EffaceEcran
        Bsr.W   CopperCurve
        Bsr.W   StarsScript
        Bsr.W   MoveStars
        Bsr.W   MoveLogo
        Bsr.W   Scroller
        Bsr.W   DisplayStars
        Bsr.W   CurveScroll
        Bsr.W   ScreenSwap
        _CHIP   a6
        Bsr.W   P61_Music
        Rts

;-----------------------------
;-----------------------------
;Initialise l'ecran
;
Largeur EQU     (320/16)*2
Hauteur EQU     180

InitEcran
        Lea     LogoPTR,a0
        Move.L  #Logo,d0
        Moveq   #5,d1
        Move.L  #40*160,d2
        InitPtr

        _CHIP   a5
        Moveq   #0,d0                           
        Move    #$38,ddfstrt(a5)
        Move    #$d0,ddfstop(a5)

        IFND    A500
        Fenetre 144,44,320,260,a5
        ELSE
        Move    #$2890,diwstrt(a5)
        Move    #$2cd0,diwstop(a5)
        ENDC

        Move    d0,bplcon2(a5)

        Lea     CopperList,a0
        Move.L  a0,cop1lc(a5)   
        Move    d0,copjmp1(a5)

        Move    #DMAF_SETCLR+DMAF_COPPER,dmacon(a5)
        Rts

;-------------------------
;---- ClrBLITTER 2bpl ----
;
EffaceEcran
        _CHIP   a0
        Move.L  EcranLogique(pc),d1
        Move    #$0100,d2
        Move    #((Hauteur*3)-1)*64+(Largeur/2),d3
        Moveq   #0,d4
        WaitBlt a0
        Move.L  d1,bltdpt(a0)
        Move    d2,bltcon0(a0)
        Move    d4,bltcon1(a0)
        Move.L  d4,bltafwm(a0)
        Move    d4,bltdmod(a0)
        Move    d3,bltsize(a0)
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

        Lea     StarFieldPTR,a0
        Move.L  EcranPhysique(pc),d0
        Moveq   #3,d1
        Move.L  #Largeur*Hauteur,d2
        InitPtr

        Move    #DMAF_SETCLR+DMAF_RASTER,dmacon(a5)
        Rts

EcranLogique    Dc.L    Ecran1
EcranPhysique   Dc.L    Ecran2

;-----------------------------
;-----------------------------
;rasters
;
MakeRaster
        Lea     BigRasterBar,a0
        Lea     Colors(pc),a1
        Move    #180-1,d0

LoopRaster
        Move    (a1)+,6(a0)
        Lea     16(a0),a0
        Dbf     d0,LoopRaster
        Rts

MoveLogo
        Lea     LogoModulo,a0
        Lea     Sin(pc),a1
        Move    SinPos(pc),d0
        Lsr     d0
        Andi    #511,d0
        Add     d0,d0
        Move    (a1,d0.W),d0
        Bpl.B   modol
        Neg     d0
modol   Lsr     #2,d0
        Mulu    #40,d0
        Move    d0,2(a0)        
        Move    d0,6(a0)
        Rts

;-----------------------------
;-----------------------------
;Randomize les premiére étoiles
;
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

        Lea     Sin(pc),a1
        Lea     Cos(pc),a2
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
        Lea     Largeur*Hauteur*2(a0),a2

        Move.L  d0,d3
        Lsr     #3,d3   
        Add     d1,d1
        Add     (a4,d1.W),d3
        Not     d0
        Moveq   #$7,d1
        And.B   d1,d0

Ink1    Cmpi    #100,d2         ;blancs
        Bgt.B   Ink2
        Bset    d0,(a0,d3.L)
        Dbf     d5,LoopStar
        Rts

Ink2    Cmpi    #150,d2         ;moyen
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


CameraControl   Dc.L    0

**********************************************************************
**
**      Double curve scrolling
**
**********************************************************************

CurveScroll
        _CHIP   a5
        Lea     EcranScroll,a4  
        Move.L  EcranLogique(pc),a1
        Lea     (Largeur*Hauteur)+6(a1),a1
        Lea     Cos(pc),a2
        Lea     MulsTab(pc),a3

        Addq    #8,SinPos
        Moveq   #14-1,d0
        Moveq   #40-2,d1
        Moveq   #42-2,d7
        Move.L  #$00030003,d2
        Move.L  #(%0000110100000000!(A!B))<<16,d3
        Move    #(16*64)+1,d4
        Move    SinPos(pc),d5
        Andi    #511*2,d5

        WaitBlt a5
        Move    d7,bltamod(a5)
        Move    d1,bltbmod(a5)
        Move    d1,bltdmod(a5)
        Move.L  d3,bltcon0(a5)  

        Move    #340,d1
        Move    #511*2,d3

BlitLoop
        REPT    8
        Move    d5,d6
        Move    (a2,d6.W),d6
        Add     d1,d6
        Asr     #2,d6
        Add     d6,d6
        Move    (a3,d6.W),d6
        Lea     (a1,d6.W),a6
        Ror.L   #2,d2
        Addq    #2,d5
        Andi    d3,d5
        Movea.L a6,a0
        IFND    A500
        WaitBlt a5
        ENDC
        Movem.L a0/a4/a6,bltbpt(a5)
        Move.L  d2,bltafwm(a5)
        Move    d4,bltsize(a5)  
        ENDR
        Addq.L  #2,a4
        Addq.L  #2,a1
        Dbf     d0,BlitLoop
        Rts
        
CopperCurve     
        Lea     BigRasterBar,a0
        Lea     Cos,a1
        Move    #Hauteur-18,d0
        Moveq   #0,d1
        Move    SinPos(pc),d1
        Moveq   #15,d4
        Move    #511,d5

        Clr     14(a0)  

LoopCurve
        Move    d1,d2
        Add     d2,d2
        Move    (a1,d2.W),d2
        Asr     #3,d2
        Move    d2,d3

        Asr     #4,d3   
        Add     d3,d3
        Neg     d3

        Add     d3,14(a0)
        Addq.L  #8,a0
        Addq.L  #8,a0
        Neg     d3
        Move    d3,14(a0)

        And.B   d4,d2
        Lsl.B   #4,d2
        Move.B  d2,11(a0)

        Addq    #2,d1
        And     d5,d1
        Dbf     d0,LoopCurve
        Rts

SinPos  Ds      1

;-------------------------------
;-------------------------------
;Affiche une fonte
;
Scroller
        _CHIP   a0

        Moveq   #0,d0   
        Move.B  ScrollCnt(pc),d0
        And.L   Speed+4(pc),d0          ; fréquence d'affichage
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
        Add     d0,d0

;-------------------------
;---- Copie une fonte ----
;-------------------------
;
        Lea     Fontes,a1
        Lea     (a1,d0.L),a1    ; pointeur sur la fonte à copier
        
        Lea     EcranScroll+40,a2
        Moveq   #-1,d0
        Move    #(944/8)-2,d2
        Move    #42-2,d3
        Move    #%0000100100000000!A,d4
        Move    #(16*64)+1,d5
        Moveq   #0,d6

BltLoop
        WaitBlt a0
        Move.L  a1,bltapt(a0)
        Move.L  a2,bltdpt(a0)   
        Move    d2,bltamod(a0)
        Move    d3,bltdmod(a0)
        Move.L  d0,bltafwm(a0)          
        Move    d4,bltcon0(a0)
        Move    d6,bltcon1(a0)
        Move    d5,bltsize(a0)  

ScrollEnd
        Addq.B  #2,ScrollCnt

;---------------------------
;---- Decale la memoire ----
;---------------------------
;
        _CHIP   a0
        Lea     EcranScroll,a1
        Lea     (42*16)-2(a1),a1
        Moveq   #0,d0
        Moveq   #-1,d1
        Move.L  #((%0010100100000000!A)<<16)!%10,d2
        WaitBlt a0
        Move.L  a1,bltapt(a0)
        Move.L  a1,bltdpt(a0)   
        Move.L  d0,bltamod(a0)
        Move.L  d1,bltafwm(a0)          
        Move.L  d2,bltcon0(a0)
        Move    #(16*64)+21,bltsize(a0)
        Rts

Speed           Dc.L    ((%0010100100000000!A)<<16)!%10,15
ChrCnt          Dc      0
ScrollCnt       Dc.B    0

ScrollText
        Dc.B    'WELCOME TO THIS NEW PART '
        Dc.B    'CALLED - SINUS DEMO - '
        Dc.B    'THIS DISK WAS RELEASED FOR THE LUCKY & TIGROU PARTY 4 '
        Dc.B    'DEMO COMPETITION HELD IN FRANCE ON THE 25-27 '
        Dc.B    'AUGUST 2000 !! !!   ENJOY IT OR DIE !! !!       '
        Dc.B    'THE CURRENT MEMBER LIST IS: '
        Dc.B    '-OSTYL- (CODE AND SOME GFX) '
        Dc.B    '-GLAVIATOR- (GFX AND SWAPPING) '
        Dc.B    '-EXPLOSATOR- (MUSIC AND BBS DARKLOGIK) '
        Dc.B    '-MICKEYLANGELATOR- (GFX AND MAIL TRADING) '
        Dc.B    '-SALVATOR- (GFX SWAP AND SOME MUSIC) '
        Dc.B    '         '
        Dc.B    'ARE YOU STILL WAITING FOR THE GREETINGS? HERE THEY ARE...   '
        Dc.B    'OSTYL TURNS HIS GOLDEN REGARDS TO THE FOLLOWING '
        Dc.B    '(SORTED FROM Z TO A) '
        Dc.B    'X-MEN - '
        Dc.B    'VISION - '
        Dc.B    'UPFRONT - '
        Dc.B    'UNIVERSE (THANX FOR NICE CONTACTING) -'
        Dc.B    'UKONX (DEEMPHASIS) - '
        Dc.B    'THE DANISH INC - '
        Dc.B    'TETRAFORCE - '
        Dc.B    'SILENTS DK - '
        Dc.B    'PURE - '
        Dc.B    'POLARIS (HIE YES LE 17 EN FORCE YEAH!) - '
        Dc.B    'ORANGE JUICE (THANX THIS GREAT PARTY) - '
        Dc.B    'MANKIND (KRABOB AND TEX)) - '
        Dc.B    'KIKI PRODUCTION (HEY PIAARK) - '
        Dc.B    'FLASH PRODUCTION - '
        Dc.B    'FAIRLIGHT - '
        Dc.B    'DOUBLE LIGHT - '
        Dc.B    'DEXION - '
        Dc.B    'CRYSTAL - '
        Dc.B    'CRIONICS - '
        Dc.B    'COMPLEX (TITAN) - '
        Dc.B    'BAMIGA SECTOR ONE DK - '
        Dc.B    'ATLANTYS (JOKER, NICE TO MET YOU AT LTP4 DUDE) - '
        Dc.B    'ANARCHY '
        Dc.B    '          '
        Dc.B    'ANOTHER STEP TOWARDS INTELIGENCE WITH XMFC '    
        Dc.B    '          '
        Dc.B    'CREDITS FOR THIS PART ARE GREAT CODING AND THE LOGO ' 
        Dc.B    'BY THE BEST AND THE ONLY OSTYL !! '
        Dc.B    '                '
        Dc.B    'THAT IS ALL FOR HERE, SEE YOU IN ANOTHER COOL PRODUCTION !! '
        Dc.B    'SCROLLY RESTART   ---------------------------------'
        Dc.B    '-------------------------------                    ',0

        EVEN

        Include asm:xmfc_demodisk/theplayer.asm

**********************************************************************
**
**
**      DATAS SECTION
**
**
**********************************************************************

Sin     Incbin  Includes:Table/Sin
Cos     Incbin  Includes:Table/Cos

Colors  Incbin  'bigshade.clist'

k       SET     0
MulsTab REPT    200
        Dc      k
k       SET     k+40
        ENDR

        SECTION ChipDatas,Data_C

CopperList

StarFieldPTR
        BplPtr  3

        CMove   $3000+BPLF_COLOR,bplcon0
        CMove   0,bpl1mod
        CMove   0,bpl2mod

        WaitRefresh
        SprCtrl 0,0,0,0
        SprCtrl 1,0,0,0
        SprCtrl 2,0,0,0
        SprCtrl 3,0,0,0
        SprCtrl 4,0,0,0
        SprCtrl 5,0,0,0
        SprCtrl 6,0,0,0
        SprCtrl 7,0,0,0

        CMove   $000,$180
        CMove   $ccc,$182
        CMove   $fff,color+6
        CMove   $567,color+8
        CMove   $333,color+10

BigRasterBar
        SetCopW 0,43
        REPT    Hauteur
        IncCWait
        CMove   0,color+4
        CMove   0,bplcon1
        CMove   0,bpl2mod
        ENDR

        IncCWait
        CMove   BPLF_COLOR,bplcon0
        CMove   $f00,$180

        IncCWait
LogoPTR BplPtr  5
        CMove   $5000+BPLF_COLOR,bplcon0
        Incbin  'logopal.clist'

        IncCWait

LogoModulo
        CMove   0,bpl1mod
        CMove   0,bpl2mod
        IncCWait
        CMove   0,bpl1mod
        CMove   0,bpl2mod
        CPal

        SetCopW 0,25
c       Set     $000

        REPT    14      
        IncCWait
        CMove   c,color
c       Set     c+$111
        ENDR    

        CEnd

Logo            Incbin  'logo.raw'
Song            Incbin  'p61.spectra'
Fontes          Incbin  'fonts.raw'

        SECTION BlankArea,Bss_C
        
Ecran1          Ds.B    Largeur*Hauteur*3
Ecran2          Ds.B    Largeur*Hauteur*3
EcranScroll     Ds.B    42*16
SampleBuffer    Ds.B    32400
