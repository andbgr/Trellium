#!/bin/bash
# Usage: make_theme.sh colors.NAME


colorscheme="$(echo "$1" | sed 's/colors.//')"
displayname="Trellium $colorscheme"
name="$(echo "$displayname" | tr -d ' ')"

rm -rv   ../$name
cp -av . ../$name
cd       ../$name

sed -i "s/^Name=.*/Name=$displayname/"  metadata.desktop
sed -i "s/^Theme-Id=.*/Theme-Id=$name/" metadata.desktop

declare -A colors_source
while read key val; do
	colors_source[$key]=$val
done < colors

declare -A colors_theme
while read key val alpha; do
	colors_theme[$key]=$val
done < "colors.$colorscheme"

declare -A alpha
while read key val alpha; do
	alpha[$key]=$alpha
done < "colors.$colorscheme"

for file in *.svg main.qml; do
	sed -i '/fill:#ff00ff/s/\(fill-opacity:[0-9.]*;\|;fill-opacity:[0-9.]*\)//' $file
	sed -i '/fill:#ff00ff/s/fill:#ff00ff/fill:#ff00ff;fill-opacity:0/'          $file
	
	for i in ${!colors_source[@]}; do
		sed -i "/fill:${colors_source[$i]}/s/\(fill-opacity:[0-9.]*;\|;fill-opacity:[0-9.]*\)//"                             $file
		sed -i "/fill:${colors_source[$i]}/s/fill:${colors_source[$i]}/fill:${colors_source[$i]};fill-opacity:${alpha[$i]}/" $file
		sed -i "/stop-color:${colors_source[$i]}/s/stop-opacity:1/stop-opacity:${alpha[$i]}/"                                $file
	done
	
	for i in ${!colors_source[@]}; do
		sed -i "s/${colors_source[$i]}/PLACEHOLDER-$i-PLACEHOLDER/g" $file
	done
	for i in ${!colors_source[@]}; do
		sed -i "s/PLACEHOLDER-$i-PLACEHOLDER/${colors_theme[$i]}/g" $file
	done
done

rsvg-convert preview.svg -o preview.png

rm -v colors* *.sh *.colors preview.svg

cd -
