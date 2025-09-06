default: $(TARGETS) zip web

BDF_SRC			:= src/bitmap/bdf
SRC_DATA		:= src/bitmap/data
SRC_DATA_DOUBLESTRIKE	:= tmp/_build/src/bitmap/data
DIST_TTF		:= dist/ttf
DIST_BDF		:= dist/bdf
DIST_ZIP		:= dist/zip
SUPPORT_BIN		:= exec/bin

DIST_ZIP_TO_DIST_TTF	:= ../ttf
DIST_ZIP_TO_DIST_BDF	:= ../bdf

#		   XXX.YZZ, typically
SFNT_REVISION	:= 000.200

VERSION		:= 0.2.0
VENDOR		:= DARN
COPYRIGHT_OWNER	:= Darren Embry
COPYRIGHT_EMAIL	:= dsembry@gmail.com

clean: FORCE
	rm -fr tmp/_build || true
	/bin/rm $(DIST_BDF)/*.bdf $(DIST_TTF)/*.ttf \
		>/dev/null 2>/dev/null || true
	find . -type f \( -name '*.tmp' -o -name '*.tmp.*' \) -exec rm {} + \
		>/dev/null 2>/dev/null || true

TARGETS = $(BDFS) $(TTFS)

BDFS = $(patsubst $(BDF_SRC)/%.src.bdf,$(DIST_BDF)/%.bdf,$(SRC_FONTS))
TTFS = $(patsubst $(BDF_SRC)/%.src.bdf,$(DIST_TTF)/%.ttf,$(SRC_FONTS))

SRC_BITMAPS_REG	= $(SRC_DATA)/TractorFeedSans.data.txt \
		  $(SRC_DATA)/TractorFeedSerif.data.txt
SRC_BITMAPS_DS	= $(patsubst $(SRC_DATA)/%.data.txt,$(SRC_DATA_DOUBLESTRIKE)/%.doublestrike.data.txt,$(SRC_BITMAPS_REG))
SRC_BITMAPS	= $(SRC_BITMAPS_REG) $(SRC_BITMAPS_DS)

SRC_FONTS	= $(BDF_SRC)/TractorFeedSans-SmCn.src.bdf \
		  $(BDF_SRC)/TractorFeedSans-Regular.src.bdf \
		  $(BDF_SRC)/TractorFeedSans-Cond.src.bdf \
		  $(BDF_SRC)/TractorFeedSerif-SmCn.src.bdf \
		  $(BDF_SRC)/TractorFeedSerif-Regular.src.bdf \
		  $(BDF_SRC)/TractorFeedSerif-Cond.src.bdf \
		  $(BDF_SRC)/TractorFeedSans-SmCnBd.src.bdf \
		  $(BDF_SRC)/TractorFeedSans-Bold.src.bdf \
		  $(BDF_SRC)/TractorFeedSans-CnBd.src.bdf \
		  $(BDF_SRC)/TractorFeedSerif-SmCnBd.src.bdf \
		  $(BDF_SRC)/TractorFeedSerif-Bold.src.bdf \
		  $(BDF_SRC)/TractorFeedSerif-CnBd.src.bdf \

DS_PROG			= $(SUPPORT_BIN)/doublestrike.py
BDFBDF			= ~/git/dse.d/perl-font-bdf/bin/bdf2bdf
BDFBDF_OPTIONS		=
BITMAPFONT2TTF		= bitmapfont2ttf
BITMAPFONT2TTF_OPTIONS	= --dot-width 1 --dot-height 1 --circular-dots

doublestrike: $(SRC_BITMAPS_DS) $(SRC_FONTS_DS) $(DS_PROG) Makefile

$(SRC_DATA_DOUBLESTRIKE)/%.doublestrike.data.txt: $(SRC_DATA)/%.data.txt Makefile $(DS_PROG)
	mkdir -p $(SRC_DATA_DOUBLESTRIKE)
	$(DS_PROG) < $< > $@.tmp
	mv $@.tmp $@

dist/bdf/%.bdf: src/bitmap/bdf/%.src.bdf $(SRC_BITMAPS) Makefile
	mkdir -p dist/bdf || true
	$(BDFBDF) $(BDFBDF_OPTIONS) $< > $@.tmp.bdf
	mv $@.tmp.bdf $@

$(DIST_TTF)/%.ttf: $(DIST_BDF)/%.bdf $(SRC_BITMAPS) $(SUPPORT_BIN)/set-metas.py Makefile
	mkdir -p $(DIST_TTF) || true
	$(BITMAPFONT2TTF) $(BITMAPFONT2TTF_OPTIONS) $< $@.tmp.ttf
	mv $@.tmp.ttf $@
	$(SUPPORT_BIN)/set-metas.py \
		--sfnt-revision "$(SFNT_REVISION)" \
		--ps-version "$(VERSION)" \
		--vendor "$(VENDOR)" \
		"$@"
	fontofl --owner "$(COPYRIGHT_OWNER)" --email "$(COPYRIGHT_EMAIL)" "$@"

ZIP_FILE       = $(DIST_ZIP)/TractorFeed-$(VERSION).zip
UNVER_ZIP_FILE = $(DIST_ZIP)/TractorFeed.zip

zip: $(ZIP_FILE) $(UNVER_ZIP_FILE)

$(ZIP_FILE): $(TTFS) $(BDFS)
	cd $(DIST_ZIP) && \
		bsdtar -c -f "TractorFeed-$(VERSION).zip" \
		--format zip \
		-s '#^\.\./ttf#TractorFeed-$(VERSION)#' \
		-s '#^\.\./bdf#TractorFeed-$(VERSION)#' \
		$(DIST_ZIP_TO_DIST_TTF) \
		$(DIST_ZIP_TO_DIST_BDF)

$(UNVER_ZIP_FILE): $(ZIP_FILE)
	cp $(ZIP_FILE) $(UNVER_ZIP_FILE)

web: $(ZIP_FILE) $(UNVER_ZIP_FILE) $(BDFS) $(TTFS)
	rsync -av dist/ public/dist/

publish:
	ssh dse@webonastick.com 'cd git/dse.d/fonts.d/tractorfeed-fonts && git pull'


.PHONY: FORCE
