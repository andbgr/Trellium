/***************************************************************************
* Copyright (c) 2015 Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
* Copyright (c) 2013 Abdurrahman AVCI <abdurrahmanavci@gmail.com
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without restriction,
* including without limitation the rights to use, copy, modify, merge,
* publish, distribute, sublicense, and/or sell copies of the Software,
* and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included
* in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
* OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
* OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
* OR OTHER DEALINGS IN THE SOFTWARE.
*
***************************************************************************/

import QtQuick 2.2
import QtQuick.Controls 1.4 as QQC
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import SddmComponents 2.0

Rectangle {
    id: container
    width: 1024
    height: 768
    
    color: "#000000"
	
// 	Use this to control all font sizes (also affects icons and overall size of the greeter)
	property double scalingFactor: 1

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int sessionIndex: session.index

    TextConstants { id: textConstants }

    Connections {
        target: sddm
        onLoginSucceeded: {
        }

        onLoginFailed: {
			message.text = textConstants.loginFailed;
			passwd_entry.text = "";
        }
    }

    Background {
		id: background
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        onStatusChanged: {
            if (status == Image.Error && source != config.defaultBackground) {
                source = config.defaultBackground
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                listView.focus = true;
            }
        }
    }

    Rectangle {
		anchors.fill: parent
		color: "transparent"
		//visible: primaryScreen
		
		Rectangle {
			id: "greeter"
			width: 640 * container.scalingFactor
			height: 360 * container.scalingFactor
			anchors.centerIn: parent
			color: "transparent"
			
// 			grab background as source for blur behind greeter
			ShaderEffectSource {
				id: effect_source
				anchors.fill: background
				sourceItem: background
				sourceRect: Qt.rect(greeter.x,greeter.y, greeter.width, greeter.height)
			}
			
// 			blur it, this is a rectangle without rounded corners
			FastBlur {
				id: blur
				anchors.fill: parent
				source: effect_source
				radius: 80
				visible: false
			}
			
// 			mask with rounded corners
			BorderImage {
				id: mask
				anchors.fill: parent
				border.left: 5
				border.right: 5
				border.top: 5
				border.bottom: 5
				smooth: false
				source: "greeter-mask.svg"
				visible: false
			}
			
// 			now we have a blurred area with rounded corners
			OpacityMask {
				anchors.fill: parent
				source: blur
				maskSource: mask
			}
			
			BorderImage {
				anchors.fill: parent
				border.left: 5
				border.right: 5
				border.top: 5
				border.bottom: 5
				smooth: false
				source: "greeter.svg"
			}
			
			ColumnLayout {
				id: "rootlayout"
				anchors.fill: parent
				anchors.leftMargin: 2
				anchors.rightMargin: 2
				anchors.topMargin: 2
				anchors.bottomMargin: 2
				spacing: 0
				
				Text {
					id: "header"
					Layout.preferredHeight: footer.Layout.minimumHeight - 2
					Layout.margins: 1
					Layout.alignment: Qt.AlignTop | Qt.AlignCenter
					color: "#000000"
					text: sddm.hostName
					font.family: "Liberation Sans"
					font.pixelSize: 19 * container.scalingFactor
				}
				Text {
// 					Spacer
					Layout.preferredHeight: message.height
				}
				GridLayout {
					Layout.leftMargin: 8 * container.scalingFactor
					Layout.rightMargin: 8 * container.scalingFactor
					Layout.topMargin: 8 * container.scalingFactor
					Layout.bottomMargin: 8 * container.scalingFactor
					columns: 2
					rowSpacing: 4 * container.scalingFactor
					columnSpacing: 4 * container.scalingFactor
					
					QQC.Label {
						Layout.alignment: Qt.AlignRight
						text: textConstants.userName
						font.family: "Liberation Sans"
						font.pixelSize: 19 * container.scalingFactor
						color: "#000000"
					}
					
					QQC.TextField {
						id: user_entry
						text: userModel.lastUser
						Layout.fillWidth: true
						Layout.preferredHeight: font.pixelSize + 13 //this is really ugly, why isn't the minimum height determined by content?
						font.family: "Liberation Sans"
						font.pixelSize: 19 * container.scalingFactor
						textColor: "#000000"
						style: TextFieldStyle {
							background: BorderImage {
								border.left: 4
								border.right: 4
								border.top: 4
								border.bottom: 4
								smooth: false
								source: control.focus ? "entry-focused.svg"
								                      : "entry.svg"
							}
						}
					}
					
					QQC.Label {
						Layout.alignment: Qt.AlignRight
						text: textConstants.password
						font.family: "Liberation Sans"
						font.pixelSize: 19 * container.scalingFactor
						color: "#000000"
					}
					
					QQC.TextField {
						id: passwd_entry
						echoMode: TextInput.Password
						Layout.fillWidth: true
						Layout.preferredHeight: font.pixelSize + 13 //this is really ugly, why isn't the minimum height implicitly determined by content?
						font.family: "Liberation Sans"
						font.pixelSize: 19 * container.scalingFactor
						textColor: "#000000"
						style: TextFieldStyle {
							background: BorderImage {
								border.left: 4
								border.right: 4
								border.top: 4
								border.bottom: 4
								smooth: false
								source: control.focus ? "entry-focused.svg"
								                      : "entry.svg"
							}
						}
						Keys.onPressed: {
							if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
								sddm.login(user_entry.text, passwd_entry.text, sessionbutton.currentIndex);
								event.accepted = true;
							}
						}
					}
				}
				Text {
					id: message
					Layout.alignment: Qt.AlignCenter
					text: ""
					font.family: "Liberation Sans"
					font.pixelSize: 19 * container.scalingFactor
					color: "#810000"
				}
				RowLayout {
					id: "footer"
					Layout.fillWidth: true
					Layout.alignment: Qt.AlignBottom
					spacing: 0
					QQC.ToolButton {
						id: sessionbutton
						Layout.alignment: Qt.AlignBottom
						Layout.leftMargin: 8 * container.scalingFactor
						Layout.rightMargin: 8 * container.scalingFactor
						Layout.topMargin: 8 * container.scalingFactor
						Layout.bottomMargin: 8 * container.scalingFactor
						property int currentIndex: -1
						
						style: ButtonStyle {
							padding.right: 6
							background: BorderImage {
								border.left: 7
								border.right: 7
								border.top: 7
								border.bottom: 7
								smooth: false
								source: control.pressed ? "button-pressed.svg"
								      : control.hovered ? "button-hover.svg"
								      : control.focus ? "button-hover.svg"
								      : "button.svg"
							}
							label: RowLayout {
								QQC.Label {
									Layout.fillWidth: true
									text: instantiator.objectAt(sessionbutton.currentIndex).text || ""
									font.family: "Liberation Sans"
									font.pixelSize: 19 * container.scalingFactor
									color: "#000000"
								}
								Image {
									source: "arrow-down.svg"
									smooth: false
								}
							}
						}
						
						Component.onCompleted: {
							currentIndex = sessionModel.lastIndex
						}
						
						menu: QQC.Menu {
							id: sessionmenu
							Instantiator {
								id: instantiator
								model: sessionModel
								onObjectAdded: sessionmenu.insertItem(index, object)
								onObjectRemoved: sessionmenu.removeItem(object)
								delegate: QQC.MenuItem {
									text: model.name
									onTriggered: {
										sessionbutton.currentIndex = model.index
									}
								}
							}
						}
					}
					Text {
// 						Spacer
						Layout.fillWidth: true
					}
					QQC.ToolButton {
						id: reboot_button
// 						enabled: sddm.canReboot
						Layout.alignment: Qt.AlignBottom
						style: ButtonStyle {
							padding.top: 7
							padding.right: 5
							padding.bottom: 4
							padding.left: 7
							background: BorderImage {
								border.top: 7
								border.right: 5
								border.bottom: 4
								border.left: 7
								smooth: false
								source: control.pressed ? "button-left-pressed.svg"
								      : control.hovered ? "button-left-hover.svg"
								      : control.focus ? "button-left-hover.svg"
								      : "button-left.svg"
							}
							label: Image {
								sourceSize.width: 30 * container.scalingFactor
								sourceSize.height: 20 * container.scalingFactor
								source: "reboot.svg"
								opacity: reboot_button.enabled ? 1 : 0.5
							}
						}
						onClicked: sddm.reboot()
					}
					QQC.ToolButton {
						id: suspend_button
// 						visible: sddm.canSuspend
						Layout.alignment: Qt.AlignBottom
						style: ButtonStyle {
							padding.top: 7
							padding.right: 5
							padding.bottom: 4
							padding.left: 5
							background: BorderImage {
								border.top: 7
								border.right: 5
								border.bottom: 4
								border.left: 5
								smooth: false
								source: control.pressed ? "button-middle-pressed.svg"
								      : control.hovered ? "button-middle-hover.svg"
								      : control.focus ? "button-middle-hover.svg"
								      : "button-middle.svg"
							}
							label: Image {
								sourceSize.width: 30 * container.scalingFactor
								sourceSize.height: 20 * container.scalingFactor
								source: "suspend.svg"
								opacity: suspend_button.enabled ? 1 : 0.5
							}
						}
						onClicked: sddm.suspend()
					}
					QQC.ToolButton {
						id: hibernate_button
// 						visible: sddm.canHibernate
						Layout.alignment: Qt.AlignBottom
						style: ButtonStyle {
							padding.top: 7
							padding.right: 5
							padding.bottom: 4
							padding.left: 5
							background: BorderImage {
								border.top: 7
								border.right: 5
								border.bottom: 4
								border.left: 5
								smooth: false
								source: control.pressed ? "button-middle-pressed.svg"
								      : control.hovered ? "button-middle-hover.svg"
								      : control.focus ? "button-middle-hover.svg"
								      : "button-middle.svg"
							}
							label: Image {
								sourceSize.width: 30 * container.scalingFactor
								sourceSize.height: 20 * container.scalingFactor
								source: "hibernate.svg"
								opacity: hibernate_button.enabled ? 1 : 0.5
							}
						}
						onClicked: sddm.hibernate()
					}
					QQC.ToolButton {
						id: shutdown_button
// 						enabled: sddm.canPowerOff
						Layout.alignment: Qt.AlignBottom
						style: ButtonStyle {
							padding.top: 7
							padding.right: 4
							padding.bottom: 4
							padding.left: 5
							background: BorderImage {
								border.top: 7
								border.right: 4
								border.bottom: 4
								border.left: 5
								smooth: false
								source: control.pressed ? "button-right-pressed.svg"
								      : control.hovered ? "button-right-hover.svg"
								      : control.focus ? "button-right-hover.svg"
								      : "button-right.svg"
							}
							label: Image {
								sourceSize.width: 30 * container.scalingFactor
								sourceSize.height: 20 * container.scalingFactor
								source: "shutdown.svg"
								opacity: shutdown_button.enabled ? 1 : 0.5
							}
						}
						onClicked: sddm.powerOff()
					}
				}
			}
		}
    }
    
    Component.onCompleted: {
		if (user_entry.text === "")
			user_entry.focus = true;
		else
			passwd_entry.focus = true;
	}
}
