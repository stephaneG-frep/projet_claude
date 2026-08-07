/// Résultat d'une opération arithmétique avec ses drapeaux associés,
/// calculé en 64 bits non signés exacts via [BigInt] pour rester correct
/// quelle que soit la plateforme (y compris le Web, où `int` natif perd de
/// la précision au-delà de 2^53).
class FlaggedResult {
  final int value;
  final bool carry;
  final bool overflow;
  const FlaggedResult(this.value, this.carry, this.overflow);
}

final BigInt _mask64 = (BigInt.one << 64) - BigInt.one;

BigInt _toUnsigned64(int v) => BigInt.from(v).toUnsigned(64);

int _toSignedInt(BigInt v) => v.toUnsigned(64).toSigned(64).toInt();

FlaggedResult addWithFlags(int a, int b) {
  final ba = _toUnsigned64(a);
  final bb = _toUnsigned64(b);
  final sum = ba + bb;
  final carry = sum > _mask64;
  final result = _toSignedInt(sum);
  final overflow = (a >= 0) == (b >= 0) && (result >= 0) != (a >= 0);
  return FlaggedResult(result, carry, overflow);
}

FlaggedResult subWithFlags(int a, int b) {
  final ba = _toUnsigned64(a);
  final bb = _toUnsigned64(b);
  final borrow = ba < bb;
  final diff = (ba - bb).toUnsigned(64);
  final result = _toSignedInt(diff);
  final overflow = (a >= 0) != (b >= 0) && (result >= 0) != (a >= 0);
  return FlaggedResult(result, borrow, overflow);
}

FlaggedResult mulWithFlags(int a, int b) {
  final product = _toUnsigned64(a) * _toUnsigned64(b);
  final overflows = product > _mask64;
  final result = _toSignedInt(product.toUnsigned(64));
  return FlaggedResult(result, overflows, overflows);
}

class DivisionResult {
  final int quotient;
  final int remainder;
  const DivisionResult(this.quotient, this.remainder);
}

DivisionResult divWithRemainder(int dividend, int divisor) {
  final bd = _toUnsigned64(dividend);
  final bv = _toUnsigned64(divisor);
  final q = bd ~/ bv;
  final r = bd.remainder(bv);
  return DivisionResult(_toSignedInt(q), _toSignedInt(r));
}
