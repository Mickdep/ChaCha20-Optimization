/* Based on the public domain implemntation in
 * crypto_stream/chacha20/e/ref from http://bench.cr.yp.to/supercop.html
 * by Daniel J. Bernstein */

#include <stdint.h>

#define ROUNDS 20

typedef uint32_t uint32;

static uint32 load_littleendian(const unsigned char *x)
{
  return (uint32)(x[0]) | (((uint32)(x[1])) << 8) | (((uint32)(x[2])) << 16) | (((uint32)(x[3])) << 24);
}

static void store_littleendian(unsigned char *x, uint32 u)
{
  x[0] = u;
  u >>= 8;
  x[1] = u;
  u >>= 8;
  x[2] = u;
  u >>= 8;
  x[3] = u;
}

static uint32 rotate(uint32 a, int d)
{
  uint32 t;
  t = a >> (32 - d);
  a <<= d;
  return a | t;
}

//Assembly implementation of crypto_core_chacha20 function in assembly
extern int cryptocore_quarterrounds(unsigned char *out,
                         const unsigned char *in,
                         const unsigned char *k,
                         const unsigned char *c);

static const unsigned char sigma[16] = "expand 32-byte k";

int crypto_stream_chacha20(unsigned char *c, unsigned long long clen, const unsigned char *n, const unsigned char *k)
{
  unsigned char in[16];
  unsigned char block[64];
  unsigned char kcopy[32];
  unsigned long long i;
  unsigned int u;

  if (!clen)
    return 0;

  for (i = 0; i < 32; ++i)
    kcopy[i] = k[i];
  for (i = 0; i < 8; ++i)
    in[i] = n[i];
  for (i = 8; i < 16; ++i)
    in[i] = 0;

  while (clen >= 64)
  {
    cryptocore_quarterrounds(c, in, kcopy, sigma);

    u = 1;
    for (i = 8; i < 16; ++i)
    {
      u += (unsigned int)in[i];
      in[i] = u;
      u >>= 8;
    }

    clen -= 64;
    c += 64;
  }

  if (clen)
  {
    cryptocore_quarterrounds(block, in, kcopy, sigma);
    for (i = 0; i < clen; ++i)
      c[i] = block[i];
  }
  return 0;
}
