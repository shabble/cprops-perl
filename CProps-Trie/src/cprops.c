// stupidness with die() in props/log.h colliding with one provided by Perl.
#undef die

#include <cprops/collection.h>
#include <cprops/trie.h>
#include <cprops/vector.h>

// Docs: http://cprops.sourceforge.net/cp_trie.3.html

cp_trie *trie_create() {
    cp_trie *new = cp_trie_create(COLLECTION_MODE_NOSYNC);
    return new;
}

int trie_destroy(cp_trie *trie) {
    return cp_trie_destroy(trie);
}

int trie_count(cp_trie *trie) {
    return cp_trie_count(trie);
}

SV* trie_add(cp_trie *trie, char *key, SV *val) {
    void *value;

    value = (void *) newRV_inc(val);

    int ret = cp_trie_add(trie, savepv(key), value);

    if (ret == 0) {
        return newSViv(1);
    } else {
        return newSV(0);
    }
}

SV* trie_remove(cp_trie *trie, char *key) {
    void *node;
    int ret = cp_trie_remove(trie, key, &node);
    if (ret == 1 && node != NULL) {
        SV *sv = (SV *)node;
        return SvRV(sv);
    } else {
        return newSV(0);
    }
}

void trie_prefix_match(cp_trie *trie, char *prefix) {
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

SV* trie_exact_match(cp_trie *trie, char *key) {
    void *match;
    match = cp_trie_exact_match(trie, key);
    if (match != NULL) {
        SV* sv = (SV *)match;
        return SvRV(sv);
    } else {
        return newSV(0);
    }
}

void trie_submatch(cp_trie *trie, char *key) {

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

void trie_prefixes(cp_trie *trie, char *search) {

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

void spam(cp_trie *trie, char *match) {
    cp_vector *v = cp_trie_fetch_matches(trie, match);
    int sz = cp_vector_size(v);
    int i;
    for (i = 0; i < sz; i++) {
        char *str = (char *)cp_vector_element_at(v, i);
        printf("Prefix: %s\n", str);
    }
}
