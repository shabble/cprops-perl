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

cp_trie *_trie_create() {
    cp_trie *new = cp_trie_create_trie
        (
            COLLECTION_MODE_NOSYNC,
            NULL,
            NULL
        );
    return new;
}

int _trie_destroy(cp_trie *trie) {
    return cp_trie_destroy(trie);
}

int _trie_count(cp_trie *trie) {
    return cp_trie_count(trie);
}

SV* _trie_add(cp_trie *trie, SV *key, SV *val) {


    char *key_copy = savesvpv(key);

    printf("Ref count of value (%p) is: %d\n", val, SvREFCNT(val));

    SvREFCNT_inc(val);
    SvREFCNT_inc(val);

    printf("Ref count of value (%p) is: %d\n", val, SvREFCNT(val));
    int ret = cp_trie_add(trie, key_copy, val);

    //cp_trie_dump(trie);
    if (ret == 0) {
        return newSViv(1);
    } else {
        return newSV(0);
    }
}

SV* _trie_remove(cp_trie *trie, char *key) {
    void *node;
    int ret = cp_trie_remove(trie, strdup(key), &node);
    //cp_trie_dump(trie);

    /* success?! according to docs, 0 is success but code appears to show that
     * 1 is success */
    if (ret == 1) {
        if (node != NULL) {
            SV *sv_node = (SV *)node;
            printf("Remove: Ref count of value (%p) is: %d\n", sv_node,
                   SvREFCNT(sv_node));
            SvREFCNT_dec(sv_node);
            printf("Remove: Ref count of value (%p) is: %d\n", sv_node,
                   SvREFCNT(sv_node));
            return sv_node;
        } else {
            printf("Remove succeeded but node NULL\n");
            return newSV(0);
        }
    } else {
        printf("Remove %s failed?\n", key);
        return newSV(0);
    }
}


void _trie_prefix_match(cp_trie *trie, char *prefix) {
    /* Inline_Stack_Vars; */
    /* Inline_Stack_Reset; */

    /* void *node; */
    /* int ret = cp_trie_prefix_match(trie, prefix, &node); */
    /* if (ret) { */
    /*     SV* sv = (SV *)node; */
    /*     Inline_Stack_Push(sv_2mortal(newSViv(ret))); */
    /*     Inline_Stack_Push(sv); */
    /* } else { */
    /*     Inline_Stack_Push(sv_2mortal(newSV(0))); */
    /* } */

    /* Inline_Stack_Done; */
    return;
}

SV* _trie_exact_match(cp_trie *trie, char *key) {
    SV *node;
    node = (SV *)cp_trie_exact_match(trie, key);
    if (node != NULL) {
        printf("Get: Ref count of value (%p) is: %d\n", node, SvREFCNT(node));
        SvREFCNT_inc(node); // WHY!?!?!?
        return node;
    } else {
        return newSV(0);
    }
}

void _trie_submatch(cp_trie *trie, char *key) {

    /* Inline_Stack_Vars; */
    /* Inline_Stack_Reset; */

    /* cp_vector *v = cp_trie_submatch(trie, key); */

    /* if (v == NULL) { */
    /*     // add an undef to the stack as a failure marker. */
    /*     Inline_Stack_Push(sv_2mortal(newSV(0))); */
    /* } else { */
    /*     int sz = cp_vector_size(v); */
    /*     int i; */
    /*     for (i = 0; i < sz; i++) { */
    /*         SV *sv = (SV *)cp_vector_element_at(v, i); */
    /*         Inline_Stack_Push(sv); */
    /*     } */
    /* } */

    /* Inline_Stack_Done; */
    return;
    
}

void _trie_prefixes(cp_trie *trie, char *search) {

    /* Inline_Stack_Vars; */
    /* Inline_Stack_Reset; */

    /* cp_vector *v = cp_trie_fetch_matches(trie, search); */

    /* if (v == NULL) { */
    /*     // add an undef to the stack for failure. */
    /*     Inline_Stack_Push(sv_2mortal(newSV(0))); */
    /* } else { */
    /*     int sz = cp_vector_size(v); */
    /*     int i; */
    /*     for (i = 0; i < sz; i++) { */
    /*         SV *sv = (SV *)cp_vector_element_at(v, i); */
    /*         Inline_Stack_Push(sv); */
    /*     } */
    /* } */

    /* Inline_Stack_Done; */
    return;
}

MODULE = CProps::Trie	PACKAGE = CProps::Trie	

PROTOTYPES: DISABLE


cp_trie *
_trie_create ()

int
_trie_destroy (trie)
	cp_trie *	trie

int
_trie_count (trie)
	cp_trie *	trie

SV *
_trie_add (trie, key, val)
	cp_trie *	trie
	SV *	key
	SV *	val

SV *
_trie_remove (trie, key)
	cp_trie *	trie
	char *	key

void
_trie_prefix_match (trie, prefix)
	cp_trie *	trie
	char *	prefix
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	_trie_prefix_match(trie, prefix);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
_trie_exact_match (trie, key)
	cp_trie *	trie
	char *	key

void
_trie_submatch (trie, key)
	cp_trie *	trie
	char *	key
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	_trie_submatch(trie, key);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
_trie_prefixes (trie, search)
	cp_trie *	trie
	char *	search
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	_trie_prefixes(trie, search);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

