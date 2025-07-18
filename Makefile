default:
	@for i in $(TARGETS); do echo $$i; done
	make $(TARGETS)

clean: FORCE
	/bin/rm src/bitmap/*.ds.*.txt \
		>/dev/null 2>/dev/null || true
	/bin/rm src/bitmap/*.doublestrike.*.txt \
		>/dev/null 2>/dev/null || true
	/bin/rm dist/bdf/*.bdf dist/ttf/*.ttf \
		>/dev/null 2>/dev/null || true
	find . -type f \( -name '*.tmp' -o -name '*.tmp.*' \) -exec rm {} + \
		>/dev/null 2>/dev/null || true

TARGETS = $(BDFS) $(TTFS) $(WEB_TTFS)

BDFS = $(patsubst src/bitmap/%.font.txt,dist/bdf/%.bdf,$(SRC_FONTS))
TTFS = $(patsubst src/bitmap/%.font.txt,dist/ttf/%.ttf,$(SRC_FONTS))

SRC_BITMAPS_REG	= src/bitmap/TractorFeedSans.chars.txt \
		  src/bitmap/TractorFeedSerif.chars.txt
SRC_BITMAPS_DS	= $(patsubst %.chars.txt,%.ds.chars.txt,$(SRC_BITMAPS_REG))
SRC_BITMAPS	= $(SRC_BITMAPS_REG) $(SRC_BITMAPS_DS)

SRC_FONTS	= src/bitmap/TractorFeedSans-SmCn.font.txt \
		  src/bitmap/TractorFeedSans-Regular.font.txt \
		  src/bitmap/TractorFeedSans-Cond.font.txt \
		  src/bitmap/TractorFeedSerif-SmCn.font.txt \
		  src/bitmap/TractorFeedSerif-Regular.font.txt \
		  src/bitmap/TractorFeedSerif-Cond.font.txt \
		  src/bitmap/TractorFeedSans-SmCnBd.font.txt \
		  src/bitmap/TractorFeedSans-Bold.font.txt \
		  src/bitmap/TractorFeedSans-CnBd.font.txt \
		  src/bitmap/TractorFeedSerif-SmCnBd.font.txt \
		  src/bitmap/TractorFeedSerif-Bold.font.txt \
		  src/bitmap/TractorFeedSerif-CnBd.font.txt \

DS_PROG			= bin/doublestrike
BDFBDF			= ~/git/dse.d/perl-font-bdf/bin/bdf2bdf
BDFBDF_OPTIONS		=
BITMAPFONT2TTF		= bitmapfont2ttf
BITMAPFONT2TTF_OPTIONS	= --dot-width 1 --dot-height 1 --circular-dots

doublestrike: $(SRC_BITMAPS_DS) $(SRC_FONTS_DS) $(DS_PROG) Makefile

src/bitmap/%.ds.chars.txt: src/bitmap/%.chars.txt Makefile $(DS_PROG)
	$(DS_PROG) < $< > $@.tmp
	mv $@.tmp $@

src/bitmap/%.ds.font.txt: src/bitmap/%.font.txt Makefile $(DS_PROG)
	$(DS_PROG) < $< > $@.tmp
	mv $@.tmp $@

dist/bdf/%.bdf: src/bitmap/%.font.txt $(SRC_BITMAPS) Makefile
	mkdir -p dist/bdf || true
	$(BDFBDF) $(BDFBDF_OPTIONS) $< > $@.tmp.bdf
	mv $@.tmp.bdf $@

dist/ttf/%.ttf: dist/bdf/%.bdf $(SRC_BITMAPS) Makefile
	mkdir -p dist/ttf || true
	$(BITMAPFONT2TTF) $(BITMAPFONT2TTF_OPTIONS) $< $@.tmp.ttf
	mv $@.tmp.ttf $@

WEB_BDFS = $(patsubst src/bitmap/%.font.txt,public/dist/bdf/%.bdf,$(SRC_FONTS))
WEB_TTFS = $(patsubst src/bitmap/%.font.txt,public/dist/ttf/%.ttf,$(SRC_FONTS))

public/dist/bdf/%.bdf: dist/bdf/%.bdf Makefile
	cp "$<" "$@"
public/dist/ttf/%.ttf: dist/ttf/%.ttf Makefile
	cp "$<" "$@"

.PHONY: FORCE
