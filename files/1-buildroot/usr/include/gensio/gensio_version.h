/*
 *  gensio - A library for abstracting stream I/O
 *  Copyright (C) 2018  Corey Minyard <minyard@acm.org>
 *
 *  SPDX-License-Identifier: LGPL-2.1-only
 */

#ifndef GENSIO_VERSION_H
#define GENSIO_VERSION_H

#define gensio_version_major 2
#define gensio_version_minor 5
#define gensio_version_patch 5
#define gensio_version_string "2.5.5"

/*
 * A macro to compare a gensio version, for handling new features.
 */
#define gensio_version_ge(maj, min, patch) \
    ((gensio_version_major > (maj)) ||					\
     (gensio_version_major == (maj) && gensio_version_minor > (min)) ||	\
     (gensio_version_major == (maj) && gensio_version_minor == (min) &&	\
      gensio_version_patch >= (patch)))

/*
 * A macro to compare a gensio version, for handling features being
 * removed.
 */
#define gensio_version_lt(maj, min, patch) \
    ((gensio_version_major < (maj)) ||					\
     (gensio_version_major == (maj) && gensio_version_minor < (min)) ||	\
     (gensio_version_major == (maj) && gensio_version_minor == (min) &&	\
      gensio_version_patch < (patch)))


#endif /* GENSIO_VERSION_H */
