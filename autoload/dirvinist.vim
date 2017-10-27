if exists("g:autoloaded_dirvinist")
  finish
endif
let g:autoloaded_dirvinist = 1

if !exists("g:dirvinist_show_headers")
    let g:dirvinist_show_headers = 1
endif

function! dirvinist#category_complete(lead, cmdline, _) abort
    let categories = keys(projectionist#navigation_commands())
    return filter(categories, 'v:val =~ "^".a:lead')
endfunction

function! s:glob_files(category) abort
    let commands = projectionist#navigation_commands()
    if !has_key(commands, a:category)
        return
    endif
    let variants = commands[a:category]
    let formats = []
    for variant in variants
        call add(formats, variant[0] . projectionist#slash() . (variant[1] =~# '\*\*'
            \ ? variant[1] : substitute(variant[1], '\*', '**/*', '')))
    endfor
    let files = []
    for format in formats
        let files += split(glob(format), '\n')
    endfor
    return files
endfunction

function! s:set_buffer_settings() abort
    setlocal concealcursor=nvc
    setlocal conceallevel=3
    setlocal undolevels=-1
    setlocal ft=dirvish
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    silent keepmarks keepjumps %delete _
    syntax match dirvinist "#.*$"
    hi def link dirvinist Todo
endfunction

function! dirvinist#get_files(...) abort
    if empty(a:000)
        let categories = keys(projectionist#navigation_commands())
    else
        let categories = a:000
    endif
    let lines = []
    for category in categories
        let files = s:glob_files(category)
        if !empty(files)
            if g:dirvinist_show_headers
                call add(lines, "# " . category)
            endif
            let lines += files
        endif
    endfor
    let prev_folder = resolve(expand('%:p'))
    if empty(lines)
        echo "No files found."
        return
    endif
    enew
    call s:set_buffer_settings()
    call setline(1, lines)
    setlocal undolevels<
    call ProjectionistDetect(prev_folder)
endfunction
