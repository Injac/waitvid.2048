''
'' VGA display 128xP (quad cog) - demo
''
''        Author: Marko Lukat
'' Last modified: 2016/08/20
''       Version: 0.3
''
CON
  _clkmode = client#_clkmode
  _xinfreq = client#_xinfreq

OBJ
  client: "core.con.client.demoboard"
     vga: "waitvid.128xP.ui"
  
VAR
  word  palette[vga#bcnt_raw / 2]                       ' 2n aligned
  
PUB selftest : c | cursor

  vga.init

  vga.str(string(vga#ESC, "s"))                         ' page mode

  repeat vga#bcnt                                       ' fill screen
    vga.putc(c++)

  waitcnt(clkfreq*3 + cnt)

' Driver starts up in (simple) monochrome mode (no colour buffer).
' Changing colour or switching into monochrome mode requires bit 31
' to be set (colour value is cleaned up, sync bits & Co).

  vga.setn(2, NEGX|%%3000_0000)
  waitcnt(clkfreq + cnt)
  vga.setn(2, NEGX|%%0300_0000)
  waitcnt(clkfreq + cnt)
  vga.setn(2, NEGX|%%0030_0000)
  waitcnt(clkfreq + cnt)
  vga.setn(2, NEGX|%%0220_0010)
  waitcnt(clkfreq + cnt)

' Switch to colour per position mode.

  vga.setn(2, @palette{0})
  waitcnt(clkfreq + cnt)

  fill(vga.str(string(vga#ESC, "c", %%3000, %%0003)))
  fill(vga.str(string(vga#ESC, "c", %%0300, %%0003)))
  fill(vga.str(string(vga#ESC, "c", %%0030, %%0003)))

' Direct access to colour buffer.

  prng(@palette{0})

' Change background palette.

  c := constant(%%0000_0010_1110_3330 | %%3{!Z})
  repeat 4
    c <-= 8
    vga.setn(4, c)
    waitcnt(clkfreq + cnt)

' String output using ESC sequences.

  vga.str(string(vga#ESC, "c", %%0003, %%0003, vga#FF))
  vga.str(string(vga#ESC, "=", vga#columns -23, vga#rows -2))

  vga.str(string(vga#ESC, "c", %%3003, %%0003, "multi "))
  vga.str(string(vga#ESC, "c", %%0303, %%0003, "coloured "))
  vga.str(string(vga#ESC, "c", %%0033, %%0003, "message"))
  waitcnt(clkfreq*2 + cnt)

' ... back to monochrome mode

  vga.setn(2, NEGX|%%2220_0000)

  vga.str(string(vga#ESC, "=", vga#columns -23, vga#rows -2))
  vga.str(string("    monochrome"))

  waitcnt(clkfreq*2 + cnt)

  vga.setn(2, NEGX|%%0220_0010)

  waitcnt(clkfreq*2 + cnt)

' UI owns the primary cursor (crs0), show it.
'
' When talking directly to the driver (no UI) both cursors are available
' and can be registered like shown for crs1 below (see also DDK demo).

  vga.str(string(vga#ESC, "O"))                         ' cursor on

' setup and register secondary cursor (crs1)

  cursor.byte{0} := %0011                               ' mode (block|flashing|on)
  cursor.byte[1] := vga#columns -20
  cursor.byte[2] := vga#rows -2

  vga.setn(6, @cursor)                                  ' register (see vga.setn() for command)
  
  waitcnt(clkfreq*4 + cnt)

  vga.str(string(vga#ESC, "o"))                         ' cursor off
  vga.setn(6, 0)                                        ' deregister crs1 (or set its mode to %---0)
  
PRI fill(char)

  vga.str(string(vga#ESC, "=", vga#columns, vga#rows))  ' HOME
  repeat vga#bcnt
    vga.putc(char++)
    waitcnt(clkfreq/800 + cnt)

PRI prng(base) : ID

  if (ID := cognew(@entry, @base)) > -1
    waitcnt(clkfreq*5 + cnt)
    cogstop(ID)
    waitcnt(clkfreq + cnt)
  
DAT             org     0                       ' direct palette access

entry           or      lfsr, cnt
                
:load           mov     ecnt, bcnt
                rdlong  addr, par               ' @palette{0}

:loop           shl     lfsr, #1 wc             ' |
        if_c    xor     lfsr, mxor              ' iterate LFSR

                wrbyte  lfsr, addr              ' upset palette entry and
                add     addr, #1                ' advance address
                
                djnz    ecnt, #:loop            ' whole screen
                jmp     #:load                  ' repeat

' initialised data and/or presets

bcnt            long    vga#bcnt

mxor            long    $1D872B41
lfsr            long    1

' uninitialised data and/or temporaries

addr            res     1
ecnt            res     1

                fit
                
DAT