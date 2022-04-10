class NormalizeNumber {
  //
  //using min max normalization
  //
  static double inRange({
    required double currentValue,
    required double minValue,
    required double maxValue,
    required double newMaxValue,
    required double newMinValue,
  }) {
    double converatedValue = 0.0;
    converatedValue = (currentValue - minValue) / (maxValue - minValue) * (newMaxValue - newMinValue) + newMinValue;
    return converatedValue;
  }
}
