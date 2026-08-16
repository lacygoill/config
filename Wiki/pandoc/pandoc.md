# Installation

Download the latest `.deb` here:
<https://github.com/jgm/pandoc/blob/master/INSTALL.md>

Install it:

    $ dpkg -i *.deb

Install any missing dependency:

    $ apt install /usr/bin/rsvg-convert

##
# Usage
## markdown → pdf

    $ pandoc input.md \
         -N \
         --pdf-engine=xelatex \
         --variable mainfont="DejaVu Sans Mono" \
         --variable sansfont="DejaVu Sans Mono" \
         --variable monofont="DejaVu Sans Mono" \
         --variable fontsize=12pt \
         --toc \
         -o output.pdf

Source: <http://pandoc.org/demos.html>

In particular, see the example #14.
