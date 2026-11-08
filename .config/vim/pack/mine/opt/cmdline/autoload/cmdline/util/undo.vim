vim9script

export def EmitAddToUndolistC() #{{{1
    # We want to be able to undo the transformation.
    # We emit  a custom event, so  that we can  add the current line  to our
    # undo list in `vim-readline`.
    if exists('#User#AddToUndolistC')
        doautocmd <nomodeline> User AddToUndolistC
    endif
enddef
