// stupidness with die() in props/log.h colliding with one provided by Perl.
#undef die

#include <cprops/collection.h>
#include <cprops/trie.h>
#include <cprops/vector.h>


void _print_type(SV*);
// Docs: http://cprops.sourceforge.net/cp_trie.3.html


void _trie__node_destructor(void *ptr);
void* _trie__node_copier(void *ptr);


void _trie__node_destructor(void *ptr) {
    printf("Destructor called on node %p\n", ptr);
}

void* _trie__node_copier(void *ptr) {
    printf("Copy called on node %p\n", ptr);
    return ptr;
}



cp_trie *_trie_create() {
    cp_trie *new = cp_trie_create_trie
        (
            COLLECTION_MODE_NOSYNC | COLLECTION_MODE_COPY,
            &_trie__node_copier,
            &_trie__node_destructor
        );
    return new;
}

int _trie_destroy(cp_trie *trie) {
    return cp_trie_destroy(trie);
}

int _trie_count(cp_trie *trie) {
    return cp_trie_count(trie);
}

SV* _trie_add(cp_trie *trie, char *key, SV *val) {

    void *value;
    value = (void *) newRV_inc(val);
    printf("Adding key %s with valptr: %p\n", key, value);

    int ret = cp_trie_add(trie, savepv(key), value);

    if (ret == 0) {
        return newSViv(1);
    } else {
        return newSV(0);
    }
}

SV* _trie_remove(cp_trie *trie, char *key) {
    void *node;
    int ret = cp_trie_remove(trie, key, &node);
    /* success?! according to docs, 0 is success but code appears to show that
     * 1 is success */
    if (ret == 1) {
        if (node != NULL) {
            SV *sv = (SV *)node;
            //printf("Returning ptr: %p, refok: %d\n", sv, SvROK(sv));
            printf("SV in remove is: ");
            _print_type(sv);
            printf(" ptr: %p\n", sv);
            return SvRV(sv);
        } else {
            printf("Remove succeeded but node NULL\n");
            return newSV(0);
        }
    } else {
        printf("Remove %s failed?\n", key);
        return newSV(0);
    }
}

void _print_type(SV *sv) {

    if (SvROK(sv)) {
        int type = SvTYPE(SvRV(sv));

        switch (type) {
        case SVt_IV:
            printf("Scalar (Int)");
            break;
        case SVt_NV: 
            printf("Scalar (NV)");
            break;
        case SVt_PV:
            printf("Scalar (Str)");
            break;
        case SVt_RV:
            printf("Scalar (Ref)");
            break;
        case SVt_PVAV:
            printf("Array");
            break;
        case SVt_PVHV:
            printf("Hash");
            break;
        case SVt_PVCV:
            printf("Code");
            break;
        case SVt_PVGV:
            printf("Glob or FH");
            break;
        case SVt_PVMG:
            printf("Blessed or Magical Scalar");
            break;
        default:
            printf("Default: %d", type);
        }
    
    } else {
        printf("Not a Reference");
    }
}

void _trie_prefix_match(cp_trie *trie, char *prefix) {
    Inline_Stack_Vars;
    Inline_Stack_Reset;

    void *node;
    int ret = cp_trie_prefix_match(trie, prefix, &node);
    if (ret) {
        SV* sv = (SV *)node;
        Inline_Stack_Push(sv_2mortal(newSViv(ret)));
        Inline_Stack_Push(SvRV(sv));
    } else {
        Inline_Stack_Push(sv_2mortal(newSV(0)));
    }

    Inline_Stack_Done;
    return;
}

SV* _trie_exact_match(cp_trie *trie, char *key) {
    void *node;
    node = cp_trie_exact_match(trie, key);
    if (node != NULL) {
        SV* sv = (SV *) node;
        printf("get returning ptr %p: ", sv);
        _print_type(sv);
        printf("\n");
        return SvRV(sv);
    } else {
        return newSV(0);
    }
}

void _trie_submatch(cp_trie *trie, char *key) {

    Inline_Stack_Vars;
    Inline_Stack_Reset;

    cp_vector *v = cp_trie_submatch(trie, key);

    if (v == NULL) {
        // add an undef to the stack as a failure marker.
        Inline_Stack_Push(sv_2mortal(newSV(0)));
    } else {
        int sz = cp_vector_size(v);
        int i;
        for (i = 0; i < sz; i++) {
            SV *sv = (SV *)cp_vector_element_at(v, i);
            Inline_Stack_Push(SvRV(sv));
        }
    }

    Inline_Stack_Done;
    return;
    
}

void _trie_prefixes(cp_trie *trie, char *search) {

    Inline_Stack_Vars;
    Inline_Stack_Reset;

    cp_vector *v = cp_trie_fetch_matches(trie, search);

    if (v == NULL) {
        // add an undef to the stack as a failure marker.
        Inline_Stack_Push(sv_2mortal(newSV(0)));
    } else {
        int sz = cp_vector_size(v);
        int i;
        for (i = 0; i < sz; i++) {
            SV *sv = (SV *)cp_vector_element_at(v, i);
            Inline_Stack_Push(SvRV(sv));
        }
    }

    Inline_Stack_Done;
    return;
}
