
augroup ZFFilePost_augroup
    autocmd!
    autocmd BufReadPost,FileReadPost * :call ZFFilePostAction()
    function! ZFFilePostRegister(moduleName, params)
        if !exists('g:ZFFilePost')
            let g:ZFFilePost = {}
        endif
        let g:ZFFilePost[a:moduleName] = a:params
    endfunction
    function! ZFFilePostAction()
        let file = expand('<afile>')
        if !filereadable(file) || empty(get(g:, 'ZFFilePost', {}))
                    \ || get(b:, 'ZFFilePostDisable', 0)
                    \ || get(b:, 'ZFFilePostProcessing', 0)
            return
        endif
        let b:ZFFilePostFile = file
        let b:ZFFilePostProcessing = 1
        let priorityHighest = -1
        let itemHighest = {}
        for item in values(g:ZFFilePost)
            let priority = item['checker'](file)
            if priority > priorityHighest
                let priorityHighest = priority
                let itemHighest = item
            endif
        endfor
        if !empty(itemHighest)
            if exists('b:ZFFilePostRunning')
                if !empty(get(b:ZFFilePostRunning, 'cleanup', ''))
                    call b:ZFFilePostRunning['cleanup'](file)
                endif
            endif
            let b:ZFFilePostRunning = itemHighest
            call itemHighest['action'](file)
        endif
        unlet b:ZFFilePostProcessing
    endfunction
    function! ZFFilePostDisable()
        let b:ZFFilePostDisable = 1
        call ZFFilePostCleanup()
    endfunction
    function! ZFFilePostCleanup()
        if !exists('b:ZFFilePostFile')
            return
        endif
        if exists('b:ZFFilePostRunning')
            unlet b:ZFFilePostRunning
        endif
        for item in values(g:ZFFilePost)
            if !empty(get(item, 'cleanup', ''))
                call item['cleanup'](b:ZFFilePostFile)
            endif
        endfor
    endfunction
augroup END

function! s:autoEnable_checker(file)
    if g:ZFHexEditorProcessing > 0
        return -1
    endif

    let isHexFile = 0

    if !isHexFile
        let extList = get(g:, 'ZFHexEditor_autoEnable', [])
        if !empty(extList)
            let ext = fnamemodify(a:file, ':e')
            for t in extList
                if t == ext
                    let isHexFile = 1
                    break
                endif
            endfor
        endif
    endif

    if !isHexFile
        let isHexFile = ZF_HexEditorAutoDetect(a:file)
    endif

    return isHexFile ? 1 : -1
endfunction
function! s:autoEnable_action(file)
    if g:ZFHexEditorProcessing > 0
        return
    endif
    if exists('b:ZFHexSaved_filetype')
        call ZFHexEditorOff()
    endif
    call ZFHexEditorOn()
endfunction
function! s:autoEnable_cleanup(file)
    if g:ZFHexEditorProcessing > 0
        return
    endif
    if exists('b:ZFHexSaved_filetype')
        call ZFHexEditorOff()
    endif
endfunction
call ZFFilePostRegister('ZFHexEditor', {
            \   'checker' : function('s:autoEnable_checker'),
            \   'action' : function('s:autoEnable_action'),
            \   'cleanup' : function('s:autoEnable_cleanup'),
            \ })

