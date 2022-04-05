if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

" ============================================================
" 0000abcd
syn region zfxxdAddr start="\%1v" end="\%9v"

" 0000abcd:
syn region zfxxdAddrColumn start="\%9v" end="\%10v"

" 0000abcd: 11 22 33 44
syn region zfxxdHex start="\%10v" end="\%58v"

" 0000abcd: 11 22 .. ee ff  abcdefg
syn region zfxxdText start="\%60v" end="\%76v"

" ============================================================
hi def link zfxxdAddr Tag
hi def link zfxxdAddrColumn Comment
hi def link zfxxdHex Normal
hi def link zfxxdText Constant

let b:current_syntax = "xxd"

