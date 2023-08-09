import math

MIN_TICK = -887272
MAX_TICK = 887272

Q96 = 2**96
DECIMAL = 10**18


def price_to_tick(p):
    return math.floor(math.log(p, 1.0001))


def tick_to_price(tick):
    return math.pow(1.0001, tick)


def price_to_sqrtp(p):
    return int(math.sqrt(p) * Q96)


def sqrtp_to_price(sqrtp):
    return (sqrtp / Q96) ** 2


def tick_to_sqrtp(tick):
    return int(price_to_sqrtp(tick_to_price(tick)))


# delta y
def liquidity0(amount, sqrtpa, sqrtpb):
    if sqrtpa > sqrtpb:
        sqrtpa, sqrtpb = sqrtpb, sqrtpa
    return (amount * (sqrtpa * sqrtpb) / Q96) / (sqrtpb - sqrtpa)


# delta x
def liquidity1(amount, sqrtpa, sqrtpb):
    if sqrtpa > sqrtpb:
        sqrtpa, sqrtpb = sqrtpb, sqrtpa
    return amount * Q96 / (sqrtpb - sqrtpa)


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

lower_tick = price_to_tick(price_low)
current_tick = price_to_tick(price_cur)
upper_tick = price_to_tick(price_upp)

print(f"Tick range: {lower_tick}-{upper_tick}; current tick: {current_tick}")

sqrtp_low = price_to_sqrtp(price_low)
sqrtp_cur = price_to_sqrtp(price_cur)
sqrtp_upp = price_to_sqrtp(price_upp)

print(f"Current sqrt price: {sqrtp_cur}")

amount_eth = 1 * DECIMAL
amount_usdc = 5000 * DECIMAL

liq0 = liquidity0(amount_eth, sqrtp_cur, sqrtp_upp)
liq1 = liquidity1(amount_usdc, sqrtp_cur, sqrtp_low)
liq = int(min(liq0, liq1))

print(
    f"Deposit: {amount_eth/DECIMAL} ETH, {amount_usdc/DECIMAL} USDC; liquidity: {liq}"
)
print("~" * 64)
# Swap USDC for ETH
amount_in = 42 * DECIMAL
price_delta = (amount_in * Q96) // liq
price_after = sqrtp_cur + price_delta
print("New price: ", (price_after / Q96) ** 2)
print("New sqrt Price: ", price_after)
print("New tick: ", price_to_tick((price_after / Q96) ** 2))

amount_in = calc_amount1(liq, price_after, sqrtp_cur)
amount_out = calc_amount0(liq, price_after, sqrtp_cur)

print("USDC in: ", amount_in / DECIMAL)
print("ETH out: ", amount_out / DECIMAL)
