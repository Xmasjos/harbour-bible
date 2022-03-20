import QtQuick 2.6
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.5
import Nemo.KeepAlive 1.2 // prevent screen blanking posible???
import QtFeedback 5.0 // haptic effects


Page {
    id: page
    allowedOrientations: Orientation.All


    // necessary variables
    property bool finishedLoading : true
    property bool finishedLoadingSettings : true
    property bool searchingActive : false
    property string currentBookOnSearch : ""
    property int currentChapterOnSearch : 0
    property string currentSearchList : "bible"

    property int displayCurrentBookNr : Number(storageItem.getSettings("chosenBookNumber", 1))
    property string displayCurrentBookNameLong : storageItem.getSettings("chosenBookLongname", qsTr("Genesis"))
    property string displayCurrentBookNameShort : storageItem.getSettings("chosenBookShortname", qsTr("Gen"))
    property int displayCurrentChapterNr : Number(storageItem.getSettings("chosenChapterNumber", 1))
    property int displayCurrentVerseNr
    property string positionText : (displayCurrentBookNameLong.toString() + " " + displayCurrentChapterNr.toString())
    property int maxChapterCurrentBook
    property var bookNameArray : []
    property var lastChapterPerBook1Array : []
    property var lastChapterPerBook2Array : []
    property bool formerDB_BookmarksAvailable : false
    property int counterDB_Bookmarks : Number(storageItem.getTableCount('bookmarks', 0))
    property int counterDB_Notes : Number(storageItem.getTableCount('notes', 0))
    property string tmpBookmarkString : ""
    property string tmpNotesString : ""
    //property bool activeTypingNotes : (Qt.inputMethod.visible)

    // UI variables
    property string emptyLoadTitle : "[" + qsTr("Load") + "]"
    property int currentFontIndex : Number(storageItem.getSettings("indexSelectorFont", 0))
    property string customFontPath : storageItem.getSettings( 'fontPath', "" )
    property string customFontName : storageItem.getSettings( 'fontName', emptyLoadTitle )
    property int settingsTextsize : storageItem.getSettings("fontsize", Theme.fontSizeSmall)
    property int indexMenuEmphasis : Number(storageItem.getSettings("indexMenuEmphasis", 0))
    property int indexShowNotes : Number(storageItem.getSettings("showNotes", 0))
    property int indexCitationStyle : Number(storageItem.getSettings("citationStyle", 0)) //Harvard long = German
    property bool warningIntegrityFile1 : false
    property bool warningIntegrityFile2 : false
    property bool tempWarningIntegrityFile1 : false
    property bool tempWarningIntegrityFile2 : false

    property string settingsColorBackground : storageItem.getSettings("colorBackground", "transparent")
    property string settingsColorText : ( storageItem.getSettings("colorText", "theme") === "theme" ) ? (Theme.primaryColor) : (storageItem.getSettings("colorText", Theme.primaryColor))
    property string settingsSplitscreenBibles : storageItem.getSettings("splitscreenBibles", "one")
    property string designPickerLayout : storageItem.getSettings("bookSelectorLayout", "grid") // "list"
    property int displayPreventBlanking : Number(storageItem.getSettings( 'screenBlanking', 0 )) // 0=system blanking ON | 1=blanking disabled OFF
    property int indexColorScheme : Number(storageItem.getSettings("indexSelectorColorscheme", 0))
    property var colorSchemes : [
        // name,                background,     font,       highlightColor,         highlightPullmenuColor,             imagapath
        [qsTr("system"),        "transparent",  "theme",    Theme.highlightColor,   Theme.highlightBackgroundColor,     ""],
        [qsTr("dark page"),     "black",        "white",    Theme.highlightColor,   Theme.highlightBackgroundColor,     ""],
        [qsTr("light page"),    "antiquewhite", "black",    "darkBlue",             "darkBlue",                         ""],
        [qsTr("qatar"),         "#54042b",      "white",    "#eb7d00",              "#eb7d00",                          ""],
        [qsTr("pastel"),        "#e6f5f5",      "#605366",  "#bd71a3",              "#bd71a3",                          ""],
        [qsTr("teal"),          "#aeeeee",      "black",    "#6e3f11",              "#6e3f11",                          ""],
        [qsTr("old paper"),     "transparent",  "black",    "black",                Theme.highlightBackgroundColor,     "../artwork/paper_old.jpg"],
        [qsTr("ivory paper"),   "transparent",  "black",    "black",                Theme.highlightBackgroundColor,     "../artwork/paper_ivory.jpg"],
        [qsTr("grain paper"),   "transparent",  "black",    "black",                Theme.highlightBackgroundColor,     "../artwork/paper_grain.jpg"],
    ]
    property color customFontColor : colorSchemes[indexColorScheme][2]
    property color customHighlightColor : colorSchemes[indexColorScheme][3]
    property string pullBackgroundColor : colorSchemes[indexColorScheme][4]
    property string currentBackgroundImagePath : colorSchemes[indexColorScheme][5]
    property color upperMenuBackColor : (indexMenuEmphasis === 0) ? "transparent" : Theme.rgba(settingsColorText, 0.1)

    // metadata
    property string filePath1 : storageItem.getInfos('filePath', 'translation1_info', "n/a")
    property string filePath2 : storageItem.getInfos('filePath', 'translation2_info', "n/a")
    property string bibleName1
    property string bibleVersion1
    property string bibleDate1
    property string bibleLanguage1
    property string bibleName2
    property string bibleVersion2
    property string bibleDate2
    property string bibleLanguage2

    // temp preview variables
    property string tempFilePath1 : filePath1
    property string tempFileTitle1 : (bibleName1.length > 0) ? bibleName1 : emptyLoadTitle
    property string tempFileLanguage1 : bibleLanguage1
    property string tempFileDate1 : bibleDate1
    property string tempFileVersion1 : bibleVersion1
    property string tempFilePath2 : filePath2
    property string tempFileTitle2 : (bibleName2.length > 0) ? bibleName2 : emptyLoadTitle
    property string tempFileLanguage2 : bibleLanguage2
    property string tempFileDate2 : bibleDate2
    property string tempFileVersion2 : bibleVersion2
    property string tempFontPath : customFontPath
    property string tempFontName : customFontName

    // autostart
    Component.onCompleted: {
        firstBootClearDB()
        // create a quick parsable list from model
        for (var i = 0; i < listmodel_BooksOverview.count ; i++) {
            if (listmodel_BooksOverview.get(i).bookNumber !== 0 && listmodel_BooksOverview.get(i).bookNumber !== 9999) {
                bookNameArray.push([listmodel_BooksOverview.get(i).longName, listmodel_BooksOverview.get(i).shortName])
            }
        }
        // update fonts if custom path
        if (currentFontIndex !== 0) {
            localFont.source = customFontPath
        }
        py.parseXML_File( filePath1, filePath2, "full", "cleanUp" )
        generateBookmarkList_FromDB()
        generateNotesList_FromDB()
        // custom db restorer
        py.isFormerDBavailable()
    }


    // items
    HapticsEffect {
        id: rumbleEffect
        attackIntensity: 1.0
        attackTime: 250
        intensity: 1.0
        duration: 100
        fadeTime: 250
        fadeIntensity: 0.0
    }
    DisplayBlanking {
        id: idPreventorScreenBlanking
        preventBlanking: displayPreventBlanking === 1
    }
    FontLoader {
        id: localFont
        onSourceChanged: {
            //console.log("font changed...")
        }
    }

    ListModel {
        id: listmodel_BooksOverview
        // Old Testament

        ListElement {
            longName : qsTr("OLD TESTAMENT")
            shortName : qsTr("OT")
            bookChapters : 0
            bookNumber : 0
        }
        ListElement {
            longName : qsTr("Genesis")
            shortName : qsTr("Gen")
            bookChapters : 50
            bookNumber : 1
        }
        ListElement {
            longName : qsTr("Exodus")
            shortName : qsTr("Exo")
            bookChapters : 40
            bookNumber : 2
        }
        ListElement {
            longName : qsTr("Leviticus")
            shortName : qsTr("Lev")
            bookChapters : 27
            bookNumber : 3
        }
        ListElement {
            longName : qsTr("Numbers")
            shortName : qsTr("Num")
            bookChapters : 36
            bookNumber : 4
        }
        ListElement {
            longName : qsTr("Deuteronomy")
            shortName : qsTr("Deut")
            bookChapters : 34
            bookNumber : 5
        }
        ListElement {
            longName : qsTr("Joshua")
            shortName : qsTr("Josh")
            bookChapters : 24
            bookNumber : 6
        }
        ListElement {
            longName : qsTr("Judges")
            shortName : qsTr("Judg")
            bookChapters : 21
            bookNumber : 7
        }
        ListElement {
            longName : qsTr("Ruth")
            shortName : qsTr("Ruth")
            bookChapters : 4
            bookNumber : 8
        }
        ListElement {
            longName : qsTr("1 Samuel")
            shortName : qsTr("Sam¹")
            bookChapters : 31
            bookNumber : 9
        }
        ListElement {
            longName : qsTr("2 Samuel")
            shortName : qsTr("Sam²")
            bookChapters : 24
            bookNumber : 10
        }
        ListElement {
            longName : qsTr("1 Kings")
            shortName : qsTr("Kgs¹")
            bookChapters : 22
            bookNumber : 11
        }
        ListElement {
            longName : qsTr("2 Kings")
            shortName : qsTr("Kgs²")
            bookChapters : 25
            bookNumber : 12
        }
        ListElement {
            longName : qsTr("1 Chronicles")
            shortName : qsTr("Chr¹")
            bookChapters : 29
            bookNumber : 13
        }
        ListElement {
            longName : qsTr("2 Chronicles")
            shortName : qsTr("Chr²")
            bookChapters : 36
            bookNumber : 14
        }
        ListElement {
            longName : qsTr("Ezra")
            shortName : qsTr("Ezr")
            bookChapters : 10
            bookNumber : 15
        }
        ListElement {
            longName : qsTr("Nehemiah")
            shortName : qsTr("Neh")
            bookChapters : 13
            bookNumber : 16
        }
        ListElement {
            longName : qsTr("Esther")
            shortName : qsTr("Est")
            bookChapters : 10
            bookNumber : 17
        }
        ListElement {
            longName : qsTr("Job")
            shortName : qsTr("Job")
            bookChapters : 42
            bookNumber : 18
        }
        ListElement {
            longName : qsTr("Psalms")
            shortName : qsTr("Ps")
            bookChapters : 150
            bookNumber : 19
        }
        ListElement {
            longName : qsTr("Proverbs")
            shortName : qsTr("Prov")
            bookChapters : 31
            bookNumber : 20
        }
        ListElement {
            longName : qsTr("Ecclesiastes")
            shortName : qsTr("Eccl")
            bookChapters : 12
            bookNumber : 21
        }
        ListElement {
            longName : qsTr("Song of Salomon")
            shortName : qsTr("Song")
            bookChapters : 8
            bookNumber : 22
        }
        ListElement {
            longName : qsTr("Isaiah")
            shortName : qsTr("Isa")
            bookChapters : 66
            bookNumber : 23
        }
        ListElement {
            longName : qsTr("Jeremiah")
            shortName : qsTr("Jer")
            bookChapters : 52
            bookNumber : 24
        }
        ListElement {
            longName : qsTr("Lamentations")
            shortName : qsTr("Lam")
            bookChapters : 5
            bookNumber : 25
        }
        ListElement {
            longName : qsTr("Ezekiel")
            shortName : qsTr("Ezk")
            bookChapters : 48
            bookNumber : 26
        }
        ListElement {
            longName : qsTr("Daniel")
            shortName : qsTr("Dan")
            bookChapters : 12
            bookNumber : 27
        }
        ListElement {
            longName : qsTr("Hosea")
            shortName : qsTr("Hos")
            bookChapters : 14
            bookNumber : 28
        }
        ListElement {
            longName : qsTr("Joel")
            shortName : qsTr("Joel")
            bookChapters : 4
            bookNumber : 29
        }
        ListElement {
            longName : qsTr("Amos")
            shortName : qsTr("Amos")
            bookChapters : 9
            bookNumber : 30
        }
        ListElement {
            longName : qsTr("Obadiah")
            shortName : qsTr("Obad")
            bookChapters : 1
            bookNumber : 31
        }
        ListElement {
            longName : qsTr("Jonah")
            shortName : qsTr("Jon")
            bookChapters : 4
            bookNumber : 32
        }
        ListElement {
            longName : qsTr("Micah")
            shortName : qsTr("Mic")
            bookChapters : 7
            bookNumber : 33
        }
        ListElement {
            longName : qsTr("Nahum")
            shortName : qsTr("Nah")
            bookChapters : 3
            bookNumber : 34
        }
        ListElement {
            longName : qsTr("Habakkuk")
            shortName : qsTr("Hab")
            bookChapters : 3
            bookNumber : 35
        }
        ListElement {
            longName : qsTr("Zephaniah")
            shortName : qsTr("Zeph")
            bookChapters : 3
            bookNumber : 36
        }
        ListElement {
            longName : qsTr("Haggai")
            shortName : qsTr("Hag")
            bookChapters : 2
            bookNumber : 37
        }
        ListElement {
            longName : qsTr("Zechariah")
            shortName : qsTr("Zech")
            bookChapters : 14
            bookNumber : 38
        }
        ListElement {
            longName : qsTr("Malachi")
            shortName : qsTr("Mal")
            bookChapters : 4 // = 3 only for German translations, international versions have some verses from chapter 3 in chapter 4
            bookNumber : 39
        }

        // spacers for GridView
        ListElement {
            longName : qsTr("")
            shortName : qsTr("")
            bookChapters : 0
            bookNumber : 9999
        }
        ListElement {
            longName : qsTr("")
            shortName : qsTr("")
            bookChapters : 0
            bookNumber : 9999
        }

        // New Testament
        ListElement {
            longName : qsTr("NEW TESTAMENT")
            shortName : qsTr("NT")
            bookChapters : 0
            bookNumber : 0
        }
        ListElement {
            longName : qsTr("Matthew")
            shortName : qsTr("Matt")
            bookChapters : 28
            bookNumber : 40
        }
        ListElement {
            longName : qsTr("Mark")
            shortName : qsTr("Mk")
            bookChapters : 16
            bookNumber : 41
        }
        ListElement {
            longName : qsTr("Luke")
            shortName : qsTr("Lk")
            bookChapters : 24
            bookNumber : 42
        }
        ListElement {
            longName : qsTr("John")
            shortName : qsTr("Joh")
            bookChapters : 21
            bookNumber : 43
        }
        ListElement {
            longName : qsTr("Acts")
            shortName : qsTr("Act")
            bookChapters : 28
            bookNumber : 44
        }
        ListElement {
            longName : qsTr("Romans")
            shortName : qsTr("Rom")
            bookChapters : 16
            bookNumber : 45
        }
        ListElement {
            longName : qsTr("1 Corinthians")
            shortName : qsTr("Cor¹")
            bookChapters : 16
            bookNumber : 46
        }
        ListElement {
            longName : qsTr("2 Corinthians")
            shortName : qsTr("Cor²")
            bookChapters : 13
            bookNumber : 47
        }
        ListElement {
            longName : qsTr("Galatians")
            shortName : qsTr("Gal")
            bookChapters : 6
            bookNumber : 48
        }
        ListElement {
            longName : qsTr("Ephesians")
            shortName : qsTr("Eph")
            bookChapters : 6
            bookNumber : 49
        }
        ListElement {
            longName : qsTr("Philippians")
            shortName : qsTr("Phil")
            bookChapters : 4
            bookNumber : 50
        }
        ListElement {
            longName : qsTr("Colossians")
            shortName : qsTr("Col")
            bookChapters : 4
            bookNumber : 51
        }
        ListElement {
            longName : qsTr("1 Thessalonians")
            shortName : qsTr("Thes¹")
            bookChapters : 5
            bookNumber : 52
        }
        ListElement {
            longName : qsTr("2 Thessalonians")
            shortName : qsTr("Thes²")
            bookChapters : 3
            bookNumber : 53
        }
        ListElement {
            longName : qsTr("1 Timothy")
            shortName : qsTr("Tim¹")
            bookChapters : 6
            bookNumber : 54
        }
        ListElement {
            longName : qsTr("2 Timothy")
            shortName : qsTr("Tim²")
            bookChapters : 4
            bookNumber : 55
        }
        ListElement {
            longName : qsTr("Titus")
            shortName : qsTr("Tit")
            bookChapters : 3
            bookNumber : 56
        }
        ListElement {
            longName : qsTr("Philemon")
            shortName : qsTr("Phm")
            bookChapters : 1
            bookNumber : 57
        }
        ListElement {
            longName : qsTr("Hebrews")
            shortName : qsTr("Heb")
            bookChapters : 13
            bookNumber : 58
        }
        ListElement {
            longName : qsTr("James")
            shortName : qsTr("Jas")
            bookChapters : 5
            bookNumber : 59
        }
        ListElement {
            longName : qsTr("1 Peter")
            shortName : qsTr("Pet¹")
            bookChapters : 5
            bookNumber : 60
        }
        ListElement {
            longName : qsTr("2 Peter")
            shortName : qsTr("Pet²")
            bookChapters : 3
            bookNumber : 61
        }
        ListElement {
            longName : qsTr("1 John")
            shortName : qsTr("John¹")
            bookChapters : 5
            bookNumber : 62
        }
        ListElement {
            longName : qsTr("2 John")
            shortName : qsTr("John²")
            bookChapters : 1
            bookNumber : 63
        }
        ListElement {
            longName : qsTr("3 John")
            shortName : qsTr("John³")
            bookChapters : 1
            bookNumber : 64
        }
        ListElement {
            longName : qsTr("Jude")
            shortName : qsTr("Jud")
            bookChapters : 1
            bookNumber : 65
        }
        ListElement {
            longName : qsTr("Revelation")
            shortName : qsTr("Rev")
            bookChapters : 22
            bookNumber : 66
        }
    }
    ListModel {
        id: listmodel_parsedFile1
    }
    ListModel {
        id: listmodel_parsedFile2
    }
    ListModel {
        id: listmodel_CurrentChapter_Bible
    }
    ListModel {
        id: listmodel_Bookmarks
        property string sortColumnName: ""

        onCountChanged: {
            // autosort functions ... get also stored when add or remove item
            sortColumnName = "massIndex"
            quick_sort()

            // create string to search through
            tmpBookmarkString = "|||"
            for (var n = 0; n < listmodel_Bookmarks.count; n++) {
                var tmpBookmarkBookNumber = listmodel_Bookmarks.get(n).bookNumber
                var tmpBookmarkChapterNumber = listmodel_Bookmarks.get(n).chapterNumber
                var tmpBookmarkVerseNumber = listmodel_Bookmarks.get(n).verseNumber
                tmpBookmarkString = tmpBookmarkString + (tmpBookmarkBookNumber + "-" + tmpBookmarkChapterNumber + "-" + tmpBookmarkVerseNumber + "|||")
            }
            //console.log(tmpBookmarkString)
        }
        // auto sort functions
        function swap(a,b) {
            if (a<b) {
                move(a,b,1);
                move (b-1,a,1);
            }
            else if (a>b) {
                move(b,a,1);
                move (a-1,b,1);
            }
        }
        function partition(begin, end, pivot) {
            var piv=get(pivot)[sortColumnName];
            swap(pivot, end-1);
            var store=begin;
            var ix;
            for(ix=begin; ix<end-1; ++ix) {
                if(get(ix)[sortColumnName] < piv) {
                    swap(store,ix);
                    ++store;
                }
            }
            swap(end-1, store);

            return store;
        }
        function qsort(begin, end) {
            if(end-1>begin) {
                var pivot=begin+Math.floor(Math.random()*(end-begin));

                pivot=partition( begin, end, pivot);

                qsort(begin, pivot);
                qsort(pivot+1, end);
            }
        }
        function quick_sort() {
            qsort(0,count)
        }

    }
    ListModel {
        id: listmodel_Notes
        property string sortColumnName: ""

        onCountChanged: {
            // autosort functions ... get also stored when add or remove item
            sortColumnName = "massIndex"
            quick_sort()

            // create string to search through
            tmpNotesString = "|||"
            for (var n = 0; n < listmodel_Notes.count; n++) {
                var tmpNotesBookNumber = listmodel_Notes.get(n).bookNumber
                var tmpNotesChapterNumber = listmodel_Notes.get(n).chapterNumber
                var tmpNotesVerseNumber = listmodel_Notes.get(n).verseNumber
                tmpNotesString = (tmpNotesString + tmpNotesBookNumber + "-" + tmpNotesChapterNumber + "-" + tmpNotesVerseNumber + "|||")
            }
            //console.log(tmpNotesString)
        }
        // auto sort functions
        function swap(a,b) {
            if (a<b) {
                move(a,b,1);
                move (b-1,a,1);
            }
            else if (a>b) {
                move(b,a,1);
                move (a-1,b,1);
            }
        }
        function partition(begin, end, pivot) {
            var piv=get(pivot)[sortColumnName];
            swap(pivot, end-1);
            var store=begin;
            var ix;
            for(ix=begin; ix<end-1; ++ix) {
                if(get(ix)[sortColumnName] < piv) {
                    swap(store,ix);
                    ++store;
                }
            }
            swap(end-1, store);

            return store;
        }
        function qsort(begin, end) {
            if(end-1>begin) {
                var pivot=begin+Math.floor(Math.random()*(end-begin));

                pivot=partition( begin, end, pivot);

                qsort(begin, pivot);
                qsort(pivot+1, end);
            }
        }
        function quick_sort() {
            qsort(0,count)
        }

    }
    // search result models
    ListModel {
        id: listmodel_SearchResultsBible
    }
    ListModel {
        id: listmodel_SearchResultsBook
    }
    ListModel {
        id: listmodel_SearchResultsChapter
    }

    // helper lists for QML parsing of two bibles in splitscreen
    ListModel {
        id: listmodel_helperBible1_Verses
    }
    ListModel {
        id: listmodel_helperBible2_Verses
    }

    // loaded pages and overlays
    BannerBooks {
        id: bannerBooks
    }
    BannerSearch {
        id: bannerSearch
    }
    BannerBookmarks {
        id: bannerBookmarks
    }
    BannerNotes {
        id: bannerNotes
    }
    SettingsPage {
        id: settingsPage
    }

    // PyOtherSide
    Python {
        id: py
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../py'));
            importModule('biblex', function () {});

            // return handlers from python
            setHandler('finishedParsing', function( previewFull, allVersesList1, allVersesList2, lastChapterList1, lastChapterList2 ) {
                //console.log("gotten list from py, start making listmodel")
                // Listmodel 1
                lastChapterPerBook1Array = lastChapterList1
                listmodel_parsedFile1.clear()
                for (var i = 0; i < allVersesList1.length ; i++) {
                    var tmpBookNr = parseInt(allVersesList1[i][0]) - 1
                    if (tmpBookNr <= 65) { // do not include apokryphs for no data in bookNameArray[]
                        var currentBookNameLong_Model = bookNameArray[tmpBookNr][0]
                        var currentBookNameShort_Model = bookNameArray[tmpBookNr][1]
                        listmodel_parsedFile1.append( { bookNumber : tmpBookNr,
                                                         bookNameLong: currentBookNameLong_Model,
                                                         bookNameShort: currentBookNameShort_Model,
                                                         chapterNumber : parseInt(allVersesList1[i][1]),
                                                         verseNumber : parseInt(allVersesList1[i][2]),
                                                         verseText : allVersesList1[i][3]
                                                     } )
                    }
                }

                // Listmodel 2
                lastChapterPerBook2Array = lastChapterList2
                listmodel_parsedFile2.clear()
                for (i = 0; i < allVersesList2.length ; i++) {
                    tmpBookNr = parseInt(allVersesList2[i][0]) - 1
                    if (tmpBookNr <= 65) { // do not include apokryphs for no data in bookNameArray[]
                        currentBookNameLong_Model = bookNameArray[tmpBookNr][0]
                        currentBookNameShort_Model = bookNameArray[tmpBookNr][1]
                        listmodel_parsedFile2.append( { bookNumber : tmpBookNr,
                                                         bookNameLong: currentBookNameLong_Model,
                                                         bookNameShort: currentBookNameShort_Model,
                                                         chapterNumber : parseInt(allVersesList2[i][1]),
                                                         verseNumber : parseInt(allVersesList2[i][2]),
                                                         verseText : allVersesList2[i][3]
                                                     } )
                    }

                }
                generateCurrentChapterText( 0, "fromParser" )
                //console.log("finished listmodel")
            });
            setHandler('gotBibleMetadata', function( previewFull, infotitle1, infotitle2, infoversion1, infoversion2, infolanguage1, infolanguage2, infodate1, infodate2) {
                if (previewFull === "full") {
                    bibleName1 = infotitle1
                    bibleVersion1 = infoversion1
                    bibleDate1 = infodate1
                    bibleLanguage1 = infolanguage1
                    bibleName2 = infotitle2
                    bibleVersion2 = infoversion2
                    bibleDate2 = infodate2
                    bibleLanguage2 = infolanguage2
                }
                else { // preview
                    tempFileTitle1 = (infotitle1.length > 0) ? infotitle1 : emptyLoadTitle
                    tempFileVersion1 = infoversion1
                    tempFileDate1 = infodate1
                    tempFileLanguage1 = infolanguage1
                    tempFileTitle2 = (infotitle2.length > 0) ? infotitle2 : emptyLoadTitle
                    tempFileVersion2 = infoversion2
                    tempFileDate2 = infodate2
                    tempFileLanguage2 = infolanguage2
                    finishedLoadingSettings = true
                    finishedLoading = true
                }
            });
            setHandler('gotSearchResults', function( foundVerses, targetList) {
                if (targetList === "fullBible") {
                    listmodel_SearchResultsBible.clear()
                    for (var i = 0; i < foundVerses.length ; i++) {
                        var tmpBookNr = parseInt(foundVerses[i][0]) // - 1
                        var currentBookNameLong_Model = bookNameArray[tmpBookNr-1][0]
                        var currentBookNameShort_Model = bookNameArray[tmpBookNr-1][1]
                        listmodel_SearchResultsBible.append( { bookNumber : tmpBookNr,
                                                         bookNameLong: currentBookNameLong_Model,
                                                         bookNameShort: currentBookNameShort_Model,
                                                         chapterNumber : parseInt(foundVerses[i][1]),
                                                         verseNumber : parseInt(foundVerses[i][2]),
                                                         verseText1 : foundVerses[i][3]
                                                     } )
                    }
                    // dirty bugfix: add alibi entry for empty lists, with an empty list the scrollBar messes up positioning
                    listmodel_SearchResultsBible.append( { bookNumber : 9999,
                                                     bookNameLong: "",
                                                     bookNameShort: "",
                                                     chapterNumber : 0,
                                                     verseNumber : 0,
                                                     verseText1 : ""
                                                 } )
                }
                else if (targetList === "currentBook") {
                    listmodel_SearchResultsBook.clear()
                    for (i = 0; i < foundVerses.length ; i++) {
                        tmpBookNr = parseInt(foundVerses[i][0]) - 1
                        currentBookNameLong_Model = bookNameArray[tmpBookNr][0]
                        currentBookNameShort_Model = bookNameArray[tmpBookNr][1]
                        listmodel_SearchResultsBook.append( { bookNumber : tmpBookNr,
                                                         bookNameLong: currentBookNameLong_Model,
                                                         bookNameShort: currentBookNameShort_Model,
                                                         chapterNumber : parseInt(foundVerses[i][1]),
                                                         verseNumber : parseInt(foundVerses[i][2]),
                                                         verseText1 : foundVerses[i][3]
                                                     } )
                    }
                    // dirty bugfix: add alibi entry for empty lists, with an empty list the scrollBar messes up positioning
                    listmodel_SearchResultsBook.append( { bookNumber : 9999,
                                                     bookNameLong: "",
                                                     bookNameShort: "",
                                                     chapterNumber : 0,
                                                     verseNumber : 0,
                                                     verseText1 : ""
                                                 } )
                } else { // targetList === "currentChapter"
                    listmodel_SearchResultsChapter.clear()
                    for (i = 0; i < foundVerses.length ; i++) {
                        tmpBookNr = parseInt(foundVerses[i][0]) - 1
                        currentBookNameLong_Model = bookNameArray[tmpBookNr][0]
                        currentBookNameShort_Model = bookNameArray[tmpBookNr][1]
                        listmodel_SearchResultsChapter.append( { bookNumber : tmpBookNr,
                                                         bookNameLong: currentBookNameLong_Model,
                                                         bookNameShort: currentBookNameShort_Model,
                                                         chapterNumber : parseInt(foundVerses[i][1]),
                                                         verseNumber : parseInt(foundVerses[i][2]),
                                                         verseText1 : foundVerses[i][3]
                                                     } )
                    }
                    // dirty bugfix: add alibi entry for empty lists, with an empty list the scrollBar messes up positioning
                    listmodel_SearchResultsChapter.append( { bookNumber : 9999,
                                                     bookNameLong: "",
                                                     bookNameShort: "",
                                                     chapterNumber : 0,
                                                     verseNumber : 0,
                                                     verseText1 : ""
                                                 } )
                }
                currentBookOnSearch = displayCurrentBookNameLong
                currentChapterOnSearch = displayCurrentChapterNr
                searchingActive = false
            });
            setHandler('formerDB_BookmarksAvailable', function() {
                formerDB_BookmarksAvailable = true
            });
            setHandler('restoreOldDatabaseBookmarks', function(foundBookmarks) {
                for (var i = 0; i < foundBookmarks.length ; i++) {
                    if ( tmpBookmarkString.indexOf("|||" + (foundBookmarks[i][1]).toString() + "-" + (foundBookmarks[i][4]).toString() + "-" + (foundBookmarks[i][5]).toString() + "|||") === -1 ) {
                        //console.log("this old bookmark is not yet in current bookmarks: " + foundBookmarks[i])
                        listmodel_Bookmarks.append({
                            bookNumber : foundBookmarks[i][1],
                            bookNameLong : foundBookmarks[i][2],
                            bookNameShort : foundBookmarks[i][3],
                            chapterNumber : foundBookmarks[i][4],
                            verseNumber : foundBookmarks[i][5],
                            verseText1 : foundBookmarks[i][6],
                            highlightThisVers : true,
                            massIndex: (parseInt(foundBookmarks[i][1]) * 1000000) + (parseInt(foundBookmarks[i][4]) * 1000) + (parseInt(foundBookmarks[i][5]) * 1)  // where is verse in bible for ordering them according to bible position
                        })
                    }
                }
                updateBookmarksDB_fromList()
                formerDB_BookmarksAvailable = false
            });
            setHandler('successParsingFile', function( affectedFile, previewFull ) {
                if (previewFull === "full") {
                    if (affectedFile === filePath1) {
                        warningIntegrityFile1 = false
                    }
                    if (affectedFile === filePath2) {
                        warningIntegrityFile2 = false
                    }
                } else { // "preview" on settings page
                    if (affectedFile === tempFilePath1) {
                        tempWarningIntegrityFile1 = false
                    }
                    if (affectedFile === tempFilePath2) {
                        tempWarningIntegrityFile2 = false
                    }
                }
            });
            setHandler('errorParsingFile', function(bookNumbersError, affectedFile, previewFull) {
                console.log("book integrity error for: " + affectedFile + "\n" + "at bookNumber: " + bookNumbersError)
                if (previewFull === "full") {
                    if (affectedFile === filePath1) {
                        warningIntegrityFile1 = true
                    }
                    if (affectedFile === filePath2) {
                        warningIntegrityFile2 = true
                    }
                } else { // "preview" on settings page
                    if (affectedFile === tempFilePath1) {
                        tempWarningIntegrityFile1 = true
                    }
                    if (affectedFile === tempFilePath2) {
                        tempWarningIntegrityFile2 = true
                    }
                }
                finishedLoading = true
            });
            setHandler('debugPythonLogs', function(i) {
                console.log(i)
            });

        }
        // function calls to python
        function parseXML_File ( filePath1, filePath2, previewFull, postParsing ) {
            finishedLoading = false
            call("biblex.parseXML_File", [ filePath1, filePath2, previewFull, postParsing ])
        }
        function findVerses (  searchWordsList, currentBookNr, currentChapterNr) {
            searchingActive = false
            call("biblex.findVerses", [  searchWordsList, currentBookNr, currentChapterNr ])
        }
        function findOldDatabaseBookmarks () {
            call("biblex.findOldDatabaseBookmarks", [])
        }
        function isFormerDBavailable () {
            call("biblex.isFormerDBavailable", [])
        }

        onError: {
            //console.log('python error: ' + traceback) //when an exception is raised, this error handler will be called
        }
        onReceived: {
            //console.log('got message from python: ' + data) //asychronous messages from Python arrive here; done there via pyotherside.send()
        }
    }

    // overdraws background with selected color
    Rectangle {
        anchors.fill: parent
        color: settingsColorBackground
        opacity: 1
    }
    // replacement for app-background, on prev. page must be forced backgroundVisible=true, otherwise black screen when no image here
    background: Image {
        visible: currentBackgroundImagePath !== ""
        anchors.fill: parent
        fillMode: Image.Stretch
        asynchronous: true
        autoTransform: true
        source: currentBackgroundImagePath
    }

    // main view
    SilicaListView {
        id: idListViewChapterParserAll
        anchors.fill: parent
        header: Column {
            width: page.width
            onHeightChanged: {
                // scroll back to top on change of menu emphasis, which changes the height here
                idListViewChapterParserAll.positionViewAtIndex( 0, ListView.Center)
            }

            Row {
                id: idHeaderRowCurrentBible
                width: parent.width
                height: Theme.itemSizeLarge

                IconButton {
                    id: buttonSearch
                    enabled: finishedLoading
                    width: parent.width / 8
                    height: parent.height
                    icon.color: customHighlightColor
                    icon.source: "image://theme/icon-m-search?"
                    onClicked: {
                        hideAllNoteFields()
                        bannerSearch.notify( Theme.rgba(Theme.highlightDimmerColor, 1), parent.height )
                    }

                    Rectangle {
                        z: -1
                        anchors.fill: parent
                        color: upperMenuBackColor
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 1.0; color: upperMenuBackColor }
                        }
                    }
                }
                Item {
                    width: parent.width / 8
                    height: parent.height

                    IconButton {
                        id: buttonBookmarks
                        enabled: finishedLoading
                        rotation: 90
                        width: parent.width
                        height: parent.height
                        icon.color: customHighlightColor
                        icon.source: "image://theme/icon-m-attach?"
                        onClicked: {
                            hideAllNoteFields()
                            bannerBookmarks.notify( Theme.rgba(Theme.highlightDimmerColor, 1), parent.height )
                        }
                    }
                    Rectangle {
                        z: -1
                        anchors.fill: parent
                        color: upperMenuBackColor
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 1.0; color: upperMenuBackColor }
                        }
                    }
                }
                Item {
                    width: parent.width / 8 * 4
                    height: parent.height

                    Label {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        truncationMode: TruncationMode.Elide
                        font.pixelSize: Theme.fontSizeLarge //Medium
                        color: customHighlightColor
                        text: positionText

                        MouseArea {
                            enabled: finishedLoading
                            anchors.fill: parent
                            onClicked: {
                                hideAllNoteFields()
                                bannerBooks.notify( Theme.rgba(Theme.highlightDimmerColor, 1), parent.height, designPickerLayout )
                            }
                        }
                    }
                    Rectangle {
                        z: -1
                        anchors.fill: parent
                        //color: upperMenuBackColor
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 1.0; color: upperMenuBackColor }
                        }
                    }
                }
                Item {
                    width: parent.width / 8
                    height: parent.height

                    IconButton {
                        id: buttonNotes
                        visible: indexShowNotes === 1
                        enabled: finishedLoading
                        rotation: 90
                        width: parent.width
                        height: parent.height
                        icon.color: customHighlightColor
                        icon.source: "image://theme/icon-m-edit?"
                        icon.rotation: -90
                        onClicked: {
                            hideAllNoteFields()
                            bannerNotes.notify( Theme.rgba(Theme.highlightDimmerColor, 1), parent.height )
                        }
                    }
                    Item {
                        id: buttonNotesReplacement
                        visible: indexShowNotes === 0
                        width: parent.width
                        height: parent.height
                    }
                    Rectangle {
                        z: -1
                        anchors.fill: parent
                        color: upperMenuBackColor
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 1.0; color: upperMenuBackColor }
                        }
                    }
                }
                IconButton {
                    id: buttonSettings
                    enabled: finishedLoading
                    width: parent.width / 8
                    height: parent.height
                    icon.color: customHighlightColor
                    icon.source: "image://theme/icon-m-setting?"
                    onClicked: {
                        hideAllNoteFields()
                        // reset temp infos
                        tempFileTitle1 = (bibleName1.length > 0) ? bibleName1 : emptyLoadTitle
                        tempFileVersion1 = bibleVersion1
                        tempFileDate1 = bibleDate1
                        tempFileLanguage1 = bibleLanguage1
                        tempFilePath1 = filePath1
                        tempFileTitle2 = (bibleName2.length > 0) ? bibleName2 : emptyLoadTitle
                        tempFileVersion2 = bibleVersion2
                        tempFileDate2 = bibleLanguage2
                        tempFileLanguage2 = tempFileLanguage2
                        tempFilePath2 = filePath2
                        tempFontPath = customFontPath
                        tempFontName = customFontName
                        tempWarningIntegrityFile1 = warningIntegrityFile1
                        tempWarningIntegrityFile2 = warningIntegrityFile2
                        // open page
                        pageStack.push(settingsPage, {
                                           changedPath1 : false,
                                           changedPath2 : false,
                                           changedSplitscreen: false
                        })
                    }
                    onPressAndHold: {
                        rumbleEffect.start()
                        // create a quick parsable list from model
                        for (var i = 0; i < listmodel_BooksOverview.count ; i++) {
                            if (listmodel_BooksOverview.get(i).bookNumber !== 0 && listmodel_BooksOverview.get(i).bookNumber !== 9999) {
                                bookNameArray.push([listmodel_BooksOverview.get(i).longName, listmodel_BooksOverview.get(i).shortName])
                            }
                        }
                        // update fonts if custom path
                        if (currentFontIndex !== 0) {
                            localFont.source = customFontPath
                        }
                        py.parseXML_File( filePath1, filePath2, "full", "cleanUp" )
                        listmodel_Bookmarks.clear()
                        listmodel_Notes.clear()
                        generateBookmarkList_FromDB()
                        generateNotesList_FromDB()
                    }

                    Rectangle {
                        z: -1
                        anchors.fill: parent
                        color: upperMenuBackColor
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 1.0; color: upperMenuBackColor }
                        }
                    }

                    BusyIndicator {
                        anchors.centerIn: parent
                        size: BusyIndicatorSize.Medium * 1.25
                        running: finishedLoading === false
                        color: parent.icon.color
                    }
                }
            }
            Item {
                width: parent.width
                height: (indexMenuEmphasis === 0) ? -Theme.paddingSmall : 2* Theme.paddingSmall
            }
        }
        footer: Item {
            width: parent.width
            height: Theme.iconSizeLarge + 2* Theme.paddingSmall
        }
        cacheBuffer: 20000 //pixels = 10 * screenHeight

        ViewPlaceholder {
            enabled: (filePath1 === "n/a") && (filePath2 === "n/a")
            text: qsTr("Load Bible")
            hintText: qsTr("Choose XML file in Settings.")
        }
        VerticalScrollDecorator {
            color: ( customFontColor === customHighlightColor ) ? pullBackgroundColor : customHighlightColor
            flickable: idListViewChapterParserAll
        }
        PullDownMenu {
            id: idPushUpMenu
            quickSelect: true
            highlightColor: pullBackgroundColor
            backgroundColor: highlightColor
            enabled: displayCurrentChapterNr - 1 > 0
            //topMargin: Theme.paddingLarge

            MenuItem {
                Icon {
                    anchors.centerIn: parent
                    source: "image://theme/icon-s-arrow?"
                    sourceSize.width: height
                    sourceSize.height: height
                    rotation: 180 //90
                    scale: 1.4
                    color: settingsColorText
                }
                color: settingsColorText
                onClicked: {
                    idListViewChapterParserAll.positionViewAtIndex( 0, ListView.Center)
                    displayCurrentChapterNr = displayCurrentChapterNr - 1
                    generateCurrentChapterText( 0, "fromBackward" )
                }
            }
        }
        PushUpMenu {
            quickSelect: true
            highlightColor: idPushUpMenu.highlightColor
            backgroundColor: idPushUpMenu.backgroundColor
            enabled: (displayCurrentChapterNr + 1) <= maxChapterCurrentBook
            //bottomMargin: 0 //Theme.paddingLarge

            MenuItem {
                Icon {
                    anchors.centerIn: parent
                    source: "image://theme/icon-s-arrow?"
                    sourceSize.width: height
                    sourceSize.height: height
                    //rotation: -90
                    scale: 1.4
                    color: settingsColorText
                }
                color: settingsColorText
                onClicked: {
                    idListViewChapterParserAll.positionViewAtIndex( 0, ListView.Center)
                    displayCurrentChapterNr = displayCurrentChapterNr + 1
                    generateCurrentChapterText( 0, "fromForeward" )
                }
            }
        }

        model: listmodel_CurrentChapter_Bible
        delegate: ListItem {
            id: idListItem
            visible: finishedLoading
            contentHeight: idListLabelsQML.height
            contentWidth: parent.width
            menu: ContextMenu {
                id: idContextMenu

                MenuItem {
                    Row {
                        anchors.fill: parent
                        Item {
                            width: ( settingsSplitscreenBibles === "one" ) ? (parent.width / 3) : (parent.width / 4)
                            height: parent.height

                            IconButton {
                                anchors.centerIn: parent
                                icon.source: "image://theme/icon-m-clipboard?"
                                onClicked:  {
                                    rumbleEffect.start()
                                    //Clipboard.text = verseText1 + " (" + bookNameLong + " " + chapterNumber + "," + verseNumber + ")"
                                    if (indexCitationStyle === 0) { // harvard full
                                        Clipboard.text = verseText1 + " (" + bookNameArray[parseInt(bookNumber)][0] + " " + chapterNumber + ", " + verseNumber + ")"
                                    } else if (indexCitationStyle === 1) { // harvard short
                                        Clipboard.text = verseText1 + " (" + bookNameArray[parseInt(bookNumber)][1] + " " + chapterNumber + ", " + verseNumber + ")"
                                    } else if (indexCitationStyle === 2) { // chicago long
                                        Clipboard.text = verseText1 + " (" + bookNameArray[parseInt(bookNumber)][0] + " " + chapterNumber + ":" + verseNumber + ")"
                                    } else { // chicago short
                                        Clipboard.text = verseText1 + " (" + bookNameArray[parseInt(bookNumber)][1] + " " + chapterNumber + ":" + verseNumber + ")"
                                    }
                                    //console.log(Clipboard.text)
                                    idContextMenu.close()
                                }
                            }
                        }
                        Item {
                            width: ( settingsSplitscreenBibles === "one" ) ? (parent.width / 3) : (parent.width / 4)
                            height: parent.height

                            IconButton {
                                anchors.centerIn: parent
                                icon.source: "image://theme/icon-m-attach?"
                                icon.rotation: 180
                                onClicked: {
                                    if (idFirstTextLabel.font.bold === false) {
                                        listmodel_Bookmarks.append({
                                            bookNumber : bookNumber + 1,
                                            bookNameLong : bookNameLong,
                                            bookNameShort : bookNameShort,
                                            chapterNumber : chapterNumber,
                                            verseNumber :  verseNumber,
                                            verseText1 : verseText1,
                                            highlightThisVers : true,
                                            massIndex: ((bookNumber + 1) * 1000000) + (chapterNumber * 1000) + (verseNumber * 1)  // where is verse in bible for ordering them according to bible position
                                        })
                                    }
                                    else { // remove bookmark
                                        for (var j = listmodel_Bookmarks.count -1; j >= 0; --j) {
                                            if (listmodel_Bookmarks.get(j).bookNumber === bookNumber+1 && listmodel_Bookmarks.get(j).chapterNumber === chapterNumber && listmodel_Bookmarks.get(j).verseNumber === verseNumber) {
                                                listmodel_Bookmarks.remove(j)
                                            }
                                        }
                                    }
                                    updateBookmarksDB_fromList()
                                    idContextMenu.close()
                                }
                                Icon {
                                    visible: idFirstTextLabel.font.bold
                                    anchors.centerIn: parent
                                    sourceSize.width: width
                                    sourceSize.height: height
                                    scale: 1.5
                                    color: Theme.errorColor
                                    source: "../artwork/icon-m-unpick.svg?"
                                }
                            }
                        }
                        Item {
                            width: ( settingsSplitscreenBibles === "one" ) ? (parent.width / 3) : (parent.width / 4)
                            height: parent.height

                            IconButton {
                                anchors.centerIn: parent
                                icon.source: "image://theme/icon-m-edit?"
                                onClicked: {
                                    if (hasNote === false) { // add note
                                        // update current chapter-listmodel
                                        listmodel_CurrentChapter_Bible.setProperty(index, "hasNote", true)
                                        listmodel_CurrentChapter_Bible.setProperty(index, "noteText", "")
                                        // update note-listmodel
                                        listmodel_Notes.append({
                                            bookNumber : bookNumber+1,
                                            bookNameLong : bookNameLong,
                                            bookNameShort : bookNameShort,
                                            chapterNumber : chapterNumber,
                                            verseNumber : verseNumber,
                                            verseText1 : verseText1,
                                            noteText : noteTextEditArea.text,
                                            highlightThisVers : true,
                                            massIndex: ((bookNumber+1) * 1000000) + (chapterNumber * 1000) + (verseNumber * 1)  // where is verse in bible for ordering them according to bible position
                                        })
                                        // update database
                                        updateNotesDB_fromList()
                                        // open text entry field ... maybe too much
                                        //showNote = true
                                    }
                                    else { // remove note
                                        // remove from current chapter-listmodel
                                        listmodel_CurrentChapter_Bible.setProperty(index, "hasNote", false)
                                        listmodel_CurrentChapter_Bible.setProperty(index, "noteText", "")
                                        // remove from note-listmodel
                                        for (var j = listmodel_Notes.count -1; j >= 0; --j) {
                                            if (listmodel_Notes.get(j).bookNumber === bookNumber+1 && listmodel_Notes.get(j).chapterNumber === chapterNumber && listmodel_Notes.get(j).verseNumber === verseNumber) {
                                                listmodel_Notes.remove(j)
                                                break
                                            }
                                        }
                                        // update the database
                                        updateNotesDB_fromList()
                                        // close text entry field
                                        showNote = false
                                        //noteTextEditArea.visible = false
                                    }
                                    idContextMenu.close()
                                }
                                Icon {
                                    visible: hasNote
                                    anchors.centerIn: parent
                                    sourceSize.width: width
                                    sourceSize.height: height
                                    scale: 1.5
                                    color: Theme.errorColor
                                    source: "../artwork/icon-m-unpick.svg?"
                                }
                            }
                        }
                        Item {
                            visible: ( settingsSplitscreenBibles !== "one" )
                            width: ( settingsSplitscreenBibles === "one" ) ? 0 : (parent.width / 4)
                            height: parent.height

                            IconButton {
                                anchors.centerIn: parent
                                icon.source: "image://theme/icon-m-clipboard?"
                                onClicked:  {
                                    rumbleEffect.start()
                                    //Clipboard.text = verseText2 + " (" + bookNameLong + " " + chapterNumber + "," + verseNumber + ")"
                                    if (indexCitationStyle === 0) { // harvard full
                                        Clipboard.text = verseText2 + " (" + bookNameArray[parseInt(bookNumber)][0] + " " + chapterNumber + ", " + verseNumber + ")"
                                    } else if (indexCitationStyle === 1) { // harvard short
                                        Clipboard.text = verseText2 + " (" + bookNameArray[parseInt(bookNumber)][1] + " " + chapterNumber + ", " + verseNumber + ")"
                                    } else if (indexCitationStyle === 2) { // chicago full
                                        Clipboard.text = verseText2 + " (" + bookNameArray[parseInt(bookNumber)][0] + " " + chapterNumber + ":" + verseNumber + ")"
                                    } else { // chicago short
                                        Clipboard.text = verseText2 + " (" + bookNameArray[parseInt(bookNumber)][1] + " " + chapterNumber + ":" + verseNumber + ")"
                                    }
                                    //console.log(Clipboard.text)
                                    idContextMenu.close()
                                }
                            }
                        }
                    }
                }
            }

            Column {
                id: idListLabelsQML
                x: Theme.paddingSmall
                width: parent.width - 2*x
                topPadding: Theme.paddingSmall
                bottomPadding: Theme.paddingSmall

                Row {
                    id: idVerseTextRow
                    width: parent.width

                    Label {
                        id: idFirstTextLabel
                        width: ( settingsSplitscreenBibles === "one" ) ? parent.width : ( parent.width/2  - Theme.paddingMedium/2 )
                        color: settingsColorText
                        font.bold:  ( tmpBookmarkString.indexOf("|||" + displayCurrentBookNr + "-" + displayCurrentChapterNr + "-" + (index+1) + "|||" ) !== -1 ) //does not work with lists...why?
                        wrapMode: Text.WordWrap
                        font.pixelSize: settingsTextsize
                        font.family: (currentFontIndex === 0) ? Theme.fontFamily : localFont.name
                        text: ( verseText1 !== "" ) ? (verseNumber + ". " + verseText1) : ("")
                    }
                    Item {
                        id: idSplitscreenSpacerItem
                        visible: settingsSplitscreenBibles !== "one"
                        width: Theme.paddingMedium
                        height: 1
                    }
                    Label {
                        id: idSecondTextLabel
                        visible: settingsSplitscreenBibles !== "one"
                        width: parent.width/2 - Theme.paddingMedium/2
                        color: settingsColorText
                        font.bold: ( tmpBookmarkString.indexOf("|||" + displayCurrentBookNr + "-" + displayCurrentChapterNr + "-" + (index+1) + "|||" ) !== -1 ) //idFirstTextLabel.font.bold
                        wrapMode: Text.WordWrap
                        font.pixelSize: settingsTextsize
                        font.family: (currentFontIndex === 0) ? Theme.fontFamily : localFont.name
                        text: ( verseText2 !== "" ) ? (verseNumber + ". " + verseText2) : ("")
                    }
                }
                Item {
                    visible: noteTextEditButton.visible
                    width: parent.width
                    height: Theme.paddingSmall * 2
                }
                Item {
                    id: idBookmarksRow
                    visible: (hasNote === true && indexShowNotes === 1)
                    width: parent.width
                    height: (showNote === false) ? (idNotesEditRowHide.height) : (idNotesEditRowShow.height)

                    IconButton {
                        id: idNotesEditRowHide
                        visible: showNote === false
                        y: Theme.paddingMedium // Medium for scale 1.2 // Small for scale 1.5
                        width: parent.width
                        height: Theme.iconSizeMedium
                        icon.color: customHighlightColor
                        icon.rotation: 0
                        icon.source: "image://theme/icon-s-edit?"
                        icon.scale: 1.2 // 1.5
                        onClicked: {
                            if (noteTextEditArea.visible === true) {
                                showNote = false
                            } else {
                                showNote = true
                            }
                        }
                    }
                    Row {
                        id: idNotesEditRowShow
                        visible: showNote === true
                        x: 0
                        width: parent.width - 2*x
                        height: noteTextEditArea.height

                        TextArea {
                            id: noteTextEditArea
                            textTopMargin: Theme.paddingMedium * 1.4
                            visible: (hasNote && indexShowNotes === 1 && showNote === true)
                            onVisibleChanged: {
                                if (visible === true) {
                                    if (text === "") {
                                        forceActiveFocus()
                                    }
                                } else {
                                    focus = false
                                }
                            }
                            width:  parent.width - noteTextEditButton.width
                            backgroundStyle: TextEditor.NoBackground
                            labelVisible: false
                            placeholderText: qsTr("type here")
                            placeholderColor: customHighlightColor
                            font.pixelSize: settingsTextsize
                            color: settingsColorText
                            textLeftMargin: Theme.paddingLarge
                            //textRightMargin: textLeftMargin
                            font.italic: true
                            text: noteText
                            onFocusChanged: {
                                // apply and save changes on exiting keyboard
                                if (focus === false) {
                                    // update current chapter-listmodel
                                    listmodel_CurrentChapter_Bible.setProperty(index, "hasNote", true)
                                    listmodel_CurrentChapter_Bible.setProperty(index, "noteText", text)
                                    // update notes-listmodel
                                    for (var j = listmodel_Notes.count -1; j >= 0; --j) {
                                        if (listmodel_Notes.get(j).bookNumber === bookNumber+1 && listmodel_Notes.get(j).chapterNumber === chapterNumber && listmodel_Notes.get(j).verseNumber === verseNumber) {
                                            listmodel_Notes.setProperty(j, "noteText", text)
                                            break
                                        }
                                    }
                                    // update database
                                    //updateNotesDB_fromList()
                                    storageItem.updateNote( bookNumber+1, chapterNumber, verseNumber, text )
                                }
                            }
                        }
                        IconButton {
                            id: noteTextEditButton
                            width: Theme.iconSizeMedium * 1.2
                            height: parent.height
                            icon.color: customHighlightColor
                            icon.rotation: 180
                            icon.source: "image://theme/icon-s-arrow?"
                            onClicked: {
                                if (noteTextEditArea.visible === true) {
                                    showNote = false
                                } else {
                                    showNote = true
                                }
                            }
                        }
                    }
                    Rectangle {
                        z: -1
                        anchors.fill: idNotesEditRowShow
                        anchors.leftMargin: -Theme.paddingLarge
                        anchors.rightMargin: anchors.leftMargin
                        visible: idNotesEditRowShow.visible
                        color: (showNote && hasNote) ? Theme.rgba(customHighlightColor, 0.2) : "transparent"
                        radius: Theme.paddingLarge
                    }
                }
            }
            Rectangle {
                id: backgroundHighlight
                z: -10
                anchors.fill: parent
                color: "transparent"

                SequentialAnimation {
                    running: highlightThisVers === true

                    PauseAnimation {
                        duration: 300
                    }
                    ColorAnimation {
                        target: backgroundHighlight
                        property: "color"
                        from: "transparent"
                        to: Theme.rgba(( customFontColor === customHighlightColor ) ? Theme.errorColor : customHighlightColor, 0.35)
                        duration: 650
                    }
                    PauseAnimation {
                        duration: 100
                    }
                    ColorAnimation {
                        target: backgroundHighlight
                        property: "color"
                        from: Theme.rgba(( customFontColor === customHighlightColor ) ? Theme.errorColor : customHighlightColor, 0.35)
                        to: "transparent"
                        duration: 1450
                        onStopped: {
                            highlightThisVers = false
                        }
                    }
                }
            }
        }
    }


    // ******************************************** important functions ******************************************** //


    function generateCurrentChapterText( scrollToVerse, fromWhere ) {
        finishedLoading = false
        //console.log(scrollToVerse)

        listmodel_CurrentChapter_Bible.clear()
        if ( settingsSplitscreenBibles === "one" ) {
            maxChapterCurrentBook = (lastChapterPerBook1Array[displayCurrentBookNr-1] !== undefined) ? lastChapterPerBook1Array[displayCurrentBookNr-1] : 1
            for (var i = 0; i < listmodel_parsedFile1.count; i++) {
                if ( (listmodel_parsedFile1.get(i).bookNumber === displayCurrentBookNr-1) && (listmodel_parsedFile1.get(i).chapterNumber === displayCurrentChapterNr) ) {
                    // enable highlighting effect when jumped to verse from search, bookmarks or edits
                    var tmpCurrentVerseNr = listmodel_parsedFile1.get(i).verseNumber
                    var tmpShowNote = false
                    if ( displayCurrentVerseNr === tmpCurrentVerseNr ) {
                        var highlightVerse = true
                        if ( fromWhere === "fromNotes" ) {
                            tmpShowNote = true
                        }
                    } else {
                        highlightVerse = false
                    }

                    // get editText from notes-listmodel if verse is contained
                    var tmpEditText = ""
                    var tmpHasNote = false
                    if ( tmpNotesString.indexOf("|||" + displayCurrentBookNr + "-" + displayCurrentChapterNr + "-" + tmpCurrentVerseNr + "|||") !== -1 ) {
                        //console.log(displayCurrentBookNr, displayCurrentChapterNr, tmpCurrentVerseNr)
                        for (var j = 0; j < listmodel_Notes.count; j++) {
                            if (listmodel_Notes.get(j).bookNumber === displayCurrentBookNr && listmodel_Notes.get(j).chapterNumber === displayCurrentChapterNr && listmodel_Notes.get(j).verseNumber === tmpCurrentVerseNr) {
                                tmpEditText = listmodel_Notes.get(j).noteText
                                tmpHasNote = true
                                break
                            }
                        }
                    }

                    listmodel_CurrentChapter_Bible.append({
                        bookNumber : listmodel_parsedFile1.get(i).bookNumber,
                        bookNameLong : listmodel_parsedFile1.get(i).bookNameLong,
                        bookNameShort : listmodel_parsedFile1.get(i).bookNameShort,
                        chapterNumber : listmodel_parsedFile1.get(i).chapterNumber,
                        verseNumber : tmpCurrentVerseNr,
                        verseText1 : (listmodel_parsedFile1.get(i).verseText),
                        verseText2 : "",
                        highlightThisVers : highlightVerse,
                        noteText : tmpEditText,
                        hasNote : tmpHasNote,
                        showNote : tmpShowNote
                    })
                }

            }
        }

        if ( settingsSplitscreenBibles === "two" ) {
            maxChapterCurrentBook = Math.max( (lastChapterPerBook1Array[displayCurrentBookNr-1] !== undefined) ? lastChapterPerBook1Array[displayCurrentBookNr-1] : 1,
                                             (lastChapterPerBook2Array[displayCurrentBookNr-1]) !== undefined ? lastChapterPerBook2Array[displayCurrentBookNr-1] : 1)

            // create a helper model with those verses from text 1
            listmodel_helperBible1_Verses.clear()
            for (var k = 0; k < listmodel_parsedFile1.count; k++) {
                if ( (listmodel_parsedFile1.get(k).bookNumber === displayCurrentBookNr-1) && (listmodel_parsedFile1.get(k).chapterNumber === displayCurrentChapterNr) ) {
                    tmpCurrentVerseNr = listmodel_parsedFile1.get(k).verseNumber
                    tmpShowNote = false
                    if ( displayCurrentVerseNr === tmpCurrentVerseNr) {
                        highlightVerse = true
                        if ( fromWhere === "fromNotes" ) {
                            tmpShowNote = true
                        }
                    } else {
                        highlightVerse = false
                    }

                    tmpEditText = ""
                    tmpHasNote = false
                    if ( tmpNotesString.indexOf("|||" + displayCurrentBookNr + "-" + displayCurrentChapterNr + "-" + tmpCurrentVerseNr + "|||") !== -1 ) {
                        //console.log(displayCurrentBookNr, displayCurrentChapterNr, tmpCurrentVerseNr)
                        for (j = 0; j < listmodel_Notes.count; j++) {
                            if (listmodel_Notes.get(j).bookNumber === displayCurrentBookNr && listmodel_Notes.get(j).chapterNumber === displayCurrentChapterNr && listmodel_Notes.get(j).verseNumber === tmpCurrentVerseNr) {
                                tmpEditText = listmodel_Notes.get(j).noteText
                                tmpHasNote = true
                                break
                            }
                        }
                    }

                    listmodel_helperBible1_Verses.append({
                        bookNumber : listmodel_parsedFile1.get(k).bookNumber,
                        bookNameLong : listmodel_parsedFile1.get(k).bookNameLong,
                        bookNameShort : listmodel_parsedFile1.get(k).bookNameShort,
                        chapterNumber : listmodel_parsedFile1.get(k).chapterNumber,
                        verseNumber : tmpCurrentVerseNr,
                        verseText : (listmodel_parsedFile1.get(k).verseText),
                        highlightThisVers : highlightVerse,
                        noteText : tmpEditText,
                        hasNote : tmpHasNote,
                        showNote : tmpShowNote
                    })
                }
            }

            // create a helper model with those verses from text 2
            listmodel_helperBible2_Verses.clear()
            for (k = 0; k < listmodel_parsedFile2.count; k++) {
                if ( (listmodel_parsedFile2.get(k).bookNumber === displayCurrentBookNr-1) && (listmodel_parsedFile2.get(k).chapterNumber === displayCurrentChapterNr) ) {
                    tmpCurrentVerseNr = listmodel_parsedFile2.get(k).verseNumber
                    tmpShowNote = false
                    if ( displayCurrentVerseNr === tmpCurrentVerseNr ) {
                        highlightVerse = true
                        if ( fromWhere === "fromNotes" ) {
                            tmpShowNote = true
                        }
                    } else {
                        highlightVerse = false
                    }

                    tmpEditText = ""
                    tmpHasNote = false
                    if ( tmpNotesString.indexOf("|||" + displayCurrentBookNr + "-" + displayCurrentChapterNr + "-" + tmpCurrentVerseNr + "|||") !== -1 ) {
                        //console.log(displayCurrentBookNr, displayCurrentChapterNr, tmpCurrentVerseNr)
                        for (j = 0; j < listmodel_Notes.count; j++) {
                            if (listmodel_Notes.get(j).bookNumber === displayCurrentBookNr && listmodel_Notes.get(j).chapterNumber === displayCurrentChapterNr && listmodel_Notes.get(j).verseNumber === tmpCurrentVerseNr) {
                                tmpEditText = listmodel_Notes.get(j).noteText
                                tmpHasNote = true
                                break
                            }
                        }
                    }

                    listmodel_helperBible2_Verses.append({
                        bookNumber : listmodel_parsedFile2.get(k).bookNumber,
                        bookNameLong : listmodel_parsedFile2.get(k).bookNameLong,
                        bookNameShort : listmodel_parsedFile2.get(k).bookNameShort,
                        chapterNumber : listmodel_parsedFile2.get(k).chapterNumber,
                        verseNumber : tmpCurrentVerseNr,
                        verseText : (listmodel_parsedFile2.get(k).verseText),
                        highlightThisVers : highlightVerse,
                        noteText : tmpEditText,
                        hasNote : tmpHasNote,
                        showNote : tmpShowNote
                    })
                }
            }

            // now merge both temporary lists together
            var maxCountVerses = (Math.max(listmodel_helperBible1_Verses.count, listmodel_helperBible2_Verses.count))
            var minCountVerses = (Math.min(listmodel_helperBible1_Verses.count, listmodel_helperBible2_Verses.count))

            // first use common verses
            for (i = 0; i < minCountVerses; i++) {
                //console.log(i)
                listmodel_CurrentChapter_Bible.append({
                    bookNumber : listmodel_helperBible1_Verses.get(i).bookNumber,
                    bookNameLong : listmodel_helperBible1_Verses.get(i).bookNameLong,
                    bookNameShort : listmodel_helperBible1_Verses.get(i).bookNameShort,
                    chapterNumber : listmodel_helperBible1_Verses.get(i).chapterNumber,
                    verseNumber : listmodel_helperBible1_Verses.get(i).verseNumber,
                    verseText1 : ( i <= listmodel_helperBible1_Verses.count )   ? listmodel_helperBible1_Verses.get(i).verseText    : "",
                    verseText2 : ( i <= listmodel_helperBible2_Verses.count )   ? listmodel_helperBible2_Verses.get(i).verseText    : "",
                    highlightThisVers : listmodel_helperBible1_Verses.get(i).highlightThisVers,
                    noteText : listmodel_helperBible1_Verses.get(i).noteText,
                    hasNote : listmodel_helperBible1_Verses.get(i).hasNote,
                    showNote : listmodel_helperBible1_Verses.get(i).showNote
                })
                //console.log(listmodel_helperBible1_Verses.get(i).highlightThisVers)
            }

            // now add the leftover verses from which is longer
            if ( listmodel_helperBible1_Verses.count >= listmodel_helperBible2_Verses.count ) {
                for (i = minCountVerses; i < maxCountVerses; i++) {
                    //console.log(i)
                    listmodel_CurrentChapter_Bible.append({
                        bookNumber : listmodel_helperBible1_Verses.get(i).bookNumber,
                        bookNameLong : listmodel_helperBible1_Verses.get(i).bookNameLong,
                        bookNameShort : listmodel_helperBible1_Verses.get(i).bookNameShort,
                        chapterNumber : listmodel_helperBible1_Verses.get(i).chapterNumber,
                        verseNumber : listmodel_helperBible1_Verses.get(i).verseNumber,
                        verseText1 : listmodel_helperBible1_Verses.get(i).verseText,
                        verseText2 : "",
                        highlightThisVers : listmodel_helperBible1_Verses.get(i).highlightThisVers,
                        noteText : listmodel_helperBible1_Verses.get(i).noteText,
                        hasNote : listmodel_helperBible1_Verses.get(i).hasNote,
                        showNote : listmodel_helperBible1_Verses.get(i).showNote
                    })
                }
            }
            else {
                for (i = minCountVerses; i < maxCountVerses; i++) {
                    //console.log(i)
                    listmodel_CurrentChapter_Bible.append({
                        bookNumber : listmodel_helperBible2_Verses.get(i).bookNumber,
                        bookNameLong : listmodel_helperBible2_Verses.get(i).bookNameLong,
                        bookNameShort : listmodel_helperBible2_Verses.get(i).bookNameShort,
                        chapterNumber : listmodel_helperBible2_Verses.get(i).chapterNumber,
                        verseNumber : listmodel_helperBible2_Verses.get(i).verseNumber,
                        verseText1 : "",
                        verseText2 : listmodel_helperBible2_Verses.get(i).verseText,
                        highlightThisVers : listmodel_helperBible2_Verses.get(i).highlightThisVers,
                        noteText : listmodel_helperBible2_Verses.get(i).noteText,
                        hasNote : listmodel_helperBible2_Verses.get(i).hasNote,
                        showNote : listmodel_helperBible2_Verses.get(i).showNote
                    })
                }
            }

        }

        displayCurrentVerseNr = -1 // makes sure not to show a highlighted verse when switching chapter e.g.
        idListViewChapterParserAll.positionViewAtIndex( scrollToVerse, ListView.Center)

        // save position in DB
        storageItem.setSettings("chosenBookNumber", displayCurrentBookNr)
        storageItem.setSettings("chosenBookLongname", displayCurrentBookNameLong)
        storageItem.setSettings("chosenBookShortname", displayCurrentBookNameShort)
        storageItem.setSettings("chosenChapterNumber", displayCurrentChapterNr)
        finishedLoading = true
        finishedLoadingSettings = true
    }


    function generateBookmarkList_FromDB() {
        counterDB_Bookmarks = parseInt(storageItem.getTableCount('bookmarks', 0))
        var allBookmarks = storageItem.getAllBookmarks("", "orderTime") //orderBible
        for (var i = 0; i < allBookmarks.length ; i++) {
            //console.log(allBookmarks[i])
            if (allBookmarks[i] !== "none") {
                listmodel_Bookmarks.append({
                    bookNumber : allBookmarks[i][1],
                    bookNameLong : allBookmarks[i][2],
                    bookNameShort : allBookmarks[i][3],
                    chapterNumber : allBookmarks[i][4],
                    verseNumber : allBookmarks[i][5],
                    verseText1 : allBookmarks[i][6],
                    highlightThisVers : true,
                    massIndex: (parseInt(allBookmarks[i][1]) * 1000000) + (parseInt(allBookmarks[i][4]) * 1000) + (parseInt(allBookmarks[i][5]) * 1)  // where is verse in bible for ordering them according to bible position
                })
            }
        }
    }


    function updateBookmarksDB_fromList() {
        storageItem.removeFullTable('bookmarks')
        for (var i = 0; i < listmodel_Bookmarks.count ; i++) {
            var tmpCurrentIndex = i
            var tmpCurrentBookNr = listmodel_Bookmarks.get(i).bookNumber
            var tmpCurrentBookNameLong = listmodel_Bookmarks.get(i).bookNameLong
            var tmpCurrentBookNameShort = listmodel_Bookmarks.get(i).bookNameShort
            var tmpCurrentChapterNr = listmodel_Bookmarks.get(i).chapterNumber
            var tmpCurrentVersNr = listmodel_Bookmarks.get(i).verseNumber
            var tmpCurrentVers = listmodel_Bookmarks.get(i).verseText1
            storageItem.setBookmark( tmpCurrentIndex, tmpCurrentBookNr, tmpCurrentBookNameLong, tmpCurrentBookNameShort, tmpCurrentChapterNr, tmpCurrentVersNr, tmpCurrentVers )
        }
    }


    function generateNotesList_FromDB() {
        // Patch: needs separate function only loaded once on startup, while updateFromDB_Settings_Model() is also called on return from settings, would populate list a second time
        counterDB_Notes = parseInt(storageItem.getTableCount('notes', 0))
        for (var i = 0; i < counterDB_Notes ; i++) {
            var currentNote = storageItem.getNote(i, "none")
            if (currentNote !== "none") {
                listmodel_Notes.append({
                    bookNumber : currentNote[1],
                    bookNameLong : currentNote[2],
                    bookNameShort : currentNote[3],
                    chapterNumber : currentNote[4],
                    verseNumber : currentNote[5],
                    verseText1 : currentNote[6],
                    noteText : currentNote[7],
                    highlightThisVers : true,
                    massIndex: (parseInt(currentNote[1]) * 1000000) + (parseInt(currentNote[4]) * 1000) + (parseInt(currentNote[5]) * 1)  // where is verse in bible for ordering them according to bible position
                })
            }
        }
    }


    function updateNotesDB_fromList() {
        storageItem.removeFullTable('notes')
        for (var i = 0; i < listmodel_Notes.count ; i++) {
            var tmpCurrentIndex = i
            var tmpCurrentBookNr = listmodel_Notes.get(i).bookNumber
            var tmpCurrentBookNameLong = listmodel_Notes.get(i).bookNameLong
            var tmpCurrentBookNameShort = listmodel_Notes.get(i).bookNameShort
            var tmpCurrentChapterNr = listmodel_Notes.get(i).chapterNumber
            var tmpCurrentVersNr = listmodel_Notes.get(i).verseNumber
            var tmpCurrentVers = listmodel_Notes.get(i).verseText1
            var tmpCurrentNoteText = listmodel_Notes.get(i).noteText
            storageItem.setNote( tmpCurrentIndex, tmpCurrentBookNr, tmpCurrentBookNameLong, tmpCurrentBookNameShort, tmpCurrentChapterNr, tmpCurrentVersNr, tmpCurrentVers, tmpCurrentNoteText )
        }
    }


    function hideAllNoteFields() {
        for (var i = 0; i < listmodel_CurrentChapter_Bible.count ; i++) {
            listmodel_CurrentChapter_Bible.setProperty(i, "showNote", false)
        }
    }


    function firstBootClearDB() {
        var firstBoot = storageItem.getSettings("firstBoot", "true")
        //console.log(firstBoot)
        if (firstBoot === "true") {
            //storageItem.removeFullTable('bookmarks')
            storageItem.removeFullTable('table_bible_raw1')
            storageItem.removeFullTable('table_bible_raw2')
            storageItem.removeFullTable('settings_table')
            storageItem.removeFullTable('info_table')
            displayCurrentBookNr = 1
            displayCurrentBookNameLong = qsTr("Genesis")
            displayCurrentBookNameShort = qsTr("Gen")
            displayCurrentChapterNr = 1
            currentFontIndex = 0
            customFontPath = ""
            customFontName = emptyLoadTitle
            settingsTextsize = Theme.fontSizeSmall
            settingsColorBackground = "transparent"
            settingsColorText = Theme.primaryColor
            settingsSplitscreenBibles = "one"
            designPickerLayout = "grid"
            displayPreventBlanking = 1
            indexColorScheme = 0
            customHighlightColor = colorSchemes[indexColorScheme][3]
            pullBackgroundColor = colorSchemes[indexColorScheme][4]
            currentBackgroundImagePath = colorSchemes[indexColorScheme][5]
            upperMenuBackColor = Theme.rgba(settingsColorText, 0.1)
            filePath1 = "n/a"
            filePath2 = "n/a"
            tempFilePath1 = filePath1
            tempFileTitle1 = emptyLoadTitle
            tempFileLanguage1 = bibleLanguage1
            tempFileDate1 = bibleDate1
            tempFileVersion1 = bibleVersion1
            tempFilePath2 = filePath2
            tempFileTitle2 = emptyLoadTitle
            tempFileLanguage2 = bibleLanguage2
            tempFileDate2 = bibleDate2
            tempFileVersion2 = bibleVersion2
            tempFontPath = customFontPath
            tempFontName = customFontName
            storageItem.setSettings("firstBoot", "false" )
        }
        //storageItem.setSettings("firstBoot", "true" )
    }
}
