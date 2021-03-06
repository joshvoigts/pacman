/*
 *  deps.h
 *
 *  Copyright (c) 2006-2011 Pacman Development Team <pacman-dev@archlinux.org>
 *  Copyright (c) 2002-2006 by Judd Vinet <jvinet@zeroflux.org>
 *  Copyright (c) 2005 by Aurelien Foret <orelien@chez.com>
 *  Copyright (c) 2006 by Miklos Vajna <vmiklos@frugalware.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#ifndef _ALPM_DEPS_H
#define _ALPM_DEPS_H

#include "db.h"
#include "sync.h"
#include "package.h"
#include "alpm.h"

void _alpm_dep_free(pmdepend_t *dep);
pmdepend_t *_alpm_dep_dup(const pmdepend_t *dep);
void _alpm_depmiss_free(pmdepmissing_t *miss);
alpm_list_t *_alpm_sortbydeps(pmhandle_t *handle, alpm_list_t *targets, int reverse);
void _alpm_recursedeps(pmdb_t *db, alpm_list_t *targs, int include_explicit);
int _alpm_resolvedeps(pmhandle_t *handle, alpm_list_t *localpkgs, pmpkg_t *pkg,
		alpm_list_t *preferred, alpm_list_t **packages, alpm_list_t *remove,
		alpm_list_t **data);
pmdepend_t *_alpm_splitdep(const char *depstring);
int _alpm_depcmp(pmpkg_t *pkg, pmdepend_t *dep);

#endif /* _ALPM_DEPS_H */

/* vim: set ts=2 sw=2 noet: */
