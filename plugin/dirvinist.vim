command! -bar -bang -nargs=* -complete=customlist,dirvinist#category_complete Dirvinist call dirvinist#get_files(<f-args>)
