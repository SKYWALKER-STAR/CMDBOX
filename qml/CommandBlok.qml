import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Popup {
    id: preview
    modal: true
    focus: true
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    // Always show in the visual center of the window overlay.
    parent: Overlay.overlay
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    width: Math.min(parent ? parent.width * 0.9 : 800, 800)
    height: Math.min(parent ? parent.height * 0.8 : 500, 500)

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 120; easing.type: Easing.OutCubic }
        NumberAnimation { property: "scale"; from: 0.98; to: 1.0; duration: 140; easing.type: Easing.OutCubic }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 110; easing.type: Easing.InCubic }
        NumberAnimation { property: "scale"; from: 1.0; to: 0.98; duration: 110; easing.type: Easing.InCubic }
    }

    property string winTitle: "命令查看"
    property string cmdText: ""

    function openWith(titleStr, cmdStr) {
        winTitle = titleStr && titleStr.length ? titleStr : "命令查看"
        cmdText = cmdStr
        open()
    }

    onOpened: {
        cmdArea.forceActiveFocus()
        cmdArea.selectAll()
    }

    // Flat “card” with subtle border + shadow
    background: Item {
        Rectangle {
            id: card
            anchors.fill: parent
            radius: 14
            color: "#ffffff"
            border.color: "#E5E7EB"
            border.width: 1

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#1F2937" // will be dimmed by shadowOpacity
                shadowOpacity: 0.18
                shadowBlur: 0.65
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 10
            }
        }
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Label {
                    text: preview.winTitle
                    font.pixelSize: 16
                    font.bold: true
                    color: "#111827"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Label {
                    text: "只读预览，可一键复制"
                    font.pixelSize: 12
                    color: "#6B7280"
                    Layout.fillWidth: true
                }
            }

            ToolButton {
                text: "✕"
                implicitWidth: 34
                implicitHeight: 34
                onClicked: preview.close()
                background: Rectangle {
                    radius: 10
                    color: parent.pressed ? "#F3F4F6" : (parent.hovered ? "#F9FAFB" : "transparent")
                    border.color: parent.hovered ? "#E5E7EB" : "transparent"
                }
                contentItem: Label {
                    text: parent.text
                    font.pixelSize: 14
                    color: "#6B7280"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#F1F5F9"
        }

        // Body
        TextArea {
            id: cmdArea
            text: preview.cmdText
            readOnly: true
            selectByMouse: true
            wrapMode: wrapToggle.checked ? TextEdit.Wrap : TextEdit.NoWrap
            font.family: "Consolas"
            font.pixelSize: 13
            color: "#0F172A"
            Layout.fillWidth: true
            Layout.fillHeight: true

            background: Rectangle {
                radius: 12
                color: "#F8FAFC"
                border.color: "#E2E8F0"
            }

            // Add line numbers
            Row {
                spacing: 0
                Rectangle {
                    width: 30
                    color: "#E5E7EB"
                    Text {
                        anchors.centerIn: parent
                        text: (index + 1) + "."
                        font.pixelSize: 12
                        color: "#6B7280"
                    }
                }
                TextEdit {
                    // ...existing code...
                }
            }
        }

        // Footer
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Item { Layout.fillWidth: true }

            Button {
                text: "复制"
                onClicked: if (typeof CommandManager !== "undefined") CommandManager.copyToClipboard(cmdArea.text)
            }
            Button {
                text: "关闭"
                onClicked: preview.close()
            }
        }
    }

    // Add a toast notification for copy success
    Item {
        id: toast
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        visible: false
        opacity: 0

        Rectangle {
            width: 200
            height: 40
            radius: 8
            color: "#323232"
            opacity: 0.9

            Text {
                anchors.centerIn: parent
                text: "复制成功"
                color: "#FFFFFF"
                font.pixelSize: 14
            }
        }

        states: [
            State {
                name: "visible"
                when: toast.visible
                PropertyChanges { target: toast; opacity: 1 }
            }
        ]

        transitions: [
            Transition {
                from: ""
                to: "visible"
                NumberAnimation { property: "opacity"; duration: 300 }
            },
            Transition {
                from: "visible"
                to: ""
                NumberAnimation { property: "opacity"; duration: 300 }
            }
        ]
    }

    // Add a word wrap toggle
    RowLayout {
        spacing: 10
        CheckBox {
            id: wrapToggle
            text: "自动换行"
            checked: false
        }
    }
}