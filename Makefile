
docs: AppleDoc/docset-installed.txt

SOURCEDIR = LFSClient
SOURCES := $(shell find $(SOURCEDIR) -name '*.h' -o -name '*.m')

AppleDoc/docset-installed.txt: $(SOURCES)
	appledoc \
		--output AppleDoc \
		--project-name "StreamHub-iOS-SDK" \
		--project-company "Livefyre" \
		--project-version "0.3.1" \
		--keep-undocumented-objects \
		--keep-undocumented-members \
		--company-id "com.livefyre.streamhub_ios_sdk" \
		$(SOURCEDIR)
