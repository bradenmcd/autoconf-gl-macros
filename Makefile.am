ACLOCAL_AMFLAGS = -I m4

dist-hook:
	if test -d $(top_srcdir)/.svn; then \
    (cd $(top_srcdir) && (if test -e ChangeLog; then rm ChangeLog; fi) && svn2cl --group-by-day); \
    cp $(top_srcdir)/ChangeLog $(distdir); \
fi
