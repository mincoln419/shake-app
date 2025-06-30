import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../services/todo_provider.dart';

class AddCategoryDialog extends ConsumerStatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  ConsumerState<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<AddCategoryDialog> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedColor = '#FF9800';

  final List<String> _colorOptions = [
    '#FF9800', // Orange
    '#2196F3', // Blue
    '#4CAF50', // Green
    '#9C27B0', // Purple
    '#F44336', // Red
    '#00BCD4', // Cyan
    '#FF5722', // Deep Orange
    '#3F51B5', // Indigo
    '#009688', // Teal
    '#E91E63', // Pink
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('새 카테고리 추가'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '카테고리 이름',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          const Text('색상 선택'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _colorOptions.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _parseColor(color),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColor == color ? Colors.black : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: _selectedColor == color
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _addCategory,
          child: const Text('추가'),
        ),
      ],
    );
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF${hexColor}', radix: 16));
  }

  void _addCategory() async {
    final name = _nameController.text.trim();
    
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리 이름을 입력해주세요')),
      );
      return;
    }

    // 중복 체크
    final exists = await ref.read(categoriesProvider.notifier).categoryExists(name);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미 존재하는 카테고리입니다')),
      );
      return;
    }

    final category = Category(
      name: name,
      color: _selectedColor,
      createdAt: DateTime.now(),
    );

    await ref.read(categoriesProvider.notifier).addCategory(category);
    
    Navigator.pop(context, true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('카테고리 "$name"이 추가되었습니다')),
    );
  }
} 