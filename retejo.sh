#!/bin/sh
#@(#) a simple static website generator, written in plain POSIX shell
#@(#) probably needs some love to add some functions and such, but generally
#@(#) relatively simple and easy to use.
#@(#) [EO] simpla statika retejo generato, skribita en simpla POSIX-sxelo.
#@(#) probable bezonas amon por aldoni funkciojn, sed gxenerale simpla kaj
#@(#) facile uzebla

set -euf
# probably could set a `-o pipefail` as well, but thats
# bash-only

arg=$1
base=' '
target=' '
type=md

# grab a base and a target here; we could also note if
# we even *have* a target or if we also want to generate
# a directory listing...

if [ -d "$arg" ]
then
    base=$arg
    if [ -f "$base/index.txt" ]
    then
        target="$base/index.txt"
    elif [ -f "$base/README.md" ]
    then
        target="$base/README.md"
    elif [ -f "$base/README.adoc" ]
    then
        target="$base/README.adoc"
        type=adoc
    fi
elif [ -f "$arg" ]
then
    target=$arg
    base=`dirname $arg`
    if [ "${target#*.}" = "adoc" ]; then
        type=adoc
    fi
fi

# generate the header
cat header.html

# generate the side bar
echo '  <div id="side-bar">'
echo '    <div>'
echo '      <ul>'

for i in `find . -type d -depth 1`
do
    i=`echo $i | sed -e 's/\.\///'`
    if [ "$i" = ".git" ]; then
        continue
    elif [ "$i" = "$base" ]; then

        # TODO (lojikil) currently only matches on depth
        # we need to check prefixes...

        echo '    <li> <a href="/'$i'">&rsaquo; ' $i '</a></li>'
        echo '    <li>'
        echo '      <ul>'
        for d in `find $i -type d -depth 1`
        do
            d=`echo $d | sed -e 's/\.\///'`
            echo '         <li><a href="/'$d'">&rsaquo;' $d '</a></li>'
        done
        echo '      </ul>'
        echo '    </li>'
    else
        echo '    <li> <a href="/'$i'">&rsaquo;' $i '</a></li>'
    fi
done

echo '      </ul>'
echo '    </div>'
echo '  </div>'
echo 
echo
echo '  <div id="main-copy">'

if [ -f "$target" ]
then
    if [ "$type" = "adoc" ]
    then
        asciidoctor -b docbook $target -o - | pandoc -f docbook -t html
    else
        pandoc -f markdown -t html $target
    fi
else
    # should probably support doing this regardless, so that you
    # can have an index.txt as well as a directory content dump
    # additionally, can be used for Gopher/Gemini as well...
    # lastly, should support symlinking index.txt to README.md
    echo '<h1>Directory Contents</h1>'
    echo '<ul>'
    for g in `find $base -depth 1`
    do
        echo '<li><a href="/'$g'">'$g'</a></li>'
    done
    echo '</ul>'
fi

echo '  </div>'

cat footer.html
