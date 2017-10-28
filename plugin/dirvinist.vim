command! -bar -bang -nargs=* -complete=customlist,dirvinist#type_complete Dirvinist call dirvinist#get_files(<f-args>)
