import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0 // File-Loader



Dialog {
    id: pageSettings
    allowedOrientations: Orientation.Portrait
    canAccept: finishedLoadingSettings
    onDone: {
        if (result == DialogResult.Accepted) {
            writeDB_Settings()
            if (changedPath1 === true || changedPath2 === true) {
                listmodel_CurrentChapter_Bible.clear()
                py.parseXML_File( tempFilePath1, tempFilePath2, "full", "cleanUp" )
            } else if (changedSplitscreen === true) {
                generateCurrentChapterText( 0, "fromSettings" )
            }
        }
    }

    onOpened: {
        if (storageItem.getSettings( "splitscreenBibles", "one") === "one" ) {
            idComboBoxParallelBibles.currentIndex = 0
        } else {
            idComboBoxParallelBibles.currentIndex = 1
        }
        selectorColorscheme.currentIndex = Number(storageItem.getSettings("indexSelectorColorscheme", 0))
        selectorMenuEmphasis.currentIndex = Number(storageItem.getSettings("indexMenuEmphasis", 0))
        selectorTextsize.currentIndex = Number(storageItem.getSettings("indexSelectorTextsize", 1))
        if ( storageItem.getSettings("bookSelectorLayout", "grid") === "grid") {
            selectorBooklist.currentIndex = 0
        } else {
            selectorBooklist.currentIndex = 1
        }
        selectorPositionConvention.currentIndex = Number( storageItem.getSettings("citationStyle", 0) )
        selectorBlankingPreventor.currentIndex = Number(storageItem.getSettings( 'screenBlanking', 0 ))
        selectorShowNotes.currentIndex = Number(storageItem.getSettings("showNotes", 0))
    }

    // from firstPage, reset changedPaths to false
    property bool changedPath1
    property bool changedPath2
    property bool changedSplitscreen

    Component {
       id: fontPickerPage

       FilePickerPage {
           title: qsTr("Select font")
           nameFilters: [ '*.ttf', '*.otf' ]
           onSelectedContentPropertiesChanged: {
               tempFontPath = selectedContentProperties.filePath
               tempFontName = selectedContentProperties.fileName
           }
       }
    }
    Component {
       id: filePickerPage1

       FilePickerPage {
           title: qsTr("Load ZefaniaXML Bible #1")
           nameFilters: [ '*.xml' ]
           onSelectedContentPropertiesChanged: {
               finishedLoadingSettings = false
               changedPath1 = true
               tempFilePath1 = selectedContentProperties.filePath
               py.parseXML_File( tempFilePath1, tempFilePath2, "preview", "cleanUp" )
           }
       }
    }
    Component {
       id: filePickerPage2

       FilePickerPage {
           title: qsTr("Load ZefaniaXML Bible #2")
           nameFilters: [ '*.xml' ]
           onSelectedContentPropertiesChanged: {
               finishedLoadingSettings = false
               changedPath2 = true
               tempFilePath2 = selectedContentProperties.filePath
               py.parseXML_File( tempFilePath1, tempFilePath2, "preview", "cleanUp" )
           }
       }
    }

    SilicaFlickable{
        anchors.fill: parent
        contentHeight: column.height // tell overall height

        Column {
            id: column
            width: pageSettings.width
            //spacing: Theme.paddingLarge

            DialogHeader {
                //title: qsTr("Settings")
            }
            Row {
                width: parent.width

                Label {
                    id: idLabelSettingsHeader
                    width: parent.width / 5 * 4
                    leftPadding: Theme.paddingLarge  + Theme.paddingSmall
                    font.pixelSize: Theme.fontSizeExtraLarge
                    color: Theme.highlightColor
                    text: qsTr("Settings")
                }
                IconButton {
                    width: parent.width / 5
                    height: parent.height
                    anchors.verticalCenter: idLabelSettingsHeader.verticalCenter
                    icon.color: (idBusyIndicator.running) ? "transparent" : Theme.highlightColor
                    icon.scale: 1.1
                    icon.source: "image://theme/icon-m-about?"
                    onClicked: {
                        pageStack.animatorPush(Qt.resolvedUrl("AboutPage.qml"), {})
                    }

                    BusyIndicator {
                        id: idBusyIndicator
                        anchors.centerIn: parent
                        visible: running
                        size: BusyIndicatorSize.Medium * 1.25
                        running: finishedLoadingSettings === false
                    }
                }
            }
            Item {
                width: parent.width
                height: Theme.paddingLarge
            }

            Row {
                width: parent.width

                ComboBox {
                    id: idComboBoxParallelBibles
                    width: parent.width // 7 * 6
                    label: qsTr("Bibles")
                    currentIndex: (storageItem.getSettings( "splitscreenBibles", "one") === "one" ) ? 0 : 1
                    menu: ContextMenu {
                        MenuItem { text: qsTr("single - fullscreen") }
                        MenuItem { text: qsTr("dual - splitscreen") }
                    }
                    onCurrentIndexChanged: {
                        if (currentIndex === 0) {
                            changedSplitscreen = false
                        }
                        else if (currentIndex === 1) {
                            changedSplitscreen = true
                        }
                    }
                }
            }
            Item {
                width: parent.width
                height: Theme.paddingLarge
            }
            Row {
                x: Theme.paddingLarge  + Theme.paddingSmall
                width: parent.width - 2*x
                spacing: Theme.paddingLarge

                Label {
                    id: selectorBible1
                    width: (idComboBoxParallelBibles.currentIndex === 0) ? (parent.width) : (parent.width / 2 - parent.spacing / 2  )
                    color: Theme.highlightColor
                    truncationMode: TruncationMode.Fade //Elide
                    text: tempFileTitle1

                    MouseArea {
                        anchors.fill: parent
                        onClicked: pageStack.push(filePickerPage1)
                    }
                }
                Label {
                    id: selectorBible2
                    visible: idComboBoxParallelBibles.currentIndex !== 0
                    width: (parent.width / 2 - Theme.paddingLarge / 2)
                    color: Theme.highlightColor
                    truncationMode: TruncationMode.Fade //Elide
                    text: tempFileTitle2

                    MouseArea {
                        anchors.fill: parent
                        onClicked: pageStack.push(filePickerPage2)
                    }
                }
            }
            Row {
                x: Theme.paddingLarge + Theme.paddingSmall
                width: parent.width - 2*x
                spacing: Theme.paddingLarge

                Label {
                    id: selectorBible1Label
                    visible: true
                    width: (idComboBoxParallelBibles.currentIndex === 0) ? (parent.width) : (parent.width / 2 - parent.spacing / 2)
                    wrapMode: TextEdit.Wrap
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: qsTr("Language") + ": " + tempFileLanguage1
                        + "\n" + qsTr("Date") + ": " + tempFileDate1
                        + "\n" + qsTr("Version") + ": " + tempFileVersion1
                        + "\n" + qsTr("Path") + ": " + tempFilePath1
                }
                Label {
                    id: selectorBible2Label
                    visible: (idComboBoxParallelBibles.currentIndex === 1)
                    width: (parent.width / 2 - parent.spacing / 2)
                    wrapMode: TextEdit.Wrap
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: qsTr("Language") + ": " + tempFileLanguage2
                        + "\n" + qsTr("Date") + ": " + tempFileDate2
                        + "\n" + qsTr("Version") + ": " + tempFileVersion2
                        + "\n" + qsTr("Path") + ": " + tempFilePath2
                }
            }
            Row {
                visible: tempWarningIntegrityFile1 || tempWarningIntegrityFile2
                x: Theme.paddingLarge + Theme.paddingSmall
                width: parent.width - 2*x
                spacing: Theme.paddingLarge

                Label {
                    id: warningBible1Label
                    width: (idComboBoxParallelBibles.currentIndex === 0) ? (parent.width) : (parent.width / 2 - parent.spacing / 2)
                    wrapMode: TextEdit.Wrap
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.errorColor
                    text: tempWarningIntegrityFile1 ? qsTr("file integrity error") : ""
                }
                Label {
                    id: warningBible2Label
                    visible: (idComboBoxParallelBibles.currentIndex === 1)
                    width: (parent.width / 2 - parent.spacing / 2)
                    wrapMode: TextEdit.Wrap
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.errorColor
                    text: tempWarningIntegrityFile2 ? qsTr("file integrity error") : ""
                }
            }
            Item {
                width: parent.width
                height: Theme.paddingLarge * 1.5
            }
            ComboBox {
                id: selectorColorscheme
                width: parent.width
                label: qsTr("Theme")
                currentIndex: Number(storageItem.getSettings("indexSelectorColorscheme", 0))
                menu: ContextMenu {
                    Repeater {
                        model: colorSchemes
                        MenuItem {
                            text: colorSchemes[index][0]
                            Rectangle {
                                anchors.fill: parent
                                color: colorSchemes[index][1]
                                opacity: 1
                            }
                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                color: (colorSchemes[index][2] !== "theme") ? colorSchemes[index][2] : Theme.primaryColor
                                text: parent.text
                            }
                        }
                    }
                }
            }
            ComboBox {
                id: selectorMenuEmphasis
                width: parent.width
                label: qsTr("Menu")
                currentIndex: Number(storageItem.getSettings("indexMenuEmphasis", 0))
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("standard")
                    }
                    MenuItem {
                        text: qsTr("highlighted")
                    }
                }
            }
            ComboBox {
                id: selectorTextsize
                width: parent.width
                label: qsTr("Fontsize")
                currentIndex: Number(storageItem.getSettings("indexSelectorTextsize", 1))
                menu: ContextMenu {
                    MenuItem {
                        id: item_0
                        font.pixelSize: Theme.fontSizeTiny
                        text: qsTr("tiny")
                    }
                    MenuItem {
                        id: item_1
                        font.pixelSize: Theme.fontSizeExtraSmall
                        text: qsTr("extra small")
                    }
                    MenuItem {
                        id: item_2
                        font.pixelSize: Theme.fontSizeSmall
                        text: qsTr("small")
                    }
                    MenuItem {
                        id: item_3
                        font.pixelSize: Theme.fontSizeMedium
                        text: qsTr("medium")
                    }
                    MenuItem {
                        id: item_4
                        font.pixelSize: Theme.fontSizeLarge
                        text: qsTr("large")
                    }
                }
            }
            Row {
                width: parent.width

                ComboBox {
                    id: selectorFont
                    width: (currentIndex === 0) ? parent.width : ( parent.width / 2 - Theme.paddingMedium - Theme.paddingSmall)
                    label: qsTr("Font")
                    currentIndex: currentFontIndex //Number( storageItem.getSettings("indexSelectorFont", 0))
                    menu: ContextMenu {
                        MenuItem {
                            text: qsTr("Sailfish")
                        }
                        MenuItem {
                            text: qsTr("custom")
                       }
                    }
                }
                ValueButton {
                    visible: selectorFont.currentIndex === 1
                    width: parent.width / 2 + Theme.paddingMedium + Theme.paddingSmall
                    labelColor: Theme.highlightColor
                    label: tempFontName
                    onClicked: {
                        pageStack.push(fontPickerPage)
                    }
                }
            }
            ComboBox {
                id: selectorBooklist
                width: parent.width
                label: qsTr("Layout books")
                currentIndex: ( storageItem.getSettings("bookSelectorLayout", "grid") === "grid") ? 0 : 1
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("grid")
                    }
                    MenuItem {
                        text: qsTr("list")
                   }
                }
            }
            ComboBox {
                id: selectorPositionConvention
                width: parent.width
                label: qsTr("Citation Style")
                currentIndex: Number( storageItem.getSettings("citationStyle", 0) )
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Harvard long")
                    }
                    MenuItem {
                        text: qsTr("Harvard short")
                    }
                    MenuItem {
                        text: qsTr("Chicago long")
                    }
                    MenuItem {
                        text: qsTr("Chicago short")
                    }
                }
            }
            ComboBox {
                id: selectorBlankingPreventor
                width: parent.width
                label: qsTr("Screen blanking")
                currentIndex: Number(storageItem.getSettings( 'screenBlanking', 0 ))
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("system")
                    }
                    MenuItem {
                        text: qsTr("disabled")
                   }
                }
            }
            ComboBox {
                id: selectorShowNotes
                width: parent.width
                label: qsTr("Notes (beta)")
                currentIndex: Number(storageItem.getSettings("showNotes", 0))
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("off")
                    }
                    MenuItem {
                        text: qsTr("on")
                   }
                }
            }

            Item {
                visible: formerDB_BookmarksAvailable
                width: parent.width
                height: Theme.paddingLarge * 1.5
            }
            Button {
                id: idButtonOldDB
                visible: formerDB_BookmarksAvailable
                x: Theme.paddingLarge  + Theme.paddingSmall
                width: parent.width - 2*x
                text: qsTr("Restore former DB Bookmarks")
                onClicked: py.findOldDatabaseBookmarks()
            }
        }
    }




    // ******************************************** important functions ******************************************** //

    function writeDB_Settings() {

        //storageItem.removeFullTable( 'settings_table' )
        if ( idComboBoxParallelBibles.currentIndex === 0 ) { settingsSplitscreenBibles = "one" }
        else if ( idComboBoxParallelBibles.currentIndex === 1 ) { settingsSplitscreenBibles = "two" }
        storageItem.setSettings("splitscreenBibles", settingsSplitscreenBibles)

        storageItem.setSettings("indexSelectorFont", selectorFont.currentIndex )
        storageItem.setSettings("fontName", tempFontName )
        storageItem.setSettings("fontPath", tempFontPath )
        if ( selectorFont.currentIndex === 1 && tempFontPath !== "" ) { //SF standard font
            customFontName = tempFontName
            customFontPath = tempFontPath
            currentFontIndex = 1
            localFont.source = tempFontPath
        }
        else { // normal font
            currentFontIndex = 0
            localFont.source = tempFontPath
        }

        if (selectorTextsize.currentIndex === 0) { settingsTextsize = Theme.fontSizeTiny }
        else if (selectorTextsize.currentIndex === 1) { settingsTextsize = Theme.fontSizeExtraSmall }
        else if (selectorTextsize.currentIndex === 2) { settingsTextsize = Theme.fontSizeSmall }
        else if (selectorTextsize.currentIndex === 3) { settingsTextsize = Theme.fontSizeMedium }
        else if (selectorTextsize.currentIndex === 4) { settingsTextsize = Theme.fontSizeLarge }
        storageItem.setSettings("fontsize", settingsTextsize )

        indexMenuEmphasis = selectorMenuEmphasis.currentIndex
        if (indexMenuEmphasis === 0) {
            upperMenuBackColor = "transparent"
        }
        else {
            upperMenuBackColor = Theme.rgba(settingsColorText, 0.1)
        }
        storageItem.setSettings("indexMenuEmphasis", indexMenuEmphasis)
        indexShowNotes = selectorShowNotes.currentIndex
        storageItem.setSettings("showNotes", indexShowNotes)
        indexCitationStyle = selectorPositionConvention.currentIndex
        storageItem.setSettings("citationStyle", indexCitationStyle)

        storageItem.setSettings("indexSelectorColorscheme", selectorColorscheme.currentIndex)
        settingsColorBackground = colorSchemes[selectorColorscheme.currentIndex][1]
        customFontColor = colorSchemes[selectorColorscheme.currentIndex][2]
        customHighlightColor = colorSchemes[selectorColorscheme.currentIndex][3]
        pullBackgroundColor = colorSchemes[selectorColorscheme.currentIndex][4]
        currentBackgroundImagePath = colorSchemes[selectorColorscheme.currentIndex][5]
        var settingsColorText_db = colorSchemes[selectorColorscheme.currentIndex][2]
        if (settingsColorText_db === "theme") {
            settingsColorText = Theme.primaryColor
        } else {
            settingsColorText = settingsColorText_db
        }
        storageItem.setSettings("colorText", settingsColorText_db)
        storageItem.setSettings("colorBackground", settingsColorBackground)
        storageItem.setSettings("indexSelectorTextsize", selectorTextsize.currentIndex)

        if ( selectorBooklist.currentIndex === 0 ) {
            designPickerLayout = "grid"
        } else if ( selectorBooklist.currentIndex === 1 ) {
            designPickerLayout = "list"
        }
        storageItem.setSettings("bookSelectorLayout", designPickerLayout)

        if ( selectorBlankingPreventor.currentIndex === 0 ) {
            displayPreventBlanking = 0
        } else if ( selectorBlankingPreventor.currentIndex === 1 ) {
            displayPreventBlanking = 1
        }
        storageItem.setSettings("screenBlanking", displayPreventBlanking)
        storageItem.setInfos('filePath', tempFilePath1, tempFilePath2)
        filePath1 = tempFilePath1
        filePath2 = tempFilePath2

        // also clear search search results
        listmodel_SearchResultsBible.clear()
        listmodel_SearchResultsBook.clear()
        listmodel_SearchResultsChapter.clear()
    }

}
