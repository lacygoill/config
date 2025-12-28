# ?

- <https://castel.dev/post/lecture-notes-1/>
- <https://castel.dev/post/lecture-notes-2/>
- <https://castel.dev/post/lecture-notes-3/>

[texlive-en.pdf](~/texlive/2018/texmf-dist/doc/texlive/texlive-en/texlive-en.pdf)

- <https://github.com/lervag/vimtex/issues>
- <https://github.com/honza/vim-snippets/blob/master/UltiSnips/tex.snippets>
- <https://github.com/honza/vim-snippets/blob/master/UltiSnips/texmath.snippets>

- <http://dante.ctan.org/tex-archive/info/luatex/lualatex-doc/lualatex-doc.pdf> (short guide to luatex)

- <http://cremeronline.com/LaTeX/minimaltikz.pdf> (Minimal introduction to TikZ)

- <http://detexify.kirelabs.org/classify.html> (draw a symbol in the browser and get the corresponding macro)
- <http://www.texample.net/tikz/examples/> (examples of graphs)
- <https://www.latextemplates.com/> (examples of templates)

- <https://www.overleaf.com/blog/571-an-introduction-to-luatex-part-1-what-is-it-and-what-makes-it-so-different#.WrF8AHXwYrg>

---

Interesting LaTeX package:
- <https://ctan.org/pkg/pythontex> Run Python from within a document, typesetting the results

---

Document these commands:

    x_|c    compile selection
    n_|c    single shot compilation
    n_|C    continuous compilation

    n_|ec   edit latexmkrc

    n_|n    clean some auxiliary files
    n_|N    clean all auxiliary files

    n_|s    stop continuous compilation of current file
    n_|S    stop continuous compilation of all files

    n_|v    view compiled file
    n_|V    view compiled selection


Also, document the  fact that when you  compile a visual selection,  it must NOT
include the preamble.   Otherwise, you won't get the expected  result.  It seems
vimtex adds the preamble at the beginning of the file automatically.

Also,  according  to  `:help VimtexCompileSelected`,  you  could  add  a  custom
operator to compile a text-object:

    When  used  as  a normal  mode  mapping,  the  mapping  will act  as  an
    |operator| on the following motion or text object.  Finally, when used as
    a visual mode mapping, it will act on the selected lines.

Try something like this:

    nmap  |?  <plug>(vimtex-compile-selected)
           ^
           replace with whatever key you want
