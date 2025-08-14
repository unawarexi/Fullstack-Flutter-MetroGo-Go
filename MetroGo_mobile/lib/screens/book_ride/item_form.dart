import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:datride_mobile/utils/helper_functions.dart';

class ItemForm extends StatefulWidget {
  const ItemForm({super.key});

  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _senderNameController = TextEditingController();
  final _senderContactController = TextEditingController();
  final _receiverNameController = TextEditingController();
  final _receiverContactController = TextEditingController();
  final _packageDescriptionController = TextEditingController();
  final _packageQuantityController = TextEditingController(); // New field for package quantity

  // Image picker
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _packageImages = [];

  // Dropdown selections
  String? _selectedPackageType;
  String? _selectedPackageTexture;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Package type options
  final List<String> _packageTypes = [
    'Small Package',
    'Large Package',
    'Bulky Item',
    'Fragile Item',
    'Electronics',
    'Documents'
  ];

  // Package texture options
  final List<String> _packageTextures = [
    'Soft',
    'Hard',
    'Rigid',
    'Flexible',
    'Liquid',
    'Powder'
  ];

  // Image picker method
  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage(
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    
    setState(() {
      _packageImages.addAll(pickedFiles);
    });
  }

  // Date picker method
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Time picker method
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Submit form method
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Collect form data
      final formData = {
        'senderName': _senderNameController.text,
        'senderContact': _senderContactController.text,
        'receiverName': _receiverNameController.text,
        'receiverContact': _receiverContactController.text,
        'packageType': _selectedPackageType,
        'packageTexture': _selectedPackageTexture,
        'packageQuantity': _packageQuantityController.text, // Include package quantity
        'deliveryDate': _selectedDate,
        'deliveryTime': _selectedTime,
        'packageDescription': _packageDescriptionController.text,
        'packageImages': _packageImages.map((file) => file.path).toList(),
      };

      // TODO: Implement actual submission logic (e.g., API call)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Package Delivery Request Submitted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Package Delivery Form'),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sender Details Section
              _buildSectionTitle('Sender Details', isDarkMode),
              TextFormField(
                controller: _senderNameController,
                decoration: _inputDecoration('Sender Name', isDarkMode),
                validator: (value) => value!.isEmpty ? 'Please enter sender name' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _senderContactController,
                decoration: _inputDecoration('Sender Contact', isDarkMode),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Please enter contact number' : null,
              ),

              // Receiver Details Section
              const SizedBox(height: 25),
              _buildSectionTitle('Receiver Details', isDarkMode),
              TextFormField(
                controller: _receiverNameController,
                decoration: _inputDecoration('Receiver Name', isDarkMode),
                validator: (value) => value!.isEmpty ? 'Please enter receiver name' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _receiverContactController,
                decoration: _inputDecoration('Receiver Contact', isDarkMode),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Please enter contact number' : null,
              ),

              // Delivery Date and Time
              const SizedBox(height: 25),
              _buildSectionTitle('Delivery Schedule', isDarkMode),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selectDate(context),
                      child: Text(
                        _selectedDate == null 
                          ? 'Select Date' 
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selectTime(context),
                      child: Text(
                        _selectedTime == null 
                          ? 'Select Time' 
                          : _selectedTime!.format(context),
                      ),
                    ),
                  ),
                ],
              ),

              // Package Type Selection
              const SizedBox(height: 25),
              _buildSectionTitle('Package Details', isDarkMode),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(border: InputBorder.none),
                  value: _selectedPackageType,
                  items: _packageTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPackageType = value;
                    });
                  },
                  validator: (value) => value == null ? 'Please select package type' : null,
                ),
              ),

              // Package Texture Selection
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(border: InputBorder.none),
                  value: _selectedPackageTexture,
                  items: _packageTextures.map((texture) {
                    return DropdownMenuItem(
                      value: texture,
                      child: Text(texture),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPackageTexture = value;
                    });
                  },
                  validator: (value) => value == null ? 'Please select package texture' : null,
                ),
              ),

              // Package Quantity
              const SizedBox(height: 15),
              TextFormField(
                controller: _packageQuantityController,
                decoration: _inputDecoration('Package Quantity', isDarkMode),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter package quantity' : null,
              ),

              // Package Description
              const SizedBox(height: 15),
              TextFormField(
                controller: _packageDescriptionController,
                decoration: _inputDecoration('Package Description', isDarkMode),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Please provide package description' : null,
              ),

              // Image Upload
              const SizedBox(height: 25),
              _buildSectionTitle('Package Images', isDarkMode),
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: Icon(Icons.upload_file),
                label: Text('Upload Package Images'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
              ),

              // Display Selected Images
              const SizedBox(height: 15),
              _buildImagePreview(),

              // Submit Button
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  'Submit Delivery Request',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create section titles
  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  // Input decoration helper method
  InputDecoration _inputDecoration(String label, bool isDarkMode) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.purple),
      ),
    );
  }

  // Image preview widget
  Widget _buildImagePreview() {
    return _packageImages.isEmpty
        ? Text(
            'No images selected',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          )
        : SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _packageImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Stack(
                    children: [
                      Image.file(
                        File(_packageImages[index].path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _packageImages.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
  }
}