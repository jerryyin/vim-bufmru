" autoload/bufmru.vim

function! bufmru#sort(b1, b2)
  let t1 = str2float(reltimestr(BufMRUTime(a:b1)))
  let t2 = str2float(reltimestr(BufMRUTime(a:b2)))
  return t1 == t2 ? 0 : t1 > t2 ? -1 : 1
endfunction

function! bufmru#enter()
  call bufmru#save("enter()")
endfunction

function! bufmru#save(reason)
  let i = bufnr("%")
  if buflisted(i)
    let s:bufmru_files[i] = reltime()  " Update with the current time when buffer is entered
    " Trigger UI update only if needed
    silent doautocmd User BufMRUChange
    if get(g:, 'airline#extensions#tabline#enabled', 0)
      call airline#extensions#tabline#buflist#invalidate()
    endif
    if !empty(get(g:, 'lightline', {}))
      call lightline#update()
    endif
    if bufnr("$") > 1
      let stl = &showtabline
      set showtabline=0
      let &showtabline = stl
    endif
  endif
endfunction

function! BufMRUTime(bufn)
  return get(s:bufmru_files, a:bufn, s:bufmru_starttime)
endfunction

function! BufMRUList()
  let bufs = filter(range(1, bufnr("$")), 'buflisted(v:val)')
  call sort(bufs, "bufmru#sort")
  return bufs
endfunction

function! bufmru#show()
  let bufs = BufMRUList()
  for buf in bufs
    let bufn = bufname(buf)
    let buft = reltimestr(BufMRUTime(buf))
    echom buf . " | " . buft . "s | " . bufn
  endfor
endfunction

function! bufmru#go(inc)
  let list = BufMRUList()
  let idx = index(list, bufnr("%"))
  let i = list[(idx + a:inc) % len(list)]
  execute "buffer" i
endfunction

function! bufmru#init()
  let s:bufmru_files = {}
  let s:bufmru_starttime = reltime()
  call bufmru#autocmd()
endfunction

function! bufmru#autocmd()
  augroup bufmru_buffers
    autocmd!
    autocmd BufEnter * call bufmru#enter()
  augroup END
endfunction

" Set the default number of buffers to keep open
if !exists("g:bufmru_nb_to_keep")
  let g:bufmru_nb_to_keep = 25
endif

" Function to limit open buffers to the specified maximum
function! BufMRUAutoClose()
  " Get a list of all listed buffers and their usage info
  let buffers = filter(range(1, bufnr('$')), 'buflisted(v:val)')

  " Only proceed if the buffer count exceeds the max allowed
  if len(buffers) > g:bufmru_nb_to_keep
    " Sort buffers by last used time in ascending order
    call sort(buffers, {a, b -> getbufinfo(a)->lastused - getbufinfo(b)->lastused})

    " Close the oldest buffers to maintain the max allowed
    for i in range(0, len(buffers) - g:bufmru_nb_to_keep - 1)
      execute 'bdelete' buffers[i]
    endfor
  endif
endfunction

" Autocommand to trigger BufMRUAutoClose every time a new buffer is entered
augroup BufMRUAutoCloseGroup
  autocmd!
  autocmd BufEnter * call BufMRUAutoClose()
augroup END

