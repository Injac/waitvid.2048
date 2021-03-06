''
'' VGA display 40x15 (single cog, ROM font, palette) - demo
''
''        Author: Marko Lukat
'' Last modified: 2014/03/01
''       Version: 0.2.pal.10
''
'' 20131019: characters 0..31 can be customised
'' 20131025: allow for startup vgrp/vpin configuration
'' 20131027: moved video setup to top level
'' 20140301: improved plot method
''
CON
  _clkmode = client#_clkmode
  _xinfreq = client#_xinfreq

OBJ
  client: "core.con.client.demoboard"
     vga: "waitvid.40x15.plte.ui"

VAR
  long  font[32*32/2]
  
PUB selftest : c

  vga.init(constant(2 << 9 | %%333_0))

  vga.str(string(vga#ESC, "s"))                         ' page mode

  repeat vga#bcnt                                       ' fill screen
    vga.putc(c++)

  waitcnt(clkfreq*3 + cnt)

  vga.setn(1, @pal1)                                    ' override default

  fill(vga.str(string(vga#ESC, "c", %1100_1100)), FALSE)
  fill(vga.str(string(vga#ESC, "c", %1010_1010)), FALSE)
  fill(vga.str(string(vga#ESC, "c", %1001_1001)), FALSE)

' Change palette.

  vga.setn(1, @pal0)                                    ' switch to palette 0

  fill(0, TRUE)

  waitcnt(clkfreq*3 + cnt)

  repeat 32
    c := pal0[31]                                       ' |
    bytemove(@pal0[17], @pal0[16], 15)                  ' |
    pal0[16] := c                                       ' rotate palette 0 (16..31)
    
    repeat 15
      vga.setn(1, @pal0)                                ' update palette

' String output using ESC sequences.

  vga.setn(1, @pal1)                                    ' switch to palette 1

  vga.str(string(vga#ESC, "c", %1000_1000, vga#FF))
  vga.str(string(vga#ESC, "=", vga#columns -23, vga#rows -2))

  vga.str(string(vga#ESC, "c", %1100_1100, "multi "))
  vga.str(string(vga#ESC, "c", %1010_1010, "coloured "))
  vga.str(string(vga#ESC, "c", %1001_1001, "message"))

' Custom character demonstration.

  c := vga.str(string(vga#ESC, "c", %1111_1000, vga#ESC, "=", (vga#columns -32)/2, 1))
  repeat 32
    vga.putc(c++)

  c := vga.str(string(vga#ESC, "=", (vga#columns -32)/2, 2))
  repeat 32
    vga.putc(c)

  vga.str(string(vga#ESC, "=", (vga#columns -32)/2,   3, "characters 0..31 in first line", 13))
  vga.str(string(vga#ESC, "=", (vga#columns -32)/2, 255, "32x character 0 in second line", 13))

  waitcnt(clkfreq*2 + cnt)

  vga.str(string(vga#ESC, "=", (vga#columns -32)/2, 255, "changing base address ...", 13))

  c := constant(NEGX|$8000)                             ' default to ROM font
  repeat 512
    c.word{0} += 128                                    ' next character
    repeat 1
      vga.setn(1, c)                                    ' update address

  waitcnt(clkfreq*2 + cnt)

  vga.str(string(vga#ESC, "=", (vga#columns -32)/2, 255, "changing characters 0/1 ...", 13))

  longmove(@font{0}, c, constant(32*32/2))              ' copy first 32 ROM characters

  repeat 592
    vga.setn(1, NEGX|@font{0})                          ' swap to r/w copy

    c := font{0}                                        ' |
    longmove(@font{0}, @font[1], 31)                    ' |
    font[31] := c                                       ' rotate character 0 definition

  waitcnt(clkfreq*2 + cnt)

  vga.str(string(vga#ESC, "=", (vga#columns -32)/2, 255, "back to ROM font ...", 13))

  vga.setn(1, constant(NEGX|$8000))                     ' back to ROM font

  waitcnt(clkfreq*2 + cnt)

  vga.str(string(vga#ESC, "=", (vga#columns -32)/2, 255, "simple graphics ...", 13))
  
  char(4, 1, " ", 32, 0)
  char(4, 2, " ", 32, 0)

  vga.setn(1, NEGX|@font{0})                            ' swap to r/w copy

  char(27,  8,  0, 8, 1)
  char(27,  9,  8, 8, 1)
  char(27, 10, 16, 8, 1)
  char(27, 11, 24, 8, 1)                                ' build screen

  waitcnt(clkfreq*2 + cnt)

  repeat
    repeat 128*128
      plot(?frqa, frqb?)                                ' random pixels
    repeat 128*128
      plot(vscl, vscl >> 7)                             ' sweep
      vscl++
  
PRI char(x, y, c, ccnt, delta)

  vga.str(string(vga#ESC, "="))
  vga.out(x)
  vga.out(y)
  repeat ccnt
    vga.putc(c)
    c += delta

PRI plot(x, y)

  font[(x & $60) + (y & $60) << 2 + (y & $1F)] ^= bits[x & $1F]
  
DAT

bits    long    |< 0, |< 2, |< 4, |< 6, |< 8, |< 10, |< 12, |< 14, |< 16, |< 18, |< 20, |< 22, |< 24, |< 26, |< 28, |< 30
        long    |< 1, |< 3, |< 5, |< 7, |< 9, |< 11, |< 13, |< 15, |< 17, |< 19, |< 21, |< 23, |< 25, |< 27, |< 29, |< 31
                
PRI fill(c, mode{boolean})

  vga.str(string(vga#ESC, "=", vga#columns, vga#rows))  ' HOME
  repeat vga#bcnt
    if mode
      vga.str(string(vga#ESC, "c"))
      vga.out(c)
    vga.putc(c++)
    waitcnt(clkfreq/200 + cnt)

DAT

pal0    byte    %%0000, %%0010, %%0100, %%0110
        byte    %%1000, %%1010, %%1100, %%1110
        byte    %%0000, %%0030, %%0300, %%0330
        byte    %%3000, %%3030, %%3300, %%3330
                                              
        byte    %%0000, %%0010, %%0100, %%0110
        byte    %%1000, %%1010, %%1100, %%1110
        byte    %%0000, %%0030, %%0300, %%0330
        byte    %%3000, %%3030, %%3300, %%3330

DAT

pal1    byte    %%0220[8]
        byte    %%0000, %%0030, %%0300, %%0330
        byte    %%3000, %%3030, %%3300, %%3330

        byte    %%0010[8]
        byte    %%0000[8]

DAT