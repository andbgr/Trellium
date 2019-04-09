#!/bin/bash
# Usage: make_theme.sh colors.NAME


colorscheme="$(echo "$1" | sed 's/colors.//')"
displayname="Trellium $colorscheme"
name="$(echo "$displayname" | tr -d ' ')"

rm -rv    ../../$name
cp -av .. ../../$name
cd        ../../$name/xfwm4

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

sed -i "s/^active_text_color=.*/active_text_color=${colors_theme[text-bg]}/"     themerc
sed -i "s/^inactive_text_color=.*/inactive_text_color=${colors_theme[text-bg]}/" themerc

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

	rsvg-convert $file -o $(echo $file | sed 's/\.svg$/.png/')
done

convert decoration.png -crop 6x27+0+0 top-left-active.xpm
convert decoration.png -crop 6x27+60+0 top-right-active.xpm
convert decoration.png -crop 1x27+6+0 title-1-active.xpm
ln -sv title-1-active.xpm title-2-active.xpm
ln -sv title-1-active.xpm title-3-active.xpm
ln -sv title-1-active.xpm title-4-active.xpm
ln -sv title-1-active.xpm title-5-active.xpm
convert decoration.png -crop 3x1+0+6 left-active.xpm
convert decoration.png -crop 3x1+63+6 right-active.xpm
convert decoration.png -crop 1x6+6+60 bottom-active.xpm
convert decoration.png -crop 6x6+0+60 bottom-left-active.xpm
convert decoration.png -crop 6x6+60+60 bottom-right-active.xpm

convert buttons.png -crop 28x27+190+0 close-active.xpm
convert buttons.png -crop 29x27+161+0 maximize-toggled-active.xpm
convert buttons.png -crop 29x27+132+0 maximize-active.xpm
convert buttons.png -crop 29x27+103+0 shade-active.xpm
convert buttons.png -crop 31x27+72+0 hide-active.xpm
convert buttons.png -crop 33x27+39+0 stick-active.xpm
convert buttons.png -crop 37x27+2+0 menu-active.xpm

convert buttons-hover.png -crop 28x27+190+0 close-prelight.xpm
convert buttons-hover.png -crop 29x27+161+0 maximize-toggled-prelight.xpm
convert buttons-hover.png -crop 29x27+132+0 maximize-prelight.xpm
convert buttons-hover.png -crop 29x27+103+0 shade-prelight.xpm
convert buttons-hover.png -crop 31x27+72+0 hide-prelight.xpm
convert buttons-hover.png -crop 33x27+39+0 stick-prelight.xpm
convert buttons-hover.png -crop 37x27+2+0 menu-prelight.xpm

convert buttons-pressed.png -crop 28x27+190+0 close-pressed.xpm
convert buttons-pressed.png -crop 29x27+161+0 maximize-toggled-pressed.xpm
convert buttons-pressed.png -crop 29x27+132+0 maximize-pressed.xpm
convert buttons-pressed.png -crop 29x27+103+0 shade-pressed.xpm
convert buttons-pressed.png -crop 31x27+72+0 hide-pressed.xpm
convert buttons-pressed.png -crop 33x27+39+0 stick-pressed.xpm
convert buttons-pressed.png -crop 37x27+2+0 menu-pressed.xpm

ln -sv stick-pressed.xpm stick-toggled-active.xpm
ln -sv stick-pressed.xpm stick-toggled-prelight.xpm
ln -sv stick-pressed.xpm stick-toggled-pressed.xpm

ln -sv shade-pressed.xpm shade-toggled-active.xpm
ln -sv shade-pressed.xpm shade-toggled-prelight.xpm
ln -sv shade-pressed.xpm shade-toggled-pressed.xpm

for i in *-active.xpm; do
	ln -sv $i $(echo $i | sed 's/-active/-inactive/')
done




rm -v colors* *.sh *.colors *.svg *.png

cd -
