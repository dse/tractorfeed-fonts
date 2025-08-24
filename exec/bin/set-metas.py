#!/usr/bin/env -S fontforge -quiet
# -*- mode: python; coding: utf-8 -*-
import fontforge, sys, argparse
from datetime import date
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('filename')
    parser.add_argument('--sfnt-revision', type=float, metavar='XXX.YZZ', help='XXX = major, Y = minor, ZZ = patch; e.g., "000.902"')
    parser.add_argument('--ps-version', type=str, metavar='VERSION', help='a string containing the actual version number, e.g., "0.9.2", "9.2.0-beta", etc.')
    parser.add_argument('--vendor', type=str, metavar='VENDOR', help='your 4-character (registered) font vendor string')
    parser.add_argument('--copyright-owner', type=str, metavar='NAME', help='Add copyright/SIL-OFL message using your name', default='Darren Embry')
    args = parser.parse_args()

    print("Opening: %s" % args.filename)
    font = fontforge.open(args.filename)

    if args.vendor is not None:
        font.os2_vendor = args.vendor

    copyright_year = date.today().year

    if args.copyright_owner is not None:
        font.copyright = "Copyright %d %s.  SIL Open Font License Version 1.1.  https://openfontlicense.org/open-font-license-official-text/" % \
            (copyright_year, args.copyright_owner)

    if args.sfnt_revision is not None:
        font.sfntRevision = args.sfnt_revision

    if args.ps_version is not None:
        font.version = args.ps_version
        font.appendSFNTName(1033, "Version", font.version)

    print("Writing: %s" % args.filename)
    if args.filename.endswith('.sfd'):
        font.save(args.filename)
    else:
        font.generate(args.filename)
    font.close()
main()
