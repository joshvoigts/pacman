/*
 *  alpm_list.c
 * 
 *  Copyright (c) 2002-2006 by Judd Vinet <jvinet@zeroflux.org>
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
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, 
 *  USA.
 */

#include "config.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>

#include "alpm_list.h"
#include "util.h"

/** \defgroup alpm_list functions */
/*\@{*/

/* Allocation */

/** Allocate a new alpm_list_t
 *  @return a new alpm_list_t item, or NULL on failure
 */
alpm_list_t *alpm_list_new()
{
	alpm_list_t *list = NULL;

	list = (alpm_list_t *)malloc(sizeof(alpm_list_t));
	if(list) {
		list->data = NULL;
		list->prev = NULL;
		list->next = NULL;
	}
	return(list);
}

/** Free a list structure and possibly the internal data as well
 *  @param list the list to free
 *  @param fn a free function for the internal data, or NULL for none
 */
void alpm_list_free(alpm_list_t *list, alpm_list_fn_free fn)
{
	alpm_list_t *it = list;

	while(it) {
		alpm_list_t *ptr = it->next;
		if(fn && it->data) {
			fn(it->data);
		}
		FREE(it);
		it = ptr;
	}
}

/** Free the outer list, but not the contained data
 *  A minor simplification of alpm_list_free
 *  @param list the list to free
 */
void alpm_list_free_outer(alpm_list_t *list)
{
	alpm_list_free(list, NULL);
}

/* Mutators */

/** Add a new item to the list
 *  @param list the list to add to
 *  @param data the new item to be added to the list
 *  @return the resultant list, or NULL on failure
 */
alpm_list_t *alpm_list_add(alpm_list_t *list, void *data)
{
	alpm_list_t *ptr, *lp;

	ptr = list;
	if(ptr == NULL) {
		ptr = alpm_list_new();
		if(ptr == NULL) {
			return(NULL);
		}
	}

	lp = alpm_list_last(ptr);
	if(lp == ptr && lp->data == NULL) {
		/* nada */
	} else {
		lp->next = alpm_list_new();
		if(lp->next == NULL) {
			return(NULL);
		}
		lp->next->prev = lp;
		lp = lp->next;
	}

	lp->data = data;

	return(ptr);
}

/** Add items to a list in sorted order.
 *  @param list the list to add to
 *  @param data the new item to be added to the list
 *  @param fn the comparison function to use to determine order
 *  @return the resultant list, or NULL on failure
 */
alpm_list_t *alpm_list_add_sorted(alpm_list_t *list, void *data, alpm_list_fn_cmp fn)
{
	if(!fn) {
		return alpm_list_add(list, data);
	} else {
		alpm_list_t *add = NULL, *prev = NULL, *next = list;

		add = alpm_list_new();
		add->data = data;

		/* Find insertion point. */
		while(next) {
			if(fn(add->data, next->data) <= 0) break;
			prev = next;
			next = next->next;
		}

		/*  Insert node before insertion point. */
		add->prev = prev;
		add->next = next;

		if(next != NULL) {
			next->prev = add;   /*  Not at end.  */
		}

		if(prev != NULL) {
			prev->next = add;       /*  In middle.  */
		}

		return(list);
	}
}

/** Merge the two sorted sublists into one sorted list
 * @param left the first list
 * @param right the second list
 * @param fn comparison function for determining merge order
 */
alpm_list_t *alpm_list_mmerge(alpm_list_t *left, alpm_list_t *right, alpm_list_fn_cmp fn)
{
	alpm_list_t *newlist, *lp;

	if (left == NULL) 
		return right;
	if (right == NULL)
		return left;

	if (fn(left->data, right->data) <= 0) {
		newlist = left;
		left = left->next;
	}
	else {
		newlist = right;
		right = right->next;
	}
	newlist->prev = NULL;
	newlist->next = NULL;
	lp = newlist;

	while ((left != NULL) && (right != NULL)) {
		if (fn(left->data, right->data) <= 0) {
			lp->next = left;
			left->prev = lp;
			left = left->next;
		} 
		else {
			lp->next = right;
			right->prev = lp;
			right = right->next;
		}
		lp = lp->next;
		lp->next = NULL;
	}
	if (left != NULL) {
		lp->next = left;
		left->prev = lp;
	}
	else if (right != NULL) {
		lp->next = right;
		right->prev = lp;
	}
	return(newlist);
}

/** Sort a list of size `n` using mergesort algorithm
 *  @param list the list to sort
 *  @param n the size of the list
 *  @param fn the comparison function for determining order
 */
alpm_list_t* alpm_list_msort(alpm_list_t *list, int n, alpm_list_fn_cmp fn)
{
	if (n > 1) {
		alpm_list_t *left = list;
		alpm_list_t *lastleft = alpm_list_nth(list, n/2 - 1);
		alpm_list_t *right = lastleft->next;
		/* terminate first list */
		lastleft->next = NULL;	

		left = alpm_list_msort(left, n/2, fn);
		right = alpm_list_msort(right, n - (n/2), fn);
		list = alpm_list_mmerge(left, right, fn);
	}
	return(list);
}

/** Remove an item from the list
 *  @param haystack the list to remove the item from
 *  @param needle the data member of the item we're removing
 *  @param fn the comparison function for searching
 *  @param data output parameter containing the data member of the item removed
 *  @return the resultant list, or NULL on failure
 */
alpm_list_t *alpm_list_remove(alpm_list_t *haystack, void *needle, alpm_list_fn_cmp fn, void **data)
{ /* TODO I modified this to remove ALL matching items.  Do we need a remove_first? */
	alpm_list_t *i = haystack, *tmp = NULL;

	if(data) {
		*data = NULL;
	}

	while(i) {
		if(i->data == NULL) {
			continue;
		}
		tmp = i->next;
		if(fn(needle, i->data) == 0) {
			/* we found a matching item */
			if(i->next) {
				i->next->prev = i->prev;
			}
			if(i->prev) {
				i->prev->next = i->next;
			}

			if(i == haystack) {
				/* The item found is the first in the chain */
				haystack = haystack->next;
			}

			if(data) {
				*data = i->data;
			}
			i->data = NULL;
			free(i);
		}
		i = tmp;
	}

	return(haystack);
}

/** Create a new list without any duplicates
 *  @note DOES NOT copy data members
 *  @param list the list to copy
 *  @return a NEW list containing non-duplicated items
 */
alpm_list_t *alpm_list_remove_dupes(alpm_list_t *list)
{ /* TODO does removing the strdup here cause invalid free's anywhere? */
	alpm_list_t *lp = list, *newlist = NULL;
	while(lp) {
		if(!alpm_list_is_in(lp->data, newlist)) {
			newlist = alpm_list_add(newlist, lp->data);
		}
		lp = lp->next;
	}
	return(newlist);
}

/** Copy a string list, including data
 *  @note this is gross, assumes string data members
 *  @param list the list to copy
 *  @return a copy of the original list
 */
alpm_list_t *alpm_list_strdup(alpm_list_t *list)
{
	alpm_list_t *lp = list, *newlist = NULL;
	while(lp) {
		newlist = alpm_list_add(newlist, strdup(lp->data));
		lp = lp->next;
	}
	return(newlist);
}

/** Create a new list in reverse order
 *  @param list the list to copy
 *  @return a NEW list in reverse order of the first
 */
alpm_list_t *alpm_list_reverse(alpm_list_t *list)
{ /* TODO any invalid free's from NOT duplicating data here? */
	alpm_list_t *lp, *newlist = NULL;

	lp = alpm_list_last(list);
	while(lp) {
		newlist = alpm_list_add(newlist, lp->data);
		lp = lp->prev;
	}
	return(newlist);
}

/* Accessors */

/** Get the first element of a list.
 * @param list the list
 * @return the first element in the list
 */
alpm_list_t *alpm_list_first(alpm_list_t *list)
{
	return(list);
}

/** Return nth element from list (starting with 0)
 *  @param list the list to access
 *  @param n the index of the item to find
 *  @return an alpm_list_t node for index `n`
 */
alpm_list_t *alpm_list_nth(alpm_list_t *list, int n)
{
	alpm_list_t *i = list;
	while(n--) {
		i = i->next;
	}
	return(i);
}

/** Get the next element of a list.
 * @param entry the list entry
 * @return the next element, or NULL when no more elements exist
 */
alpm_list_t *alpm_list_next(alpm_list_t *entry)
{
	return(entry->next);
}
/** Get the last item in the list.
 *  @param list the list to operate on
 *  @return the last element in the list
 */
alpm_list_t *alpm_list_last(alpm_list_t *list)
{
	alpm_list_t *i = list;
	while(i && i->next) {
		i = i->next;
	}
	return(i);
}

/** Get the data member of a list entry.
 * @param entry the list entry
 * @return the contained data, or NULL if none
 */
void *alpm_list_getdata(const alpm_list_t *entry)
{
	return(entry->data);
}

/* Misc */

/** Count the list items
 *  @param list the list to operate on
 *  @return the number of list items
 */
int alpm_list_count(const alpm_list_t *list)
{
	unsigned int i = 0;
	const alpm_list_t *lp = list;
	while(lp) {
		++i;
		lp = lp->next;
	}
	return(i);
}

/** Is an item in the list
 *  @param needle the data to compare to (== comparison)
 *  @param haystack the list to search
 *  @return 1 if `needle` is found, 0 otherwise
 */
int alpm_list_is_in(const void *needle, alpm_list_t *haystack)
{
	alpm_list_t *lp = haystack;
	while(lp) {
		if(lp->data == needle) {
			return(1);
		}
		lp = lp->next;
	}
	return(0);
}

/* Test for existence of a string in a alpm_list_t
*/
/** Is a _string_ in the list (optimization of alpm_list_is_in for strings)
 *  @param needle the string to compare
 *  @param haystack the list to search
 *  @return 1 if `needle` is found, 0 otherwise
 */
int alpm_list_is_strin(const char *needle, alpm_list_t *haystack)
{
	alpm_list_t *lp = haystack;
	while(lp) {
		if(lp->data && strcmp((const char *)lp->data, needle) == 0) {
			return(1);
		}
	}
	return(0);
}

/** @} */

/* vim: set ts=2 sw=2 noet: */