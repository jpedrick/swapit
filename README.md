swapit
==========================

Switch current vim buffer between header and source files

To map "Swapit()" to F4 key:
nnoremap <F4> :call Swapit()<CR>

Define possible file extensions headers swap to source, source swap to headers:
let g:swapit_header_extensions = 'hpp:h'
let g:swapit_source_extensions = 'cpp:cxx:C:c:cc'

Define timeout. If search operation takes too long, error out and return vim control back to user.
let g:swapit_timeout = 5

Define log level [off, error, warn, info, debug]. Each level includes more detailed info of plugin progress:
let g:swapit_log_level = 'error' 

I recommend 'error' for normal every day use.




