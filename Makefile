TARGETS = $(BDFS) $(TTFS) $(WEBSITE_TTFS)

DEPS       = src/bitmap/TractorFeedSans.chars.txt \
             src/bitmap/TractorFeedSerif.chars.txt
SRC_FONTS  = \
             src/bitmap/TractorFeedSans-SmCn.font.txt \
             src/bitmap/TractorFeedSans-Regular.font.txt \
             src/bitmap/TractorFeedSans-Cond.font.txt \
             src/bitmap/TractorFeedSerif-SmCn.fon.txt \
             src/bitmap/TractorFeedSerif-Regular.font.txt \
             src/bitmap/TractorFeedSerif-Cond.font.txt
BDFS       = $(patsubst src/bitmap/%.font.txt,dist/bdf/%.bdf,$(SRC_FONTS))
TTFS       = $(patsubst src/bitmap/%.font.txt,dist/ttf/%.ttf,$(SRC_FONTS))
WEBSITE_TTFS = $(patsubst src/bitmap/%.font.txt,public/ttf/%.ttf,$(SRC_FONTS))

# BDFBDF                 = ~/git/dse.d/perl-font-bitmap/bin/bdfbdf
BDFBDF                 = ~/git/dse.d/perl-font-bdf/bin/bdf2bdf
BDFBDF_OPTIONS         =
BITMAPFONT2TTF         = bitmapfont2ttf
BITMAPFONT2TTF_OPTIONS = --dot-width 1 --dot-height 1 --circular-dots

default: $(TARGETS)
website: $(WEBSITE_TTFS)

debug:
	BITMAPFONT2TTF=1 make default

dist/bdf/%.bdf: src/bitmap/%.font.txt $(DEPS) Makefile
	mkdir -p dist/bdf || true
	$(BDFBDF) $(BDFBDF_OPTIONS) $< > $@.tmp.bdf
	mv $@.tmp.bdf $@

dist/ttf/%.ttf: dist/bdf/%.bdf Makefile
	mkdir -p dist/ttf || true
	$(BITMAPFONT2TTF) $(BITMAPFONT2TTF_OPTIONS) $< $@.tmp.ttf
	mv $@.tmp.ttf $@

public/ttf/%.ttf: dist/ttf/%.ttf Makefile
	mkdir -p public/ttf || true
	cp $< $@.tmp.ttf
	mv $@.tmp.ttf $@

clean:
	/bin/rm $(BDFS) $(TTFS) */*.tmp.* >/dev/null 2>/dev/null || true

publish1:
	rsync -av dist/ttf/ dse@webonastick.com:/www/webonastick.com/htdocs/demos/tractorfeed/fonts
