**********************************************************************
**
**
**      Bob-Scrolling (Ltp4 DemoDisk)
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

Start   _CHIP   a0
        Move    #DMAF_SETCLR+DMAF_MASTER+DMAF_BLITTER,dmacon(a0)
        Move    #INTF_SETCLR+INTF_INTEN,intena(a0)

        Moveq   #0,d0
        Lea     Song,a0
        Sub.L   a1,a1
        Lea     SampleBuffer,a2
        Bsr.W   P61_Init
        Tst.L   d0
        Bne.B   Error

        Bsr.W   InitStarField
        Bsr.W   InitRainbow
        Bsr.W   InitEcran

        Move.L  #Vbl,Lev3Vbl
        Move    #INTF_SETCLR+INTF_VERTB,$dff000+intena

Main    WaitLMB Main

        _CHIP   a6
        Bsr.W   P61_End

Error   Moveq   #0,d0
        Rts

;==================================
;----------------------------------
;
Vbl     _CHIP   a6
        Bsr.W   Clr
        Bsr.W   MontsScrolling
        Bsr.W   P61_Music
        Bsr.W   BarEqualizer
        Bsr.W   JmpLogo
        Bsr.W   Scroller
        Bsr.W   ScreenSwap
        Rts

;==================================
;----------------------------------
;Initialise l'ecran
;
Largeur EQU     (320/16)*2
Hauteur EQU     180

InitEcran
        Lea     MontsPTR,a0
        Move.L  #Monts,d0
        Moveq   #3,d1
        Move.L  #80*150,d2
        InitPtr

        Lea     LogoPTR,a0
        Move.L  #Logo+(40*62),d0
        Moveq   #4,d1
        Move.L  #40*146,d2
        InitPtr

        _CHIP   a5
        Moveq   #0,d0                           

        IFND    A500
        Fenetre 129,44,320,240,a5
        Move    d0,fmode(a5)
        Move    #BPLF_PF2OF0+BPLF_PF2OF1,bplcon3(a5)
        Move    #BPLF_OSPRM4+BPLF_ESPRM4,bplcon4(a5)
        ELSE
        Move    #$2c81,diwstrt(a5)
        Move    #$1cc1,diwstop(a5)
        ENDIF

        Move    d0,bplcon2(a5)

        Lea     CopperList,a0
        Move.L  a0,cop1lc(a5)   
        Move    d0,copjmp1(a5)

        Move    #DMAF_SETCLR+DMAF_COPPER+DMAF_RASTER,dmacon(a5)
        Rts

;==================================
;----------------------------------
;
ScreenSwap
        Move.L  EcranLogique(pc),d0
        Move.L  EcranPhysique(pc),d1
        Move.L  d0,EcranPhysique
        Move.L  d1,EcranLogique

        Lea     BobsPTR,a0
        Move.L  EcranPhysique,d0
        Addq.L  #2,d0
        Moveq   #3,d1
        Moveq   #48,d2
        InitPtr
        Rts

EcranLogique    Dc.L    BobsScreen1
EcranPhysique   Dc.L    BobsScreen2     

;==================================
;----------------------------------
;
InitStarField
        Lea     StarsField+15,a0
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
        Lea     28(a0),a0
        Dbf     d3,StarsLoop1
        Rts

InitRainbow
        Lea     MountainRainbw(pc),a0
        Lea     2*20(a0),a0
        Lea     ScrollerRainbw(pc),a1
        Lea     StarsField,a2
        Lea     StarsField,a3
        Lea     (28*20)+6(a2),a2
        Lea     (28*10)+10(a3),a3
        Moveq   #(126-28)-1,d0
Loop1   Move    (a0)+,(a2)
        Move    (a1)+,(a3)
        Lea     28(a2),a2       
        Lea     28(a3),a3
        Dbf     d0,Loop1
        Rts

MountainRainbw  Incbin  'dat:demodiskltp4/rasterdemo/mountain.rainb'
ScrollerRainbw  Incbin  'dat:demodiskltp4/rasterdemo/scroll.rainb'

;==================================
;----------------------------------
;
MontsScrolling
        Lea     MontsScroll,a0

        Move    MontsScrollCnt(pc),d0
        Cmpi    #320,d0
        Blt.B   Ok
        Clr     MontsScrollCnt
        Moveq   #0,d0
Ok      Move    d0,d1
        Lsr     #4,d0
        Add     d0,d0
        Neg     d0
        Move    d0,6(a0)
        Andi.B  #15,d1
        Move    d1,2(a0)
        Addq    #2,MontsScrollCnt

ScrollStars
        Lea     StarsField+15,a0
        Moveq   #(100/2)-1,d0
        Moveq   #1,d1
        Moveq   #2,d2   

ScrollStarsLoop
        Sub.B   d1,(a0)
        Lea     28(a0),a0
        Sub.B   d2,(a0)
        Lea     28(a0),a0
        Dbf     d0,ScrollStarsLoop

FinScroll
        Rts

MontsScrollCnt  Ds      1

********************************************************************
**
**
**      Bob-Scroller
**
**
********************************************************************

Scroller
        Move    ScrollBobs(pc),d0
        Andi    #31,d0
        Move    d0,ScrollBobs
        Bne.W   DisplayBobs

;prend une nouvelle fonte
;
GetText Lea     Text(pc),a0
        Move    ChrCnt(pc),d0
        Addq    #1,ChrCnt
        Moveq   #0,d1
        Move.B  (a0,d0.W),d1
        Bne.B   GetEffect1
        Clr     ChrCnt
        Bra.B   GetText 
        
GetEffect1
        Cmpi.B  #"#",d1
        Bne.B   GetEffect2
        Move.B  1(a0,d0.W),ScrollSpeed+1
        Move.B  2(a0,d0.W),ScrollSinSpeed+1     
        Sf.B    ScrollAbsSin
        Addq    #2,ChrCnt
        Bra.B   GetText 

GetEffect2
        Cmpi.B  #"*",d1
        Bne.B   GetFont
        Move.B  1(a0,d0.W),ScrollSpeed+1
        Move.B  2(a0,d0.W),ScrollSinSpeed+1     
        St.B    ScrollAbsSin
        Addq    #2,ChrCnt
        Bra.B   GetText 

GetFont Sub.B   #32,d1
        Add     d1,d1
        Add     d1,d1
        Move.L  d1,m0+4 

;Swap les bobs
;
        Lea     m11+4(pc),a0
        Lea     m12+4(pc),a1
        REPT    12
        Move.L  (a0),(a1)
        Subq    #8,a0
        Subq    #8,a1
        ENDR

        Move    ScrollSinSpeed(pc),d0
        Sub     d0,Deph

DisplayBobs
        Lea     $dff002,a6
        Lea     SinTab(pc),a0
        Lea     m1(pc),a1
        Move    Angle(pc),d7
        Add     Deph(pc),d7
        Andi    #511,d7
        Move    d7,d6

;Pre-Init blitter
        Move    #(1888/8)-6,d0
        Swap    d0
        Move    #48-6,d0
        WBlt    a6
        Move.L  #$ffff0000,bltafwm-2(a6)
        Move.L  d0,bltamod-2(a6)
        Move    d0,bltbmod-2(a6)

        Move    ScrollSinSpeed(pc),d7

        Move    #11-1,d0
        
LoopScroolBobs
        Move.L  d0,-(sp)
        Move    d6,d5
        Add     d5,d5
        Move    (a0,d5.W),d5
        Bmi.B   ImNegativ
        Tst.B   ScrollAbsSin
        Beq.B   ImNegativ       
        Neg     d5
ImNegativ
        Asr     #3,d5
        Addi    #56,d5
        Ext.L   d5
        Move.L  (a1)+,d0
        Move.L  d5,d1
        Move.L  (a1)+,d2
        Bsr.B   GrabBob
        Add     d7,d6
        Andi    #511,d6
        Move.L  (sp)+,d0
        Dbf     d0,LoopScroolBobs

        Addq    #8,Angle
        Move    ScrollSpeed(pc),d0
        Add     d0,ScrollBobs
        Rts

**********************************************************************
**
**
**      d0      =       bob_x
**      d1      =       bob_y
**
**
**********************************************************************

GrabBob Lea     Fonts,a4
        Lea     (a4,d2.L),a4

        Sub     ScrollBobs(pc),d0

        Move    d0,d2
        Lsr     #4,d0   
        Add     d0,d0
        Andi    #15,d2
        Ror     #4,d2
        Ori     #%0000110100000000!(A!B),d2
        Swap    d2
        Clr     d2

        Lea     MulTab(pc),a5
        Add     d1,d1
        Add     (a5,d1.W),d0

        Move.L  EcranLogique(pc),a5
        Lea     (a5,d0.W),a5

        WBlt    a6
        Move.L  a4,bltapt-2(a6)
        Move.L  a5,bltbpt-2(a6)
        Move.L  a5,bltdpt-2(a6)
        Move.L  d2,bltcon0-2(a6)
        Move    #(32*3*64)+3,bltsize-2(a6)
        Rts

m0      Dc.L    0,0
m1      Dc.L    32*11,0
m2      Dc.L    32*10,0
m3      Dc.L    32*09,0
m4      Dc.L    32*08,0
m5      Dc.L    32*07,0
m6      Dc.L    32*06,0
m7      Dc.L    32*05,0
m8      Dc.L    32*04,0
m9      Dc.L    32*03,0
m10     Dc.L    32*02,0
m11     Dc.L    32*01,0
m12     Dc.L    0,0

ScrollBobs      Ds      1
Angle           Ds      1
ChrCnt          Ds      1

ScrollSinSpeed  Dc      60
ScrollSpeed     Dc      2
ScrollAbsSin    Dc.B    0,0     
Deph            Ds      1

Text    Dc.B    "#",4,70
        Dc.B    "YEAH FANS !!!! WELCOME TO THIS " 
        Dc.B    "X-METAL FORCE CREW LTP2K-MEGADEMO "
        Dc.B    "          "
        Dc.B    "#",4,15
        Dc.B    "AND ME OSTYL I'M SURE YOU WILL ALL ENJOY THIS DISK FILLED "
        Dc.B    "WITH NICE PIECES OF TRUE OLDSCHOOL DEMONSTRATION "
        Dc.B    "          "
        Dc.B    "#",2,50
        Dc.B    "CREDITS ARE ALL CODING BY OSTYL "
        Dc.B    "CHARSET BY DRUCER OF NORTHSTAR AND THE MUSIC WAS RIPPED..."
        Dc.B    "BUT WHO CARE ??? "
        Dc.B    "          "
        Dc.B    "*",4,50
        Dc.B    "THIS MEGADEMO WAS RELEASED FOR THE LUCKY AND TIGROU PARTY 2000 "
        Dc.B    "IN FRANCE (NEAR PARIS) "  
        Dc.B    "          "
        Dc.B    "#",4,20
        Dc.B    "AND A MEGA BIG GREETING MUST FLY TO "
        Dc.B    "THE PARTY ORGANIZER... YEAH THANX YOU FOR THIS DAMN FUCKING "
        Dc.B    "HOT GATHERING !!! "
        Dc.B    "          "
        Dc.B    "*",8,30
        Dc.B    "AND BECAUSE IM THE BEST, IT WILL WIN THE OLDSCHOOL " 
        Dc.B    "DEMO-COMPETION........................" 
        Dc.B    "          "
        Dc.B    "#",8,8
        Dc.B    "NO ONE CAN JUST FIGHT WITH US "
        Dc.B    "          "
        Dc.B    "#",4,40
        Dc.B    "DO YOU LIKE JOKES ??? HERE IS COMMING UP AN GOOD ONE "
        DC.B    "THIS IS FOR YOU LITTLE ARROGANT CODERS............"
        Dc.B    "          "
        Dc.B    "*",4,20
        Dc.B    "HOW MANY CODERS DOES IT TAKE TO CHANGE A LIGHT BULB ??? "
        Dc.B    "......................................"
        Dc.B    "          "
        Dc.B    "#",4,10
        Dc.B    "OK, THIS IS THE ANSWER:  IT TAKES TWENTY CODERS !!   "
        Dc.B    "ONE TO DO IT AND NINETEEN JUST HERE TO SAY: OK GUY, YOUR "
        Dc.B    "ARE A GOOD BOY BUT WE CAN DO IT A HELL MUSH BETTER !! "
        Dc.B    "          "
        Dc.B    "#",4,40
        Dc.B    "I HAVE FOUND IT IN AN OLD OLD OLD DEMODISK FROM "
        Dc.B    "UPFRONT CALLED PLASTIC PASSION... AND I THINK IT SHOWS WELL "
        Dc.B    "HOW CODERS WERE ARROGANT AT THIS TIME............    "
        Dc.B    "          "
        Dc.B    "#",2,6
        Dc.B    "SCROLL RESTART.............                        "
        Dc.B    0
        EVEN

SinTab  Incbin  Includes:Table/sin
MulTab  
k       SET     0
MulsTab REPT    200
        Dc      k
k       SET     k+(48*3)
        ENDR

        EVEN

**********************************************************************
**
**
**      Animation du logo
**
**
**********************************************************************

JmpLogo Lea     LogoModulo,a0
        Lea     SinTab(pc),a1
        Move    JmpAng1(pc),d0
        Andi    #511,d0
        Add     d0,d0
        Move    (a1,d0.W),d1
        Bpl.B   SinusPositif
        Neg     d1
SinusPositif
        Lsr     #3,d1
        Subi    #50,d1
        Mulu    #40,d1
        Move    d1,2(a0)        
        Move    d1,6(a0)
        Subq    #4,JmpAng1
        Rts

JmpAng1 Ds      1

**********************************************************************
**
**      RasterBar equalizer
**
**********************************************************************

BarEqualizer
        Move    #148,a1

Equz0   Lea     CopperEquz0,a0
        Move    Equz0Cnt(pc),d0
        Beq.B   Equz1
        Add     d0,d0
        Add     d0,d0
        Lea     6(a0,d0.W),a0
        REPT    16
        Clr     (a0)
        Add.L   a1,a0
        ENDR
        Subq    #1,Equz0Cnt

Equz1   Lea     CopperEquz1,a0
        Move    Equz1Cnt(pc),d0
        Beq.B   Equz2
        Add     d0,d0
        Add     d0,d0
        Lea     6(a0,d0.W),a0
        REPT    16
        Clr     (a0)
        Add.L   a1,a0
        ENDR
        Subq    #1,Equz1Cnt

Equz2   Lea     CopperEquz2,a0
        Move    Equz2Cnt(pc),d0
        Beq.B   Equz3
        Add     d0,d0
        Add     d0,d0
        Lea     6(a0,d0.W),a0
        REPT    16
        Clr     (a0)
        Add.L   a1,a0
        ENDR
        Subq    #1,Equz2Cnt

Equz3   Lea     CopperEquz3,a0
        Move    Equz3Cnt(pc),d0
        Beq.B   EquzTests
        Add     d0,d0
        Add     d0,d0
        Lea     6(a0,d0.W),a0
        REPT    16
        Clr     (a0)
        Add.L   a1,a0
        ENDR
        Subq    #1,Equz3Cnt

EquzTests
        Lea     P61_temp0+P61_Note(pc),a0
        Lea     P61_temp1+P61_Note(pc),a1
        Lea     P61_temp2+P61_Note(pc),a2
        Lea     P61_temp3+P61_Note(pc),a3

        Moveq   #35,d4

TestEquz0
        Tst     (a0)    
        Beq.B   TestEquz1       
        Clr     (a0)
        Move    d4,Equz0Cnt
        Lea     CopperEquz0+4+2,a4
        Move    #$100,d0
        Bsr.B   RefreshEquz

TestEquz1
        Tst     (a1)
        Beq.B   TestEquz2       
        Clr     (a1)
        Move    d4,Equz1Cnt
        Lea     CopperEquz1+4+2,a4
        Move    #$10,d0
        Bsr.B   RefreshEquz

TestEquz2
        Tst     (a2)
        Beq.B   TestEquz3       
        Clr     (a2)
        Move    d4,Equz2Cnt
        Lea     CopperEquz2+4+2,a4
        Move    #$101,d0
        Bsr.B   RefreshEquz

TestEquz3
        Tst     (a3)
        Beq.B   FinEquz 
        Clr     (a3)
        Move    d4,Equz3Cnt
        Lea     CopperEquz3+4+2,a4
        Move    #$111,d0
        Bsr.B   RefreshEquz

FinEquz Rts

RefreshEquz
        Lea     $dff002,a6
        Move    #148,a5
        Move    #(35*64)+1,d1   
        Moveq   #0,d2
        Moveq   #-1,d3
        Moveq   #4-2,d5
        WBlt    a6
        Move.L  #(%0000000100000000!A)<<16,bltcon0-2(a6)
        Move.L  d3,bltafwm-2(a6)
        Move    d5,bltdmod-2(a6)

        REPT    16
        WBlt    a6
        Move.L  a4,bltdpt-2(a6)
        Move    d2,bltadat-2(a6)
        Move    d1,bltsize-2(a6)
        Add     a5,a4
        Add     d0,d2
        ENDR
        Rts
        
Equz0Cnt        Dc      35
Equz1Cnt        Dc      35
Equz2Cnt        Dc      35
Equz3Cnt        Dc      35

Equz0Note       Ds      1
Equz1Note       Ds      1
Equz2Note       Ds      1
Equz3Note       Ds      1

**********************************************************************
**
**      Screen clearing
**
**********************************************************************

Clr     Lea     $dff002,a5
        Move.L  EcranLogique(pc),a0
        Addi.L  #(48*3*22)+4,a0
        Move    #$0100,d2
        Move    #(97*3*64)+20,d3
        Moveq   #0,d4
        WBlt    a5
        Move.L  a0,bltdpt-2(a5)
        Move    d2,bltcon0-2(a5)
        Move    d4,bltcon1-2(a5)
        Move.L  d4,bltafwm-2(a5)
        Move    #8,bltdmod-2(a5)
        Move    d3,bltsize-2(a5)
        Rts

**********************************************************************
**
**      ThePlayer6.1a
**
**********************************************************************

        Include asm:xmfc_demodisk/theplayer.asm

;==================================
;----------------------------------
;
        SECTION ChipDatas,Data_C

CopperList
                CMove   BPLF_COLOR,bplcon0

                CWait   0,1

MontsPTR        CMove   0,$e0   ;1
                CMove   0,$e2
                CMove   0,$e8   ;3
                CMove   0,$ea
                CMove   0,$f0   ;5
                CMove   0,$f2

BobsPTR         CMove   0,$e4   ;2
                CMove   0,$e6
                CMove   0,$ec   ;4
                CMove   0,$ee
                CMove   0,$f4   ;6
                CMove   0,$f6

                CWait   0,2
                CMove   $30,ddfstrt
                CMove   $d0,ddfstop

MontsScroll     CMove   0,bplcon1
                CMove   0,bpl1mod
                CMove   (48*2)+6,bpl2mod

                CWait   0,3
                CMove   $6000+BPLF_COLOR+BPLF_DPF,bplcon0
                
                CWait   0,4
                Incbin  'dat:demodiskltp4/rasterdemo/montains.clist'
                CMove   $568,color+(17*2)
                CMove   $eee,color+(19*2)

                SetCopW 0,44
                IncCWait
                CMove   40-2,bpl1mod

;------------------------------------------
;============ StarField copper ============
;
SprtYpos        SET     60
                SetCopW 0,SprtYpos

StarsField      Rept    126/2
                IncCWait
                CMove   0,color
                CMove   0,color+(9*2)
                SprCtrl 0,0,SprtYpos,1
                CMove   $8000,$144
                CMove   $0000,$146
SprtYpos        SET     SprtYpos+1      
                IncCWait
                CMove   0,color
                CMove   0,color+(9*2)
                SprCtrl 0,0,SprtYpos,1
                CMove   $8000,$144
                CMove   $8000,$146
SprtYpos        SET     SprtYpos+1      
                ENDR

;
; LOGO
;
                SetCopW 0,193

                IncCWait
                CMove   BPLF_COLOR,bplcon0

                IncCWait
LogoPTR         BplPtr  4
                CMove   $38,ddfstrt
                CMove   $d0,ddfstop
                CMove   0,bplcon1
LogoModulo      CMove   0,bpl1mod
                CMove   0,bpl2mod

                IncCWait
                CMove   $4000+BPLF_COLOR,bplcon0
                CMove   0,color
                CMove   0,color+2
                CMove   0,color+4
                CMove   0,color+8
                CMove   0,color+10
                CMove   0,color+12
                CMove   0,color+14
                CMove   0,color+16
                CMove   0,color+18
                CMove   0,color+20
                CMove   0,color+22
                CMove   0,color+24
                CMove   0,color+26
                CMove   0,color+28
                CMove   0,color+30
                CMove   0,color+32
                CMove   0,color+34
                
                IncCWait
                CMove   0,bpl1mod
                CMove   0,bpl2mod

                Incbin  'dat:demodiskltp4/rasterdemo/logo.clist'

                SetCopW 60,215
CopperEquz0     REPT    16
                IncCWait
                REPT    36
                CMove   0,color
                ENDR
                ENDR

                SetCopW 60,238
CopperEquz1     REPT    16
                IncCWait
                REPT    36
                CMove   0,color
                ENDR
                ENDR

                CPal
                SetCopW 60,5
CopperEquz2     REPT    16
                IncCWait
                REPT    36
                CMove   0,color
                ENDR
                ENDR

                SetCopW 60,28
CopperEquz3     REPT    16
                IncCWait
                REPT    36
                CMove   0,color
                ENDR
                ENDR
                CEnd

Monts   Incbin  'montains.raw'
Fonts   Incbin  'fonts.raw'
Logo    Incbin  'logo.raw'
Song    Incbin  'p61.song'

;==================================
;----------------------------------
;
        SECTION Vide,Bss_C
                                
BobsScreen1     Ds.B    48*150*3
BobsScreen2     Ds.B    48*150*3
                EVEN

SampleBuffer    Ds.B    200000
                EVEN
