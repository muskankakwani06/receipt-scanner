import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/receipt.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  XFile? _image;
  bool _isAnalyzing = false;
  Receipt? _analysisResult;
  String _targetCurrency = '₹';

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _image = image;
        _analysisResult = null;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;
    final provider = context.read<AppProvider>();
    final apiKey = provider.settings.apiKey;

    if (apiKey.isEmpty) {
      _showToast('Please set your API key in Profile');
      return;
    }

      setState(() => _isAnalyzing = true);

      try {
        final bytes = await _image!.readAsBytes();
        
        // Upload image to Firebase Storage
        final imageUrl = await provider.uploadReceiptImage(bytes, 'Receipt');

        Receipt result;
        if (apiKey.toLowerCase() == 'demo') {
          result = await provider.gemini.getDemoData(_targetCurrency);
        } else {
          result = await provider.gemini.analyzeReceipt(
            apiKey,
            bytes,
            _image!.mimeType ?? 'image/jpeg',
            _targetCurrency,
          );
        }

        // Attach the image URL to the result
        final finalResult = result.copyWith(imageUrl: imageUrl);

        setState(() {
          _analysisResult = finalResult;
          _isAnalyzing = false;
        });
      } catch (e) {
        setState(() => _isAnalyzing = false);
        _showToast('Analysis failed: $e');
      }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    _targetCurrency = provider.settings.currency;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.receipt_long_rounded, color: AppTheme.primary),
            SizedBox(width: 12),
            Text('Receipt Scanner +', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          children: [
            _buildUploadZone(),
            const SizedBox(height: 32),
            if (_image == null) _buildScanInstructions(),
            if (_image != null && !_isAnalyzing && _analysisResult == null) _buildAnalyzeAction(),
            if (_isAnalyzing) _buildLoadingState(),
            if (_analysisResult != null) _buildResultsState(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadZone() {
    return GestureDetector(
      onTap: () => _showPickerOptions(),
      child: Container(
        width: double.infinity,
        height: 360,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary.withOpacity(0.12),
              Colors.white.withOpacity(0.03),
            ],
          ),
          border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 1.5),
          image: _image != null
              ? DecorationImage(
                  image: kIsWeb 
                      ? NetworkImage(_image!.path) as ImageProvider
                      : FileImage(File(_image!.path)), 
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.45), BlendMode.darken),
                )
              : null,
        ),
        child: _image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
                        ),
                      ).animate(onPlay: (c) => c.repeat()).scaleXY(begin: 0.8, end: 1.2, duration: 2000.ms, curve: Curves.easeInOut),
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 30, spreadRadius: 5),
                          ],
                        ),
                        child: const Icon(LucideIcons.camera, size: 60, color: AppTheme.primary),
                      ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -5, end: 5, duration: 1500.ms),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('Ready to Scan', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text('Upload your receipt to get started', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.plus, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('Select Image', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ColorFilter.matrix([1,0,0,0,0, 0,1,0,0,0, 0,0,1,0,0, 0,0,0,1,0]), // Fix for web blur
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: InkWell(
                            onTap: () => _showPickerOptions(),
                            child: const Row(
                              children: [
                                Icon(LucideIcons.refreshCcw, color: Colors.white, size: 16),
                                SizedBox(width: 8),
                                Text('Replace', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildScanInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Scanning Guide', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTipCard(LucideIcons.sun, 'Good Lighting', 'Ensure text is clear')),
            const SizedBox(width: 12),
            Expanded(child: _buildTipCard(LucideIcons.maximize, 'Flat Surface', 'Avoid any folds')),
          ],
        ),
        const SizedBox(height: 12),
        _buildStepItem('1', 'Capture', 'Take a photo of your paper receipt'),
        _buildStepItem('2', 'AI Processing', 'Our Gemini AI reads every item'),
        _buildStepItem('3', 'Save', 'Categorize and track your budget'),
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              Icon(LucideIcons.shieldCheck, color: AppTheme.success.withOpacity(0.5), size: 32),
              const SizedBox(height: 8),
              Text('Secure AI Analysis', style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 12)),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1);
  }

  Widget _buildTipCard(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary, size: 24),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStepItem(String num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
            ),
            child: Text(num, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(desc, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: const Text('Camera'),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: const Text('Gallery'),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeAction() {
    const currencies = ['₹', r'$', '€', '£'];
    return Column(
      children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Currency', style: TextStyle(color: AppTheme.textSecondary)),
                DropdownButton<String>(
                  value: _targetCurrency,
                  dropdownColor: AppTheme.surface,
                  underline: const SizedBox(),
                  items: currencies.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: (val) {
                    if (val != null) context.read<AppProvider>().updateCurrency(val);
                  },
                ),
              ],
            ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _analyzeImage,
            icon: const Icon(LucideIcons.sparkles),
            label: const Text('Analyze with AI'),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const CircularProgressIndicator(),
        const SizedBox(height: 24),
        const Text('AI is reading your receipt...', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
        const Text('Extracting items & categorizing', style: TextStyle(color: AppTheme.textSecondary)),
        const SizedBox(height: 24),
        _buildLoadingStep('📷 Processing image', true),
        _buildLoadingStep('🔍 Extracting items', false),
        _buildLoadingStep('🏷️ Categorizing', false),
      ],
    ).animate().fadeIn();
  }

  Widget _buildLoadingStep(String label, bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(active ? LucideIcons.checkCircle2 : LucideIcons.circle, color: active ? AppTheme.success : AppTheme.textSecondary, size: 18),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: active ? AppTheme.textPrimary : AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildResultsState() {
    final r = _analysisResult!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              Text(r.merchant, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(DateFormat('dd MMM yyyy').format(r.date), style: const TextStyle(color: AppTheme.textSecondary)),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  Text('${r.currency}${r.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Extracted Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...r.items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (AppTheme.categoryStyles[item.category]?.color ?? AppTheme.categoryStyles['Other']!.color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(item.category, style: TextStyle(fontSize: 10, color: AppTheme.categoryStyles[item.category]?.color)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(item.name, style: const TextStyle(fontSize: 14))),
              Text('${r.currency}${item.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        )),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() { _image = null; _analysisResult = null; }),
                child: const Text('Reset'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<AppProvider>().saveReceipt(r);
                  _showToast('Saved to budget!');
                  setState(() { _image = null; _analysisResult = null; });
                },
                child: const Text('Save to Budget'),
              ),
            ),
          ],
        ),
      ],
    ).animate().slideY(begin: 0.1).fadeIn();
  }
}
