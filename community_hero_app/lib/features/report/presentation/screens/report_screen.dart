import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../widgets/bounce_button.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/report_controller.dart';
import '../../../../services/location_service.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  bool _fetchingLocation = false;
  
  String _selectedCategory = 'Pothole';
  String _selectedSeverity = 'Medium';
  final List<XFile> _images = [];
  final Map<String, Map<String, dynamic>?> _predictions = {}; // Key: XFile.path
  final Map<String, bool> _analyzing = {}; // Key: XFile.path
  final Map<String, bool> _validity = {}; // Key: XFile.path
  
  final List<String> _categories = ['Pothole', 'Streetlight Out', 'Graffiti', 'Litter', 'Water Leak', 'Other'];
  final List<String> _severities = ['Low', 'Medium', 'High', 'Critical'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentLocation() async {
    if (!mounted) return;
    setState(() {
      _fetchingLocation = true;
    });
    try {
      final locationService = ref.read(locationServiceProvider);
      final position = await locationService.getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _latController.text = position.latitude.toStringAsFixed(6);
        _lngController.text = position.longitude.toStringAsFixed(6);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS Location fetched successfully!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
      setState(() {
        if (_latController.text.isEmpty) _latController.text = "22.5726";
        if (_lngController.text.isEmpty) _lngController.text = "88.3639";
      });
    } finally {
      if (mounted) {
        setState(() {
          _fetchingLocation = false;
        });
      }
    }
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
      if (!mounted) return;
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
      final lat = double.tryParse(_latController.text.trim());
      final lng = double.tryParse(_lngController.text.trim());
      
      if (lat == null || lat < -90 || lat > 90) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid Latitude (-90 to 90)'), backgroundColor: Colors.red),
        );
        return;
      }
      if (lng == null || lng < -180 || lng > 180) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid Longitude (-180 to 180)'), backgroundColor: Colors.red),
        );
        return;
      }

      final success = await ref.read(reportControllerProvider.notifier).submitReport(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _selectedCategory,
            severity: _selectedSeverity,
            latitude: lat,
            longitude: lng,
            images: _images,
          );
          
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report submitted successfully!'), backgroundColor: Colors.green),
          );
          context.go('/dashboard'); // Redirect back to dashboard
        } else {
          final errorState = ref.read(reportControllerProvider);
          final errorMsg = errorState.error?.toString() ?? 'Failed to submit report. Please try again.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
          );
        }
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
      String reason = 'Invalid image detected. Please remove screenshots, selfies, QR codes, or private indoor photos using the cross (X) button on the image(s).';
      for (var entry in _predictions.entries) {
        final path = entry.key;
        final pred = entry.value;
        if (pred != null && _validity[path] == false) {
          final predReason = pred['reasoning'] as String?;
          if (predReason != null && predReason.isNotEmpty) {
            reason = 'AI Check: $predReason Please remove this image using the cross (X) button.';
            break;
          }
        }
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                reason,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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

                            return _AnimatedImageItem(
                              key: ValueKey(image.path),
                              image: image,
                              isAnalyzing: isAnalyzingImg,
                              isValid: isImgValid,
                              onDelete: () {
                                setState(() {
                                  _images.removeAt(index);
                                  _analyzing.remove(image.path);
                                  _predictions.remove(image.path);
                                  _validity.remove(image.path);
                                });
                              },
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
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Location Coordinates',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _fetchingLocation ? null : _fetchCurrentLocation,
                        icon: _fetchingLocation 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location, size: 18),
                        label: Text(_fetchingLocation ? 'Fetching...' : 'Locate Me'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Latitude',
                            hintText: 'E.g., 22.5726',
                            prefixIcon: Icon(Icons.map_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            final val = double.tryParse(value);
                            if (val == null || val < -90 || val > 90) {
                              return 'Invalid (-90 to 90)';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _lngController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                            hintText: 'E.g., 88.3639',
                            prefixIcon: Icon(Icons.map_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            final val = double.tryParse(value);
                            if (val == null || val < -180 || val > 180) {
                              return 'Invalid (-180 to 180)';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  BounceButton(
                    onTap: isLoading || _analyzing.values.any((status) => status == true) ? null : _submit,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: isLoading || _analyzing.values.any((status) => status == true) ? null : _submit,
                        icon: isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.send),
                        label: Text(isLoading ? 'Submitting & Locating...' : 'Submit Report'),
                      ),
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

class _AnimatedImageItem extends StatefulWidget {
  final XFile image;
  final bool isAnalyzing;
  final bool isValid;
  final VoidCallback onDelete;

  const _AnimatedImageItem({
    super.key,
    required this.image,
    required this.isAnalyzing,
    required this.isValid,
    required this.onDelete,
  });

  @override
  State<_AnimatedImageItem> createState() => _AnimatedImageItemState();
}

class _AnimatedImageItemState extends State<_AnimatedImageItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDelete() {
    _controller.forward().then((_) {
      widget.onDelete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Container(
              width: 180,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: !widget.isValid ? Colors.red : Colors.transparent,
                  width: 3,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    kIsWeb
                        ? Image.network(widget.image.path, fit: BoxFit.cover)
                        : FutureBuilder<Uint8List>(
                            future: widget.image.readAsBytes(),
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
                    if (widget.isAnalyzing)
                      Container(
                        color: Colors.black.withValues(alpha: 0.5),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    if (!widget.isValid)
                      Container(
                        color: Colors.red.withValues(alpha: 0.4),
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
                onTap: _handleDelete,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.black.withValues(alpha: 0.7),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
