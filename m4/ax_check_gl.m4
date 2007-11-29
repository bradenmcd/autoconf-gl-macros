dnl @synopsis AX_CHECK_GL
dnl
dnl Check for an OpenGL implementation.  If GL is found, the required compiler
dnl and linker flags are included in the output variables "GL_CFLAGS" and
dnl "GL_LIBS", respectively.  This macro adds the configure option
dnl "--with-apple-opengl-framework", which users can use to indicate that
dnl Apple's OpenGL framework should be used on Mac OS X.  If Apple's OpenGL
dnl framework is used, the symbol "HAVE_APPLE_OPENGL_FRAMEWORK" is defined.  If
dnl no GL implementation is found, "no_gl" is set to "yes".
dnl
dnl @version 1.8
dnl @author Braden McDaniel <braden@endoframe.com>
dnl
AC_DEFUN([AX_CHECK_GL],
[AC_REQUIRE([AC_PATH_X])dnl
AC_REQUIRE([ACX_PTHREAD])dnl

#
# There isn't a reliable way to know we should use the Apple OpenGL framework
# without a configure option.  A Mac OS X user may have installed an
# alternative GL implementation (e.g., Mesa), which may or may not depend on X.
#
AC_ARG_WITH([apple-opengl-framework],
            [AC_HELP_STRING([--with-apple-opengl-framework],
                            [use Apple OpenGL framework (Mac OS X only)])])
AS_IF([test "X$with_apple_opengl_framework" = "Xyes"],
[AC_DEFINE([HAVE_APPLE_OPENGL_FRAMEWORK], [1],
           [Use the Apple OpenGL framework.])
GL_LIBS="-framework OpenGL"],
[AC_LANG_PUSH([C])
AX_LANG_COMPILER_MS
AS_IF([test X$ax_compiler_ms = Xno],
      [GL_CFLAGS="${PTHREAD_CFLAGS}"; GL_LIBS="${PTHREAD_LIBS} -lm"])

#
# Use x_includes and x_libraries if they have been set (presumably by
# AC_PATH_X).
#
AS_IF([test "X$no_x" != "Xyes"],
      [AS_IF([test -n "$x_includes"],
             [GL_CFLAGS="-I${x_includes} ${GL_CFLAGS}"])]
       AS_IF([test -n "$x_libraries"],
             [GL_LIBS="-L${x_libraries} -lX11 ${GL_LIBS}"]))

AC_CHECK_HEADERS([windows.h])

AC_CACHE_CHECK([for OpenGL library], [ax_cv_check_gl_libgl],
[ax_cv_check_gl_libgl="no"
ax_save_CPPFLAGS="${CPPFLAGS}"
CPPFLAGS="${GL_CFLAGS} ${CPPFLAGS}"
ax_save_LIBS="${LIBS}"
LIBS=""
ax_check_libs="-lopengl32 -lGL"
for ax_lib in ${ax_check_libs}; do
  AS_IF([test X$ax_compiler_ms = Xyes],
        [ax_try_lib=`echo $ax_lib | sed -e 's/^-l//' -e 's/$/.lib/'`],
        [ax_try_lib="${ax_lib}"])
  LIBS="${ax_try_lib} ${GL_LIBS} ${ax_save_LIBS}"
  AC_LINK_IFELSE(
  [AC_LANG_PROGRAM([[
# if HAVE_WINDOWS_H && defined(_WIN32)
#   include <windows.h>
# endif
# include <GL/gl.h>]],
                   [[glBegin(0)]])],
  [ax_cv_check_gl_libgl="${ax_try_lib}"; break])
done
LIBS=${ax_save_LIBS}
CPPFLAGS=${ax_save_CPPFLAGS}])

AS_IF([test "X${ax_cv_check_gl_libgl}" = "Xno"],
      [no_gl="yes"; GL_CFLAGS=""; GL_LIBS=""],
      [GL_LIBS="${ax_cv_check_gl_libgl} ${GL_LIBS}"])
AC_LANG_POP([C])])

AC_SUBST([GL_CFLAGS])
AC_SUBST([GL_LIBS])
])dnl
