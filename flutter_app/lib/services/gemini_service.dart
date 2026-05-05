import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/receipt.dart';

class GeminiService {
  Future<Receipt> analyzeReceipt(String apiKey, Uint8List imageBytes, String mimeType, String targetCurrency) async {
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );

    final prompt = '''
You are the Receipt Scanner + AI. Analyze this receipt image and extract ALL items with prices.

Return ONLY valid JSON (no markdown, no explanation):
{
  "merchant": "Store/Restaurant name",
  "date": "DD MMM YYYY",
  "items": [
    {
      "name": "Item name",
      "price": 123.45,
      "category": "Food & Dining"
    }
  ],
  "subtotal": 0,
  "tax": 0,
  "total": 0,
  "currency": "$targetCurrency"
}

Categories must be one of: Food & Dining, Transport, Shopping, Health, Entertainment, Utilities, Other.
If you cannot read the receipt clearly, make reasonable estimates based on what's visible.
All prices must be numbers (no currency symbols).
''';

    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart(mimeType, imageBytes),
      ])
    ];

    final response = await model.generateContent(content);
    final text = response.text;

    if (text == null) {
      throw Exception('Failed to get response from Gemini');
    }

    // Clean JSON response
    final cleanJson = text.replaceAll('```json', '').replaceAll('```', '').trim();
    final Map<String, dynamic> data = jsonDecode(cleanJson);

    return Receipt(
      merchant: data['merchant'] ?? 'Unknown',
      date: _parseDate(data['date']),
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      tax: (data['tax'] ?? 0.0).toDouble(),
      total: (data['total'] ?? 0.0).toDouble(),
      currency: targetCurrency,
      items: (data['items'] as List?)?.map((i) => ReceiptItem.fromMap(i)).toList() ?? [],
      savedAt: DateTime.now(),
    );
  }

  DateTime _parseDate(String? dateStr) {
    if (dateStr == null) return DateTime.now();
    try {
      // Basic parsing, could be improved with intl
      return DateTime.tryParse(dateStr) ?? DateTime.now();
    } catch (_) {
      return DateTime.now();
    }
  }

  Future<Receipt> getDemoData(String currency) async {
    await Future.delayed(const Duration(seconds: 2));
    return Receipt(
      merchant: "Liquor Street",
      date: DateTime.now(),
      subtotal: 1035.00,
      tax: 103.53,
      total: 1139.00,
      currency: currency,
      items: [
        ReceiptItem(name: "Tandoori chicken", price: 309.75, category: "Food & Dining"),
        ReceiptItem(name: "Lasooni Dal Tadka", price: 288.75, category: "Food & Dining"),
        ReceiptItem(name: "Hyderabadi Murg Biryani", price: 393.75, category: "Food & Dining"),
        ReceiptItem(name: "Tandoori Roti (all food less spicy)", price: 63.00, category: "Food & Dining"),
        ReceiptItem(name: "Tandoori Roti", price: 31.50, category: "Food & Dining"),
      ],
      savedAt: DateTime.now(),
    );
  }
}
