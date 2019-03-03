#!/bin/bash
# This is invoked by make_theme.sh




# Right -> Bottom
cp -av lxqt-panel.right.qss lxqt-panel.bottom.qss

sed -i 's/LXQtPanel\[position="Right"\]/LXQtPanel[position="Bottom"]/' lxqt-panel.bottom.qss

sed -i 's/-top/-PLACEHOLDER-top/' lxqt-panel.bottom.qss
sed -i 's/-right/-PLACEHOLDER-right/' lxqt-panel.bottom.qss
sed -i 's/-bottom/-PLACEHOLDER-bottom/' lxqt-panel.bottom.qss
sed -i 's/-left/-PLACEHOLDER-left/' lxqt-panel.bottom.qss

sed -i 's/-PLACEHOLDER-top/-left/' lxqt-panel.bottom.qss
sed -i 's/-PLACEHOLDER-right/-bottom/' lxqt-panel.bottom.qss
sed -i 's/-PLACEHOLDER-bottom/-right/' lxqt-panel.bottom.qss
sed -i 's/-PLACEHOLDER-left/-top/' lxqt-panel.bottom.qss

sed -i 's/\([0-9]\+\) \([0-9]\+\) \([0-9]\+\) \([0-9]\+\)/\4 \3 \2 \1/' lxqt-panel.bottom.qss

sed -i 's/-vertical\.svg/-horizontal.svg/' lxqt-panel.bottom.qss




# Right -> Left
cp -av lxqt-panel.right.qss lxqt-panel.left.qss

sed -i 's/LXQtPanel\[position="Right"\]/LXQtPanel[position="Left"]/' lxqt-panel.left.qss

sed -i 's/-right/-PLACEHOLDER-right/' lxqt-panel.left.qss
sed -i 's/-left/-PLACEHOLDER-left/' lxqt-panel.left.qss

sed -i 's/-PLACEHOLDER-right/-left/' lxqt-panel.left.qss
sed -i 's/-PLACEHOLDER-left/-right/' lxqt-panel.left.qss

sed -i 's/\([0-9]\+\) \([0-9]\+\) \([0-9]\+\) \([0-9]\+\)/\1 \4 \3 \2/' lxqt-panel.left.qss




# Right -> Top
cp -av lxqt-panel.right.qss lxqt-panel.top.qss

sed -i 's/LXQtPanel\[position="Right"\]/LXQtPanel[position="Top"]/' lxqt-panel.top.qss

sed -i 's/-top/-PLACEHOLDER-top/' lxqt-panel.top.qss
sed -i 's/-right/-PLACEHOLDER-right/' lxqt-panel.top.qss
sed -i 's/-bottom/-PLACEHOLDER-bottom/' lxqt-panel.top.qss
sed -i 's/-left/-PLACEHOLDER-left/' lxqt-panel.top.qss

sed -i 's/-PLACEHOLDER-top/-left/' lxqt-panel.top.qss
sed -i 's/-PLACEHOLDER-right/-top/' lxqt-panel.top.qss
sed -i 's/-PLACEHOLDER-bottom/-right/' lxqt-panel.top.qss
sed -i 's/-PLACEHOLDER-left/-bottom/' lxqt-panel.top.qss

sed -i 's/\([0-9]\+\) \([0-9]\+\) \([0-9]\+\) \([0-9]\+\)/\2 \3 \4 \1/' lxqt-panel.top.qss

sed -i 's/-vertical\.svg/-horizontal.svg/' lxqt-panel.top.qss




cat lxqt-panel.right.qss lxqt-panel.bottom.qss lxqt-panel.left.qss lxqt-panel.top.qss > lxqt-panel.qss
rm -v lxqt-panel.bottom.qss lxqt-panel.left.qss lxqt-panel.top.qss
