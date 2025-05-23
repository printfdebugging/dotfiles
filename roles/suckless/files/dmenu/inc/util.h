#ifndef UTIL_H
#define UTIL_H

#include <stddef.h>

#define MAX(A, B)        ((A) > (B) ? (A) : (B))
#define MIN(A, B)        ((A) < (B) ? (A) : (B))
#define BETWEEN(X, A, B) ((A) <= (X) && (X) <= (B))
#define LENGTH(X)        (sizeof(X) / sizeof(X)[0])
#define OPAQUE           0xffu

void  die(const char *fmt, ...);
void *ecalloc(size_t nmemb, size_t size);

#endif
