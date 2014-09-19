'''' Font data (one bit/pixel, 8x12) extracted from''''   VGA High-Res Text Driver v1.0''   Author: Chip Gracey''   Copyright (c) 2006 Parallax, Inc.''   See end of file for terms of use.''''        Author: Marko Lukat'' Last modified: 2012/03/17''       Version: 0.1''        Layout: four scan lines per character''CON  height = 12  PUB addr  return @fontDATfont    long    $0C080000, $30100000, $7E3C1800, $18181800, $81423C00, $99423C00, $8181FF00, $E7C3FF00          long    $1E0E0602, $1C000000, $00000000, $00000000, $18181818, $18181818, $00000000, $18181818          long    $00000000, $18181818, $18181818, $18181818, $18181818, $00FFFF00, $CC993366, $66666666          long    $AA55AA55, $0F0F0F0F, $0F0F0F0F, $0F0F0F0F, $0F0F0F0F, $00000000, $00000000, $00000000          long    $00000000, $3C3C1800, $77666600, $7F363600, $667C1818, $46000000, $1B1B0E00, $1C181800          long    $0C183000, $180C0600, $66000000, $18000000, $00000000, $00000000, $00000000, $60400000          long    $73633E00, $1E181000, $66663C00, $60663C00, $3C383000, $06067E00, $060C3800, $63637F00          long    $66663C00, $66663C00, $1C000000, $00000000, $18306000, $00000000, $180C0600, $60663C00          long    $63673E00, $66663C00, $66663F00, $63663C00, $66361F00, $06467F00, $06467F00, $63663C00          long    $63636300, $18183C00, $30307800, $36666700, $06060F00, $7F776300, $67636300, $63361C00          long    $66663F00, $63361C00, $66663F00, $66663C00, $185A7E00, $66666600, $66666600, $63636300          long    $66666600, $66666600, $31637F00, $0C0C3C00, $03010000, $30303C00, $361C0800, $00000000          long    $0C000000, $00000000, $06060700, $00000000, $30303800, $00000000, $0C6C3800, $00000000          long    $06060700, $00181800, $00606000, $06060700, $18181E00, $00000000, $00000000, $00000000          long    $00000000, $00000000, $00000000, $00000000, $0C080000, $00000000, $00000000, $00000000          long    $00000000, $00000000, $00000000, $18187000, $18181800, $18180E00, $73DBCE00, $18180000          long    $F3F7FFFF, $CFEFFFFF, $81C3E7FF, $E7E7E7FF, $7EBDC3FF, $66BDC3FF, $7E7E00FF, $183C00FF          long    $E1F1F9FD, $E3FFFFFF, $FFFFFFFF, $FFFFFFFF, $E7E7E7E7, $E7E7E7E7, $FFFFFFFF, $E7E7E7E7          long    $FFFFFFFF, $E7E7E7E7, $E7E7E7E7, $E7E7E7E7, $E7E7E7E7, $FF0000FF, $3366CC99, $99999999          long    $55AA55AA, $F0F0F0F0, $F0F0F0F0, $F0F0F0F0, $F0F0F0F0, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF          long    $FFFFFFFF, $C3C3E7FF, $889999FF, $80C9C9FF, $9983E7E7, $B9FFFFFF, $E4E4F1FF, $E3E7E7FF          long    $F3E7CFFF, $E7F3F9FF, $99FFFFFF, $E7FFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $9FBFFFFF          long    $8C9CC1FF, $E1E7EFFF, $9999C3FF, $9F99C3FF, $C3C7CFFF, $F9F981FF, $F9F3C7FF, $9C9C80FF          long    $9999C3FF, $9999C3FF, $E3FFFFFF, $FFFFFFFF, $E7CF9FFF, $FFFFFFFF, $E7F3F9FF, $9F99C3FF          long    $9C98C1FF, $9999C3FF, $9999C0FF, $9C99C3FF, $99C9E0FF, $F9B980FF, $F9B980FF, $9C99C3FF          long    $9C9C9CFF, $E7E7C3FF, $CFCF87FF, $C99998FF, $F9F9F0FF, $80889CFF, $989C9CFF, $9CC9E3FF          long    $9999C0FF, $9CC9E3FF, $9999C0FF, $9999C3FF, $E7A581FF, $999999FF, $999999FF, $9C9C9CFF          long    $999999FF, $999999FF, $CE9C80FF, $F3F3C3FF, $FCFEFFFF, $CFCFC3FF, $C9E3F7FF, $FFFFFFFF          long    $F3FFFFFF, $FFFFFFFF, $F9F9F8FF, $FFFFFFFF, $CFCFC7FF, $FFFFFFFF, $F393C7FF, $FFFFFFFF          long    $F9F9F8FF, $FFE7E7FF, $FF9F9FFF, $F9F9F8FF, $E7E7E1FF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF          long    $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $F3F7FFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF          long    $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $E7E78FFF, $E7E7E7FF, $E7E7F1FF, $8C2431FF, $E7E7FFFF          long    $080C7E7E, $10307E7E, $18181818, $7E181818, $81818181, $99BDBDBD, $81818181, $E7BD99BD          long    $1E3E7E3E, $1C3E3E3E, $30F0C000, $0C0F0300, $00C0F030, $00030F0C, $00FFFF00, $18181818          long    $18FFFF00, $00FFFF18, $18F8F818, $181F1F18, $18FFFF18, $00FFFF00, $CC993366, $66666666          long    $AA55AA55, $FFFF0F0F, $F0F00F0F, $0F0F0F0F, $00000F0F, $FFFF0000, $F0F00000, $0F0F0000          long    $00000000, $0018183C, $00000033, $7F363636, $66603C06, $0C183066, $337B5B0E, $0000000C          long    $0C060606, $18303030, $663CFF3C, $18187E18, $00000000, $00007E00, $00000000, $060C1830          long    $676F6B7B, $18181818, $0C183060, $60603860, $307F3336, $60603E06, $66663E06, $0C183060          long    $66763C6E, $60607C66, $1C00001C, $00001C1C, $180C060C, $007E007E, $18306030, $00181830          long    $033B7B7B, $66667E66, $66663E66, $63030303, $66666666, $06263E26, $06263E26, $63730303          long    $63637F63, $18181818, $33333030, $36361E36, $66460606, $63636B7F, $737B7F6F, $63636363          long    $06063E66, $7B636363, $66363E66, $66301C06, $18181818, $66666666, $66666666, $366B6B63          long    $663C183C, $18183C66, $43060C18, $0C0C0C0C, $30180C06, $30303030, $00000063, $00000000          long    $0030381C, $333E301E, $6666663E, $0606663C, $3333333E, $067E663C, $0C0C3E0C, $3333336E          long    $66666E36, $1818181C, $60606070, $361E3666, $18181818, $6B6B6B3F, $6666663E, $6666663C          long    $6666663B, $3333336E, $066E7637, $300C663C, $0C0C0C7E, $33333333, $66666666, $6B6B6363          long    $1C1C3663, $66666666, $0C30627E, $180C060C, $18181818, $18306030, $00000000, $0018187E          long    $F7F38181, $EFCF8181, $E7E7E7E7, $81E7E7E7, $7E7E7E7E, $66424242, $7E7E7E7E, $18426642          long    $E1C181C1, $E3C1C1C1, $CF0F3FFF, $F3F0FCFF, $FF3F0FCF, $FFFCF0F3, $FF0000FF, $E7E7E7E7          long    $E70000FF, $FF0000E7, $E70707E7, $E7E0E0E7, $E70000E7, $FF0000FF, $3366CC99, $99999999          long    $55AA55AA, $0000F0F0, $0F0FF0F0, $F0F0F0F0, $FFFFF0F0, $0000FFFF, $0F0FFFFF, $F0F0FFFF          long    $FFFFFFFF, $FFE7E7C3, $FFFFFFCC, $80C9C9C9, $999FC3F9, $F3E7CF99, $CC84A4F1, $FFFFFFF3          long    $F3F9F9F9, $E7CFCFCF, $99C300C3, $E7E781E7, $FFFFFFFF, $FFFF81FF, $FFFFFFFF, $F9F3E7CF          long    $98909484, $E7E7E7E7, $F3E7CF9F, $9F9FC79F, $CF80CCC9, $9F9FC1F9, $9999C1F9, $F3E7CF9F          long    $9989C391, $9F9F8399, $E3FFFFE3, $FFFFE3E3, $E7F3F9F3, $FF81FF81, $E7CF9FCF, $FFE7E7CF          long    $FCC48484, $99998199, $9999C199, $9CFCFCFC, $99999999, $F9D9C1D9, $F9D9C1D9, $9C8CFCFC          long    $9C9C809C, $E7E7E7E7, $CCCCCFCF, $C9C9E1C9, $99B9F9F9, $9C9C9480, $8C848090, $9C9C9C9C          long    $F9F9C199, $849C9C9C, $99C9C199, $99CFE3F9, $E7E7E7E7, $99999999, $99999999, $C994949C          long    $99C3E7C3, $E7E7C399, $BCF9F3E7, $F3F3F3F3, $CFE7F3F9, $CFCFCFCF, $FFFFFF9C, $FFFFFFFF          long    $FFCFC7E3, $CCC1CFE1, $999999C1, $F9F999C3, $CCCCCCC1, $F98199C3, $F3F3C1F3, $CCCCCC91          long    $999991C9, $E7E7E7E3, $9F9F9F8F, $C9E1C999, $E7E7E7E7, $949494C0, $999999C1, $999999C3          long    $999999C4, $CCCCCC91, $F99189C8, $CFF399C3, $F3F3F381, $CCCCCCCC, $99999999, $94949C9C          long    $E3E3C99C, $99999999, $F3CF9D81, $E7F3F9F3, $E7E7E7E7, $E7CF9FCF, $FFFFFFFF, $FFE7E781          long    $00000000, $00000000, $00001818, $0000183C, $00003C42, $00003C42, $0000FF81, $0000FFC3          long    $0002060E, $00000000, $18181818, $18181818, $00000000, $00000000, $00000000, $18181818          long    $18181818, $00000000, $18181818, $18181818, $18181818, $00FFFF00, $CC993366, $66666666          long    $AA55AA55, $FFFFFFFF, $F0F0F0F0, $0F0F0F0F, $00000000, $FFFFFFFF, $F0F0F0F0, $0F0F0F0F        long    $00000000, $00001818, $00000000, $00003636, $0018183E, $00006266, $00006E3B, $00000000          long    $00003018, $0000060C, $00000000, $00000000, $0C181C1C, $00000000, $00001C1C, $00000103          long    $00003E63, $00007E18, $00007E66, $00003C66, $00007830, $00003C66, $00003C66, $00000C0C          long    $00003C66, $00001C30, $0000001C, $0C181C1C, $00006030, $00000000, $0000060C, $00001818          long    $00003E07, $00006666, $00003F66, $00003C66, $00001F36, $00007F46, $00000F06, $00007C66          long    $00006363, $00003C18, $00001E33, $00006766, $00007F66, $00006363, $00006363, $00001C36          long    $00000F06, $00603C36, $00006766, $00003C66, $00003C18, $00003C66, $0000183C, $00003636          long    $00006666, $00003C18, $00007F63, $00003C0C, $00004060, $00003C30, $00000000, $FFFF0000          long    $00000000, $00006E33, $00003B66, $00003C66, $00006E33, $00003C66, $00001E0C, $1E33303E          long    $00006766, $00007E18, $3C666660, $00006766, $00007E18, $00006B6B, $00006666, $00003C66          long    $0F063E66, $78303E33, $00000F06, $00003C66, $0000386C, $00006E33, $0000183C, $00003636          long    $00006336, $1C30607C, $00007E46, $00007018, $00001818, $00000E18, $00000000, $0000007E          long    $FFFFFFFF, $FFFFFFFF, $FFFFE7E7, $FFFFE7C3, $FFFFC3BD, $FFFFC3BD, $FFFF007E, $FFFF003C          long    $FFFDF9F1, $FFFFFFFF, $E7E7E7E7, $E7E7E7E7, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $E7E7E7E7          long    $E7E7E7E7, $FFFFFFFF, $E7E7E7E7, $E7E7E7E7, $E7E7E7E7, $FF0000FF, $3366CC99, $99999999          long    $55AA55AA, $00000000, $0F0F0F0F, $F0F0F0F0, $FFFFFFFF, $00000000, $0F0F0F0F, $F0F0F0F0          long    $FFFFFFFF, $FFFFE7E7, $FFFFFFFF, $FFFFC9C9, $FFE7E7C1, $FFFF9D99, $FFFF91C4, $FFFFFFFF          long    $FFFFCFE7, $FFFFF9F3, $FFFFFFFF, $FFFFFFFF, $F3E7E3E3, $FFFFFFFF, $FFFFE3E3, $FFFFFEFC          long    $FFFFC19C, $FFFF81E7, $FFFF8199, $FFFFC399, $FFFF87CF, $FFFFC399, $FFFFC399, $FFFFF3F3          long    $FFFFC399, $FFFFE3CF, $FFFFFFE3, $F3E7E3E3, $FFFF9FCF, $FFFFFFFF, $FFFFF9F3, $FFFFE7E7          long    $FFFFC1F8, $FFFF9999, $FFFFC099, $FFFFC399, $FFFFE0C9, $FFFF80B9, $FFFFF0F9, $FFFF8399          long    $FFFF9C9C, $FFFFC3E7, $FFFFE1CC, $FFFF9899, $FFFF8099, $FFFF9C9C, $FFFF9C9C, $FFFFE3C9          long    $FFFFF0F9, $FF9FC3C9, $FFFF9899, $FFFFC399, $FFFFC3E7, $FFFFC399, $FFFFE7C3, $FFFFC9C9          long    $FFFF9999, $FFFFC3E7, $FFFF809C, $FFFFC3F3, $FFFFBF9F, $FFFFC3CF, $FFFFFFFF, $0000FFFF          long    $FFFFFFFF, $FFFF91CC, $FFFFC499, $FFFFC399, $FFFF91CC, $FFFFC399, $FFFFE1F3, $E1CCCFC1          long    $FFFF9899, $FFFF81E7, $C399999F, $FFFF9899, $FFFF81E7, $FFFF9494, $FFFF9999, $FFFFC399          long    $F0F9C199, $87CFC1CC, $FFFFF0F9, $FFFFC399, $FFFFC793, $FFFF91CC, $FFFFE7C3, $FFFFC9C9          long    $FFFF9CC9, $E3CF9F83, $FFFF81B9, $FFFF8FE7, $FFFFE7E7, $FFFFF1E7, $FFFFFFFF, $FFFFFF81  DAT{{ TERMS OF USE: MIT License Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.}}DAT