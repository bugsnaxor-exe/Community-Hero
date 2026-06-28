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
  List<XFile> _images = [];
  bool _isImageValid = true;
  
  bool _isAnalyzing = false;
  Map<String, dynamic>? _aiPrediction;

  final List<String> _categories = ['Pothole', 'Streetlight Out', 'Graffiti', 'Litter', 'Water Leak', 'Other'];
  final List<String> _severities = ['Low', 'Medium', 'High', 'Critical'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
        _isAnalyzing = true;
        _aiPrediction = null; 
      });
      
      // Perform AI Analysis on the first new image
      final prediction = await ref.read(reportControllerProvider.notifier).analyzeImage(pickedFiles.first);
      
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _aiPrediction = prediction;
          
          if (prediction != null) {
            final predCategory = prediction['category'] as String?;
            final predSeverity = prediction['severity'] as String?;
            final isValid = prediction['is_valid'] ?? true;
            final confidence = prediction['confidence'] ?? 1.0;
            
            // Extremely specific check as requested: only block if explicitly invalid or very low confidence on non-standard category
            if (isValid == false || (predCategory == 'Other' && confidence < 0.3)) {
              _isImageValid = false;
            } else {
              _isImageValid = true;
            }
            
            if (predCategory != null && _categories.contains(predCategory)) {
              _selectedCategory = predCategory;
            }
            if (predSeverity != null && _severities.contains(predSeverity)) {
              _selectedSeverity = predSeverity;
            }
          }
        });
      }
    }
  }

  void _submit() async {
    if (!_isImageValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid image detected. Please upload a real issue.'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least one image.'), backgroundColor: Colors.orange),
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
        context.go('/home'); // Redirect back to home
      }
    }
  }

  Widget _buildAiPredictionWidget() {
    if (_isAnalyzing) {
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
            Expanded(child: Text('AI is analyzing the image...', style: TextStyle(color: Colors.blue))),
          ],
        ),
      );
    }
    
    if (_aiPrediction != null) {
      final confidence = ((_aiPrediction!['confidence'] ?? 0.0) * 100).toInt();
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
                  Text('Category: ${_aiPrediction!['category']} | Severity: ${_aiPrediction!['severity']} ($confidence% confidence)'),
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

    ref.listen<AsyncValue<void>>(
      reportControllerProvider,
      (_, state) {
        if (!state.isLoading && state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report an Issue'),
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
                  // Image Picker Section
                  GestureDetector(
                    onTap: () {
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
                                  );
                                }
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: kIsWeb
                                        ? Image.network(_images[index].path, fit: BoxFit.cover, width: 180)
                                        : FutureBuilder<Uint8List>(
                                            future: _images[index].readAsBytes(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return const SizedBox(
                                                  width: 180,
                                                  child: Center(child: CircularProgressIndicator()),
                                                );
                                              }
                                              if (snapshot.hasData) {
                                                return Image.memory(snapshot.data!, fit: BoxFit.cover, width: 180);
                                              }
                                              return const SizedBox(width: 180, child: Icon(Icons.error));
                                            },
                                          ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // AI Prediction Display
                  _buildAiPredictionWidget(),
                  if (_isAnalyzing || _aiPrediction != null) const SizedBox(height: 16),
                  
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
                      onPressed: isLoading || _isAnalyzing ? null : _submit,
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
