dnl
dnl Check for GLU.  If GLU is found, the required preprocessor and linker flags
dnl are included in the output variables "GLU_CFLAGS" and "GLU_LIBS",
dnl respectively.  If no GLU implementation is found, "no_glu" is set to "yes".
dnl
dnl If the header "GL/glu.h" is found, "HAVE_GL_GLU_H" is defined.  If the
dnl header "OpenGL/glu.h" is found, HAVE_OPENGL_GLU_H is defined.  These
dnl preprocessor definitions may not be mutually exclusive.
dnl
dnl version: 2.0
dnl author: Braden McDaniel <braden@endoframe.com>
dnl
AC_DEFUN([AX_CHECK_GLU],
[AC_REQUIRE([AX_CHECK_GL])dnl
AC_REQUIRE([AC_PROG_CXX])dnl
GLU_CFLAGS="${GL_CFLAGS}"

ax_save_CPPFLAGS="${CPPFLAGS}"
CPPFLAGS="${GL_CFLAGS} ${CPPFLAGS}"
AC_CHECK_HEADERS([GL/glu.h OpenGL/glu.h])
CPPFLAGS="${ax_save_CPPFLAGS}"

m4_define([AX_CHECK_GLU_PROGRAM],
          [AC_LANG_PROGRAM([[
# if defined(HAVE_WINDOWS_H) && defined(_WIN32)
#   include <windows.h>
# endif
# ifdef HAVE_GL_GLU_H
#   include <GL/glu.h>
# elif defined(HAVE_OPENGL_GLU_H)
#   include <OpenGL/glu.h>
# else
#   error no glu.h
# endif]],
                           [[gluBeginCurve(0)]])])

AC_CACHE_CHECK([for OpenGL Utility library], [ax_cv_check_glu_libglu],
[ax_cv_check_glu_libglu="no"
ax_save_CPPFLAGS="${CPPFLAGS}"
CPPFLAGS="${GL_CFLAGS} ${CPPFLAGS}"
ax_save_LIBS="${LIBS}"

#
# First, check for the possibility that everything we need is already in
# GL_LIBS.
#
LIBS="${GL_LIBS} ${ax_save_LIBS}"
#
# libGLU typically links with libstdc++ on POSIX platforms.
# However, setting the language to C++ means that test program
# source is named "conftest.cc"; and Microsoft cl doesn't know what
# to do with such a file.
#
AC_LANG_PUSH([C++])
AS_IF([test X$ax_compiler_ms = Xyes],
      [AC_LANG_PUSH([C])])
AC_LINK_IFELSE(
[AX_CHECK_GLU_PROGRAM],
[ax_cv_check_glu_libglu=yes],
[LIBS=""
ax_check_libs="-lglu32 -lGLU"
for ax_lib in ${ax_check_libs}; do
  AS_IF([test X$ax_compiler_ms = Xyes],
        [ax_try_lib=`echo $ax_lib | sed -e 's/^-l//' -e 's/$/.lib/'`],
        [ax_try_lib="${ax_lib}"])
  LIBS="${ax_try_lib} ${GL_LIBS} ${ax_save_LIBS}"
  AC_LINK_IFELSE([AX_CHECK_GLU_PROGRAM],
                 [ax_cv_check_glu_libglu="${ax_try_lib}"; break])
done
])
AS_IF([test X$ax_compiler_ms = Xyes],
      [AC_LANG_POP([C])])
AC_LANG_POP([C++])

LIBS=${ax_save_LIBS}
CPPFLAGS=${ax_save_CPPFLAGS}])
AS_IF([test "X$ax_cv_check_glu_libglu" = Xno],
      [no_glu=yes; GLU_CFLAGS=""; GLU_LIBS=""],
      [AS_IF([test "X$ax_cv_check_glu_libglu" = Xyes],
             [GLU_LIBS="$GL_LIBS"],
             [GLU_LIBS="${ax_cv_check_glu_libglu} ${GL_LIBS}"])])
AC_SUBST([GLU_CFLAGS])
AC_SUBST([GLU_LIBS])
])
