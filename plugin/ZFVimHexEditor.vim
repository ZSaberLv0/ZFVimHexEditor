
command! -nargs=0 ZFHexEditor :call ZF_HexEditor()
highlight link ZFHexChar WildMenu

function! ZF_HexEditor()
    let s:running += 1
    try
        noautocmd call s:askSave()
        if !exists('b:ZFHexSaved_filetype')
            noautocmd call s:enable()
        else
            noautocmd call s:disable()
        endif
    endtry
    let s:running -= 1
endfunction

if !exists('*ZF_HexEditorAutoDetect')
    function! ZF_HexEditorAutoDetect(file)
        return ZF_HexEditorAutoDetectDefault(a:file)
    endfunction
endif
function! ZF_HexEditorAutoDetectDefault(file)
    let maxFileSize = get(g:, 'ZFHexEditor_maxFileSize', 5*1024*1024)
    if maxFileSize > 0 && getfsize(a:file) > maxFileSize
        return 0
    endif
    let lines = readfile(a:file, 'b', 1)
    if empty(lines)
        return 0
    endif
    if lines[0] =~ '[\x00-\x08\x10-\x1a\x1c-\x1f]\{5,}'
        return 1
    endif
    return 0
endfunction

let s:running = 0
function! s:autoEnable()
    if s:running > 0
        return
    endif

    let isHexFile = 0

    if !isHexFile
        let extList = get(g:, 'ZFHexEditor_autoEnable', [])
        if !empty(extList)
            let ext = fnamemodify(expand('%'), ':e')
            for t in extList
                if t == ext
                    let isHexFile = 1
                    break
                endif
            endfor
        endif
    endif

    if !isHexFile
        let path = fnamemodify(expand('%'), ':p')
        if filereadable(path)
            let isHexFile = ZF_HexEditorAutoDetect(path)
        endif
    endif

    if isHexFile
        if exists('b:ZFHexSaved_filetype')
            call s:disable()
        endif
        call ZF_HexEditor()
    endif
endfunction
autocmd BufReadPost,FileReadPost * :noautocmd call s:autoEnable()

function! s:enable()
    let b:ZFHexSaved_filetype=&filetype
    let b:ZFHexSaved_binary=&binary
    let b:ZFHexSaved_modifiable=&modifiable
    setlocal binary
    silent edit!
    setlocal modifiable
    silent %!xxd -g 1
    set filetype=xxd
    autocmd BufWriteCmd <buffer> silent call s:save()
    autocmd CursorMoved <buffer> silent call s:redraw()
    call s:resetUndo()
    silent call s:redraw()
endfunction
function! s:disable()
    autocmd! BufWriteCmd <buffer>
    autocmd! CursorMoved <buffer>
    silent edit!
    call s:resetUndo()
    if exists('b:ZFHexChar_hl') && b:ZFHexChar_hl != -1
        call matchdelete(b:ZFHexChar_hl)
        unlet b:ZFHexChar_hl
    endif

    execute 'set filetype=' . b:ZFHexSaved_filetype
    unlet b:ZFHexSaved_filetype

    if !b:ZFHexSaved_binary
        setlocal nobinary
    endif
    unlet b:ZFHexSaved_binary

    if !b:ZFHexSaved_modifiable
        setlocal nomodifiable
    endif
    unlet b:ZFHexSaved_modifiable
endfunction

function! s:askSave()
    if &modified
        echo '[ZFHex] file modified, save first? (y/n) '
        let choice = nr2char(getchar())
        if choice != 'y'
            redraw!
            echo '[ZFHex] canceled'
            return
        endif
        silent w!
        redraw!
    endif
endfunction
function! s:save()
    let s:running += 1
    try
        autocmd! BufWriteCmd <buffer>
        execute 'doautocmd FileWritePre ' . fnamemodify(expand('%'), ':t')
        execute 'doautocmd BufWritePre ' . fnamemodify(expand('%'), ':t')
        %!xxd -r
        w!
        %!xxd -g 1
        set nomodified
        redraw!
        autocmd BufWriteCmd <buffer> silent call s:save()
    endtry
    let s:running -= 1
endfunction
function! s:resetUndo()
    let old_undolevels = &undolevels
    set undolevels=-1
    execute "normal a \<BS>\<Esc>"
    let &undolevels = old_undolevels
    unlet old_undolevels

    set nomodified
endfunction
function! s:redraw()
    if exists('b:ZFHexChar_hl') && b:ZFHexChar_hl != -1
        call matchdelete(b:ZFHexChar_hl)
        unlet b:ZFHexChar_hl
    endif
    if !exists('b:ZFHexSaved_filetype')
        return
    endif
    let c = col('.')
    if c >= 10 && c <= 57
        let b:ZFHexChar_hl = matchadd('ZFHexChar', '\%' . (60+((c-10)/3)) . 'c\%' . line('.') . 'l')
    elseif c >= 60 && c <= 75
        let b:ZFHexChar_hl = matchadd('ZFHexChar', '\%>' . (10+(c-60)*3) . 'c\%<' . (10+(c-60)*3+3) . 'c\%' . line('.') . 'l')
    endif
endfunction

