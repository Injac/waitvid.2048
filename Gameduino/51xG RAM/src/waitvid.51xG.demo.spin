''
'' VGA display 51xG (dual cog) - demo
''
''        Author: Marko Lukat
'' Last modified: 2012/09/17
''       Version: 0.2
''
CON
  _clkmode = client#_clkmode
  _xinfreq = client#_xinfreq

CON
  columns  = driver#res_x / 8
  rows     = driver#res_y / font#height
  bcnt     = columns * rows

  rows_raw = (driver#res_y + font#height - 1) / font#height
  bcnt_raw = columns * rows_raw

OBJ
  client: "core.con.client.demoboard"
  driver: "waitvid.51xG.driver.2048"
    font: "fourCol8x8-1font"
  
VAR
  long  link[driver#res_m], scroll, palette[256]
  word  scrn[bcnt_raw / 2]
  
PUB selftest : n

  longfill(@palette{0}, %%0000_0000_0220_0010, 256)     ' default colours
  wordfill(@scrn{0}, $2020, bcnt_raw/2)                 ' clear screen
  
  link{0} := @scrn.byte[bcnt_raw - columns]
  link[1] := font#height << 24 | font.addr
  link[2] := @palette{0}

  driver.init(-1, @link{0})                             ' start driver

  repeat bcnt
    scrn.byte[bcnt_raw - ++n] := n

  print(         0,       0, 10)
  print(columns -1,       0, 11)
  print(columns -1, rows -1, 13)
  print(         0, rows -1, 12)

  repeat n from 1 to columns -2
    print(n,       0, 14)
    print(n, rows -1, 14)
    
  repeat n from 1 to rows -2
    print(         0, n, 15)
    print(columns -1, n, 15)

  waitcnt(clkfreq*3 + cnt)
  
  repeat                                                ' animate screen
    move(512, +1, +1, TRUE)
    move(512, +1, -1, FALSE)
    move(512, -1, -1, TRUE)
    move(512, -1, +1, FALSE)

PRI move(scnt, dx, dy, change)

  repeat scnt
    link[2] := @palette{0}
    repeat
    while link[2]
    scroll.word[0] += dx                                ' palette.word[-2]
    scroll.word[1] += dy                                ' palette.word[-1]
    if change
      palette[?frqa & $FF] := cnt

PRI print(x, y, c)

  scrn.byte[bcnt_raw - y * columns - ++x] := c

DAT