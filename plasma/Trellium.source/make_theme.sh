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
mv -v Trellium.source.colors   "$name".colors
sed -i "s/^Name=.*/Name=$displayname/"                            "$name".colors
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


# Calculate opacity of scrollbars/sliders, which are rendered on top of (also translucent) widgets, assuming an average background value (0-255)
avg_bg_brightness=85
bg_brightness=$(bc <<< "($((0x$(echo ${colors_theme[bg]} | cut -b2-3))) + \
	                 $((0x$(echo ${colors_theme[bg]} | cut -b4-5))) + \
	                 $((0x$(echo ${colors_theme[bg]} | cut -b6-7)))) / 3")
bg_pressed_brightness=$(bc <<< "($((0x$(echo ${colors_theme[bg-pressed]} | cut -b2-3))) + \
	                         $((0x$(echo ${colors_theme[bg-pressed]} | cut -b4-5))) + \
		                 $((0x$(echo ${colors_theme[bg-pressed]} | cut -b6-7)))) / 3")
bg_alpha=${alpha[bg]}
bg_pressed_alpha=${alpha[bg-pressed]}
scrollbar_alpha=$(bc -l <<< "($bg_pressed_alpha*($avg_bg_brightness*($bg_alpha-1)+$bg_pressed_brightness-$bg_brightness*$bg_alpha))/($bg_alpha*($avg_bg_brightness*($bg_pressed_alpha-1)*($bg_alpha-1)+$bg_pressed_brightness*$bg_pressed_alpha+$bg_brightness*(-1*$bg_pressed_alpha*$bg_alpha+$bg_alpha-1)))")
min=$(echo 1 $scrollbar_alpha | tr ' ' '\n' | sort -n | head -1)
max=$(echo 0 $min             | tr ' ' '\n' | sort -n | tail -1)
scrollbar_alpha=$max


for i in ${!colors_source[@]}; do
	sed -i "s/$(hextorgb ${colors_source[$i]})/$(hextorgb ${colors_theme[$i]})/" $name.colors
done

for file in widgets/*.svg; do
	sed -i "/#808080/s/opacity:0.751/opacity:$scrollbar_alpha/"                 $file
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

rm -v colors* *.sh
mv -v $name.colors colors

cd -
