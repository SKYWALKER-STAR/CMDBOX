import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import CommandManager 1.0

Popup {
    id: createOptionPopup
    modal: true
    focus: true
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    parent: Overlay.overlay
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    width: 320
    height: 120

    // 当前操作的分组名
    property string targetGroup: "All"

    signal addFolderRequested(string groupName)
    signal addCommandRequested(string groupName)

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 120; easing.type: Easing.OutCubic }
        NumberAnimation { property: "scale"; from: 0.96; to: 1.0; duration: 140; easing.type: Easing.OutCubic }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 100; easing.type: Easing.InCubic }
        NumberAnimation { property: "scale"; from: 1.0; to: 0.96; duration: 100; easing.type: Easing.InCubic }
    }

    function openFor(groupName) {
        targetGroup = groupName || "All"
        open()
    }

    background: Rectangle {
        radius: 12
        color: "#ffffff"
        border.color: "#E5E7EB"
        border.width: 1
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Label {
            text: "选择新增类型"
            font.pixelSize: 14
            font.bold: true
            color: "#111827"
            Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Button {
                text: "📂 新增目录"
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                font.pixelSize: 13
                font.bold: true
                background: Rectangle {
                    radius: 8
                    color: parent.pressed ? "#E5E7EB" : (parent.hovered ? "#F3F4F6" : "#F8FAFC")
                    border.color: "#E2E8F0"
                }
                contentItem: Label {
                    text: parent.text
                    color: "#111827"
                    font.pixelSize: parent.font.pixelSize
                    font.bold: parent.font.bold
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    createOptionPopup.close()
                    createOptionPopup.addFolderRequested(createOptionPopup.targetGroup)
                }
            }

            Button {
                text: "📄 新增命令"
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                font.pixelSize: 13
                font.bold: true
                background: Rectangle {
                    radius: 8
                    color: parent.pressed ? "#E5E7EB" : (parent.hovered ? "#F3F4F6" : "#F8FAFC")
                    border.color: "#E2E8F0"
                }
                contentItem: Label {
                    text: parent.text
                    color: "#111827"
                    font.pixelSize: parent.font.pixelSize
                    font.bold: parent.font.bold
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    createOptionPopup.close()
                    createOptionPopup.addCommandRequested(createOptionPopup.targetGroup)
                }
            }
        }
    }
}
