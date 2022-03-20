# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-bible

CONFIG += sailfishapp

QT += qml quick xmlpatterns

SOURCES += src/harbour-bible.cpp

DISTFILES += qml/harbour-bible.qml \
    qml/cover/CoverPage.qml \
    qml/pages/AboutPage.qml \
    qml/pages/BannerBookmarks.qml \
    qml/pages/BannerBooks.qml \
    qml/pages/BannerNotes.qml \
    qml/pages/BannerSearch.qml \
    qml/pages/FirstPage.qml \
    qml/pages/ScrollBar.qml \
    qml/pages/SettingsPage.qml \
    rpm/harbour-bible.changes.in \
    rpm/harbour-bible.changes.run.in \
    rpm/harbour-bible.spec \
    rpm/harbour-bible.yaml \
    translations/*.ts \
    harbour-bible.desktop \
    translations/harbour-bible-ru.ts \
    translations/harbour-bible-de.ts \
    translations/harbour-bible-hu.ts \
    translations/harbour-bible-fi.ts \

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-bible-de.ts \
    translations/harbour-bible-ru.ts \
    translations/harbour-bible-hu.ts \
    translations/harbour-bible-fi.ts \

HEADERS +=
