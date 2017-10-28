if exists("g:autoloaded_dirvinist")
  finish
endif
let g:autoloaded_dirvinist = 1

if !exists("g:dirvinist_show_headers")
    let g:dirvinist_show_headers = 1
endif

function! s:list_types() abort
    return ["alternate"] + keys(projectionist#navigation_commands())
endfunction

function! s:glob_files(type) abort
    let commands = projectionist#navigation_commands()
    if !has_key(commands, a:type)
        return
    endif
    let variants = commands[a:type]
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

function! dirvinist#type_complete(lead, cmdline, _) abort
    let types = s:list_types()
    return filter(types, 'v:val =~ "^".a:lead')
endfunction

function! dirvinist#get_files(...) abort
    if empty(a:000)
        let types = s:list_types()
    else
        let types = a:000
    endif
    let lines = []
    for type in types
        if type == "alternate"
            let alternates = projectionist#query_file('alternate')
            if !empty(alternates)
                call add(lines, "# " . type)
                let lines += alternates
            endif
        else
            let files = s:glob_files(type)
            if !empty(files)
                if g:dirvinist_show_headers
                    call add(lines, "# " . type)
                endif
                let lines += files
            endif
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
