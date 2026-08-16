# Purpose: Failing silently.
# Reference: page 198 (paper) / 236 (ebook)

from pathlib import Path
def count_words(path):
    """Count the approximate number of words in a file."""
    try:
        contents = path.read_text(encoding='utf-8')
    except FileNotFoundError:
        # Now when a `FileNotFoundError` is raised, the code in the except block
        # runs, but nothing  happens.  No traceback is produced,  and there's no
        # output in response  to the error that was raised.   Users see the word
        # counts for each  file that exists, but they don't  see any indica tion
        # that a file wasn't found.
        #
        # The `pass` statement also acts as a placeholder.  It's a reminder that
        # you're choosing  to do nothing at  a specific point in  your program's
        # execution and  that you might want  to do something there  later.  For
        # example,  in  this  program  we  might decide  to  write  any  missing
        # filenames to  a file  called `missing_files.txt`.  Our  users wouldn't
        # see this file, but  we’d be able to read the file  and deal with any
        # missing texts.
        pass
    else:
        words = contents.split()
        num_words = len(words)
        print(f'The file {path} has about {num_words} words.')
filenames = ['alice.txt', 'siddhartha.txt', 'moby_dick.txt', 'little_women.txt']
for filename in filenames:
    path = Path(filename)
    count_words(path)

#     The file alice.txt has about 30389 words.
#     The file moby_dick.txt has about 215840 words.
#     The file little_women.txt has about 195624 words.
