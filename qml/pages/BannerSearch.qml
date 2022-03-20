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
    onOpacityChanged: {
        //console.log("Test")
    }

    // own variables
    property var hideBackColor : Theme.rgba(Theme.overlayBackgroundColor, 0.9)
    property string searchwords : ""
    property int totalFilteredCounter : idListViewSearchResults.count -1 //-1 because of added alibi listItem to not confuse custom scrollBar height on empty lists
    property bool pageEntered
    property bool blockScrolling : Qt.inputMethod.visible
    property real roundCornersRadius : Theme.paddingLarge

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
    Timer {
        // needed to slide down keyboard
        id: idTimerDelaySearch
        interval: 500
        repeat: false
        onTriggered: {
            createSearchResultsModel()
        }
    }
    Rectangle {
        anchors.fill: parent
        color: hideBackColor

        Rectangle {
            id: idBackgroundRectSearch
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            width: parent.width
            height: parent.height - anchors.topMargin - Theme.paddingLarge
            radius: roundCornersRadius

            SilicaListView {
                id: idListViewSearchResults
                quickScroll: false

                ScrollBar {
                    id: idScrollBarSearch
                    enabled: (blockScrolling === false)
                    labelVisible: (currentSearchList === "bible")
                    topPadding: (isPortrait) ? idListViewSearchResults.headerItem.height : 0
                    bottomPadding: (isPortrait) ? Theme.itemSizeSmall : 0
                    labelModelTag: "bookNameShort"
                    // dirty bugfix for scrollBar position
                    listcountMax: (totalFilteredCounter !== undefined) ? totalFilteredCounter : 0
                }

                anchors.fill: parent
                clip: true
                interactive: (blockScrolling === false)
                height: contentHeight
                header: Column {
                    id: idSearchHeader
                    width: (isPortrait) ? (parent.width) : (parent.width - roundCornersRadius*2)

                    Item {
                        width: parent.width
                        height: searchField.height

                        SearchField {

                            Item {
                                id: idWatchdog_pageEntered
                                enabled: ( pageEntered === true ) ? true : false
                                onEnabledChanged: {
                                    if ( enabled === true && searchField.text.length === 0 ) { // on_enter
                                        searchField.forceActiveFocus()
                                    }
                                    if ( enabled === false ) { // on exit
                                        searchField.focus = false
                                    }
                                }
                            }

                            id: searchField
                            canHide: false
                            enabled: searchingActive === false
                            width: parent.width
                            placeholderText: qsTr("type here")
                            placeholderColor: Theme.secondaryHighlightColor
                            focus: true
                            font.pixelSize: Theme.fontSizeMedium //settingsTextsize
                            EnterKey.onClicked: {
                                focus = false
                                searchwords = searchField.text
                                searchingActive = true
                                listmodel_SearchResultsBible.clear()
                                listmodel_SearchResultsBook.clear()
                                listmodel_SearchResultsChapter.clear()
                                //... 500ms needed for keyboard to slide down
                                idTimerDelaySearch.start()
                                //createSearchResultsModel()
                            }
                        }
                        BusyIndicator {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.iconSizeMedium / 2 - Theme.paddingSmall / 3
                            running: (searchingActive === true)
                        }
                    }
                    Row {
                        width: parent.width
                        leftPadding: Theme.paddingLarge
                        rightPadding: leftPadding
                        height: Theme.iconSizeMedium * 1.2
                        enabled: searchingActive === false

                        IconButton {
                            id: idFilterLabel1
                            width: (parent.width - 2*parent.leftPadding) / 3
                            height: parent.height
                            down: currentSearchList === "bible"
                            onClicked: {
                                currentSearchList = "bible"
                            }

                            Label {
                                width: parent.width
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignLeft
                                font.pixelSize: Theme.fontSizeExtraSmall
                                text: qsTr("Complete Bible") + "\n"
                            }
                        }
                        IconButton {
                            id: idFilterLabel2
                            width: (parent.width - 2*parent.leftPadding) / 3
                            height: parent.height
                            down: currentSearchList === "book"
                            onClicked: {
                                currentSearchList = "book"
                            }

                            Label {
                                width: parent.width
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignHCenter
                                font.pixelSize: Theme.fontSizeExtraSmall
                                text: (currentChapterOnSearch === 0) ? (qsTr("Current Book") + "\n") : (currentBookOnSearch + "\n")
                            }
                        }
                        IconButton {
                            id: idFilterLabel3
                            width: (parent.width - 2*parent.leftPadding) / 3
                            height: parent.height
                            down: currentSearchList === "chapter"
                            onClicked: {
                                currentSearchList = "chapter"
                            }

                            Label {
                                width: parent.width
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignRight
                                font.pixelSize: Theme.fontSizeExtraSmall
                                text: (currentChapterOnSearch === 0) ? (qsTr("Current Chapter") + "\n") : (qsTr("Chapter") + " " + currentChapterOnSearch + "\n")
                            }
                        }
                    }
                }

                model: {
                    if (currentSearchList === "bible") {
                        return listmodel_SearchResultsBible
                    }
                    else if (currentSearchList === "book") {
                        return listmodel_SearchResultsBook
                    }
                    else { //currentSearchList === "chapter"
                        return listmodel_SearchResultsChapter
                    }
                }
                delegate: ListItem {
                    visible: (bookNumber !== 9999) //for there is one last alibi item at end of list, see dirty hack
                    contentHeight: searchItemID.height
                    contentWidth: (idScrollBarSearch.visible) ? ( (blockScrolling === false) ? (parent.width - roundCornersRadius*2) : (parent.width) ) : (parent.width)
                    onClicked: {
                        displayCurrentBookNr = bookNumber
                        displayCurrentBookNameLong = bookNameLong
                        displayCurrentBookNameShort = bookNameShort
                        displayCurrentChapterNr = chapterNumber
                        displayCurrentVerseNr = verseNumber
                        generateCurrentChapterText( displayCurrentVerseNr-1, "fromSearch" )
                        hide()
                    }

                    MouseArea {
                        // prevents clicking or scrolling items when keyboard is open
                        preventStealing: true
                        anchors.fill: parent
                        enabled: (blockScrolling === true)
                    }
                    Column {
                        id: searchItemID
                        x: Theme.paddingLarge
                        width: (idScrollBarSearch.visible) ? ( (blockScrolling === false) ? (parent.width - 2*x) : (parent.width - 2*x - roundCornersRadius*2) ) : (parent.width - 2*x)
                        topPadding: Theme.paddingSmall
                        bottomPadding: Theme.paddingSmall

                        Label {
                            width: parent.width
                            color: Theme.highlightColor
                            wrapMode: Text.WordWrap
                            font.pixelSize: settingsTextsize
                            horizontalAlignment: Text.AlignLeft
                            //text: (index+1) + "/" + totalFilteredCounter + " - " + bookNameLong + " " + chapterNumber + ", " + verseNumber + ":"
                            text: {
                                if (indexCitationStyle === 0) { // harvard full
                                    return (index+1) + "/" + totalFilteredCounter + " - " + bookNameLong + " " + chapterNumber + ", " + verseNumber
                                } else if (indexCitationStyle === 1) { // harvard short
                                    return (index+1) + "/" + totalFilteredCounter + " - " + bookNameShort + " " + chapterNumber + ", " + verseNumber
                                } else if (indexCitationStyle === 2) { // chicago long
                                    return (index+1) + "/" + totalFilteredCounter + " - " + bookNameLong + " " + chapterNumber + ":" + verseNumber
                                } else { // chicago short
                                    return (index+1) + "/" + totalFilteredCounter + " - " + bookNameShort + " " + chapterNumber + ":" + verseNumber
                                }
                            }

                        }
                        Label {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            font.pixelSize: settingsTextsize
                            text: verseText1
                        }
                    }

                }
            }
        }
    }


    function createSearchResultsModel() {
        // in case German keyboard uses double quotes... make it international single quotes
        searchwords = searchwords.replace('"', "'")
         // get individual searchwords from monolithic search string
        var searchWordsList = (searchwords.toLowerCase()).split(/(?=(?:(?:[^']*'){2})*[^']*$)\s+/)
        // remove outer single quotas if still present
        for (var k = 0; k < searchWordsList.length; k++ ) {
            if ( searchWordsList[k].slice(0,1) === "'" && searchWordsList[k].slice(-1) === "'" ) {
                    searchWordsList[k] = searchWordsList[k].substring(1)
                    searchWordsList[k] = searchWordsList[k].substring(0, searchWordsList[k].length - 1)
                }
        }
        py.findVerses( searchWordsList, displayCurrentBookNr, displayCurrentChapterNr )
    }

    function checkContainsWords(tmpCurrentVerseText, searchWordsList) {
        var found = true
        for ( var j = 0; j < searchWordsList.length; j++) {
            if ( ((tmpCurrentVerseText.toLowerCase()).indexOf(searchWordsList[j])) === -1  ) {
                found = false;
            }
        }
        return found
    }

    function notify( color, upperMargin ) {
        // color settings
        if (color && (typeof(color) != "undefined")) {
            idBackgroundRectSearch.color = color
        }
        else {
            idBackgroundRectSearch.color = Theme.rgba(Theme.highlightBackgroundColor, 0.9)
        }
        // position settings
        if (upperMargin && (typeof(upperMargin) != "undefined")) {
            idBackgroundRectSearch.anchors.topMargin = upperMargin
        }
        else {
            idBackgroundRectSearch.anchors.topMargin = 0
        }
        // show banner overlay
        show()
    }

    function show() {
        popup.opacity = 1.0
        pageEntered = true // see watchdog -> maybe show keyboard
    }

    function hide() {
        pageEntered = false // see watchdog -> hide keyboard
        popup.opacity = 0.0
    }
}

