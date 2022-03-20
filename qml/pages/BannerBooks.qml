import QtQuick 2.6
import Sailfish.Silica 1.0


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

    // UI variables
    property var hideBackColor : Theme.rgba(Theme.overlayBackgroundColor, 0.9)
    property var maxColumns : (isPortrait) ? 7 : 14
    property var designPickerLayout
    property bool chaptersActiveHideBooks

    // variables to pass back to FirstPage.qml
    property var tmpCurrentBookNumber
    property var tmpCurrentBookNameShort
    property var tmpCurrentBookNameLong
    property var tmpCurrentBookChaptersAll

    onOpacityChanged: { // slow reload when loaded again after settings changed ... ToDo: load on opening
        chaptersActiveHideBooks = false
        listmodel_ChaptersOverview.clear()
    }

    Behavior on opacity {
        FadeAnimator {}
    }
    ListModel {
        id: listmodel_ChaptersOverview
    }
    Rectangle {
        anchors.fill: parent
        color: hideBackColor

        Rectangle {
            id: idBackgroundRectBooks
            visible: chaptersActiveHideBooks === false
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            width: parent.width // - 2*Theme.paddingMedium
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingLarge
            //anchors.bottomMargin: (isPortrait && height < parent.height) ? ( Theme.paddingLarge * 5) : 0
            radius: Theme.paddingLarge

            SilicaListView {
                id: idListViewBooksLongname
                visible: designPickerLayout === "list"
                anchors.fill: parent
                clip: true
                height: contentHeight
                model: listmodel_BooksOverview

                VerticalScrollDecorator {}

                delegate: ListItem {
                    contentHeight: (bookNumber === 9999) ? 0 : Theme.itemSizeExtraSmall
                    contentWidth: parent.width - 2* idBackgroundRectBooks.radius
                    contentX: idBackgroundRectBooks.radius
                    onClicked: {
                        if (bookNumber !== 0 && bookNumber !== 9999 ) {
                            tmpCurrentBookNumber = bookNumber
                            tmpCurrentBookNameLong = longName
                            tmpCurrentBookNameShort = shortName
                            tmpCurrentBookChaptersAll = bookChapters
                            chaptersActiveHideBooks = true
                            createChapterModel()
                        }
                    }
                    Label {
                        text: longName
                        color: ( bookNumber === 0 ) ? Theme.errorColor : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        truncationMode: TruncationMode.Fade
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            SilicaGridView {
                id: idListViewBooksShortname
                visible: designPickerLayout === "grid"
                anchors.fill: parent
                clip: true
                width: parent.width
                height: contentHeight
                cellWidth: parent.width / maxColumns - Theme.paddingSmall / maxColumns
                cellHeight: cellWidth
                model: listmodel_BooksOverview

                VerticalScrollDecorator {}

                delegate: ListItem {
                    contentX: Theme.paddingSmall
                    contentWidth:  parent.width / maxColumns - Theme.paddingSmall
                    contentHeight: contentWidth
                    onClicked: {
                        if ( bookNumber !== 0 && bookNumber !== 9999 ) {
                            tmpCurrentBookNumber = bookNumber
                            tmpCurrentBookNameLong = longName
                            tmpCurrentBookNameShort = shortName
                            tmpCurrentBookChaptersAll = bookChapters
                            chaptersActiveHideBooks = true
                            createChapterModel()
                        }
                    }

                    Label {
                        text: shortName
                        color: ( bookNumber === 0 ) ? Theme.errorColor : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        truncationMode: TruncationMode.Elide //Fade
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }

        Rectangle {
            id: idBackgroundRectChapters
            visible: chaptersActiveHideBooks === true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            width: parent.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingLarge
            radius: Theme.paddingLarge

            SilicaGridView {
                id: idListViewChapters
                anchors.fill: parent
                clip: true
                width: parent.width
                height: contentHeight
                cellWidth: parent.width / maxColumns - Theme.paddingSmall / maxColumns
                cellHeight: cellWidth
                model: listmodel_ChaptersOverview

                VerticalScrollDecorator {}

                delegate: ListItem {
                    contentX: Theme.paddingSmall
                    contentWidth:  parent.width / maxColumns - Theme.paddingSmall
                    contentHeight: contentWidth
                    onClicked: {
                        storageItem.setSettings("chosenBookNumber", tmpCurrentBookNumber)
                        storageItem.setSettings("chosenBookLongname", tmpCurrentBookNameLong)
                        storageItem.setSettings("chosenBookShortname", tmpCurrentBookNameShort)
                        storageItem.setSettings("chosenBookChapters", tmpCurrentBookChaptersAll)
                        storageItem.setSettings("chosenChapterNumber", chapterNumber)

                        displayCurrentBookNr = tmpCurrentBookNumber
                        displayCurrentBookNameLong = tmpCurrentBookNameLong
                        displayCurrentBookNameShort = tmpCurrentBookNameShort
                        displayCurrentChapterNr = chapterNumber

                        generateCurrentChapterText( 0 )
                        hide()
                    }
                    Label {
                        text: chapterNumber
                        font.pixelSize: Theme.fontSizeSmall
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }

    function createChapterModel() {
        for (var i = 1; i <= tmpCurrentBookChaptersAll ; i++) {
            listmodel_ChaptersOverview.append({ chapterNumber : i })
        }
    }
    function notify( color, upperMargin, designPicker ) {
        // color settings
        if (color && (typeof(color) != "undefined")) {
            idBackgroundRectBooks.color = color
            idBackgroundRectChapters.color = color
        }
        else {
            idBackgroundRectBooks.color = Theme.rgba(Theme.highlightDimmerColor, 1)
            idBackgroundRectChapters.color  = Theme.rgba(Theme.highlightDimmerColor, 1)
        }
        // position settings
        if (upperMargin && (typeof(upperMargin) != "undefined")) {
            idBackgroundRectBooks.anchors.topMargin = upperMargin
            idBackgroundRectChapters.anchors.topMargin = upperMargin
        }
        else {
            idBackgroundRectBooks.anchors.topMargin = 0
            idBackgroundRectChapters.anchors.topMargin = 0
        }
        // book picker layout settings
        if (designPicker && (typeof(designPicker) != "undefined")) {
             designPickerLayout = designPicker
        }
        else {
            idBackgroundRectBooks.anchors.topMargin = 0
            designPickerLayout = storageItem.getSettings("bookSelectorLayout", "grid") // "list"
        }
        // show banner overlay
        show()
    }
    function show() { popup.opacity = 1.0 }
    function hide() {
        popup.opacity = 0.0

    }
}

