#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import pyotherside
import os
import xml.etree.ElementTree as ET
from pathlib import Path
import sqlite3


#pyotherside.send('debugPythonLogs', i)


allVersesList1 = []
allVersesList2 = []

def parseXML_File ( filePath1, filePath2, previewFull, postParsing ):
    allVersesList1.clear() # = []
    '''
    lastChapterList1 = [0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0]
    '''
    #allow for apokryphs
    lastChapterList1 = [0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,
                        0]
    allVersesList2.clear() # = []
    '''
    lastChapterList2 = [0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0]
    '''
    lastChapterList2 = [0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,
                        0]
    infotitle1 = ""
    infoversion1 = "n/a"
    infolanguage1 = "n/a"
    infodate1 = "n/a"
    infotitle2 = ""
    infoversion2 = "n/a"
    infolanguage2 = "n/a"
    infodate2 = "n/a"

    if os.path.exists(filePath1):
        # parse metadata first
        root = ET.parse(filePath1).getroot()
        for info1 in root.iter('XMLBIBLE'):
            try:
                infotitle1 = str(info1.attrib["biblename"])
            except:
                infotitle1 = "n/a"
            try:
                infoversion1 = str(info1.attrib["version"])
            except:
                infoversion1 = "n/a"
        for info2 in root.iter('language'):
            try:
                infolanguage1 = str(info2.text)
            except:
                infolanguage1 = "n/a"
        for info3 in root.iter('date'):
            try:
                infodate1 = str(info3.text)
            except:
                infodate1 = "n/a"

        # plausibility and missing books test for file loading ... do not allow book to be loaded
        tmpBooksList = []
        parseFull = True
        for indexBook, book in enumerate(root.iter('BIBLEBOOK')):
            try:
                bookNr = book.attrib["bnumber"]
            except:
                bookNr = indexBook + 1
            tmpBooksList.append(int(bookNr))
            #pyotherside.send('debugPythonLogs', tmpBooksList)
            #if (all(x2-x1 == 1 for x1, x2 in zip(tmpBooksList[:-1], tmpBooksList[1:])) is False) : # strict sorted list upwards
            if ( (tmpBooksList != sorted(tmpBooksList)) or (int(bookNr) > len(lastChapterList1)) or (int(bookNr) > 66 and len(tmpBooksList) <= 66 ) or (len(tmpBooksList) != len(set(tmpBooksList))) ): # 4 integrity tests: not_ascending OR too_large_number OR same_booknumber_twice
                pyotherside.send('errorParsingFile', tmpBooksList, filePath1, previewFull)
                parseFull = False
                break
            else:
                pyotherside.send('successParsingFile', filePath1, previewFull)
        # parse verses next
        if "full" in previewFull and parseFull is True :
            for indexBook, book in enumerate(root.iter('BIBLEBOOK')):
                try:
                    #bookNr = str(book.attrib)
                    bookNr = book.attrib["bnumber"]
                except:
                    bookNr = indexBook + 1
                for indexChapter, chapter in enumerate(book):
                    try:
                        chapterNr = chapter.attrib["cnumber"]
                    except:
                        chapterNr = indexChapter + 1

                    for indexVerse, verse in enumerate(chapter):
                        try:
                            verseNr = verse.attrib["vnumber"]
                        except:
                            verseNr = indexVerse + 1
                        try:
                            #verseText = ET.tostring(verse, encoding='unicode', method='html') # method='html'
                            #verseText = ET.tostring(verse, encoding='unicode', method='text') # output almost same as itertext
                            verseText = "|".join(verse.itertext())
                            if "cleanUp" in postParsing:
                                verseText = verseText.replace(r"[\n\t\r]*", "").replace(r"[\s+]*", " ").replace("�", " - ").strip()
                        except:
                            verseText = "parsing error"
                        allVersesList1.append ([ bookNr, chapterNr, verseNr, str( verseText) ])
                lastChapterList1[int(bookNr)-1] = (int(chapterNr))

    if os.path.exists(filePath2):
        # parse metadata first
        root = ET.parse(filePath2).getroot()
        for info1 in root.iter('XMLBIBLE'):
            try:
                infotitle2 = str(info1.attrib["biblename"])
            except:
                infotitle2 = "n/a"
            try:
                infoversion2 = str(info1.attrib["version"])
            except:
                infoversion2 = "n/a"
        for info2 in root.iter('language'):
            try:
                infolanguage2 = str(info2.text)
            except:
                infolanguage2 = "n/a"
        for info3 in root.iter('date'):
            try:
                infodate2 = str(info3.text)
            except:
                infodate2 = "n/a"

        # plausibility and missing books test for file loading ... do not allow book to be loaded
        tmpBooksList = []
        parseFull = True
        for indexBook, book in enumerate(root.iter('BIBLEBOOK')):
            try:
                bookNr = book.attrib["bnumber"]
            except:
                bookNr = indexBook + 1
            tmpBooksList.append(int(bookNr))
            #pyotherside.send('debugPythonLogs', tmpBooksList)
            #if (all(x2-x1 == 1 for x1, x2 in zip(tmpBooksList[:-1], tmpBooksList[1:])) is False) : # strict sorted list upwards
            if ( (tmpBooksList != sorted(tmpBooksList)) or (int(bookNr) > len(lastChapterList2)) or (int(bookNr) > 66 and len(tmpBooksList) <= 66 ) or (len(tmpBooksList) != len(set(tmpBooksList))) ): # 4 integrity tests: not_ascending OR too_large_number OR same_booknumber_twice
                pyotherside.send('errorParsingFile', tmpBooksList, filePath2, previewFull)
                parseFull = False
                break
            else:
                pyotherside.send('successParsingFile', filePath2, previewFull)

        # parse verses next
        if "full" in previewFull and parseFull is True :
            for indexBook, book in enumerate(root.iter('BIBLEBOOK')):
                try:
                    bookNr = book.attrib["bnumber"]
                except:
                    bookNr = indexBook + 1

                for indexChapter, chapter in enumerate(book):
                    try:
                        chapterNr = chapter.attrib["cnumber"]
                    except:
                        chapterNr = indexChapter + 1

                    for indexVerse, verse in enumerate(chapter):
                        try:
                            verseNr = verse.attrib["vnumber"]
                        except:
                            verseNr = indexVerse + 1
                        try:
                            verseText = "|".join(verse.itertext())
                            if "cleanUp" in postParsing:
                                verseText = verseText.replace(r"[\n\t\r]*", "").replace(r"[\s+]*", " ").replace("�", " - ").strip()
                        except:
                            verseText = "parsing error"

                        allVersesList2.append ([ bookNr, chapterNr, verseNr, str( verseText) ])
                lastChapterList2[int(bookNr)-1] = (int(chapterNr))

    if "full" in previewFull:
        pyotherside.send('finishedParsing', previewFull, allVersesList1, allVersesList2, lastChapterList1, lastChapterList2)
    pyotherside.send('gotBibleMetadata', previewFull, infotitle1, infotitle2, infoversion1, infoversion2, infolanguage1, infolanguage2, infodate1, infodate2 )


def findVerses ( searchWordsList, currentBookNr, currentChapterNr ):
    def checkContainsWords(verseText, searchWordsList):
        found = True
        for searchWord in searchWordsList:
            if searchWord not in verseText.lower():
                found = False
        return found

    foundVersesInBible = []
    foundVersesInCurrentBook = []
    foundVersesInCurrentChapter = []
    #pyotherside.send('debugPythonLogs', currentBookNr)
    #pyotherside.send('debugPythonLogs', currentChapterNr)
    resultsList = []
    for curentVerse in allVersesList1:
        bookNr = curentVerse[0]
        chapterNr = curentVerse[1]
        verseNr = curentVerse[2]
        verseText = curentVerse[3]
        verseContained = checkContainsWords(verseText, searchWordsList)
        if verseContained is True:
            foundVersesInBible.append([ bookNr, chapterNr, verseNr, verseText ])
            if int(bookNr) is int(currentBookNr):
                foundVersesInCurrentBook.append([ bookNr, chapterNr, verseNr, verseText ])
                if int(chapterNr) is int(currentChapterNr):
                    foundVersesInCurrentChapter.append([ bookNr, chapterNr, verseNr, verseText ])
    pyotherside.send('gotSearchResults', foundVersesInBible, "fullBible")
    pyotherside.send('gotSearchResults', foundVersesInCurrentBook, "currentBook")
    pyotherside.send('gotSearchResults', foundVersesInCurrentChapter, "currentChapter")




def findOldDatabaseBookmarks ():
    oldDatabaseFolder = str(Path.home()) + "/.local/share/harbour-bible/harbour-bible/QML/OfflineStorage/Databases/"
    oldDatabaseFile = ""
    foundBookmarks = []
    for subdir, dirs, files in os.walk(oldDatabaseFolder):
        for file in files:
            if file.endswith('.sqlite'):
                oldDatabaseFile = str(file)
                try:
                    conn = sqlite3.connect(oldDatabaseFolder + "/" + oldDatabaseFile)
                    c = conn.cursor()
                    c.execute('SELECT * FROM bookmarks')
                    data = c.fetchall()
                    for row in data:
                        tmpListBookmarksRow = []
                        for column in row:
                            tmpListBookmarksRow.append(column)
                        foundBookmarks.append(tmpListBookmarksRow)
                except:
                    pyotherside.send('debugPythonLogs', "no bookmarks found")
            os.rename(oldDatabaseFolder + "/" + file, oldDatabaseFolder + "/" + file + ".backup")
    pyotherside.send('restoreOldDatabaseBookmarks', foundBookmarks)


def isFormerDBavailable ():
    oldDatabaseFolder = str(Path.home()) + "/.local/share/harbour-bible/harbour-bible/QML/OfflineStorage/Databases/"
    foundBookmarks = []
    for subdir, dirs, files in os.walk(oldDatabaseFolder):
        for file in files:
            if file.endswith('.sqlite'):
                pyotherside.send('formerDB_BookmarksAvailable', )
