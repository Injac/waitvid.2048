''
'' VGA display 80xM (single cog) - video driver and pixel generator
''
''        Author: Marko Lukat
'' Last modified: 2013/11/25
''       Version: 0.2
''
'' long[par][0]:  screen:   [!Z]:addr =  16:16 -> zero (accepted), 2n
'' long[par][1]:    font: size:*:addr = 8:8:16 -> zero (accepted), 2n
'' long[par][2]: palette:  [!Z]:fg:bg = 16:8:8 -> zero (accepted), optional colour
'' long[par][3]: frame indicator
''
'' 20131123: initial version (640x480@60Hz timing, %11 sync locked)
'' 20131125: updated comments
''
OBJ
  system: "core.con.system"

PUB null
'' This is not a top level object.
  
PUB init(ID, mailbox)

  return system.launch(ID, @driver, mailbox)
  
DAT             org     0                       ' cog binary header

header_2048     long    system#ID_2             ' magic number for a cog binary
                word    header_size             ' header size
                word    system#MAPPING          ' flags
                word    0, 0                    ' start register, register count

                word    @__table - @header_2048 ' translation table byte offset

header_size     fit     16
                
DAT             org     0                       ' video driver

driver          jmpret  $, #setup               '  -4   once

                mov     dira, mask              ' drive outputs

' horizontal timing 640(640)  1(16) 6(96)  3(48)
'   vertical timing 480(480) 10(10) 2(2)  33(33)

' Check for updates and apply them (if available).

update          rdlong  temp, scrn_ wz          ' |
        if_nz   mov     scrn, temp              ' |
        if_nz   wrlong  zero, scrn_             ' update and acknowledge screen buffer setup

                rdbyte  temp, font_ wz          ' |
        if_nz   mov     scnt, temp              ' |
        if_nz   min     scnt, #8                ' extract font height
        if_nz   rdlong  font, font_             ' |
        if_nz   shr     font, #1{/2}            ' added twice during emitter run
        if_nz   wrlong  zero, font_             ' update and acknowledge font definition setup

                rdlong  temp, plte_ wz          ' |
        if_nz   mov     plte, temp              ' |
        if_nz   wrlong  zero, plte_             ' update and acknowledge font colour setup

' Vertical sync chain.

{vsync}         mov     ecnt, #10
                call    #blank                  ' front porch
                djnz    ecnt, #$-1

                xor     sync, #$0101            ' active
                                                '                       mov     ecnt, #2  
                call    #blank                  ' |                     call    #blank    
                call    #blank                  ' vertical sync         djnz    ecnt, #$-1

                xor     sync, #$0101            ' inactive

                mov     eins, scrn              ' screen base address
                mov     drei, #res_y            ' max visible scanlines

                mov     zwei, #33               ' zwei controls fetch (8..1)
                call    #blank                  ' back porch
                call    #fetch                  ' grab characters for first line
                djnz    zwei, #$-2

' Vertical sync chain done, do visible area.

:line           mov     frqb, font              ' font base address /2
                mov     zwei, scnt              ' font size
                max     zwei, drei              ' limit against what's left
                sub     drei, zwei              ' update what's left

:scan           waitcnt cnt, #0                 ' re-sync after back porch              (##)

                mov     outa, idle              ' take over sync lines
                mov     vcfg, vcfg_norm         ' disconnect from video h/w             (&&)

                call    #emit                   ' |
                call    #hsync                  ' display scanline
                call    #fetch                  ' grab characters for next line
                
                add     frqb, #256/2            ' next row in character definition(s)
                djnz    zwei, #:scan            ' repeat for font size
                tjnz    drei, #:line            ' repeat for all rows

                wrlong  cnt, fcnt_              ' announce vertical blank
                
                jmp     #update                 ' next frame


blank           mov     vscl, line              ' 256/640
                waitvid sync, #%000             ' latch blank line

                call    #head                   ' update emitter

hsync           mov     vscl, wrap              ' horizontal sync
                waitvid sync, wrap_value

                mov     vcfg, vcfg_sync         ' drive sync lines                      (&&)
                mov     outa, #0                ' stop interfering

                mov     cnt, cnt                ' record sync point                     (##)
                add     cnt, #9{14}+376           
hsync_ret
blank_ret       ret


emit            mov     vscl, hvis              ' 1/32

' The worst case timing for a 4 character block comes down to
' 4 + 23 + 16 * 3 + 12 + 7 which fits nicely in the 101 cycle
' window required for 32 pixels.

                mov     phsb, #3-3              '  -4
                rdbyte  temp, phsb              '  +0 =
                shl     temp, #8                '  +8   0000DD00
                mov     phsb, #2-2              '  -4
                rdbyte  vier, phsb              '  +0 =
                or      temp, vier              '  -4   0000DDCC
                mov     phsb, #1-1              '  -4
                rdbyte  vier, phsb              '  +0 =
                shl     temp, #8                '  +8   00DDCC00
                mov     phsb, #0-0              '  -4
                rdbyte  acht, phsb              '  +0 =
                or      temp, vier              '  +8   00DDCCBB
                shl     temp, #8                '  -4   DDCCBB00
                or      temp, acht              '  +0 = DDCCBBAA
                waitvid plte, temp              '                       0

                mov     phsb, #3-3              '  -4
                rdbyte  temp, phsb              '  +0 =
                shl     temp, #8                '  +8   0000DD00
                mov     phsb, #2-2              '  -4
                rdbyte  vier, phsb              '  +0 =
                or      temp, vier              '  -4   0000DDCC
                mov     phsb, #1-1              '  -4
                rdbyte  vier, phsb              '  +0 =
                shl     temp, #8                '  +8   00DDCC00
                mov     phsb, #0-0              '  -4
                rdbyte  acht, phsb              '  +0 =
                or      temp, vier              '  +8   00DDCCBB
                shl     temp, #8                '  -4   DDCCBB00
                or      temp, acht              '  +0 = DDCCBBAA
                waitvid plte, temp              '                       4

                mov     phsb, #3-3              '  -4
                rdbyte  temp, phsb              '  +0 =
                shl     temp, #8                '  +8   0000DD00
                mov     phsb, #2-2              '  -4
                rdbyte  vier, phsb              '  +0 =
                or      temp, vier              '  -4   0000DDCC
                mov     phsb, #1-1              '  -4
                rdbyte  vier, phsb              '  +0 =
                shl     temp, #8                '  +8   00DDCC00
                mov     phsb, #0-0              '  -4
                rdbyte  acht, phsb              '  +0 =
                or      temp, vier              '  +8   00DDCCBB
                shl     temp, #8                '  -4   DDCCBB00
                or      temp, acht              '  +0 = DDCCBBAA
                waitvid plte, temp              '                       8

                mov     phsb, #3-3              '  -4
                rdbyte  temp, phsb              '  +0 =
                shl     temp, #8                '  +8   0000DD00
                mov     phsb, #2-2              '  -4
                rdbyte  vier, phsb              '  +0 =
                or      temp, vier              '  -4   0000DDCC
                mov     phsb, #1-1              '  -4
                rdbyte  vier, phsb              '  +0 =
                shl     temp, #8                '  +8   00DDCC00
                mov     phsb, #0-0              '  -4
                rdbyte  acht, phsb              '  +0 =
                or      temp, vier              '  +8   00DDCCBB
                shl     temp, #8                '  -4   DDCCBB00
                or      temp, acht              '  +0 = DDCCBBAA
                waitvid plte, temp              '                       12

                mov     phsb, #3-3              '  -4
                rdbyte  temp, phsb              '  +0 =
                shl     temp, #8                '  +8   0000DD00
                mov     phsb, #2-2              '  -4
                rdbyte  vier, phsb              '  +0 =
                or      temp, vier              '  -4   0000DDCC
                mov     phsb, #1-1              '  -4
                rdbyte  vier, phsb              '  +0 =
                shl     temp, #8                '  +8   00DDCC00
                mov     phsb, #0-0              '  -4
                rdbyte  acht, phsb              '  +0 =
                or      temp, vier              '  +8   00DDCCBB
                shl     temp, #8                '  -4   DDCCBB00
                or      temp, acht              '  +0 = DDCCBBAA
                waitvid plte, temp              '                       16

                mov     phsb, #3-3              '  -4
                rdbyte  temp, phsb              '  +0 =
                shl     temp, #8                '  +8   0000DD00
                mov     phsb, #2-2              '  -4
                rdbyte  vier, phsb              '  +0 =
                or      temp, vier              '  -4   0000DDCC
                mov     phsb, #1-1              '  -4
                rdbyte  vier, phsb              '  +0 =
                shl     temp, #8                '  +8   00DDCC00
                mov     phsb, #0-0              '  -4
                rdbyte  acht, phsb              '  +0 =
                or      temp, vier              '  +8   00DDCCBB
                shl     temp, #8                '  -4   DDCCBB00
                or      temp, acht              '  +0 = DDCCBBAA
                waitvid plte, temp              '                       20

                mov     phsb, #3-3              '  -4
                rdbyte  temp, phsb              '  +0 =
                shl     temp, #8                '  +8   0000DD00
                mov     phsb, #2-2              '  -4
                rdbyte  vier, phsb              '  +0 =
                or      temp, vier              '  -4   0000DDCC
                mov     phsb, #1-1              '  -4
                rdbyte  vier, phsb              '  +0 =
                shl     temp, #8                '  +8   00DDCC00
                mov     phsb, #0-0              '  -4
                rdbyte  acht, phsb              '  +0 =
                or      temp, vier              '  +8   00DDCCBB
                shl     temp, #8                '  -4   DDCCBB00
                or      temp, acht              '  +0 = DDCCBBAA
                waitvid plte, temp              '                       24

                mov     phsb, #3-3              '  -4
                rdbyte  temp, phsb              '  +0 =
                shl     temp, #8                '  +8   0000DD00
                mov     phsb, #2-2              '  -4
                rdbyte  vier, phsb              '  +0 =
                or      temp, vier              '  -4   0000DDCC
                mov     phsb, #1-1              '  -4
                rdbyte  vier, phsb              '  +0 =
                shl     temp, #8                '  +8   00DDCC00
                mov     phsb, #0-0              '  -4
                rdbyte  acht, phsb              '  +0 =
                or      temp, vier              '  +8   00DDCCBB
                shl     temp, #8                '  -4   DDCCBB00
                or      temp, acht              '  +0 = DDCCBBAA
                waitvid plte, temp              '                       28

                mov     phsb, #3-3              '  -4
                rdbyte  temp, phsb              '  +0 =
                shl     temp, #8                '  +8   0000DD00
                mov     phsb, #2-2              '  -4
                rdbyte  vier, phsb              '  +0 =
                or      temp, vier              '  -4   0000DDCC
                mov     phsb, #1-1              '  -4
                rdbyte  vier, phsb              '  +0 =
                shl     temp, #8                '  +8   00DDCC00
                mov     phsb, #0-0              '  -4
                rdbyte  acht, phsb              '  +0 =
                or      temp, vier              '  +8   00DDCCBB
                shl     temp, #8                '  -4   DDCCBB00
                or      temp, acht              '  +0 = DDCCBBAA
                waitvid plte, temp              '                       32

                mov     phsb, #3-3              '  -4
                rdbyte  temp, phsb              '  +0 =
                shl     temp, #8                '  +8   0000DD00
                mov     phsb, #2-2              '  -4
                rdbyte  vier, phsb              '  +0 =
                or      temp, vier              '  -4   0000DDCC
                mov     phsb, #1-1              '  -4
                rdbyte  vier, phsb              '  +0 =
                shl     temp, #8                '  +8   00DDCC00
                mov     phsb, #0-0              '  -4
                rdbyte  acht, phsb              '  +0 =
                or      temp, vier              '  +8   00DDCCBB
                shl     temp, #8                '  -4   DDCCBB00
                or      temp, acht              '  +0 = DDCCBBAA
                waitvid plte, temp              '                       36

                mov     phsb, #3-3              '  -4
                rdbyte  temp, phsb              '  +0 =
                shl     temp, #8                '  +8   0000DD00
                mov     phsb, #2-2              '  -4
                rdbyte  vier, phsb              '  +0 =
                or      temp, vier              '  -4   0000DDCC
                mov     phsb, #1-1              '  -4
                rdbyte  vier, phsb              '  +0 =
                shl     temp, #8                '  +8   00DDCC00
                mov     phsb, #0-0              '  -4
                rdbyte  acht, phsb              '  +0 =
                or      temp, vier              '  +8   00DDCCBB
                shl     temp, #8                '  -4   DDCCBB00
                or      temp, acht              '  +0 = DDCCBBAA
                waitvid plte, temp              '                       40

                mov     phsb, #3-3              '  -4
                rdbyte  temp, phsb              '  +0 =
                shl     temp, #8                '  +8   0000DD00
                mov     phsb, #2-2              '  -4
                rdbyte  vier, phsb              '  +0 =
                or      temp, vier              '  -4   0000DDCC
                mov     phsb, #1-1              '  -4
                rdbyte  vier, phsb              '  +0 =
                shl     temp, #8                '  +8   00DDCC00
                mov     phsb, #0-0              '  -4
                rdbyte  acht, phsb              '  +0 =
                or      temp, vier              '  +8   00DDCCBB
                shl     temp, #8                '  -4   DDCCBB00
                or      temp, acht              '  +0 = DDCCBBAA
                waitvid plte, temp              '                       44

                mov     phsb, #3-3              '  -4
                rdbyte  temp, phsb              '  +0 =
                shl     temp, #8                '  +8   0000DD00
                mov     phsb, #2-2              '  -4
                rdbyte  vier, phsb              '  +0 =
                or      temp, vier              '  -4   0000DDCC
                mov     phsb, #1-1              '  -4
                rdbyte  vier, phsb              '  +0 =
                shl     temp, #8                '  +8   00DDCC00
                mov     phsb, #0-0              '  -4
                rdbyte  acht, phsb              '  +0 =
                or      temp, vier              '  +8   00DDCCBB
                shl     temp, #8                '  -4   DDCCBB00
                or      temp, acht              '  +0 = DDCCBBAA
                waitvid plte, temp              '                       48

                mov     phsb, #3-3              '  -4
                rdbyte  temp, phsb              '  +0 =
                shl     temp, #8                '  +8   0000DD00
                mov     phsb, #2-2              '  -4
                rdbyte  vier, phsb              '  +0 =
                or      temp, vier              '  -4   0000DDCC
                mov     phsb, #1-1              '  -4
                rdbyte  vier, phsb              '  +0 =
                shl     temp, #8                '  +8   00DDCC00
                mov     phsb, #0-0              '  -4
                rdbyte  acht, phsb              '  +0 =
                or      temp, vier              '  +8   00DDCCBB
                shl     temp, #8                '  -4   DDCCBB00
                or      temp, acht              '  +0 = DDCCBBAA
                waitvid plte, temp              '                       52

                mov     phsb, #3-3              '  -4
                rdbyte  temp, phsb              '  +0 =
                shl     temp, #8                '  +8   0000DD00
                mov     phsb, #2-2              '  -4
                rdbyte  vier, phsb              '  +0 =
                or      temp, vier              '  -4   0000DDCC
                mov     phsb, #1-1              '  -4
                rdbyte  vier, phsb              '  +0 =
                shl     temp, #8                '  +8   00DDCC00
                mov     phsb, #0-0              '  -4
                rdbyte  acht, phsb              '  +0 =
                or      temp, vier              '  +8   00DDCCBB
                shl     temp, #8                '  -4   DDCCBB00
                or      temp, acht              '  +0 = DDCCBBAA
                waitvid plte, temp              '                       56

                mov     phsb, #3-3              '  -4
                rdbyte  temp, phsb              '  +0 =
                shl     temp, #8                '  +8   0000DD00
                mov     phsb, #2-2              '  -4
                rdbyte  vier, phsb              '  +0 =
                or      temp, vier              '  -4   0000DDCC
                mov     phsb, #1-1              '  -4
                rdbyte  vier, phsb              '  +0 =
                shl     temp, #8                '  +8   00DDCC00
                mov     phsb, #0-0              '  -4
                rdbyte  acht, phsb              '  +0 =
                or      temp, vier              '  +8   00DDCCBB
                shl     temp, #8                '  -4   DDCCBB00
                or      temp, acht              '  +0 = DDCCBBAA
                waitvid plte, temp              '                       60

                mov     phsb, #3-3              '  -4
                rdbyte  temp, phsb              '  +0 =
                shl     temp, #8                '  +8   0000DD00
                mov     phsb, #2-2              '  -4
                rdbyte  vier, phsb              '  +0 =
                or      temp, vier              '  -4   0000DDCC
                mov     phsb, #1-1              '  -4
                rdbyte  vier, phsb              '  +0 =
                shl     temp, #8                '  +8   00DDCC00
                mov     phsb, #0-0              '  -4
                rdbyte  acht, phsb              '  +0 =
                or      temp, vier              '  +8   00DDCCBB
                shl     temp, #8                '  -4   DDCCBB00
                or      temp, acht              '  +0 = DDCCBBAA
                waitvid plte, temp              '                       64

                mov     phsb, #3-3              '  -4
                rdbyte  temp, phsb              '  +0 =
                shl     temp, #8                '  +8   0000DD00
                mov     phsb, #2-2              '  -4
                rdbyte  vier, phsb              '  +0 =
                or      temp, vier              '  -4   0000DDCC
                mov     phsb, #1-1              '  -4
                rdbyte  vier, phsb              '  +0 =
                shl     temp, #8                '  +8   00DDCC00
                mov     phsb, #0-0              '  -4
                rdbyte  acht, phsb              '  +0 =
                or      temp, vier              '  +8   00DDCCBB
                shl     temp, #8                '  -4   DDCCBB00
                or      temp, acht              '  +0 = DDCCBBAA
                waitvid plte, temp              '                       68

                mov     phsb, #3-3              '  -4
                rdbyte  temp, phsb              '  +0 =
                shl     temp, #8                '  +8   0000DD00
                mov     phsb, #2-2              '  -4
                rdbyte  vier, phsb              '  +0 =
                or      temp, vier              '  -4   0000DDCC
                mov     phsb, #1-1              '  -4
                rdbyte  vier, phsb              '  +0 =
                shl     temp, #8                '  +8   00DDCC00
                mov     phsb, #0-0              '  -4
                rdbyte  acht, phsb              '  +0 =
                or      temp, vier              '  +8   00DDCCBB
                shl     temp, #8                '  -4   DDCCBB00
                or      temp, acht              '  +0 = DDCCBBAA
                waitvid plte, temp              '                       72

                mov     phsb, #3-3              '  -4
                rdbyte  temp, phsb              '  +0 =
                shl     temp, #8                '  +8   0000DD00
                mov     phsb, #2-2              '  -4
                rdbyte  vier, phsb              '  +0 =
                or      temp, vier              '  -4   0000DDCC
                mov     phsb, #1-1              '  -4
                rdbyte  vier, phsb              '  +0 =
                shl     temp, #8                '  +8   00DDCC00
                mov     phsb, #0-0              '  -4
                rdbyte  acht, phsb              '  +0 =
                or      temp, vier              '  +8   00DDCCBB
                shl     temp, #8                '  -4   DDCCBB00
                or      temp, acht              '  +0 = DDCCBBAA
                waitvid plte, temp              '                       76

' Update the first 12 characters in here due to timing constraints.

head            cmp     zwei, #1 wz             ' last character scanline?
        if_ne   jmp     head_ret

                movs    emit+ 10, #0-0
                movs    emit+  7, #0-0
                movs    emit+  4, #0-0
                movs    emit+  1, #0-0          ' 0

                movs    emit+ 25, #0-0
                movs    emit+ 22, #0-0
                movs    emit+ 19, #0-0
                movs    emit+ 16, #0-0          ' 4

                movs    emit+ 40, #0-0
                movs    emit+ 37, #0-0
                movs    emit+ 34, #0-0
                movs    emit+ 31, #0-0          ' 8
head_ret
emit_ret        ret


fetch           cmp     drei, #0 wz             ' enabled?
        if_e    jmp     fetch_ret

                cmp     zwei, #1 wz             ' critical
        if_e    jmp     #xfer                   ' transfer remaining character data

                cmp     zwei, #8 wc,wz          '  > 8  nothing to do
        if_a    jmp     fetch_ret

        if_e    movd    :one, #head+3           ' == 8
        if_e    movd    :two, #head+2           ' == 8

                cmp     zwei, #7 wz             ' bridge gap between head and xfer

        if_e    movd    :one, #xfer+1           ' == 7
        if_e    movd    :two, #xfer+0           ' == 7

                mov     ecnt, #6                ' 12 characters each
                
:loop           rdword  temp, eins              '  +0 = $0000BBAA
                add     eins, #2                '  +8   advance screen address

                ror     temp, #8                '  -4   $AA0000BB
:one            movs    head+3, temp            '  +0 =
                add     $-1, dst2               '  +4

                shr     temp, #24               '  +8   $000000AA
:two            movs    head+2, temp            '  -4
                add     $-1, dst2               '  +0 =

                cmp     :two, stop wz           '  +4   early abort for line 2
        if_ne   djnz    ecnt, #:loop            '  +8

                jmp     fetch_ret

stop            movs    xfer+ 68, temp

xfer            movs    emit+ 55, #0-0
                movs    emit+ 52, #0-0
                movs    emit+ 49, #0-0
                movs    emit+ 46, #0-0          ' 12

                movs    emit+ 70, #0-0
                movs    emit+ 67, #0-0
                movs    emit+ 64, #0-0
                movs    emit+ 61, #0-0          ' 16

                movs    emit+ 85, #0-0
                movs    emit+ 82, #0-0
                movs    emit+ 79, #0-0
                movs    emit+ 76, #0-0          ' 20

                movs    emit+100, #0-0
                movs    emit+ 97, #0-0
                movs    emit+ 94, #0-0
                movs    emit+ 91, #0-0          ' 24

                movs    emit+115, #0-0
                movs    emit+112, #0-0
                movs    emit+109, #0-0
                movs    emit+106, #0-0          ' 28

                movs    emit+130, #0-0
                movs    emit+127, #0-0
                movs    emit+124, #0-0
                movs    emit+121, #0-0          ' 32

                movs    emit+145, #0-0
                movs    emit+142, #0-0
                movs    emit+139, #0-0
                movs    emit+136, #0-0          ' 36

                movs    emit+160, #0-0
                movs    emit+157, #0-0
                movs    emit+154, #0-0
                movs    emit+151, #0-0          ' 40

                movs    emit+175, #0-0
                movs    emit+172, #0-0
                movs    emit+169, #0-0
                movs    emit+166, #0-0          ' 44

                movs    emit+190, #0-0
                movs    emit+187, #0-0
                movs    emit+184, #0-0
                movs    emit+181, #0-0          ' 48

                movs    emit+205, #0-0
                movs    emit+202, #0-0
                movs    emit+199, #0-0
                movs    emit+196, #0-0          ' 52

                movs    emit+220, #0-0
                movs    emit+217, #0-0
                movs    emit+214, #0-0
                movs    emit+211, #0-0          ' 56

                movs    emit+235, #0-0
                movs    emit+232, #0-0
                movs    emit+229, #0-0
                movs    emit+226, #0-0          ' 60

                movs    emit+250, #0-0
                movs    emit+247, #0-0
                movs    emit+244, #0-0
                movs    emit+241, #0-0          ' 64

                movs    emit+265, #0-0
                movs    emit+262, #0-0
                movs    emit+259, #0-0
                movs    emit+256, #0-0          ' 68

                movs    emit+280, #0-0
                movs    emit+277, #0-0
                movs    emit+274, #0-0
                movs    emit+271, #0-0          ' 72

                movs    emit+295, #0-0
                movs    emit+292, #0-0
                movs    emit+289, #0-0
                movs    emit+286, #0-0          ' 76

fetch_ret       ret

' initialised data and/or presets

idle            long    hv_idle
sync            long    hv_idle ^ $0200

frqx            long    $1423D70A               ' 25.175MHz
                        
wrap_value      long    %0001111110             ' horizontal sync pulse (1/6/3 reverse)
wrap            long    16 << 12 | 160          '  16/160
hvis            long     1 << 12 | 32           '   1/32
line            long     0 << 12 | 640          ' 256/640

vcfg_norm       long    %0_01_0_00_000 << 23 | vgrp << 9 | vpin
vcfg_sync       long    %0_01_0_00_000 << 23 | sgrp << 9 | %11

mask            long    vpin << (vgrp * 8) | %11 << (sgrp * 8)

scrn_           long    +0                      ' |
font_           long    +7                      ' |
plte_           long    +8                      ' |
fcnt_           long    12                      ' mailbox addresses (local copy)

zwei            long    0                       ' no fetch/update during startup

plte            long    dcolour                 ' colour
dst2            long    2 << 9                  ' dst +/-= 2
                
' Stuff below is re-purposed for temporary storage.

setup           add     scrn_, par              ' @long[par][0]
                add     font_, par              ' @long[par][1]
                add     plte_, par              ' @long[par][2]
                add     fcnt_, par              ' @long[par][3]

' Upset video h/w and relatives.

                movi    ctrb, #%0_11111_000     ' LOGIC always (loader support)
                movi    ctra, #%0_00001_101     ' PLL, VCO/4
                mov     frqa, frqx              ' 25.175MHz
                
                mov     vscl, hvis              ' 1/32
                mov     vcfg, vcfg_sync         ' VGA, 2 colour mode

                jmp     %%0                     ' return

                fit
                
' uninitialised data and/or temporaries

                org     setup

ecnt            res     1                       ' element count
scrn            res     1                       ' screen buffer
font            res     1                       ' font definition
scnt            res     1                       ' scanlines (per char)
temp            res     1

eins            res     1
drei            res     1
vier            res     1
acht            res     1

tail            fit
                
DAT                                             ' translation table

__table         word    (@__names - @__table)/2

                word    res_x
                word    res_y
                word    res_m
                
__names         byte    "res_x", 0
                byte    "res_y", 0
                byte    "res_m", 0

CON
  zero    = $1F0                                ' par (dst only)
  vpin    = $0FC                                ' pin group mask
  vgrp    = 2                                   ' pin group
  sgrp    = 2                                   ' pin group sync
  hv_idle = $01010101 * %11 {%hv}               ' h/v sync inactive
  dcolour = %%0220_0010                         ' default colour
  
  res_x   = 640                                 ' |
  res_y   = 480                                 ' |
  res_m   = 4                                   ' UI support

  alias   = 0
  
DAT