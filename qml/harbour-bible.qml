import QtQuick 2.6
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "pages"

ApplicationWindow
{
    // settings that do not need to be reloaded from database in case of change in settings for efficiency
    property bool reloadDBSettings : false

    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    // must be forced to show on FirstPage when image background not shown on firstPage... otherwise would be black only
    //background.image: Theme.backgroundImage
    _backgroundVisible : true

    Item {
        id: storageItem

        function getDatabase() {
           return storageItem.LocalStorage.openDatabaseSync("Bible_DB", "0.1", "BibleDatabaseComplete", 5000000); // 5 MB estimated size
        }

        function setSettings( setting, value ) {
          var db = getDatabase();
          var res = "";
           db.transaction(function(tx) {
             tx.executeSql('CREATE TABLE IF NOT EXISTS ' + 'settings_table' + '(setting TEXT UNIQUE, value TEXT)');
            var rs = tx.executeSql('INSERT OR REPLACE INTO ' + 'settings_table' + ' VALUES (?,?);', [setting,value]);
              if (rs.rowsAffected > 0) {
               res = "OK";
              } else {
               res = "Error";
              }
            }
           );
           return res;
        }

        function getSettings( setting, default_value ) {
           var db = getDatabase();
           var res="";
           try {
            db.transaction(function(tx) {
             var rs = tx.executeSql('SELECT value FROM '+ 'settings_table' +' WHERE setting=?;', [setting]);
              if (rs.rows.length > 0) {
               res = rs.rows.item(0).value;
              } else {
               res = default_value;
              }
              if (res === null) {
                  res = default_value
              }
            })
           } catch (err) {
             //console.log("Database " + err);
            res = default_value;
           };
           //console.log(setting + " = " + res)
           return res
        }

        function setInfos( categ_info, translat1_info, translat2_info ) {
          var db = getDatabase();
          var res = "";
           db.transaction(function(tx) {
             tx.executeSql('CREATE TABLE IF NOT EXISTS ' + 'info_table' + '(category_info TEXT UNIQUE, translation1_info TEXT, translation2_info TEXT)');
            var rs = tx.executeSql('INSERT OR REPLACE INTO ' + 'info_table' + ' VALUES (?,?,?);', [categ_info,translat1_info,translat2_info]);
              if (rs.rowsAffected > 0) {
               res = "OK";
              } else {
               res = "Error";
              }
            }
           );
           return res;
        }

        function setNote( note_id, bookNumber, bookNameLong, bookNameShort, chapterNumber, verseNumber, verse, noteText ) {
          var db = getDatabase();
          var res = "";
           db.transaction(function(tx) {
             tx.executeSql('CREATE TABLE IF NOT EXISTS ' + 'notes' + '(note_id INTEGER, bookNumber INTEGER, bookNameLong TEXT, bookNameShort TEXT, chapterNumber INTEGER, verseNumber INTEGER, verse TEXT, noteText TEXT)');
            var rs = tx.executeSql('INSERT OR REPLACE INTO ' + 'notes' + ' VALUES (?,?,?,?,?,?,?,?);', [ note_id, bookNumber, bookNameLong, bookNameShort, chapterNumber, verseNumber, verse, noteText ]);
              if (rs.rowsAffected > 0) {
               res = "OK";
              } else {
               res = "Error";
              }
            }
           );
           return res;
        }

        function getNote( note_id, default_value ) {
           var db = getDatabase();
           var res=[];
           try {
            db.transaction(function(tx) {
             //var rs = tx.executeSql('SELECT note_id,bookNumber,bookNameLong,bookNameShort,chapterNumber,verseNumber,verse,noteText FROM '+ 'notes' +' WHERE note_id=?;', [note_id]);
             var rs = tx.executeSql('SELECT * FROM '+ 'notes' +' WHERE note_id=?;', [note_id]);
              if (rs.rows.length > 0) {
                for (var i = 0; i < rs.rows.length; i++) {
                 res.push(rs.rows.item(i).note_id)
                 res.push(rs.rows.item(i).bookNumber)
                 res.push(rs.rows.item(i).bookNameLong)
                 res.push(rs.rows.item(i).bookNameShort)
                 res.push(rs.rows.item(i).chapterNumber)
                 res.push(rs.rows.item(i).verseNumber)
                 res.push(rs.rows.item(i).verse)
                 res.push(rs.rows.item(i).noteText)
                }
              } else {
               res = default_value;
              }
            })
           } catch (err) {
             //console.log("Database " + err);
            res = default_value;
           };
           return res
        }

        function updateNote ( bookNumber, chapterNumber, verseNumber, noteText ) {
            var db = getDatabase();
            var res = "";
             db.transaction(function(tx) {
              tx.executeSql('CREATE TABLE IF NOT EXISTS ' + 'notes' + '(note_id INTEGER, bookNumber INTEGER, bookNameLong TEXT, bookNameShort TEXT, chapterNumber INTEGER, verseNumber INTEGER, verse TEXT, noteText TEXT)');
              var rs = tx.executeSql('UPDATE notes SET noteText="' + noteText + '" WHERE bookNumber=' + bookNumber + ' AND chapterNumber=' + chapterNumber + ' AND verseNumber=' + verseNumber + ';');
                if (rs.rowsAffected > 0) {
                 res = "OK";
                } else {
                 res = "Error";
                }
              }
             );
             return res;
        }

        function setBookmark( bookmark_id, bookNumber, bookNameLong, bookNameShort, chapterNumber, verseNumber, verse ) {
          var db = getDatabase();
          var res = "";
           db.transaction(function(tx) {
             tx.executeSql('CREATE TABLE IF NOT EXISTS ' + 'bookmarks' + '(bookmark_id INTEGER, bookNumber INTEGER, bookNameLong TEXT, bookNameShort TEXT, chapterNumber INTEGER, verseNumber INTEGER, verse TEXT)');
            var rs = tx.executeSql('INSERT OR REPLACE INTO ' + 'bookmarks' + ' VALUES (?,?,?,?,?,?,?);', [ bookmark_id, bookNumber, bookNameLong, bookNameShort, chapterNumber, verseNumber, verse ]);
              if (rs.rowsAffected > 0) {
               res = "OK";
              } else {
               res = "Error";
              }
            }
           );
           return res;
        }

        function getBookmark( bookmark_id, default_value ) {
           var db = getDatabase();
           var res=[];
           try {
            db.transaction(function(tx) {
             //var rs = tx.executeSql('SELECT bookmark_id,bookNumber,bookNameLong,bookNameShort,chapterNumber,verseNumber,verse FROM '+ 'bookmarks' +' WHERE bookmark_id=?;', [bookmark_id]);
             var rs = tx.executeSql('SELECT * FROM '+ 'bookmarks' +' WHERE bookmark_id=?;', [bookmark_id]);
              if (rs.rows.length > 0) {
                for (var i = 0; i < rs.rows.length; i++) {
                 res.push(rs.rows.item(i).bookmark_id)
                 res.push(rs.rows.item(i).bookNumber)
                 res.push(rs.rows.item(i).bookNameLong)
                 res.push(rs.rows.item(i).bookNameShort)
                 res.push(rs.rows.item(i).chapterNumber)
                 res.push(rs.rows.item(i).verseNumber)
                 res.push(rs.rows.item(i).verse)
                }
              } else {
               res = default_value;
              }
            })
           } catch (err) {
             //console.log("Database " + err);
            res = default_value;
           };
           return res
        }

        function getAllBookmarks( default_value, orderType ) {
           var db = getDatabase();
           var res=[];
           try {
            db.transaction(function(tx) {
             if (orderType === "orderBible") {
              var rs = tx.executeSql('SELECT * FROM '+ 'bookmarks ORDER BY bookNumber, chapterNumber, verseNumber;')
             } else {
              rs = tx.executeSql('SELECT * FROM '+ 'bookmarks;')
             }
              if (rs.rows.length > 0) {
                for (var i = 0; i < rs.rows.length; i++) {
                 res.push([rs.rows.item(i).bookmark_id,
                          rs.rows.item(i).bookNumber,
                          rs.rows.item(i).bookNameLong,
                          rs.rows.item(i).bookNameShort,
                          rs.rows.item(i).chapterNumber,
                          rs.rows.item(i).verseNumber,
                          rs.rows.item(i).verse])
                }
              } else {
               res = default_value;
              }
            })
           } catch (err) {
             //console.log("Database " + err);
            res = default_value;
           };
           return res
        }

        function getInfos( categ_info, column_info, default_value ) {
           var db = getDatabase();
           var res="";
           try {
            db.transaction(function(tx) {
             var rs = tx.executeSql('SELECT ' + column_info + ' AS some_info FROM '+ 'info_table' +' WHERE category_info=?;', [categ_info]);
              if (rs.rows.length > 0) {
               res = rs.rows.item(0).some_info;

              } else {
               res = default_value;
              }
            })
           } catch (err) {
            //console.log("Database " + err);
            res = default_value;
           };
           return res
        }

        /*
        function getBibleRawtext( tableName, value, default_value ) {
            var db = getDatabase();
            var res="";
            try {
             db.transaction(function(tx) {
              var rs = tx.executeSql('SELECT ' + value + ' AS this_info FROM '+ tableName +';');
               if (rs.rows.length > 0) {
                res = rs.rows.item(0).this_info;
               } else {
                res = default_value;
               }
             })
            } catch (err) {
             //console.log("Database " + err);
             res = default_value;
            };
            return res
         }

        function setBibleRawtext(tableName, rawBooksIncluded, rawChaptersIncluded, rawVersnumbersIncluded, rawVersesIncluded) { // tableName -> use 'table_bible_raw1' and 'table_bible_raw2 independently' -> then merge to combined table later
          var db = getDatabase();
          var res = "";
           db.transaction(function(tx) { tx.executeSql('DROP TABLE IF EXISTS ' + tableName) });
           db.transaction(function(tx) { tx.executeSql('CREATE TABLE IF NOT EXISTS ' + tableName + '( arrayBooknumbers TEXT, arrayChapternumbers TEXT, arrayVersenumbers TEXT, arrayVerses TEXT )') });
           db.transaction(function(tx) {
            var rs = tx.executeSql('INSERT INTO ' + tableName + ' VALUES (?,?,?,?);', [ rawBooksIncluded, rawChaptersIncluded, rawVersnumbersIncluded, rawVersesIncluded ]);
            });
        }
        */
        // more general functions
        function removeFullTable (tableName) {
            var db = getDatabase();
            var res = "";
            db.transaction(function(tx) { tx.executeSql('DROP TABLE IF EXISTS ' + tableName) });
        }

        function getTableCount (tableName, default_value) {
             var db = getDatabase();
             var res="";
             try {
              db.transaction(function(tx) {
               var rs = tx.executeSql('SELECT count(*) AS some_info FROM ' + tableName + ';');
                if (rs.rows.length > 0) {
                 res = rs.rows.item(0).some_info;

                } else {
                 res = default_value;
                }
              })
             } catch (err) {
              //console.log("Database " + err);
              res = default_value;
             };
             return res
        }
    }
}
