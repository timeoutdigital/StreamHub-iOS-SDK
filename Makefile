
docs: AppleDoc/docset-installed.txt

SOURCEDIR = LFSClient
SOURCES := $(shell find $(SOURCEDIR) -name '*.h' -o -name '*.m')

AppleDoc/docset-installed.txt: $(SOURCES)
	appledoc \
		--output AppleDoc \
		--project-name "StreamHub-iOS-SDK" \
		--project-company "Livefyre" \
		--company-id "com.livefyre.streamhub_ios_sdk" \
		$(SOURCEDIR)
