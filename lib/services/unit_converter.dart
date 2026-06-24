/// Unit conversions and display formatting. Pure Dart, no Flutter deps.
library;

const double yardsPerMeter = 1.0936132983;
const double mmPerInch = 25.4;
const double kgPerLb = 0.45359237;

double yardsToMeters(double yd) => yd / yardsPerMeter;
double metersToYards(double m) => m * yardsPerMeter;
double inchesToMm(double inch) => inch * mmPerInch;
double mmToInches(double mm) => mm / mmPerInch;
double lbToKg(double lb) => lb * kgPerLb;
double kgToLb(double kg) => kg / kgPerLb;

/// The unit system the UI presents.
enum UnitSystem { us, metric }

extension UnitSystemX on UnitSystem {
  String get label => this == UnitSystem.us ? 'US (yd / lb / in)' : 'Metric (m / kg / mm)';

  /// Length: yards in US, meters in metric.
  String get lengthUnit => this == UnitSystem.us ? 'yd' : 'm';

  /// Diameter: thousandths of an inch (mils) in US, mm in metric.
  String get diameterUnit => this == UnitSystem.us ? 'in' : 'mm';

  String get testUnit => this == UnitSystem.us ? 'lb' : 'kg';

  /// Format a yard length for the active system.
  String length(double yards, {int decimals = 0}) {
    final v = this == UnitSystem.us ? yards : yardsToMeters(yards);
    return '${v.toStringAsFixed(decimals)} $lengthUnit';
  }

  /// Format a diameter (stored in inches) for the active system.
  String diameter(double diameterIn) {
    if (this == UnitSystem.us) {
      return '${diameterIn.toStringAsFixed(3)} in';
    }
    return '${inchesToMm(diameterIn).toStringAsFixed(3)} mm';
  }

  /// Format a line test (stored in lb) for the active system.
  String test(double lbTest) {
    if (this == UnitSystem.us) {
      return '${lbTest.toStringAsFixed(0)} lb';
    }
    return '${lbToKg(lbTest).toStringAsFixed(1)} kg';
  }
}
