import math

MIN_TICK = -887272
MAX_TICK = 887272

Q96 = 2**96
ETH_DECIMAL = 10**18


def price_to_tick(p):
    return math.floor(math.log(p, 1.0001))


def price_to_sqrtp(p):
    return int(math.sqrt(p) * Q96)


def sqrtp_to_price(sqrtp):
    return (sqrtp / Q96)**2


def tick_to_sqrtp(t):
    return int((1.0001**(t / 2)) * Q96)


def liquidity0(amount, pa, pb):
    if pa > pb:
        pa, pb = pb, pa
    return (amount * (pa * pb) / Q96) / (pb - pa)


def liquidity1(amount, pa, pb):
    if pa > pb:
        pa, pb = pb, pa
    return amount * Q96 / (pb - pa)


def calc_amount0(liq, pa, pb):
    if pa > pb:
        pa, pb = pb, pa
    return int(liq * Q96 * (pb - pa) / pb / pa)


def calc_amount1(liq, pa, pb):
    if pa > pb:
        pa, pb = pb, pa
    return int(liq * (pb - pa) / Q96)


# Liquidity provision
price_low = 4545
price_cur = 5000
price_upp = 5500

print(f"Price range: {price_low}-{price_upp}; current price: {price_cur}")

sqrtp_low = price_to_sqrtp(price_low)
sqrtp_cur = price_to_sqrtp(price_cur)
sqrtp_upp = price_to_sqrtp(price_upp)

amount_eth = 1 * ETH_DECIMAL
amount_usdc = 5000 * ETH_DECIMAL

liq0 = liquidity0(amount_eth, sqrtp_cur, sqrtp_upp)
liq1 = liquidity1(amount_usdc, sqrtp_cur, sqrtp_low)
liq = int(min(liq0, liq1))

print(
    f"Deposit: {amount_eth/ETH_DECIMAL} ETH, {amount_usdc/ETH_DECIMAL} USDC; liquidity: {liq}"
)

# Swap USDC for ETH
amount_in = 42 * ETH_DECIMAL

print(f"\nSelling {amount_in/ETH_DECIMAL} USDC")

price_diff = (amount_in * Q96) // liq
price_next = sqrtp_cur + price_diff

print("New price:", (price_next / Q96)**2)
print("New sqrtP:", price_next)
print("New tick:", price_to_tick((price_next / Q96)**2))

amount_in = calc_amount1(liq, price_next, sqrtp_cur)
amount_out = calc_amount0(liq, price_next, sqrtp_cur)

print("USDC in:", amount_in / ETH_DECIMAL)
print("ETH out:", amount_out / ETH_DECIMAL)

# Swap ETH for USDC
amount_in = 0.01337 * ETH_DECIMAL

print(f"\nSelling {amount_in/ETH_DECIMAL} ETH")

price_next = int(
    (liq * Q96 * sqrtp_cur) // (liq * Q96 + amount_in * sqrtp_cur))

print("New price:", (price_next / Q96)**2)
print("New sqrtP:", price_next)
print("New tick:", price_to_tick((price_next / Q96)**2))

amount_in = calc_amount0(liq, price_next, sqrtp_cur)
amount_out = calc_amount1(liq, price_next, sqrtp_cur)

print("ETH in:", amount_in / ETH_DECIMAL)
print("USDC out:", amount_out / ETH_DECIMAL)
