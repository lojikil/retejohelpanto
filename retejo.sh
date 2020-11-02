set -e
base=$1

# generate the header

cat header.html

# generate the side bar
echo '  <div id="side-bar">'
echo '    <div>'

for i in `find . -type d -depth 1`
do
    if [ "$i" = "./.git" ]; then
        continue
    elif [ "$i" = "$base" ]; then

        # TODO (lojikil) currently only matches on depth
        # we need to check prefixes...

        echo '    <li> <a href="'$i'">&rsaquo; ' $i '</a></li>'
        echo '    <li>'
        echo '      <ul>'
        for d in `find $i -type d -depth 1`
        do
            echo '         <li><a href="'$d'">&rsaquo;' $d '</a></li>'
        done
        echo '      </ul>'
        echo '    </li>'
    else
        echo '    <li> <a href="'$i'">&rsaquo;' $i '</a></li>'
    fi
done

echo '    </div>'
echo '  </div>'
echo 
echo
echo '  <div id="main-copy">'

pandoc -f markdown -t html $base/index.txt

echo '  </div>'

cat footer.html
