#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

/* stupidness with die() in props/log.h colliding with one provided by Perl. */
#undef die

#include <collection.h>
#include <trie.h>
#include <vector.h>

char *_trie_downgrade_key(SV *key);

/*  returns a copy of the key transformed from UTF8 or other encodings to plain
 *  (char *) bytes. Dies with error if the string contains embedded NUL
 *  characters.
 */

char *_trie_downgrade_key(SV *key) {
    STRLEN len;
    char *key_bytes = SvPVutf8(key, len);
    size_t c_len = strlen(key_bytes);

    if (c_len != len) {
        croak("Key cannot contain embedded NUL characters");
    }
    return savepvn(key_bytes, len);
}

/* Docs: http://cprops.sourceforge.net/cp_trie.3.html */

MODULE = CProps::Trie	PACKAGE = CProps::Trie

PROTOTYPES: DISABLE

cp_trie *
_trie_create ()
CODE:
    RETVAL = cp_trie_create(COLLECTION_MODE_NOSYNC);
OUTPUT:
    RETVAL

int
_trie_destroy (trie)
	cp_trie *	trie
CODE:
    RETVAL = cp_trie_destroy(trie);
OUTPUT:
    RETVAL

int
_trie_count (trie)
	cp_trie *	trie
CODE:
    RETVAL = cp_trie_count(trie);
OUTPUT:
    RETVAL


SV *
_trie_add (trie, key, val)
	cp_trie *	trie
	SV *	key
	SV *	val
PPCODE: # test comment
    char *key_copy = _trie_downgrade_key(key);

    #/*  printf("Ref count of value (%p) is: %d\n", val, SvREFCNT(val)); */

    SvREFCNT_inc(val);
    int ret = cp_trie_add(trie, key_copy, val);

    /* free up the key, since the trie strdups it anyway */
    Safefree(key_copy);

    if (ret == 0) {
        XSRETURN_YES;
    } else {
        XSRETURN_NO;
    }


void
_trie_exact_match (trie, key)
	cp_trie *	trie
	SV      *	key
PPCODE:
    SV *node;
    char *key_copy = _trie_downgrade_key(key);
    node = (SV *)cp_trie_exact_match(trie, key_copy);
    Safefree(key_copy);
    if (node != NULL) {
     #   /* printf("Get: Ref count of value (%p) is: %d\n", node,
     #      SvREFCNT(node)); */
        XPUSHs(node);
    } else {
        XSRETURN_UNDEF;
    }


void
_trie_remove (trie, key)
	cp_trie *	trie
    SV      *	key
PPCODE:
    void *node;
    char *key_copy = _trie_downgrade_key(key);
    int ret = cp_trie_remove(trie, key_copy, &node);
    Safefree(key_copy);
    #/* success?! according to docs, 0 is success but code appears to show that
    # * 1 is success */

    if (ret == 1) {
        if (node != NULL) {
            SV *sv_node = (SV *)node;
            XPUSHs(sv_2mortal(sv_node));
        } else {
            #/* TODO: make this a croak? */
            printf("Err: Remove succeeded but node NULL\n");
            XSRETURN_UNDEF;
        }
    } else {
        XSRETURN_UNDEF;
    }

void
_trie_prefix_match (trie, prefix)
	cp_trie *	trie
	SV      *	prefix
PPCODE:
    void *node;
    char *prefix_copy = _trie_downgrade_key(prefix);

    int ret = cp_trie_prefix_match(trie, prefix_copy, &node);
    Safefree(prefix_copy);

    if (ret) {
        SV* sv = (SV *)node;
        XPUSHs(sv_2mortal(newSViv(ret))); /* num matches   */
		XPUSHs(sv);						  /* nearest node. */
	} else {
		XPUSHs(sv_2mortal(newSViv(0)));	  /* 0 matches	   */
		XPUSHs(sv_2mortal(newSV(0)));	  /* node is undef */
    }


void
_trie_submatch (trie, key)
	cp_trie *	trie
	SV      *	key
PPCODE:
    char *key_copy = _trie_downgrade_key(key);
    cp_vector *v = cp_trie_submatch(trie, key_copy);
    Safefree(key_copy);

    if (v == NULL) {
        XSRETURN_EMPTY;
    } else {
        int sz = cp_vector_size(v);
        int i;
        for (i = 0; i < sz; i++) {
            SV *sv = (SV *)cp_vector_element_at(v, i);
            XPUSHs(sv);
        }
    }

void
_trie_prefixes (trie, search)
	cp_trie *	trie
	SV      *	search
PPCODE:
    char *key_copy = _trie_downgrade_key(search);
    cp_vector *v = cp_trie_fetch_matches(trie, key_copy);
    Safefree(key_copy);

    if (v == NULL) {
        XSRETURN_EMPTY;
    } else {
        int sz = cp_vector_size(v);
        int i;
        for (i = 0; i < sz; i++) {
            SV *sv = (SV *)cp_vector_element_at(v, i);
            XPUSHs(sv);
        }
    }
