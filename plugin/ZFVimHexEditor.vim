
command! -nargs=0 ZFHexEditor :call ZFHexEditor()
highlight default link ZFHexChar WildMenu

if !exists('*ZF_HexEditorAutoDetect')
    function! ZF_HexEditorAutoDetect(file)
        return ZF_HexEditorAutoDetectDefault(a:file)
    endfunction
endif

if !exists('g:ZFHexEditor_ignoreFt')
    let g:ZFHexEditor_ignoreFt = [
                \   '7z',
                \   'bz2',
                \   'gz',
                \   'lz',
                \   'lzma',
                \   'rar',
                \   'tar',
                \   'xz',
                \   'z',
                \   'zip',
                \ ]
endif

function! ZF_HexEditorAutoDetectDefault(file)
    let maxFileSize = get(g:, 'ZFHexEditor_maxFileSize', 10*1024*1024)
    if getfsize(a:file) > maxFileSize
        return 0
    endif

    if index(g:ZFHexEditor_ignoreFt, tolower(fnamemodify(a:file, ':e'))) >= 0
        return 0
    endif

    let lines = readfile(a:file, 'b', 3)
    if !empty(lines)
        for line in lines
            if line =~ '[\x00-\x08\x10-\x1a\x1c-\x1f]\{5,}'
                return 1
            endif
        endfor
    endif
    return 0
endfunction

if !exists('g:ZFHexEditorProcessing')
    let g:ZFHexEditorProcessing = 0
endif
function! ZFHexEditor()
    let g:ZFHexEditorProcessing += 1
    try
        noautocmd let continue = s:askSave()
        if continue
            if !exists('b:ZFHexSaved_filetype')
                noautocmd call s:enable()
            else
                noautocmd call s:disable()
            endif
        endif
    endtry
    let g:ZFHexEditorProcessing -= 1
endfunction
function! ZFHexEditorOn()
    let g:ZFHexEditorProcessing += 1
    try
        if !exists('b:ZFHexSaved_filetype')
            noautocmd let continue = s:askSave()
            if continue
                noautocmd call s:enable()
            endif
        endif
    endtry
    let g:ZFHexEditorProcessing -= 1
endfunction
function! ZFHexEditorOff()
    let g:ZFHexEditorProcessing += 1
    try
        noautocmd let continue = s:askSave()
        if continue
            if exists('b:ZFHexSaved_filetype')
                noautocmd call s:disable()
            endif
        endif
    endtry
    let g:ZFHexEditorProcessing -= 1
endfunction

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
            redraw
            echo '[ZFHex] canceled'
            return 0
        endif
        silent w!
        redraw!
    endif
    return 1
endfunction
function! s:save()
    let g:ZFHexEditorProcessing += 1
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
    let g:ZFHexEditorProcessing -= 1
endfunction
function! s:resetUndo()
    let modifiableSaved = &modifiable

    let old_undolevels = &undolevels
    set undolevels=-1
    set modifiable
    execute "normal a \<BS>\<Esc>"
    let &modifiable = modifiableSaved
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

