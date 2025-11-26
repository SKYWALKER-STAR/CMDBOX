import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "CMD BOX"

    Component.onCompleted: {
        // Ensure data is loaded when window is ready
        commandManager.initialize()
    }

    Shortcut {
        sequence: "Ctrl+F"
        onActivated: searchField.forceActiveFocus()
    }

    Shortcut {
        sequence: "Ctrl+N"
        onActivated: commandDialog.openForAdd()
    }

    header: ToolBar {
        height: 60
        padding: 10

        background: Rectangle {
            color: "#f5f5f5"
            border.color: "#e0e0e0"
            border.width: 1
        }

        RowLayout {
            anchors.fill: parent
            spacing: 15

            Label {
                text: "CMD BOX"
                font.bold: true
                font.pixelSize: 20
                Layout.alignment: Qt.AlignVCenter
                color: "#333333"
            }

            TextField {
                id: searchField
                placeholderText: "搜索命令..."
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignVCenter
                verticalAlignment: Text.AlignVCenter
                leftPadding: 10
                
                onTextChanged: commandManager.setFilter(text)
                
                background: Rectangle {
                    color: "white"
                    radius: 8
                    border.color: searchField.activeFocus ? "#2196F3" : "#e0e0e0"
                    border.width: 1
                }
            }

            ComboBox {
                id: groupCombo
                model: commandManager.groups
                currentIndex: 0
                onCurrentTextChanged: {
                    commandManager.setGroupFilter(currentText)
                }
                Layout.preferredWidth: 160
                Layout.alignment: Qt.AlignVCenter
            }

            ToolButton {
                text: "⋮"
                font.pixelSize: 24
                onClicked: optionsMenu.open()
                
                Menu {
                    id: optionsMenu
                    y: parent.height
                    
                    MenuItem {
                        text: "导入数据"
                        onTriggered: importDialog.open()
                    }
                    MenuItem {
                        text: "导出数据"
                        onTriggered: exportDialog.open()
                    }
                }
            }
        }
    }

    FileDialog {
        id: importDialog
        title: "选择要导入的 JSON 文件"
        nameFilters: ["JSON files (*.json)", "All files (*)"]
        fileMode: FileDialog.OpenFile
        onAccepted: {
            if (commandManager.importCommands(selectedFile)) {
                copyNotification.text = "数据导入成功"
                copyNotification.open()
            } else {
                copyNotification.text = "导入失败"
                copyNotification.open()
            }
        }
    }

    FileDialog {
        id: exportDialog
        title: "导出为 JSON 文件"
        nameFilters: ["JSON files (*.json)", "All files (*)"]
        fileMode: FileDialog.SaveFile
        currentFile: "commands.json"
        onAccepted: {
            if (commandManager.exportCommands(selectedFile)) {
                copyNotification.text = "数据导出成功"
                copyNotification.open()
            } else {
                copyNotification.text = "导出失败"
                copyNotification.open()
            }
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        model: commandManager
        clip: true
        spacing: 10
        
        footer: Item {
            width: listView.width
            height: 60
            
            ToolButton {
                id: addButton
                anchors.centerIn: parent
                text: "+"
                font.pixelSize: 24
                width: 50
                height: 50
                onClicked: addMenu.open()
                background: Rectangle {
                    color: addButton.pressed ? "#d0d0d0" : "#e0e0e0"
                    radius: 25
                    border.color: "#cccccc"
                }
            }

            Menu {
                id: addMenu
                x: addButton.x
                y: addButton.y + addButton.height + 2
                MenuItem {
                    text: "1. Add Folder"
                    onTriggered: commandDialog.openForAddFolder()
                }
                MenuItem {
                    text: "2. Add Command"
                    onTriggered: commandDialog.openForAdd()
                }
            }
        }

        delegate: ItemDelegate {
            width: listView.width
            height: column.implicitHeight + 20

            onClicked: {
                commandManager.copyToClipboard(model.commandContent)
                copyNotification.text = "已复制: " + model.title
                copyNotification.open()
            }

            background: Rectangle {
                color: parent.hovered ? "#f0f0f0" : "white"
                border.color: "#e0e0e0"
                radius: 5
            }

            ColumnLayout {
                id: column
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5

                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: model.title
                        font.bold: true
                        font.pixelSize: 16
                        Layout.fillWidth: true
                    }
                    Button {
                        text: "复制"
                        onClicked: {
                            commandManager.copyToClipboard(model.commandContent)
                            copyNotification.text = "已复制: " + model.title
                            copyNotification.open()
                        }
                    }
                    Button {
                        text: "修改"
                        onClicked: {
                            commandDialog.openForEdit(index, model.title, model.commandContent, model.description, model.group, model.isFolder)
                        }
                    }
                    Button {
                        text: "删除"
                        onClicked: commandManager.removeCommand(index)
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "#f5f5f5"
                    radius: 3
                    border.color: "#dddddd"

                    Text {
                        anchors.fill: parent
                        anchors.margins: 5
                        text: model.commandContent
                        font.family: "Courier New"
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }

                Label {
                    text: model.description
                    color: "gray"
                    font.pixelSize: 12
                    visible: model.description !== ""
                }
            }
        }
    }

    Dialog {
        id: commandDialog
        property int editIndex: -1
        property bool folderMode: false
        title: folderMode ? (editIndex === -1 ? "添加新分组" : "修改分组")
                      : (editIndex === -1 ? "添加新命令" : "修改命令")
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        width: 400

        function openForAdd() {
            editIndex = -1
            folderMode = false
            titleField.text = ""
            commandField.text = ""
            descField.text = ""
            groupField.text = ""
            open()
        }

        function openForAddFolder() {
            editIndex = -1
            folderMode = true
            titleField.text = ""
            commandField.text = ""
            descField.text = ""
            groupField.text = ""
            open()
        }

        function openForEdit(index, title, cmd, desc, group, isFolder) {
            editIndex = index
            folderMode = !!isFolder
            titleField.text = title
            commandField.text = cmd
            descField.text = desc
            // QML calls pass group as 4th arg when available
            if (typeof(group) !== 'undefined') groupField.text = group
            else groupField.text = ""
            open()
        }

        onAccepted: {
            if (titleField.text === "")
                return
            if (!folderMode && commandField.text === "")
                return

            if (folderMode) {
                if (editIndex === -1) {
                    commandManager.addFolder(titleField.text, groupField.text)
                } else {
                    commandManager.editFolder(editIndex, titleField.text, groupField.text)
                }
            } else {
                if (editIndex === -1) {
                    commandManager.addCommand(titleField.text, commandField.text, descField.text, groupField.text)
                } else {
                    commandManager.editCommand(editIndex, titleField.text, commandField.text, descField.text, groupField.text)
                }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 10

            TextField {
                id: titleField
                placeholderText: "标题 (例如: 查看日志)"
                Layout.fillWidth: true
            }

            TextArea {
                id: commandField
                placeholderText: "命令内容 (例如: tail -f /var/log/syslog)"
                Layout.fillWidth: true
                Layout.preferredHeight: folderMode ? 0 : 100
                visible: !folderMode
                background: Rectangle {
                    border.color: "#ccc"
                }
            }

            TextField {
                id: descField
                placeholderText: "描述 (可选)"
                Layout.fillWidth: true
                visible: !folderMode
            }

            TextField {
                id: groupField
                placeholderText: "分组 (可选)"
                Layout.fillWidth: true
            }
        }
    }

    ToolTip {
        id: copyNotification
        text: "命令已复制到剪贴板"
        timeout: 2000
        anchors.centerIn: parent
    }
}
