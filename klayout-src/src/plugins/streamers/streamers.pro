
TEMPLATE = subdirs

# Automatically include all sub-folders, but not the .pro file
SUBDIR_LIST = $$files($$PWD/*)
SUBDIR_LIST -= $$PWD/streamers.pro

SUBDIRS = $$SUBDIR_LIST

# CommonDB CORE reader (streamers/mcore → CommonDB/integrations/klayout/mcore)
SUBDIRS += mcore
