#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
//#include "INLINE.h"
// stupidness with die() in props/log.h colliding with one provided by Perl.
#undef die

#include <cprops/collection.h>
#include <cprops/trie.h>
#include <cprops/vector.h>

// Docs: http://cprops.sourceforge.net/cp_trie.3.html

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
PPCODE:
    char *key_copy = savesvpv(key);

    // printf("Ref count of value (%p) is: %d\n", val, SvREFCNT(val));

    SvREFCNT_inc(val);
    int ret = cp_trie_add(trie, key_copy, val); 

    if (ret == 0) {
        XSRETURN_YES;
    } else {
        XSRETURN_NO;
    }


void
_trie_exact_match (trie, key)
	cp_trie *	trie
	char    *	key
PPCODE:
    SV *node;
    node = (SV *)cp_trie_exact_match(trie, key);
    if (node != NULL) {
        //printf("Get: Ref count of value (%p) is: %d\n", node, SvREFCNT(node));
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
    int ret = cp_trie_remove(trie, savesvpv(key), &node);

    /* success?! according to docs, 0 is success but code appears to show that
     * 1 is success */

    if (ret == 1) {
        if (node != NULL) {
            SV *sv_node = (SV *)node;
            XPUSHs(sv_2mortal(sv_node));
        } else {
            printf("Remove succeeded but node NULL\n");
            XSRETURN_NO;
        }
    } else {
        printf("Remove %s failed?\n", key);
        XSRETURN_NO;
    }

void
_trie_prefix_match (trie, prefix)
	cp_trie *	trie
	char *	prefix
PPCODE:
    void *node;
    int ret = cp_trie_prefix_match(trie, prefix, &node);
    if (ret) {
        SV* sv = (SV *)node;
        XPUSHs(sv_2mortal(newSViv(ret))); // num matches
        XPUSHs(sv);                       // nearest node.
    } else {
        XPUSHs(sv_2mortal(newSViv(0)));   // 0 matches
        XPUSHs(sv_2mortal(newSV(0)));     // node is undef
    }


void
_trie_submatch (trie, key)
	cp_trie *	trie
	char *	key
PPCODE:
    cp_vector *v = cp_trie_submatch(trie, key);

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
	char *	search
PPCODE:
    cp_vector *v = cp_trie_fetch_matches(trie, search);

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
