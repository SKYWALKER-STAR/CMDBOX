import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import CommandManager 1.0

Menu {
    id: root

    property var contextItem: null
    property string defaultGroupName: ""

    readonly property bool hasContext: contextItem !== null && typeof contextItem !== "undefined"
    readonly property bool isFolder: hasContext && !!contextItem.isFolder
    readonly property bool isAllGroup: isFolder && contextItem.name === "All"

    signal addCommandRequested(string groupName)
    signal addFolderRequested()
    signal viewRequested(var item)
    signal editRequested(var item)
    signal deleteRequested(var item)

    function openFor(item, x, y) {
        contextItem = item
        popup(x, y)
    }

    MenuItem {
        text: "新增命令"
        enabled: !hasContext || isFolder
        onTriggered: root.addCommandRequested(isFolder ? contextItem.name : root.defaultGroupName)
    }

    MenuItem {
        text: "新增分组"
        onTriggered: root.addFolderRequested()
    }

    MenuSeparator { }

    MenuItem {
        text: "查看"
        enabled: hasContext
        onTriggered: root.viewRequested(contextItem)
    }

    MenuItem {
        text: isFolder ? "重命名" : "编辑"
        enabled: hasContext && !isAllGroup
        onTriggered: root.editRequested(contextItem)
    }

    MenuItem {
        text: "删除"
        enabled: hasContext && !isAllGroup
        onTriggered: root.deleteRequested(contextItem)
    }
}
