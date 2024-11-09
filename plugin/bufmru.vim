" Reload and Compatibility Guard {{{1
" ============================================================================
" Reload protection.
if (exists('g:did_bufmru') && g:did_bufmru) || &cp || version < 700
    finish
endif
let g:did_bufmru = 1

" avoid line continuation issues (see ':help user_41.txt')
let s:save_cpo = &cpo
set cpo&vim
" 1}}}


call bufmru#init()

command! -nargs=0 BufMRU :call bufmru#show()

