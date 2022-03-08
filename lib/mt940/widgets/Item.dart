import 'package:flutter/material.dart';
import '../models/Product.dart';

class Item extends StatefulWidget {
  final Product product;
  final ValueChanged<bool> onSelected;
  const Item({
    Key? key,
    required this.product,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<Item> createState() => _ItemState();
}

class _ItemState extends State<Item> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
          widget.onSelected(isSelected);
        });
      },
      child: Container(
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(width: 20, color: Colors.orange)
                      : null),
              child: Icon(
                widget.product.iconData,
                size: 32,
              ),
            ),
            Text(
              widget.product.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
