# **Swap***it*
==========================

Switch current vim buffer between header and source files.

### Installation
Add the following line to your Vundle config in **~/.vimrc**:
```vim
Plugin 'jpedrick/swapit'
```

### Usage

To map "Swapit()" to F4 key:
```vim
nnoremap <F4> :call Swapit()<CR>
```

Define possible file extensions headers swap to source, source swap to headers:
```vim
let g:swapit_header_extensions = 'hpp:h'
let g:swapit_source_extensions = 'cpp:cxx:C:c:cc'
```

setting hidden mode is recommended:
```vim
set hidden
```

Define timeout. If search operation takes too long, error out and return vim control back to user.
```vim
let g:swapit_timeout = 5
```

Define log level *[off, error, warn, info, debug]*. Each level includes more detailed info of plugin progress:(*error* for normal every day use.)
```vim
let g:swapit_log_level = 'error'
```


