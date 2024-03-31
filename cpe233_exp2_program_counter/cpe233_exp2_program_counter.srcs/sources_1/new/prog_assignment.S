// high-level C
int DIGITS = 4;
for (i = DIGITS-1; i; i--)
{
    bcd[i] = 0;
    v = w[i]<<3;
    if (x >= v)
    {
        x -= v;
        bcd[i] += 8;
    }
    v>>=1;
    if (x >= v)
    {
        x -= v;
        bcd[i] += 4;
    }
    v>>=1;
    if (x >= v)
    {
        x -= v;
        bcd[i] += 2;
    }
    v>>=1;
    if (x >= v)
    {
        x -= v;
        bcd[i] += 1;
    }
}
bcd[0] = x;

// RISC-V assembly
bin_to_4_digit_bcd:

