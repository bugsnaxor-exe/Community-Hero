import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/report_controller.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = 'Pothole';
  String _selectedSeverity = 'Medium';
  final List<XFile> _images = [];
  final Map<String, Map<String, dynamic>?> _predictions = {}; // Key: XFile.path
  final Map<String, bool> _analyzing = {}; // Key: XFile.path
  final Map<String, bool> _validity = {}; // Key: XFile.path
  
  final List<String> _categories = ['Pothole', 'Streetlight Out', 'Graffiti', 'Litter', 'Water Leak', 'Other'];
  final List<String> _severities = ['Low', 'Medium', 'High', 'Critical'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImages(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImages(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages(ImageSource source) async {
    if (_images.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maximum 6 images allowed.')));
      return;
    }
    
    final picker = ImagePicker();
    List<XFile> pickedFiles = [];
    
    if (source == ImageSource.gallery) {
      pickedFiles = await picker.pickMultiImage(imageQuality: 80);
    } else {
      final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) pickedFiles.add(pickedFile);
    }
    
    if (pickedFiles.isNotEmpty) {
      int remainingSlots = 6 - _images.length;
      if (pickedFiles.length > remainingSlots) {
        pickedFiles = pickedFiles.sublist(0, remainingSlots);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Only up to 6 images can be uploaded.')));
      }

      setState(() {
        _images.addAll(pickedFiles);
        for (var file in pickedFiles) {
          _analyzing[file.path] = true;
          _validity[file.path] = true; // Assume valid initially
        }
      });

      // Analyze each picked image asynchronously
      for (var file in pickedFiles) {
        _analyzeSingleImage(file);
      }
    }
  }

  Future<void> _analyzeSingleImage(XFile file) async {
    final prediction = await ref.read(reportControllerProvider.notifier).analyzeImage(file);
    if (!mounted) return;

    setState(() {
      _analyzing[file.path] = false;
      _predictions[file.path] = prediction;

      if (prediction != null) {
        final predCategory = prediction['category'] as String?;
        final predSeverity = prediction['severity'] as String?;
        final isValid = prediction['is_valid'] ?? true;

        // Simplified validity check: trust AI's invalid flag
        if (isValid == false || predCategory == 'Invalid') {
          _validity[file.path] = false;
        } else {
          _validity[file.path] = true;

          // Auto-fill category and severity based on the first valid prediction
          if (_selectedCategory == 'Other' || _selectedCategory == 'Pothole') {
            if (predCategory != null && _categories.contains(predCategory)) {
              _selectedCategory = predCategory;
            }
          }
          if (predSeverity != null && _severities.contains(predSeverity)) {
            _selectedSeverity = predSeverity;
          }
        }
      } else {
        // If analysis fails, treat as valid to avoid blocking user
        _validity[file.path] = true;
      }
    });
  }

  void _submit() async {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least one image.'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_analyzing.values.any((status) => status == true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait until image analysis is complete.'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_validity.values.any((status) => status == false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('One or more uploaded images are invalid or not related to community issues. Please remove them.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final success = await ref.read(reportControllerProvider.notifier).submitReport(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _selectedCategory,
            severity: _selectedSeverity,
            images: _images,
          );
          
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully!'), backgroundColor: Colors.green),
        );
        context.go('/dashboard'); // Redirect back to dashboard
      }
    }
  }

  Widget _buildAiPredictionWidget() {
    final isAnalyzing = _analyzing.values.any((status) => status == true);
    final hasInvalid = _validity.values.any((status) => status == false);

    if (isAnalyzing) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 16),
            Expanded(child: Text('AI is analyzing the uploaded image(s)...', style: TextStyle(color: Colors.blue))),
          ],
        ),
      );
    }
    
    if (hasInvalid) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
        ),
        child: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Invalid image detected. Please remove screenshots, selfies, QR codes, or private indoor photos using the cross (X) button on the image(s).',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    final validPredictions = _predictions.values.where((p) => p != null && p['is_valid'] == true).toList();
    if (validPredictions.isNotEmpty) {
      final firstPred = validPredictions.first!;
      final confidence = ((firstPred['confidence'] ?? 0.0) * 100).toInt();
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AI Prediction Applied', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  Text('Category: ${firstPred['category']} | Severity: ${firstPred['severity']} ($confidence% confidence)'),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportControllerProvider);
    final isLoading = reportState.isLoading;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Report Issue', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              // Photo Upload Section
              Text(
                'Upload Photos (Max 6)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  if (_images.isEmpty) {
                    _showImageSourceBottomSheet();
                  }
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                  ),
                  child: _images.isEmpty
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Tap to add photos', style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length < 6 ? _images.length + 1 : _images.length,
                          itemBuilder: (context, index) {
                            if (index == _images.length) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () => _showImageSourceBottomSheet(),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 180,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                                          SizedBox(height: 8),
                                          Text('Add more', style: TextStyle(color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            final image = _images[index];
                            final isAnalyzingImg = _analyzing[image.path] ?? false;
                            final isImgValid = _validity[image.path] ?? true;

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 180,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: !isImgValid ? Colors.red : Colors.transparent,
                                        width: 3,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          kIsWeb
                                              ? Image.network(image.path, fit: BoxFit.cover)
                                              : FutureBuilder<Uint8List>(
                                                  future: image.readAsBytes(),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                                      return const Center(child: CircularProgressIndicator());
                                                    }
                                                    if (snapshot.hasData) {
                                                      return Image.memory(snapshot.data!, fit: BoxFit.cover);
                                                    }
                                                    return const Center(child: Icon(Icons.error));
                                                  },
                                                ),
                                          if (isAnalyzingImg)
                                            Container(
                                              color: Colors.black.withOpacity(0.5),
                                              child: const Center(
                                                child: CircularProgressIndicator(color: Colors.white),
                                              ),
                                            ),
                                          if (!isImgValid)
                                            Container(
                                              color: Colors.red.withOpacity(0.4),
                                              child: const Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.warning, color: Colors.white, size: 36),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      'INVALID IMAGE',
                                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _images.removeAt(index);
                                          _analyzing.remove(image.path);
                                          _predictions.remove(image.path);
                                          _validity.remove(image.path);
                                        });
                                      },
                                      child: CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Colors.black.withOpacity(0.7),
                                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 16),
              
              // AI Prediction Display
              _buildAiPredictionWidget(),
              if (_analyzing.isNotEmpty) const SizedBox(height: 16),
                  
                  // Text Inputs
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title', hintText: 'E.g., Large pothole on Main St'),
                    validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val!),
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSeverity,
                    decoration: const InputDecoration(labelText: 'Severity'),
                    items: _severities.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => setState(() => _selectedSeverity = val!),
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description', hintText: 'Provide more details...'),
                    maxLines: 4,
                    validator: (value) => value == null || value.isEmpty ? 'Description is required' : null,
                  ),
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isLoading || _analyzing.values.any((status) => status == true) ? null : _submit,
                      icon: isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send),
                      label: Text(isLoading ? 'Submitting & Locating...' : 'Submit Report'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
