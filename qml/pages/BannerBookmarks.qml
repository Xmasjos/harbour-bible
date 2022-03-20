import QtQuick 2.6
import Sailfish.Silica 1.0
//import Sailfish.Silica.private 1.0

MouseArea {
    id: popup
    z: 10
    width: parent.width
    height: parent.height
    visible: opacity > 0
    opacity: 0.0
    onClicked: {
        hide()
    }
    onOpacityChanged: {
        //listmodel_Bookmarks.clear()
    }

    // UI variables
    property var hideBackColor : Theme.rgba(Theme.overlayBackgroundColor, 0.9)
    property real roundCornersRadius : Theme.paddingLarge
    property bool blockScrolling : Qt.inputMethod.visible

    // suppress blend to main window on this overlay, e.g. for context menu
    property alias __silica_applicationwindow_instance: fakeApplicationWindow
    Item {
        id: fakeApplicationWindow
        // suppresses warnings by context menu
        property var _dimScreen
        property var _undim
        function _undim() {}
        function _dimScreen() {}
    }
    Behavior on opacity {
        FadeAnimator {}
    }

    Rectangle {
        anchors.fill: parent
        color: hideBackColor
        onColorChanged: opacity = 4

        Rectangle {
            id: idBackgroundRectBookmarks
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            width: parent.width
            height: parent.height - anchors.topMargin - Theme.paddingLarge
            radius: Theme.paddingLarge

            SilicaListView {
                anchors.fill: parent

                ScrollBar {
                    id: idScrollBarBookmarks
                    enabled: (blockScrolling === false)
                    labelVisible: true
                    labelModelTag: "bookNameShort"
                    topPadding: (isPortrait) ? (parent.headerItem.height) : 0
                    bottomPadding: (isPortrait) ? (Theme.itemSizeSmall) : 0
                }

                clip: true
                height: contentHeight
                header: Row {
                    width: (isPortrait) ? (parent.width) : (parent.width - roundCornersRadius*2)

                    Item {
                        width: Theme.iconSizeLarge
                        height: Theme.iconSizeLarge
                        Icon {
                            id: idBookmarkSymbol
                            anchors.centerIn: parent
                            rotation: 90
                            source: "image://theme/icon-m-attach?"
                        }
                    }
                    Item {
                        width: parent.width - Theme.iconSizeLarge
                        height: parent.height
                        Label {
                            id: searchField
                            width: parent.width
                            font.pixelSize: Theme.fontSizeMedium
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: (parent.height - idBookmarkSymbol.height) / 2 + Theme.paddingSmall * 1.25
                            text: qsTr("Bookmarks")
                        }
                    }
                }
                footer: Item {
                    width: parent.width
                    height: Theme.itemSizeSmall
                }

                model: listmodel_Bookmarks
                delegate: ListItem {
                    contentHeight: searchItemID.height
                    contentWidth: (idScrollBarBookmarks.visible) ? ( parent.width - roundCornersRadius*2 ) : (parent.width)
                    menu: ContextMenu {
                        x: 0
                        width: (idScrollBarBookmarks.visible) ? ( idBackgroundRectBookmarks.width - roundCornersRadius*2 ) : (idBackgroundRectBookmarks.width)
                        MenuItem {
                            onClicked: {
                                listmodel_Bookmarks.remove(index)
                                updateBookmarksDB_fromList()
                            }
                            Icon {
                                anchors.centerIn: parent
                                source: "image://theme/icon-m-delete?"
                            }
                        }
                    }
                    onClicked: {
                        displayCurrentBookNr = bookNumber
                        displayCurrentBookNameLong = bookNameArray[parseInt(bookNumber) - 1][0] //bookNameLong
                        displayCurrentBookNameShort = bookNameArray[parseInt(bookNumber) - 1][1] //bookNameShort
                        displayCurrentChapterNr = chapterNumber
                        displayCurrentVerseNr = verseNumber
                        generateCurrentChapterText( displayCurrentVerseNr-1, "fromBookmarks" )
                        hide()
                    }

                    Column {
                        id: searchItemID
                        x: Theme.paddingLarge
                        width: (idScrollBarBookmarks.visible) ? ( parent.width - roundCornersRadius*2  - 2 * x) : (parent.width - 2 * x)
                        topPadding: Theme.paddingSmall
                        bottomPadding: Theme.paddingSmall
                        Item {
                            width: parent.width
                            height: Theme.paddingSmall
                        }
                        Label {
                            id: idTestLabel
                            width: parent.width
                            color: Theme.highlightColor
                            wrapMode: Text.WordWrap
                            font.pixelSize: settingsTextsize
                            horizontalAlignment: Text.AlignLeft
                            //text: bookNameLong + " " + chapterNumber + ", " + verseNumber + ":"
                            //text: bookNameArray[parseInt(bookNumber) - 1][0] + " " + chapterNumber + ", " + verseNumber + ":"
                            text: {
                                if (indexCitationStyle === 0) { // harvard full
                                    return bookNameArray[parseInt(bookNumber) - 1][0] + " " + chapterNumber + ", " + verseNumber //+ ":"
                                } else if (indexCitationStyle === 1) { // harvard short
                                    return bookNameArray[parseInt(bookNumber) - 1][1] + " " + chapterNumber + ", " + verseNumber //+ ":"
                                } else if (indexCitationStyle === 2) { // chicago long
                                    return bookNameArray[parseInt(bookNumber) - 1][0] + " " + chapterNumber + ":" + verseNumber //+ ":"
                                } else { // chicago short
                                    return bookNameArray[parseInt(bookNumber) - 1][1] + " " + chapterNumber + ":" + verseNumber //+ ":"
                                }
                            }
                        }
                        Label {
                            width: parent.width
                            color: Theme.primaryColor
                            wrapMode: Text.WordWrap
                            font.pixelSize: settingsTextsize
                            text: verseText1
                        }
                        Item {
                            width: parent.width
                            height: Theme.paddingSmall
                        }
                    }
                }
            }
        }
    }



    function notify( color, upperMargin ) {
        // color settings
        if (color && (typeof(color) != "undefined")) {
            idBackgroundRectBookmarks.color = color
        }
        else {
            idBackgroundRectBookmarks.color = Theme.rgba(Theme.highlightBackgroundColor, 0.9)
        }
        // position settings
        if (upperMargin && (typeof(upperMargin) != "undefined")) {
            idBackgroundRectBookmarks.anchors.topMargin = upperMargin
        }
        else {
            idBackgroundRectBookmarks.anchors.topMargin = 0
        }
        // show banner overlay
        show()
    }

    function show() { popup.opacity = 1.0 }

    function hide() { popup.opacity = 0.0 }
}

