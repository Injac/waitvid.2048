''
''        Author: Marko Lukat
'' Last modified: 2016/01/22
''       Version: 0.2
''
PUB null
'' This is not a top level object.

PUB init(ID{ignored}, mailbox)

  ifnot result := cognew(@driver, mailbox) +1
    abort

CON
'   cmd[8..0]: cog entry address
'     cmd[12]: command has(1) no(0) arguments
' cmd[15..13]: number of arguments -1

  cmd_clip      = %011_1 << 12|$00A
  cmd_blit      = %101_1 << 12|$017

DAT             org     0                       ' graphics driver

driver          jmpret  $, #setup

{done}          wrlong  zero, par
{idle}          rdlong  code, par wz
                test    code, argn wc           ' check for arguments
        if_z    jmp     #$-2

                mov     addr, code              ' args:n:[!Z]:cmd = 16:4:3:9
                ror     addr, #16               ' extract argument location
        if_c    call    #args                   ' fetch arguments
        if_c    addx    addr, #3                ' advance beyond last argument
                jmp     code                    ' execute function

' #### SET CLIP RECTANGLE
' ------------------------------------------------------
' parameters:   arg0: x1
'               arg1: y1 inclusive
'               arg2: x2
'               arg3: y2 exclusive

setclip         mov     c_x1, arg0              ' copy and sanity check
                mins    c_x1, #0
                maxs    c_x1, #res_x

                mov     c_y1, arg1
                mins    c_y1, #0
                maxs    c_y1, #res_y

                mov     c_x2, arg2
                mins    c_x2, #0
                maxs    c_x2, #res_x

                mov     c_y2, arg3
                mins    c_y2, #0
                maxs    c_y2, #res_y

                jmp     %%0                     ' return

' #### BLIT SPRITE
' ------------------------------------------------------
' parameters:   arg0: dst buffer (word aligned) or NULL
'               arg1: src buffer (word aligned) + header
'               arg2: x
'               arg3: y
'               arg4: frame index
'               arg5: mask or NULL

blit            cmp     arg0, #0 wz
        if_e    rdword  arg0, surface           ' draw surface

' The header is located before the buffer data (negative offsets).
' Fetch everything necessary.

                mov     wb, #15                 ' prepare alignment             (==)

                sub     arg1, #6                ' access to header
                rdword  arg6, arg1              ' frame size in bytes
                add     arg1, #2

                neg     xs, arg2                ' xs := -x                      (%%)
                rdword  ws, arg1                ' logical frame width
                add     arg1, #2

                neg     ys, arg3                ' ys := -y                      (##)
                rdword  hs, arg1                ' logical frame height
                add     arg1, #2

                add     wb, ws                  ' take a copy for final drawing (==)
                andn    wb, #15                 ' align to 16n                  (==)
                shr     wb, #3                  ' byte count (8 px/byte)

{multiply?}     tjz     arg4, #blit_cy

                shl     arg6, #8 -1             ' align operand for 16x8bit

                shr     arg4, #1 wc
        if_c    add     arg4, arg6 wc
                rcr     arg4, #1 wc
        if_c    add     arg4, arg6 wc
                rcr     arg4, #1 wc
        if_c    add     arg4, arg6 wc
                rcr     arg4, #1 wc
        if_c    add     arg4, arg6 wc           ' 16x4bit, precision: 8

                rcr     arg4, #1 wc
        if_c    add     arg4, arg6 wc
                rcr     arg4, #1 wc
        if_c    add     arg4, arg6 wc
                rcr     arg4, #1 wc
        if_c    add     arg4, arg6 wc
                rcr     arg4, #1 wc
        if_c    add     arg4, arg6 wc           ' 16x4bit, precision: 8

                cmp     arg5, #0 wz
        if_ne   add     arg5, arg4              ' |
                add     arg1, arg4              ' apply offset

' Do all the necessary vertical clipping.

blit_cy         add     hs, arg3                ' lower edge
                maxs    hs, c_y2                ' min(lower edge, c_y2)
                mins    arg3, c_y1              ' max(y, c_y1)

                cmps    hs, arg3 wz,wc,wr       ' if lower edge =< y
        if_be   jmp     %%0                     '   early exit

{multiply?}     add     ys, arg3 wz             ' ys == 0|c_y1 - y              (##)
        if_z    jmp     #blit_cx

' An offset into the source buffer needs to be applied. The following
' code performs ys *= wb. The range of ys is configurable during core
' initialisation (4/8/12/16bit).

blit_s          shl     wb, #16{bit} -1         ' align operand for 16xNbit
blit_m          jmpret  $, #$+1 wc,nr           ' clear carry

                rcr     ys, #1 wc
        if_c    add     ys, wb wc
                rcr     ys, #1 wc
        if_c    add     ys, wb wc
                rcr     ys, #1 wc
        if_c    add     ys, wb wc
                rcr     ys, #1 wc
        if_c    add     ys, wb wc               ' 16x4bit, precision: 16

                rcr     ys, #1 wc
        if_c    add     ys, wb wc
                rcr     ys, #1 wc
        if_c    add     ys, wb wc
                rcr     ys, #1 wc
        if_c    add     ys, wb wc
                rcr     ys, #1 wc
        if_c    add     ys, wb wc               ' 16x4bit, precision: 16/12

                rcr     ys, #1 wc
        if_c    add     ys, wb wc
                rcr     ys, #1 wc
        if_c    add     ys, wb wc
                rcr     ys, #1 wc
        if_c    add     ys, wb wc
                rcr     ys, #1 wc
        if_c    add     ys, wb wc               ' 16x4bit, precision: 16/12/8

                rcr     ys, #1 wc
        if_c    add     ys, wb wc
                rcr     ys, #1 wc
        if_c    add     ys, wb wc
                rcr     ys, #1 wc
        if_c    add     ys, wb wc
                rcr     ys, #1 wc
        if_c    add     ys, wb wc               ' 16x4bit, precision: 16/12/8/4

                shr     wb, blit_s              ' restore width

' Do all the necessary horizontal clipping.

blit_cx         add     ws, arg2                ' right edge
                maxs    ws, c_x2                ' min(right edge, c_x2)
                mins    arg2, c_x1              ' max(x, c_x1)

                cmps    ws, arg2 wz,wc,wr       ' if x => right edge
        if_be   jmp     %%0                     '   early exit

                add     xs, arg2                ' xs == 0|c_x1 - x              (%%)

' dst += (y * 128 + x) / 8 (byte address)

                shl     arg3, #4                ' *16
                add     arg0, arg3
                
                ror     arg2, #3                ' /8
                add     arg0, arg2
                
                shr     arg2, #29 wc            ' |                                     rol ???, #3
                muxc    arg2, #%1000            ' bit index in word (0..15)             and ???, #%1111

' src += ys * wb + xs / 8 (byte address)

                ror     xs, #3                  ' /8
                add     arg1, ys{*wb}           ' |
                add     arg1, xs                ' apply to source

                cmp     arg5, #0 wz
        if_ne   add     arg5, ys{*wb}           ' |
        if_ne   add     arg5, xs                ' apply to mask
                muxnz   mskA, wb                ' 0/wb

                shr     xs, #29 wc              ' |                                     rol ???, #3
                muxc    xs, #%1000 wz           ' bit index in word (0..15)     (&&)    and ???, #%1111
                muxz    :jump, #%11             ' select hblit function

' calculate clipping mask update based on length overhead (if zero then carry clear)

                add     ws, xs                  ' avoid calculating (16 - xs)
'       if_nz   cmp     ws, #8*2 +1 wc          ' all columns from same word    (&&)
'       if_nz   muxc    :jump, #%01             ' outa vs outb                  (&&)

                mov     arg3, ws
        if_c    sub     arg3, xs                ' all columns from same word
                and     arg3, #%1111

                neg     clip, #1
                shl     clip, arg3              ' create tail window

                mov     arg3, arg2
        if_a    sub     arg3, xs                '                               (&&)
        if_a    and     arg3, #%1111            '                               (&&)
                shl     clip, arg3              ' now aligned with dst

' arg0: r/u c   dst  byte address (xxword OK)
' arg1: r/u c   src  byte address (xxword OK)
' arg5: r/u c   mask byte address (xxword OK)
' arg2: r/o c   dst bit index
'   xs: r/o     src bit index
'   ws: r/o c   bit width
'   hs: r/u     row count
'   wb: r/o     source width in byte (row advance)
'
' arg3: r/w     temporary
' arg4: r/w     temporary
' arg6: r/w     temporary

:loop           mov     dstT, arg0              ' |
                mov     srcT, arg1              ' |
                mov     mskT, arg5              ' |
                mov     arg4, ws                ' working copy
                mov     arg6, arg2              ' |

:jump           jmpret  link, func              ' hblit

                add     arg0, #128/8            ' |
                add     arg1, wb                ' advance
                add     arg5, mskA              ' |

                djnz    hs, #:loop              ' for all rows

                jmp     %%0                     ' return


fn_11           rdword  dstL, dstT              '  +0 =
fn_11_loop      add     dstT, #2                '  +8
                cmp     arg5, #0 wz             '  -4   check masking mode
                rdword  dstH, dstT              '  +0 =
                shl     dstH, #16               '  +8
                or      dstL, dstH              '  -4   extract 32 dst pixel

        if_nz   rdword  mskW, mskT              '  +0 = extract 16 mask bits
        if_nz   add     mskT, #2                '  +8
        if_z    mov     mskW, mskF              '  -4   full mask

                rdword  srcW, srcT              '  +0 = extract 16 src pixel
                add     srcT, #2                '  +8
                shl     srcW, arg6              '  -4
                shl     mskW, arg6              '  +0 =

                sub     arg4, #16 wz,wc         '  +4   update/check column count
        if_b    andn    mskW, clip              '  +8   apply patch for columns < 16

                and     srcW, mskW              '  +0 = clear transparent pixels
                andn    dstL, mskW              '  +4   make space for src
                or      dstL, srcW              '  +8   combine dst/src

                sub     dstT, #2                '  -4   rewind
                wrword  dstL, dstT              '  +0 = update low word
                shr     dstL, #16               '  +8   dstL := dstH
                add     dstT, #2                '  -4   advance (again)
        if_be   wrword  dstL, dstT              '  +0 = update high word (exit path)
        if_a    jmp     #fn_11_loop             '       for all columns

                jmp     link                    '       return

fn_00
fn_01
                jmp     %%0

' support code (fetch up to 8 arguments)

args            rdlong  arg0, addr              ' read 1st argument
                cmpsub  addr, delta wc          ' [increment address and] check exit
        if_nc   jmpret  zero, args_ret wc,nr    ' cond: early return

                rdlong  arg1, addr              ' read 2nd argument
                cmpsub  addr, delta wc
        if_nc   jmpret  zero, args_ret wc,nr

                rdlong  arg2, addr              ' read 3rd argument
                cmpsub  addr, delta wc
        if_nc   jmpret  zero, args_ret wc,nr

                rdlong  arg3, addr              ' read 4th argument
                cmpsub  addr, delta wc
        if_nc   jmpret  zero, args_ret wc,nr

                rdlong  arg4, addr              ' read 5th argument
                cmpsub  addr, delta wc
        if_nc   jmpret  zero, args_ret wc,nr

                rdlong  arg5, addr              ' read 6th argument
                cmpsub  addr, delta wc
        if_nc   jmpret  zero, args_ret wc,nr

                rdlong  arg6, addr              ' read 7th argument
                cmpsub  addr, delta wc
        if_nc   jmpret  zero, args_ret wc,nr

                rdlong  arg7, addr              ' read 8th argument
'               cmpsub  addr, delta wc
'       if_nc   jmpret  zero, args_ret wc,nr

args_ret        ret

' initialised data and/or presets

surface         long    +4                      ' draw surface location

c_x1            long    0
c_y1            long    0
c_x2            long    res_x
c_y2            long    res_y

delta           long    %001_0 << 28 | $FFFC    ' %10 deal with movi setup
                                                ' -(-4) address increment
argn            long    |< 12                   ' function does have arguments
mskA            long    0                       ' mask pointer advance
mskF            long    $0000FFFF               ' full mask (all bits)

' Stuff below is re-purposed for temporary storage.

setup           add     surface, par            ' draw surface location

                rdlong  arg0, surface
                shr     arg0, #24 -2
                and     arg0, #%1100            ' 0/4/8/12

                add     blit_m, arg0            ' |
                add     blit_m, arg0            ' adjust jump
                sub     blit_s, arg0            ' adjust pre-shift

                movs    func+%00, #fn_00        ' |
                movs    func+%01, #fn_01        ' |
                movs    func+%11, #fn_11        ' hblit function setup

                jmp     %%0                     ' return

EOD{ata}        fit

' uninitialised data and/or temporaries

                org     setup

arg0            res     1                       ' |
arg1            res     1                       ' |
arg2            res     1                       ' |
arg3            res     1                       ' |
arg4            res     1                       ' |
arg5            res     1                       ' |
arg6            res     1                       ' |                
arg7            res     1                       ' command arguments

addr            res     1                       ' parameter pointer   
code            res     1                       ' function entry point
link            res     1                       ' return address

xs              res     1
ys              res     1
ws              res     1
hs              res     1

wb              res     1
clip            res     1

dstT{ransfer}   res     1
srcT{ransfer}   res     1
mskT{ransfer}   res     1

dstH{igh}       res     1
dstL{ow}        res     1
srcW{ord}       res     1
mskW{ord}       res     1

tail            fit
                
CON
  zero          = $1F0                          ' par (dst only)
  func          = $1F4                          ' outa

  res_x         = 128                           ' |
  res_y         = 64                            ' |
  res_m         = 2                             ' UI support
  res_a         = 8                             ' max command arguments

  alias         = 0

DAT