#!/bin/bash
# Usage: make_theme.sh colors.NAME


function hextorgb {
	r=$((0x$(echo $1 | cut -b2-3)))
	g=$((0x$(echo $1 | cut -b4-5)))
	b=$((0x$(echo $1 | cut -b6-7)))

	echo "$r,$g,$b"
}


colorscheme="$(echo "$1" | sed 's/colors.//')"
displayname="Trellium $colorscheme"
name="$(echo "$displayname" | tr -d ' ')"

rm -rv   ../$name
cp -av . ../$name
cd       ../$name
mv -v Trellium.sourcerc "$name"rc

sed -i "s/^Name=.*/Name=$displayname/"                            metadata.desktop
sed -i "s/^X-KDE-PluginInfo-Name=.*/X-KDE-PluginInfo-Name=$name/" metadata.desktop

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

sed -i "s/^ActiveTextColor=.*/ActiveTextColor=$(hextorgb ${colors_theme[text-bg]})/"       "$name"rc 
sed -i "s/^InactiveTextColor=.*/InactiveTextColor=$(hextorgb ${colors_theme[text-bg]})/" "$name"rc 

for file in *.svg; do
	sed -i '/#ff00ff/s/fill-opacity:1/fill-opacity:0/' $file
	
	for i in ${!colors_source[@]}; do
		sed -i "/${colors_source[$i]}/s/fill-opacity:1/fill-opacity:${alpha[$i]}/g" $file
		sed -i "/${colors_source[$i]}/s/stop-opacity:1/stop-opacity:${alpha[$i]}/g" $file
	done
	
	for i in ${!colors_source[@]}; do
		sed -i "s/${colors_source[$i]}/PLACEHOLDER-$i-PLACEHOLDER/g" $file
	done
	for i in ${!colors_source[@]}; do
		sed -i "s/PLACEHOLDER-$i-PLACEHOLDER/${colors_theme[$i]}/g" $file
	done
done

rm -v colors*  *.sh README $(ls | grep '.colors$' | grep -v $name.colors)

cd -
