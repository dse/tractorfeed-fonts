default: $(TARGETS) zip web

VERSION = 0.1.0

clean: FORCE
	/bin/rm src/bitmap/*.doublestrike.*.txt \
		>/dev/null 2>/dev/null || true
	/bin/rm src/bitmap/*.doublestrike.*.txt \
		>/dev/null 2>/dev/null || true
	/bin/rm dist/bdf/*.bdf dist/ttf/*.ttf \
		>/dev/null 2>/dev/null || true
	find . -type f \( -name '*.tmp' -o -name '*.tmp.*' \) -exec rm {} + \
		>/dev/null 2>/dev/null || true

TARGETS = $(BDFS) $(TTFS)

BDFS = $(patsubst src/bitmap/bdf/%.src.bdf,dist/bdf/%.bdf,$(SRC_FONTS))
TTFS = $(patsubst src/bitmap/bdf/%.src.bdf,dist/ttf/%.ttf,$(SRC_FONTS))

SRC_BITMAPS_REG	= src/bitmap/TractorFeedSans.chars.txt \
		  src/bitmap/TractorFeedSerif.chars.txt
SRC_BITMAPS_DS	= $(patsubst %.chars.txt,%.doublestrike.chars.txt,$(SRC_BITMAPS_REG))
SRC_BITMAPS	= $(SRC_BITMAPS_REG) $(SRC_BITMAPS_DS)

SRC_FONTS	= src/bitmap/bdf/TractorFeedSans-SmCn.src.bdf \
		  src/bitmap/bdf/TractorFeedSans-Regular.src.bdf \
		  src/bitmap/bdf/TractorFeedSans-Cond.src.bdf \
		  src/bitmap/bdf/TractorFeedSerif-SmCn.src.bdf \
		  src/bitmap/bdf/TractorFeedSerif-Regular.src.bdf \
		  src/bitmap/bdf/TractorFeedSerif-Cond.src.bdf \
		  src/bitmap/bdf/TractorFeedSans-SmCnBd.src.bdf \
		  src/bitmap/bdf/TractorFeedSans-Bold.src.bdf \
		  src/bitmap/bdf/TractorFeedSans-CnBd.src.bdf \
		  src/bitmap/bdf/TractorFeedSerif-SmCnBd.src.bdf \
		  src/bitmap/bdf/TractorFeedSerif-Bold.src.bdf \
		  src/bitmap/bdf/TractorFeedSerif-CnBd.src.bdf \

DS_PROG			= bin/doublestrike
BDFBDF			= ~/git/dse.d/perl-font-bdf/bin/bdf2bdf
BDFBDF_OPTIONS		=
BITMAPFONT2TTF		= bitmapfont2ttf
BITMAPFONT2TTF_OPTIONS	= --dot-width 1 --dot-height 1 --circular-dots

doublestrike: $(SRC_BITMAPS_DS) $(SRC_FONTS_DS) $(DS_PROG) Makefile

src/bitmap/%.doublestrike.chars.txt: src/bitmap/%.chars.txt Makefile $(DS_PROG)
	$(DS_PROG) < $< > $@.tmp
	mv $@.tmp $@

src/bitmap/bdf/%.doublestrike.src.bdf: src/bitmap/bdf/%.src.bdf Makefile $(DS_PROG)
	$(DS_PROG) < $< > $@.tmp
	mv $@.tmp $@

dist/bdf/%.bdf: src/bitmap/bdf/%.src.bdf $(SRC_BITMAPS) Makefile
	mkdir -p dist/bdf || true
	$(BDFBDF) $(BDFBDF_OPTIONS) $< > $@.tmp.bdf
	mv $@.tmp.bdf $@

dist/ttf/%.ttf: dist/bdf/%.bdf $(SRC_BITMAPS) Makefile
	mkdir -p dist/ttf || true
	$(BITMAPFONT2TTF) $(BITMAPFONT2TTF_OPTIONS) $< $@.tmp.ttf
	mv $@.tmp.ttf $@

ZIP_FILE       = dist/zip/TractorFeed-$(VERSION).zip
UNVER_ZIP_FILE = dist/zip/TractorFeed.zip

zip: $(ZIP_FILE) $(UNVER_ZIP_FILE)

$(ZIP_FILE): $(TTFS) $(BDFS)
	cd dist/zip && \
		bsdtar -c -f "TractorFeed-$(VERSION).zip" \
		--format zip \
		-s '#^\.\./ttf#TractorFeed-$(VERSION)#' \
		-s '#^\.\./bdf#TractorFeed-$(VERSION)#' \
		../ttf ../bdf

$(UNVER_ZIP_FILE): $(ZIP_FILE)
	cp $(ZIP_FILE) $(UNVER_ZIP_FILE)

web: $(ZIP_FILE) $(UNVER_ZIP_FILE) $(BDFS) $(TTFS)
	rsync -av dist/ public/dist/

publish:
	ssh dse@webonastick.com 'cd git/dse.d/fonts.d/tractorfeed-fonts && git pull'

.PHONY: FORCE
