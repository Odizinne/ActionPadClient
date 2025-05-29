import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Controls.impl
import Odizinne.ActionPadClient

Page {
    id: root

    signal navigateBack()
    property int delegateHeight: 60
    Material.background: UserSettings.darkMode ? "#1C1C1C" : "#E3E3E3"

    header: ToolBar {
        Material.elevation: 6
        Material.background: UserSettings.darkMode ? "#2B2B2B" : "#FFFFFF"

        ToolButton {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            icon.source: "qrc:/icons/back.svg"
            icon.color: UserSettings.darkMode ? "white" : "black"
            icon.width: 18
            icon.height: 18
            onClicked: root.navigateBack()
        }

        Label {
            text: "Settings"
            font.pixelSize: 18
            font.bold: true
            anchors.centerIn: parent
        }
    }

    ScrollingArea {
        id: scrollArea
        anchors.fill: parent
        contentWidth: width
        contentHeight: textContainer.height + 20

        Item {
            id: textContainer
            width: scrollArea.width
            //height: mainCol.height + 20
            anchors.top: parent.top
            anchors.topMargin: 10

            ColumnLayout {
                id: mainCol
                anchors.fill: parent
                spacing: 10

                Label {
                    text: qsTr("Server config")
                    font.pixelSize: 14
                    opacity: 0.6
                    Layout.preferredHeight: 48
                    Layout.leftMargin: 16
                    verticalAlignment: Text.AlignBottom
                    bottomPadding: 8
                    color: UserSettings.darkMode ? "white" : "black"
                }

                Column {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    spacing: 5

                    Label {
                        text: "IP"
                    }

                    TextField {
                        id: serverAddressField
                        width: parent.width
                        text: UserSettings.savedIP
                        placeholderText: "192.168.1.100"
                        onTextChanged: {
                            if (ActionPadClient) ActionPadClient.serverAddress = text
                            UserSettings.savedIP = text
                        }
                    }
                }

                Column {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    spacing: 5

                    Label {
                        text: "Port"
                    }

                    TextField {
                        id: serverPortField
                        width: parent.width
                        text: UserSettings.savedPort
                        placeholderText: "8080"
                        validator: IntValidator { bottom: 1; top: 65535 }
                        onTextChanged: {
                            if (text.length > 0 && ActionPadClient) {
                                ActionPadClient.serverPort = parseInt(text)
                                UserSettings.savedPort = text
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Label {
                        Layout.fillWidth: true
                        text: "Connection Status:"
                    }

                    Label {
                        text: ActionPadClient ? ActionPadClient.connectionStatus : "Disconnected"
                        color: ActionPadClient && ActionPadClient.isConnected ? "green" : "red"
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    text: ActionPadClient && ActionPadClient.isConnected ? "Disconnect" : "Connect"

                    onClicked: {
                        if (ActionPadClient) {
                            if (ActionPadClient.isConnected) {
                                ActionPadClient.disconnectFromServer()
                            } else {
                                ActionPadClient.connectToServer()
                            }
                        }
                    }
                }

                MenuSeparator {
                    Layout.fillWidth: true
                }

                Label {
                    text: qsTr("Application config")
                    font.pixelSize: 14
                    opacity: 0.6
                    Layout.preferredHeight: 48
                    Layout.leftMargin: 16
                    verticalAlignment: Text.AlignBottom
                    bottomPadding: 8
                    color: UserSettings.darkMode ? "white" : "black"
                }

                SwitchDelegate {
                    id: darkModeSwitch
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.delegateHeight
                    text: qsTr("Dark mode")
                    checked: UserSettings.darkMode
                    onClicked: UserSettings.darkMode = checked

                    Item {
                        anchors.right: parent.right
                        anchors.rightMargin: 70
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20
                        height: 20

                        IconImage {
                            anchors.fill: parent
                            source: "qrc:/icons/sun.svg"
                            color: "black"
                            opacity: !darkModeSwitch.checked ? 1 : 0
                            rotation: darkModeSwitch.checked ? 360 : 0
                            mipmap: true

                            Behavior on rotation {
                                NumberAnimation {
                                    duration: 500
                                    easing.type: Easing.OutQuad
                                }
                            }

                            Behavior on opacity {
                                NumberAnimation { duration: 500 }
                            }
                        }

                        IconImage {
                            anchors.fill: parent
                            source: "qrc:/icons/moon.svg"
                            color: "white"
                            opacity: darkModeSwitch.checked ? 1 : 0
                            rotation: darkModeSwitch.checked ? 360 : 0
                            mipmap: true

                            Behavior on rotation {
                                NumberAnimation {
                                    duration: 500
                                    easing.type: Easing.OutQuad
                                }
                            }

                            Behavior on opacity {
                                NumberAnimation { duration: 100 }
                            }
                        }
                    }
                }
            }
        }
    }
}

