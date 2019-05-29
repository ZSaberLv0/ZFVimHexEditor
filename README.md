
hex editor mode for vim using `xxd`

![](https://raw.githubusercontent.com/ZSaberLv0/ZFVimHexEditor/master/preview.png)

if you like my work, [check here](https://github.com/ZSaberLv0?utf8=%E2%9C%93&tab=repositories&q=ZFVim) for a list of my vim plugins

# usage

```
" toggle hex editor mode
:ZFHexEditor
```

```
" config file extensions that enter hex editor mode automatically
let g:ZFHexEditor_autoEnable = ['exe', 'dll', 'so']
```

# LIMITATION

* toggle hex editor mode would save the file, and the save action *CAN NOT UNDO*

    * you may use [ZSaberLv0/ZFVimBackup](https://github.com/ZSaberLv0/ZFVimBackup)
        to backup files automatically

* for hex mode, you should only modify texts that are inside the hex range,
    it's your responsibility to ensure the buffer is valid for `xxd` to convert

