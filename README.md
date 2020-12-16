
hex editor mode for vim using `xxd`

![](https://raw.githubusercontent.com/ZSaberLv0/ZFVimHexEditor/master/preview.png)

if you like my work, [check here](https://github.com/ZSaberLv0?utf8=%E2%9C%93&tab=repositories&q=ZFVim) for a list of my vim plugins,
or [buy me a coffee](https://github.com/ZSaberLv0/ZSaberLv0)

# usage

```
" toggle hex editor mode
:ZFHexEditor
```

```
" config file extensions that enter hex editor mode automatically
let g:ZFHexEditor_autoEnable = ['exe', 'dll', 'so']

" or, supply a custom function to detect binary file,
" we have a builtin detect function by default,
" you may disable it by define your own
function! ZF_HexEditorAutoDetect(file)
    if YourChecker(a:file)
        return 1
    else
        " you may fallback to default checker
        return ZF_HexEditorAutoDetectDefault(a:file)
    endif
endfunction

" for the builtin detect function,
" you may setup the max file size to detect,
" or set to -1 to disable auto detect
let g:ZFHexEditor_maxFileSize = 10*1024*1024
```

# LIMITATION

* toggle hex editor mode would save the file, and the save action *CAN NOT UNDO*

    * you may use [ZSaberLv0/ZFVimBackup](https://github.com/ZSaberLv0/ZFVimBackup)
        to backup files automatically

* for hex mode, you should only modify texts that are inside the hex range,
    it's your responsibility to ensure the buffer is valid for `xxd` to convert

# FAQ

* Q: `xxd` called every time when exit and re-entering hex buffer

    A: you should check `:h bufhidden` and `:h hidden` is setup properly,
    the recommended setting is `set hidden | setlocal bufhidden=`

    note, some plugin may `set bufhidden=unload` when opening large file

