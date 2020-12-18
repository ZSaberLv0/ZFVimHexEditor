
augroup ZFFilePost_augroup
    autocmd!
    autocmd BufReadPost,FileReadPost * :noautocmd call ZFFilePostAction()
    function! ZFFilePostRegister(moduleName, checker, action)
        if !exists('g:ZFFilePost')
            let g:ZFFilePost = {}
        endif
        let g:ZFFilePost[a:moduleName] = {
                    \   'checker' : a:checker,
                    \   'action' : a:action,
                    \ }
    endfunction
    function! ZFFilePostAction()
        let file = expand('<afile>')
        if !filereadable(file) || empty(get(g:, 'ZFFilePost', {}))
            return
        endif
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
            call itemHighest['action'](file)
        endif
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
    call ZFHexEditor()
endfunction
call ZFFilePostRegister('ZFHexEditor', function('s:autoEnable_checker'), function('s:autoEnable_action'))

