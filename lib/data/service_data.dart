// Shared service data: prices and helper formatter.
// Imported by services_page, book_now_page, and appointments_page
// so prices stay consistent across the app from a single source of truth.

const Map<String, double> kServicePrices = {
  'General Check-up': 500,
  'Diagnostics': 1200,
  'Dental Care': 800,
  'Nutrition Consultations': 400,
  'Parasite Prevention': 600,
  'Quick Grooming': 300,
  'Special Treatments': 700,
  'Full Grooming Packages': 1000,
};

/// Returns a nicely formatted Philippine Peso price string, e.g. "₱1,500"
/// Returns an empty string if the service is not in the map.
String kFormatPrice(String serviceName) {
  final price = kServicePrices[serviceName];
  if (price == null) return '';
  final p = price.toInt();
  if (p >= 1000) {
    final thousands = p ~/ 1000;
    final remainder = (p % 1000).toString().padLeft(3, '0');
    return '₱$thousands,$remainder';
  }
  return '₱$p';
}
