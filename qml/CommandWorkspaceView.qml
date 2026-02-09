import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import CommandManager 1.0

Rectangle {
    id: workspace
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#fafafa"

    // 主题变量
    property color cardColor: "#ffffff"
    property color subtleBorder: "#e5e5e5"
    property color primary: "#171717"
    property color textPrimary: "#0a0a0a"
    property color textSecondary: "#737373"
    property color accent: "#525252"

    // 当前命令数据
    property int commandIndex: -1
    property string commandTitle: ""
    property string commandContent: ""
    property string commandDescription: ""
    property string commandGroup: ""

    // 是否有活跃命令
    property bool hasActiveCommand: commandIndex >= 0

    // 外部引用
    property var commandDialog: null
    property var copyNotification: null
    property var previewWin: null

    // 信号
    signal commandDeleted()

    function openCommand(index, title, cmd, description, group) {
        commandIndex = index
        commandTitle = title || ""
        commandContent = cmd || ""
        commandDescription = description || ""
        commandGroup = group || ""
    }

    function clear() {
        commandIndex = -1
        commandTitle = ""
        commandContent = ""
        commandDescription = ""
        commandGroup = ""
    }

    // 空状态
    Item {
        anchors.fill: parent
        visible: !hasActiveCommand

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 16

            Label {
                text: "⌘"
                font.pixelSize: 56
                color: "#d4d4d4"
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: "选择一个命令开始"
                font.pixelSize: 16
                font.weight: Font.Medium
                color: textSecondary
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: "在左侧导航栏中点击命令，即可在此查看详情"
                font.pixelSize: 13
                color: "#a3a3a3"
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // 命令工作区
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0
        visible: hasActiveCommand

        // ── 顶部标题栏 ──
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            color: cardColor
            border.color: subtleBorder
            border.width: 0

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 24
                anchors.rightMargin: 24
                spacing: 12

                // 方法标签（类似 Postman GET 标签）
                Rectangle {
                    Layout.preferredWidth: cmdLabel.implicitWidth + 20
                    Layout.preferredHeight: 28
                    radius: 6
                    color: "#171717"
                    Label {
                        id: cmdLabel
                        anchors.centerIn: parent
                        text: "CMD"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#ffffff"
                    }
                }

                // 命令标题
                Label {
                    text: commandTitle
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    color: textPrimary
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                // 操作按钮
                CButton {
                    text: "复制"
                    theme: "primary"
                    onClicked: {
                        if (CommandManager) {
                            CommandManager.copyToClipboard(commandContent)
                            if (copyNotification) {
                                copyNotification.text = "已复制: " + commandTitle
                                copyNotification.open()
                            }
                        }
                    }
                }

                CButton {
                    text: "修改"
                    theme: "warning"
                    onClicked: {
                        if (commandDialog) {
                            commandDialog.openForEdit(commandIndex, commandTitle, commandContent, commandDescription, commandGroup, false)
                        }
                    }
                }

                CButton {
                    text: "删除"
                    theme: "danger"
                    onClicked: {
                        deleteConfirmDialog.open()
                    }
                }

                CButton {
                    text: "</>"
                    theme: "success"
                    implicitWidth: 40
                    onClicked: {
                        if (previewWin) previewWin.openWith(commandTitle, commandContent)
                    }
                }
            }

            // 底线
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: subtleBorder
            }
        }

        // ── 命令栏（类似 Postman URL 栏）──
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            Layout.leftMargin: 24
            Layout.rightMargin: 24
            Layout.topMargin: 16
            color: cardColor
            radius: 8
            border.color: cmdBar.activeFocus ? primary : subtleBorder
            border.width: cmdBar.activeFocus ? 2 : 1

            Behavior on border.color { ColorAnimation { duration: 150 } }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 8
                spacing: 8

                // 命令图标
                Label {
                    text: "❯"
                    font.pixelSize: 16
                    font.bold: true
                    color: accent
                    Layout.preferredWidth: 20
                }

                // 命令文本（可选中复制）
                TextInput {
                    id: cmdBar
                    text: commandContent
                    readOnly: true
                    selectByMouse: true
                    font.family: "Consolas, Courier New, monospace"
                    font.pixelSize: 14
                    color: textPrimary
                    clip: true
                    Layout.fillWidth: true
                    verticalAlignment: Text.AlignVCenter
                }

                // 快速复制
                ToolButton {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    contentItem: Label {
                        text: "📋"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        radius: 6
                        color: parent.pressed ? "#e5e5e5" : (parent.hovered ? "#f0f0f0" : "transparent")
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: "复制命令"
                    ToolTip.delay: 300
                    onClicked: {
                        if (CommandManager) {
                            CommandManager.copyToClipboard(commandContent)
                            if (copyNotification) {
                                copyNotification.text = "已复制: " + commandTitle
                                copyNotification.open()
                            }
                        }
                    }
                }
            }
        }

        // ── Tab 栏 ──
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            Layout.leftMargin: 24
            Layout.rightMargin: 24
            Layout.topMargin: 16
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Repeater {
                    model: [
                        { label: "详情", tab: 0 },
                        { label: "说明", tab: 1 }
                    ]

                    delegate: Rectangle {
                        Layout.preferredWidth: 80
                        Layout.fillHeight: true
                        color: "transparent"

                        property bool isActive: tabStack.currentIndex === modelData.tab

                        Label {
                            anchors.centerIn: parent
                            text: modelData.label
                            font.pixelSize: 13
                            font.weight: isActive ? Font.DemiBold : Font.Normal
                            color: isActive ? textPrimary : textSecondary
                        }

                        // 活跃指示条
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width - 16
                            height: 2
                            radius: 1
                            color: primary
                            visible: isActive
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: tabStack.currentIndex = modelData.tab
                        }
                    }
                }

                Item { Layout.fillWidth: true }
            }

            // 底线
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: subtleBorder
            }
        }

        // ── 内容区 ──
        StackLayout {
            id: tabStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: 0

            // Tab 0: 详情
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ColumnLayout {
                    width: tabStack.width
                    spacing: 0

                    // 字段行
                    Repeater {
                        model: [
                            { key: "命令名称", value: commandTitle },
                            { key: "所属分组", value: commandGroup },
                            { key: "说明", value: commandDescription || "（无）" }
                        ]

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 52
                            color: index % 2 === 0 ? "#ffffff" : "#fafafa"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 24
                                anchors.rightMargin: 24
                                spacing: 16

                                Label {
                                    text: modelData.key
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    color: textSecondary
                                    Layout.preferredWidth: 100
                                }

                                Label {
                                    text: modelData.value
                                    font.pixelSize: 13
                                    color: textPrimary
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 1
                                color: subtleBorder
                                opacity: 0.5
                            }
                        }
                    }

                    // 命令完整内容
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.leftMargin: 24
                        Layout.rightMargin: 24
                        Layout.topMargin: 20
                        Layout.preferredHeight: Math.max(cmdFullText.implicitHeight + 32, 120)
                        radius: 8
                        color: "#1e1e1e"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                Label {
                                    text: "命令内容"
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                    color: "#9ca3af"
                                    Layout.fillWidth: true
                                }
                                ToolButton {
                                    contentItem: Label {
                                        text: "📋 复制"
                                        font.pixelSize: 11
                                        color: "#9ca3af"
                                    }
                                    background: Rectangle {
                                        radius: 4
                                        color: parent.hovered ? "#374151" : "transparent"
                                    }
                                    onClicked: {
                                        if (CommandManager) {
                                            CommandManager.copyToClipboard(commandContent)
                                            if (copyNotification) {
                                                copyNotification.text = "已复制: " + commandTitle
                                                copyNotification.open()
                                            }
                                        }
                                    }
                                }
                            }

                            TextArea {
                                id: cmdFullText
                                text: commandContent
                                readOnly: true
                                selectByMouse: true
                                wrapMode: TextEdit.Wrap
                                font.family: "Consolas, Courier New, monospace"
                                font.pixelSize: 13
                                color: "#e5e7eb"
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                background: Item {}
                            }
                        }
                    }

                    // 底部留白
                    Item { Layout.preferredHeight: 24 }
                }
            }

            // Tab 1: 说明
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ColumnLayout {
                    width: tabStack.width
                    spacing: 0

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.leftMargin: 24
                        Layout.rightMargin: 24
                        Layout.topMargin: 20
                        Layout.preferredHeight: Math.max(descText.implicitHeight + 32, 200)
                        radius: 8
                        color: cardColor
                        border.color: subtleBorder

                        TextArea {
                            id: descText
                            anchors.fill: parent
                            anchors.margins: 16
                            text: commandDescription || "暂无说明"
                            readOnly: true
                            selectByMouse: true
                            wrapMode: TextEdit.Wrap
                            font.pixelSize: 14
                            color: commandDescription ? textPrimary : textSecondary
                            background: Item {}
                        }
                    }

                    Item { Layout.preferredHeight: 24 }
                }
            }
        }
    }

    // 删除确认对话框
    Popup {
        id: deleteConfirmDialog
        modal: true
        focus: true
        padding: 0
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        parent: Overlay.overlay
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        width: 380
        height: 200

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 120; easing.type: Easing.OutCubic }
            NumberAnimation { property: "scale"; from: 0.96; to: 1.0; duration: 140; easing.type: Easing.OutCubic }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 100; easing.type: Easing.InCubic }
            NumberAnimation { property: "scale"; from: 1.0; to: 0.96; duration: 100; easing.type: Easing.InCubic }
        }

        background: Rectangle {
            radius: 12
            color: "#ffffff"
            border.color: "#E5E7EB"
            border.width: 1
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Rectangle {
                    width: 36; height: 36; radius: 18
                    color: "#FEF2F2"
                    Label {
                        anchors.centerIn: parent
                        text: "⚠"
                        font.pixelSize: 18
                    }
                }
                Label {
                    text: "删除命令"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#111827"
                    Layout.fillWidth: true
                }
            }

            Label {
                text: "确定要删除「" + commandTitle + "」吗？此操作不可撤销。"
                font.pixelSize: 13
                color: "#6B7280"
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Item { Layout.fillWidth: true }

                CButton {
                    text: "取消"
                    theme: "neutral"
                    onClicked: deleteConfirmDialog.close()
                }

                CButton {
                    text: "删除"
                    theme: "danger"
                    onClicked: {
                        if (CommandManager && commandIndex >= 0) {
                            CommandManager.removeCommand(commandIndex)
                            workspace.clear()
                            workspace.commandDeleted()
                        }
                        deleteConfirmDialog.close()
                    }
                }
            }
        }
    }

    // 监听数据变化（编辑后自动刷新）
    Connections {
        target: CommandManager
        function onCommandsChanged() {
            if (!hasActiveCommand) return
            // 刷新当前命令数据
            var cmds = CommandManager.commandsInFolder(commandGroup)
            for (var i = 0; i < cmds.length; i++) {
                if (cmds[i].sourceIndex === commandIndex) {
                    commandTitle = cmds[i].title
                    commandContent = cmds[i].commandContent
                    commandDescription = cmds[i].description || ""
                    return
                }
            }
            // 如果找不到了（被删除），清空
            workspace.clear()
        }
    }
}
